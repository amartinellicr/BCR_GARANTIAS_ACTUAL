using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;
using System.Configuration;

namespace BCRGARANTIAS.Negocios
{
    public class Bin_Tarjeta
    {
        /// <summary>
        /// M�todo que permite insertar un nuevo bin 
        /// </summary>
        /// <param name="nBin">Entero con el n�mero de bin</param>
        /// <param name="strUsuario">C�digo del usuario que realiza la operaci�n</param>
        /// <param name="strIP">Direcci�n IP de la m�quina donde se realiza la operaci�n</param>
        /// <returns>C�digo obtenido del procedimiento almacenado</returns>
        public int Insertar_Bin_Tarjeta(int nBin, string strUsuario, string strIP)
        {
            /*variable para almacenar el valor del mensaje que retorna el procedimiento almacenado*/
            int nMensaje = 0;

            using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
            {
                try
                {
                    /*declara el sqlCommand que se utilizar� para la consulta*/
                    SqlCommand cmdInsertarBin = new SqlCommand("pa_InsertarBinTarjeta", oConexion);

                    /*indica al sqlCommand que es un procedimiento almacenado el que se ejecutar�*/
                    cmdInsertarBin.CommandType = CommandType.StoredProcedure;
                    /*indica al sqlCommand el tiempo que puede durar la ejecuci�n*/
                    cmdInsertarBin.CommandTimeout = 120;

                    /*ingresa los par�metro requeridos por el procedimiento almacenado*/
                    cmdInsertarBin.Parameters.AddWithValue("@nNumeroBin", nBin);

                    /*abre la conexi�n con el servidor*/
                    oConexion.Open();

                    nMensaje = Convert.ToInt32(cmdInsertarBin.ExecuteScalar().ToString());

                    if (nMensaje == 0)
                    {
                        string strInsertarBin = "INSERT INTO TAR_BIN_SISTAR(bin) VALUES(" + nBin.ToString() + ")";

                        Bitacora oBitacora = new Bitacora();

                        oBitacora.InsertarBitacora("TAR_BIN_SISTAR", strUsuario, strIP, null,
                           1, null, string.Empty, string.Empty, strInsertarBin, string.Empty,
                           ContenedorTar_bin_sistar.BIN,
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
                    /*cierra la coneci�n con el servidor*/
                    oConexion.Close();
                }/*fin del finally*/

            }/*fin del using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))*/

            return nMensaje;
        }

        /// <summary>
        /// M�todo que permite eliminar un bin espec�fico 
        /// </summary>
        /// <param name="nBin">Entero con el n�mero de bin</param>
        /// <param name="strUsuario">C�digo del usuario que realiza la operaci�n</param>
        /// <param name="strIP">Direcci�n IP de la m�quina donde se realiza la operaci�n</param>
        /// <returns>C�digo obtenido del procedimiento almacenado</returns>
        public int Eliminar_Bin_Tarjeta(int nBin, string strUsuario, string strIP)
        {
            /*variable para almacenar el valor del mensaje que retorna el procedimiento almacenado*/
            int nMensaje = 0;

            using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
            {
                try
                {
                    /*declara el sqlCommand que se utilizar� para la consulta*/
                    SqlCommand cmdInsertarBin = new SqlCommand("pa_EliminarBinTarjeta", oConexion);

                    /*indica al sqlCommand que es un procedimiento almacenado el que se ejecutar�*/
                    cmdInsertarBin.CommandType = CommandType.StoredProcedure;
                    /*indica al sqlCommand el tiempo que puede durar la ejecuci�n*/
                    cmdInsertarBin.CommandTimeout = 120;

                    /*ingresa los par�metro requeridos por el procedimiento almacenado*/
                    cmdInsertarBin.Parameters.AddWithValue("@nNumeroBin", nBin);

                    /*abre la conexi�n con el servidor*/
                    oConexion.Open();

                    nMensaje = Convert.ToInt32(cmdInsertarBin.ExecuteScalar().ToString());

                    if (nMensaje == 0)
                    {
                        string strEliminarBin = "DELETE FROM TAR_BIN_SISTAR WHERE bin = " + nBin.ToString();

                        Bitacora oBitacora = new Bitacora();

                        oBitacora.InsertarBitacora("TAR_BIN_SISTAR", strUsuario, strIP, null,
                           3, null, string.Empty, string.Empty, strEliminarBin, string.Empty,
                           ContenedorTar_bin_sistar.BIN,
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
                    /*cierra la coneci�n con el servidor*/
                    oConexion.Close();
                }/*fin del finally*/

            }/*fin del using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))*/

            return nMensaje;
        }

        /// <summary>
        /// Funci�n que permite obtener los bines que existen en la BD
        /// </summary>
        /// <returns>Tabla con los bines almacenados en la BD</returns>
        public DataSet ObtenerListaBin()
        {
            DataSet dsBines = new DataSet();


                try
                {
                    dsBines = AccesoBD.ejecutarConsulta("select bin, fecingreso from " + ContenedorTar_bin_sistar.NOMBRE_ENTIDAD + " order by bin");
                }
                catch
                {
                    return null;
                }

                return dsBines;
        }
    }
}
