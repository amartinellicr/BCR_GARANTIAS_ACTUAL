using System;
using System.Data;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;
using BCR.GARANTIAS.Comun;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Deudores.
    /// </summary>
    public class Deudores
	{
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        int nFilasAfectadas = 0;

        #endregion Variables Globales

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
                

                listaCampos = new string[] { clsDeudor._entidadDeudor,
                                             clsDeudor._codTipoDeudor, nTipoPersona.ToString(),
                                             clsDeudor._codGeneradorDivisas, nGeneradorDivisas.ToString(),
                                             clsDeudor._codVinculadoEntidad, nVinculadoEntidad.ToString(),
                                             clsDeudor._codCondicionEspecial, ((nCondicionEspecial != -1) ? nCondicionEspecial.ToString(): DBNull.Value.ToString()),
                                             clsDeudor._codTipoAsignacion, ((nTipoAsignacion != -1) ? nTipoAsignacion.ToString(): DBNull.Value.ToString()),
                                             clsDeudor._nombreDeudor, strNombre,
                                             clsDeudor._cedulaDeudor, strCedula};

                strQry = string.Format("UPDATE dbo.{0} SET {1} = {2}, {3} = {4}, {5} = {6}, {7} = {8}, {9} = {10}, {11} = '{12}' WHERE {13} = '{14}'", listaCampos);


                listaCampos = new string[] { clsDeudor._codTipoDeudor, clsDeudor._codGeneradorDivisas, clsDeudor._codVinculadoEntidad,
                                             clsDeudor._codCondicionEspecial, clsDeudor._codTipoAsignacion, clsDeudor._nombreDeudor,
                                             clsDeudor._entidadDeudor,
                                             clsDeudor._cedulaDeudor, strCedula};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5} FROM dbo.{6} WHERE {7} = '{8}'", listaCampos);


                DataSet dsDeudor = AccesoBD.ejecutarConsulta(sentenciaSql);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strQry, oConexion))
                    {
                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.Text;
                        oComando.Connection.Open();
                        oComando.CommandTimeout = AccesoBD.TiempoEsperaEjecucion;

                        //Ejecuta el comando
                        nFilasAfectadas = oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }

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
                            clsGarantiaFiduciaria oGarantia = clsGarantiaFiduciaria.Current;

                            switch (oGarantia.TipoOperacion)
                            {
                                case ((int)Enumeradores.Tipos_Operaciones.Directa):
                                    listaCampos = new string[] { oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(),
                                                                     oGarantia.Moneda.ToString(),  oGarantia.Producto.ToString(),
                                                                     oGarantia.Numero.ToString()};
                                    strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}-{4}");

                                    break;

                                case ((int)Enumeradores.Tipos_Operaciones.Contrato):
                                    listaCampos = new string[] { oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(),
                                                                     oGarantia.Moneda.ToString(), oGarantia.Numero.ToString()};
                                    strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}");

                                    break;

                                case ((int)Enumeradores.Tipos_Operaciones.Tarjeta):

                                    strOperacionCrediticia = oGarantia.Tarjeta;

                                    break;

                                default:
                                    break;
                            }

                            strGarantia = ((oGarantia.CedulaFiador.Length > 0) ? oGarantia.CedulaFiador : "-");
                        }
                        else if (nTipoGarantia == 2)
                        {
                            CGarantiaReal oGarantia = CGarantiaReal.Current;

                            switch (oGarantia.TipoOperacion)
                            {
                                case ((int)Enumeradores.Tipos_Operaciones.Directa):
                                    listaCampos = new string[] { oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(),
                                                                     oGarantia.Moneda.ToString(),  oGarantia.Producto.ToString(),
                                                                     oGarantia.Numero.ToString()};
                                    strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}-{4}");

                                    break;

                                case ((int)Enumeradores.Tipos_Operaciones.Contrato):
                                    listaCampos = new string[] { oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(),
                                                                     oGarantia.Moneda.ToString(), oGarantia.Numero.ToString()};
                                    strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}");

                                    break;

                                default:
                                    break;
                            }

                            switch (oGarantia.TipoGarantiaReal)
                            {
                                case ((int)Enumeradores.Tipos_Garantia_Real.Hipoteca):
                                    strGarantia = string.Format("{0}-{1}", ((oGarantia.Partido != -1) ? oGarantia.Partido.ToString() : string.Empty), ((oGarantia.Finca != -1) ? oGarantia.Finca.ToString() : string.Empty));
                                    break;
                                case ((int)Enumeradores.Tipos_Garantia_Real.Cedula_Hipotecaria):
                                    strGarantia = string.Format("{0}-{1}", ((oGarantia.Partido != -1) ? oGarantia.Partido.ToString() : string.Empty), ((oGarantia.Finca != -1) ? oGarantia.Finca.ToString() : string.Empty));
                                    break;
                                case ((int)Enumeradores.Tipos_Garantia_Real.Prenda):
                                    strGarantia = string.Format("{0}-{1}", ((oGarantia.ClaseBien != null) ? oGarantia.ClaseBien : string.Empty), ((oGarantia.NumPlaca != null) ? oGarantia.NumPlaca : string.Empty));
                                    break;
                                default:
                                    break;
                            }
                        }
                        else if (nTipoGarantia == 3)
                        {
                            CGarantiaValor oGarantia = CGarantiaValor.Current;

                            switch (oGarantia.TipoOperacion)
                            {
                                case ((int)Enumeradores.Tipos_Operaciones.Directa):
                                    listaCampos = new string[] { oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(),
                                                                     oGarantia.Moneda.ToString(),  oGarantia.Producto.ToString(),
                                                                     oGarantia.Numero.ToString()};
                                    strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}-{4}");

                                    break;

                                case ((int)Enumeradores.Tipos_Operaciones.Contrato):
                                    listaCampos = new string[] { oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(),
                                                                     oGarantia.Moneda.ToString(), oGarantia.Numero.ToString()};
                                    strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}");

                                    break;

                                default:
                                    break;
                            }

                            strGarantia = ((oGarantia.Seguridad != null) ? oGarantia.Seguridad : "-");
                        }

                        #endregion

                        if (!dsDeudor.Tables[0].Rows[0].IsNull(clsDeudor._codTipoDeudor))
                        {
                            int nTipoDeudorObt = Convert.ToInt32(dsDeudor.Tables[0].Rows[0][clsDeudor._codTipoDeudor].ToString());

                            if (nTipoDeudorObt != nTipoPersona)
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty,
                                   clsDeudor._codTipoDeudor,
                                   oTraductor.TraducirTipoPersona(nTipoDeudorObt),
                                   oTraductor.TraducirTipoPersona(nTipoPersona));
                            }
                        }
                        else
                        {
                            if (nTipoPersona != -1)
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                      2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, clsDeudor._codTipoDeudor,
                                      string.Empty,
                                      oTraductor.TraducirTipoPersona(nTipoPersona));
                            }
                        }

                        if (!dsDeudor.Tables[0].Rows[0].IsNull(clsDeudor._codGeneradorDivisas))
                        {
                            int nCodigoGeneradorDivisasObt = Convert.ToInt32(dsDeudor.Tables[0].Rows[0][clsDeudor._codGeneradorDivisas].ToString());

                            if (nCodigoGeneradorDivisasObt != nGeneradorDivisas)
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, clsDeudor._codGeneradorDivisas,
                                   oTraductor.TraducirTipoGenerador(nCodigoGeneradorDivisasObt),
                                   oTraductor.TraducirTipoGenerador(nGeneradorDivisas));
                            }
                        }
                        else
                        {
                            if (nGeneradorDivisas != -1)
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                       2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, clsDeudor._codGeneradorDivisas,
                                       string.Empty,
                                       oTraductor.TraducirTipoGenerador(nGeneradorDivisas));
                            }
                        }

                        if (!dsDeudor.Tables[0].Rows[0].IsNull(clsDeudor._codVinculadoEntidad))
                        {
                            int nCodigoVinculadoEntidadObt = Convert.ToInt32(dsDeudor.Tables[0].Rows[0][clsDeudor._codVinculadoEntidad].ToString());

                            if (nCodigoVinculadoEntidadObt != nVinculadoEntidad)
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, clsDeudor._codVinculadoEntidad,
                                   oTraductor.TraducirTipoVinculadoEntidad(nCodigoVinculadoEntidadObt),
                                   oTraductor.TraducirTipoVinculadoEntidad(nVinculadoEntidad));
                            }
                        }
                        else
                        {
                            if (nVinculadoEntidad != -1)
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                      2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, clsDeudor._codVinculadoEntidad,
                                      string.Empty,
                                      oTraductor.TraducirTipoVinculadoEntidad(nVinculadoEntidad));
                            }
                        }

                        if (!dsDeudor.Tables[0].Rows[0].IsNull(clsDeudor._codCondicionEspecial))
                        {
                            int nCodigoCondicionEspecialObt = Convert.ToInt32(dsDeudor.Tables[0].Rows[0][clsDeudor._codCondicionEspecial].ToString());

                            if (nCodigoCondicionEspecialObt != nCondicionEspecial)
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, clsDeudor._codCondicionEspecial,
                                   oTraductor.TraducirTipoCondicionEspecial(nCodigoCondicionEspecialObt),
                                   oTraductor.TraducirTipoCondicionEspecial(nCondicionEspecial));
                            }
                        }
                        else
                        {
                            if (nCondicionEspecial != -1)
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                       2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, clsDeudor._codCondicionEspecial,
                                       string.Empty,
                                       oTraductor.TraducirTipoCondicionEspecial(nCondicionEspecial));
                            }
                        }

                        if (!dsDeudor.Tables[0].Rows[0].IsNull(clsDeudor._codTipoAsignacion))
                        {
                            int nCodigoTipoAsignacionObt = Convert.ToInt32(dsDeudor.Tables[0].Rows[0][clsDeudor._codTipoAsignacion].ToString());

                            if (nCodigoTipoAsignacionObt != nTipoAsignacion)
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, clsDeudor._codTipoAsignacion,
                                   oTraductor.TraducirTipoAsignacion(nCodigoTipoAsignacionObt),
                                   oTraductor.TraducirTipoAsignacion(nTipoAsignacion));
                            }
                        }
                        else
                        {
                            if (nTipoAsignacion != -1)
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                       2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, clsDeudor._codTipoAsignacion,
                                       string.Empty,
                                       oTraductor.TraducirTipoAsignacion(nTipoAsignacion));
                            }
                        }

                        if (!dsDeudor.Tables[0].Rows[0].IsNull(clsDeudor._nombreDeudor))
                        {
                            string strNombreDeudorObt = dsDeudor.Tables[0].Rows[0][clsDeudor._nombreDeudor].ToString();

                            if ((strNombreDeudorObt.Trim().CompareTo(strNombre.Trim()) != 0) && (strNombre != string.Empty))
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, clsDeudor._nombreDeudor,
                                   strNombreDeudorObt,
                                   strNombre);
                            }
                        }
                        else
                        {
                            if (strNombre != string.Empty)
                            {
                                oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
                                       2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, clsDeudor._nombreDeudor,
                                       string.Empty,
                                       strNombre);
                            }
                        }
                    }

                    #endregion
                }
            }
            catch
            {
                throw;
            }
        }

        public string ObtenerNombreDeudor(string strCedula)
        {
            string nombreDeudor = string.Empty;

            try
            {
                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_ObtenerNombreCliente", oConexion))
                    {
                        SqlParameter oParam = new SqlParameter();

                        //declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;
                        oComando.CommandTimeout = AccesoBD.TiempoEsperaEjecucion;

                        //agrega los parametros
                        oComando.Parameters.AddWithValue("@strCedula", strCedula);

                        //inicializacion del objeto output
                        oParam.SqlDbType = SqlDbType.VarChar;
                        oParam.Size = 150;
                        oParam.Direction = ParameterDirection.Output;
                        oParam.ParameterName = "@strNombre";
                        oComando.Parameters.Add(oParam);

                        //Abre la conexion
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        oComando.ExecuteNonQuery();

                        nombreDeudor = oParam.Value.ToString();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }
            }
            catch
            {
                throw;
            }

            return nombreDeudor;
        }
	#endregion
	}
}
