using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Configuration;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    public class Tarjetas
    {
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };

        #endregion Variables Globales

        #region M�todos P�blicos

        /// <summary>
        /// M�todo que permite actualizar el estado de una tarjeta
        /// </summary>
        /// <param name="strNumeroTarjeta">String que posee el n�mero de la tarjeta a la que se le debe actualizar el estado</param>
        /// <param name="strEstadoTarjeta">String que posee el nuevo estado de la tarjeta</param>
        /// <param name="nTipoGarantia">Entero que indica el tipo de garant�a</param>
        /// <returns>Entero con el c�digo de �xito o error de la operaci�n realizada</returns>
        public int ActualizarEstadoTarjeta(string strNumeroTarjeta, string strEstadoTarjeta, int nTipoGarantia)
        {
            int nCodigoRetornado = -1;
            string strTipoGarantia = "-";
            Bitacora oBitacora = new Bitacora();
            DataSet dsData = new DataSet();
            DataSet dsTarjeta = new DataSet();
            long nNumeroTarjeta = 0;

            try
            {
                if ((strEstadoTarjeta != string.Empty) && (strNumeroTarjeta != string.Empty))
                {
                    #region Obtener los datos de la BD antes de ser actualizados

                    //Se obtienen los datos antes de ser modificados, para luego insertalos en la bit�cora
                    strNumeroTarjeta = ((Int64.TryParse(strNumeroTarjeta, out nNumeroTarjeta)) ? nNumeroTarjeta.ToString() : string.Empty);

                    listaCampos = new string[] { clsTarjeta._indicadorEstadoTarjeta, clsTarjeta._codigoTipoGarantia,
                                                 clsTarjeta._entidadTarjeta,
                                                 clsTarjeta._numeroTarjeta, strNumeroTarjeta};

                    sentenciaSql = string.Format("SELECT {0}, {1} FROM dbo.{2} WHERE {3} = '{4}'", listaCampos);

                    dsTarjeta = AccesoBD.ejecutarConsulta(sentenciaSql);

                    #endregion


                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        using (SqlCommand oComando = new SqlCommand("pa_ModificarEstadoTarjeta", oConexion))
                        {
                            SqlParameter oParam = new SqlParameter();

                            //Declara las propiedades del comando
                            oComando.CommandType = CommandType.StoredProcedure;

                            //Agrega los parametros
                            oComando.Parameters.AddWithValue("@strNumeroTarjeta", strNumeroTarjeta);
                            oComando.Parameters.AddWithValue("@strEstadoTarjeta", strEstadoTarjeta);

                            //Abre la conexion
                            oComando.Connection.Open();

                            //Ejecuta el comando
                            nCodigoRetornado = Convert.ToInt32(oComando.ExecuteScalar().ToString());

                            oComando.Connection.Close();
                            oComando.Connection.Dispose();
                        }
                    }

                    if (nCodigoRetornado == 0)
                    {
                        #region Inserci�n en Bit�cora

                        TraductordeCodigos oTraductor = new TraductordeCodigos();

                        listaCampos = new string[] { clsTarjeta._entidadTarjeta,
                                                     clsTarjeta._indicadorEstadoTarjeta, strEstadoTarjeta,
                                                     clsTarjeta._numeroTarjeta, strNumeroTarjeta};

                        string strModificarTarjeta = string.Format("UPDATE {0} SET {1} = '{2}' WHERE {3} = '{4}'", listaCampos);
                        
                        if ((dsTarjeta != null) && (dsTarjeta.Tables.Count > 0) && (dsTarjeta.Tables[0].Rows.Count > 0))
                        {
                            if (nTipoGarantia == -1)
                            {
                                if (!dsTarjeta.Tables[0].Rows[0].IsNull(clsTarjeta._codigoTipoGarantia))
                                {
                                    strTipoGarantia = dsTarjeta.Tables[0].Rows[0][clsTarjeta._codigoTipoGarantia].ToString();

                                    if (strTipoGarantia.CompareTo("1") != 0)
                                    {
                                        nTipoGarantia = 4;
                                    }
                                    else
                                    {
                                        nTipoGarantia = 1;
                                    }
                                }
                            }

                            if (!dsTarjeta.Tables[0].Rows[0].IsNull(clsTarjeta._indicadorEstadoTarjeta))
                            {
                                string strTipoEstadoObt = dsTarjeta.Tables[0].Rows[0][clsTarjeta._indicadorEstadoTarjeta].ToString();

                                if (strTipoEstadoObt.CompareTo(strEstadoTarjeta) != 0)
                                {

                                    oBitacora.InsertarBitacora(clsTarjeta._entidadTarjeta, "SISTAR", "-", null,
                                       2, nTipoGarantia, string.Empty, strNumeroTarjeta, strModificarTarjeta, string.Empty,
                                       clsTarjeta._indicadorEstadoTarjeta,
                                       oTraductor.TraducirCodigoEstadoTarjeta(strTipoEstadoObt),
                                       oTraductor.TraducirCodigoEstadoTarjeta(strEstadoTarjeta));
                                }
                            }
                            else
                            {

                                oBitacora.InsertarBitacora(clsTarjeta._entidadTarjeta, "SISTAR", "-", null,
                                       2, nTipoGarantia, string.Empty, strNumeroTarjeta, strModificarTarjeta, string.Empty,
                                       clsTarjeta._indicadorEstadoTarjeta,
                                       string.Empty,
                                       oTraductor.TraducirCodigoEstadoTarjeta(strEstadoTarjeta));
                            }
                        }
                        else
                        {
                            if (nTipoGarantia != -1)
                            {
                                oBitacora.InsertarBitacora(clsTarjeta._entidadTarjeta, "SISTAR", "-", null,
                                    2, nTipoGarantia, string.Empty, strNumeroTarjeta, strModificarTarjeta, string.Empty,
                                    string.Empty,
                                    string.Empty,
                                    string.Empty);
                            }
                            else
                            {
                                oBitacora.InsertarBitacora(clsTarjeta._entidadTarjeta, "SISTAR", "-", null,
                                    2, null, string.Empty, strNumeroTarjeta, strModificarTarjeta, string.Empty,
                                    string.Empty,
                                    string.Empty,
                                    string.Empty);
                            }
                        }

                        #endregion
                    }
                    else
                    {
                        oBitacora.InsertarBitacora(clsTarjeta._entidadTarjeta, "SISTAR", "-", null,
                           2, nTipoGarantia, string.Empty, strNumeroTarjeta, "Error al cambiar estado: " + nCodigoRetornado.ToString(), string.Empty,
                           clsTarjeta._indicadorEstadoTarjeta,
                           string.Empty,
                           strEstadoTarjeta);
                    }
                }
                else
                {
                    if ((strNumeroTarjeta == string.Empty) && (strEstadoTarjeta == string.Empty))
                    {
                        nCodigoRetornado = 5;
                    }
                    else if (strNumeroTarjeta == string.Empty)
                    {
                        nCodigoRetornado = 3;
                    }
                    else if (strEstadoTarjeta == string.Empty)
                    {
                        nCodigoRetornado = 4;
                    }
                    else
                    {
                        nCodigoRetornado = 2;
                    }

                }
            }
            catch
            {
                throw;
            }
        
            return nCodigoRetornado;
        }

        /// <summary>
        /// Funci�n que permite obtener el estado actual de una determinada tarjeta
        /// </summary>
        /// <param name="strNumeroTarjeta">String que posee el n�mero de la tarjeta a ser consultada</param>
        /// <returns>String con el estado que posee la tarjeta</returns>
        public string ObtenerEstadoTarjeta(string strNumeroTarjeta)
        {
            DataSet dsDatos = new DataSet();
            string strEstadoActual = string.Empty;

            try
            {
                listaCampos = new string[] {clsTarjeta._indicadorEstadoTarjeta, 
                                            clsTarjeta._entidadTarjeta,
                                            clsTarjeta._numeroTarjeta, strNumeroTarjeta};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = '{3}'", listaCampos);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(sentenciaSql, oConexion))
                    {
                        oComando.Connection.Open();

                        using (SqlDataAdapter cmdUsuario = new SqlDataAdapter(oComando))
                        {
                            cmdUsuario.Fill(dsDatos, "Tarjeta");
                        }

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }

                if ((dsDatos.Tables["Tarjeta"] != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Tarjeta"].Rows.Count > 0))
                {
                    if (!dsDatos.Tables["Tarjeta"].Rows[0].IsNull(clsTarjeta._indicadorEstadoTarjeta))
                    {
                        strEstadoActual = dsDatos.Tables["Tarjeta"].Rows[0][clsTarjeta._indicadorEstadoTarjeta].ToString();
                    }
                }
            }
            catch
            {
                throw;
            }

            return strEstadoActual;
        }

        /// <summary>
        /// Funci�n que determina si el bin de una tarjeta a validar en Sistar, realmente est� en Sistar
        /// </summary>
        /// <param name="nBin">N�mero de Bin a ser validado</param>
        /// <returns>True: Si existe el bin � False en caso contrario</returns>
        public bool Verifica_Tarjeta_Sistar(decimal nBin)
        {
            DataSet dsDatos = new DataSet();
            bool bPerteneceASistar = false;

            try
            {
                listaCampos = new string[] {clsTarjeta._numeroBin,
                                            clsTarjeta._entidadBinSistar,
                                            clsTarjeta._numeroBin, nBin.ToString()};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = '{3}'", listaCampos);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(sentenciaSql, oConexion))
                    {
                        oComando.Connection.Open();

                        using (SqlDataAdapter cmdUsuario = new SqlDataAdapter(oComando))
                        {
                            cmdUsuario.Fill(dsDatos, "Tarjeta");
                        }

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }

                if ((dsDatos.Tables["Tarjeta"] != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Tarjeta"].Rows.Count > 0))
                {
                    if (!dsDatos.Tables["Tarjeta"].Rows[0].IsNull("bin"))
                    {
                        bPerteneceASistar = true;
                    }
                }
            }
            catch
            {
                throw;
            }

            return bPerteneceASistar;
        }

        #region M�todo AsignarGarantiaTarjeta: asigna la garant�a a la tarjeta

        /// <summary>
        /// Asigna el tipo de garant�a a la tarjeta en BCR - Garant�as
        /// </summary>
        /// <param name="_numeroTarjeta">
        /// N�mero de tarjeta a la cual se asigna la nueva garant�a
        /// </param>
        /// <param name="_codigoGarantiaNuevo">
        /// C�digo de la garant�a que se est� asignando a la tarjeta
        /// </param>
        /// <param name="strUsuario">
        /// Usuario que realiz� la operaci�n
        /// </param>
        /// <param name="strIP">
        /// Direcci�n IP de la m�quina de donde se realiz� la operaci�n
        /// </param>
        /// <param name="_observaciones">
        /// Observaciones de la operaci�n realizada
        /// </param>
        /// <param name="_codigoRespuesta">
        /// Codigo de confirmaci�n enviado por sistar
        /// </param>
        /// <param name="_infoTarjeta">
        /// Informaci�n necesaria en caso de tener que ingresar la tarjeta en BCR - Garant�as
        /// </param>
        /// <returns>
        /// Entero con el numero de mensaje retornado por la operaci�n
        /// </returns>
        public int AsignarGarantiaTarjeta(string _numeroTarjeta, string _codigoGarantiaNuevo,  
            string strUsuario, string strIP, string _observaciones, string _codigoRespuesta, string[] _infoTarjeta)
        {

            /*variable para almacenar el valor del mensaje que retorna el procedimiento almacenado*/
            int _mensaje = 0;

            /*variable para almacenar el codigo de la garant�a anterior*/
            string _codigoGrantiaAnterior = string.Empty;

            //Valida que la respuesta de MQ fuera "TRANSACCION SATISFACTORIA"
            if (_codigoRespuesta.ToString() == "000")
            {
                #region Actualizaci�n del tipo de garant�a en BCR - Garant�as

                /*declara la conexi�n que se va a utilizar con el servidor*/
                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    /*declara la transacci�n a utilizar*/
                    SqlTransaction _transaccion = null;

                    try
                    {
                        #region Selecci�n de la informaci�n de la garant�a a sustituir

                        /*declara el sqlCommand que se utilizar� para la consulta*/
                        SqlCommand _cmdGarantiaEliminada = new SqlCommand("pa_Consulta_Info_Garantia_Eliminar", oConexion);

                        /*indica al sqlCommand que es un procedimiento almacenado el que se ejecutar�*/
                        _cmdGarantiaEliminada.CommandType = CommandType.StoredProcedure;
                        /*indica al sqlCommand el tiempo que puede durar la ejecuci�n*/
                        _cmdGarantiaEliminada.CommandTimeout = 120;

                        /*ingresa los par�metro requeridos por el procedimiento almacenado*/
                        _cmdGarantiaEliminada.Parameters.AddWithValue("@piCodigo_Catalogo", ConfigurationManager.AppSettings["CAT_TIPO_GARANTIA_TARJETA"].ToString());
                        _cmdGarantiaEliminada.Parameters.AddWithValue("@pnNumero_Tarjeta", _numeroTarjeta);
                        _cmdGarantiaEliminada.Parameters.AddWithValue("@piCodigo_Tipo_Garantia", _codigoGarantiaNuevo);

                        
                        /*declara el sqlDataAdapter que realizar� la consulta*/
                        SqlDataAdapter _daGarantiaEliminada = new SqlDataAdapter(_cmdGarantiaEliminada);
                        /*declara el DataTable que se utilizar� para almacenar la informaci�n consultada*/
                        DataTable _dtInfoGarantiaEliminada = new DataTable("Garant�a_A_Eliminar");

                        #endregion Selecci�n de la informaci�n de la garant�a a sustituir

                        #region Asignaci�n del tipo de garant�a

                        /*declara el sqlCommand que se utilizar� para la consulta*/
                        SqlCommand _cmdTipoGrantia = new SqlCommand("pa_Modificar_Tipo_Garantia_Tarjeta", oConexion);

                        /*indica al sqlCommand que es un procedimiento almacenado el que se ejecutar�*/
                        _cmdTipoGrantia.CommandType = CommandType.StoredProcedure;
                        /*indica al sqlCommand el tiempo que puede durar la ejecuci�n*/
                        _cmdTipoGrantia.CommandTimeout = 120;

                        /*ingresa los par�metro requeridos por el procedimiento almacenado*/
                        _cmdTipoGrantia.Parameters.AddWithValue("@codigo_catalogo", ConfigurationManager.AppSettings["CAT_TIPO_GARANTIA_TARJETA"].ToString());
                        _cmdTipoGrantia.Parameters.AddWithValue("@numero_tarjeta", _numeroTarjeta);
                        _cmdTipoGrantia.Parameters.AddWithValue("@codigo_tipo_Garantia", _codigoGarantiaNuevo);
                        _cmdTipoGrantia.Parameters.AddWithValue("@observaciones", _observaciones);
                        _cmdTipoGrantia.Parameters.AddWithValue("@cedula_deudor", _infoTarjeta[0]);
                        _cmdTipoGrantia.Parameters.AddWithValue("@cod_bin", _infoTarjeta[1]);
                        _cmdTipoGrantia.Parameters.AddWithValue("@cod_interno_sistar", _infoTarjeta[2]);
                        _cmdTipoGrantia.Parameters.AddWithValue("@cod_moneda", _infoTarjeta[3]);
                        _cmdTipoGrantia.Parameters.AddWithValue("@cod_oficina_registra", (_infoTarjeta[4].Equals(string.Empty)) ? null : _infoTarjeta[4]);

                        #endregion Asignaci�n del tipo de garant�a

                        #region Selecciona el valor del campo observaciones

                        /*declara el sqlCommand que se utilizar� para la consulta*/

                        sentenciaSql = string.Format("DECLARE @codigo_tarjeta INT; SET @codigo_tarjeta = (SELECT cod_tarjeta FROM dbo.Tar_tarjeta WHERE num_tarjeta = {0}) SELECT observaciones FROM dbo.TAR_GARANTIAS_X_PERFIL_X_TARJETA WHERE cod_tarjeta = @codigo_tarjeta", _numeroTarjeta);

                        SqlCommand _cmdObservaciones = new SqlCommand(sentenciaSql);

                        /*se asigna la conexi�n*/
                        _cmdObservaciones.Connection = oConexion;

                        /*indica al sqlCommand el tiempo que puede durar la ejecuci�n*/
                        _cmdObservaciones.CommandTimeout = AccesoBD.TiempoEsperaEjecucion;


                        string _observacionesAnteriores = string.Empty;

                        #endregion Selecciona el valor del campo observaciones

                        #region Selecciona el valor del campo cod_tipo_garantia de la tabla tar_tarjeta

                        /*declara el sqlCommand que se utilizar� para la consulta*/
                        sentenciaSql = string.Format("SELECT cod_tipo_garantia FROM dbo.TAR_TARJETA WHERE num_tarjeta = '{0}'", _numeroTarjeta);

                        SqlCommand _cmdCodigoGarantia = new SqlCommand(sentenciaSql);

                        /*se asigna la conexi�n*/
                        _cmdCodigoGarantia.Connection = oConexion;

                        /*indica al sqlCommand el tiempo que puede durar la ejecuci�n*/
                        _cmdCodigoGarantia.CommandTimeout = 120;

                        #endregion Selecciona el valor del campo cod_tipo_garantia de la tabla tar_tarjeta

                        /*abre la conexi�n con el servidor*/
                        oConexion.Open();

                        /*inicia la transacci�n*/
                        _transaccion = oConexion.BeginTransaction();

                        /*indica al sqlCommand la transacci�n a utilizar y lo ejecuta*/
                        _cmdCodigoGarantia.Transaction = _transaccion;
                        _codigoGrantiaAnterior = (_cmdCodigoGarantia.ExecuteScalar() == null) ? string.Empty : _cmdCodigoGarantia.ExecuteScalar().ToString();

                        /*indica al sqlCommand la transacci�n a utilizar y lo ejecuta*/
                        _cmdGarantiaEliminada.Transaction = _transaccion;
                        _daGarantiaEliminada.Fill(_dtInfoGarantiaEliminada);

                        /*indica al sqlCommand la transacci�n a utilizar y lo ejecuta*/
                        _cmdObservaciones.Transaction = _transaccion;
                        _observacionesAnteriores = (_cmdObservaciones.ExecuteScalar() == null) ? string.Empty : _cmdObservaciones.ExecuteScalar().ToString();

                        /*indica al sqlCommand la transacci�n a utilizar y lo ejecuta*/
                        _cmdTipoGrantia.Transaction = _transaccion;
                        _mensaje = Convert.ToInt32(_cmdTipoGrantia.ExecuteScalar().ToString());

                        InsertarBitacora(strUsuario, strIP, _numeroTarjeta, _codigoGarantiaNuevo, _observaciones,
                        _mensaje, _observacionesAnteriores, _codigoGrantiaAnterior, _infoTarjeta);

                        /*elimina la informaci�n de la garant�a*/
                        foreach (DataRow dr in _dtInfoGarantiaEliminada.Rows)
                        {
                            InsertarBitacoraEliminacion(dr, _numeroTarjeta, strUsuario, strIP);
                        }/*fin del foreach (DataRow dr in _dtInfoGarantiaEliminada.Rows)*/

                        /*termina la transacci�n*/
                        _transaccion.Commit();

                        /*cierra la coneci�n con el servidor*/
                        oConexion.Close();

                    }
                    catch
                    {
                        /*asigna el mensaje de error*/
                        _mensaje = 0;

                        /*retorna la informaci�n al estado anterior a la ejecuci�n de la transacci�n*/
                        _transaccion.Rollback();
                    }
                    finally
                    {
                        /*cierra la coneci�n con el servidor*/
                        oConexion.Close();
                    }/*fin del finally*/

                }/*fin del using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))*/

                #endregion Actualizaci�n del tipo de garant�a en BCR - Garant�as

            }/*fin del if (_codigoRespuesta.ToString() == "000")*/

            return _mensaje;

        }/*fin del m�todo AsignarGarantiaTarjeta*/

        #endregion M�todo AsignarGarantiaTarjeta: asigna la garant�a a la tarjeta

        /// <summary>
        /// Funci�n que verifica si el c�digo obtenido de SISTAR para el tipo de garant�a corresponde a un perfil o no
        /// </summary>
        /// <param name="nCodigoTipoGarantia">C�digo del tipo de garant�a a ser verificado</param>
        /// <returns>True: En caso de que el c�digo corresponda a un perfil.
        ///          False: En caso contrario</returns>
        public bool CodigoTipoTarjetaEsPerfil(int nCodigoTipoGarantia)
        {
            bool bDatoRetornar = false;
            string strDescripcion = string.Empty;

            strDescripcion = new TraductordeCodigos().TraducirCodigoTipoGarantiaTarjeta(nCodigoTipoGarantia.ToString());

            if ((nCodigoTipoGarantia != 1) && (strDescripcion != string.Empty) && (strDescripcion.CompareTo("-") != 0))
            {
                bDatoRetornar = true;
            }

            return bDatoRetornar;
        }
        #endregion

        #region M�todos Privados

        /// <summary>
        /// Inserta en bit�cora la informaci�n que ha sido elimana de la garant�a al realizar el cambio de
        /// Garant�a por Perfil a Garant�a Fiduciaria y viceversa
        /// </summary>
        /// <param name="_drInfoFilaEliminada">
        /// Fila con la informaci�n que ha sido elimana
        /// </param>
        /// <param name="numeroTarjeta">
        /// N�mero de tarjeta a la que aplica el cambio de garant�a
        /// </param>
        /// <param name="strUsuario">
        /// Usuario del sistema que realiz� el cambio
        /// </param>
        /// <param name="strIP">
        /// N�mero IP de la m�quina desde la cual se realiz� el cambio
        /// </param>
        private void InsertarBitacoraEliminacion(DataRow _drInfoFilaEliminada, string numeroTarjeta,
            string strUsuario, string strIP)
        {
            #region Inserci�n en Bit�cora

            Bitacora oBitacora = new Bitacora();

            TraductordeCodigos oTraductor = new TraductordeCodigos();

            if (_drInfoFilaEliminada.Table.Columns.Count == 2)
            {
                string strEliminarGarXPerfilXTarjeta = string.Format("DECLARE @codigo_tarjeta INT; SET @codigo_tarjeta = (SELECT cod_tarjeta FROM dbo.Tar_tarjeta WHERE num_tarjeta = {0}) DELETE FROM dbo.TAR_GARANTIAS_X_PERFIL_X_TARJETA WHERE cod_tarjeta = @codigo_tarjeta", numeroTarjeta);

                oBitacora.InsertarBitacora("TAR_GARANTIAS_X_PERFIL_X_TARJETA", strUsuario, strIP, null,
                                           3, 4, null, numeroTarjeta, strEliminarGarXPerfilXTarjeta, string.Empty,
                                           _drInfoFilaEliminada.Table.Columns[clsGarantiasXPerfil._observacion].ColumnName,
                                           _drInfoFilaEliminada[clsGarantiasXPerfil._observacion].ToString(),
                                           string.Empty);
            }/*fin del if (_drInfoFilaEliminada.Table.Columns.Count == 1)*/
            else
            {

                string strEliminarGarFiduXTarjeta = string.Format("DECLARE @codigo_tarjeta INT; SET @codigo_tarjeta = (SELECT cod_tarjeta FROM dbo.Tar_tarjeta WHERE num_tarjeta = {0}) DELETE FROM dbo.TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA WHERE cod_tarjeta = @codigo_tarjeta", numeroTarjeta);

                string strCedulaFiador = oTraductor.ObtenerCedulaFiadorGarFiduTar(
                    _drInfoFilaEliminada[clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria].ToString());

                if (_drInfoFilaEliminada != null)
                {
                    #region Garant�a Fiduciaria por Tarjeta

                    //foreach (DataRow _drInfoFilaEliminada in dsGarantiaFiduciariaXTarjeta.Tables[0].Rows)
                    //{
                    for (int nIndice = 0; nIndice < _drInfoFilaEliminada.Table.Columns.Count; nIndice++)
                    {
                        switch (_drInfoFilaEliminada.Table.Columns[nIndice].ColumnName)
                        {
                            case clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria: oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                                                           3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                                                           _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                                                                           strCedulaFiador,
                                                                                           string.Empty);
                                break;

                            case clsGarantiaFiduciariaTarjeta._consecutivoTarjeta: oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                                                           3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                                                           _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                                                                           numeroTarjeta,
                                                                                           string.Empty);
                                break;

                            case clsGarantiaFiduciariaTarjeta._codigoOperacionEspecial:
                                if (_drInfoFilaEliminada[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                {
                                    oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                       3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                       _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                       oTraductor.TraducirTipoOperacionEspecial(Convert.ToInt32(_drInfoFilaEliminada[nIndice, DataRowVersion.Current].ToString())),
                                       string.Empty);
                                }
                                else
                                {
                                    oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                       3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                       _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                       string.Empty,
                                       string.Empty);
                                }

                                break;

                            case clsGarantiaFiduciariaTarjeta._codigoTipoPersonaAcreedor:
                                if (_drInfoFilaEliminada[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                {
                                    oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                           3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                           _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                           oTraductor.TraducirTipoPersona(Convert.ToInt32(_drInfoFilaEliminada[nIndice, DataRowVersion.Current].ToString())),
                                           string.Empty);
                                }
                                else
                                {
                                    oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                           3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                           _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                           string.Empty,
                                           string.Empty);
                                }
                                break;

                            case clsGarantiaFiduciariaTarjeta._codigoTipoDocumentoLegal:
                                if (_drInfoFilaEliminada[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                {
                                    oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                               3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                               _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                               oTraductor.TraducirTipoDocumento(Convert.ToInt32(_drInfoFilaEliminada[nIndice, DataRowVersion.Current].ToString())),
                                               string.Empty);
                                }
                                else
                                {
                                    oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                               3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                               _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                               string.Empty,
                                               string.Empty);
                                }
                                break;

                            case clsGarantiaFiduciariaTarjeta._codigoTipoMitigador:
                                if (_drInfoFilaEliminada[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                {
                                    oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                   3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                   _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                                   oTraductor.TraducirTipoMitigador(Convert.ToInt32(_drInfoFilaEliminada[nIndice, DataRowVersion.Current].ToString())),
                                                   string.Empty);
                                }
                                else
                                {
                                    oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                  3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                  _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                                  string.Empty,
                                                  string.Empty);
                                }
                                break;

                            default: oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                      3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                      _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                      _drInfoFilaEliminada[nIndice, DataRowVersion.Current].ToString(),
                                      string.Empty);
                                break;
                        }

                    }
 
                    #endregion
                }
                else
                {
                    oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                        3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                        string.Empty, string.Empty, string.Empty);
                }

            }/*fin del else de if (cantidadColumnas == 1)*/

            #endregion
        }

        /// <summary>
        /// Registra en la bit�cora los cambios producidos por una inserci�n o modificaci�n en la tabla de
        /// TAR_GARANTIAS_x_PERFIL_X_TARJETA
        /// </summary>
        /// <param name="_usuario">
        /// Usuario que realiz� el cambio
        /// </param>
        /// <param name="_iP">
        /// N�mero IP de la m�quina de donde se realiz� el cambio
        /// </param>
        /// <param name="_numeroTarjeta">
        /// N�mero de tarjeta para la cual se realiz� el cambio
        /// </param>
        /// <param name="_codigoTipoGarantia">
        /// C�digo nuevo de garant�a que se aplic� a la tarjeta
        /// </param>
        /// <param name="_valorActual">
        /// Valor actual del campo modificado
        /// </param>
        /// <param name="mensaje">
        /// Tipo de mensaje obtenido del procedimiento almacenado para saber si es modificaci�n o inserci�n
        /// </param>
        /// <param name="_valorAnterior">
        /// Valor que pose�a el campo antes de realizar la modificaci�n
        /// </param>
        /// <param name="_codigoGarantiaAnterior">
        /// C�digo de garant�a que pose�a la tarjeta antes de la modificaci�n
        /// </param>
        private void InsertarBitacora(string _usuario, string _iP, string _numeroTarjeta, string _codigoTipoGarantia,
            string _valorActual, int mensaje, string _valorAnterior, string _codigoGarantiaAnterior, string[] _infoTarjeta)
        {
            Bitacora oBitacora = new Bitacora();
            TraductordeCodigos traductor = new TraductordeCodigos();

            #region Registro en bit�cora de la modificacion en Tar_Tarjeta

            if (!mensaje.Equals(1))
            {
                listaCampos = new string[] { clsTarjeta._entidadTarjeta,
                                             clsTarjeta._codigoTipoGarantia, _codigoTipoGarantia,
                                             clsTarjeta._numeroTarjeta, _numeroTarjeta};

                string strModificarTarjeta = string.Format("UPDATE dbo.{0} SET {1} = {2} WHERE {3} = '{4}'", listaCampos);

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, null,
                                           2, 4, null, _numeroTarjeta, strModificarTarjeta, string.Empty,
                                           clsTarjeta._codigoTipoGarantia,
                                           traductor.TraducirCodigoTipoGarantiaTarjeta(_codigoGarantiaAnterior),
                                           traductor.TraducirCodigoTipoGarantiaTarjeta(_codigoTipoGarantia));
            }

            #endregion Registro en bit�cora de la modificacion en Tar_Tarjeta

            if (mensaje.Equals(1))
            {
                listaCampos = new string[] { clsTarjeta._entidadTarjeta,
                                             clsTarjeta._cedulaDeudor, clsTarjeta._numeroTarjeta, clsTarjeta._codigoBin, clsTarjeta._codigoInternoSistar, clsTarjeta._codigoMoneda,
                                             clsTarjeta._codigoOficinaRegistra, clsTarjeta._codigoTipoGarantia, clsTarjeta._indicadorEstadoTarjeta,
                                             _infoTarjeta[0], _numeroTarjeta, _infoTarjeta[0], _infoTarjeta[2], _infoTarjeta[3], _infoTarjeta[4], _codigoTipoGarantia,
                                             clsGarantiasXPerfil._entidadGarantiaPerfilXTarjeta,
                                             clsGarantiasXPerfil._consecutivoTarjeta, clsGarantiasXPerfil._observacion,
                                             _valorActual};

                string strInsertarTarjeta = string.Format("INSERT INTO dbo.{0} ({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}) VALUES({9}, {10}, {11}, {12}, {13}, {14}, {15}, 'N') SET @codigo_tarjeta = SCOPE_IDENTITY(); INSERT INTO dbo.{16} ({17}, {18}) VALUES(@codigo_tarjeta, {19})", listaCampos);

                #region Tarjeta

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    clsTarjeta._cedulaDeudor, string.Empty, _infoTarjeta[0]);

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    clsTarjeta._numeroTarjeta, string.Empty, _numeroTarjeta);

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    clsTarjeta._codigoBin, string.Empty, _infoTarjeta[1]);

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    clsTarjeta._codigoInternoSistar, string.Empty, _infoTarjeta[2]);

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    clsTarjeta._codigoMoneda, string.Empty, 
                    traductor.TraducirTipoMoneda(Convert.ToInt32(_infoTarjeta[3])));

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    clsTarjeta._codigoOficinaRegistra, string.Empty, _infoTarjeta[4]);

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    clsTarjeta._codigoTipoGarantia, string.Empty, 
                    traductor.TraducirCodigoTipoGarantiaTarjeta(_codigoTipoGarantia));

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    clsTarjeta._indicadorEstadoTarjeta, string.Empty, traductor.TraducirCodigoEstadoTarjeta("N"));

                oBitacora.InsertarBitacora("TAR_GARANTIAS_x_PERFIL_X_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    clsGarantiasXPerfil._observacion, string.Empty, _valorActual);

                #endregion

            }
            else
                if (mensaje.Equals(2))
                {
                    string strInsertarGarantiaPerfil = "declare @codigo_tarjeta int; " +
                                                       "set @codigo_tarjeta = (select cod_tarjeta " +
                                                       "from dbo.Tar_tarjeta " +
                                                       "where num_tarjeta = " + _numeroTarjeta + ") " +
                                                       "insert into dbo.TAR_GARANTIAS_x_PERFIL_X_TARJETA( " +
                                                       "cod_tarjeta, observaciones) " +
                                                       "values( @codigo_tarjeta, " + _valorActual + " )";

                    oBitacora.InsertarBitacora("TAR_GARANTIAS_x_PERFIL_X_TARJETA", _usuario, _iP, null,
                                               1, 4, null, _numeroTarjeta, strInsertarGarantiaPerfil, string.Empty,
                                               clsGarantiasXPerfil._observacion,
                                               _valorAnterior, _valorActual);
                }
                else
                    if (mensaje.Equals(3))
                    {
                        string strModificarGarantiaPerfil = "declare @codigo_tarjeta int; " +
                                                            "set @codigo_tarjeta = (select cod_tarjeta " +
                                                            "from dbo.Tar_tarjeta " +
                                                            "where num_tarjeta = " + _numeroTarjeta + ") " +
                                                            "update dbo.TAR_GARANTIAS_x_PERFIL_X_TARJETA " +
                                                            "set observaciones = " + _valorActual + " " +
                                                            "where cod_tarjeta = @codigo_tarjeta";

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_x_PERFIL_X_TARJETA", _usuario, _iP, null,
                                                   2, 4, null, _numeroTarjeta, strModificarGarantiaPerfil, string.Empty,
                                                   clsGarantiasXPerfil._observacion,
                                                   _valorAnterior, _valorActual);
                    }

        }/*fin del m�todo*/


        #endregion
    }
}
