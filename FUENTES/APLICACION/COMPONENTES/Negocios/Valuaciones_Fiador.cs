using System;
using System.Data;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;
using BCR.GARANTIAS.Comun;

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
        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        int nFilasAfectadas = 0;

        #endregion

        #region Metodos Publicos

        public void Crear(int nGarantiaFiduciaria, string dFecha, decimal nIngresoNeto, int nTieneCapacidad, 
                          string strUsuario, string strIP)
		{
            try
            {
                string strIngreso = nIngresoNeto.ToString();
                strIngreso = strIngreso.Replace(",", ".");

                DateTime dFechaConvertida = Convert.ToDateTime(dFecha);

                string strFecha = dFechaConvertida.ToString("yyyyMMdd");

                listaCampos = new string[] { clsValuacionesFiador._entidadAvaluoFiador,
                                             clsValuacionesFiador._consecutivoGarantiaFiduciaria, clsValuacionesFiador._fechaValuacion, clsValuacionesFiador._montoIngresoNeto, clsValuacionesFiador._indicadorTieneCapacidadPago,
                                             nGarantiaFiduciaria.ToString(), strFecha, strIngreso,  ((nTieneCapacidad != -1) ? nTieneCapacidad.ToString() : UtilitariosComun.ValorNulo)};

                string strInsertarValuacionesFiador = string.Format("INSERT INTO dbo.{0} ({1}, {2}, {3}, {4}) VALUES({5}, '{6}', CONVERT(DECIMAL(18,2), '{7}'), {8})", listaCampos);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strInsertarValuacionesFiador, oConexion))
                    {
                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.Text;
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

                    clsGarantiaFiduciaria oGarantia = clsGarantiaFiduciaria.Current;

                    switch (oGarantia.TipoOperacion)
                    {
                        case ((int)Enumeradores.Tipos_Operaciones.Directa):

                            strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}-{4}", oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(), oGarantia.Moneda.ToString(), oGarantia.Producto.ToString(), oGarantia.Numero.ToString());
                            break;

                        case ((int)Enumeradores.Tipos_Operaciones.Contrato):
                            strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}", oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(), oGarantia.Moneda.ToString(), oGarantia.Numero.ToString());
                            break;
                        case ((int)Enumeradores.Tipos_Operaciones.Tarjeta):
                            strOperacionCrediticia = oGarantia.Tarjeta;
                            break;
                        default:
                            break;
                    }

                    //Informacion del fiador
                    if (oGarantia.CedulaFiador != null)
                        strGarantia = oGarantia.CedulaFiador;

                    oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
                       1, 1, strGarantia, strOperacionCrediticia, strInsertarValuacionesFiador, string.Empty,
                       clsValuacionesFiador._consecutivoGarantiaFiduciaria,
                       string.Empty,
                       strGarantia);

                    oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
                       1, 1, strGarantia, strOperacionCrediticia, strInsertarValuacionesFiador, string.Empty,
                       clsValuacionesFiador._fechaValuacion,
                       string.Empty,
                       dFecha);

                    oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
                       1, 1, strGarantia, strOperacionCrediticia, strInsertarValuacionesFiador, string.Empty,
                       clsValuacionesFiador._montoIngresoNeto,
                       string.Empty,
                       nIngresoNeto.ToString("N2"));

                    //oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
                    //   1, 1, strGarantia, strOperacionCrediticia, strInsertarValuacionesFiador, string.Empty, 
                    //   clsValuacionesFiador._indicadorTieneCapacidadPago,
                    //   string.Empty,
                    //   oTraductor.TraducirTipoTieneCapacidad(nTieneCapacidad));

                    #endregion
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

                listaCampos = new string[] { clsValuacionesFiador._entidadAvaluoFiador,
                                             clsValuacionesFiador._consecutivoGarantiaFiduciaria, nGarantiaFiduciaria.ToString(),
                                             clsValuacionesFiador._fechaValuacion, dFechaConvertida.ToString("yyyyMMdd")};

                string strEliminarValuacionFiador = string.Format("DELETE FROM dbo.{0} WHERE {1} = {2} AND {3} = '{4}'", listaCampos);

                listaCampos = new string[] { clsValuacionesFiador._montoIngresoNeto, clsValuacionesFiador._fechaValuacion,
                                             clsValuacionesFiador._entidadAvaluoFiador,
                                             clsValuacionesFiador._consecutivoGarantiaFiduciaria, nGarantiaFiduciaria.ToString(),
                                             clsValuacionesFiador._fechaValuacion, dFechaConvertida.ToShortDateString()};

                sentenciaSql = string.Format("SELECT {0}, {1} FROM dbo.{2} WHERE {3} = {4} AND {5} = '{6}'", listaCampos);

                //Se obtienen los datos antes de ser borrados, para poder insertarlos en la bitácora
                DataSet dsValuacionesFiador = AccesoBD.ejecutarConsulta(sentenciaSql);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strEliminarValuacionFiador, oConexion))
                    {
                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.Text;
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

                    CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;

                    switch (oGarantia.TipoOperacion)
                    {
                        case ((int)Enumeradores.Tipos_Operaciones.Directa):

                            strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}-{4}", oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(), oGarantia.Moneda.ToString(), oGarantia.Producto.ToString(), oGarantia.Numero.ToString());
                            break;

                        case ((int)Enumeradores.Tipos_Operaciones.Contrato):
                            strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}", oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(), oGarantia.Moneda.ToString(), oGarantia.Numero.ToString());
                            break;
                        case ((int)Enumeradores.Tipos_Operaciones.Tarjeta):
                            strOperacionCrediticia = oGarantia.Tarjeta;
                            break;
                        default:
                            break;
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
                                switch (drValFia.Table.Columns[nIndice].ColumnName)
                                {
                                    case clsValuacionesFiador._indicadorTieneCapacidadPago: break;
                                    case clsValuacionesFiador._consecutivoGarantiaFiduciaria:
                                        oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
                                       3, 1, strGarantia, strOperacionCrediticia, strEliminarValuacionFiador, string.Empty,
                                       drValFia.Table.Columns[nIndice].ColumnName,
                                       strGarantia,
                                       string.Empty);

                                        break;

                                    case clsValuacionesFiador._fechaValuacion:

                                        DateTime dtFechaVal = Convert.ToDateTime(drValFia[clsValuacionesFiador._fechaValuacion].ToString());

                                        oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
                                           3, 1, strGarantia, strOperacionCrediticia, strEliminarValuacionFiador, string.Empty,
                                           drValFia.Table.Columns[nIndice].ColumnName,
                                           dtFechaVal.ToShortDateString(),
                                           string.Empty);

                                        break;

                                    case clsValuacionesFiador._montoIngresoNeto:

                                        decimal ingresoNeto = Convert.ToDecimal(drValFia[clsValuacionesFiador._montoIngresoNeto].ToString());

                                        oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
                                           3, 1, strGarantia, strOperacionCrediticia, strEliminarValuacionFiador, string.Empty,
                                           drValFia.Table.Columns[nIndice].ColumnName,
                                           ingresoNeto.ToString("N2"),
                                           string.Empty);

                                        break;

                                    default:
                                        oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
                                       3, 1, strGarantia, strOperacionCrediticia, strEliminarValuacionFiador, string.Empty,
                                       drValFia.Table.Columns[nIndice].ColumnName,
                                       drValFia[nIndice, DataRowVersion.Current].ToString(),
                                       string.Empty);
                                        break;
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
            catch
            {
                throw;
            }
		}

        public DataSet ObtenerValuaciones(int nGarantiaFiduciaria)
        {
            DataSet listaAvaluos = new DataSet();

            try
            {
                listaCampos = new string[] {clsValuacionesFiador._fechaValuacion, clsValuacionesFiador._montoIngresoNeto,
                                            clsValuacionesFiador._entidadAvaluoFiador,
                                            clsValuacionesFiador._consecutivoGarantiaFiduciaria,  nGarantiaFiduciaria.ToString()};

                string strInsertarValuacionesFiador = string.Format("SELECT CONVERT(VARCHAR(10), {0}, 103) AS fecha_valuacion, {0} AS fecha_Avaluo, {1} FROM dbo.{2} WHERE {3} = {4} ORDER BY fecha_Avaluo DESC", listaCampos);

                listaAvaluos = AccesoBD.ejecutarConsulta(strInsertarValuacionesFiador);

            }
            catch
            {
                throw;
            }

            return listaAvaluos;
        }
        
        public bool ExisteFecha(int nGarantiaFiduciaria, string dFecha)
        {
            bool existeFecha = false;
            int valorRetornado;

            try
            {
                listaCampos = new string[] {clsValuacionesFiador._entidadAvaluoFiador,
                                            clsValuacionesFiador._consecutivoGarantiaFiduciaria, nGarantiaFiduciaria.ToString(),
                                            clsValuacionesFiador._fechaValuacion, dFecha};

                string strConsultarFechaValuacion = string.Format("(SELECT 1 FROM dbo.{0} WHERE {1} = {2} AND {3} = '{4}')", listaCampos);

                SqlParameter[] parameters = new SqlParameter[] { };

                object resultadoObtenido = AccesoBD.ExecuteScalar(CommandType.Text, strConsultarFechaValuacion, parameters);
                existeFecha = (((resultadoObtenido != null) && (int.TryParse(resultadoObtenido.ToString(), out valorRetornado))) ? ((valorRetornado != 0) ? true : false) : false);
            }
            catch
            {
                throw;
            }

            return existeFecha;
        }

		#endregion
	}
}
