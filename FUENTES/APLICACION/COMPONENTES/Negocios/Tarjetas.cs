using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;
using System.Configuration;

namespace BCRGARANTIAS.Negocios
{
    public class Tarjetas
    {
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

            try
            {
                if ((strEstadoTarjeta != string.Empty) && (strNumeroTarjeta != string.Empty))
                {
					using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
					{
						SqlCommand oComando = new SqlCommand("pa_ModificarEstadoTarjeta", oConexion);
						DataSet dsData = new DataSet();
						SqlParameter oParam = new SqlParameter();

						long nNumeroTarjeta = 0;

						if (Int64.TryParse(strNumeroTarjeta, out nNumeroTarjeta))
						{
							//nNumeroTarjeta = Convert.ToInt64(strNumeroTarjeta);
							strNumeroTarjeta = nNumeroTarjeta.ToString();
						}

						#region Obtener los datos de la BD antes de ser actualizados

						DataSet dsTarjeta = new DataSet();

						//Se obtienen los datos antes de ser modificados, para luego insertalos en la bit�cora
						string strConsultaTarjeta = "select " +
								 ContenedorTarjeta.COD_ESTADO_TARJETA + "," +
								 ContenedorTarjeta.COD_TIPO_GARANTIA +
								 " from " + ContenedorTarjeta.NOMBRE_ENTIDAD +
								 " where " + ContenedorTarjeta.NUM_TARJETA + " = '" + strNumeroTarjeta + "'";

						dsTarjeta = AccesoBD.ejecutarConsulta(strConsultaTarjeta);

						#endregion

						//Declara las propiedades del comando
						oComando.CommandType = CommandType.StoredProcedure;

						//Agrega los parametros
						oComando.Parameters.AddWithValue("@strNumeroTarjeta", strNumeroTarjeta);
						oComando.Parameters.AddWithValue("@strEstadoTarjeta", strEstadoTarjeta);

						//Abre la conexion
						oConexion.Open();

						//Ejecuta el comando
						nCodigoRetornado = Convert.ToInt32(oComando.ExecuteScalar().ToString());

						if (nCodigoRetornado == 0)
						{
							#region Inserci�n en Bit�cora

							TraductordeCodigos oTraductor = new TraductordeCodigos();

							string strModificarTarjeta = "UPDATE TAR_TARJETA SET cod_estado_tarjeta = '" + strEstadoTarjeta +
								"' WHERE num_tarjeta = '" + strNumeroTarjeta + "'";


							if ((dsTarjeta != null) && (dsTarjeta.Tables.Count > 0) && (dsTarjeta.Tables[0].Rows.Count > 0))
							{
								if (nTipoGarantia == -1)
								{
									if (!dsTarjeta.Tables[0].Rows[0].IsNull(ContenedorTarjeta.COD_TIPO_GARANTIA))
									{
										strTipoGarantia = dsTarjeta.Tables[0].Rows[0][ContenedorTarjeta.COD_TIPO_GARANTIA].ToString();

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

								if (!dsTarjeta.Tables[0].Rows[0].IsNull(ContenedorTarjeta.COD_ESTADO_TARJETA))
								{
									string strTipoEstadoObt = dsTarjeta.Tables[0].Rows[0][ContenedorTarjeta.COD_ESTADO_TARJETA].ToString();

									if (strTipoEstadoObt.CompareTo(strEstadoTarjeta) != 0)
									{

										oBitacora.InsertarBitacora(ContenedorTarjeta.NOMBRE_ENTIDAD, "SISTAR", "-", null,
										   2, nTipoGarantia, string.Empty, strNumeroTarjeta, strModificarTarjeta, string.Empty,
										   ContenedorTarjeta.COD_ESTADO_TARJETA,
										   oTraductor.TraducirCodigoEstadoTarjeta(strTipoEstadoObt),
										   oTraductor.TraducirCodigoEstadoTarjeta(strEstadoTarjeta));
									}
								}
								else
								{

									oBitacora.InsertarBitacora(ContenedorTarjeta.NOMBRE_ENTIDAD, "SISTAR", "-", null,
										   2, nTipoGarantia, string.Empty, strNumeroTarjeta, strModificarTarjeta, string.Empty,
										   ContenedorTarjeta.COD_ESTADO_TARJETA,
										   string.Empty,
										   oTraductor.TraducirCodigoEstadoTarjeta(strEstadoTarjeta));
								}
							}
							else
							{
								if (nTipoGarantia != -1)
								{
									oBitacora.InsertarBitacora(ContenedorTarjeta.NOMBRE_ENTIDAD, "SISTAR", "-", null,
										2, nTipoGarantia, string.Empty, strNumeroTarjeta, strModificarTarjeta, string.Empty,
										string.Empty,
										string.Empty,
										string.Empty);
								}
								else
								{
									oBitacora.InsertarBitacora(ContenedorTarjeta.NOMBRE_ENTIDAD, "SISTAR", "-", null,
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
							oBitacora.InsertarBitacora(ContenedorTarjeta.NOMBRE_ENTIDAD, "SISTAR", "-", null,
							   2, nTipoGarantia, string.Empty, strNumeroTarjeta, "Error al cambiar estado: " + nCodigoRetornado.ToString(), string.Empty,
							   ContenedorTarjeta.COD_ESTADO_TARJETA,
							   string.Empty,
							   strEstadoTarjeta);
						}
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
				using (OleDbConnection oleDbConnection1 = AccesoBD.ObtenerStringConexion())
				{
					OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cod_estado_tarjeta FROM " + ContenedorTarjeta.NOMBRE_ENTIDAD + " WHERE num_tarjeta = '" + strNumeroTarjeta + "'", oleDbConnection1);
					cmdConsulta.Fill(dsDatos, "Tarjeta");

					if ((dsDatos.Tables["Tarjeta"] != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Tarjeta"].Rows.Count > 0))
					{
						if (!dsDatos.Tables["Tarjeta"].Rows[0].IsNull(ContenedorTarjeta.COD_ESTADO_TARJETA))
						{
							strEstadoActual = dsDatos.Tables["Tarjeta"].Rows[0][ContenedorTarjeta.COD_ESTADO_TARJETA].ToString();
						}
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
				using (OleDbConnection oleDbConnection1 = AccesoBD.ObtenerStringConexion())
				{
					OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT bin FROM TAR_BIN_SISTAR WHERE bin = '" + nBin + "'", oleDbConnection1);
					cmdConsulta.Fill(dsDatos, "Tarjeta");

					if ((dsDatos.Tables["Tarjeta"] != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Tarjeta"].Rows.Count > 0))
					{
						if (!dsDatos.Tables["Tarjeta"].Rows[0].IsNull("bin"))
						{
							bPerteneceASistar = true;
						}
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
                        SqlCommand _cmdObservaciones = new SqlCommand("declare @codigo_tarjeta int; " +
                                                        "set @codigo_tarjeta = (select cod_tarjeta " +
                                                        "from dbo.Tar_tarjeta " +
                                                        "where num_tarjeta " + " = " + _numeroTarjeta + ") " +
                                                        "select observaciones " +
                                                        "from dbo.TAR_GARANTIAS_X_PERFIL_X_TARJETA " +
                                                        "where cod_tarjeta = @codigo_tarjeta");

                        /*se asigna la conexi�n*/
                        _cmdObservaciones.Connection = oConexion;

                        /*indica al sqlCommand el tiempo que puede durar la ejecuci�n*/
                        _cmdObservaciones.CommandTimeout = 120;


                        string _observacionesAnteriores = string.Empty;

                        #endregion Selecciona el valor del campo observaciones

                        #region Selecciona el valor del campo cod_tipo_garantia de la tabla tar_tarjeta

                        /*declara el sqlCommand que se utilizar� para la consulta*/
                        SqlCommand _cmdCodigoGarantia = new SqlCommand("select cod_tipo_garantia " +
                                                        "from dbo.TAR_TARJETA " +
                                                        "where num_tarjeta = " + _numeroTarjeta);

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
                string strEliminarGarXPerfilXTarjeta = "declare @codigo_tarjeta int; " +
                                                       "set @codigo_tarjeta = (select cod_tarjeta " +
                                                       "from dbo.Tar_tarjeta " +
                                                       "where num_tarjeta = " + numeroTarjeta + ") " +
                                                       "delete TAR_GARANTIAS_X_PERFIL_X_TARJETA " +
                                                       "where cod_tarjeta = @codigo_tarjeta";

                oBitacora.InsertarBitacora("TAR_GARANTIAS_X_PERFIL_X_TARJETA", strUsuario, strIP, null,
                                           3, 4, null, numeroTarjeta, strEliminarGarXPerfilXTarjeta, string.Empty,
                                           _drInfoFilaEliminada.Table.Columns[ContenedorGarantias_x_perfil_x_tarjeta.OBSERVACIONES].ColumnName,
                                           _drInfoFilaEliminada[ContenedorGarantias_x_perfil_x_tarjeta.OBSERVACIONES].ToString(),
                                           string.Empty);
            }/*fin del if (_drInfoFilaEliminada.Table.Columns.Count == 1)*/
            else
            {

                string strEliminarGarFiduXTarjeta = "declare @codigo_tarjeta int; " +
                                                    "set @codigo_tarjeta = (select cod_tarjeta " +
                                                    "from dbo.Tar_tarjeta " +
                                                    "where num_tarjeta = " + numeroTarjeta + ") " +
                                                    "delete TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA " +
                                                    "where cod_tarjeta = @codigo_tarjeta";


                string strCedulaFiador = oTraductor.ObtenerCedulaFiadorGarFiduTar(
                    _drInfoFilaEliminada[ContenedorGarantias_fiduciarias_x_tarjeta.COD_GARANTIA_FIDUCIARIA].ToString());

                //string strCedulaDeudor = oTraductor.ObtenerCedulaDeudorTarjeta(nTarjeta.ToString());

                //if ((dsGarantiaFiduciariaXTarjeta != null) && (dsGarantiaFiduciariaXTarjeta.Tables.Count > 0) && (dsGarantiaFiduciariaXTarjeta.Tables[0].Rows.Count > 0))
                if (_drInfoFilaEliminada != null)
                {
                    #region Garant�a Fiduciaria por Tarjeta

                    //foreach (DataRow _drInfoFilaEliminada in dsGarantiaFiduciariaXTarjeta.Tables[0].Rows)
                    //{
                    for (int nIndice = 0; nIndice < _drInfoFilaEliminada.Table.Columns.Count; nIndice++)
                    {
                        switch (_drInfoFilaEliminada.Table.Columns[nIndice].ColumnName)
                        {
                            case ContenedorGarantias_fiduciarias_x_tarjeta.COD_GARANTIA_FIDUCIARIA: oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                                                           3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                                                           _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                                                                           strCedulaFiador,
                                                                                           string.Empty);
                                break;

                            case ContenedorGarantias_fiduciarias_x_tarjeta.COD_TARJETA: oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                                                           3, 1, strCedulaFiador, numeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                                                           _drInfoFilaEliminada.Table.Columns[nIndice].ColumnName,
                                                                                           numeroTarjeta,
                                                                                           string.Empty);
                                break;

                            case ContenedorGarantias_fiduciarias_x_tarjeta.COD_OPERACION_ESPECIAL:
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

                            case ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_ACREEDOR:
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

                            case ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_DOCUMENTO_LEGAL:
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

                            case ContenedorGarantias_fiduciarias_x_tarjeta.COD_TIPO_MITIGADOR:
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
                    //}

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
                string strModificarTarjeta = "update dbo.TAR_TARJETA " +
                                             "set cod_tipo_garantia = " + _codigoTipoGarantia + " " +
                                             "where num_tarjeta = " + _numeroTarjeta;

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, null,
                                           2, 4, null, _numeroTarjeta, strModificarTarjeta, string.Empty,
                                           ContenedorTarjeta.COD_TIPO_GARANTIA,
                                           traductor.TraducirCodigoTipoGarantiaTarjeta(_codigoGarantiaAnterior),
                                           traductor.TraducirCodigoTipoGarantiaTarjeta(_codigoTipoGarantia));
            }

            #endregion Registro en bit�cora de la modificacion en Tar_Tarjeta

            if (mensaje.Equals(1))
            {
                string strInsertarTarjeta = "insert into tar_tarjeta (cedula_deudor, num_tarjeta, cod_bin, " +
                                            "cod_interno_sistar, cod_moneda, cod_oficina_registra, " +
                                            "@cod_tipo_garantia, cod_estado_tarjeta) " +
                                            "values (" + _infoTarjeta[0] + ", " + _numeroTarjeta + ", " + _infoTarjeta[0] + ", " +
                                            _infoTarjeta[2] + ", " + _infoTarjeta[3] + ", " + _infoTarjeta[4] + ", " +
                                            _codigoTipoGarantia + ", 'N') " +
                                            "set @codigo_tarjeta = scope_identity(); " +
                                            "insert into dbo.TAR_GARANTIAS_x_PERFIL_X_TARJETA (cod_tarjeta, observaciones) " +
                                            "values(@codigo_tarjeta, " + _valorActual + ")";

                #region Tarjeta

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    ContenedorTarjeta.CEDULA_DEUDOR, string.Empty, _infoTarjeta[0]);

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    ContenedorTarjeta.NUM_TARJETA, string.Empty, _numeroTarjeta);

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    ContenedorTarjeta.COD_BIN, string.Empty, _infoTarjeta[1]);

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    ContenedorTarjeta.COD_INTERNO_SISTAR, string.Empty, _infoTarjeta[2]);

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    ContenedorTarjeta.COD_MONEDA, string.Empty, 
                    traductor.TraducirTipoMoneda(Convert.ToInt32(_infoTarjeta[3])));

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    ContenedorTarjeta.COD_OFICINA_REGISTRA, string.Empty, _infoTarjeta[4]);

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    ContenedorTarjeta.COD_TIPO_GARANTIA, string.Empty, 
                    traductor.TraducirCodigoTipoGarantiaTarjeta(_codigoTipoGarantia));

                oBitacora.InsertarBitacora("TAR_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    ContenedorTarjeta.COD_ESTADO_TARJETA, string.Empty, traductor.TraducirCodigoEstadoTarjeta("N"));

                oBitacora.InsertarBitacora("TAR_GARANTIAS_x_PERFIL_X_TARJETA", _usuario, _iP, Convert.ToInt32(_infoTarjeta[4]),
                    1, 4, "-", _numeroTarjeta, strInsertarTarjeta, string.Empty,
                    ContenedorGarantias_x_perfil_x_tarjeta.OBSERVACIONES, string.Empty, _valorActual);

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
                                               ContenedorGarantias_x_perfil_x_tarjeta.OBSERVACIONES,
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
                                                   ContenedorGarantias_x_perfil_x_tarjeta.OBSERVACIONES,
                                                   _valorAnterior, _valorActual);
                    }

        }/*fin del m�todo*/


        #endregion
    }
}
