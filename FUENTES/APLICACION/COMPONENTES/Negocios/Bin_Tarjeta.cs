using System;
using System.Data;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    public class Bin_Tarjeta
    {
        /// <summary>
        /// Método que permite insertar un nuevo bin 
        /// </summary>
        /// <param name="nBin">Entero con el número de bin</param>
        /// <param name="strUsuario">Código del usuario que realiza la operación</param>
        /// <param name="strIP">Dirección IP de la máquina donde se realiza la operación</param>
        /// <returns>Código obtenido del procedimiento almacenado</returns>
        public int Insertar_Bin_Tarjeta(int nBin, string strUsuario, string strIP)
        {
            /*variable para almacenar el valor del mensaje que retorna el procedimiento almacenado*/
            int nMensaje = 0;

            using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
            {
                try
                {
                    /*declara el sqlCommand que se utilizará para la consulta*/
                    using (SqlCommand cmdInsertarBin = new SqlCommand("pa_InsertarBinTarjeta", oConexion))
                    {
                        /*indica al sqlCommand que es un procedimiento almacenado el que se ejecutará*/
                        cmdInsertarBin.CommandType = CommandType.StoredProcedure;
                        /*indica al sqlCommand el tiempo que puede durar la ejecución*/
                        cmdInsertarBin.CommandTimeout = AccesoBD.TiempoEsperaEjecucion;

                        /*ingresa los parámetro requeridos por el procedimiento almacenado*/
                        cmdInsertarBin.Parameters.AddWithValue("@nNumeroBin", nBin);

                        /*abre la conexión con el servidor*/
                        cmdInsertarBin.Connection.Open();

                        nMensaje = Convert.ToInt32(cmdInsertarBin.ExecuteScalar().ToString());

                        cmdInsertarBin.Connection.Close();
                        cmdInsertarBin.Connection.Dispose();
                    }

                    if (nMensaje == 0)
                    {
                        string strInsertarBin = string.Format("INSERT INTO TAR_BIN_SISTAR(bin) VALUES({0})", nBin.ToString());

                        Bitacora oBitacora = new Bitacora();

                        oBitacora.InsertarBitacora("TAR_BIN_SISTAR", strUsuario, strIP, null,
                           1, null, string.Empty, string.Empty, strInsertarBin, string.Empty,
                           clsTarjeta._numeroBin,
                           string.Empty,
                           nBin.ToString());
                    }
                }
                catch
                {
                    /*asigna el mensaje de error*/
                    nMensaje = 2;
                }
                finally
                {
                    /*cierra la coneción con el servidor*/
                    oConexion.Close();
                }/*fin del finally*/

            }/*fin del using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))*/

            return nMensaje;
        }

        /// <summary>
        /// Método que permite eliminar un bin específico 
        /// </summary>
        /// <param name="nBin">Entero con el número de bin</param>
        /// <param name="strUsuario">Código del usuario que realiza la operación</param>
        /// <param name="strIP">Dirección IP de la máquina donde se realiza la operación</param>
        /// <returns>Código obtenido del procedimiento almacenado</returns>
        public int Eliminar_Bin_Tarjeta(int nBin, string strUsuario, string strIP)
        {
            /*variable para almacenar el valor del mensaje que retorna el procedimiento almacenado*/
            int nMensaje = 0;

            using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
            {
                try
                {
                    /*declara el sqlCommand que se utilizará para la consulta*/
                    using (SqlCommand cmdInsertarBin = new SqlCommand("pa_EliminarBinTarjeta", oConexion))
                    {
                        /*indica al sqlCommand que es un procedimiento almacenado el que se ejecutará*/
                        cmdInsertarBin.CommandType = CommandType.StoredProcedure;
                        /*indica al sqlCommand el tiempo que puede durar la ejecución*/
                        cmdInsertarBin.CommandTimeout = 120;

                        /*ingresa los parámetro requeridos por el procedimiento almacenado*/
                        cmdInsertarBin.Parameters.AddWithValue("@nNumeroBin", nBin);

                        /*abre la conexión con el servidor*/
                        cmdInsertarBin.Connection.Open();

                        nMensaje = Convert.ToInt32(cmdInsertarBin.ExecuteScalar().ToString());

                        cmdInsertarBin.Connection.Close();
                        cmdInsertarBin.Connection.Dispose();
                    }

                    if (nMensaje == 0)
                    {
                        string strEliminarBin = string.Format("DELETE FROM TAR_BIN_SISTAR WHERE bin = {0}", nBin.ToString());

                        Bitacora oBitacora = new Bitacora();

                        oBitacora.InsertarBitacora("TAR_BIN_SISTAR", strUsuario, strIP, null,
                           3, null, string.Empty, string.Empty, strEliminarBin, string.Empty,
                           clsTarjeta._numeroBin,
                           nBin.ToString(),
                           string.Empty);
                    }
                }
                catch
                {
                    /*asigna el mensaje de error*/
                    nMensaje = 2;
                }
                finally
                {
                    /*cierra la coneción con el servidor*/
                    oConexion.Close();
                }/*fin del finally*/

            }/*fin del using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))*/

            return nMensaje;
        }

        /// <summary>
        /// Función que permite obtener los bines que existen en la BD
        /// </summary>
        /// <returns>Tabla con los bines almacenados en la BD</returns>
        public DataSet ObtenerListaBin()
        {
            DataSet dsBines = new DataSet();

            try
            {
                string[] listaCampos = { clsTarjeta._numeroBin, clsTarjeta._fechaIngreso, clsTarjeta._entidadBinSistar, clsTarjeta._numeroBin };
                string sentenciaSQL = string.Format("SELECT {0}, {1} FROM dbo.{2} ORDER BY {3}", listaCampos);

                dsBines = AccesoBD.ejecutarConsulta(sentenciaSQL);
            }
            catch
            {
                return null;
            }

            return dsBines;
        }
    }
}
