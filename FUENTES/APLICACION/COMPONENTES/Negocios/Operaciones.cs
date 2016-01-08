using System;
using System.Data;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;


namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Operaciones.
    /// </summary>
    public class Operaciones
	{        
        #region Métodos Públicos
        public long ObtenerConsecutivoOperacion(int nContabilidad, int nOficina, int nMoneda, int nProducto, long nOperacion, string strDeudor)
		{
            DataSet dsData = new DataSet();
            long nConsecutivo = 0;

            try
            {
                SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("nContabilidad", SqlDbType.SmallInt),
                        new SqlParameter("nOficina", SqlDbType.SmallInt),
                        new SqlParameter("nMoneda", SqlDbType.SmallInt),
                        new SqlParameter("nProducto", SqlDbType.SmallInt),
                        new SqlParameter("nOperacion", SqlDbType.Decimal),
                        new SqlParameter("strDeudor", SqlDbType.VarChar, 30)
                    };

                parameters[0].Value = nContabilidad;
                parameters[1].Value = nOficina;
                parameters[2].Value = nMoneda;
                parameters[3].Value = nProducto;
                parameters[4].Value = nOperacion;
                parameters[5].Value = strDeudor;

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    object datoRetornado = AccesoBD.ExecuteScalar(CommandType.StoredProcedure, "pa_ObtenerConsecutivoOperacion", parameters);

                    oConexion.Close();
                    oConexion.Dispose();

                    nConsecutivo = (long.TryParse(datoRetornado.ToString(), out nConsecutivo) ? nConsecutivo : 0);
                }
 
                return nConsecutivo;
            }
            catch
            {
                throw;
            }
		}

        public clsOperacionCrediticia ValidarOperacion(int nContabilidad, int nOficina, int nMoneda, int nProducto, long nOperacion)
        {
            DataSet dsDatos = new DataSet();
            clsOperacionCrediticia datosOperacion = new clsOperacionCrediticia();

            try
            {
                SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("Contabilidad", SqlDbType.SmallInt),
                        new SqlParameter("Oficina", SqlDbType.SmallInt),
                        new SqlParameter("Moneda", SqlDbType.SmallInt),
                        new SqlParameter("Producto", SqlDbType.SmallInt),
                        new SqlParameter("Operacion", SqlDbType.Decimal)
                    };

                parameters[3].IsNullable = true;

                parameters[0].Value = nContabilidad;
                parameters[1].Value = nOficina;
                parameters[2].Value = nMoneda;

                if (nProducto != -1)
                {
                    parameters[3].Value = nProducto;
                }
                else
                {
                    parameters[3].Value = DBNull.Value;
                }

                parameters[4].Value = nOperacion;

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_ValidarOperaciones", parameters);

                    oConexion.Close();
                    oConexion.Dispose();
                }

                datosOperacion.Contabilidad = ((short) nContabilidad);
                datosOperacion.Oficina = ((short) nOficina);
                datosOperacion.Moneda = ((short) nMoneda);
                datosOperacion.Producto = ((short) nProducto);
                datosOperacion.Operacion = nOperacion;

                datosOperacion.EsGiro = (((dsDatos.Tables[0].Columns.Contains(clsOperacionCrediticia._indicadorEsGiro)) && (!dsDatos.Tables[0].Rows[0].IsNull(clsOperacionCrediticia._indicadorEsGiro)) && (dsDatos.Tables[0].Rows[0][clsOperacionCrediticia._indicadorEsGiro].ToString().CompareTo("1") == 0)) ? true : false);

                datosOperacion.ConsecutivoContrato = (((dsDatos.Tables[0].Columns.Contains(clsOperacionCrediticia._consecutivoContrato)) && (!dsDatos.Tables[0].Rows[0].IsNull(clsOperacionCrediticia._consecutivoContrato))) ? (long.Parse(dsDatos.Tables[0].Rows[0][clsOperacionCrediticia._consecutivoContrato].ToString())) : -1);

                datosOperacion.FormatoLargoContrato = (((datosOperacion.EsGiro) && (dsDatos.Tables[0].Columns.Contains(clsOperacionCrediticia._formatoLargoContrato)) && (!dsDatos.Tables[0].Rows[0].IsNull(clsOperacionCrediticia._formatoLargoContrato))) ? (dsDatos.Tables[0].Rows[0][clsOperacionCrediticia._formatoLargoContrato].ToString()) : string.Empty);

                datosOperacion.ConsecutivoOperacion = (((!datosOperacion.EsGiro) && (dsDatos.Tables[0].Columns.Contains(clsOperacionCrediticia._consecutivoOperacion)) && (!dsDatos.Tables[0].Rows[0].IsNull(clsOperacionCrediticia._consecutivoOperacion))) ? (long.Parse(dsDatos.Tables[0].Rows[0][clsOperacionCrediticia._consecutivoOperacion].ToString())) : -1);

                datosOperacion.CedulaDeudor = (((!datosOperacion.EsGiro) && (dsDatos.Tables[0].Columns.Contains(clsOperacionCrediticia._cedulaDeudor)) && (!dsDatos.Tables[0].Rows[0].IsNull(clsOperacionCrediticia._cedulaDeudor))) ? (dsDatos.Tables[0].Rows[0][clsOperacionCrediticia._cedulaDeudor].ToString()) : string.Empty);

                datosOperacion.NombreDeudor = (((!datosOperacion.EsGiro) && (dsDatos.Tables[0].Columns.Contains(clsOperacionCrediticia._nombreDeudor)) && (!dsDatos.Tables[0].Rows[0].IsNull(clsOperacionCrediticia._nombreDeudor))) ? (dsDatos.Tables[0].Rows[0][clsOperacionCrediticia._nombreDeudor].ToString()) : string.Empty);

                datosOperacion.EsValida = ((datosOperacion.EsGiro) ? false : true);
            }
            catch
            {
                throw;
            }           

            return datosOperacion;
        }

        #endregion
    }
}
