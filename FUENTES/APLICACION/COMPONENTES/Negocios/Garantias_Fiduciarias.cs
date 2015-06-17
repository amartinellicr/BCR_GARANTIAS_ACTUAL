using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Garantias_Fiduciarias.
	/// </summary>
	public class Garantias_Fiduciarias
	{
		#region Metodos Publicos
		public void Crear(long nOperacion, int nTipoGarantia, int nClaseGarantia, string strCedulaFiador,
						  int nTipoFiador, string strNombreFiador, int nTipoMitigador, int nTipoDocumento, 
						  decimal nMontoMitigador, decimal nPorcentajeResponsabilidad, int nOperacionEspecial,
						  int nTipoAcreedor, string strCedulaAcreedor, string strUsuario, string strIP,
                          string strOperacionCrediticia)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_InsertarGarantiaFiduciaria", oConexion);
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
					oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
					oComando.Parameters.AddWithValue("@nTipoMitigador", nTipoMitigador);
					oComando.Parameters.AddWithValue("@nTipoDocumentoLegal", nTipoDocumento);
					oComando.Parameters.AddWithValue("@nMontoMitigador", nMontoMitigador);
					oComando.Parameters.AddWithValue("@nPorcentaje", nPorcentajeResponsabilidad);
					oComando.Parameters.AddWithValue("@nOperacionEspecial", nOperacionEspecial);
					oComando.Parameters.AddWithValue("@nTipoAcreedor", nTipoAcreedor);
					oComando.Parameters.AddWithValue("@strCedulaAcreedor", strCedulaAcreedor);
					oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
					oComando.Parameters.AddWithValue("@strIP", strIP);
					//oComando.Parameters.AddWithValue("@nOficina",nOficina);	

					//Se obtiene la información de la Garantía Fiduciaria, esto por si se debe insertar
					DataSet dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA +
						   " from GAR_GARANTIA_FIDUCIARIA " +
						   " where " + ContenedorGarantia_fiduciaria.CEDULA_FIADOR + " = '" + strCedulaFiador + "'");

					//Abre la conexion
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						if ((dsGarantiaFiduciaria == null) || (dsGarantiaFiduciaria.Tables.Count == 0) || (dsGarantiaFiduciaria.Tables[0].Rows.Count == 0))
						{
							#region Garantía Fiduciaria

							string strInsertaGarantiaFiduciaria = "INSERT INTO GAR_GARANTIA_FIDUCIARIA (cod_tipo_garantia, cod_clase_garantia," +
									"cedula_fiador, nombre_fiador, cod_tipo_fiador) VALUES(" +
									nTipoGarantia.ToString() + "," + nClaseGarantia.ToString() + "," +
									strCedulaFiador + "," + strNombreFiador + "," + nTipoFiador.ToString() + ")";

							oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
								1, 1,
								strCedulaFiador, strOperacionCrediticia, strInsertaGarantiaFiduciaria, string.Empty,
								ContenedorGarantia_fiduciaria.CEDULA_FIADOR,
								string.Empty,
								strCedulaFiador);

							oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarantiaFiduciaria, string.Empty,
								ContenedorGarantia_fiduciaria.COD_CLASE_GARANTIA,
								string.Empty,
								oTraductor.TraducirClaseGarantia(nClaseGarantia));

							oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarantiaFiduciaria, string.Empty,
								ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR,
								string.Empty,
								oTraductor.TraducirTipoPersona(nTipoFiador));

							oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarantiaFiduciaria, string.Empty,
								ContenedorGarantia_fiduciaria.COD_TIPO_GARANTIA,
								string.Empty,
								oTraductor.TraducirTipoGarantia(nTipoGarantia));

							oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarantiaFiduciaria, string.Empty,
								ContenedorGarantia_fiduciaria.NOMBRE_FIADOR,
								string.Empty,
								strNombreFiador);

							dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA +
								" from GAR_GARANTIA_FIDUCIARIA " +
								" where " + ContenedorGarantia_fiduciaria.CEDULA_FIADOR + " = '" + strCedulaFiador + "'");

							#endregion
						}

						if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
						{
							#region Garantía Fiduciaria por Operación

							string strCodigoGarFidu = dsGarantiaFiduciaria.Tables[0].Rows[0][ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA].ToString();

							string strInsertaGarFiduXOperacion = "INSERT INTO GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION(cod_operacion, cod_garantia_fiduciaria," +
								"cod_tipo_mitigador,cod_tipo_documento_legal,monto_mitigador,porcentaje_responsabilidad,cod_operacion_especial,cod_tipo_acreedor," +
								"cedula_acreedor) VALUES(" + nOperacion.ToString() + "," + strCodigoGarFidu + "," +
								nTipoMitigador.ToString() + "," + nTipoDocumento.ToString() + "," + nMontoMitigador.ToString() + "," +
								nPorcentajeResponsabilidad.ToString() + "," + nOperacionEspecial.ToString() + "," +
								nTipoAcreedor.ToString() + "," + strCedulaAcreedor + ")";

							long nGarantiaFiduciaria = (long)Convert.ToInt32(strCodigoGarFidu);

							oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
								ContenedorGarantias_fiduciarias_x_operacion.CEDULA_ACREEDOR,
								string.Empty,
								strCedulaAcreedor);

							oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
								ContenedorGarantias_fiduciarias_x_operacion.COD_GARANTIA_FIDUCIARIA,
								string.Empty,
								strCedulaFiador);

							oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
								ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION,
								string.Empty,
								strOperacionCrediticia);

							oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
								ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION_ESPECIAL,
								string.Empty,
								oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));

							oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
								ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_ACREEDOR,
								string.Empty,
								oTraductor.TraducirTipoPersona(nTipoAcreedor));

							oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
								ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_DOCUMENTO_LEGAL,
								string.Empty,
								oTraductor.TraducirTipoDocumento(nTipoDocumento));

							oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
								ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_MITIGADOR,
								string.Empty,
								oTraductor.TraducirTipoMitigador(nTipoMitigador));

							oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
								ContenedorGarantias_fiduciarias_x_operacion.MONTO_MITIGADOR, "0", nMontoMitigador.ToString());

							oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
								1, 1, strCedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
								ContenedorGarantias_fiduciarias_x_operacion.PORCENTAJE_RESPONSABILIDAD, "0", nPorcentajeResponsabilidad.ToString());

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

		public void Modificar(long nGarantiaFiduciaria, long nOperacion, string strCedulaFiador, int nTipoFiador, 
							string strNombreFiador, int nTipoMitigador, int nTipoDocumento, decimal nMontoMitigador, 
							decimal nPorcentajeResponsabilidad, int nOperacionEspecial, int nTipoAcreedor,
                            string strCedulaAcreedor, string strUsuario, string strIP,
                            string strOperacionCrediticia)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_ModificarGarantiaFiduciaria", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//Agrega los parametros
					oComando.Parameters.AddWithValue("@nGarantiaFiduciaria", nGarantiaFiduciaria);
					oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
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
					oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
					oComando.Parameters.AddWithValue("@strIP", strIP);
					//oComando.Parameters.AddWithValue("@nOficina",nOficina);	

					DataSet dsGarantiaFiduciariaXOperacion = new DataSet();

					DataSet dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR +
						" from GAR_GARANTIA_FIDUCIARIA" +
						" where " + ContenedorGarantia_fiduciaria.CEDULA_FIADOR + " = '" + strCedulaFiador + "'");


					dsGarantiaFiduciariaXOperacion = AccesoBD.ejecutarConsulta("select " +
						ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_MITIGADOR + "," +
						ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_DOCUMENTO_LEGAL + "," +
						ContenedorGarantias_fiduciarias_x_operacion.MONTO_MITIGADOR + "," +
						ContenedorGarantias_fiduciarias_x_operacion.PORCENTAJE_RESPONSABILIDAD + "," +
						ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION_ESPECIAL + "," +
						ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_ACREEDOR + "," +
						ContenedorGarantias_fiduciarias_x_operacion.CEDULA_ACREEDOR +
						" from " + ContenedorGarantias_fiduciarias_x_operacion.NOMBRE_ENTIDAD +
						" where " + ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION + " = " + nOperacion.ToString() +
						" and " + ContenedorGarantias_fiduciarias_x_operacion.COD_GARANTIA_FIDUCIARIA + " = " + nGarantiaFiduciaria.ToString());


					//Abre la conexion
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						#region Garantía Fiduciaria por Operación

						if ((dsGarantiaFiduciariaXOperacion != null) && (dsGarantiaFiduciariaXOperacion.Tables.Count > 0) && (dsGarantiaFiduciariaXOperacion.Tables[0].Rows.Count > 0))
						{
							string strModificarGarFiduXOperacion = "UPDATE GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION SET cod_tipo_mitigador = " + nTipoMitigador.ToString() +
												 ",cod_tipo_documento_legal = " + nTipoDocumento.ToString() +
												 ",monto_mitigador = " + nMontoMitigador.ToString() + ",porcentaje_responsabilidad = " +
												 nPorcentajeResponsabilidad.ToString() + ",cod_operacion_especial = " +
												 nOperacionEspecial.ToString() + ",cod_tipo_acreedor = " + nTipoAcreedor.ToString() + ",cedula_acreedor = " +
												 strCedulaAcreedor + " WHERE cod_operacion = " + nOperacion.ToString() +
												 " AND cod_garantia_fiduciaria = " + nGarantiaFiduciaria.ToString();


							//Campo deshabilitado en la interfaz
							if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_MITIGADOR))
							{
								int nTipoMitigadorObtenido = Convert.ToInt32(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_MITIGADOR].ToString());

								if (nTipoMitigadorObtenido != nTipoMitigador)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_MITIGADOR,
									   oTraductor.TraducirTipoMitigador(nTipoMitigadorObtenido),
									   oTraductor.TraducirTipoMitigador(nTipoMitigador));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_MITIGADOR,
									   string.Empty,
									   oTraductor.TraducirTipoMitigador(nTipoMitigador));
							}

							if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_DOCUMENTO_LEGAL))
							{
								int nTipoDocumentoObt = Convert.ToInt32(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_DOCUMENTO_LEGAL].ToString());

								if (nTipoDocumentoObt != nTipoDocumento)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_DOCUMENTO_LEGAL,
									   oTraductor.TraducirTipoDocumento(nTipoDocumentoObt),
									   oTraductor.TraducirTipoDocumento(nTipoDocumento));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_DOCUMENTO_LEGAL,
									   string.Empty,
									   oTraductor.TraducirTipoDocumento(nTipoDocumento));
							}

							//Campo deshabilitado en la interfaz
							if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_operacion.MONTO_MITIGADOR))
							{
								decimal nMontoObtenido = Convert.ToDecimal(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_operacion.MONTO_MITIGADOR].ToString());

								if (nMontoObtenido != nMontoMitigador)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.MONTO_MITIGADOR,
									   nMontoObtenido.ToString(),
									   nMontoMitigador.ToString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									  2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									  ContenedorGarantias_fiduciarias_x_operacion.MONTO_MITIGADOR,
									  string.Empty,
									  nMontoMitigador.ToString());
							}

							if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_operacion.PORCENTAJE_RESPONSABILIDAD))
							{
								decimal nPorcentajeResponsabilidadObt = Convert.ToDecimal(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_operacion.PORCENTAJE_RESPONSABILIDAD].ToString());

								if (nPorcentajeResponsabilidadObt != nPorcentajeResponsabilidad)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.PORCENTAJE_RESPONSABILIDAD,
									   nPorcentajeResponsabilidadObt.ToString(),
									   nPorcentajeResponsabilidad.ToString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.PORCENTAJE_RESPONSABILIDAD,
									   string.Empty,
									   nPorcentajeResponsabilidad.ToString());
							}

							if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION_ESPECIAL))
							{
								int nOperacionEspecialObt = Convert.ToInt32(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION_ESPECIAL].ToString());

								if (nOperacionEspecialObt != nOperacionEspecial)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION_ESPECIAL,
									   oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecialObt),
									   oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION_ESPECIAL,
									   string.Empty,
									   oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));
							}

							if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_ACREEDOR))
							{
								int nTipoAcreedorObt = Convert.ToInt32(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_ACREEDOR].ToString());

								if (nTipoAcreedorObt != nTipoAcreedor)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_ACREEDOR,
									   oTraductor.TraducirTipoPersona(nTipoAcreedorObt),
									   oTraductor.TraducirTipoPersona(nTipoAcreedor));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_ACREEDOR,
										string.Empty,
									   oTraductor.TraducirTipoPersona(nTipoAcreedor));
							}

							if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_fiduciarias_x_operacion.CEDULA_ACREEDOR))
							{
								string strCedulaAcreedorObt = dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][ContenedorGarantias_fiduciarias_x_operacion.CEDULA_ACREEDOR].ToString();

								if (strCedulaAcreedorObt.CompareTo(strCedulaAcreedor) != 0)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.CEDULA_ACREEDOR,
									   strCedulaAcreedorObt,
									   strCedulaAcreedor);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
									   ContenedorGarantias_fiduciarias_x_operacion.CEDULA_ACREEDOR,
									   string.Empty,
									   strCedulaAcreedor);
							}

						}

						#endregion

						#region Garantía Fiduciaria

						if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
						{
							string strModificarGarantiaFiduciaria = "UPDATE GAR_GARANTIA_FIDUCIARIA SET cod_tipo_fiador = " + nTipoFiador.ToString() +
								"WHERE cedula_fiador = '" + strCedulaFiador + "'";

							if (!dsGarantiaFiduciaria.Tables[0].Rows[0].IsNull(ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR))
							{
								int nTipoFiadorObt = Convert.ToInt32(dsGarantiaFiduciaria.Tables[0].Rows[0][ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR].ToString());

								if (nTipoFiadorObt != nTipoFiador)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarantiaFiduciaria, string.Empty,
									   ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR,
									   oTraductor.TraducirTipoPersona(nTipoFiadorObt),
									   oTraductor.TraducirTipoPersona(nTipoFiador));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
									   2, 1, strCedulaFiador, strOperacionCrediticia, strModificarGarantiaFiduciaria, string.Empty,
									   ContenedorGarantia_fiduciaria.COD_TIPO_FIADOR,
									   string.Empty,
									   oTraductor.TraducirTipoPersona(nTipoFiador));
							}
						}

						#endregion

						#endregion
					}
				}
			}
			catch
			{
				throw;
			}
		}

		public void Eliminar(long nGarantiaFiduciaria, long nOperacion, string strUsuario, string strIP,
                             string strOperacionCrediticia)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_EliminarGarantiaFiduciaria", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();


					//Se obtiene los datos antes de ser borrados, para luego registrarlos en la bitácora
					string strConsultaGarFiduXOperacion = "select " + ContenedorGarantias_fiduciarias_x_operacion.CEDULA_ACREEDOR + "," +
						ContenedorGarantias_fiduciarias_x_operacion.COD_ESTADO + "," + ContenedorGarantias_fiduciarias_x_operacion.COD_GARANTIA_FIDUCIARIA + "," +
						ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION + "," + ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION_ESPECIAL + "," +
						ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_ACREEDOR + "," + ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_DOCUMENTO_LEGAL + "," +
						ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_MITIGADOR + "," + ContenedorGarantias_fiduciarias_x_operacion.MONTO_MITIGADOR + "," +
						ContenedorGarantias_fiduciarias_x_operacion.PORCENTAJE_RESPONSABILIDAD +
						" from " + ContenedorGarantias_fiduciarias_x_operacion.NOMBRE_ENTIDAD +
						" where " + ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION + " = " + nOperacion.ToString() +
						" and " + ContenedorGarantias_fiduciarias_x_operacion.COD_GARANTIA_FIDUCIARIA + " = " + nGarantiaFiduciaria.ToString();

					DataSet dsGarantiaFiduciariaXOP = AccesoBD.ejecutarConsulta(strConsultaGarFiduXOperacion);


					//Declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//Agrega los parametros
					oComando.Parameters.AddWithValue("@nGarantiaFiduciaria", nGarantiaFiduciaria);
					oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
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

						CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;

						string strEliminarGarFiduXOperacion = "DELETE GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION" +
							"WHERE cod_operacion =" + nOperacion.ToString() + " AND cod_garantia_fiduciaria = " + nGarantiaFiduciaria.ToString();

						string strCedulaFiador = "-";

						if (oGarantia.CedulaFiador != null)
						{
							strCedulaFiador = oGarantia.CedulaFiador;
						}
						else
						{
							strCedulaFiador = oTraductor.ObtenerCedulaFiadorGarFidu(nGarantiaFiduciaria.ToString());
						}

						if ((dsGarantiaFiduciariaXOP != null) && (dsGarantiaFiduciariaXOP.Tables.Count > 0) && (dsGarantiaFiduciariaXOP.Tables[0].Rows.Count > 0))
						{
							#region Garantía Fiduciaria por Operación

							foreach (DataRow drGarFiduXOP in dsGarantiaFiduciariaXOP.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drGarFiduXOP.Table.Columns.Count; nIndice++)
								{
									switch (drGarFiduXOP.Table.Columns[nIndice].ColumnName)
									{
										case ContenedorGarantias_fiduciarias_x_operacion.COD_ESTADO:
											if (drGarFiduXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
													   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
													   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
													   oTraductor.TraducirTipoEstado(Convert.ToInt32(drGarFiduXOP[nIndice, DataRowVersion.Current].ToString())),
													   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
													   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
													   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
													   string.Empty,
													   string.Empty);
											}

											break;

										case ContenedorGarantias_fiduciarias_x_operacion.COD_GARANTIA_FIDUCIARIA: oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
																									   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
																									   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
																									   strCedulaFiador,
																									   string.Empty);
											break;

										case ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION: oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
																									   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
																									   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
																									   strOperacionCrediticia,
																									   string.Empty);
											break;

										case ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION_ESPECIAL:
											if (drGarFiduXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
													   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
													   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
													   oTraductor.TraducirTipoOperacionEspecial(Convert.ToInt32(drGarFiduXOP[nIndice, DataRowVersion.Current].ToString())),
													   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
													   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
													   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
													   string.Empty,
													   string.Empty);
											}

											break;

										case ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_ACREEDOR:
											if (drGarFiduXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
														   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
														   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
														   oTraductor.TraducirTipoPersona(Convert.ToInt32(drGarFiduXOP[nIndice, DataRowVersion.Current].ToString())),
														   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
														   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
														   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
														   string.Empty,
														   string.Empty);
											}

											break;

										case ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_DOCUMENTO_LEGAL:
											if (drGarFiduXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
															   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
															   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
															   oTraductor.TraducirTipoDocumento(Convert.ToInt32(drGarFiduXOP[nIndice, DataRowVersion.Current].ToString())),
															   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
															   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
															   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
															   string.Empty,
															   string.Empty);
											}
											break;

										case ContenedorGarantias_fiduciarias_x_operacion.COD_TIPO_MITIGADOR:
											if (drGarFiduXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
															   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
															   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
															   oTraductor.TraducirTipoMitigador(Convert.ToInt32(drGarFiduXOP[nIndice, DataRowVersion.Current].ToString())),
															   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
															   3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
															   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
															   string.Empty,
															   string.Empty);
											}

											break;

										default: oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
												  3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
												  drGarFiduXOP.Table.Columns[nIndice].ColumnName,
												  drGarFiduXOP[nIndice, DataRowVersion.Current].ToString(),
												  string.Empty);
											break;
									}


								}
							}

							#endregion
						}
						else
						{
							oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", strUsuario, strIP, null,
									  3, 1, strCedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
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
