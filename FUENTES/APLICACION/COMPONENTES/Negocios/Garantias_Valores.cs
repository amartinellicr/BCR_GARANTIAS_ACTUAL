using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Collections.Specialized;
using System.Diagnostics;

using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;
using BCR.GARANTIAS.Comun;


namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Garantias_Valores.
	/// </summary>
	public class Garantias_Valores
    {
        #region Variables Globales
            string mstrOperacionCrediticia = "-";
            string mstrGarantia = "-";
        #endregion

        #region Metodos Publicos

        public void Crear(long nOperacion, int nTipoGarantia, int nClaseGarantia, string strSeguridad, 
						DateTime dFechaConstitucion, DateTime dFechaVencimiento,
						int nClasificacion, string strInstrumento, string strSerie, int nTipoEmisor,
						string strEmisor, decimal nPremio, string strISIN, decimal nValorFacial,
						int nMonedaValorFacial, decimal nValorMercado, int nMonedaValorMercado,
						int nTenencia, DateTime dFechaPrescripcion, int nTipoMitigador, int nTipoDocumento, 
						decimal nMontoMitigador, int nInscripcion, /*DateTime dFechaPresentacion, */
						decimal nPorcentaje, int nGradoGravamen, int nGradoPrioridades,
						decimal nMontoPrioridades, int nOperacionEspecial, int nTipoAcreedor,
                        string strCedulaAcreedor, string strUsuario, string strIP,
                        string strOperacionCrediticia, string strDescripcionInstrumento)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_InsertarGarantiaValor", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//Agrega los parametros
					oComando.Parameters.AddWithValue("@nTipoGarantia", nTipoGarantia);
					oComando.Parameters.AddWithValue("@nClaseGarantia", nClaseGarantia);
					oComando.Parameters.AddWithValue("@strNumeroSeguridad", strSeguridad);

					oComando.Parameters.AddWithValue("@dFechaConstitucion", dFechaConstitucion);
					oComando.Parameters.AddWithValue("@dFechaVencimiento", dFechaVencimiento);

					if (nClasificacion != -1)
						oComando.Parameters.AddWithValue("@nClasificacion", nClasificacion);

					if (strInstrumento != "")
						oComando.Parameters.AddWithValue("@strInstrumento", strInstrumento);

					if (strSerie != "")
						oComando.Parameters.AddWithValue("@strSerie", strSerie);

					if (nTipoEmisor != -1)
						oComando.Parameters.AddWithValue("@nTipoEmisor", nTipoEmisor);

					if (strEmisor != "")
						oComando.Parameters.AddWithValue("@strCedulaEmisor", strEmisor);

					oComando.Parameters.AddWithValue("@nPremio", nPremio);

					if (strISIN != "")
						oComando.Parameters.AddWithValue("@strISIN", strISIN);

					if (nValorFacial != 0)
						oComando.Parameters.AddWithValue("@nValorFacial", nValorFacial);

					if (nMonedaValorFacial != -1)
						oComando.Parameters.AddWithValue("@nMonedaValorFacial", nMonedaValorFacial);

					if (nValorMercado != 0)
						oComando.Parameters.AddWithValue("@nValorMercado", nValorMercado);

					if (nMonedaValorMercado != -1)
						oComando.Parameters.AddWithValue("@nMonedaValorMercado", nMonedaValorMercado);

					if (nTenencia != -1)
						oComando.Parameters.AddWithValue("@nTenencia", nTenencia);

					oComando.Parameters.AddWithValue("@dFechaPrescripcion", dFechaPrescripcion);
					oComando.Parameters.AddWithValue("@nOperacion", nOperacion);

					if (nTipoMitigador != -1)
						oComando.Parameters.AddWithValue("@nTipoMitigador", nTipoMitigador);

					if (nTipoDocumento != -1)
						oComando.Parameters.AddWithValue("@nTipoDocumentoLegal", nTipoDocumento);

					oComando.Parameters.AddWithValue("@nMontoMitigador", nMontoMitigador);

					if (nInscripcion != -1)
						oComando.Parameters.AddWithValue("@nInscripcion", nInscripcion);

					//				oComando.Parameters.AddWithValue("@dFechaPresentacion",dFechaPresentacion);
					oComando.Parameters.AddWithValue("@nPorcentaje", nPorcentaje);
					oComando.Parameters.AddWithValue("@nGradoGravamen", nGradoGravamen);

					if (nGradoPrioridades != -1)
						oComando.Parameters.AddWithValue("@nGradoPrioridades", nGradoPrioridades);

					if (nMontoPrioridades != 0)
						oComando.Parameters.AddWithValue("@nMontoPrioridades", nMontoPrioridades);

					if (nOperacionEspecial != -1)
						oComando.Parameters.AddWithValue("@nOperacionEspecial", nOperacionEspecial);

					if (nTipoAcreedor != -1)
						oComando.Parameters.AddWithValue("@nTipoAcreedor", nTipoAcreedor);

					if (strCedulaAcreedor != "")
						oComando.Parameters.AddWithValue("@strCedulaAcreedor", strCedulaAcreedor);

					oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
					oComando.Parameters.AddWithValue("@strIP", strIP);
					//oComando.Parameters.AddWithValue("@nOficina",nOficina);	

					//Obtener la información sobre la Garantía Valor, esto por si se debe insertar
					DataSet dsGarantiaValor = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_valor.COD_GARANTIA_VALOR +
							" from " + ContenedorGarantia_valor.NOMBRE_ENTIDAD +
							" where " + ContenedorGarantia_valor.COD_CLASE_GARANTIA + " = " + nClaseGarantia.ToString() +
							" and " + ContenedorGarantia_valor.NUMERO_SEGURIDAD + " = '" + strSeguridad + "'");

					//Abre la conexion
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						string mstrOperacionCrediticia = oTraductor.ObtenerCedulaDeudor(nOperacion.ToString());
						string mstrGarantia = string.Empty;

						if ((dsGarantiaValor == null) || (dsGarantiaValor.Tables.Count == 0) || (dsGarantiaValor.Tables[0].Rows.Count == 0))
						{
							#region Inserción en Bitácora de la garantía valor

							string strInsertarGarantiaValor = "INSERT INTO GAR_GARANTIA_VALOR (cod_tipo_garantia,cod_clase_garantia,numero_seguridad,fecha_constitucion," +
								"fecha_vencimiento_instrumento,cod_clasificacion_instrumento,des_instrumento,des_serie_instrumento," +
								"cod_tipo_emisor,cedula_emisor,premio,cod_isin,valor_facial,cod_moneda_valor_facial,valor_mercado," +
								"cod_moneda_valor_mercado,cod_tenencia,fecha_prescripcion) VALUES(" + nTipoGarantia.ToString() + "," +
								nClaseGarantia.ToString() + "," + strSeguridad + "," + dFechaConstitucion.ToShortDateString() + "," +
								dFechaVencimiento.ToShortDateString() + "," + nClasificacion.ToString() + "," + strInstrumento + "," +
								strSerie + "," + nTipoEmisor.ToString() + "," + strEmisor + "," + nPremio.ToString() + "," +
								strISIN + "," + nValorFacial.ToString() + "," + nMonedaValorFacial.ToString() + "," +
								nValorMercado.ToString() + "," + nMonedaValorMercado.ToString() + "," + nTenencia.ToString() + "," +
								dFechaPrescripcion.ToShortDateString() + ")";


							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.COD_TIPO_GARANTIA,
								string.Empty,
								oTraductor.TraducirTipoGarantia(nTipoGarantia));

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.COD_CLASE_GARANTIA,
								string.Empty,
								oTraductor.TraducirClaseGarantia(nClaseGarantia));

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.NUMERO_SEGURIDAD,
								string.Empty,
								strSeguridad);

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.FECHA_CONSTITUCION,
								string.Empty,
								dFechaConstitucion.ToShortDateString());

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.FECHA_VENCIMIENTO_INSTRUMENTO,
								string.Empty,
								dFechaVencimiento.ToShortDateString());

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.COD_CLASIFICACION_INSTRUMENTO,
								string.Empty,
								oTraductor.TraducirTipoClasificacionInstrumento(nClasificacion));

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.DES_INSTRUMENTO,
								string.Empty,
								strDescripcionInstrumento);

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.DES_SERIE_INSTRUMENTO,
								string.Empty,
								strSerie);

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.COD_TIPO_EMISOR,
								string.Empty,
								oTraductor.TraducirTipoPersona(nTipoEmisor));

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.CEDULA_EMISOR,
								string.Empty,
								strEmisor);

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.PREMIO,
								string.Empty,
								nPremio.ToString());

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.COD_ISIN,
								string.Empty,
								strISIN);

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.VALOR_FACIAL,
								string.Empty,
								nValorFacial.ToString());

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.COD_MONEDA_VALOR_FACIAL,
								string.Empty,
								oTraductor.TraducirTipoMoneda(nMonedaValorFacial));

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.VALOR_MERCADO,
								string.Empty,
								nValorMercado.ToString());

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.COD_MONEDA_VALOR_MERCADO,
								string.Empty,
								oTraductor.TraducirTipoMoneda(nMonedaValorMercado));

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.COD_TENENCIA,
								string.Empty,
								oTraductor.TraducirTipoTenencia(nTenencia));

							oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
								1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
								ContenedorGarantia_valor.FECHA_PRESCRIPCION, "01/01/1900", dFechaPrescripcion.ToShortDateString());



							dsGarantiaValor = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_valor.COD_GARANTIA_VALOR +
							" from " + ContenedorGarantia_valor.NOMBRE_ENTIDAD +
							" where " + ContenedorGarantia_valor.COD_CLASE_GARANTIA + " = " + nClaseGarantia.ToString() +
							" and " + ContenedorGarantia_valor.NUMERO_SEGURIDAD + " = '" + strSeguridad + "'");

							#endregion
						}

						if ((dsGarantiaValor != null) && (dsGarantiaValor.Tables.Count > 0) && (dsGarantiaValor.Tables[0].Rows.Count > 0))
						{
							#region Inserción en Bitácora de la garantía valor por operación

							string strCodigoGarantiaValor = dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.COD_GARANTIA_VALOR].ToString();

							mstrGarantia = strSeguridad;

							string strInsertarGarValorXOperacion = "INSERT INTO GAR_GARANTIAS_VALOR_X_OPERACION (cod_operacion,cod_garantia_valor,cod_tipo_mitigador," +
								"cod_tipo_documento_legal,monto_mitigador,cod_inscripcion," +
								"porcentaje_responsabilidad,cod_grado_gravamen,cod_grado_prioridades,monto_prioridades," +
								"cod_operacion_especial,cod_tipo_acreedor,cedula_acreedor) VALUES(" + nOperacion.ToString() + "," +
								strCodigoGarantiaValor + "," + nTipoMitigador.ToString() + "," + nTipoDocumento.ToString() + "," +
								nMontoMitigador.ToString() + "," + nInscripcion.ToString() + "," + nPorcentaje.ToString() + "," +
								nGradoGravamen.ToString() + "," + nGradoPrioridades.ToString() + "," + nMontoPrioridades.ToString() + "," +
								nOperacionEspecial.ToString() + "," + nTipoAcreedor.ToString() + "," + strCedulaAcreedor + ")";


							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.COD_OPERACION,
								string.Empty,
								mstrOperacionCrediticia);

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.COD_GARANTIA_VALOR,
								string.Empty,
								mstrGarantia);

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.COD_TIPO_MITIGADOR,
								string.Empty,
								oTraductor.TraducirTipoMitigador(nTipoMitigador));

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.COD_TIPO_DOCUMENTO_LEGAL,
								string.Empty,
								oTraductor.TraducirTipoDocumento(nTipoDocumento));

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.MONTO_MITIGADOR, "0", nMontoMitigador.ToString());

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.COD_INSCRIPCION,
								string.Empty,
								oTraductor.TraducirTipoInscripcion(nInscripcion));

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.PORCENTAJE_RESPONSABILIDAD,
								string.Empty,
								nPorcentaje.ToString());

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.COD_GRADO_GRAVAMEN,
								string.Empty,
								oTraductor.TraducirGradoGravamen(nGradoGravamen));

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.COD_GRADO_PRIORIDADES,
								string.Empty,
								nGradoPrioridades.ToString());

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.MONTO_PRIORIDADES,
								string.Empty,
								nMontoPrioridades.ToString());

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.COD_OPERACION_ESPECIAL,
								string.Empty,
								oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.COD_TIPO_ACREEDOR,
								string.Empty,
								oTraductor.TraducirTipoPersona(nTipoAcreedor));

							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
								1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
								ContenedorGarantias_valor_x_operacion.CEDULA_ACREEDOR,
								string.Empty,
								strCedulaAcreedor);

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

		public void Modificar(long nOperacion, long nGarantiaValor, int nTipoGarantia, 
							int nClaseGarantia, string strSeguridad, 
							DateTime dFechaConstitucion, DateTime dFechaVencimiento,
							int nClasificacion, string strInstrumento, string strSerie, int nTipoEmisor,
							string strEmisor, decimal nPremio, string strISIN, decimal nValorFacial,
							int nMonedaValorFacial, decimal nValorMercado, int nMonedaValorMercado,
							int nTenencia, DateTime dFechaPrescripcion, int nTipoMitigador, int nTipoDocumento, 
							decimal nMontoMitigador, int nInscripcion, /*DateTime dFechaPresentacion, */
							decimal nPorcentaje, int nGradoGravamen, int nGradoPrioridades,
							decimal nMontoPrioridades, int nOperacionEspecial, int nTipoAcreedor,
                            string strCedulaAcreedor, string strUsuario, string strIP,
                            string strOperacionCrediticia, string strDescripcionInstrumento, string strDescInstNuevo)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_ModificarGarantiaValor", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//Agrega los parametros
					oComando.Parameters.AddWithValue("@nGarantiaValor", nGarantiaValor);
					oComando.Parameters.AddWithValue("@nTipoGarantia", nTipoGarantia);
					oComando.Parameters.AddWithValue("@nClaseGarantia", nClaseGarantia);
					oComando.Parameters.AddWithValue("@strNumeroSeguridad", strSeguridad);

					oComando.Parameters.AddWithValue("@dFechaConstitucion", dFechaConstitucion);
					oComando.Parameters.AddWithValue("@dFechaVencimiento", dFechaVencimiento);

					if (nClasificacion != -1)
						oComando.Parameters.AddWithValue("@nClasificacion", nClasificacion);

					if (strInstrumento != "")
						oComando.Parameters.AddWithValue("@strInstrumento", strInstrumento);

					if (strSerie != "")
						oComando.Parameters.AddWithValue("@strSerie", strSerie);

					if (nTipoEmisor != -1)
						oComando.Parameters.AddWithValue("@nTipoEmisor", nTipoEmisor);

					if (strEmisor != "")
						oComando.Parameters.AddWithValue("@strCedulaEmisor", strEmisor);

					oComando.Parameters.AddWithValue("@nPremio", nPremio);

					if (strISIN != "")
						oComando.Parameters.AddWithValue("@strISIN", strISIN);

					if (nValorFacial != 0)
						oComando.Parameters.AddWithValue("@nValorFacial", nValorFacial);

					if (nMonedaValorFacial != -1)
						oComando.Parameters.AddWithValue("@nMonedaValorFacial", nMonedaValorFacial);

					if (nValorMercado != 0)
						oComando.Parameters.AddWithValue("@nValorMercado", nValorMercado);

					if (nMonedaValorMercado != -1)
						oComando.Parameters.AddWithValue("@nMonedaValorMercado", nMonedaValorMercado);

					if (nTenencia != -1)
						oComando.Parameters.AddWithValue("@nTenencia", nTenencia);

					oComando.Parameters.AddWithValue("@dFechaPrescripcion", dFechaPrescripcion);
					oComando.Parameters.AddWithValue("@nOperacion", nOperacion);

					if (nTipoMitigador != -1)
						oComando.Parameters.AddWithValue("@nTipoMitigador", nTipoMitigador);

					if (nTipoDocumento != -1)
						oComando.Parameters.AddWithValue("@nTipoDocumentoLegal", nTipoDocumento);

					oComando.Parameters.AddWithValue("@nMontoMitigador", nMontoMitigador);

					if (nInscripcion != -1)
						oComando.Parameters.AddWithValue("@nInscripcion", nInscripcion);

					//				oComando.Parameters.AddWithValue("@dFechaPresentacion",dFechaPresentacion);
					oComando.Parameters.AddWithValue("@nPorcentaje", nPorcentaje);
					oComando.Parameters.AddWithValue("@nGradoGravamen", nGradoGravamen);

					if (nGradoPrioridades != -1)
						oComando.Parameters.AddWithValue("@nGradoPrioridades", nGradoPrioridades);

					if (nMontoPrioridades != 0)
						oComando.Parameters.AddWithValue("@nMontoPrioridades", nMontoPrioridades);

					if (nOperacionEspecial != -1)
						oComando.Parameters.AddWithValue("@nOperacionEspecial", nOperacionEspecial);

					if (nTipoAcreedor != -1)
						oComando.Parameters.AddWithValue("@nTipoAcreedor", nTipoAcreedor);

					if (strCedulaAcreedor != "")
						oComando.Parameters.AddWithValue("@strCedulaAcreedor", strCedulaAcreedor);

					oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
					oComando.Parameters.AddWithValue("@strIP", strIP);
					//oComando.Parameters.AddWithValue("@nOficina",nOficina);	


					#region Obtener los datos que podrían cambiar antes de que se actualicen

					DataSet dsGarantiaValor = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_valor.FECHA_CONSTITUCION + "," +
						   ContenedorGarantia_valor.FECHA_VENCIMIENTO_INSTRUMENTO + "," + ContenedorGarantia_valor.COD_CLASIFICACION_INSTRUMENTO + "," +
						   ContenedorGarantia_valor.DES_INSTRUMENTO + "," + ContenedorGarantia_valor.DES_SERIE_INSTRUMENTO + "," +
						   ContenedorGarantia_valor.COD_TIPO_EMISOR + "," + ContenedorGarantia_valor.CEDULA_EMISOR + "," +
						   ContenedorGarantia_valor.PREMIO + "," + ContenedorGarantia_valor.COD_ISIN + "," +
						   ContenedorGarantia_valor.VALOR_FACIAL + "," + ContenedorGarantia_valor.COD_MONEDA_VALOR_FACIAL + "," +
						   ContenedorGarantia_valor.VALOR_MERCADO + "," + ContenedorGarantia_valor.COD_MONEDA_VALOR_MERCADO + "," +
						   ContenedorGarantia_valor.COD_TENENCIA + "," + ContenedorGarantia_valor.FECHA_PRESCRIPCION +
						   " from " + ContenedorGarantia_valor.NOMBRE_ENTIDAD +
						   " where " + ContenedorGarantia_valor.COD_GARANTIA_VALOR + " = " + nGarantiaValor.ToString());

					DataSet dsGarantiaValorXOperacion = AccesoBD.ejecutarConsulta("select " + ContenedorGarantias_valor_x_operacion.COD_TIPO_MITIGADOR + "," +
						   ContenedorGarantias_valor_x_operacion.COD_TIPO_DOCUMENTO_LEGAL + "," + ContenedorGarantias_valor_x_operacion.MONTO_MITIGADOR + "," +
						   ContenedorGarantias_valor_x_operacion.COD_INSCRIPCION + "," + ContenedorGarantias_valor_x_operacion.PORCENTAJE_RESPONSABILIDAD + "," +
						   ContenedorGarantias_valor_x_operacion.COD_GRADO_GRAVAMEN + "," + ContenedorGarantias_valor_x_operacion.COD_GRADO_PRIORIDADES + "," +
						   ContenedorGarantias_valor_x_operacion.MONTO_PRIORIDADES + "," + ContenedorGarantias_valor_x_operacion.COD_OPERACION_ESPECIAL + "," +
						   ContenedorGarantias_valor_x_operacion.COD_TIPO_ACREEDOR + "," + ContenedorGarantias_valor_x_operacion.CEDULA_ACREEDOR +
						   " from " + ContenedorGarantias_valor_x_operacion.NOMBRE_ENTIDAD +
						   " where " + ContenedorGarantias_valor_x_operacion.COD_OPERACION + " = " + nOperacion.ToString() +
						   " and " + ContenedorGarantias_valor_x_operacion.COD_GARANTIA_VALOR + " = " + nGarantiaValor.ToString());

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

						if (strSeguridad != string.Empty)
						{
							mstrGarantia = strSeguridad;
						}

						mstrOperacionCrediticia = strOperacionCrediticia;

						#region Inserción en Bitácora de las garantías valor que han cambiado

						if ((dsGarantiaValor != null) && (dsGarantiaValor.Tables.Count > 0) && (dsGarantiaValor.Tables[0].Rows.Count > 0))
						{
							string strModificarGarntiaValor = "UPDATE GAR_GARANTIA_VALOR SET fecha_constitucion = " + dFechaConstitucion.ToShortDateString() +
						   ",fecha_vencimiento_instrumento = " + dFechaVencimiento.ToShortDateString() +
						   ",cod_clasificacion_instrumento = " + nClasificacion.ToString() +
						   ",des_instrumento = " + strInstrumento +
						   ",des_serie_instrumento = " + strSerie +
						   ",cod_tipo_emisor = " + nTipoEmisor.ToString() +
						   ",cedula_emisor = " + strEmisor +
						   ",premio = " + nPremio.ToString() +
						   ",cod_isin = " + strISIN +
						   ",valor_facial = " + nValorFacial.ToString() +
						   ",cod_moneda_valor_facial = " + nMonedaValorFacial.ToString() +
						   ",valor_mercado = " + nValorMercado.ToString() +
						   ",cod_moneda_valor_mercado = " + nMonedaValorMercado.ToString() +
						   ",cod_tenencia = " + nTenencia.ToString() +
						   ",fecha_prescripcion = " + dFechaPrescripcion.ToShortDateString() +
						   " WHERE cod_garantia_valor = " + nGarantiaValor.ToString();

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.FECHA_CONSTITUCION))
							{
								DateTime dFechaConstitucionObt = Convert.ToDateTime(dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.FECHA_CONSTITUCION].ToString());

								if (dFechaConstitucionObt != dFechaConstitucion)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.FECHA_CONSTITUCION,
										dFechaConstitucionObt.ToShortDateString(),
										dFechaConstitucion.ToShortDateString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.FECHA_CONSTITUCION,
										string.Empty,
										dFechaConstitucion.ToShortDateString());
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.FECHA_VENCIMIENTO_INSTRUMENTO))
							{
								DateTime dFechaVencimientoInstrumentoObt = Convert.ToDateTime(dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.FECHA_VENCIMIENTO_INSTRUMENTO].ToString());

								if (dFechaVencimientoInstrumentoObt != dFechaVencimiento)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.FECHA_VENCIMIENTO_INSTRUMENTO,
										dFechaVencimientoInstrumentoObt.ToShortDateString(),
										dFechaVencimiento.ToShortDateString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.FECHA_VENCIMIENTO_INSTRUMENTO,
										string.Empty,
										dFechaVencimiento.ToShortDateString());
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.COD_CLASIFICACION_INSTRUMENTO))
							{
								int nCodigoClasificacionInstrumentoObt = Convert.ToInt32(dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.COD_CLASIFICACION_INSTRUMENTO].ToString());

								if ((nClasificacion != -1) && (nCodigoClasificacionInstrumentoObt != nClasificacion))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.COD_CLASIFICACION_INSTRUMENTO,
										oTraductor.TraducirTipoClasificacionInstrumento(nCodigoClasificacionInstrumentoObt),
										oTraductor.TraducirTipoClasificacionInstrumento(nClasificacion));
								}
							}
							else
							{
								if (nClasificacion != -1)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
											ContenedorGarantia_valor.COD_CLASIFICACION_INSTRUMENTO,
											string.Empty,
											oTraductor.TraducirTipoClasificacionInstrumento(nClasificacion));
								}
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.DES_INSTRUMENTO))
							{
								string strDescripInstrumObt = dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.DES_INSTRUMENTO].ToString();

								if ((strDescripcionInstrumento != string.Empty) && (strDescInstNuevo != string.Empty)
									  && (strDescripcionInstrumento.CompareTo(strDescInstNuevo) != 0))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.DES_INSTRUMENTO,
										strDescripcionInstrumento,
										strDescInstNuevo);
								}
								else if (strDescripInstrumObt.CompareTo(strInstrumento) != 0)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
									   2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
									   ContenedorGarantia_valor.DES_INSTRUMENTO,
									   strDescripInstrumObt,
									   strInstrumento);
								}
							}
							else
							{
								if (strInstrumento != string.Empty)
								{
									if ((strDescripcionInstrumento != string.Empty) && (strDescInstNuevo != string.Empty)
									  && (strDescripcionInstrumento.CompareTo(strDescInstNuevo) != 0))
									{
										oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
											ContenedorGarantia_valor.DES_INSTRUMENTO,
											strDescripcionInstrumento,
											strDescInstNuevo);
									}
									else
									{
										oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
											   2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
											   ContenedorGarantia_valor.DES_INSTRUMENTO,
											   string.Empty,
											   strInstrumento);
									}
								}
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.DES_SERIE_INSTRUMENTO))
							{
								string strDescripcionSerieInstrumentoObt = dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.DES_SERIE_INSTRUMENTO].ToString();

								if (strDescripcionSerieInstrumentoObt.CompareTo(strSerie) != 0)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.DES_SERIE_INSTRUMENTO,
										strDescripcionSerieInstrumentoObt,
										strSerie);
								}
							}
							else
							{
								if (strSerie != string.Empty)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
											ContenedorGarantia_valor.DES_SERIE_INSTRUMENTO,
											string.Empty,
											strSerie);
								}
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.COD_TIPO_EMISOR))
							{
								int nCodigoTipoEmisorObt = Convert.ToInt32(dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.COD_TIPO_EMISOR].ToString());

								if ((nTipoEmisor != -1) && (nCodigoTipoEmisorObt != nTipoEmisor))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.COD_TIPO_EMISOR,
										oTraductor.TraducirTipoPersona(nCodigoTipoEmisorObt),
										oTraductor.TraducirTipoPersona(nTipoEmisor));
								}
							}
							else
							{
								if (nTipoEmisor != -1)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
											ContenedorGarantia_valor.COD_TIPO_EMISOR,
											string.Empty,
											oTraductor.TraducirTipoPersona(nTipoEmisor));
								}
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.CEDULA_EMISOR))
							{
								string strCedulaEmisorObt = dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.CEDULA_EMISOR].ToString();

								if ((strEmisor != string.Empty) && (strCedulaEmisorObt.CompareTo(strEmisor) != 0))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.CEDULA_EMISOR,
										strCedulaEmisorObt,
										strEmisor);
								}
							}
							else
							{
								if (strEmisor != string.Empty)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
											ContenedorGarantia_valor.CEDULA_EMISOR,
											string.Empty,
											strEmisor);
								}
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.PREMIO))
							{
								decimal nPremioObt = Convert.ToDecimal(dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.PREMIO].ToString());

								if (nPremioObt != nPremio)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.PREMIO,
										nPremioObt.ToString(),
										nPremio.ToString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.PREMIO,
										string.Empty,
										nPremio.ToString());
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.COD_ISIN))
							{
								string strCodigoIsinObt = dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.COD_ISIN].ToString();

								if ((strISIN != string.Empty) && (strCodigoIsinObt.CompareTo(strISIN) != 0))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.COD_ISIN,
										strCodigoIsinObt,
										strISIN);
								}
							}
							else
							{
								if (strISIN != string.Empty)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
											ContenedorGarantia_valor.COD_ISIN,
											string.Empty,
											strISIN);
								}
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.VALOR_FACIAL))
							{
								decimal nValorFacialObt = Convert.ToDecimal(dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.VALOR_FACIAL].ToString());

								if (nValorFacialObt != nValorFacial)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.VALOR_FACIAL,
										nValorFacialObt.ToString(),
										nValorFacial.ToString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.VALOR_FACIAL,
										string.Empty,
										nValorFacial.ToString());
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.COD_MONEDA_VALOR_FACIAL))
							{
								int nMonedaValorFacialObt = Convert.ToInt32(dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.COD_MONEDA_VALOR_FACIAL].ToString());

								if ((nMonedaValorFacial != -1) && (nMonedaValorFacialObt != nMonedaValorFacial))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.COD_MONEDA_VALOR_FACIAL,
										oTraductor.TraducirTipoMoneda(nMonedaValorFacialObt),
										oTraductor.TraducirTipoMoneda(nMonedaValorFacial));
								}
							}
							else
							{
								if (nMonedaValorFacial != -1)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
											ContenedorGarantia_valor.COD_MONEDA_VALOR_FACIAL,
											string.Empty,
											oTraductor.TraducirTipoMoneda(nMonedaValorFacial));
								}
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.VALOR_MERCADO))
							{
								decimal nValorMercadoObt = Convert.ToDecimal(dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.VALOR_MERCADO].ToString());

								if (nValorMercadoObt != nValorMercado)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.VALOR_MERCADO,
										nValorMercadoObt.ToString(),
										nValorMercado.ToString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.VALOR_MERCADO,
										string.Empty,
										nValorMercado.ToString());
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.COD_MONEDA_VALOR_MERCADO))
							{
								int nMonedaValorMercadoObt = Convert.ToInt32(dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.COD_MONEDA_VALOR_MERCADO].ToString());

								if ((nMonedaValorMercado != -1) && (nMonedaValorMercadoObt != nMonedaValorMercado))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.COD_MONEDA_VALOR_MERCADO,
										oTraductor.TraducirTipoMoneda(nMonedaValorMercadoObt),
										oTraductor.TraducirTipoMoneda(nMonedaValorMercado));
								}
							}
							else
							{
								if (nMonedaValorMercado != -1)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
											ContenedorGarantia_valor.COD_MONEDA_VALOR_MERCADO,
											string.Empty,
											oTraductor.TraducirTipoMoneda(nMonedaValorMercado));
								}
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.COD_TENENCIA))
							{
								int nCodigoTenenciaObt = Convert.ToInt32(dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.COD_TENENCIA].ToString());

								if ((nTenencia != -1) && (nCodigoTenenciaObt != nTenencia))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.COD_TENENCIA,
										oTraductor.TraducirTipoTenencia(nCodigoTenenciaObt),
										oTraductor.TraducirTipoTenencia(nTenencia));
								}
							}
							else
							{
								if (nTenencia != -1)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
											ContenedorGarantia_valor.COD_TENENCIA,
											string.Empty,
											oTraductor.TraducirTipoTenencia(nTenencia));
								}
							}

							if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.FECHA_PRESCRIPCION))
							{
								DateTime dFechaPrescripcionObt = Convert.ToDateTime(dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.FECHA_PRESCRIPCION].ToString());

								if (dFechaPrescripcionObt != dFechaPrescripcion)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.FECHA_PRESCRIPCION,
										dFechaPrescripcionObt.ToShortDateString(),
										dFechaPrescripcion.ToShortDateString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
										ContenedorGarantia_valor.FECHA_PRESCRIPCION,
										string.Empty,
										dFechaPrescripcion.ToShortDateString());
							}
						}

						#endregion

						#region Inserción en Bitacora de las garantías valor por operación que han cambiado

						if ((dsGarantiaValorXOperacion != null) && (dsGarantiaValorXOperacion.Tables.Count > 0) && (dsGarantiaValorXOperacion.Tables[0].Rows.Count > 0))
						{

							string strModificarGarValorXOperacion = "UPDATE GAR_GARANTIAS_VALOR_X_OPERACION SET cod_tipo_mitigador = " + nTipoMitigador.ToString() +
								",cod_tipo_documento_legal = " + nTipoDocumento.ToString() +
								",monto_mitigador = " + nMontoMitigador.ToString() +
								",cod_inscripcion = " + nInscripcion.ToString() +
								",porcentaje_responsabilidad = " + nPorcentaje.ToString() +
								",cod_grado_gravamen = " + nGradoGravamen.ToString() +
								",cod_grado_prioridades = " + nGradoPrioridades.ToString() +
								",monto_prioridades = " + nMontoPrioridades.ToString() +
								",cod_operacion_especial = " + nOperacionEspecial.ToString() +
								",cod_tipo_acreedor = " + nTipoAcreedor.ToString() +
								",cedula_acreedor = " + strCedulaAcreedor +
								" WHERE cod_operacion = " + nOperacion.ToString() +
								" AND cod_garantia_valor = " + nGarantiaValor.ToString();

							if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_valor_x_operacion.COD_TIPO_MITIGADOR))
							{
								int nCodigoTipoMitigadorObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][ContenedorGarantias_valor_x_operacion.COD_TIPO_MITIGADOR].ToString());

								if ((nTipoMitigador != -1) && (nCodigoTipoMitigadorObt != nTipoMitigador))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.COD_TIPO_MITIGADOR,
										oTraductor.TraducirTipoMitigador(nCodigoTipoMitigadorObt),
										oTraductor.TraducirTipoMitigador(nTipoMitigador));
								}
							}
							else
							{
								if (nTipoMitigador != -1)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
											ContenedorGarantias_valor_x_operacion.COD_TIPO_MITIGADOR,
											string.Empty,
											oTraductor.TraducirTipoMitigador(nTipoMitigador));
								}
							}

							if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_valor_x_operacion.COD_TIPO_DOCUMENTO_LEGAL))
							{
								int nCodigoTipoDocumentoLegalObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][ContenedorGarantias_valor_x_operacion.COD_TIPO_DOCUMENTO_LEGAL].ToString());

								if ((nTipoDocumento != -1) && (nCodigoTipoDocumentoLegalObt != nTipoDocumento))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.COD_TIPO_DOCUMENTO_LEGAL,
										oTraductor.TraducirTipoDocumento(nCodigoTipoDocumentoLegalObt),
										oTraductor.TraducirTipoDocumento(nTipoDocumento));
								}
							}
							else
							{
								if (nTipoDocumento != -1)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
											ContenedorGarantias_valor_x_operacion.COD_TIPO_DOCUMENTO_LEGAL,
											string.Empty,
											oTraductor.TraducirTipoDocumento(nTipoDocumento));
								}
							}

							if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_valor_x_operacion.MONTO_MITIGADOR))
							{
								decimal nMontoMitigadorObt = Convert.ToDecimal(dsGarantiaValorXOperacion.Tables[0].Rows[0][ContenedorGarantias_valor_x_operacion.MONTO_MITIGADOR].ToString());

								if (nMontoMitigadorObt != nMontoMitigador)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.MONTO_MITIGADOR,
										nMontoMitigadorObt.ToString(),
										nMontoMitigador.ToString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.MONTO_MITIGADOR,
										string.Empty,
										nMontoMitigador.ToString());
							}

							if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_valor_x_operacion.COD_INSCRIPCION))
							{
								int nCodigoInscripcionObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][ContenedorGarantias_valor_x_operacion.COD_INSCRIPCION].ToString());

								if ((nInscripcion != -1) && (nCodigoInscripcionObt != nInscripcion))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.COD_INSCRIPCION,
										oTraductor.TraducirTipoInscripcion(nCodigoInscripcionObt),
										oTraductor.TraducirTipoInscripcion(nInscripcion));
								}
							}
							else
							{
								if (nInscripcion != -1)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
											ContenedorGarantias_valor_x_operacion.COD_INSCRIPCION,
											string.Empty,
											oTraductor.TraducirTipoInscripcion(nInscripcion));
								}
							}

							if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_valor_x_operacion.PORCENTAJE_RESPONSABILIDAD))
							{
								decimal nPorcentajeResponsabilidadObt = Convert.ToDecimal(dsGarantiaValorXOperacion.Tables[0].Rows[0][ContenedorGarantias_valor_x_operacion.PORCENTAJE_RESPONSABILIDAD].ToString());

								if (nPorcentajeResponsabilidadObt != nPorcentaje)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.PORCENTAJE_RESPONSABILIDAD,
										nPorcentajeResponsabilidadObt.ToString(),
										nPorcentaje.ToString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.PORCENTAJE_RESPONSABILIDAD,
										string.Empty,
										nPorcentaje.ToString());
							}

							if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_valor_x_operacion.COD_GRADO_GRAVAMEN))
							{
								int nCodigoGradoGravamenObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][ContenedorGarantias_valor_x_operacion.COD_GRADO_GRAVAMEN].ToString());

								if ((nGradoGravamen != -1) && (nCodigoGradoGravamenObt != nGradoGravamen))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.COD_GRADO_GRAVAMEN,
										oTraductor.TraducirGradoGravamen(nCodigoGradoGravamenObt),
										oTraductor.TraducirGradoGravamen(nGradoGravamen));
								}
							}
							else
							{
								if (nGradoGravamen != -1)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
											ContenedorGarantias_valor_x_operacion.COD_GRADO_GRAVAMEN,
											string.Empty,
											oTraductor.TraducirGradoGravamen(nGradoGravamen));
								}
							}

							if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_valor_x_operacion.COD_GRADO_PRIORIDADES))
							{
								int nCodigoGradoPrioridadesObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][ContenedorGarantias_valor_x_operacion.COD_GRADO_PRIORIDADES].ToString());

								if ((nGradoPrioridades != -1) && (nCodigoGradoPrioridadesObt != nGradoPrioridades))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.COD_GRADO_PRIORIDADES,
										nCodigoGradoPrioridadesObt.ToString(),
										nGradoPrioridades.ToString());
								}
							}
							else
							{
								if (nGradoPrioridades != -1)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
											ContenedorGarantias_valor_x_operacion.COD_GRADO_PRIORIDADES,
											string.Empty,
											nGradoPrioridades.ToString());
								}
							}

							if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_valor_x_operacion.MONTO_PRIORIDADES))
							{
								decimal nMontoPrioridadesObt = Convert.ToDecimal(dsGarantiaValorXOperacion.Tables[0].Rows[0][ContenedorGarantias_valor_x_operacion.MONTO_PRIORIDADES].ToString());

								if (nMontoPrioridadesObt != nMontoPrioridades)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.MONTO_PRIORIDADES,
										nMontoPrioridadesObt.ToString(),
										nMontoPrioridades.ToString());
								}
							}
							else
							{
								if (nMontoPrioridades != 0)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
											ContenedorGarantias_valor_x_operacion.MONTO_PRIORIDADES,
											string.Empty,
											nMontoPrioridades.ToString());
								}
							}

							if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_valor_x_operacion.COD_OPERACION_ESPECIAL))
							{
								int nCodigoOperacionEspecialObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][ContenedorGarantias_valor_x_operacion.COD_OPERACION_ESPECIAL].ToString());

								if ((nOperacionEspecial != -1) && (nCodigoOperacionEspecialObt != -3)
									&& (nCodigoOperacionEspecialObt != nOperacionEspecial))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.COD_OPERACION_ESPECIAL,
										oTraductor.TraducirTipoOperacionEspecial(nCodigoOperacionEspecialObt),
										oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));
								}
							}

							if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_valor_x_operacion.COD_TIPO_ACREEDOR))
							{
								int nCodigoTipoAcreedorObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][ContenedorGarantias_valor_x_operacion.COD_TIPO_ACREEDOR].ToString());

								if ((nTipoAcreedor != -1) && (nCodigoTipoAcreedorObt != nTipoAcreedor))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.COD_TIPO_ACREEDOR,
										oTraductor.TraducirTipoPersona(nCodigoTipoAcreedorObt),
										oTraductor.TraducirTipoPersona(nTipoAcreedor));
								}
							}
							else
							{
								if (nTipoAcreedor != -1)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
											ContenedorGarantias_valor_x_operacion.COD_TIPO_ACREEDOR,
											string.Empty,
											oTraductor.TraducirTipoPersona(nTipoAcreedor));
								}
							}

							if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_valor_x_operacion.CEDULA_ACREEDOR))
							{
								string strCedulaAcreedorObt = dsGarantiaValorXOperacion.Tables[0].Rows[0][ContenedorGarantias_valor_x_operacion.CEDULA_ACREEDOR].ToString();

								if ((strCedulaAcreedor != string.Empty) && (strCedulaAcreedorObt.CompareTo(strCedulaAcreedor) != 0))
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
										2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
										ContenedorGarantias_valor_x_operacion.CEDULA_ACREEDOR,
										strCedulaAcreedorObt,
										strCedulaAcreedor);
								}
							}
							else
							{
								if (strCedulaAcreedor != string.Empty)
								{
									oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
											2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
											ContenedorGarantias_valor_x_operacion.CEDULA_ACREEDOR,
											string.Empty,
											strCedulaAcreedor);
								}
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

        public void Eliminar(long nOperacion, long nGarantia, string strUsuario, string strIP,
                             string strOperacionCrediticia)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_EliminarGarantiaValor", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//Agrega los parametros
					oComando.Parameters.AddWithValue("@nGarantiaValor", nGarantia);
					oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
					oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
					oComando.Parameters.AddWithValue("@strIP", strIP);
					//oComando.Parameters.AddWithValue("@nOficina",nOficina);	

					#region Obtener los datos antes de eliminarlos, con el fin de poder insertarlos en la bitácora

					DataSet dsGarantiaValorXOperacion = AccesoBD.ejecutarConsulta("select " + ContenedorGarantias_valor_x_operacion.CEDULA_ACREEDOR + "," +
						   ContenedorGarantias_valor_x_operacion.COD_ESTADO + "," + ContenedorGarantias_valor_x_operacion.COD_GARANTIA_VALOR + "," +
						   ContenedorGarantias_valor_x_operacion.COD_GRADO_GRAVAMEN + "," + ContenedorGarantias_valor_x_operacion.COD_GRADO_PRIORIDADES + "," +
						   ContenedorGarantias_valor_x_operacion.COD_INSCRIPCION + "," + ContenedorGarantias_valor_x_operacion.COD_OPERACION + "," +
						   ContenedorGarantias_valor_x_operacion.COD_OPERACION_ESPECIAL + "," + ContenedorGarantias_valor_x_operacion.COD_TIPO_ACREEDOR + "," +
						   ContenedorGarantias_valor_x_operacion.COD_TIPO_DOCUMENTO_LEGAL + "," + ContenedorGarantias_valor_x_operacion.COD_TIPO_MITIGADOR + "," +
						   ContenedorGarantias_valor_x_operacion.COD_OPERACION_ESPECIAL + "," + ContenedorGarantias_valor_x_operacion.COD_TIPO_ACREEDOR + "," +
						   ContenedorGarantias_valor_x_operacion.FECHA_PRESENTACION_REGISTRO + "," + ContenedorGarantias_valor_x_operacion.MONTO_MITIGADOR + "," +
						   ContenedorGarantias_valor_x_operacion.MONTO_PRIORIDADES + "," + ContenedorGarantias_valor_x_operacion.PORCENTAJE_RESPONSABILIDAD +
						  " from " + ContenedorGarantias_valor_x_operacion.NOMBRE_ENTIDAD +
						   " where " + ContenedorGarantias_valor_x_operacion.COD_OPERACION + " = " + nOperacion.ToString() +
						   " and " + ContenedorGarantias_valor_x_operacion.COD_GARANTIA_VALOR + " = " + nGarantia.ToString());


					DataSet dsGarantiaValor = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_valor.NUMERO_SEGURIDAD +
						" from " + ContenedorGarantia_valor.NOMBRE_ENTIDAD +
						" where " + ContenedorGarantia_valor.COD_GARANTIA_VALOR + " = " + nGarantia.ToString());

					#endregion

					//Abre la conexion
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						Bitacora oBitacora = new Bitacora();

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						string strEliminarGarValorXOperacion = "DELETE GAR_GARANTIAS_VALOR_X_OPERACION WHERE cod_operacion = " +
								nOperacion.ToString() + " AND cod_garantia_valor = " + nGarantia.ToString();


						if ((dsGarantiaValorXOperacion != null) && (dsGarantiaValorXOperacion.Tables.Count > 0) && (dsGarantiaValorXOperacion.Tables[0].Rows.Count > 0))
						{
							#region Obtener Datos Relevantes
							if ((dsGarantiaValor != null) && (dsGarantiaValor.Tables.Count > 0)
							   && (dsGarantiaValor.Tables[0].Rows.Count > 0) && (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.NUMERO_SEGURIDAD)))
							{
								mstrGarantia = dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.NUMERO_SEGURIDAD].ToString();
							}

							if (strOperacionCrediticia != string.Empty)
							{
								mstrOperacionCrediticia = strOperacionCrediticia;
							}

							#endregion

							#region Garantía Valor por Operación

							foreach (DataRow drGarValorXOP in dsGarantiaValorXOperacion.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drGarValorXOP.Table.Columns.Count; nIndice++)
								{
									switch (drGarValorXOP.Table.Columns[nIndice].ColumnName)
									{
										case ContenedorGarantias_valor_x_operacion.COD_ESTADO:
											if (drGarValorXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
												   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
												   drGarValorXOP.Table.Columns[nIndice].ColumnName,
												   oTraductor.TraducirTipoEstado(Convert.ToInt32(drGarValorXOP[nIndice, DataRowVersion.Current].ToString())),
												   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
												   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
												   drGarValorXOP.Table.Columns[nIndice].ColumnName,
												   string.Empty,
												   string.Empty);
											}
											break;

										case ContenedorGarantias_valor_x_operacion.COD_GARANTIA_VALOR: oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
																									   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
																									   drGarValorXOP.Table.Columns[nIndice].ColumnName,
																									   mstrGarantia,
																									   string.Empty);
											break;

										case ContenedorGarantias_valor_x_operacion.COD_GRADO_GRAVAMEN:
											if (drGarValorXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   oTraductor.TraducirGradoGravamen(Convert.ToInt32(drGarValorXOP[nIndice, DataRowVersion.Current].ToString())),
													   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   string.Empty,
													   string.Empty);
											}
											break;

										case ContenedorGarantias_valor_x_operacion.COD_INSCRIPCION:
											if (drGarValorXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   oTraductor.TraducirTipoInscripcion(Convert.ToInt32(drGarValorXOP[nIndice, DataRowVersion.Current].ToString())),
													   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   string.Empty,
													   string.Empty);
											}
											break;

										case ContenedorGarantias_valor_x_operacion.COD_OPERACION: oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
																									   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
																									   drGarValorXOP.Table.Columns[nIndice].ColumnName,
																									   mstrOperacionCrediticia,
																									   string.Empty);
											break;

										case ContenedorGarantias_valor_x_operacion.COD_OPERACION_ESPECIAL:
											if (drGarValorXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   oTraductor.TraducirTipoOperacionEspecial(Convert.ToInt32(drGarValorXOP[nIndice, DataRowVersion.Current].ToString())),
													   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   string.Empty,
													   string.Empty);
											}
											break;

										case ContenedorGarantias_valor_x_operacion.COD_TIPO_ACREEDOR:
											if (drGarValorXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   oTraductor.TraducirTipoPersona(Convert.ToInt32(drGarValorXOP[nIndice, DataRowVersion.Current].ToString())),
													   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   string.Empty,
													   string.Empty);
											}
											break;

										case ContenedorGarantias_valor_x_operacion.COD_TIPO_DOCUMENTO_LEGAL:
											if (drGarValorXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   oTraductor.TraducirTipoDocumento(Convert.ToInt32(drGarValorXOP[nIndice, DataRowVersion.Current].ToString())),
													   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   string.Empty,
													   string.Empty);
											}
											break;

										case ContenedorGarantias_valor_x_operacion.COD_TIPO_MITIGADOR:
											if (drGarValorXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   oTraductor.TraducirTipoMitigador(Convert.ToInt32(drGarValorXOP[nIndice, DataRowVersion.Current].ToString())),
													   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
													   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
													   drGarValorXOP.Table.Columns[nIndice].ColumnName,
													   string.Empty,
													   string.Empty);
											}
											break;

										default: oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
												  3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
												  drGarValorXOP.Table.Columns[nIndice].ColumnName,
												  drGarValorXOP[nIndice, DataRowVersion.Current].ToString(),
												  string.Empty);
											break;
									}


								}
							}

							#endregion
						}
						else
						{
							oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
							   3, 3, mstrGarantia, mstrOperacionCrediticia, mstrOperacionCrediticia, string.Empty,
							   string.Empty,
							   string.Empty,
							   string.Empty);
						}
					}
				}
			}
			catch
			{
				throw;
			}
		}



        /// <summary>
        /// Permite obtener la información de una garantía especfica, así como las posibles inconsistencias que posea.
        /// </summary>
        /// <param name="nCodOperacion">Consecutivo de la operación de la cual se obtendrá la garantía</param>
        /// <param name="nContabilidad">Consecutivo de la garantía de la cual se requiere la información</param>
        /// <param name="nOficina"></param>
        /// <param name="nMoneda"></param>
        /// <param name="nProducto"></param>
        /// <param name="strUsuario">Identificación del usuario que realiza la consulta</param>
        ///  <param name="nCodGarantiaValor">Consecutivo de la garantía de la cual se requiere la información</param>
        /// <returns>DataSet, con los datos de la garanta consultada</returns>

        public DataSet ObtenerDatosGarantiaValor(long nOperacion, long nGarantia, string strUsuario) 
        {
            DataSet dsDatos = new DataSet();
            try
            {              
                SqlParameter[] parameters = new SqlParameter[] { 
                            new SqlParameter("piOperacion", SqlDbType.BigInt),                            
                            new SqlParameter("piGarantia", SqlDbType.BigInt) ,
                            new SqlParameter("psIDUsuario", SqlDbType.VarChar,30),
                            new SqlParameter("psRespuesta", SqlDbType.VarChar,100)   
                        };

                parameters[0].Value = nOperacion;
                parameters[1].Value = nGarantia;
                parameters[2].Value = strUsuario;
                parameters[3].Value = null;
                parameters[3].Direction = ParameterDirection.Output;

                // SqlParameter[] parametrosSalida = new SqlParameter[] { };

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();
                    dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "Consultar_Garantia_Valor", parameters);
                }
               

            }
            catch (Exception ex)
            {
                StringCollection parametros = new StringCollection();
                //parametros.Add(desGarantia);
                //parametros.Add(desOperacion);
                parametros.Add(("El error se da al obtener la información de la base de datos: " + ex.Message));

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS_DETALLE, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }
            return dsDatos;
        }

		#endregion
	}
}
