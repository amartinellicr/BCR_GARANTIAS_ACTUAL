using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Text;
using System.Collections.Specialized;
using System.Collections.Generic;

using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Garantias_Reales.
    /// </summary>
    public class Garantias_Reales
    {
        #region Variables

        bool procesoNormalizacion = false;

        #endregion Variables

        #region Métodos Públicos

        public void Crear(long nOperacion, int nTipoGarantia, int nClaseGarantia, int nTipoGarantiaReal,
                          int nPartido, string strFinca, int nGrado, int nCedulaFiduciaria,
                          string strClaseBien, string strNumPlaca, int nTipoBien,
                          int nTipoMitigador, int nTipoDocumento, decimal nMontoMitigador, int nInscripcion,
                          DateTime dFechaPresentacion, decimal nPorcentaje, int nGradoGravamen, int nOperacionEspecial,
                          DateTime dFechaConstitucion, DateTime dFechaVencimiento, int nTipoAcreedor,
                          string strCedulaAcreedor, int nLiquidez, int nTenencia, int nMoneda,
                          DateTime dFechaPrescripcion, string strUsuario, string strIP,
                          string strOperacionCrediticia, string strGarantia, decimal porcentajeAceptacion)
        {
            try
            {
                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    SqlCommand oComando = new SqlCommand("pa_InsertarGarantiaReal", oConexion);
                    DataSet dsData = new DataSet();
                    SqlParameter oParam = new SqlParameter();

                    //Declara las propiedades del comando
                    oComando.CommandType = CommandType.StoredProcedure;

                    //Agrega los parámetros
                    oComando.Parameters.AddWithValue("@piTipo_Garantia", nTipoGarantia);
                    oComando.Parameters.AddWithValue("@piClase_Garantia", nClaseGarantia);
                    oComando.Parameters.AddWithValue("@nTipoGarantiaReal", nTipoGarantiaReal);

                    if (nPartido != -1)
                        oComando.Parameters.AddWithValue("@piPartido", nPartido);

                    if (strFinca != "")
                        oComando.Parameters.AddWithValue("@psNumero_Finca", strFinca);

                    if (nGrado != -1)
                        oComando.Parameters.AddWithValue("@piGrado", nGrado);

                    if (nCedulaFiduciaria != -1)
                        oComando.Parameters.AddWithValue("@piCedula_Hipotecaria", nCedulaFiduciaria);

                    if (strClaseBien != "")
                        oComando.Parameters.AddWithValue("@psClase_Bien", strClaseBien);

                    if (strNumPlaca != "")
                        oComando.Parameters.AddWithValue("@psNumero_Placa", strNumPlaca);

                    if (nTipoBien != -1)
                        oComando.Parameters.AddWithValue("@piTipo_Bien", nTipoBien);

                    oComando.Parameters.AddWithValue("@pbConsecutivo_Operacion", nOperacion);

                    if (nTipoMitigador != -1)
                        oComando.Parameters.AddWithValue("@piTipo_Mitigador", nTipoMitigador);

                    if (nTipoDocumento != -1)
                        oComando.Parameters.AddWithValue("@piTipo_Documento_Legal", nTipoDocumento);

                    oComando.Parameters.AddWithValue("@pdMonto_Mitigador", nMontoMitigador);

                    if (nInscripcion != -1)
                        oComando.Parameters.AddWithValue("@piInscripcion", nInscripcion);

                    oComando.Parameters.AddWithValue("@pdtFecha_Presentacion", dFechaPresentacion);
                    oComando.Parameters.AddWithValue("@pdPorcentaje_Responsabilidad", nPorcentaje);
                    oComando.Parameters.AddWithValue("@piGrado_Gravamen", nGradoGravamen);

                    if (nOperacionEspecial != -1)
                        oComando.Parameters.AddWithValue("@piOperacion_Especial", nOperacionEspecial);

                    oComando.Parameters.AddWithValue("@pdtFecha_Constitucion", dFechaConstitucion);
                    oComando.Parameters.AddWithValue("@pdtFecha_Vencimiento", dFechaVencimiento);

                    if (nTipoAcreedor != -1)
                        oComando.Parameters.AddWithValue("@piTipo_Acreedor", nTipoAcreedor);

                    if (strCedulaAcreedor != "")
                        oComando.Parameters.AddWithValue("@psCedula_Acreedor", strCedulaAcreedor);

                    oComando.Parameters.AddWithValue("@piLiquidez", nLiquidez);
                    oComando.Parameters.AddWithValue("@piTenencia", nTenencia);
                    oComando.Parameters.AddWithValue("@pdtFecha_Prescripcion", dFechaPrescripcion);
                    oComando.Parameters.AddWithValue("@piMoneda", nMoneda);
                    oComando.Parameters.AddWithValue("@pdPorcentaje_Aceptacion", porcentajeAceptacion);
 
                    //Abre la conexión
                    oConexion.Open();

                    //Se obtiene la información sobre la Garantía Real, esto por si se debe insertar
                    #region Armar Consulta de la Garanta Real

                    string strConsultaGarantiasReales = "select " + ContenedorGarantia_real.COD_GARANTIA_REAL +
                        " from " + ContenedorGarantia_real.NOMBRE_ENTIDAD +
                        " where " + ContenedorGarantia_real.COD_CLASE_GARANTIA + " = " + nClaseGarantia.ToString() +
                        " and " + ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL + " = " + nTipoGarantiaReal.ToString();

                    if (nPartido != -1)
                    {
                        strConsultaGarantiasReales += " and " + ContenedorGarantia_real.COD_PARTIDO + " = " + nPartido.ToString();
                    }

                    if (strFinca != string.Empty)
                    {
                        strConsultaGarantiasReales += " and " + ContenedorGarantia_real.NUMERO_FINCA + " = '" + strFinca + "'";
                    }

                    if (nGrado != -1)
                    {
                        strConsultaGarantiasReales += " and " + ContenedorGarantia_real.COD_GRADO + " = " + nGrado.ToString();
                    }

                    if (nCedulaFiduciaria != -1)
                    {
                        strConsultaGarantiasReales += " and " + ContenedorGarantia_real.CEDULA_HIPOTECARIA + " = " + nCedulaFiduciaria.ToString();
                    }

                    if (strClaseBien != string.Empty)
                    {
                        strConsultaGarantiasReales += " and " + ContenedorGarantia_real.COD_CLASE_BIEN + " = " + strClaseBien;
                    }

                    if (strNumPlaca != string.Empty)
                    {
                        strConsultaGarantiasReales += " and " + ContenedorGarantia_real.NUM_PLACA_BIEN + " = '" + strNumPlaca + "'";
                    }

                    #endregion

                    DataSet dsGarantiaReal = AccesoBD.ejecutarConsulta(strConsultaGarantiasReales);

                    //Ejecuta el comando
                    int nFilasAfectadas = oComando.ExecuteNonQuery();

                    //Inserta en bitácora
                    if (nFilasAfectadas > 0)
                    {
                        #region Inserción en Bitácora

                        Bitacora oBitacora = new Bitacora();

                        TraductordeCodigos oTraductor = new TraductordeCodigos();


                        if ((dsGarantiaReal == null) || (dsGarantiaReal.Tables.Count == 0) || (dsGarantiaReal.Tables[0].Rows.Count == 0))
                        {
                            #region Inserción de Garantía Real

                            #region Armar String de Inserción de la Garantía Real

                            string strInsertaGarantiaReal = "INSERT INTO GAR_GARANTIA_REAL(cod_tipo_garantia,cod_clase_garantia," +
                                "cod_tipo_garantia_real,cod_partido,numero_finca,cod_grado,cedula_hipotecaria," +
                                "cod_clase_bien,num_placa_bien,cod_tipo_bien) VALUES(" + nTipoGarantia.ToString() + "," +
                                nClaseGarantia.ToString() + "," + nTipoGarantiaReal.ToString() + "," +
                                nPartido.ToString() + ",";

                            if (strFinca == null)
                            {
                                strInsertaGarantiaReal += "'',";
                            }
                            else
                            {
                                strInsertaGarantiaReal += strFinca + ",";
                            }

                            if (nGrado == 0)
                            {
                                strInsertaGarantiaReal += "-1,";
                            }
                            else
                            {
                                strInsertaGarantiaReal += nGrado.ToString() + ",";
                            }

                            if (nCedulaFiduciaria == 0)
                            {
                                strInsertaGarantiaReal += "-1,";
                            }
                            else
                            {
                                strInsertaGarantiaReal += nCedulaFiduciaria.ToString() + ",";
                            }

                            if (strClaseBien == null)
                            {
                                strInsertaGarantiaReal += "'',";
                            }
                            else
                            {
                                strInsertaGarantiaReal += strClaseBien + ",";
                            }

                            if (strNumPlaca == null)
                            {
                                strInsertaGarantiaReal += "'',";
                            }
                            else
                            {
                                strInsertaGarantiaReal += strNumPlaca + ",";
                            }

                            if (nTipoBien == 0)
                            {
                                strInsertaGarantiaReal += "'',";
                            }
                            else
                            {
                                strInsertaGarantiaReal += nTipoBien.ToString() + ",";
                            }

                            #endregion

                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                                ContenedorGarantia_real.COD_TIPO_GARANTIA,
                                string.Empty,
                                oTraductor.TraducirTipoGarantia(nTipoGarantia));

                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                                ContenedorGarantia_real.COD_CLASE_GARANTIA,
                                string.Empty,
                                oTraductor.TraducirClaseGarantia(nClaseGarantia));

                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                                ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL,
                                string.Empty,
                                oTraductor.TraducirTipoGarantiaReal(nTipoGarantiaReal));

                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                                ContenedorGarantia_real.COD_PARTIDO,
                                string.Empty,
                                nPartido.ToString());

                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                                ContenedorGarantia_real.NUMERO_FINCA,
                                string.Empty,
                                strFinca);

                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                                ContenedorGarantia_real.COD_GRADO,
                                string.Empty,
                                nGrado.ToString());

                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                                ContenedorGarantia_real.CEDULA_HIPOTECARIA,
                                string.Empty,
                                nCedulaFiduciaria.ToString());

                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                                ContenedorGarantia_real.COD_CLASE_BIEN,
                                string.Empty,
                                strClaseBien);

                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                                ContenedorGarantia_real.NUM_PLACA_BIEN,
                                string.Empty,
                                strNumPlaca);

                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                                ContenedorGarantia_real.COD_TIPO_BIEN,
                                string.Empty,
                                oTraductor.TraducirTipoBien(nTipoBien));

                            dsGarantiaReal = AccesoBD.ejecutarConsulta(strConsultaGarantiasReales);

                            #endregion
                        }

                        if ((dsGarantiaReal != null) && (dsGarantiaReal.Tables.Count > 0) && (dsGarantiaReal.Tables[0].Rows.Count > 0))
                        {
                            #region Inserción de Garantías Reales por Operación

                            string strCodigoGarantiaReal = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_GARANTIA_REAL].ToString();

                            #region Armar String de Inserción de la Garantía por Operación

                            string strInsertaGarRealXOperacion = "INSERT INTO GAR_GARANTIAS_REALES_X_OPERACION (cod_operacion,cod_garantia_real,cod_tipo_mitigador," +
                                                 "cod_tipo_documento_legal,monto_mitigador,cod_inscripcion,fecha_presentacion,porcentaje_responsabilidad," +
                                                 "cod_grado_gravamen,cod_operacion_especial,fecha_constitucion,fecha_vencimiento,cod_tipo_acreedor," +
                                                 "cedula_acreedor,cod_liquidez,cod_tenencia,fecha_prescripcion,cod_moneda,Porcentaje_Aceptacion) VALUES(" +
                                                 nOperacion.ToString() + "," + strCodigoGarantiaReal + "," + nTipoMitigador.ToString() + "," +
                                                 nTipoDocumento.ToString() + "," + nMontoMitigador.ToString() + ",";

                            if (nInscripcion == 0)
                            {
                                strInsertaGarRealXOperacion += "-1,";
                            }
                            else
                            {
                                strInsertaGarRealXOperacion += nInscripcion.ToString() + ",";
                            }

                            if (dFechaPresentacion != null)
                            {
                                strInsertaGarRealXOperacion += dFechaPresentacion.ToShortDateString() + ",";
                            }

                            if (nPorcentaje == 0)
                            {
                                strInsertaGarRealXOperacion += "0,";
                            }
                            else
                            {
                                strInsertaGarRealXOperacion += nPorcentaje.ToString() + ",";
                            }

                            strInsertaGarRealXOperacion += nGradoGravamen.ToString() + ",";

                            if (nOperacionEspecial == 0)
                            {
                                strInsertaGarRealXOperacion += "-1,";
                            }
                            else
                            {
                                strInsertaGarRealXOperacion += nOperacionEspecial.ToString() + ",";
                            }

                            if (dFechaConstitucion != null)
                            {
                                strInsertaGarRealXOperacion += dFechaConstitucion.ToShortDateString() + ",";
                            }

                            if (dFechaVencimiento != null)
                            {
                                strInsertaGarRealXOperacion += dFechaVencimiento.ToShortDateString() + ",";
                            }

                            if (nTipoAcreedor == 0)
                            {
                                strInsertaGarRealXOperacion += "-1,";
                            }
                            else
                            {
                                strInsertaGarRealXOperacion += nTipoAcreedor.ToString() + ",";
                            }

                            if (strCedulaAcreedor == null)
                            {
                                strInsertaGarRealXOperacion += "'',";
                            }
                            else
                            {
                                strInsertaGarRealXOperacion += strCedulaAcreedor + ",";
                            }

                            strInsertaGarRealXOperacion += nLiquidez.ToString() + "," + nTenencia.ToString() + ",";

                            if (dFechaPrescripcion != null)
                            {
                                strInsertaGarRealXOperacion += dFechaPrescripcion.ToShortDateString() + ",";
                            }

                            strInsertaGarRealXOperacion += nMoneda.ToString();

                            if (porcentajeAceptacion == 0)
                            {
                                strInsertaGarRealXOperacion += "0)";
                            }
                            else
                            {
                                strInsertaGarRealXOperacion += porcentajeAceptacion.ToString() + ")";
                            }

                            #endregion

                            #region Garantía Real por Operación

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.COD_OPERACION,
                                string.Empty,
                                strOperacionCrediticia);

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.COD_GARANTIA_REAL,
                                string.Empty,
                                strGarantia);

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.COD_TIPO_MITIGADOR,
                                string.Empty,
                                oTraductor.TraducirTipoMitigador(nTipoMitigador));

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.COD_TIPO_DOCUMENTO_LEGAL,
                                string.Empty,
                                oTraductor.TraducirTipoDocumento(nTipoDocumento));

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.MONTO_MITIGADOR,
                                string.Empty,
                                nMontoMitigador.ToString());

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.COD_INSCRIPCION, DBNull.Value.ToString(), nInscripcion.ToString());

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.FECHA_PRESENTACION,
                                string.Empty,
                                dFechaPresentacion.ToShortDateString());

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.PORCENTAJE_RESPONSABILIDAD,
                                string.Empty,
                                nPorcentaje.ToString());

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.COD_GRADO_GRAVAMEN,
                                string.Empty,
                                oTraductor.TraducirGradoGravamen(nGradoGravamen));

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.COD_OPERACION_ESPECIAL,
                                string.Empty,
                                oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.FECHA_CONSTITUCION, string.Empty, dFechaConstitucion.ToShortDateString());

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.FECHA_VENCIMIENTO,
                                string.Empty,
                                dFechaVencimiento.ToShortDateString());

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.COD_TIPO_ACREEDOR,
                                string.Empty,
                                oTraductor.TraducirTipoPersona(nTipoAcreedor));

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.CEDULA_ACREEDOR,
                                string.Empty,
                                strCedulaAcreedor);

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.COD_LIQUIDEZ,
                                string.Empty,
                                oTraductor.TraducirTipoLiquidez(nLiquidez));

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.COD_TENENCIA,
                                string.Empty,
                                oTraductor.TraducirTipoTenencia(nTenencia));

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.FECHA_PRESCRIPCION,
                                string.Empty,
                                dFechaPrescripcion.ToShortDateString());

                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                                ContenedorGarantias_reales_x_operacion.COD_MONEDA,
                                string.Empty,
                                oTraductor.TraducirTipoMoneda(nMoneda));

                            #endregion

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

        public void Modificar(long nOperacion, long nGarantiaReal, int nTipoGarantia, int nClaseGarantia,
                            int nTipoGarantiaReal, int nPartido, string strFinca, int nGrado, int nCedulaFiduciaria,
                            string strClaseBien, string strNumPlaca, int nTipoBien,
                            int nTipoMitigador, int nTipoDocumento, decimal nMontoMitigador, int nInscripcion,
                            DateTime dFechaPresentacion, decimal nPorcentaje, int nGradoGravamen, int nOperacionEspecial,
                            DateTime dFechaConstitucion, DateTime dFechaVencimiento, int nTipoAcreedor,
                            string strCedulaAcreedor, int nLiquidez, int nTenencia, int nMoneda,
                            DateTime dFechaPrescripcion, string strUsuario, string strIP,
                            string strOperacionCrediticia, string strGarantia, decimal porcentajeAceptacion)
        {
            try
            {
                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    SqlCommand oComando = new SqlCommand("pa_ModificarGarantiaReal", oConexion);
                    DataSet dsData = new DataSet();
                    SqlParameter oParam = new SqlParameter();

                    //Declara las propiedades del comando
                    oComando.CommandType = CommandType.StoredProcedure;

                    //Agrega los parámetros
                    oComando.Parameters.AddWithValue("@pbConsecutivo_Garantia_Real", nGarantiaReal);
                    oComando.Parameters.AddWithValue("@piTipo_Garantia", nTipoGarantia);
                    oComando.Parameters.AddWithValue("@piClase_Garantia", nClaseGarantia);
                    oComando.Parameters.AddWithValue("@piTipo_Garantia_Real", nTipoGarantiaReal);

                    if (nPartido != -1)
                        oComando.Parameters.AddWithValue("@piPartido", nPartido);

                    if (strFinca != "")
                        oComando.Parameters.AddWithValue("@psNumero_Finca", strFinca);

                    if (nGrado != -1)
                        oComando.Parameters.AddWithValue("@piGrado", nGrado);

                    if (nCedulaFiduciaria != -1)
                        oComando.Parameters.AddWithValue("@piCedula_Hipotecaria", nCedulaFiduciaria);

                    if (strClaseBien != "")
                        oComando.Parameters.AddWithValue("@psClase_Bien", strClaseBien);

                    if (strNumPlaca != "")
                        oComando.Parameters.AddWithValue("@psNumero_Placa", strNumPlaca);

                    if (nTipoBien != -1)
                        oComando.Parameters.AddWithValue("@piTipo_Bien", nTipoBien);

                    oComando.Parameters.AddWithValue("@pbConsecutivo_Operacion", nOperacion);

                    if (nTipoMitigador != -1)
                        oComando.Parameters.AddWithValue("@piTipo_Mitigador", nTipoMitigador);

                    if (nTipoDocumento != -1)
                        oComando.Parameters.AddWithValue("@piTipo_Documento_Legal", nTipoDocumento);

                    oComando.Parameters.AddWithValue("@pdMonto_Mitigador", nMontoMitigador);

                    if (nInscripcion != -1)
                        oComando.Parameters.AddWithValue("@piInscripcion", nInscripcion);

                    oComando.Parameters.AddWithValue("@pdtFecha_Presentacion", dFechaPresentacion);
                    oComando.Parameters.AddWithValue("@pdPorcentaje_Responsabilidad", nPorcentaje);
                    oComando.Parameters.AddWithValue("@piGrado_Gravamen", nGradoGravamen);

                    if (nOperacionEspecial != -1)
                        oComando.Parameters.AddWithValue("@piOperacion_Especial", nOperacionEspecial);

                    oComando.Parameters.AddWithValue("@pdtFecha_Constitucion", dFechaConstitucion);
                    oComando.Parameters.AddWithValue("@pdtFecha_Vencimiento", dFechaVencimiento);

                    if (nTipoAcreedor != -1)
                        oComando.Parameters.AddWithValue("@piTipo_Acreedor", nTipoAcreedor);

                    if (strCedulaAcreedor != "")
                        oComando.Parameters.AddWithValue("@psCedula_Acreedor", strCedulaAcreedor);

                    oComando.Parameters.AddWithValue("@piLiquidez", nLiquidez);
                    oComando.Parameters.AddWithValue("@piTenencia", nTenencia);
                    oComando.Parameters.AddWithValue("@pdtFecha_Prescripcion", dFechaPrescripcion);
                    oComando.Parameters.AddWithValue("@piMoneda", nMoneda);
                    oComando.Parameters.AddWithValue("@@psCedula_Usuario", strUsuario);
                    oComando.Parameters.AddWithValue("@pdPorcentaje_Aceptacion", porcentajeAceptacion);
 
                    #region Obtener Datos previos a actualización


                    DataSet dsGarantiaReal = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL + "," +
                        ContenedorGarantia_real.COD_PARTIDO + "," + ContenedorGarantia_real.NUMERO_FINCA + "," +
                        ContenedorGarantia_real.COD_GRADO + "," + ContenedorGarantia_real.CEDULA_HIPOTECARIA + "," +
                        ContenedorGarantia_real.COD_CLASE_BIEN + "," + ContenedorGarantia_real.NUM_PLACA_BIEN + "," +
                        ContenedorGarantia_real.COD_TIPO_BIEN +
                        " from " + ContenedorGarantia_real.NOMBRE_ENTIDAD +
                        " where " + ContenedorGarantia_real.COD_GARANTIA_REAL + " = " + nGarantiaReal.ToString());


                    DataSet dsGarantiaRealXOperacion = AccesoBD.ejecutarConsulta("select " + ContenedorGarantias_reales_x_operacion.COD_TIPO_MITIGADOR + "," +
                        ContenedorGarantias_reales_x_operacion.COD_TIPO_DOCUMENTO_LEGAL + "," + ContenedorGarantias_reales_x_operacion.MONTO_MITIGADOR + "," +
                        ContenedorGarantias_reales_x_operacion.COD_INSCRIPCION + "," + ContenedorGarantias_reales_x_operacion.FECHA_PRESENTACION + "," +
                        ContenedorGarantias_reales_x_operacion.PORCENTAJE_RESPONSABILIDAD + "," + ContenedorGarantias_reales_x_operacion.COD_GRADO_GRAVAMEN + "," +
                        ContenedorGarantias_reales_x_operacion.COD_OPERACION_ESPECIAL + "," + ContenedorGarantias_reales_x_operacion.FECHA_CONSTITUCION + "," +
                        ContenedorGarantias_reales_x_operacion.FECHA_VENCIMIENTO + "," + ContenedorGarantias_reales_x_operacion.COD_TIPO_ACREEDOR + "," +
                        ContenedorGarantias_reales_x_operacion.CEDULA_ACREEDOR + "," + ContenedorGarantias_reales_x_operacion.COD_LIQUIDEZ + "," +
                        ContenedorGarantias_reales_x_operacion.COD_TENENCIA + "," + ContenedorGarantias_reales_x_operacion.FECHA_PRESCRIPCION + "," +
                        ContenedorGarantias_reales_x_operacion.COD_MONEDA + "," +
                        "Porcentaje_Aceptacion" +
                        " from " + ContenedorGarantias_reales_x_operacion.NOMBRE_ENTIDAD +
                        " where " + ContenedorGarantias_reales_x_operacion.COD_OPERACION + " = " + nOperacion.ToString() +
                        " and " + ContenedorGarantias_reales_x_operacion.COD_GARANTIA_REAL + " = " + nGarantiaReal.ToString());

                    #endregion

                    //Abre la conexión
                    oConexion.Open();

                    //Ejecuta el comando
                    int nFilasAfectadas = oComando.ExecuteNonQuery();



                    if (nFilasAfectadas > 0)
                    {
                        #region Inserción en Bitácora

                        Bitacora oBitacora = new Bitacora();

                        TraductordeCodigos oTraductor = new TraductordeCodigos();

                        if ((dsGarantiaReal != null) && (dsGarantiaReal.Tables.Count > 0) && (dsGarantiaReal.Tables[0].Rows.Count > 0))
                        {
                            #region Armar String de Modificación de la Garantía Real

                            string strModificarGarantiaReal = "UPDATE GAR_GARANTIA_REAL SET cod_tipo_garantia_real = ";

                            if (nTipoGarantiaReal != -1)
                            {
                                strModificarGarantiaReal += nTipoGarantiaReal.ToString() + ",";
                            }

                            if (nPartido != -1)
                            {
                                strModificarGarantiaReal += "cod_partido = " + nPartido.ToString() + ",";
                            }

                            if (strFinca != string.Empty)
                            {
                                strModificarGarantiaReal += "numero_finca = " + strFinca + ",";
                            }

                            if (nGrado != -1)
                            {
                                strModificarGarantiaReal += "cod_grado = " + nGrado.ToString() + ",";
                            }

                            if (nCedulaFiduciaria != -1)
                            {
                                strModificarGarantiaReal += "cedula_hipotecaria = " + nCedulaFiduciaria.ToString() + ",";
                            }

                            if (strClaseBien != string.Empty)
                            {
                                strModificarGarantiaReal += "cod_clase_bien = " + strClaseBien + ",";
                            }

                            if (strNumPlaca != string.Empty)
                            {
                                strModificarGarantiaReal += "num_placa_bien = " + strNumPlaca + ",";
                            }

                            if (nTipoBien != -1)
                            {
                                strModificarGarantiaReal += "cod_tipo_bien = " + nTipoBien.ToString();
                            }

                            strModificarGarantiaReal += "WHERE cod_garantia_real = ";

                            if (nGarantiaReal != -1)
                            {
                                strModificarGarantiaReal += nGarantiaReal.ToString();
                            }

                            #endregion

                            #region Garantía Real

                            if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL))
                            {
                                int nCodigoTipoGarantiaRealObt = Convert.ToInt32(dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL].ToString());

                                if ((nTipoGarantiaReal != -1) && (nCodigoTipoGarantiaRealObt != nTipoGarantiaReal))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                        ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL,
                                        oTraductor.TraducirTipoGarantiaReal(nCodigoTipoGarantiaRealObt),
                                        oTraductor.TraducirTipoGarantiaReal(nTipoGarantiaReal));
                                }
                            }
                            else
                            {
                                if (nTipoGarantiaReal != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                            ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL,
                                            string.Empty,
                                            oTraductor.TraducirTipoGarantiaReal(nTipoGarantiaReal));
                                }
                            }
                            if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.COD_PARTIDO))
                            {
                                int nCodigoPartidoObt = Convert.ToInt32(dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_PARTIDO].ToString());

                                if ((nPartido != -1) && (nCodigoPartidoObt != nPartido))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                        ContenedorGarantia_real.COD_PARTIDO,
                                        nCodigoPartidoObt.ToString(),
                                        nPartido.ToString());
                                }
                            }
                            else
                            {
                                if (nPartido != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                            ContenedorGarantia_real.COD_PARTIDO,
                                            string.Empty,
                                            nPartido.ToString());
                                }
                            }

                            if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.COD_GRADO))
                            {

                                int nCodigoGradoObt = Convert.ToInt32(dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_GRADO].ToString());

                                if ((nGrado != -1) && (nCodigoGradoObt != nGrado))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                        ContenedorGarantia_real.COD_GRADO,
                                        nCodigoGradoObt.ToString(),
                                        nGrado.ToString());
                                }
                            }
                            else
                            {
                                if (nGrado != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                            ContenedorGarantia_real.COD_GRADO,
                                            string.Empty,
                                            nGrado.ToString());
                                }
                            }

                            if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.CEDULA_HIPOTECARIA))
                            {
                                int nCedulaHipotecariaObt = Convert.ToInt32(dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.CEDULA_HIPOTECARIA].ToString());

                                if ((nCedulaFiduciaria != -1) && (nCedulaHipotecariaObt != nCedulaFiduciaria))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                        ContenedorGarantia_real.CEDULA_HIPOTECARIA,
                                        nCedulaHipotecariaObt.ToString(),
                                        nCedulaFiduciaria.ToString());
                                }
                            }
                            else
                            {
                                if (nCedulaFiduciaria != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                            ContenedorGarantia_real.CEDULA_HIPOTECARIA,
                                            string.Empty,
                                            nCedulaFiduciaria.ToString());
                                }
                            }

                            if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.COD_TIPO_BIEN))
                            {
                                int nTipoBienObt = Convert.ToInt32(dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_TIPO_BIEN].ToString());

                                if ((nTipoBien != -1) && (nTipoBienObt != nTipoBien))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                        ContenedorGarantia_real.COD_TIPO_BIEN,
                                        oTraductor.TraducirTipoBien(nTipoBienObt),
                                        oTraductor.TraducirTipoBien(nTipoBien));
                                }
                            }
                            else
                            {
                                if (nTipoBien != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                            ContenedorGarantia_real.COD_TIPO_BIEN,
                                            string.Empty,
                                            oTraductor.TraducirTipoBien(nTipoBien));
                                }
                            }

                            if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.NUM_PLACA_BIEN))
                            {
                                string strNumeroPlacaObt = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.NUM_PLACA_BIEN].ToString();

                                if ((strNumPlaca != string.Empty) && (strNumeroPlacaObt.CompareTo(strNumPlaca) != 0))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                        ContenedorGarantia_real.NUM_PLACA_BIEN,
                                        strNumeroPlacaObt,
                                        strNumPlaca);
                                }
                            }
                            else
                            {
                                if (strNumPlaca != string.Empty)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                            ContenedorGarantia_real.NUM_PLACA_BIEN,
                                            string.Empty,
                                            strNumPlaca);
                                }
                            }

                            if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.COD_CLASE_BIEN))
                            {
                                string strCodigoClaseBienObt = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_CLASE_BIEN].ToString();

                                if ((strClaseBien != string.Empty) && (strCodigoClaseBienObt.CompareTo(strClaseBien) != 0))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                        ContenedorGarantia_real.COD_CLASE_BIEN,
                                        strCodigoClaseBienObt,
                                        strClaseBien);
                                }
                            }
                            else
                            {
                                if (strClaseBien != string.Empty)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                            ContenedorGarantia_real.COD_CLASE_BIEN,
                                            string.Empty,
                                            strClaseBien);
                                }
                            }

                            if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.NUMERO_FINCA))
                            {
                                string strNumeroFincaObt = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.NUMERO_FINCA].ToString();

                                if ((strFinca != string.Empty) && (strNumeroFincaObt.CompareTo(strFinca) != 0))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                        ContenedorGarantia_real.NUMERO_FINCA,
                                        strNumeroFincaObt,
                                        strFinca);
                                }
                            }
                            else
                            {
                                if (strFinca != string.Empty)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificarGarantiaReal, string.Empty,
                                            ContenedorGarantia_real.NUMERO_FINCA,
                                            string.Empty,
                                            strFinca);
                                }
                            }

                            #endregion
                        }

                        #region Inserta en Bitácora las actualizaciones de las garantías reales por operación

                        if ((dsGarantiaRealXOperacion != null) && (dsGarantiaRealXOperacion.Tables.Count > 0) && (dsGarantiaRealXOperacion.Tables[0].Rows.Count > 0))
                        {
                            #region Armado del String de Modificación de la Garantía Real por Operación

                            string strModificaGarRealXOperacion = "UPDATE GAR_GARANTIAS_REALES_X_OPERACION SET cod_tipo_mitigador = ";

                            if (nTipoMitigador != -1)
                            {
                                strModificaGarRealXOperacion += nTipoMitigador.ToString() + ",";
                            }

                            if (nTipoDocumento != -1)
                            {
                                strModificaGarRealXOperacion += "cod_tipo_documento_legal = " + nTipoMitigador.ToString() + ",";
                            }

                            strModificaGarRealXOperacion += "monto_mitigador = " + nMontoMitigador.ToString() + ",";

                            if (nInscripcion != -1)
                            {
                                strModificaGarRealXOperacion += "cod_inscripcion = " + nInscripcion.ToString() + ",";
                            }

                            strModificaGarRealXOperacion += "fecha_presentacion =" + dFechaPresentacion.ToShortDateString() + ",";
                            strModificaGarRealXOperacion += "porcentaje_responsabilidad = " + nPorcentaje.ToString() + ",";
                            strModificaGarRealXOperacion += "cod_grado_gravamen = " + nGradoGravamen.ToString() + ",";

                            if (nOperacionEspecial != -1)
                            {
                                strModificaGarRealXOperacion += "cod_operacion_especial = " + nOperacionEspecial.ToString() + ",";
                            }

                            strModificaGarRealXOperacion += "fecha_constitucion =" + dFechaConstitucion.ToShortDateString() + ",";
                            strModificaGarRealXOperacion += "fecha_vencimiento = " + dFechaVencimiento.ToShortDateString() + ",";

                            if (nTipoAcreedor != -1)
                            {
                                strModificaGarRealXOperacion += "cod_tipo_acreedor = " + nTipoAcreedor.ToString() + ",";
                            }

                            if (strCedulaAcreedor != string.Empty)
                            {
                                strModificaGarRealXOperacion += "cedula_acreedor = " + strCedulaAcreedor + ",";
                            }

                            if (nLiquidez != -1)
                            {
                                strModificaGarRealXOperacion += "cod_liquidez =  = " + nLiquidez.ToString() + ",";
                            }

                            if (nTenencia != -1)
                            {
                                strModificaGarRealXOperacion += "cod_tenencia = " + nTenencia.ToString() + ",";
                            }

                            strModificaGarRealXOperacion += "fecha_prescripcion = " + dFechaPrescripcion.ToShortDateString() + ",";

                            if (nMoneda != -1)
                            {
                                strModificaGarRealXOperacion += "cod_moneda = " + nMoneda.ToString() + ",";
                            }

                            strModificaGarRealXOperacion += "Porcentaje_Aceptacion = " + porcentajeAceptacion.ToString() ;

                            strModificaGarRealXOperacion += "WHERE cod_operacion = ";
                            strModificaGarRealXOperacion += nOperacion.ToString();
                            strModificaGarRealXOperacion += "AND cod_garantia_real = ";
                            strModificaGarRealXOperacion += nGarantiaReal.ToString();

                            #endregion

                            #region Garantía Real por Operación

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.COD_TIPO_MITIGADOR))
                            {
                                int nCodigoTipoMitigadorObt = Convert.ToInt32(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.COD_TIPO_MITIGADOR].ToString());

                                if ((nTipoMitigador != -1) && (nCodigoTipoMitigadorObt != nTipoMitigador))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.COD_TIPO_MITIGADOR,
                                        oTraductor.TraducirTipoMitigador(nCodigoTipoMitigadorObt),
                                        oTraductor.TraducirTipoMitigador(nTipoMitigador));
                                }
                            }
                            else
                            {
                                if (nTipoMitigador != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                            ContenedorGarantias_reales_x_operacion.COD_TIPO_MITIGADOR,
                                            string.Empty,
                                            oTraductor.TraducirTipoMitigador(nTipoMitigador));
                                }
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.COD_TIPO_DOCUMENTO_LEGAL))
                            {
                                int nCodigoTipoDocumentoLegalObt = Convert.ToInt32(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.COD_TIPO_DOCUMENTO_LEGAL].ToString());

                                if ((nTipoDocumento != -1) && (nCodigoTipoDocumentoLegalObt != nTipoDocumento))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.COD_TIPO_DOCUMENTO_LEGAL,
                                        oTraductor.TraducirTipoDocumento(nCodigoTipoDocumentoLegalObt),
                                        oTraductor.TraducirTipoDocumento(nTipoDocumento));
                                }
                            }
                            else
                            {
                                if (nTipoDocumento != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                            ContenedorGarantias_reales_x_operacion.COD_TIPO_DOCUMENTO_LEGAL,
                                            string.Empty,
                                            oTraductor.TraducirTipoDocumento(nTipoDocumento));
                                }
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.MONTO_MITIGADOR))
                            {
                                decimal nMontoMitigadorObt = Convert.ToDecimal(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.MONTO_MITIGADOR].ToString());

                                if (nMontoMitigadorObt != nMontoMitigador)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.MONTO_MITIGADOR,
                                        nMontoMitigadorObt.ToString(),
                                        nMontoMitigador.ToString());
                                }
                            }
                            else
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.MONTO_MITIGADOR,
                                        string.Empty,
                                        nMontoMitigador.ToString());
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.COD_INSCRIPCION))
                            {
                                int nCodigoInscripcionObt = Convert.ToInt32(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.COD_INSCRIPCION].ToString());

                                if ((nInscripcion != -1) && (nCodigoInscripcionObt != nInscripcion))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.COD_INSCRIPCION,
                                        oTraductor.TraducirTipoInscripcion(nCodigoInscripcionObt),
                                        oTraductor.TraducirTipoInscripcion(nInscripcion));
                                }
                            }
                            else
                            {
                                if (nInscripcion != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                            ContenedorGarantias_reales_x_operacion.COD_INSCRIPCION,
                                            string.Empty,
                                            oTraductor.TraducirTipoInscripcion(nInscripcion));
                                }
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.FECHA_PRESENTACION))
                            {
                                DateTime dFechaPresentacionObt = Convert.ToDateTime(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.FECHA_PRESENTACION].ToString());

                                if (dFechaPresentacionObt != dFechaPresentacion)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.FECHA_PRESENTACION,
                                        dFechaPresentacionObt.ToShortDateString(),
                                        dFechaPresentacion.ToShortDateString());
                                }
                            }
                            else
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.FECHA_PRESENTACION,
                                        string.Empty,
                                        dFechaPresentacion.ToShortDateString());
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.PORCENTAJE_RESPONSABILIDAD))
                            {
                                decimal nPorcentajeResponsabilidadObt = Convert.ToDecimal(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.PORCENTAJE_RESPONSABILIDAD].ToString());

                                if (nPorcentajeResponsabilidadObt != nPorcentaje)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.PORCENTAJE_RESPONSABILIDAD,
                                        nPorcentajeResponsabilidadObt.ToString(),
                                        nPorcentaje.ToString());
                                }
                            }
                            else
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                       2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                       ContenedorGarantias_reales_x_operacion.PORCENTAJE_RESPONSABILIDAD,
                                       string.Empty,
                                       nPorcentaje.ToString());
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.COD_GRADO_GRAVAMEN))
                            {
                                int nCodigoGradoGravamenObt = Convert.ToInt32(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.COD_GRADO_GRAVAMEN].ToString());

                                if (nCodigoGradoGravamenObt != nGradoGravamen)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.COD_GRADO_GRAVAMEN,
                                        oTraductor.TraducirGradoGravamen(nCodigoGradoGravamenObt),
                                        oTraductor.TraducirGradoGravamen(nGradoGravamen));
                                }
                            }
                            else
                            {
                                if (nGradoGravamen != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                            ContenedorGarantias_reales_x_operacion.COD_GRADO_GRAVAMEN,
                                            string.Empty,
                                            oTraductor.TraducirGradoGravamen(nGradoGravamen));
                                }
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.COD_OPERACION_ESPECIAL))
                            {
                                int nCodigoOperacionEspecialObt = Convert.ToInt32(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.COD_OPERACION_ESPECIAL].ToString());

                                if ((nOperacionEspecial != -1) && (nCodigoOperacionEspecialObt != nOperacionEspecial))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.COD_OPERACION_ESPECIAL,
                                        oTraductor.TraducirTipoOperacionEspecial(nCodigoOperacionEspecialObt),
                                        oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));
                                }
                            }
                            else
                            {
                                if (nOperacionEspecial != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                            ContenedorGarantias_reales_x_operacion.COD_OPERACION_ESPECIAL,
                                            string.Empty,
                                            oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));
                                }
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.FECHA_CONSTITUCION))
                            {
                                DateTime dFechaConstitucionObt = Convert.ToDateTime(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.FECHA_CONSTITUCION].ToString());

                                if (dFechaConstitucionObt != dFechaConstitucion)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.FECHA_CONSTITUCION,
                                        dFechaConstitucionObt.ToShortDateString(),
                                        dFechaConstitucion.ToShortDateString());
                                }
                            }
                            else
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.FECHA_CONSTITUCION,
                                        string.Empty,
                                        dFechaConstitucion.ToShortDateString());
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.FECHA_VENCIMIENTO))
                            {
                                DateTime dFechaVencimientoObt = Convert.ToDateTime(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.FECHA_VENCIMIENTO].ToString());

                                if (dFechaVencimientoObt != dFechaVencimiento)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.FECHA_VENCIMIENTO,
                                        dFechaVencimientoObt.ToShortDateString(),
                                        dFechaVencimiento.ToShortDateString());
                                }
                            }
                            else
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.FECHA_VENCIMIENTO,
                                        string.Empty,
                                        dFechaVencimiento.ToShortDateString());
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.COD_TIPO_ACREEDOR))
                            {
                                int nCodigoTipoAcreedorObt = Convert.ToInt32(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.COD_TIPO_ACREEDOR].ToString());

                                if ((nTipoAcreedor != -1) && (nCodigoTipoAcreedorObt != nTipoAcreedor))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.COD_TIPO_ACREEDOR,
                                        oTraductor.TraducirTipoPersona(nCodigoTipoAcreedorObt),
                                        oTraductor.TraducirTipoPersona(nTipoAcreedor));
                                }
                            }
                            else
                            {
                                if (nTipoAcreedor != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                            ContenedorGarantias_reales_x_operacion.COD_TIPO_ACREEDOR,
                                            string.Empty,
                                            oTraductor.TraducirTipoPersona(nTipoAcreedor));
                                }
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.CEDULA_ACREEDOR))
                            {
                                string strCedulaAcreedorObt = dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.CEDULA_ACREEDOR].ToString();

                                if ((strCedulaAcreedor != string.Empty) && (strCedulaAcreedorObt.CompareTo(strCedulaAcreedor) != 0))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.CEDULA_ACREEDOR,
                                        strCedulaAcreedorObt,
                                        strCedulaAcreedor);
                                }
                            }
                            else
                            {
                                if (strCedulaAcreedor != string.Empty)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                            ContenedorGarantias_reales_x_operacion.CEDULA_ACREEDOR,
                                            string.Empty,
                                            strCedulaAcreedor);
                                }
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.COD_LIQUIDEZ))
                            {
                                int nCodigoLiquidezObt = Convert.ToInt32(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.COD_LIQUIDEZ].ToString());

                                if ((nLiquidez != -1) && (nCodigoLiquidezObt != nLiquidez))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.COD_LIQUIDEZ,
                                        oTraductor.TraducirTipoLiquidez(nCodigoLiquidezObt),
                                        oTraductor.TraducirTipoLiquidez(nLiquidez));
                                }
                            }
                            else
                            {
                                if (nLiquidez != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                            ContenedorGarantias_reales_x_operacion.COD_LIQUIDEZ,
                                            string.Empty,
                                            oTraductor.TraducirTipoLiquidez(nLiquidez));
                                }
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.COD_TENENCIA))
                            {
                                int nCodigoTeneciaObt = Convert.ToInt32(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.COD_TENENCIA].ToString());

                                if ((nTenencia != -1) && (nCodigoTeneciaObt != nTenencia))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.COD_TENENCIA,
                                        oTraductor.TraducirTipoTenencia(nCodigoTeneciaObt),
                                        oTraductor.TraducirTipoTenencia(nTenencia));
                                }
                            }
                            else
                            {
                                if (nTenencia != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                            ContenedorGarantias_reales_x_operacion.COD_TENENCIA,
                                            string.Empty,
                                            oTraductor.TraducirTipoTenencia(nTenencia));
                                }
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.FECHA_PRESCRIPCION))
                            {
                                DateTime dFechaPrescripcionObt = Convert.ToDateTime(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.FECHA_PRESCRIPCION].ToString());

                                if (dFechaPrescripcionObt != dFechaPrescripcion)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.FECHA_PRESCRIPCION,
                                        dFechaPrescripcionObt.ToShortDateString(),
                                        dFechaPrescripcion.ToShortDateString());
                                }
                            }
                            else
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.FECHA_PRESCRIPCION,
                                        string.Empty,
                                        dFechaPrescripcion.ToShortDateString());
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull(ContenedorGarantias_reales_x_operacion.COD_MONEDA))
                            {
                                int nCodigoMonedaObt = Convert.ToInt32(dsGarantiaRealXOperacion.Tables[0].Rows[0][ContenedorGarantias_reales_x_operacion.COD_MONEDA].ToString());

                                if ((nMoneda != -1) && (nCodigoMonedaObt != nMoneda))
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        ContenedorGarantias_reales_x_operacion.COD_MONEDA,
                                        oTraductor.TraducirTipoMoneda(nCodigoMonedaObt),
                                        oTraductor.TraducirTipoMoneda(nMoneda));
                                }
                            }
                            else
                            {
                                if (nMoneda != -1)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                            2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                            ContenedorGarantias_reales_x_operacion.COD_MONEDA,
                                            string.Empty,
                                            oTraductor.TraducirTipoMoneda(nMoneda));
                                }
                            }

                            if (!dsGarantiaRealXOperacion.Tables[0].Rows[0].IsNull("Porcentaje_Aceptacion"))
                            {
                                decimal porcentajeAceptacionObt = Convert.ToDecimal(dsGarantiaRealXOperacion.Tables[0].Rows[0]["Porcentaje_Aceptacion"].ToString());

                                if (porcentajeAceptacionObt != porcentajeAceptacion)
                                {
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                        2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                        "Porcentaje_Aceptacion",
                                        porcentajeAceptacionObt.ToString(),
                                        porcentajeAceptacion.ToString());
                                }
                            }
                            else
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                       2, nTipoGarantia, strGarantia, strOperacionCrediticia, strModificaGarRealXOperacion, string.Empty,
                                       "Porcentaje_Aceptacion",
                                       string.Empty,
                                       porcentajeAceptacion.ToString());
                            }

                            #endregion
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

        //AGREGAR PARAMETRO DE USUARIO EN EL SP
        //AGREGAR TAMBIEN LAS OTRAS TABLAS 

        public void Modificar(clsGarantiaReal datosGarantiaReal, string strUsuario, string strIP,
                              string strOperacionCrediticia, string strGarantia)
        {
            #region Ejemplo Trama Retornada

            //<DATOS>
            //    <MODIFICADOS>
            //        <GAROPER>
            //            <cod_operacion>136148</cod_operacion>
            //            <cod_garantia_real>13</cod_garantia_real>
            //            <cod_tipo_mitigador>2</cod_tipo_mitigador>
            //        </GAROPER>
            //    </MODIFICADOS>
            //    <PISTA_AUDITORIA>
            //        <BITACORA des_tabla="GAR_GARANTIA_REAL" cod_usuario="401640970" cod_ip="127.0.0.1" cod_oficina="NULL" cod_operacion="2" fecha_hora="20120814" cod_consulta="UPDATE GAR_GARANTIAS_REALES_X_OPERACION SET cod_tipo_mitigador=2" cod_tipo_garantia="2" cod_garantia="Partido: 1 - Finca: 355885" cod_operacion_crediticia="1-932-1-2-5895052" cod_consulta2="NULL" des_campo_afectado="cod_tipo_mitigador" est_anterior_campo_afectado="Hipotecas sobre residencias habitadas por el deudor (ponderacin del 50%)" est_actual_campo_afectado="2-Hipotecas sobre edificaciones" />
            //    </PISTA_AUDITORIA>
            //</DATOS>

            //<?xml version="1.0" encoding="utf-8"?><DATOS><MODIFICADOS><GAROPER><cod_operacion>136148</cod_operacion><cod_garantia_real>13</cod_garantia_real><cod_tipo_mitigador>2</cod_tipo_mitigador></GAROPER></MODIFICADOS><PISTA_AUDITORIA><BITACORA des_tabla="GAR_GARANTIA_REAL" cod_usuario="401640970" cod_ip="127.0.0.1" cod_oficina="NULL" cod_operacion="2" fecha_hora="20120814" cod_consulta="UPDATE GAR_GARANTIAS_REALES_X_OPERACION SET cod_tipo_mitigador=2" cod_tipo_garantia="2" cod_garantia="Partido: 1 - Finca: 355885" cod_operacion_crediticia="1-932-1-2-5895052" cod_consulta2="NULL" des_campo_afectado="cod_tipo_mitigador" est_anterior_campo_afectado="Hipotecas sobre residencias habitadas por el deudor (ponderacin del 50%)" est_actual_campo_afectado="2-Hipotecas sobre edificaciones" /></PISTA_AUDITORIA></DATOS>

            #endregion Ejemplo Trama Retornada

            string trama = datosGarantiaReal.ObtenerTramaDatosModificados(strUsuario, strIP);
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (trama.Length > 0)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psTrama", SqlDbType.NText),
                        new SqlParameter("piCodigo_Garantia_Real", SqlDbType.BigInt),
                        new SqlParameter("piCodigo_Operacion", SqlDbType.BigInt),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar,30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = trama;
                    parameters[1].Value = datosGarantiaReal.CodGarantiaReal;
                    parameters[2].Value = datosGarantiaReal.CodOperacion;
                    parameters[3].Value = strUsuario;
                    parameters[4].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "pa_ModificarGarantiaRealXML", parameters);

                        respuestaObtenida = parameters[4].Value.ToString();
                    }

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {
                            if (procesoNormalizacion)
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA_DETALLE, strGarantia, strMensajeObtenido[1], Mensajes.ASSEMBLY));
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA, strGarantia, Mensajes.ASSEMBLY));
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (procesoNormalizacion)
                    {
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA_DETALLE, strGarantia, strMensajeObtenido[1], Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA_DETALLE, strGarantia, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA, strGarantia, Mensajes.ASSEMBLY));
                    }
                }
            }
        }

        public void Eliminar(long nOperacion, long nGarantia, string strUsuario, string strIP,
                             string strOperacionCrediticia, string strGarantia)
        {
            try
            {
                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    SqlCommand oComando = new SqlCommand("pa_EliminarGarantiaReal", oConexion);
                    DataSet dsData = new DataSet();
                    SqlParameter oParam = new SqlParameter();

                    //Se obtienen los datos antes de ser borrados, con el fin de poderlos insertar en la bitácora
                    #region Obtener Datos previos a actualización

                    DataSet dsGarantiaReal = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_real.CEDULA_HIPOTECARIA + "," +
                        ContenedorGarantia_real.COD_CLASE_BIEN + "," + ContenedorGarantia_real.COD_CLASE_GARANTIA + "," +
                        ContenedorGarantia_real.COD_GARANTIA_REAL + "," + ContenedorGarantia_real.COD_GRADO + "," +
                        ContenedorGarantia_real.COD_PARTIDO + "," + ContenedorGarantia_real.COD_TIPO_BIEN + "," +
                        ContenedorGarantia_real.COD_TIPO_GARANTIA + "," + ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL + "," +
                        ContenedorGarantia_real.NUM_PLACA_BIEN + "," + ContenedorGarantia_real.NUMERO_FINCA +
                        " from " + ContenedorGarantia_real.NOMBRE_ENTIDAD +
                        " where " + ContenedorGarantia_real.COD_GARANTIA_REAL + " = " + nGarantia.ToString());


                    DataSet dsGarantiaRealXOperacion = AccesoBD.ejecutarConsulta("select " + ContenedorGarantias_reales_x_operacion.CEDULA_ACREEDOR + "," +
                        ContenedorGarantias_reales_x_operacion.COD_ESTADO + "," + ContenedorGarantias_reales_x_operacion.COD_GARANTIA_REAL + "," +
                        ContenedorGarantias_reales_x_operacion.COD_GRADO_GRAVAMEN + "," + ContenedorGarantias_reales_x_operacion.COD_INSCRIPCION + "," +
                        ContenedorGarantias_reales_x_operacion.COD_LIQUIDEZ + "," + ContenedorGarantias_reales_x_operacion.COD_MONEDA + "," +
                        ContenedorGarantias_reales_x_operacion.COD_OPERACION + "," + ContenedorGarantias_reales_x_operacion.COD_OPERACION_ESPECIAL + "," +
                        ContenedorGarantias_reales_x_operacion.COD_TENENCIA + "," + ContenedorGarantias_reales_x_operacion.COD_TIPO_ACREEDOR + "," +
                        ContenedorGarantias_reales_x_operacion.COD_TIPO_DOCUMENTO_LEGAL + "," + ContenedorGarantias_reales_x_operacion.COD_TIPO_MITIGADOR + "," +
                        ContenedorGarantias_reales_x_operacion.FECHA_CONSTITUCION + "," + ContenedorGarantias_reales_x_operacion.FECHA_PRESCRIPCION + "," +
                        ContenedorGarantias_reales_x_operacion.FECHA_PRESENTACION + "," + ContenedorGarantias_reales_x_operacion.FECHA_VENCIMIENTO + "," +
                        ContenedorGarantias_reales_x_operacion.MONTO_MITIGADOR + "," + ContenedorGarantias_reales_x_operacion.PORCENTAJE_RESPONSABILIDAD +
                        " from " + ContenedorGarantias_reales_x_operacion.NOMBRE_ENTIDAD +
                        " where " + ContenedorGarantias_reales_x_operacion.COD_OPERACION + " = " + nOperacion.ToString() +
                        " and " + ContenedorGarantias_reales_x_operacion.COD_GARANTIA_REAL + " = " + nGarantia.ToString());

                    DataSet dsValuacionesReales = AccesoBD.ejecutarConsulta("select " + ContenedorValuaciones_reales.CEDULA_EMPRESA + "," +
                        ContenedorValuaciones_reales.CEDULA_PERITO + "," + ContenedorValuaciones_reales.COD_GARANTIA_REAL + "," +
                        ContenedorValuaciones_reales.COD_INSPECCION_MENOR_TRES_MESES + "," + ContenedorValuaciones_reales.COD_RECOMENDACION_PERITO + "," +
                        ContenedorValuaciones_reales.FECHA_CONSTRUCCION + "," + ContenedorValuaciones_reales.FECHA_ULTIMO_SEGUIMIENTO + "," +
                        ContenedorValuaciones_reales.FECHA_VALUACION + "," + ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_NO_TERRENO + "," +
                        ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_TERRENO + "," + ContenedorValuaciones_reales.MONTO_TOTAL_AVALUO + "," +
                        ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_NO_TERRENO + "," + ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_TERRENO +
                        " from " + ContenedorValuaciones_reales.NOMBRE_ENTIDAD +
                        " where " + ContenedorValuaciones_reales.COD_GARANTIA_REAL + " = " + nGarantia.ToString());

                    #endregion

                    //Declara las propiedades del comando
                    oComando.CommandType = CommandType.StoredProcedure;

                    //Agrega los parámetros
                    oComando.Parameters.AddWithValue("@nGarantiaReal", nGarantia);
                    oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
                    oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
                    oComando.Parameters.AddWithValue("@strIP", strIP);
                    //oComando.Parameters.AddWithValue("@nOficina",nOficina);	

                    //Abre la conexión
                    oConexion.Open();

                    //Ejecuta el comando
                    int nFilasAfectadas = oComando.ExecuteNonQuery();


                    if (nFilasAfectadas > 0)
                    {
                        #region Inserción en Bitácora

                        Bitacora oBitacora = new Bitacora();

                        TraductordeCodigos oTraductor = new TraductordeCodigos();

                        string strElimimarGarRealXOperacion = "DELETE GAR_GARANTIAS_REALES_X_OPERACION WHERE cod_operacion = " +
                            nOperacion.ToString() + " AND cod_garantia_real = " + nGarantia.ToString();

                        if ((dsGarantiaRealXOperacion != null) && (dsGarantiaRealXOperacion.Tables.Count > 0) && (dsGarantiaRealXOperacion.Tables[0].Rows.Count > 0))
                        {
                            #region Garantía Real por Operación

                            foreach (DataRow drGarRealXOP in dsGarantiaRealXOperacion.Tables[0].Rows)
                            {
                                for (int nIndice = 0; nIndice < drGarRealXOP.Table.Columns.Count; nIndice++)
                                {
                                    switch (drGarRealXOP.Table.Columns[nIndice].ColumnName)
                                    {
                                        case ContenedorGarantias_reales_x_operacion.COD_ESTADO:
                                            if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                       drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                       oTraductor.TraducirTipoEstado(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                       string.Empty);
                                            }
                                            else
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                       drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                            }
                                            break;

                                        case ContenedorGarantias_reales_x_operacion.COD_GARANTIA_REAL: oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                                                                       3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                                                                       drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                                                                       strGarantia,
                                                                                                       string.Empty);
                                            break;

                                        case ContenedorGarantias_reales_x_operacion.COD_GRADO_GRAVAMEN:
                                            if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                      3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                      drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                      oTraductor.TraducirGradoGravamen(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                      string.Empty);
                                            }
                                            else
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                      3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                      drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                      string.Empty,
                                                      string.Empty);
                                            }
                                            break;

                                        case ContenedorGarantias_reales_x_operacion.COD_INSCRIPCION:
                                            if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                          3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                          drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                          oTraductor.TraducirTipoInscripcion(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                          string.Empty);
                                            }
                                            else
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                          3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                          drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                          string.Empty,
                                                          string.Empty);
                                            }
                                            break;

                                        case ContenedorGarantias_reales_x_operacion.COD_LIQUIDEZ:
                                            if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                        3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                        drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                        oTraductor.TraducirTipoLiquidez(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                        string.Empty);
                                            }
                                            else
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                       drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                            }
                                            break;

                                        case ContenedorGarantias_reales_x_operacion.COD_MONEDA:
                                            if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                          3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                          drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                          oTraductor.TraducirTipoMoneda(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                          string.Empty);
                                            }
                                            else
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                          3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                          drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                          string.Empty,
                                                          string.Empty);
                                            }
                                            break;

                                        case ContenedorGarantias_reales_x_operacion.COD_OPERACION: oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                                                                       3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                                                                       drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                                                                       strOperacionCrediticia,
                                                                                                       string.Empty);
                                            break;

                                        case ContenedorGarantias_reales_x_operacion.COD_OPERACION_ESPECIAL:
                                            if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                           3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                           drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                           oTraductor.TraducirTipoOperacionEspecial(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                           string.Empty);
                                            }
                                            else
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                           3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                           drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                           string.Empty,
                                                           string.Empty);
                                            }
                                            break;

                                        case ContenedorGarantias_reales_x_operacion.COD_TENENCIA:
                                            if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                              drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                              oTraductor.TraducirTipoTenencia(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                              string.Empty);
                                            }
                                            else
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                              drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                              string.Empty,
                                                              string.Empty);
                                            }
                                            break;

                                        case ContenedorGarantias_reales_x_operacion.COD_TIPO_ACREEDOR:
                                            if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                                   oTraductor.TraducirTipoPersona(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                                   string.Empty);
                                            }
                                            else
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                                   string.Empty,
                                                                   string.Empty);
                                            }
                                            break;

                                        case ContenedorGarantias_reales_x_operacion.COD_TIPO_DOCUMENTO_LEGAL:
                                            if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                       drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                       oTraductor.TraducirTipoDocumento(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                       string.Empty);
                                            }
                                            else
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                       drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                            }
                                            break;

                                        case ContenedorGarantias_reales_x_operacion.COD_TIPO_MITIGADOR:
                                            if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                           3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                           drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                           oTraductor.TraducirTipoMitigador(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                           string.Empty);
                                            }
                                            else
                                            {
                                                oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                           3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                           drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                           string.Empty,
                                                           string.Empty);
                                            }

                                            break;

                                        default: oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                  3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                  drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                  drGarRealXOP[nIndice, DataRowVersion.Current].ToString(),
                                                  string.Empty);
                                            break;
                                    }


                                }
                            }

                            #endregion
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                string.Empty,
                                string.Empty,
                                string.Empty);
                        }

                        #region Volver a obtener los datos referentes a la garantía real por operación

                        dsGarantiaRealXOperacion = AccesoBD.ejecutarConsulta("select " + ContenedorGarantias_reales_x_operacion.CEDULA_ACREEDOR + "," +
                            ContenedorGarantias_reales_x_operacion.COD_ESTADO + "," + ContenedorGarantias_reales_x_operacion.COD_GARANTIA_REAL + "," +
                            ContenedorGarantias_reales_x_operacion.COD_GRADO_GRAVAMEN + "," + ContenedorGarantias_reales_x_operacion.COD_INSCRIPCION + "," +
                            ContenedorGarantias_reales_x_operacion.COD_LIQUIDEZ + "," + ContenedorGarantias_reales_x_operacion.COD_MONEDA + "," +
                            ContenedorGarantias_reales_x_operacion.COD_OPERACION + "," + ContenedorGarantias_reales_x_operacion.COD_OPERACION_ESPECIAL + "," +
                            ContenedorGarantias_reales_x_operacion.COD_TENENCIA + "," + ContenedorGarantias_reales_x_operacion.COD_TIPO_ACREEDOR + "," +
                            ContenedorGarantias_reales_x_operacion.COD_TIPO_DOCUMENTO_LEGAL + "," + ContenedorGarantias_reales_x_operacion.COD_TIPO_MITIGADOR + "," +
                            ContenedorGarantias_reales_x_operacion.FECHA_CONSTITUCION + "," + ContenedorGarantias_reales_x_operacion.FECHA_PRESCRIPCION + "," +
                            ContenedorGarantias_reales_x_operacion.FECHA_PRESENTACION + "," + ContenedorGarantias_reales_x_operacion.FECHA_VENCIMIENTO + "," +
                            ContenedorGarantias_reales_x_operacion.MONTO_MITIGADOR + "," + ContenedorGarantias_reales_x_operacion.PORCENTAJE_RESPONSABILIDAD +
                            " from " + ContenedorGarantias_reales_x_operacion.NOMBRE_ENTIDAD +
                            " where " + ContenedorGarantias_reales_x_operacion.COD_OPERACION + " = " + nOperacion.ToString() +
                            " and " + ContenedorGarantias_reales_x_operacion.COD_GARANTIA_REAL + " = " + nGarantia.ToString());

                        #endregion

                        //Si la garantía real por operación ha sido borrada se procede a borrar la garantía real en las tablas 
                        //GAR_VALUACIONES_REALES y GAR_GARANTIA_REAL.
                        if ((dsGarantiaRealXOperacion == null) || (dsGarantiaRealXOperacion.Tables.Count == 0) || (dsGarantiaRealXOperacion.Tables[0].Rows.Count == 0))
                        {
                            string strEliminarValuacionReal = "DELETE GAR_VALUACIONES_REALES WHERE cod_garantia_real = " + nGarantia.ToString();

                            string strEliminarGarantiaReal = "DELETE GAR_GARANTIA_REAL WHERE cod_garantia_real = " + nGarantia.ToString();

                            if ((dsValuacionesReales != null) && (dsValuacionesReales.Tables.Count > 0) && (dsValuacionesReales.Tables[0].Rows.Count > 0))
                            {
                                #region Garantía Valuación Real

                                foreach (DataRow drValReal in dsValuacionesReales.Tables[0].Rows)
                                {
                                    for (int nIndice = 0; nIndice < drValReal.Table.Columns.Count; nIndice++)
                                    {
                                        switch (drValReal.Table.Columns[nIndice].ColumnName)
                                        {

                                            case ContenedorValuaciones_reales.COD_GARANTIA_REAL: oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                                                                           3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                                                                           drValReal.Table.Columns[nIndice].ColumnName,
                                                                                                           strGarantia,
                                                                                                           string.Empty);
                                                break;

                                            case ContenedorValuaciones_reales.COD_INSPECCION_MENOR_TRES_MESES:
                                                if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                                {
                                                    oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                              3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                              drValReal.Table.Columns[nIndice].ColumnName,
                                                              oTraductor.TraducirTipoInspeccion3Meses(Convert.ToInt32(drValReal[nIndice, DataRowVersion.Current].ToString())),
                                                              string.Empty);
                                                }
                                                else
                                                {
                                                    oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                              3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                              drValReal.Table.Columns[nIndice].ColumnName,
                                                              string.Empty,
                                                              string.Empty);
                                                }
                                                break;

                                            case ContenedorValuaciones_reales.COD_RECOMENDACION_PERITO:
                                                if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                                {
                                                    oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                                 3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                                 drValReal.Table.Columns[nIndice].ColumnName,
                                                                 oTraductor.TraducirTipoRecomendacionPerito(Convert.ToInt32(drValReal[nIndice, DataRowVersion.Current].ToString())),
                                                                 string.Empty);
                                                }
                                                else
                                                {
                                                    oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                                 3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                                 drValReal.Table.Columns[nIndice].ColumnName,
                                                                 string.Empty,
                                                                 string.Empty);
                                                }
                                                break;



                                            default: oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                      3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                      drValReal.Table.Columns[nIndice].ColumnName,
                                                      drValReal[nIndice, DataRowVersion.Current].ToString(),
                                                      string.Empty);
                                                break;
                                        }


                                    }
                                }

                                #endregion
                            }
                            else
                            {
                                oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                    3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                    string.Empty,
                                    string.Empty,
                                    string.Empty);
                            }

                            if ((dsGarantiaReal != null) && (dsGarantiaReal.Tables.Count > 0) && (dsGarantiaReal.Tables[0].Rows.Count > 0))
                            {
                                #region Garantía Real

                                foreach (DataRow drGarReal in dsGarantiaReal.Tables[0].Rows)
                                {
                                    for (int nIndice = 0; nIndice < drGarReal.Table.Columns.Count; nIndice++)
                                    {
                                        switch (drGarReal.Table.Columns[nIndice].ColumnName)
                                        {

                                            case ContenedorGarantia_real.COD_CLASE_GARANTIA:
                                                if (drGarReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                                {
                                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                          3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                          drGarReal.Table.Columns[nIndice].ColumnName,
                                                          oTraductor.TraducirClaseGarantia(Convert.ToInt32(drGarReal[nIndice, DataRowVersion.Current].ToString())),
                                                          string.Empty);
                                                }
                                                else
                                                {
                                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                          3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                          drGarReal.Table.Columns[nIndice].ColumnName,
                                                          string.Empty,
                                                          string.Empty);
                                                }
                                                break;

                                            case ContenedorGarantia_real.COD_GARANTIA_REAL:
                                                oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                          3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                          drGarReal.Table.Columns[nIndice].ColumnName,
                                                          strGarantia,
                                                          string.Empty);
                                                break;

                                            case ContenedorGarantia_real.COD_TIPO_BIEN:
                                                if (drGarReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                                {
                                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                               3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                               drGarReal.Table.Columns[nIndice].ColumnName,
                                                               oTraductor.TraducirTipoBien(Convert.ToInt32(drGarReal[nIndice, DataRowVersion.Current].ToString())),
                                                               string.Empty);
                                                }
                                                else
                                                {
                                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                               3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                               drGarReal.Table.Columns[nIndice].ColumnName,
                                                               string.Empty,
                                                               string.Empty);
                                                }
                                                break;

                                            case ContenedorGarantia_real.COD_TIPO_GARANTIA:
                                                if (drGarReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                                {
                                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                             3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                             drGarReal.Table.Columns[nIndice].ColumnName,
                                                             oTraductor.TraducirTipoGarantia(Convert.ToInt32(drGarReal[nIndice, DataRowVersion.Current].ToString())),
                                                             string.Empty);
                                                }
                                                else
                                                {
                                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                             3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                             drGarReal.Table.Columns[nIndice].ColumnName,
                                                             string.Empty,
                                                             string.Empty);
                                                }
                                                break;


                                            case ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL:
                                                if (drGarReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                                {
                                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                            3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                            drGarReal.Table.Columns[nIndice].ColumnName,
                                                            oTraductor.TraducirTipoGarantiaReal(Convert.ToInt32(drGarReal[nIndice, DataRowVersion.Current].ToString())),
                                                            string.Empty);
                                                }
                                                else
                                                {
                                                    oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                            3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                            drGarReal.Table.Columns[nIndice].ColumnName,
                                                            string.Empty,
                                                            string.Empty);
                                                }
                                                break;


                                            default: oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                      3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                      drGarReal.Table.Columns[nIndice].ColumnName,
                                                      drGarReal[nIndice, DataRowVersion.Current].ToString(),
                                                      string.Empty);
                                                break;
                                        }
                                    }
                                }

                                #endregion
                            }
                            else
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                    3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                    string.Empty,
                                    string.Empty,
                                    string.Empty);
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

        /// <summary>
        /// Permite obtener la información de una garantía especfica, así como las posibles inconsistencias que posea.
        /// </summary>
        /// <param name="idOperacion">Consecutivo de la operación de la cual se obtendrá la garantía</param>
        /// <param name="idGarantia">Consecutivo de la garantía de la cual se requiere la información</param>
        /// <param name="desOperacion">Número de operación, bajo el formato Contabilidad - Oficina - Moneda - Producto - Núm. Operación / Núm. Contrato</param>
        /// <param name="desGarantia">Número de garantía, bajo el formato Partido - Finca / Clase - Placa</param>
        /// <param name="identificacionUsuario">Identificación del usuario que realiza la consulta</param>
        /// <returns>Entidad del tipo clsGarantiaReal, con los datos de la garanta consultada</returns>
        public clsGarantiaReal ObtenerDatosGarantiaReal(long idOperacion, long idGarantia, string desOperacion, string desGarantia,
                                                        string identificacionUsuario, int annosCalculoPrescripcion)
        {
            clsGarantiaReal entidadGarantiaReal = new clsGarantiaReal();
            string tramaGarantiaReal = string.Empty;

            //Se realiza la consulta a la base de datos
            if ((idOperacion > 0) && (idGarantia > 0))
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piOperacion", SqlDbType.BigInt),
                        new SqlParameter("piGarantia", SqlDbType.BigInt),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = idOperacion;
                    parameters[1].Value = idGarantia;
                    parameters[2].Value = identificacionUsuario;
                    parameters[3].Value = null;
                    parameters[3].Direction = ParameterDirection.Output;


                    SqlParameter[] parametrosSalida = new SqlParameter[] { };

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        tramaGarantiaReal = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Consultar_Garantia_Real", out parametrosSalida, parameters);
                    }
                }
                catch (Exception ex)
                {
                    entidadGarantiaReal.ErrorDatos = true;
                    entidadGarantiaReal.DescripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, desGarantia, desOperacion, Mensajes.ASSEMBLY);

                    StringCollection parametros = new StringCollection();
                    parametros.Add(desGarantia);
                    parametros.Add(desOperacion);
                    parametros.Add(("El error se da al obtener la información de la base de datos: " + ex.Message));

                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS_DETALLE, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    tramaGarantiaReal = string.Empty;
                }
            }

            if (tramaGarantiaReal.Length > 0)
            {
                entidadGarantiaReal = new clsGarantiaReal(tramaGarantiaReal, desOperacion);
            }

            return entidadGarantiaReal;
        }

        /// <summary>
        /// Obtiene la lista de catálogos del mantenimiento de garantías reales
        /// </summary>
        /// <param name="listaCatalogosGarantiaReales">Lista de los catálogos que se deben obtener. La lista debe iniciar y finalizar con el 
        ///                                            caracter "|", así mismo, los valores deben ir separados por dicho caracter.
        /// </param>
        /// <returns>Enditad del tipo catálogos</returns>
        public clsCatalogos<clsCatalogo> ObtenerCatalogos(string listaCatalogosGarantiaReales)
        {
            clsCatalogos<clsCatalogo> entidadCatalogos = null;

            string tramaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (listaCatalogosGarantiaReales.Length > 0)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psListaCatalogos", SqlDbType.VarChar, 150),
                    };

                    parameters[0].Value = listaCatalogosGarantiaReales;

                    SqlParameter[] parametrosSalida = new SqlParameter[] { };

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        tramaObtenida = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "pa_ObtenerCatalogos", out parametrosSalida, parameters);
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
        /// Obtiene la lista de valuadores del mantenimiento de garantías reales
        /// </summary>
        /// <param name="tipoValuador">Tipo de valuador del cual se obtendrán lo datos</param>
        /// <returns>Enditad del tipo valuadores</returns>
        public clsValuadores<clsValuador> ObtenerValuadores(Enumeradores.TiposValuadores tipoValuador)
        {
            clsValuadores<clsValuador> entidadValuadores = null;

            string tramaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            int indicadorTipoValuador = -1;

            string descripcionTipoValuador = "los valuadores";

            switch (tipoValuador)
            {
                case Enumeradores.TiposValuadores.Perito: indicadorTipoValuador = 1; descripcionTipoValuador = "los peritos";
                    break;
                case Enumeradores.TiposValuadores.Empresa: indicadorTipoValuador = 0; descripcionTipoValuador = "las empresas valuadoras";
                    break;
                default:
                    break;
            }

            if (indicadorTipoValuador != -1)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piTipoValuador", SqlDbType.TinyInt),
                        new SqlParameter("piDatosCompletos", SqlDbType.Bit),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = indicadorTipoValuador;
                    parameters[1].Value = 0; //Indica que se obtenedrá la lista de valuadores, bajo el formato cédula - nombre completo
                    parameters[2].Direction = ParameterDirection.Output;

                    SqlParameter[] parametrosSalida = new SqlParameter[] { };

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        tramaObtenida = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Obtener_Valuadores", out parametrosSalida, parameters);
                    }
                }
                catch (Exception ex)
                {
                    entidadValuadores = new clsValuadores<clsValuador>();

                    entidadValuadores.ErrorDatos = true;
                    entidadValuadores.DescripcionError = Mensajes.Obtener(Mensajes._errorCargaListaValuadores, descripcionTipoValuador, Mensajes.ASSEMBLY);

                    string desError = "El error se da al cargar los datos del valuador: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaListaValuadoresDetalle, descripcionTipoValuador, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    tramaObtenida = string.Empty;
                }
            }

            if (tramaObtenida.Length > 0)
            {
                entidadValuadores = new clsValuadores<clsValuador>(tramaObtenida, tipoValuador);
            }

            return entidadValuadores;
        }

        /// <summary>
        /// Se encarga de ejecuta el proceso de normalización de algunos datos de la garantía a todos aquellos registros que sean de la misma finca o prenda.
        /// Siebel 1-24206841. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 24/03/2014.
        /// </summary>
        /// <param name="datosGarantiaReal">Contenedor de la información del a garantía y del avalúo</param>
        /// <param name="strUsuario">Usuario que realiza la acción</param>
        /// <param name="strIP">IP de la máquina desde donde se realzia el ajuste</param>
        /// <param name="strOperacionCrediticia">Código de la operación, bajo el formato oficina-moneda-producto-operación/contrato</param>
        /// <param name="strGarantia">Código del bien, bajo el formato Partido/Clase de bien – Finca/Placa)</param>
        public void NormalizarDatosGarantiaReal(clsGarantiaReal datosGarantiaReal, string strUsuario, string strIP,
                              string strOperacionCrediticia, string strGarantia)
        {
            #region Ejemplo Trama Retornada

            //<RESPUESTA>
            //    <CODIGO>0</CODIGO>
            //    <NIVEL></NIVEL>
            //    <ESTADO></ESTADO>
            //    <PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>
            //    <LINEA></LINEA>
            //    <MENSAJE>La replicación de avalúos ha sido satisfactoria.</MENSAJE>
            //    <DETALLE></DETALLE>
            //</RESPUESTA>
            #endregion Ejemplo Trama Retornada

            string respuestaObtenida = string.Empty;
            string detalleError = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };
            StringBuilder sbOperacionesSinNormalizar = new StringBuilder();
            bool errorReplica = false;
            clsGarantiaReal entidadGarantiaReal = new clsGarantiaReal();
            string tramaGarantiaReal = string.Empty;
            clsGarantiaReal garantiaRealNormalizar = null;

            if (datosGarantiaReal != null)
            {
                foreach (clsOperacionCrediticia GarOperActualizar in datosGarantiaReal.OperacionesRelacionadas)
                {
                    try
                    {
                        int annosCalculoPrescripcion = (datosGarantiaReal.FechaPrescripcion.Year - datosGarantiaReal.FechaVencimiento.Year);
                        garantiaRealNormalizar = ObtenerDatosGarantiaReal(GarOperActualizar.CodigoOperacion, GarOperActualizar.CodigoGarantia, GarOperActualizar.ToString(false), strGarantia, strUsuario, annosCalculoPrescripcion);
                    }
                    catch (Exception ex)
                    {
                        errorReplica = true;

                        detalleError = "Operación: " + GarOperActualizar.ToString(true) + ex.Message;

                        if (!sbOperacionesSinNormalizar.ToString().Contains(GarOperActualizar.ToString(true)))
                        {
                            sbOperacionesSinNormalizar.Append(GarOperActualizar.ToString(true));
                        }

                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorNormalizandoAvaluoDetalle, strGarantia, detalleError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    }

                    //Se revisa que la entidad haya sido creada
                    if (garantiaRealNormalizar != null)
                    {
                        //Se procede a modificar la información de la garantía y la relación de esta con la operación/contrato
                        garantiaRealNormalizar.CodTipoBien = datosGarantiaReal.CodTipoBien;
                        garantiaRealNormalizar.CodTipoMitigador = datosGarantiaReal.CodTipoMitigador;
                        garantiaRealNormalizar.ListaDescripcionValoresActualesCombos = datosGarantiaReal.ListaDescripcionValoresActualesCombos;

                        //Se procede a modificar la información del avalúo de la garantía
                        garantiaRealNormalizar.FechaValuacion = datosGarantiaReal.FechaValuacion;
                        garantiaRealNormalizar.FechaUltimoSeguimiento = datosGarantiaReal.FechaUltimoSeguimiento;
                        garantiaRealNormalizar.FechaConstruccion = datosGarantiaReal.FechaConstruccion;
                        garantiaRealNormalizar.MontoUltimaTasacionTerreno = datosGarantiaReal.MontoUltimaTasacionTerreno;
                        garantiaRealNormalizar.MontoUltimaTasacionNoTerreno = datosGarantiaReal.MontoUltimaTasacionNoTerreno;
                        garantiaRealNormalizar.MontoTasacionActualizadaTerreno = datosGarantiaReal.MontoTasacionActualizadaTerreno;
                        garantiaRealNormalizar.MontoTasacionActualizadaNoTerreno = datosGarantiaReal.MontoTasacionActualizadaNoTerreno;
                        garantiaRealNormalizar.MontoTotalAvaluo = datosGarantiaReal.MontoTotalAvaluo;
                        garantiaRealNormalizar.CedulaPerito = datosGarantiaReal.CedulaPerito;
                        garantiaRealNormalizar.CedulaEmpresa = datosGarantiaReal.CedulaEmpresa;
                        garantiaRealNormalizar.AvaluoActualizado = datosGarantiaReal.AvaluoActualizado;
                        garantiaRealNormalizar.FechaSemestreCalculado = datosGarantiaReal.FechaSemestreCalculado;

                        //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
                        garantiaRealNormalizar.PorcentajeAceptacionTerreno = datosGarantiaReal.PorcentajeAceptacionTerreno;
                        garantiaRealNormalizar.PorcentajeAceptacionNoTerreno = datosGarantiaReal.PorcentajeAceptacionNoTerreno;
                        garantiaRealNormalizar.PorcentajeAceptacionTerrenoCalculado = datosGarantiaReal.PorcentajeAceptacionTerrenoCalculado;
                        garantiaRealNormalizar.PorcentajeAceptacionNoTerrenoCalculado = datosGarantiaReal.PorcentajeAceptacionNoTerrenoCalculado;

                        //Se procede a modificar la información de la póliza, sólo si dicha póliza está asociada a la operación replicada
                        List<clsPolizaSap> listaPolizas = garantiaRealNormalizar.PolizasSap.ObtenerPolizasPorTipoBien(garantiaRealNormalizar.CodTipoBien);

                        if ((listaPolizas != null) && (listaPolizas.Count > 0))
                        {
                            foreach (clsPolizaSap polizaSap in listaPolizas)
                            {
                                if (datosGarantiaReal.PolizaSapAsociada != null)
                                {
                                    if (polizaSap.CodigoPolizaSap == datosGarantiaReal.PolizaSapAsociada.CodigoPolizaSap)
                                    {
                                        garantiaRealNormalizar.PolizaSapAsociada = datosGarantiaReal.PolizaSapAsociada;
                                        break;
                                    }
                                }
                            }
                        }

                        //Se utilizan los mismos datos las pistas de auditoria 
                        garantiaRealNormalizar.UsuarioModifico = datosGarantiaReal.UsuarioModifico;
                        garantiaRealNormalizar.FechaModifico = datosGarantiaReal.FechaModifico;
                        garantiaRealNormalizar.FechaInserto = datosGarantiaReal.FechaInserto;

                        //Se procede a modificar la operación respaldada por la garantía
                        procesoNormalizacion = true;

                        try
                        {
                            Modificar(garantiaRealNormalizar, strUsuario, strIP, strOperacionCrediticia, strGarantia);
                        }
                        catch (Exception ex)
                        {
                            errorReplica = true;

                            detalleError = "Operación: " + GarOperActualizar.ToString(true) + ex.Message;

                            if (!sbOperacionesSinNormalizar.ToString().Contains(GarOperActualizar.ToString(true)))
                            {
                                sbOperacionesSinNormalizar.Append(GarOperActualizar.ToString(true));
                            }

                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorNormalizandoAvaluoDetalle, strGarantia, detalleError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                        }
                    }
                    //}
                }

                if (errorReplica)
                {
                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorNormalizandoAvaluo, sbOperacionesSinNormalizar.ToString(), Mensajes.ASSEMBLY));
                }

                #region Obsoleto

                //try
                //{
                //    SqlParameter[] parametrosNormalizarAvaluos = new SqlParameter[] { 
                //        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                //        new SqlParameter("psIP", SqlDbType.VarChar, 20),
                //        new SqlParameter("piConsecutivo_Operacion", SqlDbType.BigInt),
                //        new SqlParameter("piConsecutivo_Garantia_Real", SqlDbType.BigInt),
                //        new SqlParameter("psFecha_Valuacion", SqlDbType.VarChar, 10),
                //        new SqlParameter("piTipo_Bien", SqlDbType.SmallInt),
                //        new SqlParameter("piTipo_Mitigador", SqlDbType.SmallInt),
                //        new SqlParameter("psCodigo_Bien", SqlDbType.VarChar, 30),
                //        new SqlParameter("psCodigo_Operacion", SqlDbType.VarChar, 30),
                //        new SqlParameter("psListaCodigosOperaciones", SqlDbType.VarChar, 1000),
                //        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                //    };


                //    parametrosNormalizarAvaluos[0].Value = strUsuario;
                //    parametrosNormalizarAvaluos[1].Value = strIP;
                //    parametrosNormalizarAvaluos[2].Value = datosGarantiaReal.CodOperacion;
                //    parametrosNormalizarAvaluos[3].Value = datosGarantiaReal.CodGarantiaReal;
                //    parametrosNormalizarAvaluos[4].Value = datosGarantiaReal.FechaValuacion.ToString("yyyyMMdd");
                //    parametrosNormalizarAvaluos[5].Value = datosGarantiaReal.CodTipoBien;
                //    parametrosNormalizarAvaluos[6].Value = datosGarantiaReal.CodTipoMitigador;
                //    parametrosNormalizarAvaluos[7].Value = datosGarantiaReal.GarantiaRealBitacora;
                //    parametrosNormalizarAvaluos[8].Value = strOperacionCrediticia;
                //    parametrosNormalizarAvaluos[9].Value = datosGarantiaReal.OperacionesRelacionadas.ListaConsecutivosOperaciones();
                //    parametrosNormalizarAvaluos[10].Direction = ParameterDirection.Output;

                //    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                //    {
                //        oConexion.Open();

                //        AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Normalizar_Avaluo_Garantias_Reales", parametrosNormalizarAvaluos);

                //        respuestaObtenida = parametrosNormalizarAvaluos[10].Value.ToString();
                //    }

                //    if (respuestaObtenida.Length > 0)
                //    {
                //        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                //        if (strMensajeObtenido[0].CompareTo("0") != 0)
                //        {
                //            throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorNormalizandoAvaluo, Mensajes.ASSEMBLY));
                //        }
                //    }
                //}
                //catch (Exception ex)
                //{
                //    string errorBitacora = string.Empty;
                //    string errorUsuario = Mensajes.Obtener(Mensajes._errorNormalizandoAvaluo, Mensajes.ASSEMBLY);
                //    ExcepcionBase errorUI = new ExcepcionBase(errorUsuario);

                //    if ((strMensajeObtenido != null) && (strMensajeObtenido.Length > 1))
                //    {
                //        string detalleError = ((strMensajeObtenido[0] != null) && (strMensajeObtenido[0].Trim().Length > 0)) ? ("Código del error: " + strMensajeObtenido[0] + ". ") : "Código del error: N/A. ";
                //        detalleError += ((strMensajeObtenido[1] != null) && (strMensajeObtenido[1].Trim().Length > 0)) ? ("Mensaje del error: " + strMensajeObtenido[1] + ". ") : "Mensaje del error: N/A. ";
                //        detalleError += ((strMensajeObtenido[2] != null) && (strMensajeObtenido[2].Trim().Length > 0)) ? ("Detalle del error: " + strMensajeObtenido[2] + ". ") : "Detalle del error: N/A. ";
                //        detalleError += "Detalle Técnico: " + ex.Message;

                //        errorBitacora = Mensajes.Obtener(Mensajes._errorNormalizandoAvaluoDetalle, strGarantia, detalleError, Mensajes.ASSEMBLY);

                //        if ((strMensajeObtenido[0].Trim().Length > 0) && (strMensajeObtenido[1].Trim().Length > 0))
                //        {
                //            if ((strMensajeObtenido[0].CompareTo("-1") == 0) || (strMensajeObtenido[0].CompareTo("-2") == 0) ||
                //               (strMensajeObtenido[0].CompareTo("-3") == 0) || (strMensajeObtenido[0].CompareTo("-4") == 0) ||
                //               (strMensajeObtenido[0].CompareTo("-5") == 0))
                //            {
                //                errorUsuario += " Detalle:" + strMensajeObtenido[1];
                //                errorUI = new ExcepcionBase(errorUsuario);
                //                errorUI.Source = strMensajeObtenido[0];
                //            }
                //        }

                //    }
                //    else
                //    {
                //        errorBitacora = Mensajes.Obtener(Mensajes._errorNormalizandoAvaluoDetalle, strGarantia, ex.Message, Mensajes.ASSEMBLY);
                //    }

                //    UtilitariosComun.RegistraEventLog(errorBitacora, EventLogEntryType.Error);
                //    throw errorUI;
                //}

                #endregion Obsoleto
            }
        }

        #endregion
    }
}
