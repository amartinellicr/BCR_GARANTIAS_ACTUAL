using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Garantias_Fiduciarias_Tarjetas.
	/// </summary>
	public class Garantias_Fiduciarias_Tarjetas
	{
		#region Metodos Publicos

		public int Crear(string strTarjeta, int nTipoGarantia, int nClaseGarantia, string strCedulaFiador,
						int nTipoFiador, string strNombreFiador, int nTipoMitigador, int nTipoDocumento, 
						decimal nMontoMitigador, decimal nPorcentajeResponsabilidad, int nOperacionEspecial,
						int nTipoAcreedor, string strCedulaAcreedor, DateTime dFechaExpiracion, decimal nMontoCobertura, 
						string strCedulaDeudor, long nBIN, long nCodigoInterno, int nMoneda, int nOficinaRegistra,
                        string strUsuario, string strIP,
                        string strOperacionCrediticia,
                        string strObservacion, int nCodigoCatalogo)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_InsertarGarantiaFiduciariaTarjeta", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//Agrega los parametros
					oComando.Parameters.AddWithValue("@nTipoGarantia", nTipoGarantia);
					oComando.Parameters.AddWithValue("@nClaseGarantia", nClaseGarantia);
					oComando.Parameters.AddWithValue("@strCedulaFiador", strCedulaFiador);
					oComando.Parameters.AddWithValue("@strNombreFiador", strNombreFiador);
					oComando.Parameters.AddWithValue("@nTipoFiador", nTipoFiador);
					oComando.Parameters.AddWithValue("@strTarjeta", strTarjeta);
					oComando.Parameters.AddWithValue("@nTipoMitigador", nTipoMitigador);
					oComando.Parameters.AddWithValue("@nTipoDocumentoLegal", nTipoDocumento);
					oComando.Parameters.AddWithValue("@nMontoMitigador", nMontoMitigador);
					oComando.Parameters.AddWithValue("@nPorcentaje", nPorcentajeResponsabilidad);
					oComando.Parameters.AddWithValue("@nOperacionEspecial", nOperacionEspecial);
					oComando.Parameters.AddWithValue("@nTipoAcreedor", nTipoAcreedor);
					oComando.Parameters.AddWithValue("@strCedulaAcreedor", strCedulaAcreedor);
					oComando.Parameters.AddWithValue("@dFechaExpiracion", dFechaExpiracion);
					oComando.Parameters.AddWithValue("@nMontoCobertura", nMontoCobertura);
					oComando.Parameters.AddWithValue("@strCedulaDeudor", strCedulaDeudor);
					oComando.Parameters.AddWithValue("@nBIN", nBIN);
					oComando.Parameters.AddWithValue("@nCodigoInternoSISTAR", nCodigoInterno);
					oComando.Parameters.AddWithValue("@nMoneda", nMoneda);
					oComando.Parameters.AddWithValue("@nOficinaRegistra", nOficinaRegistra);
					oComando.Parameters.AddWithValue("@strObservacion", strObservacion);
					oComando.Parameters.AddWithValue("@codigo_catalogo", nCodigoCatalogo);
					oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
					oComando.Parameters.AddWithValue("@strIP", strIP);
					//oComando.Parameters.AddWithValue("@nOficina",nOficina);	

					//Obtener la información sobre la Tarjeta y sobre la Garantía Fiduciaria, esto por si se deben insertar
					DataSet dsTarjeta = AccesoBD.ejecutarConsulta("select " + ContenedorTarjeta.COD_TARJETA + "," +
							ContenedorTarjeta.COD_TIPO_GARANTIA +
							" from TAR_TARJETA " +
							" where " + ContenedorTarjeta.NUM_TARJETA + " = " + strTarjeta);

					DataSet dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA +
						" from TAR_GARANTIA_FIDUCIARIA " +
						" where " + ContenedorGarantia_fiduciaria.CEDULA_FIADOR + " = '" + strCedulaFiador + "'");


					//Abre la conexion
					oConexion.Open();

					//Ejecuta el comando
					int nMensaje = Convert.ToInt32(oComando.ExecuteScalar().ToString());

					if (nMensaje == 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						if ((dsTarjeta == null) || (dsTarjeta.Tables.Count == 0) || (dsTarjeta.Tables[0].Rows.Count == 0))
						{
							#region Tarjeta

							string strInsertaTarjeta = "INSERT INTO TAR_TARJETA(num_tarjeta,cedula_deudor,cod_bin," +
								"cod_interno_sistar,cod_moneda,cod_oficina_registra, cod_tipo_garantia, cod_estado_tarjeta) VALUES(" +
								strTarjeta + "," + strCedulaDeudor + "," + nBIN.ToString() + "," +
								nCodigoInterno.ToString() + "," + nMoneda.ToString() + "," + nOficinaRegistra.ToString() + "1, N)";

							oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
								ContenedorTarjeta.NUM_TARJETA,
								string.Empty,
								strTarjeta);

							oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
								ContenedorTarjeta.COD_BIN,
								string.Empty,
								nBIN.ToString());

							oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
								ContenedorTarjeta.COD_INTERNO_SISTAR,
								string.Empty,
								nCodigoInterno.ToString());

							oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
								ContenedorTarjeta.COD_MONEDA,
								string.Empty,
								oTraductor.TraducirTipoMoneda(nMoneda));

							oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
								ContenedorTarjeta.COD_OFICINA_REGISTRA,
								string.Empty,
								nOficinaRegistra.ToString());

							oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
								ContenedorTarjeta.CEDULA_DEUDOR,
								string.Empty,
								strCedulaDeudor);

							oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
								ContenedorTarjeta.COD_TIPO_GARANTIA,
								string.Empty,
								"1");

							oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
								ContenedorTarjeta.COD_ESTADO_TARJETA,
								string.Empty,
								"N");

							dsTarjeta = AccesoBD.ejecutarConsulta("select " + ContenedorTarjeta.COD_TARJETA + "," +
								ContenedorTarjeta.COD_TIPO_GARANTIA +
								" from TAR_TARJETA " +
								" where " + ContenedorTarjeta.NUM_TARJETA + " = " + strTarjeta);

							#endregion
						}
						else if ((dsTarjeta != null) || (dsTarjeta.Tables.Count > 0) || (dsTarjeta.Tables[0].Rows.Count > 0))
						{
							/*La tarjeta ya existe*/
							#region Actualiza tipo de garantía y elimina la garantía por perfil
							if (!dsTarjeta.Tables[0].Rows[0].IsNull(ContenedorTarjeta.COD_TIPO_GARANTIA))
							{
								int nTipogarantiaObtenida = Convert.ToInt32(dsTarjeta.Tables[0].Rows[0][ContenedorTarjeta.COD_TIPO_GARANTIA].ToString());

								string strDescripcion = oTraductor.TraducirCodigoTipoGarantiaTarjeta(nTipogarantiaObtenida.ToString());

								/*Se evalúa si la garantía es por perfil*/
								if ((nTipogarantiaObtenida != 1) && (strDescripcion.CompareTo("-") != 0))
								{
									#region Actualiza Tipo de garantía de la tarjeta

									string strActualizacionTipoGarantia = "UPDATE TAR_TARJETA " +
																		  "SET cod_tipo_garantia = 1 " +
																		  "WHERE cod_tarjeta = " + dsTarjeta.Tables[0].Rows[0][ContenedorTarjeta.COD_TARJETA].ToString();

									oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
									2, nTipoGarantia, strCedulaFiador, strTarjeta, strActualizacionTipoGarantia, string.Empty,
									ContenedorTarjeta.COD_TIPO_GARANTIA,
									nTipogarantiaObtenida.ToString(),
									"1");

									#endregion

									#region Elimina garantía por perfil

									string streliminarGarantiaXPerfil = "DELETE TAR_GARANTIAS_X_PERFIL_X_TARJETA " +
																		"WHERE cod_tarjeta = " + dsTarjeta.Tables[0].Rows[0][ContenedorTarjeta.COD_TARJETA].ToString();

									/*Se obtiene la garantía por perfil antes de eliminarla*/
									DataSet dsGarantiaXPerfil = AccesoBD.ejecutarConsulta("select " + ContenedorGarantias_x_perfil_x_tarjeta.OBSERVACIONES +
										" from " + ContenedorGarantias_x_perfil_x_tarjeta.NOMBRE_ENTIDAD +
										" where " + ContenedorGarantias_x_perfil_x_tarjeta.COD_TARJETA + " = " + dsTarjeta.Tables[0].Rows[0][ContenedorTarjeta.COD_TARJETA].ToString());

									if ((dsGarantiaXPerfil != null) && (dsGarantiaXPerfil.Tables.Count > 0) && (dsGarantiaXPerfil.Tables[0].Rows.Count > 0))
									{
										if (!dsGarantiaXPerfil.Tables[0].Rows[0].IsNull(ContenedorGarantias_x_perfil_x_tarjeta.OBSERVACIONES))
										{
											string strObservacionesObt = dsGarantiaXPerfil.Tables[0].Rows[0][ContenedorGarantias_x_perfil_x_tarjeta.OBSERVACIONES].ToString();

											if (strObservacionesObt != string.Empty)
											{
												oBitacora.InsertarBitacora("TAR_GARANTIAS_X_PERFIL_X_TARJETA", strUsuario, strIP, null,
												3, 4, string.Empty, strTarjeta, streliminarGarantiaXPerfil, string.Empty,
												ContenedorGarantias_x_perfil_x_tarjeta.OBSERVACIONES,
												strObservacionesObt,
												string.Empty);
											}
										}
									}
									#endregion
								}
							}
							#endregion
						}

						if ((dsGarantiaFiduciaria == null) || (dsGarantiaFiduciaria.Tables.Count == 0) || (dsGarantiaFiduciaria.Tables[0].Rows.Count == 0))
						{
							#region Garantía Fiduciaria

							string strInsertaGarFiduTarjeta = "INSERT INTO TAR_GARANTIA_FIDUCIARIA(cod_tipo_garantia,cod_clase_garantia," +
								"cedula_fiador,nombre_fiador,cod_tipo_fiador) VALUES(" + nTipoGarantia.ToString() + "," +
								nClaseGarantia.ToString() + "," + strCedulaFiador + "," + strNombreFiador + "," + nTipoFiador.ToString() + ")";

							oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduTarjeta, string.Empty,
								ContenedorGarantia_fiduciaria.CEDULA_FIADOR,
								string.Empty,
								strCedulaFiador);

							oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduTarjeta, string.Empty,
								ContenedorGarantia_fiduciaria.COD_CLASE_GARANTIA,
								string.Empty,
								oTraductor.TraducirClaseGarantia(nClaseGarantia));

							oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduTarjeta, string.Empty,
								ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR,
								string.Empty,
								oTraductor.TraducirTipoPersona(nTipoFiador));

							oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduTarjeta, string.Empty,
								ContenedorGarantia_fiduciaria.COD_TIPO_GARANTIA,
								string.Empty,
								oTraductor.TraducirTipoGarantia(nTipoGarantia));

							oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduTarjeta, string.Empty,
								ContenedorGarantia_fiduciaria.NOMBRE_FIADOR,
								string.Empty,
								strNombreFiador);

							dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA +
								" from TAR_GARANTIA_FIDUCIARIA " +
								" where " + ContenedorGarantia_fiduciaria.CEDULA_FIADOR + " = '" + strCedulaFiador + "'");

							#endregion
						}

						if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
						{
							#region Garantía Fiduciciaria por Tarjeta

							string strCodigoGarFidu = dsGarantiaFiduciaria.Tables[0].Rows[0][ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA].ToString();
							string strCodigoTarjeta = dsTarjeta.Tables[0].Rows[0][ContenedorTarjeta.COD_TARJETA].ToString();

							long nGarantiaFiduciaria = (long)Convert.ToInt32(strCodigoGarFidu);

							string strInsertaGarFiduXTarjeta = "INSERT INTO TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA (" +
								"cod_tarjeta,cod_garantia_fiduciaria,cod_tipo_mitigador,cod_tipo_documento_legal," +
								"monto_mitigador,porcentaje_responsabilidad,cod_operacion_especial,cod_tipo_acreedor," +
								"cedula_acreedor,fecha_expiracion,monto_cobertura, des_observacion) VALUES(" + strTarjeta + "," +
								strCodigoGarFidu + "," + nTipoMitigador.ToString() + "," + nTipoDocumento.ToString() + "," +
								nMontoMitigador.ToString() + "," + nPorcentajeResponsabilidad.ToString() + "," +
								nOperacionEspecial.ToString() + "," + nTipoAcreedor.ToString() + "," +
								strCedulaAcreedor + "," + dFechaExpiracion + "," + nMontoCobertura.ToString() + "," + strObservacion + ")";


							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
								ContenedorGarantias_fiduciarias_x_tarjeta.CEDULA_ACREEDOR,
								string.Empty,
								strCedulaAcreedor);

							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
								ContenedorGarantias_fiduciarias_x_tarjeta.COD_GARANTIA_FIDUCIARIA,
								string.Empty,
								strCedulaFiador);

							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
								ContenedorGarantias_fiduciarias_x_tarjeta.COD_TARJETA,
								string.Empty,
								strTarjeta);

							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
								ContenedorGarantias_fiduciarias_x_tarjeta.COD_OPERACION_ESPECIAL,
								string.Empty,
								oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));

							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
								ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_ACREEDOR,
								string.Empty,
								oTraductor.TraducirTipoPersona(nTipoAcreedor));

							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
								ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_DOCUMENTO_LEGAL,
								string.Empty,
								oTraductor.TraducirTipoDocumento(nTipoDocumento));

							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
								ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_MITIGADOR,
								string.Empty,
								oTraductor.TraducirTipoMitigador(nTipoMitigador));

							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
								ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_MITIGADOR,
								string.Empty,
								nMontoMitigador.ToString());

							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
								ContenedorGarantias_fiduciarias_x_tarjeta.PORCENTAJE_RESPONSABILIDAD,
								string.Empty,
								nPorcentajeResponsabilidad.ToString());

							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
								1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
								ContenedorGarantias_fiduciarias_x_tarjeta.FECHA_EXPIRACION,
								string.Empty,
								dFechaExpiracion.ToShortDateString());

							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
							   1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
							   ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_COBERTURA,
							   string.Empty,
							   nMontoCobertura.ToString());

							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
							   1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
							   ContenedorGarantias_fiduciarias_x_tarjeta.DES_OBSERVACION,
							   string.Empty,
							   strObservacion);

							#endregion
						}

						#endregion
					}

					return nMensaje;
				}
			}
			catch
			{
				throw;
			}
		}

		public void Modificar(long nGarantiaFiduciaria, long nTarjeta, string strCedulaFiador, int nTipoFiador, 
							string strNombreFiador, int nTipoMitigador, int nTipoDocumento, decimal nMontoMitigador, 
							decimal nPorcentajeResponsabilidad, int nOperacionEspecial, int nTipoAcreedor, 
							string strCedulaAcreedor, DateTime dFechaExpiracion, decimal nMontoCobertura,
                            string strUsuario, string strIP,
                            string strOperacionCrediticia,
                            string strObservacion)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_ModificarGarantiaFiduciariaTarjeta", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//Agrega los parametros
					oComando.Parameters.AddWithValue("@nGarantiaFiduciaria", nGarantiaFiduciaria);
					oComando.Parameters.AddWithValue("@nTarjeta", nTarjeta);
					oComando.Parameters.AddWithValue("@strCedulaFiador", strCedulaFiador);
					oComando.Parameters.AddWithValue("@strNombreFiador", strNombreFiador);
					oComando.Parameters.AddWithValue("@nTipoFiador", nTipoFiador);
					oComando.Parameters.AddWithValue("@nTipoMitigador", nTipoMitigador);
					oComando.Parameters.AddWithValue("@nTipoDocumentoLegal", nTipoDocumento);
					oComando.Parameters.AddWithValue("@nMontoMitigador", nMontoMitigador);
					oComando.Parameters.AddWithValue("@nPorcentaje", nPorcentajeResponsabilidad);
					oComando.Parameters.AddWithValue("@nOperacionEspecial", nOperacionEspecial);
					oComando.Parameters.AddWithValue("@nTipoAcreedor", nTipoAcreedor);
					oComando.Parameters.AddWithValue("@strCedulaAcreedor", strCedulaAcreedor);
					oComando.Parameters.AddWithValue("@dFechaExpiracion", dFechaExpiracion);
					oComando.Parameters.AddWithValue("@nMontoCobertura", nMontoCobertura);
					oComando.Parameters.AddWithValue("@strObservacion", strObservacion);
					oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
					oComando.Parameters.AddWithValue("@strIP", strIP);
					//oComando.Parameters.AddWithValue("@nOficina",nOficina);	


					#region Obtener los datos de la BD antes de que cambien

					DataSet dsGarantiaFiduciariaXTarjeta = new DataSet();

					DataSet dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR + " from TAR_GARANTIA_FIDUCIARIA where " + ContenedorGarantia_fiduciaria.CEDULA_FIADOR + " = '" + strCedulaFiador + "'");

					if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
					{
						dsGarantiaFiduciariaXTarjeta = AccesoBD.ejecutarConsulta("select " +
							 ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_MITIGADOR + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_DOCUMENTO_LEGAL + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_MITIGADOR + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.PORCENTAJE_RESPONSABILIDAD + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.COD_OPERACION_ESPECIAL + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_ACREEDOR + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.CEDULA_ACREEDOR + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.FECHA_EXPIRACION + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_COBERTURA + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.DES_OBSERVACION +
							 " from " + ContenedorGarantias_fiduciarias_x_tarjeta.NOMBRE_ENTIDAD +
							 " where " + ContenedorGarantias_fiduciarias_x_tarjeta.COD_TARJETA + " = " + nTarjeta.ToString() +
							 " and " + ContenedorGarantias_fiduciarias_x_tarjeta.COD_GARANTIA_FIDUCIARIA + " = " + nGarantiaFiduciaria.ToString());
					}

					//Se obtiene el número de tarjeta
					DataSet dsTarjeta = AccesoBD.ejecutarConsulta("select " + ContenedorTarjeta.NUM_TARJETA +
						" from " + ContenedorTarjeta.NOMBRE_ENTIDAD +
						" where " + ContenedorTarjeta.COD_TARJETA + " = " + nTarjeta.ToString());

					string strNumeroTarjeta = "-";

					if ((dsTarjeta != null) && (dsTarjeta.Tables.Count > 0) && (dsTarjeta.Tables[0].Rows.Count > 0))
					{
						if (!dsTarjeta.Tables[0].Rows[0].IsNull(ContenedorTarjeta.NUM_TARJETA))
						{
							strNumeroTarjeta = dsTarjeta.Tables[0].Rows[0][ContenedorTarjeta.NUM_TARJETA].ToString();
						}
					}

					#endregion

					//Abre la conexion
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						if ((dsGarantiaFiduciariaXTarjeta != null) && (dsGarantiaFiduciariaXTarjeta.Tables.Count > 0) && (dsGarantiaFiduciariaXTarjeta.Tables[0].Rows.Count > 0))
						{
							#region Garantía Fiduciaria por Tarjeta

							string strModificaGarFiduXTarjeta = "UPDATE TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA SET cod_tipo_mitigador = " + nTipoMitigador.ToString() +
												 ",cod_tipo_documento_legal = " + nTipoDocumento.ToString() +
												 ",monto_mitigador = " + nMontoMitigador.ToString() + ",porcentaje_responsabilidad = " +
												 nPorcentajeResponsabilidad.ToString() + ",cod_operacion_especial = " +
												 nOperacionEspecial.ToString() + ",cod_tipo_acreedor = " + nTipoAcreedor.ToString() + ",cedula_acreedor = " +
												 strCedulaAcreedor + ",fecha_expiracion = " + dFechaExpiracion.ToShortDateString() + "', monto_cobertura = " +
												 nMontoCobertura.ToString() +
												 " WHERE cod_tarjeta = " + nTarjeta.ToString() +
												 " AND cod_garantia_fiduciaria = " + nGarantiaFiduciaria.ToString();

							if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_MITIGADOR))
							{
								int nTipoMitigadorObt = Convert.ToInt32(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_MITIGADOR].ToString());

								if (nTipoMitigadorObt != nTipoMitigador)
								{
									oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_MITIGADOR,
									   oTraductor.TraducirTipoMitigador(nTipoMitigadorObt),
									   oTraductor.TraducirTipoMitigador(nTipoMitigador));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_MITIGADOR,
									   string.Empty,
									   oTraductor.TraducirTipoMitigador(nTipoMitigador));
							}

							if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_DOCUMENTO_LEGAL))
							{
								int nTipoDocumentoLegalObt = Convert.ToInt32(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_DOCUMENTO_LEGAL].ToString());

								if (nTipoDocumentoLegalObt != nTipoDocumento)
								{
									oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_DOCUMENTO_LEGAL,
									   oTraductor.TraducirTipoDocumento(nTipoDocumentoLegalObt),
									   oTraductor.TraducirTipoDocumento(nTipoDocumento));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_DOCUMENTO_LEGAL,
									   string.Empty,
									   oTraductor.TraducirTipoDocumento(nTipoDocumento));
							}

							if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_MITIGADOR))
							{
								decimal nMontoMitigadorObt = Convert.ToDecimal(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_MITIGADOR].ToString());

								if (nMontoMitigadorObt != nMontoMitigador)
								{
									oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_MITIGADOR,
									   nMontoMitigadorObt.ToString(),
									   nMontoMitigador.ToString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_MITIGADOR,
									   string.Empty,
									   nMontoMitigador.ToString());
							}

							if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_tarjeta.PORCENTAJE_RESPONSABILIDAD))
							{
								decimal nPorcentajeResponsabilidadObt = Convert.ToDecimal(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_tarjeta.PORCENTAJE_RESPONSABILIDAD].ToString());

								if (nPorcentajeResponsabilidadObt != nPorcentajeResponsabilidad)
								{
									oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.PORCENTAJE_RESPONSABILIDAD,
									   nPorcentajeResponsabilidadObt.ToString(),
									   nPorcentajeResponsabilidad.ToString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.PORCENTAJE_RESPONSABILIDAD,
									   string.Empty,
									   nPorcentajeResponsabilidad.ToString());
							}

							if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_tarjeta.COD_OPERACION_ESPECIAL))
							{
								int nOperacionEspecialObt = Convert.ToInt32(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_tarjeta.COD_OPERACION_ESPECIAL].ToString());

								if (nOperacionEspecialObt != nOperacionEspecial)
								{
									oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.COD_OPERACION_ESPECIAL,
									   oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecialObt),
									   oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.COD_OPERACION_ESPECIAL,
									   string.Empty,
									   oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));
							}

							if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_ACREEDOR))
							{
								int nTipoAcreedorObt = Convert.ToInt32(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_ACREEDOR].ToString());

								if (nTipoAcreedorObt != nTipoAcreedor)
								{
									oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_ACREEDOR,
									   oTraductor.TraducirTipoPersona(nTipoAcreedorObt),
									   oTraductor.TraducirTipoPersona(nTipoAcreedor));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_ACREEDOR,
									   string.Empty,
									   oTraductor.TraducirTipoPersona(nTipoAcreedor));
							}

							if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_tarjeta.CEDULA_ACREEDOR))
							{
								string strCedulaAcreedorObt = dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_tarjeta.CEDULA_ACREEDOR].ToString();

								if (strCedulaAcreedorObt.CompareTo(strCedulaAcreedor) != 0)
								{
									oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.CEDULA_ACREEDOR,
									   strCedulaAcreedorObt,
									   strCedulaAcreedor);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.CEDULA_ACREEDOR,
									   string.Empty,
									   strCedulaAcreedor);
							}

							if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_tarjeta.FECHA_EXPIRACION))
							{
								DateTime dFechaExperiracionObtenida = Convert.ToDateTime(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_tarjeta.FECHA_EXPIRACION].ToString());

								if (dFechaExperiracionObtenida != dFechaExpiracion)
								{
									oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.FECHA_EXPIRACION,
									   dFechaExperiracionObtenida.ToShortDateString(),
									   dFechaExpiracion.ToShortDateString());

								}
							}
							else
							{
								oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.FECHA_EXPIRACION,
									   string.Empty,
									   dFechaExpiracion.ToShortDateString());
							}

							if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_COBERTURA))
							{
								decimal nMontoCoberturaObtenido = Convert.ToDecimal(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_COBERTURA].ToString());

								if (nMontoCoberturaObtenido != nMontoCobertura)
								{
									oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_COBERTURA,
									   nMontoCoberturaObtenido.ToString(),
									   nMontoCobertura.ToString());

								}
							}
							else
							{
								oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_COBERTURA,
									   string.Empty,
									   nMontoCobertura.ToString());
							}

							if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_tarjeta.DES_OBSERVACION))
							{
								string strObservacionObtenida = dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_tarjeta.DES_OBSERVACION].ToString();

								if (strObservacionObtenida.CompareTo(strObservacion) != 0)
								{
									oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.DES_OBSERVACION,
									   strObservacionObtenida,
									   strObservacion);

								}
							}
							else
							{
								oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
									   ContenedorGarantias_fiduciarias_x_tarjeta.DES_OBSERVACION,
									   string.Empty,
									   strObservacion);
							}

							#endregion
						}

						if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
						{
							#region Garantía Fiduciaria

							string strModificaGarFiduTarjeta = "UPDATE TAR_GARANTIA_FIDUCIARIA SET cod_tipo_fiador = " + nTipoFiador.ToString() +
								" WHERE cedula_fiador = '" + strCedulaFiador + "'";

							if (!dsGarantiaFiduciaria.Tables[0].Rows[0].IsNull(ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR))
							{
								int nTipoFiadorObt = Convert.ToInt32(dsGarantiaFiduciaria.Tables[0].Rows[0][ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR].ToString());

								if (nTipoFiadorObt != nTipoFiador)
								{
									oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduTarjeta, string.Empty,
									   ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR,
									   oTraductor.TraducirTipoPersona(nTipoFiadorObt),
									   oTraductor.TraducirTipoPersona(nTipoFiador));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
									  2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduTarjeta, string.Empty,
									  ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR,
									  string.Empty,
									  oTraductor.TraducirTipoPersona(nTipoFiador));
							}

							#endregion
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

        public void Eliminar(long nGarantiaFiduciaria, long nTarjeta, string strUsuario, string strIP,
                             string strOperacionCrediticia)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_EliminarGarantiaFiduciariaTarjeta", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();


					#region Obtener los datos de la BD antes de ser borrados

					DataSet dsGarantiaFiduciariaXTarjeta = new DataSet();

					//Se obtienen los datos antes de ser borrados, para luego insertalos en la bitácora
					string strConsultaGarFiduXTarjeta = "select " +
							 ContenedorGarantias_fiduciarias_x_tarjeta.COD_GARANTIA_FIDUCIARIA + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.COD_TARJETA + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_MITIGADOR + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_DOCUMENTO_LEGAL + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_MITIGADOR + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.PORCENTAJE_RESPONSABILIDAD + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.COD_OPERACION_ESPECIAL + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_ACREEDOR + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.CEDULA_ACREEDOR + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.FECHA_EXPIRACION + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.MONTO_COBERTURA + "," +
							 ContenedorGarantias_fiduciarias_x_tarjeta.DES_OBSERVACION +
							 " from " + ContenedorGarantias_fiduciarias_x_tarjeta.NOMBRE_ENTIDAD +
							 " where " + ContenedorGarantias_fiduciarias_x_tarjeta.COD_TARJETA + " = " + nTarjeta.ToString() +
							 " and " + ContenedorGarantias_fiduciarias_x_tarjeta.COD_GARANTIA_FIDUCIARIA + " = " + nGarantiaFiduciaria.ToString();

					dsGarantiaFiduciariaXTarjeta = AccesoBD.ejecutarConsulta(strConsultaGarFiduXTarjeta);

					//Se obtiene el número de la Tarjeta

					DataSet dsTarjeta = AccesoBD.ejecutarConsulta("select " + ContenedorTarjeta.NUM_TARJETA +
						" from " + ContenedorTarjeta.NOMBRE_ENTIDAD +
						" where " + ContenedorTarjeta.COD_TARJETA + " = " + nTarjeta.ToString());

					string strNumeroTarjeta = "-";

					if ((dsTarjeta != null) && (dsTarjeta.Tables.Count > 0) && (dsTarjeta.Tables[0].Rows.Count > 0))
					{
						if (!dsTarjeta.Tables[0].Rows[0].IsNull(ContenedorTarjeta.NUM_TARJETA))
						{
							strNumeroTarjeta = dsTarjeta.Tables[0].Rows[0][ContenedorTarjeta.NUM_TARJETA].ToString();
						}
					}

					#endregion

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//Agrega los parametros
					oComando.Parameters.AddWithValue("@nGarantiaFiduciaria", nGarantiaFiduciaria);
					oComando.Parameters.AddWithValue("@nTarjeta", nTarjeta);
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

						string strEliminarGarFiduXTarjeta = "DELETE TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA " +
							"WHERE cod_tarjeta = " + nTarjeta.ToString() +
							" AND cod_garantia_fiduciaria = " + nGarantiaFiduciaria.ToString();


						string strCedulaFiador = oTraductor.ObtenerCedulaFiadorGarFiduTar(nGarantiaFiduciaria.ToString());

						//string strCedulaDeudor = oTraductor.ObtenerCedulaDeudorTarjeta(nTarjeta.ToString());

						if ((dsGarantiaFiduciariaXTarjeta != null) && (dsGarantiaFiduciariaXTarjeta.Tables.Count > 0) && (dsGarantiaFiduciariaXTarjeta.Tables[0].Rows.Count > 0))
						{
							#region Garantía Fiduciaria por Tarjeta

							foreach (DataRow drGarFiduXTar in dsGarantiaFiduciariaXTarjeta.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drGarFiduXTar.Table.Columns.Count; nIndice++)
								{
									switch (drGarFiduXTar.Table.Columns[nIndice].ColumnName)
									{
										case ContenedorGarantias_fiduciarias_x_tarjeta.COD_GARANTIA_FIDUCIARIA: oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
																									   3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
																									   drGarFiduXTar.Table.Columns[nIndice].ColumnName,
																									   strCedulaFiador,
																									   string.Empty);
											break;

										case ContenedorGarantias_fiduciarias_x_tarjeta.COD_TARJETA: oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
																									   3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
																									   drGarFiduXTar.Table.Columns[nIndice].ColumnName,
																									   strNumeroTarjeta,
																									   string.Empty);
											break;

										case ContenedorGarantias_fiduciarias_x_tarjeta.COD_OPERACION_ESPECIAL:
											if (drGarFiduXTar[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
												   3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
												   drGarFiduXTar.Table.Columns[nIndice].ColumnName,
												   oTraductor.TraducirTipoOperacionEspecial(Convert.ToInt32(drGarFiduXTar[nIndice, DataRowVersion.Current].ToString())),
												   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
												   3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
												   drGarFiduXTar.Table.Columns[nIndice].ColumnName,
												   string.Empty,
												   string.Empty);
											}

											break;

										case ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_ACREEDOR:
											if (drGarFiduXTar[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
													   3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
													   drGarFiduXTar.Table.Columns[nIndice].ColumnName,
													   oTraductor.TraducirTipoPersona(Convert.ToInt32(drGarFiduXTar[nIndice, DataRowVersion.Current].ToString())),
													   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
													   3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
													   drGarFiduXTar.Table.Columns[nIndice].ColumnName,
													   string.Empty,
													   string.Empty);
											}
											break;

										case ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_DOCUMENTO_LEGAL:
											if (drGarFiduXTar[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
														   3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
														   drGarFiduXTar.Table.Columns[nIndice].ColumnName,
														   oTraductor.TraducirTipoDocumento(Convert.ToInt32(drGarFiduXTar[nIndice, DataRowVersion.Current].ToString())),
														   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
														   3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
														   drGarFiduXTar.Table.Columns[nIndice].ColumnName,
														   string.Empty,
														   string.Empty);
											}
											break;

										case ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_MITIGADOR:
											if (drGarFiduXTar[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
															   3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
															   drGarFiduXTar.Table.Columns[nIndice].ColumnName,
															   oTraductor.TraducirTipoMitigador(Convert.ToInt32(drGarFiduXTar[nIndice, DataRowVersion.Current].ToString())),
															   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
															  3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
															  drGarFiduXTar.Table.Columns[nIndice].ColumnName,
															  string.Empty,
															  string.Empty);
											}
											break;

										default: oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
												  3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
												  drGarFiduXTar.Table.Columns[nIndice].ColumnName,
												  drGarFiduXTar[nIndice, DataRowVersion.Current].ToString(),
												  string.Empty);
											break;
									}

								}
							}

							#endregion
						}
						else
						{
							oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
								3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
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
