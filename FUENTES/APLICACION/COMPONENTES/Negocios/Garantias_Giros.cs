using System;
using System.Data;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;
using BCR.GARANTIAS.Comun;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Garantias_Giros.
    /// </summary>
    public class Garantias_Giros
    {
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        string strInsertarGarantiaGiro = string.Empty;
        int nFilasAfectadas = 0;

        #endregion Variables Globales

        #region Métodos Públicos
        public void AsignarGarantias(long nGiro, long nContrato, string strUsuario, string strIP, string strOperacionCrediticia)
        {
            DataSet dsData = new DataSet();

            try
            {
                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_AsignarGarantiaGiro", oConexion))
                    {
                        SqlParameter oParam = new SqlParameter();

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        //Agrega los parametros
                        oComando.Parameters.AddWithValue("@nGiro", nGiro);
                        oComando.Parameters.AddWithValue("@nContrato", nContrato);
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
                    #region Inserción en Bitácora

                    string strGarantia = "-";
                    string strCodigoGarantia = string.Empty;
                    string strCodigoTipoGarantia = string.Empty;

                    listaCampos = new string[] { nGiro.ToString(), nContrato.ToString(), clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, clsGarantiaFiduciaria._codigoTipoGarantia };

                    strInsertarGarantiaGiro = string.Format("INSERT INTO GAR_GARANTIAS_X_GIRO (cod_operacion_giro, cod_operacion, cod_garantia, cod_tipo_garantia) VALUES ({0}, {1}, {2}, {4})", listaCampos);

                    //Aquí se determina a que tipo de garantía pertenece el número de contrato 

                    #region Garantía Fiduciaria

                    listaCampos = new string[] {nGiro.ToString(), nContrato.ToString(), clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, clsGarantiaFiduciaria._codigoTipoGarantia, clsGarantiaFiduciaria._cedulaFiador,
                                                clsGarantiaFiduciaria._entidadGarantiaFiduciariaXOperacion, clsGarantiaFiduciaria._entidadGarantiaFiduciaria,
                                                clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria,
                                                clsGarantiaFiduciaria._consecutivoOperacion, nContrato.ToString()};

                    sentenciaSql = string.Format("SELECT {0}, {1}, GGF.{2}, GGF.{3}, GGF.{4} FROM dbo.{5} GFO INNER JOIN dbo.{6} GGF ON GGF.{7} = GFO.{8} WHERE {9} = {10}");

                    DataSet dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta(sentenciaSql);

                    if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
                    {
                        if ((!dsGarantiaFiduciaria.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria))
                          && (!dsGarantiaFiduciaria.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._codigoTipoGarantia))
                          && (!dsGarantiaFiduciaria.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._cedulaFiador)))
                        {
                            strCodigoGarantia = dsGarantiaFiduciaria.Tables[0].Rows[0][clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria].ToString();
                            strCodigoTipoGarantia = dsGarantiaFiduciaria.Tables[0].Rows[0][clsGarantiaFiduciaria._codigoTipoGarantia].ToString();
                            strGarantia = dsGarantiaFiduciaria.Tables[0].Rows[0][clsGarantiaFiduciaria._cedulaFiador].ToString();

                            //Se inserta en bitácora las garantías fiduciarias replicadas
                            InsertarBitacora(strCodigoTipoGarantia, strCodigoGarantia, strOperacionCrediticia, strUsuario, strIP, strInsertarGarantiaGiro);
                        }
                    }

                    #endregion

                    #region Garantía Real

                    listaCampos = new string[] {nGiro.ToString(), nContrato.ToString(), clsGarantiaReal._codGarantiaReal, clsGarantiaReal._codTipoGarantiaReal,
                                                clsGarantiaReal._codTipoGarantia, clsGarantiaReal._numeroFinca, clsGarantiaReal._numPlacaBien, clsGarantiaReal._codClaseBien, clsGarantiaReal._codPartido,
                                                clsGarantiaReal._entidadGarantiaRealXOperacion, clsGarantiaReal._entidadGarantiaReal,
                                                clsGarantiaReal._codGarantiaReal, clsGarantiaReal._codGarantiaReal,
                                                clsGarantiaReal._codOperacion, nContrato.ToString()};

                    sentenciaSql = string.Format("SELECT {0}, {1}, GGR.{2}, GGR.{3}, GGR.{4}, GGR.{5}, GGR.{6}, GGR.{7}, GGR.{8} FROM dbo.{9} GRO INNER JOIN dbo.{10} GGR ON GRO.{11} = GGR.{12} WHERE {13} = {14}");

                    DataSet dsGarantiaReal = AccesoBD.ejecutarConsulta(sentenciaSql);

                    if ((dsGarantiaReal != null) && (dsGarantiaReal.Tables.Count > 0) && (dsGarantiaReal.Tables[0].Rows.Count > 0))
                    {
                        if ((!dsGarantiaReal.Tables[0].Rows[0].IsNull(clsGarantiaReal._codGarantiaReal))
                           && (!dsGarantiaReal.Tables[0].Rows[0].IsNull(clsGarantiaReal._codTipoGarantia)))
                        {
                            listaCampos = new string[] { nGiro.ToString(), nContrato.ToString(), clsGarantiaReal._codGarantiaReal, clsGarantiaReal._codTipoGarantia };

                            strInsertarGarantiaGiro = string.Format("INSERT INTO GAR_GARANTIAS_X_GIRO (cod_operacion_giro, cod_operacion, cod_garantia, cod_tipo_garantia) VALUES ({0}, {1}, {2}, {4})", listaCampos);

                            strCodigoGarantia = dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codGarantiaReal].ToString();
                            strCodigoTipoGarantia = dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codTipoGarantia].ToString();

                            if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(clsGarantiaReal._codTipoGarantiaReal))
                            {
                                string strCodigoTipoGarantiaReal = dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codTipoGarantiaReal].ToString();

                                int nCodigoTipoGarantiaReal = -1;

                                if (strCodigoTipoGarantiaReal != string.Empty)
                                {
                                    nCodigoTipoGarantiaReal = Convert.ToInt32(strCodigoTipoGarantiaReal);
                                }

                                //Se genera el dato correspondiente a la garantía
                                if (nCodigoTipoGarantiaReal == ((int)Enumeradores.Tipos_Garantia_Real.Hipoteca))
                                {
                                    if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(clsGarantiaReal._codPartido))
                                    {
                                        if (dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codPartido].ToString() != string.Empty)
                                        {
                                            strGarantia = dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codPartido].ToString();
                                        }

                                    }

                                    if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(clsGarantiaReal._numeroFinca))
                                    {
                                        if (dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._numeroFinca].ToString() != string.Empty)
                                        {
                                            strGarantia += "-" + dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._numeroFinca].ToString();
                                        }

                                        if ((dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codPartido] == null)
                                           || (dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codPartido].ToString() == string.Empty))
                                        {
                                            strGarantia = dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._numeroFinca].ToString();
                                        }
                                    }
                                }
                                else if (nCodigoTipoGarantiaReal == ((int)Enumeradores.Tipos_Garantia_Real.Cedula_Hipotecaria))
                                {
                                    if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(clsGarantiaReal._codPartido))
                                    {
                                        if (dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codPartido].ToString() != string.Empty)
                                        {
                                            strGarantia = dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codPartido].ToString();
                                        }

                                    }

                                    if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(clsGarantiaReal._numeroFinca))
                                    {
                                        if (dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._numeroFinca].ToString() != string.Empty)
                                        {
                                            strGarantia += "-" + dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._numeroFinca].ToString();
                                        }

                                        if ((dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codPartido] == null)
                                           || (dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codPartido].ToString() == string.Empty))
                                        {
                                            strGarantia = dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._numeroFinca].ToString();
                                        }
                                    }

                                }
                                else if (nCodigoTipoGarantiaReal == ((int)Enumeradores.Tipos_Garantia_Real.Prenda))
                                {
                                    if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(clsGarantiaReal._codClaseBien))
                                    {
                                        if (dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codClaseBien].ToString() != string.Empty)
                                        {
                                            strGarantia = dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codClaseBien].ToString();
                                        }

                                    }

                                    if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(clsGarantiaReal._numPlacaBien))
                                    {
                                        if (dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._numPlacaBien].ToString() != string.Empty)
                                        {
                                            strGarantia += "-" + dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._numPlacaBien].ToString();
                                        }

                                        if ((dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codClaseBien] == null)
                                           || (dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codClaseBien].ToString() == string.Empty))
                                        {
                                            strGarantia = dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._numPlacaBien].ToString();
                                        }
                                    }
                                }
                            }

                            //Se inserta en bitácora las garantías reales replicadas
                            InsertarBitacora(strCodigoTipoGarantia, strCodigoGarantia, strOperacionCrediticia, strUsuario, strIP, strInsertarGarantiaGiro);
                        }
                    }
                    #endregion

                    #region Garantía Valor

                    listaCampos = new string[] {nGiro.ToString(), nContrato.ToString(), clsGarantiaValor._consecutivoGarantiaValor, clsGarantiaValor._codigoTipoGarantia, clsGarantiaValor._numeroSeguridad,
                                                clsGarantiaValor._entidadGarantiaValorXOperacion, clsGarantiaValor._entidadGarantiaValor,
                                                clsGarantiaValor._consecutivoGarantiaValor, clsGarantiaValor._consecutivoGarantiaValor,
                                                clsGarantiaValor._consecutivoOperacion, nContrato.ToString()};

                    sentenciaSql = string.Format("SELECT {0}, {1}, GGV.{2}, GGV.{3}, GGV.{4} FROM dbo.{5} GVO INNER JOIN dbo.{6} GGV ON GVO.{7} = GGV.{8} WHERE {9} = {10}");

                    DataSet dsGarantiaValor = AccesoBD.ejecutarConsulta(sentenciaSql);

                    if ((dsGarantiaValor != null) && (dsGarantiaValor.Tables.Count > 0) && (dsGarantiaValor.Tables[0].Rows.Count > 0))
                    {
                        if ((!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._consecutivoGarantiaValor))
                          && (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoTipoGarantia))
                          && (!dsGarantiaValor.Tables[0].Rows[0].IsNull(clsGarantiaValor._numeroSeguridad)))
                        {
                            strCodigoGarantia = dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._consecutivoGarantiaValor].ToString();
                            strCodigoTipoGarantia = dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._codigoTipoGarantia].ToString();

                            strGarantia = dsGarantiaValor.Tables[0].Rows[0][clsGarantiaValor._numeroSeguridad].ToString();

                            //Se inserta en bitácora las garantías reales replicadas
                            InsertarBitacora(strCodigoTipoGarantia, strCodigoGarantia, strOperacionCrediticia, strUsuario, strIP, strInsertarGarantiaGiro);
                        }
                    }
                    #endregion


                    #endregion
                }
            }
            catch
            {
                throw;
            }
        }

        #endregion Métodos Públicos

        #region Métodos Privados

        /// <summary>
        /// Método que se encarga de registrar en bitácora los registros replicados
        /// </summary>
        /// <param name="codigoTipoGarantia">Tipo de garantía</param>
        /// <param name="codigoGarantia">Identificación de la garantía</param>
        /// <param name="strOperacionCrediticia">Contrato al que se están asignado los giros</param>
        /// <param name="strUsuario">Identificación del usuario que realiza la asignación</param>
        /// <param name="strIP">IP de la máquina desde la cual se hace la acción</param>
        /// <param name="insertarGarantiaGiro">Sentencia SQL generada en la inserción de los registros</param>
        private void InsertarBitacora(string codigoTipoGarantia, string codigoGarantia, string strOperacionCrediticia, string strUsuario, string strIP, string insertarGarantiaGiro)
        {
            Bitacora oBitacora = new Bitacora();

            TraductordeCodigos oTraductor = new TraductordeCodigos();

            if ((codigoTipoGarantia != string.Empty) && (codigoGarantia != string.Empty))
            {

                oBitacora.InsertarBitacora("GAR_GARANTIAS_X_GIRO", strUsuario, strIP, null,
                    1, Convert.ToInt32(codigoTipoGarantia), codigoGarantia, strOperacionCrediticia,
                    insertarGarantiaGiro, string.Empty,
                    clsGarantiasXGiro._codigoTipoGarantia,
                    string.Empty,
                    oTraductor.TraducirTipoGarantia(Convert.ToInt32(codigoTipoGarantia)));

                oBitacora.InsertarBitacora("GAR_GARANTIAS_X_GIRO", strUsuario, strIP, null,
                    1, Convert.ToInt32(codigoTipoGarantia), codigoGarantia, strOperacionCrediticia,
                    insertarGarantiaGiro, string.Empty,
                    clsGarantiasXGiro._consecutivoGarantia,
                    string.Empty,
                    codigoGarantia);

                oBitacora.InsertarBitacora("GAR_GARANTIAS_X_GIRO", strUsuario, strIP, null,
                    1, Convert.ToInt32(codigoTipoGarantia), codigoGarantia, strOperacionCrediticia,
                    insertarGarantiaGiro, string.Empty,
                    clsGarantiasXGiro._consecutivoOperacion,
                    string.Empty,
                    strOperacionCrediticia);
            }

            #endregion Métodos Privados
        }
    }
}
