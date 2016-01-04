using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Specialized;
using System.Diagnostics;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;
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
        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        int nFilasAfectadas = 0;

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
                        string strOperacionCrediticia, string strDescripcionInstrumento, decimal porcentajeAceptacion)
		{
            string identifiacionGarantia = string.Format("Valor: {0}, relacionada a la operación/contrato: {1}", strSeguridad, strOperacionCrediticia);
            DataSet dsData = new DataSet();
            DataSet dsGarantiaValor = new DataSet();

            try
            {
                //Obtener la información sobre la Garantía Valor, esto por si se debe insertar
                listaCampos = new string[] { clsGarantiaValor._consecutivoGarantiaValor,
                                             clsGarantiaValor._entidadGarantiaValor,
                                             clsGarantiaValor._codigoClaseGarantia, nClaseGarantia.ToString(),
                                             clsGarantiaValor._numeroSeguridad, strSeguridad};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3} AND {5} = '{5}'", listaCampos);

                dsGarantiaValor = AccesoBD.ejecutarConsulta(sentenciaSql);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_InsertarGarantiaValor", oConexion))
                    {
                        SqlParameter oParam = new SqlParameter();

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        //Agrega los parametros
                        oComando.Parameters.AddWithValue("@piTipo_Garantia", nTipoGarantia);
                        oComando.Parameters.AddWithValue("@piClase_Garantia", nClaseGarantia);
                        oComando.Parameters.AddWithValue("@psNumero_Seguridad", strSeguridad);

                        oComando.Parameters.AddWithValue("@pdtFecha_Constitucion", dFechaConstitucion);
                        oComando.Parameters.AddWithValue("@pdtFecha_Vencimiento", dFechaVencimiento);

                        if (nClasificacion != -1)
                            oComando.Parameters.AddWithValue("@piClasificacion", nClasificacion);

                        if (strInstrumento != "")
                            oComando.Parameters.AddWithValue("@psInstrumento", strInstrumento);

                        if (strSerie != "")
                            oComando.Parameters.AddWithValue("@psSerie", strSerie);

                        if (nTipoEmisor != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Emisor", nTipoEmisor);

                        if (strEmisor != "")
                            oComando.Parameters.AddWithValue("@psCedula_Emisor", strEmisor);

                        oComando.Parameters.AddWithValue("@pdPremio", nPremio);

                        if (strISIN != "")
                            oComando.Parameters.AddWithValue("@psISIN", strISIN);

                        if (nValorFacial != 0)
                            oComando.Parameters.AddWithValue("@pdValor_Facial", nValorFacial);

                        if (nMonedaValorFacial != -1)
                            oComando.Parameters.AddWithValue("@piMoneda_Valor_Facial", nMonedaValorFacial);

                        if (nValorMercado != 0)
                            oComando.Parameters.AddWithValue("@pdValor_Mercado", nValorMercado);

                        if (nMonedaValorMercado != -1)
                            oComando.Parameters.AddWithValue("@pdMoneda_Valor_Mercado", nMonedaValorMercado);

                        if (nTenencia != -1)
                            oComando.Parameters.AddWithValue("@piTenencia", nTenencia);

                        oComando.Parameters.AddWithValue("@pdtFecha_Prescripcion", dFechaPrescripcion);
                        oComando.Parameters.AddWithValue("@pbConsecutivo_Operacion", nOperacion);

                        if (nTipoMitigador != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Mitigador", nTipoMitigador);

                        if (nTipoDocumento != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Documento_Legal", nTipoDocumento);

                        oComando.Parameters.AddWithValue("@pdMonto_Mitigador", nMontoMitigador);

                        if (nInscripcion != -1)
                            oComando.Parameters.AddWithValue("@piInscripcion", nInscripcion);

                        oComando.Parameters.AddWithValue("@pdPorcentaje_Responsabilidad", nPorcentaje);
                        oComando.Parameters.AddWithValue("@piGrado_Gravamen", nGradoGravamen);

                        if (nGradoPrioridades != -1)
                            oComando.Parameters.AddWithValue("@piGrado_Prioridades", nGradoPrioridades);

                        if (nMontoPrioridades != 0)
                            oComando.Parameters.AddWithValue("@pdMonto_Prioridades", nMontoPrioridades);

                        if (nOperacionEspecial != -1)
                            oComando.Parameters.AddWithValue("@piOperacion_Especial", nOperacionEspecial);

                        if (nTipoAcreedor != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Acreedor", nTipoAcreedor);

                        if (strCedulaAcreedor != "")
                            oComando.Parameters.AddWithValue("@psCedula_Acreedor", strCedulaAcreedor);

                        oComando.Parameters.AddWithValue("@pdPorcentaje_Aceptacion", porcentajeAceptacion);
                                               
                        //Abre la conexion
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        nFilasAfectadas = oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }

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

                        listaCampos = new string[] {clsGarantiaValor._entidadGarantiaValor,
                                                    clsGarantiaValor._codigoTipoGarantia, clsGarantiaValor._codigoClaseGarantia, clsGarantiaValor._numeroSeguridad, clsGarantiaValor._fechaConstitucion,
                                                    clsGarantiaValor._fechaVencimientoInstrumento, clsGarantiaValor._codigoClasificacionInstrumento, clsGarantiaValor._descripcionInstrumento, clsGarantiaValor._serieInstrumento,
                                                    clsGarantiaValor._codigoTipoPersonaEmisor, clsGarantiaValor._cedulaEmisor, clsGarantiaValor._porcentajePremio, clsGarantiaValor._codigoIsin, clsGarantiaValor._montoValorFacial,
                                                    clsGarantiaValor._codigoMonedaValorFacial, clsGarantiaValor._montoValorMercado, clsGarantiaValor._codigoMonedaValorMercado, clsGarantiaValor._codigoTenencia,
                                                    clsGarantiaValor._fechaPrescripcion,
                                                    nTipoGarantia.ToString(), nClaseGarantia.ToString(), strSeguridad, dFechaConstitucion.ToShortDateString(), dFechaVencimiento.ToShortDateString(),
                                                    nClasificacion.ToString(), strInstrumento, strSerie, nTipoEmisor.ToString(), strEmisor, nPremio.ToString(), strISIN, nValorFacial.ToString(),
                                                    nMonedaValorFacial.ToString(), nValorMercado.ToString(), nMonedaValorMercado.ToString(), nTenencia.ToString(), dFechaPrescripcion.ToShortDateString()};

                        string strInsertarGarantiaValor = string.Format("INSERT INTO dbo.{0} ({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}) VALUES({19}, {20}, {21}, {22}, {23}, {24}, {25}, {26}, {27}, {28}, {29}, {30}, {31}, {32}, {33}, {34}, {35}, {36})", listaCampos);
 
                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._codigoTipoGarantia,
                            string.Empty,
                            oTraductor.TraducirTipoGarantia(nTipoGarantia));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._codigoClaseGarantia,
                            string.Empty,
                            oTraductor.TraducirClaseGarantia(nClaseGarantia));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._numeroSeguridad,
                            string.Empty,
                            strSeguridad);

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._fechaConstitucion,
                            string.Empty,
                            dFechaConstitucion.ToShortDateString());

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._fechaVencimientoInstrumento,
                            string.Empty,
                            dFechaVencimiento.ToShortDateString());

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._codigoClasificacionInstrumento,
                            string.Empty,
                            oTraductor.TraducirTipoClasificacionInstrumento(nClasificacion));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._descripcionInstrumento,
                            string.Empty,
                            strDescripcionInstrumento);

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._serieInstrumento,
                            string.Empty,
                            strSerie);

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._codigoTipoPersonaEmisor,
                            string.Empty,
                            oTraductor.TraducirTipoPersona(nTipoEmisor));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._cedulaEmisor,
                            string.Empty,
                            strEmisor);

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._porcentajePremio,
                            string.Empty,
                            nPremio.ToString("N2"));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._codigoIsin,
                            string.Empty,
                            strISIN);

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._montoValorFacial,
                            string.Empty,
                            nValorFacial.ToString("N2"));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._codigoMonedaValorFacial,
                            string.Empty,
                            oTraductor.TraducirTipoMoneda(nMonedaValorFacial));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._montoValorMercado,
                            string.Empty,
                            nValorMercado.ToString("N2"));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._codigoMonedaValorMercado,
                            string.Empty,
                            oTraductor.TraducirTipoMoneda(nMonedaValorMercado));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._codigoTenencia,
                            string.Empty,
                            oTraductor.TraducirTipoTenencia(nTenencia));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                            1, nTipoGarantia, strSeguridad, mstrOperacionCrediticia, strInsertarGarantiaValor, string.Empty,
                            clsGarantiaValor._fechaPrescripcion, string.Empty, dFechaPrescripcion.ToShortDateString());

                        dsGarantiaValor = AccesoBD.ejecutarConsulta(sentenciaSql);

                        #endregion
                    }

                    if ((dsGarantiaValor != null) && (dsGarantiaValor.Tables.Count > 0) && (dsGarantiaValor.Tables[0].Rows.Count > 0))
                    {
                        #region Inserción en Bitácora de la garantía valor por operación

                        string strCodigoGarantiaValor = dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._consecutivoGarantiaValor].ToString();

                        mstrGarantia = strSeguridad;

                        listaCampos = new string[] {clsGarantiaValor._entidadGarantiaValorXOperacion,
                                                    clsGarantiaValor._consecutivoOperacion, clsGarantiaValor._consecutivoGarantiaValor, clsGarantiaValor._codigoTipoMitigador, clsGarantiaValor._codigoTipoDocumentoLegal,
                                                    clsGarantiaValor._montoMitigador, clsGarantiaValor._codigoIndicadorInscripcion, clsGarantiaValor._porcentajeResponsabilidad, clsGarantiaValor._codigoGradoGravamen,
                                                    clsGarantiaValor._codigoGradoPrioridades, clsGarantiaValor._montoPrioridades, clsGarantiaValor._codigoOperacionEspecial, clsGarantiaValor._codigoTipoPersonaAcreedor, 
                                                    clsGarantiaValor._cedulaAcreedor, clsGarantiaValor._porcentajeAceptacion,
                                                    nOperacion.ToString(), strCodigoGarantiaValor, nTipoMitigador.ToString(), nTipoDocumento.ToString(), nMontoMitigador.ToString(), nInscripcion.ToString(),
                                                    nPorcentaje.ToString(), nGradoGravamen.ToString(), nGradoPrioridades.ToString(), nMontoPrioridades.ToString(), nOperacionEspecial.ToString(),
                                                    nTipoAcreedor.ToString(), strCedulaAcreedor, porcentajeAceptacion.ToString()};

                        string strInsertarGarValorXOperacion = string.Format("INSERT INTO dbo.{0} ({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}) VALUES({15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24}, {25}, {26}, {27}, {28})", listaCampos);

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._consecutivoOperacion,
                            string.Empty,
                            mstrOperacionCrediticia);

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._consecutivoGarantiaValor,
                            string.Empty,
                            mstrGarantia);

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._codigoTipoMitigador,
                            string.Empty,
                            oTraductor.TraducirTipoMitigador(nTipoMitigador));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._codigoTipoDocumentoLegal,
                            string.Empty,
                            oTraductor.TraducirTipoDocumento(nTipoDocumento));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._montoMitigador, "0", nMontoMitigador.ToString("N2"));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._codigoIndicadorInscripcion,
                            string.Empty,
                            oTraductor.TraducirTipoInscripcion(nInscripcion));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._porcentajeResponsabilidad,
                            string.Empty,
                            nPorcentaje.ToString("N2"));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._codigoGradoGravamen,
                            string.Empty,
                            oTraductor.TraducirGradoGravamen(nGradoGravamen));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._codigoGradoPrioridades,
                            string.Empty,
                            nGradoPrioridades.ToString());

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._montoPrioridades,
                            string.Empty,
                            nMontoPrioridades.ToString("N2"));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._codigoOperacionEspecial,
                            string.Empty,
                            oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._codigoTipoPersonaAcreedor,
                            string.Empty,
                            oTraductor.TraducirTipoPersona(nTipoAcreedor));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._cedulaAcreedor,
                            string.Empty,
                            strCedulaAcreedor);

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strInsertarGarValorXOperacion, string.Empty,
                            clsGarantiaValor._porcentajeAceptacion,
                            string.Empty,
                            porcentajeAceptacion.ToString("N2"));

                        #endregion
                    }

                    #endregion
                }
            }
            catch (SqlException ex)
            {
                string errorBD = string.Format("Código del Error: {0}, Descripción del error: {1}", ex.ErrorCode.ToString(), ex.Message);
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoGarantiaDetalle, identifiacionGarantia, errorBD, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                throw ex;
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoGarantiaDetalle, identifiacionGarantia, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                throw ex;
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
                            string strOperacionCrediticia, string strDescripcionInstrumento, string strDescInstNuevo, decimal porcentajeAceptacion)
		{
            string identifiacionGarantia = string.Format("Valor: {0}, relacionada a la operación/contrato: {1}", strSeguridad, strOperacionCrediticia);
            DateTime fechaBase = new DateTime(1900, 01, 01);
            DataSet dsData = new DataSet();
            DataSet dsGarantiaValor = new DataSet();
            DataSet dsGarantiaValorXOperacion = new DataSet();

            try
            {
                #region Obtener los datos que podrían cambiar antes de que se actualicen

                listaCampos = new string[] {clsGarantiaValor._fechaConstitucion, clsGarantiaValor._fechaVencimientoInstrumento, clsGarantiaValor._codigoClasificacionInstrumento,
                                            clsGarantiaValor._descripcionInstrumento, clsGarantiaValor._serieInstrumento, clsGarantiaValor._codigoTipoPersonaEmisor,
                                            clsGarantiaValor._cedulaEmisor, clsGarantiaValor._porcentajePremio, clsGarantiaValor._codigoIsin, clsGarantiaValor._montoValorFacial,
                                            clsGarantiaValor._codigoMonedaValorFacial, clsGarantiaValor._montoValorMercado, clsGarantiaValor._codigoMonedaValorMercado,
                                            clsGarantiaValor._codigoTenencia, clsGarantiaValor._fechaPrescripcion,
                                            clsGarantiaValor._entidadGarantiaValor,
                                            clsGarantiaValor._consecutivoGarantiaValor, nGarantiaValor.ToString()};

               sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}  FROM dbo.{15} WHERE {16} = {17})", listaCampos);

                dsGarantiaValor = AccesoBD.ejecutarConsulta(sentenciaSql);

                listaCampos = new string[] {clsGarantiaValor._codigoTipoMitigador, clsGarantiaValor._codigoTipoDocumentoLegal, clsGarantiaValor._montoMitigador,
                                            clsGarantiaValor._codigoIndicadorInscripcion, clsGarantiaValor._porcentajeResponsabilidad, clsGarantiaValor._codigoGradoGravamen,
                                            clsGarantiaValor._codigoGradoPrioridades, clsGarantiaValor._montoPrioridades, clsGarantiaValor._codigoOperacionEspecial,
                                            clsGarantiaValor._codigoTipoPersonaAcreedor, clsGarantiaValor._cedulaAcreedor, clsGarantiaValor._porcentajeAceptacion,
                                            clsGarantiaValor._entidadGarantiaValorXOperacion,
                                            clsGarantiaValor._consecutivoOperacion, nOperacion.ToString(),
                                            clsGarantiaValor._consecutivoGarantiaValor, nGarantiaValor.ToString()};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11} FROM dbo.{12} WHERE {13} = {14} AND {15} = {16})", listaCampos);
 
                dsGarantiaValorXOperacion = AccesoBD.ejecutarConsulta(sentenciaSql);

                #endregion

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_ModificarGarantiaValor", oConexion))
                    {
                        SqlParameter oParam = new SqlParameter();

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        //Agrega los parametros
                        oComando.Parameters.AddWithValue("@piConsecutivo_Garantia_Valor", nGarantiaValor);
                        oComando.Parameters.AddWithValue("@piTipo_Garantia", nTipoGarantia);
                        oComando.Parameters.AddWithValue("@piClase_Garantia", nClaseGarantia);
                        oComando.Parameters.AddWithValue("@psNumero_Seguridad", strSeguridad);

                        oComando.Parameters.AddWithValue("@pdtFecha_Constitucion", dFechaConstitucion);
                        oComando.Parameters.AddWithValue("@pdtFecha_Vencimiento", dFechaVencimiento);

                        if (nClasificacion != -1)
                            oComando.Parameters.AddWithValue("@piCodigo_Clasificacion", nClasificacion);

                        if (strInstrumento != "")
                            oComando.Parameters.AddWithValue("@psCodigo_Instrumento", strInstrumento);

                        if (strSerie != "")
                            oComando.Parameters.AddWithValue("@psNumero_Serie", strSerie);

                        if (nTipoEmisor != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Emisor", nTipoEmisor);

                        if (strEmisor != "")
                            oComando.Parameters.AddWithValue("@psCedula_Emisor", strEmisor);

                        oComando.Parameters.AddWithValue("@pdPorcentaje_Premio", nPremio);

                        if (strISIN != "")
                            oComando.Parameters.AddWithValue("@psCodigo_ISIN", strISIN);

                        if (nValorFacial != 0)
                            oComando.Parameters.AddWithValue("@pdValor_Facial", nValorFacial);

                        if (nMonedaValorFacial != -1)
                            oComando.Parameters.AddWithValue("@piMoneda_Valor_Facial", nMonedaValorFacial);

                        if (nValorMercado != 0)
                            oComando.Parameters.AddWithValue("@pdValor_Mercado", nValorMercado);

                        if (nMonedaValorMercado != -1)
                            oComando.Parameters.AddWithValue("@piMoneda_Valor_Mercado", nMonedaValorMercado);

                        if (nTenencia != -1)
                            oComando.Parameters.AddWithValue("@piCodigo_Tenencia", nTenencia);

                        oComando.Parameters.AddWithValue("@pdtFecha_Prescripcion", dFechaPrescripcion);
                        oComando.Parameters.AddWithValue("@piConsecutivo_Operacion", nOperacion);

                        if (nTipoMitigador != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Mitigador", nTipoMitigador);

                        if (nTipoDocumento != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Documento_Legal", nTipoDocumento);

                        oComando.Parameters.AddWithValue("@pdMonto_Mitigador", nMontoMitigador);

                        if (nInscripcion != -1)
                            oComando.Parameters.AddWithValue("@piCodigo_Inscripcion", nInscripcion);

                        oComando.Parameters.AddWithValue("@pdPorcentaje_Responsabilidad", nPorcentaje);
                        oComando.Parameters.AddWithValue("@piGrado_Gravamen", nGradoGravamen);

                        if (nGradoPrioridades != -1)
                            oComando.Parameters.AddWithValue("@piGrado_Prioridades", nGradoPrioridades);

                        if (nMontoPrioridades != 0)
                            oComando.Parameters.AddWithValue("@pdMonto_Prioridades", nMontoPrioridades);

                        if (nOperacionEspecial != -1)
                            oComando.Parameters.AddWithValue("@piOperacion_Especial", nOperacionEspecial);

                        if (nTipoAcreedor != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Acreedor", nTipoAcreedor);

                        if (strCedulaAcreedor != "")
                            oComando.Parameters.AddWithValue("@psCedula_Acreedor", strCedulaAcreedor);

                        oComando.Parameters.AddWithValue("@psCedula_Usuario", strUsuario);
                        oComando.Parameters.AddWithValue("@pdPorcentaje_Aceptacion", porcentajeAceptacion);
                        
                        //Abre la conexion
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        nFilasAfectadas = oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }

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
                        listaCampos = new string[] {clsGarantiaValor._entidadGarantiaValor, 
                                                    clsGarantiaValor._fechaConstitucion, dFechaConstitucion.ToShortDateString(),
                                                    clsGarantiaValor._fechaVencimientoInstrumento, dFechaVencimiento.ToShortDateString(),
                                                    clsGarantiaValor._codigoClasificacionInstrumento, nClasificacion.ToString(),
                                                    clsGarantiaValor._descripcionInstrumento, strInstrumento,
                                                    clsGarantiaValor._serieInstrumento, strSerie,
                                                    clsGarantiaValor._codigoTipoPersonaEmisor, nTipoEmisor.ToString(),
                                                    clsGarantiaValor._cedulaEmisor, strEmisor,
                                                    clsGarantiaValor._porcentajePremio, nPremio.ToString(),
                                                    clsGarantiaValor._codigoIsin, strISIN,
                                                    clsGarantiaValor._montoValorFacial, nValorFacial.ToString(),
                                                    clsGarantiaValor._codigoMonedaValorFacial, nMonedaValorFacial.ToString(),
                                                    clsGarantiaValor._montoValorMercado, nValorMercado.ToString(),
                                                    clsGarantiaValor._codigoMonedaValorMercado, nMonedaValorMercado.ToString(),
                                                    clsGarantiaValor._codigoTenencia, nTenencia.ToString(),
                                                    clsGarantiaValor._fechaPrescripcion, dFechaPrescripcion.ToShortDateString(),
                                                    clsGarantiaValor._consecutivoGarantiaValor, nGarantiaValor.ToString()};

                        string strModificarGarntiaValor = string.Format("UPDATE {0} SET {1} = {2}, {3} = {4}, {5} = {6}, {7} = {8}, {9} = {10}, {11} = {12}, {13} = {14}, {15} = {16}, {17} = {18}, {19} = {20}, {21} = {22}, {23} = {24}, {25} = {26}, {27} = {28}, {29} = {30} WHERE {31} = {32}", listaCampos);

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._fechaConstitucion))
                        {
                            DateTime dFechaConstitucionObt = Convert.ToDateTime(dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._fechaConstitucion].ToString());

                            if (dFechaConstitucionObt != dFechaConstitucion)
                            {
                                string fechaConstitucionObt = (((dFechaConstitucionObt != fechaBase) && (dFechaConstitucionObt != DateTime.MinValue)) ? dFechaConstitucionObt.ToString("dd/MM/yyyy") : string.Empty);
                                string fechaConstitucion = (((dFechaConstitucion != fechaBase) && (dFechaConstitucion != DateTime.MinValue)) ? dFechaConstitucion.ToString("dd/MM/yyyy") : string.Empty);

                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._fechaConstitucion,
                                    fechaConstitucionObt,
                                    fechaConstitucion);
                            }
                        }
                        else
                        {
                            string fechaConstitucion = (((dFechaConstitucion != fechaBase) && (dFechaConstitucion != DateTime.MinValue)) ? dFechaConstitucion.ToString("dd/MM/yyyy") : string.Empty);

                            oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._fechaConstitucion,
                                    string.Empty,
                                    fechaConstitucion);
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._fechaVencimientoInstrumento))
                        {
                            DateTime dFechaVencimientoInstrumentoObt = Convert.ToDateTime(dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._fechaVencimientoInstrumento].ToString());

                            if (dFechaVencimientoInstrumentoObt != dFechaVencimiento)
                            {
                                string fechaVencimientoInstrumentoObt = (((dFechaVencimientoInstrumentoObt != fechaBase) && (dFechaVencimientoInstrumentoObt != DateTime.MinValue)) ? dFechaVencimientoInstrumentoObt.ToString("dd/MM/yyyy") : string.Empty);
                                string fechaVencimientoInstrumento = (((dFechaVencimiento != fechaBase) && (dFechaVencimiento != DateTime.MinValue)) ? dFechaVencimiento.ToString("dd/MM/yyyy") : string.Empty);

                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._fechaVencimientoInstrumento,
                                    fechaVencimientoInstrumentoObt,
                                    fechaVencimientoInstrumento);
                            }
                        }
                        else
                        {
                            string fechaVencimientoInstrumento = (((dFechaVencimiento != fechaBase) && (dFechaVencimiento != DateTime.MinValue)) ? dFechaVencimiento.ToString("dd/MM/yyyy") : string.Empty);

                            oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._fechaVencimientoInstrumento,
                                    string.Empty,
                                    fechaVencimientoInstrumento);
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoClasificacionInstrumento))
                        {
                            int nCodigoClasificacionInstrumentoObt = Convert.ToInt32(dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._codigoClasificacionInstrumento].ToString());

                            if ((nClasificacion != -1) && (nCodigoClasificacionInstrumentoObt != nClasificacion))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._codigoClasificacionInstrumento,
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
                                        clsGarantiaValor._codigoClasificacionInstrumento,
                                        string.Empty,
                                        oTraductor.TraducirTipoClasificacionInstrumento(nClasificacion));
                            }
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._descripcionInstrumento))
                        {
                            string strDescripInstrumObt = dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._descripcionInstrumento].ToString();

                            if ((strDescripcionInstrumento != string.Empty) && (strDescInstNuevo != string.Empty)
                                  && (strDescripcionInstrumento.CompareTo(strDescInstNuevo) != 0))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._descripcionInstrumento,
                                    strDescripcionInstrumento,
                                    strDescInstNuevo);
                            }
                            else if (strDescripInstrumObt.CompareTo(strInstrumento) != 0)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                   2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                   clsGarantiaValor._descripcionInstrumento,
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
                                        clsGarantiaValor._descripcionInstrumento,
                                        strDescripcionInstrumento,
                                        strDescInstNuevo);
                                }
                                else
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                           2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                           clsGarantiaValor._descripcionInstrumento,
                                           string.Empty,
                                           strInstrumento);
                                }
                            }
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._serieInstrumento))
                        {
                            string strDescripcionSerieInstrumentoObt = dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._serieInstrumento].ToString();

                            if (strDescripcionSerieInstrumentoObt.CompareTo(strSerie) != 0)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._serieInstrumento,
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
                                        clsGarantiaValor._serieInstrumento,
                                        string.Empty,
                                        strSerie);
                            }
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoTipoPersonaEmisor))
                        {
                            int nCodigoTipoEmisorObt = Convert.ToInt32(dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._codigoTipoPersonaEmisor].ToString());

                            if ((nTipoEmisor != -1) && (nCodigoTipoEmisorObt != nTipoEmisor))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._codigoTipoPersonaEmisor,
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
                                        clsGarantiaValor._codigoTipoPersonaEmisor,
                                        string.Empty,
                                        oTraductor.TraducirTipoPersona(nTipoEmisor));
                            }
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._cedulaEmisor))
                        {
                            string strCedulaEmisorObt = dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._cedulaEmisor].ToString();

                            if ((strEmisor != string.Empty) && (strCedulaEmisorObt.CompareTo(strEmisor) != 0))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._cedulaEmisor,
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
                                        clsGarantiaValor._cedulaEmisor,
                                        string.Empty,
                                        strEmisor);
                            }
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._porcentajePremio))
                        {
                            decimal nPremioObt = Convert.ToDecimal(dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._porcentajePremio].ToString());

                            if (nPremioObt != nPremio)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._porcentajePremio,
                                    nPremioObt.ToString("N2"),
                                    nPremio.ToString("N2"));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._porcentajePremio,
                                    string.Empty,
                                    nPremio.ToString("N2"));
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoIsin))
                        {
                            string strCodigoIsinObt = dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._codigoIsin].ToString();

                            if ((strISIN != string.Empty) && (strCodigoIsinObt.CompareTo(strISIN) != 0))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._codigoIsin,
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
                                        clsGarantiaValor._codigoIsin,
                                        string.Empty,
                                        strISIN);
                            }
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._montoValorFacial))
                        {
                            decimal nValorFacialObt = Convert.ToDecimal(dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._montoValorFacial].ToString());

                            if (nValorFacialObt != nValorFacial)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._montoValorFacial,
                                    nValorFacialObt.ToString("N2"),
                                    nValorFacial.ToString("N2"));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._montoValorFacial,
                                    string.Empty,
                                    nValorFacial.ToString("N2"));
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoMonedaValorFacial))
                        {
                            int nMonedaValorFacialObt = Convert.ToInt32(dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._codigoMonedaValorFacial].ToString());

                            if ((nMonedaValorFacial != -1) && (nMonedaValorFacialObt != nMonedaValorFacial))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._codigoMonedaValorFacial,
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
                                        clsGarantiaValor._codigoMonedaValorFacial,
                                        string.Empty,
                                        oTraductor.TraducirTipoMoneda(nMonedaValorFacial));
                            }
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._montoValorMercado))
                        {
                            decimal nValorMercadoObt = Convert.ToDecimal(dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._montoValorMercado].ToString());

                            if (nValorMercadoObt != nValorMercado)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._montoValorMercado,
                                    nValorMercadoObt.ToString("N2"),
                                    nValorMercado.ToString("N2"));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._montoValorMercado,
                                    string.Empty,
                                    nValorMercado.ToString("N2"));
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoMonedaValorMercado))
                        {
                            int nMonedaValorMercadoObt = Convert.ToInt32(dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._codigoMonedaValorMercado].ToString());

                            if ((nMonedaValorMercado != -1) && (nMonedaValorMercadoObt != nMonedaValorMercado))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._codigoMonedaValorMercado,
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
                                        clsGarantiaValor._codigoMonedaValorMercado,
                                        string.Empty,
                                        oTraductor.TraducirTipoMoneda(nMonedaValorMercado));
                            }
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoTenencia))
                        {
                            int nCodigoTenenciaObt = Convert.ToInt32(dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._codigoTenencia].ToString());

                            if ((nTenencia != -1) && (nCodigoTenenciaObt != nTenencia))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._codigoTenencia,
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
                                        clsGarantiaValor._codigoTenencia,
                                        string.Empty,
                                        oTraductor.TraducirTipoTenencia(nTenencia));
                            }
                        }

                        if (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._fechaPrescripcion))
                        {
                            DateTime dFechaPrescripcionObt = Convert.ToDateTime(dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._fechaPrescripcion].ToString());

                            if (dFechaPrescripcionObt != dFechaPrescripcion)
                            {
                                string fechaPrescripcionObt = (((dFechaPrescripcionObt != fechaBase) && (dFechaPrescripcionObt != DateTime.MinValue)) ? dFechaPrescripcionObt.ToString("dd/MM/yyyy") : string.Empty);
                                string fechaPrescripcion = (((dFechaPrescripcion != fechaBase) && (dFechaPrescripcion != DateTime.MinValue)) ? dFechaPrescripcion.ToString("dd/MM/yyyy") : string.Empty);

                                oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._fechaPrescripcion,
                                    fechaPrescripcionObt,
                                    fechaPrescripcion);
                            }
                        }
                        else
                        {
                            string fechaPrescripcion = (((dFechaPrescripcion != fechaBase) && (dFechaPrescripcion != DateTime.MinValue)) ? dFechaPrescripcion.ToString("dd/MM/yyyy") : string.Empty);

                            oBitacora.InsertarBitacora("GAR_GARANTIA_VALOR", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarntiaValor, string.Empty,
                                    clsGarantiaValor._fechaPrescripcion,
                                    string.Empty,
                                    fechaPrescripcion);
                        }
                    }

                    #endregion

                    #region Inserción en Bitacora de las garantías valor por operación que han cambiado

                    if ((dsGarantiaValorXOperacion != null) && (dsGarantiaValorXOperacion.Tables.Count > 0) && (dsGarantiaValorXOperacion.Tables[0].Rows.Count > 0))
                    {
                        listaCampos = new string[] {clsGarantiaValor._entidadGarantiaValorXOperacion,
                                                    clsGarantiaValor._codigoTipoMitigador, nTipoMitigador.ToString(),
                                                    clsGarantiaValor._codigoTipoDocumentoLegal, nTipoDocumento.ToString(),
                                                    clsGarantiaValor._montoMitigador, nMontoMitigador.ToString(),
                                                    clsGarantiaValor._codigoIndicadorInscripcion, nInscripcion.ToString(), 
                                                    clsGarantiaValor._porcentajeResponsabilidad, nPorcentaje.ToString(),
                                                    clsGarantiaValor._codigoGradoGravamen, nGradoGravamen.ToString(),
                                                    clsGarantiaValor._codigoGradoPrioridades, nGradoPrioridades.ToString(),
                                                    clsGarantiaValor._montoPrioridades, nMontoPrioridades.ToString(), 
                                                    clsGarantiaValor._codigoOperacionEspecial, nOperacionEspecial.ToString(), 
                                                    clsGarantiaValor._codigoTipoPersonaAcreedor, nTipoAcreedor.ToString(),
                                                    clsGarantiaValor._cedulaAcreedor, strCedulaAcreedor,
                                                    clsGarantiaValor._porcentajeAceptacion, porcentajeAceptacion.ToString(),
                                                    clsGarantiaValor._consecutivoOperacion, nOperacion.ToString(),
                                                    clsGarantiaValor._consecutivoGarantiaValor, nGarantiaValor.ToString()};

                        string strModificarGarValorXOperacion = string.Format("UPDATE {0} SET {1} = {2}, {3} = {4}, {5} = {6}, {7} = {8}, {9} = {10}, {11} = {12}, {13} = {14}, {15} = {16}, {17} = {18}, {19} = {20}, {21} = {22}, {23} = {24} WHERE {25} = {26} AND {27} = {28}", listaCampos);

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoTipoMitigador))
                        {
                            int nCodigoTipoMitigadorObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._codigoTipoMitigador].ToString());

                            if ((nTipoMitigador != -1) && (nCodigoTipoMitigadorObt != nTipoMitigador))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._codigoTipoMitigador,
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
                                        clsGarantiaValor._codigoTipoMitigador,
                                        string.Empty,
                                        oTraductor.TraducirTipoMitigador(nTipoMitigador));
                            }
                        }

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoTipoDocumentoLegal))
                        {
                            int nCodigoTipoDocumentoLegalObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._codigoTipoDocumentoLegal].ToString());

                            if ((nTipoDocumento != -1) && (nCodigoTipoDocumentoLegalObt != nTipoDocumento))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._codigoTipoDocumentoLegal,
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
                                        clsGarantiaValor._codigoTipoDocumentoLegal,
                                        string.Empty,
                                        oTraductor.TraducirTipoDocumento(nTipoDocumento));
                            }
                        }

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._montoMitigador))
                        {
                            decimal nMontoMitigadorObt = Convert.ToDecimal(dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._montoMitigador].ToString());

                            if (nMontoMitigadorObt != nMontoMitigador)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._montoMitigador,
                                    nMontoMitigadorObt.ToString("N2"),
                                    nMontoMitigador.ToString("N2"));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._montoMitigador,
                                    string.Empty,
                                    nMontoMitigador.ToString("N2"));
                        }

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoIndicadorInscripcion))
                        {
                            int nCodigoInscripcionObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._codigoIndicadorInscripcion].ToString());

                            if ((nInscripcion != -1) && (nCodigoInscripcionObt != nInscripcion))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._codigoIndicadorInscripcion,
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
                                        clsGarantiaValor._codigoIndicadorInscripcion,
                                        string.Empty,
                                        oTraductor.TraducirTipoInscripcion(nInscripcion));
                            }
                        }

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._porcentajeResponsabilidad))
                        {
                            decimal nPorcentajeResponsabilidadObt = Convert.ToDecimal(dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._porcentajeResponsabilidad].ToString());

                            if (nPorcentajeResponsabilidadObt != nPorcentaje)
                            {
                                nPorcentajeResponsabilidadObt = ((nPorcentajeResponsabilidadObt > -1) ? nPorcentajeResponsabilidadObt : 0);
                                nPorcentaje = ((nPorcentaje > -1) ? nPorcentaje : 0);

                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._porcentajeResponsabilidad,
                                    nPorcentajeResponsabilidadObt.ToString("N2"),
                                    nPorcentaje.ToString("N2"));
                            }
                        }
                        else
                        {
                            nPorcentaje = ((nPorcentaje > -1) ? nPorcentaje : 0);

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._porcentajeResponsabilidad,
                                    string.Empty,
                                    nPorcentaje.ToString("N2"));
                        }

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoGradoGravamen))
                        {
                            int nCodigoGradoGravamenObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._codigoGradoGravamen].ToString());

                            if ((nGradoGravamen != -1) && (nCodigoGradoGravamenObt != nGradoGravamen))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._codigoGradoGravamen,
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
                                        clsGarantiaValor._codigoGradoGravamen,
                                        string.Empty,
                                        oTraductor.TraducirGradoGravamen(nGradoGravamen));
                            }
                        }

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoGradoPrioridades))
                        {
                            int nCodigoGradoPrioridadesObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._codigoGradoPrioridades].ToString());

                            if ((nGradoPrioridades != -1) && (nCodigoGradoPrioridadesObt != nGradoPrioridades))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._codigoGradoPrioridades,
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
                                        clsGarantiaValor._codigoGradoPrioridades,
                                        string.Empty,
                                        nGradoPrioridades.ToString());
                            }
                        }

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._montoPrioridades))
                        {
                            decimal nMontoPrioridadesObt = Convert.ToDecimal(dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._montoPrioridades].ToString());

                            if (nMontoPrioridadesObt != nMontoPrioridades)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._montoPrioridades,
                                    nMontoPrioridadesObt.ToString("N2"),
                                    nMontoPrioridades.ToString("N2"));
                            }
                        }
                        else
                        {
                            if (nMontoPrioridades != 0)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                        clsGarantiaValor._montoPrioridades,
                                        string.Empty,
                                        nMontoPrioridades.ToString("N2"));
                            }
                        }

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoOperacionEspecial))
                        {
                            int nCodigoOperacionEspecialObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._codigoOperacionEspecial].ToString());

                            if ((nOperacionEspecial != -1) && (nCodigoOperacionEspecialObt != -3)
                                && (nCodigoOperacionEspecialObt != nOperacionEspecial))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._codigoOperacionEspecial,
                                    oTraductor.TraducirTipoOperacionEspecial(nCodigoOperacionEspecialObt),
                                    oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));
                            }
                        }

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoTipoPersonaAcreedor))
                        {
                            int nCodigoTipoAcreedorObt = Convert.ToInt32(dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._codigoTipoPersonaAcreedor].ToString());

                            if ((nTipoAcreedor != -1) && (nCodigoTipoAcreedorObt != nTipoAcreedor))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._codigoTipoPersonaAcreedor,
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
                                        clsGarantiaValor._codigoTipoPersonaAcreedor,
                                        string.Empty,
                                        oTraductor.TraducirTipoPersona(nTipoAcreedor));
                            }
                        }

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._cedulaAcreedor))
                        {
                            string strCedulaAcreedorObt = dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._cedulaAcreedor].ToString();

                            if ((strCedulaAcreedor != string.Empty) && (strCedulaAcreedorObt.CompareTo(strCedulaAcreedor) != 0))
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._cedulaAcreedor,
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
                                        clsGarantiaValor._cedulaAcreedor,
                                        string.Empty,
                                        strCedulaAcreedor);
                            }
                        }

                        if (!dsGarantiaValorXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaValor._porcentajeAceptacion))
                        {
                            decimal porcentajeAceptacionObt = Convert.ToDecimal(dsGarantiaValorXOperacion.Tables[0].Rows[0][clsGarantiaValor._porcentajeAceptacion].ToString());

                            if (porcentajeAceptacionObt != porcentajeAceptacion)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._porcentajeAceptacion,
                                    porcentajeAceptacionObt.ToString("N2"),
                                    porcentajeAceptacion.ToString("N2"));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                    2, nTipoGarantia, mstrGarantia, mstrOperacionCrediticia, strModificarGarValorXOperacion, string.Empty,
                                    clsGarantiaValor._porcentajeAceptacion,
                                    string.Empty,
                                    porcentajeAceptacion.ToString("N2"));
                        }
                    }

                    #endregion

                    #endregion
                }
            }
            catch (SqlException ex)
            {
                string errorBD = string.Format("Código del Error: {0}, Descripción del error: {1}", ex.ErrorCode.ToString(), ex.Message);
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoGarantiaDetalle, identifiacionGarantia, errorBD, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                throw ex;
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoGarantiaDetalle, identifiacionGarantia, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                throw ex;
            }
        }

        public void Eliminar(long nOperacion, long nGarantia, string strUsuario, string strIP,
                             string strOperacionCrediticia)
		{
            DataSet dsData = new DataSet();
            DataSet dsGarantiaValor = new DataSet();
            DataSet dsGarantiaValorXOperacion = new DataSet();

            try
            {
                #region Obtener los datos antes de eliminarlos, con el fin de poder insertarlos en la bitácora

                listaCampos = new string[] {clsGarantiaValor._numeroSeguridad,
                                            clsGarantiaValor._entidadGarantiaValor,
                                            clsGarantiaValor._consecutivoGarantiaValor, nGarantia.ToString()};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3})", listaCampos);

                dsGarantiaValor = AccesoBD.ejecutarConsulta(sentenciaSql);

                listaCampos = new string[] {clsGarantiaValor._codigoTipoMitigador, clsGarantiaValor._codigoTipoDocumentoLegal, clsGarantiaValor._montoMitigador,
                                            clsGarantiaValor._codigoIndicadorInscripcion, clsGarantiaValor._porcentajeResponsabilidad, clsGarantiaValor._codigoGradoGravamen,
                                            clsGarantiaValor._codigoGradoPrioridades, clsGarantiaValor._montoPrioridades, clsGarantiaValor._codigoOperacionEspecial,
                                            clsGarantiaValor._codigoTipoPersonaAcreedor, clsGarantiaValor._cedulaAcreedor, clsGarantiaValor._porcentajeAceptacion,
                                            clsGarantiaValor._codigoEstadoRegistro, clsGarantiaValor._consecutivoGarantiaValor, clsGarantiaValor._consecutivoOperacion,
                                            clsGarantiaValor._fechaPresentacionRegistro, 
                                            clsGarantiaValor._entidadGarantiaValorXOperacion,
                                            clsGarantiaValor._consecutivoOperacion, nOperacion.ToString(),
                                            clsGarantiaValor._consecutivoGarantiaValor, nGarantia.ToString()};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15} FROM dbo.{16} WHERE {17} = {18} AND {19} = {20})", listaCampos);

                dsGarantiaValorXOperacion = AccesoBD.ejecutarConsulta(sentenciaSql);
                
                #endregion

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_EliminarGarantiaValor", oConexion))
                    {
                        SqlParameter oParam = new SqlParameter();

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        //Agrega los parametros
                        oComando.Parameters.AddWithValue("@nGarantiaValor", nGarantia);
                        oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
                        oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
                        oComando.Parameters.AddWithValue("@strIP", strIP);

                        //Abre la conexion
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        nFilasAfectadas = oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }

                if (nFilasAfectadas > 0)
                {
                    Bitacora oBitacora = new Bitacora();

                    TraductordeCodigos oTraductor = new TraductordeCodigos();

                    listaCampos = new string[] {clsGarantiaValor._entidadGarantiaValorXOperacion,
                                                clsGarantiaValor._consecutivoOperacion, nOperacion.ToString(),
                                                clsGarantiaValor._consecutivoGarantiaValor, nGarantia.ToString()};

                    string strEliminarGarValorXOperacion = string.Format("DELETE {0} WHERE {1} = {2} AND {3} = {4}", listaCampos);

                    if ((dsGarantiaValorXOperacion != null) && (dsGarantiaValorXOperacion.Tables.Count > 0) && (dsGarantiaValorXOperacion.Tables[0].Rows.Count > 0))
                    {
                        #region Obtener Datos Relevantes
                        if ((dsGarantiaValor != null) && (dsGarantiaValor.Tables.Count > 0)
                           && (dsGarantiaValor.Tables[0].Rows.Count > 0) && (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._numeroSeguridad)))
                        {
                            mstrGarantia = dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._numeroSeguridad].ToString();
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
                                    case clsGarantiaValor._codigoEstadoRegistro:
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

                                    case clsGarantiaValor._consecutivoGarantiaValor:
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                                      3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
                                                      drGarValorXOP.Table.Columns[nIndice].ColumnName,
                                                      mstrGarantia,
                                                      string.Empty);
                                        break;

                                    case clsGarantiaValor._codigoGradoGravamen:
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

                                    case clsGarantiaValor._codigoIndicadorInscripcion:
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

                                    case clsGarantiaValor._consecutivoOperacion:
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                                          3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
                                                          drGarValorXOP.Table.Columns[nIndice].ColumnName,
                                                          mstrOperacionCrediticia,
                                                          string.Empty);
                                        break;

                                    case clsGarantiaValor._codigoOperacionEspecial:
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

                                    case clsGarantiaValor._codigoTipoPersonaAcreedor:
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

                                    case clsGarantiaValor._codigoTipoDocumentoLegal:
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

                                    case clsGarantiaValor._codigoTipoMitigador:
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

                                    case clsGarantiaValor._montoMitigador:
                                        if (drGarValorXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            decimal montoMitigador = decimal.Parse((drGarValorXOP[nIndice, DataRowVersion.Current].ToString().Length > 0) ? drGarValorXOP[nIndice, DataRowVersion.Current].ToString() : "0");

                                            oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                                   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
                                                   drGarValorXOP.Table.Columns[nIndice].ColumnName,
                                                   montoMitigador.ToString("N2"),
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

                                    case clsGarantiaValor._montoPrioridades:
                                        if (drGarValorXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            decimal montoPrioridades = decimal.Parse((drGarValorXOP[nIndice, DataRowVersion.Current].ToString().Length > 0) ? drGarValorXOP[nIndice, DataRowVersion.Current].ToString() : "0");

                                            oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
                                                   3, 3, mstrGarantia, mstrOperacionCrediticia, strEliminarGarValorXOperacion, string.Empty,
                                                   drGarValorXOP.Table.Columns[nIndice].ColumnName,
                                                   montoPrioridades.ToString("N2"),
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


                                    default:
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_VALOR_X_OPERACION", strUsuario, strIP, null,
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
                            new SqlParameter("piConsecutivo_Operacion", SqlDbType.BigInt),                            
                            new SqlParameter("piConsecutivo_Garantia", SqlDbType.BigInt) ,
                            new SqlParameter("psCedula_Usuario", SqlDbType.VarChar,30),
                            new SqlParameter("psRespuesta", SqlDbType.VarChar,100)   
                        };

                parameters[0].Value = nOperacion;
                parameters[1].Value = nGarantia;
                parameters[2].Value = strUsuario;
                parameters[3].Value = null;
                parameters[3].Direction = ParameterDirection.Output;

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
