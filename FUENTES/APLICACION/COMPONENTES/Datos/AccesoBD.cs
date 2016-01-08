using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Xml;
using System.Collections;
using System.Text;
using System.Data.OleDb;

using BCR.Seguridad.Cryptography;

namespace BCRGARANTIAS.Datos
{
    /// <summary>
    /// Summary description for AccesoBD.
    /// </summary>
    public class AccesoBD
    {
        /// <summary>
        /// Tiempo de espera que transcurre al ejecutar una sentencia a nivel de base de datos. Es dado en segundos.
        /// </summary>
        private const int tiempo_Espera_Ejecucion = 300;

        /// <summary>
        /// Tiempo de espera parametrizado para la ejecución de un proceso
        /// </summary>
        public static int TiempoEsperaEjecucion
        {
            get
            {
                string tiempoParametrizado = ((ConfigurationManager.AppSettings["TIEMPO_ESPERA_EJECUCION"] != null) ? ConfigurationManager.AppSettings["TIEMPO_ESPERA_EJECUCION"] : string.Empty);
                int tiempoRetornado = ((tiempoParametrizado.Length > 0) ? (int.Parse(tiempoParametrizado)) : tiempo_Espera_Ejecucion);
                return tiempoRetornado;
            }
        }

        /// <summary>
        /// Metodo para obtener el string de conexión de la base de datos
        /// </summary>
        /// <returns>System.Data.OleDb.OleDbConnection</returns>
        public static OleDbConnection ObtenerStringConexion()
        {
            OleDbConnection oConexion = new OleDbConnection();
            TripleDES oSeguridad = new TripleDES();

            try
            {
                string strCadenaConexion = ConfigurationManager.ConnectionStrings["Sql_Server_OLDB"].ConnectionString;
                oConexion.ConnectionString = oSeguridad.Decrypt(strCadenaConexion);
                oConexion.Open();
            }
            catch
            {
                oConexion = null;
            }
            return oConexion;
        }

        /// <summary>
        /// Metodo para obtener el string de conexión de la base de datos
        /// </summary>
        public static string ObtenerConnectionString()
        {
           TripleDES oSeguridad = new TripleDES();

            string strConnectionString = ConfigurationManager.ConnectionStrings["Sql_Server"].ConnectionString;

            return oSeguridad.Decrypt(strConnectionString);
        }

        /// <summary>
        /// Método privado que ejecuta una consulta en la base de datos
        /// </summary>
        /// <param name="sqlQuery">consulta SQL</param>
        /// <returns>System.Data.DataSet</returns>
        private static DataSet consultarBD(string sqlQuery)
        {
            DataSet myDS = new DataSet();   //se carga el resultado de la consulta

            using (SqlConnection oConexion = new SqlConnection(ObtenerConnectionString()))
            {
                 using (SqlCommand oComando = new SqlCommand(sqlQuery, oConexion))
                {
                    oComando.CommandTimeout = TiempoEsperaEjecucion;
                    oComando.CommandText = sqlQuery;
                    oComando.Connection.Open();

                    if (sqlQuery.ToLower().StartsWith("select"))
                    {
                        using (SqlDataAdapter oDataAdapter = new SqlDataAdapter())
                        {
                            oDataAdapter.SelectCommand = oComando;
                            oDataAdapter.SelectCommand.Connection = oConexion;
                            oDataAdapter.Fill(myDS, "resultado");
                            oComando.Connection.Close();
                            oComando.Connection.Dispose();
                            return myDS;
                        }
                    }
                    else
                    {
                        //es un update , insert o delete
                        oComando.ExecuteNonQuery();
                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                        return null;
                    }
                }
            }
        }

        /// <summary>
        /// Método público que ejecuta una consulta en la base de datos
        /// </summary>
        /// <param name="sqlQuery">consulta SQL</param>
        /// <returns>System.Data.DataSet</returns>
        public static DataSet ejecutarConsulta(string sqlQuery)
        {
            return consultarBD(sqlQuery);
        }

        public static SqlConnection obtenerConexion()
        {
            SqlConnection oconection = new SqlConnection(ObtenerConnectionString());

            if (oconection.State != ConnectionState.Open)
            {
                oconection.Open();
            }

            return oconection;
        }

        #region [ExecteScalar]

        public static object ExecuteScalar(CommandType commandType, string sqlInstruction, SqlParameter[] parameters)
        {
            object vnRetorno = null;

            using (SqlConnection oConexion = obtenerConexion())
            {
                using (SqlCommand oComando = new SqlCommand(sqlInstruction, oConexion))
                {
                    oComando.CommandType = commandType;
                    oComando.CommandTimeout = TiempoEsperaEjecucion;

                    AttachParameters(oComando, parameters);

                    try
                    {
                        vnRetorno = oComando.ExecuteScalar();
                        oComando.Parameters.Clear();
                    }
                    catch (Exception)
                    {

                        throw;
                    }
                    finally
                    {
                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }
            }

            return vnRetorno;
        }

        public static object ExecuteScalar(CommandType commandType, string sqlInstruction, int tiempoEspera, SqlParameter[] parameters)
        {
            object vnRetorno = null;

            using (SqlConnection oConexion = obtenerConexion())
            {
                using (SqlCommand oComando = new SqlCommand(sqlInstruction, oConexion))
                {
                    oComando.CommandType = commandType;
                    oComando.CommandTimeout = tiempoEspera;

                    AttachParameters(oComando, parameters);

                    try
                    {
                        vnRetorno = oComando.ExecuteScalar();
                        oComando.Parameters.Clear();
                    }
                    catch (Exception)
                    {

                        throw;
                    }
                    finally
                    {
                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }
            }

            return vnRetorno;
        }

        #endregion [ExecteScalar]

        #region [ ExecuteNonQuery ]
        public static int ExecuteNonQuery(string tprocedure, SqlParameter[] parameters)
        {
            return ExecuteNonQuery(CommandType.StoredProcedure, tprocedure, parameters);
        }

        public static int ExecuteNonQuery(string tprocedure, SqlParameter[] parameters, out SqlParameter[] parametersOut)
        {
            return ExecuteNonQuery(CommandType.StoredProcedure, tprocedure, parameters, out parametersOut);
        }

        public static int ExecuteNonQuery(CommandType commandType, string sqlInstruction, SqlParameter[] parameters)
        {
            int vnRetorno = 0;
            using (SqlConnection oConexion = obtenerConexion())
            {
                using (SqlCommand oComando = new SqlCommand(sqlInstruction, oConexion))
                {
                    oComando.CommandType = commandType;
                    oComando.CommandTimeout = TiempoEsperaEjecucion;

                    AttachParameters(oComando, parameters);

                    try
                    {
                        vnRetorno = oComando.ExecuteNonQuery();
                        oComando.Parameters.Clear();
                    }
                    catch (Exception)
                    {

                        throw;
                    }
                    finally
                    {
                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }
            }

            return vnRetorno;
        }

        public static int ExecuteNonQuery(CommandType commandType, string sqlInstruction, int tiempoEspera, SqlParameter[] parameters)
        {
            int vnRetorno = 0;

            using (SqlConnection oConexion = obtenerConexion())
            {
                using (SqlCommand oComando = new SqlCommand(sqlInstruction, oConexion))
                {
                    oComando.CommandType = commandType;
                    oComando.CommandTimeout = tiempoEspera;

                    AttachParameters(oComando, parameters);

                    try
                    {
                        vnRetorno = oComando.ExecuteNonQuery();
                        oComando.Parameters.Clear();
                    }
                    catch (Exception)
                    {

                        throw;
                    }
                    finally
                    {
                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }
            }

            return vnRetorno;
        }

        public static int ExecuteNonQuery(CommandType commandType, string sqlInstruction, SqlParameter[] parameters, out SqlParameter[] parametersOut)
        {
            int vnRetorno = 0;

            using (SqlConnection oConexion = obtenerConexion())
            {
                using (SqlCommand oComando = new SqlCommand(sqlInstruction, oConexion))
                {
                    oComando.CommandType = commandType;
                    oComando.CommandTimeout = TiempoEsperaEjecucion;

                    AttachParameters(oComando, parameters);

                    try
                    {
                        vnRetorno = oComando.ExecuteNonQuery();

                        int nParametrosSalida = 0;

                        foreach (SqlParameter sqlParam in oComando.Parameters)
                        {
                            if ((sqlParam.Direction == ParameterDirection.Output) || (sqlParam.Direction == ParameterDirection.InputOutput))
                            {
                                nParametrosSalida++;
                            }
                        }

                        nParametrosSalida = (nParametrosSalida == 0) ? 1 : nParametrosSalida;

                        parametersOut = new SqlParameter[nParametrosSalida];

                        nParametrosSalida = 0;

                        foreach (SqlParameter sqlParam in oComando.Parameters)
                        {
                            if ((sqlParam.Direction == ParameterDirection.Output) || (sqlParam.Direction == ParameterDirection.InputOutput))
                            {
                                parametersOut[nParametrosSalida] = sqlParam;
                            }
                        }

                        oComando.Parameters.Clear();
                    }
                    catch (Exception)
                    {
                        throw;
                    }
                    finally
                    {
                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }
            }

            return vnRetorno;
        }

        #endregion

        #region [ ExecuteDataSet ]

        public static DataSet ExecuteDataSet(
                CommandType commandType,
                string sqlInstruction,
                SqlParameter[] parameters)
        {
            DataSet dsDatos = new DataSet(); 

            using (SqlConnection oConexion = obtenerConexion())
            {
                using (SqlCommand oComando = new SqlCommand(sqlInstruction, oConexion))
                {
                    oComando.CommandType = commandType;
                    oComando.CommandTimeout = TiempoEsperaEjecucion;
                    AttachParameters(oComando, parameters);

                    using (SqlDataAdapter oDataAdapter = new SqlDataAdapter(oComando))
                    {
                        try
                        {
                            oDataAdapter.Fill(dsDatos, "Datos");
                            oComando.Parameters.Clear();
                        }
                        catch (Exception)
                        {

                            throw;
                        }
                        finally
                        {
                            oComando.Connection.Close();
                            oComando.Connection.Dispose();
                        }
                    }
                }                
            }


            return dsDatos;
        }

        public static DataSet ExecuteDataSet(CommandType commandType, string sqlInstruction, SqlParameter[] parameters,int tiempoEspera)
        {
            DataSet dsDatos = new DataSet();

            using (SqlConnection oConexion = obtenerConexion())
            {
                using (SqlCommand oComando = new SqlCommand(sqlInstruction, oConexion))
                {
                    oComando.CommandType = commandType;
                    oComando.CommandTimeout = tiempoEspera;
                    AttachParameters(oComando, parameters);

                    using (SqlDataAdapter oDataAdapter = new SqlDataAdapter(oComando))
                    {
                        try
                        {
                            oDataAdapter.Fill(dsDatos, "Datos");
                            oComando.Parameters.Clear();
                        }
                        catch (Exception)
                        {

                            throw;
                        }
                        finally
                        {
                            oComando.Connection.Close();
                            oComando.Connection.Dispose();
                        }
                    }
                }
            }


            return dsDatos;
        }


        #endregion

        #region [ ExecuteXmlReader ]
        /// <summary>
        /// Execute a SqlCommand (that returns a resultset and takes no parameters) against the provided SqlConnection. 
        /// </summary>
        /// <remarks>
        /// e.g.:  
        ///  XmlReader r = ExecuteXmlReader(conn, CommandType.StoredProcedure, "GetOrders");
        /// </remarks>
        /// <param name="connection">A valid SqlConnection</param>
        /// <param name="commandType">The CommandType (stored procedure, text, etc.)</param>
        /// <param name="commandText">The stored procedure name or T-SQL command using "FOR XML AUTO"</param>
        /// <returns>An XmlReader containing the resultset generated by the command</returns>
        public static XmlReader ExecuteXmlReader(SqlConnection connection, CommandType commandType, string commandText)
        {
            // Pass through the call providing null for the set of SqlParameters
            return ExecuteXmlReader(connection, commandType, commandText, (SqlParameter[])null);
        }

        /// <summary>
        /// Execute a SqlCommand (that returns a resultset) against the specified SqlConnection 
        /// using the provided parameters.
        /// </summary>
        /// <remarks>
        /// e.g.:  
        ///  XmlReader r = ExecuteXmlReader(conn, CommandType.StoredProcedure, "GetOrders", new SqlParameter("@prodid", 24));
        /// </remarks>
        /// <param name="connection">A valid SqlConnection</param>
        /// <param name="commandType">The CommandType (stored procedure, text, etc.)</param>
        /// <param name="commandText">The stored procedure name or T-SQL command using "FOR XML AUTO"</param>
        /// <param name="commandParameters">An array of SqlParamters used to execute the command</param>
        /// <returns>An XmlReader containing the resultset generated by the command</returns>
        public static XmlReader ExecuteXmlReader(SqlConnection connection, CommandType commandType, string commandText, params SqlParameter[] commandParameters)
        {
            if (connection == null) throw new ArgumentNullException("connection");

            bool mustCloseConnection = false;
            // Create a command and prepare it for execution
            SqlCommand cmd = new SqlCommand();
            try
            {
                PrepareCommand(cmd, connection, (SqlTransaction)null, commandType, commandText, commandParameters, out mustCloseConnection);

                // Create the DataAdapter & DataSet
                XmlReader retval = cmd.ExecuteXmlReader();

                // Detach the SqlParameters from the command object, so they can be used again
                cmd.Parameters.Clear();

                return retval;
            }
            catch
            {
                if (mustCloseConnection)
                    connection.Close();
                throw;
            }
        }

        /// <summary>
        /// Execute a SqlCommand (that returns a resultset) against the specified SqlConnection 
        /// using the provided parameters.
        /// </summary>
        /// <remarks>
        /// e.g.:  
        ///  XmlReader r = ExecuteXmlReader(conn, CommandType.StoredProcedure, "GetOrders", new SqlParameter("@prodid", 24));
        /// </remarks>
        /// <param name="connection">A valid SqlConnection</param>
        /// <param name="commandType">The CommandType (stored procedure, text, etc.)</param>
        /// <param name="commandText">The stored procedure name or T-SQL command using "FOR XML AUTO"</param>
        /// <param name="commandParameters">An array of SqlParamters used to execute the command</param>
        /// <param name="tiempoEspera">Tiempo de espera de ejecución del comando, 0 = Infinito</param>
        /// <returns>An XmlReader containing the resultset generated by the command</returns>
        public static XmlReader ExecuteXmlReader(SqlConnection connection, CommandType commandType, string commandText, int tiempoEspera, params SqlParameter[] commandParameters)
        {
            if (connection == null) throw new ArgumentNullException("connection");

            bool mustCloseConnection = false;
            // Create a command and prepare it for execution
            SqlCommand cmd = new SqlCommand();
            try
            {
                PrepareCommand(cmd, connection, (SqlTransaction)null, commandType, commandText, commandParameters, out mustCloseConnection);

                cmd.CommandTimeout = tiempoEspera;

                // Create the DataAdapter & DataSet
                XmlReader retval = cmd.ExecuteXmlReader();

                // Detach the SqlParameters from the command object, so they can be used again
                cmd.Parameters.Clear();

                return retval;
            }
            catch
            {
                if (mustCloseConnection)
                    connection.Close();
                throw;
            }
        }

        /// <summary>
        /// Execute a SqlCommand (that returns a resultset) against the specified SqlConnection 
        /// using the provided parameters.
        /// </summary>
        /// <remarks>
        /// e.g.:  
        ///  XmlReader r = ExecuteXmlReader(conn, CommandType.StoredProcedure, "GetOrders", new SqlParameter("@prodid", 24));
        /// </remarks>
        /// <param name="connection">A valid SqlConnection</param>
        /// <param name="commandType">The CommandType (stored procedure, text, etc.)</param>
        /// <param name="commandText">The stored procedure name or T-SQL command using "FOR XML AUTO"</param>
        /// <param name="commandParameters">An array of SqlParamters used to execute the command</param>
        /// <returns>An XmlReader containing the resultset generated by the command</returns>
        public static string ExecuteXmlReader(SqlConnection connection, CommandType commandType, string commandText, out SqlParameter[] commandOutputParameters, params SqlParameter[] commandParameters)
        {
            if (connection == null) throw new ArgumentNullException("connection");

            string xmlRetorno = string.Empty;

            bool mustCloseConnection = false;
            // Create a command and prepare it for execution
            SqlCommand cmd = new SqlCommand();
            try
            {
                PrepareCommand(cmd, connection, (SqlTransaction)null, commandType, commandText, commandParameters, out mustCloseConnection);

                // Create the DataAdapter & DataSet
                XmlReader retval = cmd.ExecuteXmlReader();

                if (retval != null)
                {
                    StringBuilder sb = new StringBuilder();

                    while (retval.Read())
                    {
                        sb.AppendLine(retval.ReadOuterXml());
                    }

                    xmlRetorno = sb.ToString();
                }

                retval.Close();

                if (cmd.Connection != null)
                {
                    cmd.Connection.Close();
                }

                int nParametrosSalida = 0;

                foreach (SqlParameter sqlParam in cmd.Parameters)
                {
                    if ((sqlParam.Direction == ParameterDirection.Output) || (sqlParam.Direction == ParameterDirection.InputOutput))
                    {
                        nParametrosSalida++;
                    }
                }

                nParametrosSalida = (nParametrosSalida == 0) ? 1 : nParametrosSalida;

                commandOutputParameters = new SqlParameter[nParametrosSalida];

                nParametrosSalida = 0;

                foreach (SqlParameter sqlParam in cmd.Parameters)
                {
                    if ((sqlParam.Direction == ParameterDirection.Output) || (sqlParam.Direction == ParameterDirection.InputOutput))
                    {
                        commandOutputParameters[nParametrosSalida] = sqlParam;
                        nParametrosSalida++;
                    }
                }

                // Detach the SqlParameters from the command object, so they can be used again
                cmd.Parameters.Clear();

                return xmlRetorno;
            }
            catch
            {
                if (mustCloseConnection)
                    connection.Close();
                throw;
            }
        }

        /// <summary>
        /// Execute a SqlCommand (that returns a resultset) against the specified SqlTransaction
        /// using the provided parameters.
        /// </summary>
        /// <remarks>
        /// e.g.:  
        ///  XmlReader r = ExecuteXmlReader(trans, CommandType.StoredProcedure, "GetOrders", new SqlParameter("@prodid", 24));
        /// </remarks>
        /// <param name="transaction">A valid SqlTransaction</param>
        /// <param name="commandType">The CommandType (stored procedure, text, etc.)</param>
        /// <param name="commandText">The stored procedure name or T-SQL command using "FOR XML AUTO"</param>
        /// <param name="commandParameters">An array of SqlParamters used to execute the command</param>
        /// <returns>An XmlReader containing the resultset generated by the command</returns>
        public static string ExecuteXmlReader(SqlTransaction transaction, CommandType commandType, string commandText, out SqlParameter[] commandOutputParameters, params SqlParameter[] commandParameters)
        {
            if (transaction == null) throw new ArgumentNullException("transaction");
            if (transaction != null && transaction.Connection == null) throw new ArgumentException("The transaction was rollbacked or commited, please provide an open transaction.", "transaction");

            // Create a command and prepare it for execution
            SqlCommand cmd = new SqlCommand();
            bool mustCloseConnection = false;
            string xmlRetorno = string.Empty;

            PrepareCommand(cmd, transaction.Connection, transaction, commandType, commandText, commandParameters, out mustCloseConnection);

            // Create the DataAdapter & DataSet
            XmlReader retval = cmd.ExecuteXmlReader();

            if (retval != null)
            {
                StringBuilder sb = new StringBuilder();

                while (retval.Read())
                {
                    sb.AppendLine(retval.ReadOuterXml());
                }

                xmlRetorno = sb.ToString();
            }

            retval.Close();

            if (cmd.Connection != null)
            {
                cmd.Connection.Close();
            }

            cmd.Connection.Close();

            int nParametrosSalida = 0;

            foreach (SqlParameter sqlParam in cmd.Parameters)
            {
                if ((sqlParam.Direction == ParameterDirection.Output) || (sqlParam.Direction == ParameterDirection.InputOutput))
                {
                    nParametrosSalida++;
                }
            }

            nParametrosSalida = (nParametrosSalida == 0) ? 1 : nParametrosSalida;

            commandOutputParameters = new SqlParameter[nParametrosSalida];

            nParametrosSalida = 0;

            foreach (SqlParameter sqlParam in cmd.Parameters)
            {
                if ((sqlParam.Direction == ParameterDirection.Output) || (sqlParam.Direction == ParameterDirection.InputOutput))
                {
                    commandOutputParameters[nParametrosSalida] = sqlParam;
                    nParametrosSalida++;
                }
            }

            // Detach the SqlParameters from the command object, so they can be used again
            cmd.Parameters.Clear();

            return xmlRetorno;
        }

        /// <summary>
        /// Execute a stored procedure via a SqlCommand (that returns a resultset) against the specified SqlConnection 
        /// using the provided parameter values.  This method will query the database to discover the parameters for the 
        /// stored procedure (the first time each stored procedure is called), and assign the values based on parameter order.
        /// </summary>
        /// <remarks>
        /// This method provides no access to output parameters or the stored procedure's return value parameter.
        /// 
        /// e.g.:  
        ///  XmlReader r = ExecuteXmlReader(conn, "GetOrders", 24, 36);
        /// </remarks>
        /// <param name="connection">A valid SqlConnection</param>
        /// <param name="spName">The name of the stored procedure using "FOR XML AUTO"</param>
        /// <param name="parameterValues">An array of objects to be assigned as the input values of the stored procedure</param>
        /// <returns>An XmlReader containing the resultset generated by the command</returns>
        public static XmlReader ExecuteXmlReader(SqlConnection connection, string spName, params object[] parameterValues)
        {
            if (connection == null) throw new ArgumentNullException("connection");
            if (spName == null || spName.Length == 0) throw new ArgumentNullException("spName");

            // If we receive parameter values, we need to figure out where they go
            if ((parameterValues != null) && (parameterValues.Length > 0))
            {
                // Pull the parameters for this stored procedure from the parameter cache (or discover them & populate the cache)
                SqlParameter[] commandParameters = SqlHelperParameterCache.GetSpParameterSet(connection, spName);

                // Assign the provided values to these parameters based on parameter order
                AssignParameterValues(commandParameters, parameterValues);

                // Call the overload that takes an array of SqlParameters
                return ExecuteXmlReader(connection, CommandType.StoredProcedure, spName, commandParameters);
            }
            else
            {
                // Otherwise we can just call the SP without params
                return ExecuteXmlReader(connection, CommandType.StoredProcedure, spName);
            }
        }

        /// <summary>
        /// Execute a SqlCommand (that returns a resultset and takes no parameters) against the provided SqlTransaction. 
        /// </summary>
        /// <remarks>
        /// e.g.:  
        ///  XmlReader r = ExecuteXmlReader(trans, CommandType.StoredProcedure, "GetOrders");
        /// </remarks>
        /// <param name="transaction">A valid SqlTransaction</param>
        /// <param name="commandType">The CommandType (stored procedure, text, etc.)</param>
        /// <param name="commandText">The stored procedure name or T-SQL command using "FOR XML AUTO"</param>
        /// <returns>An XmlReader containing the resultset generated by the command</returns>
        public static XmlReader ExecuteXmlReader(SqlTransaction transaction, CommandType commandType, string commandText)
        {
            // Pass through the call providing null for the set of SqlParameters
            return ExecuteXmlReader(transaction, commandType, commandText, (SqlParameter[])null);
        }

        /// <summary>
        /// Execute a SqlCommand (that returns a resultset) against the specified SqlTransaction
        /// using the provided parameters.
        /// </summary>
        /// <remarks>
        /// e.g.:  
        ///  XmlReader r = ExecuteXmlReader(trans, CommandType.StoredProcedure, "GetOrders", new SqlParameter("@prodid", 24));
        /// </remarks>
        /// <param name="transaction">A valid SqlTransaction</param>
        /// <param name="commandType">The CommandType (stored procedure, text, etc.)</param>
        /// <param name="commandText">The stored procedure name or T-SQL command using "FOR XML AUTO"</param>
        /// <param name="commandParameters">An array of SqlParamters used to execute the command</param>
        /// <returns>An XmlReader containing the resultset generated by the command</returns>
        public static XmlReader ExecuteXmlReader(SqlTransaction transaction, CommandType commandType, string commandText, params SqlParameter[] commandParameters)
        {
            if (transaction == null) throw new ArgumentNullException("transaction");
            if (transaction != null && transaction.Connection == null) throw new ArgumentException("The transaction was rollbacked or commited, please provide an open transaction.", "transaction");

            // Create a command and prepare it for execution
            SqlCommand cmd = new SqlCommand();
            bool mustCloseConnection = false;
            PrepareCommand(cmd, transaction.Connection, transaction, commandType, commandText, commandParameters, out mustCloseConnection);

            // Create the DataAdapter & DataSet
            XmlReader retval = cmd.ExecuteXmlReader();

            // Detach the SqlParameters from the command object, so they can be used again
            cmd.Parameters.Clear();
            return retval;
        }

        /// <summary>
        /// Execute a stored procedure via a SqlCommand (that returns a resultset) against the specified 
        /// SqlTransaction using the provided parameter values.  This method will query the database to discover the parameters for the 
        /// stored procedure (the first time each stored procedure is called), and assign the values based on parameter order.
        /// </summary>
        /// <remarks>
        /// This method provides no access to output parameters or the stored procedure's return value parameter.
        /// 
        /// e.g.:  
        ///  XmlReader r = ExecuteXmlReader(trans, "GetOrders", 24, 36);
        /// </remarks>
        /// <param name="transaction">A valid SqlTransaction</param>
        /// <param name="spName">The name of the stored procedure</param>
        /// <param name="parameterValues">An array of objects to be assigned as the input values of the stored procedure</param>
        /// <returns>A dataset containing the resultset generated by the command</returns>
        public static XmlReader ExecuteXmlReader(SqlTransaction transaction, string spName, params object[] parameterValues)
        {
            if (transaction == null) throw new ArgumentNullException("transaction");
            if (transaction != null && transaction.Connection == null) throw new ArgumentException("The transaction was rollbacked or commited, please provide an open transaction.", "transaction");
            if (spName == null || spName.Length == 0) throw new ArgumentNullException("spName");

            // If we receive parameter values, we need to figure out where they go
            if ((parameterValues != null) && (parameterValues.Length > 0))
            {
                // Pull the parameters for this stored procedure from the parameter cache (or discover them & populate the cache)
                SqlParameter[] commandParameters = SqlHelperParameterCache.GetSpParameterSet(transaction.Connection, spName);

                // Assign the provided values to these parameters based on parameter order
                AssignParameterValues(commandParameters, parameterValues);

                // Call the overload that takes an array of SqlParameters
                return ExecuteXmlReader(transaction, CommandType.StoredProcedure, spName, commandParameters);
            }
            else
            {
                // Otherwise we can just call the SP without params
                return ExecuteXmlReader(transaction, CommandType.StoredProcedure, spName);
            }
        }

        #endregion [ ExecuteXmlReader ]

        /// <summary>
        /// This method assigns dataRow column values to an array of SqlParameters
        /// </summary>
        /// <param name="commandParameters">Array of SqlParameters to be assigned values</param>
        /// <param name="dataRow">The dataRow used to hold the stored procedure's parameter values</param>
        private static void AssignParameterValues(SqlParameter[] commandParameters, DataRow dataRow)
        {
            if ((commandParameters == null) || (dataRow == null))
            {
                // Do nothing if we get no data
                return;
            }

            int i = 0;
            // Set the parameters values
            foreach (SqlParameter commandParameter in commandParameters)
            {
                // Check the parameter name
                if (commandParameter.ParameterName == null ||
                    commandParameter.ParameterName.Length <= 1)
                    throw new Exception(
                        string.Format(
                            "Please provide a valid parameter name on the parameter #{0}, the ParameterName property has the following value: '{1}'.",
                            i, commandParameter.ParameterName));
                if (dataRow.Table.Columns.IndexOf(commandParameter.ParameterName.Substring(1)) != -1)
                    commandParameter.Value = dataRow[commandParameter.ParameterName.Substring(1)];
                i++;
            }
        }

        /// <summary>
        /// This method assigns an array of values to an array of SqlParameters
        /// </summary>
        /// <param name="commandParameters">Array of SqlParameters to be assigned values</param>
        /// <param name="parameterValues">Array of objects holding the values to be assigned</param>
        private static void AssignParameterValues(SqlParameter[] commandParameters, object[] parameterValues)
        {
            if ((commandParameters == null) || (parameterValues == null))
            {
                // Do nothing if we get no data
                return;
            }

            // We must have the same number of values as we pave parameters to put them in
            if (commandParameters.Length != parameterValues.Length)
            {
                throw new ArgumentException("Parameter count does not match Parameter Value count.");
            }

            // Iterate through the SqlParameters, assigning the values from the corresponding position in the 
            // value array
            for (int i = 0, j = commandParameters.Length; i < j; i++)
            {
                // If the current array value derives from IDbDataParameter, then assign its Value property
                if (parameterValues[i] is IDbDataParameter)
                {
                    IDbDataParameter paramInstance = (IDbDataParameter)parameterValues[i];
                    if (paramInstance.Value == null)
                    {
                        commandParameters[i].Value = DBNull.Value;
                    }
                    else
                    {
                        commandParameters[i].Value = paramInstance.Value;
                    }
                }
                else if (parameterValues[i] == null)
                {
                    commandParameters[i].Value = DBNull.Value;
                }
                else
                {
                    commandParameters[i].Value = parameterValues[i];
                }
            }
        }

        /// <summary>
        /// This method opens (if necessary) and assigns a connection, transaction, command type and parameters 
        /// to the provided command
        /// </summary>
        /// <param name="command">The SqlCommand to be prepared</param>
        /// <param name="connection">A valid SqlConnection, on which to execute this command</param>
        /// <param name="transaction">A valid SqlTransaction, or 'null'</param>
        /// <param name="commandType">The CommandType (stored procedure, text, etc.)</param>
        /// <param name="commandText">The stored procedure name or T-SQL command</param>
        /// <param name="commandParameters">An array of SqlParameters to be associated with the command or 'null' if no parameters are required</param>
        /// <param name="mustCloseConnection"><c>true</c> if the connection was opened by the method, otherwose is false.</param>
        private static void PrepareCommand(SqlCommand command, SqlConnection connection, SqlTransaction transaction, CommandType commandType, string commandText, SqlParameter[] commandParameters, out bool mustCloseConnection)
        {
            if (command == null) throw new ArgumentNullException("command");
            if (commandText == null || commandText.Length == 0) throw new ArgumentNullException("commandText");

            // If the provided connection is not open, we will open it
            if (connection.State != ConnectionState.Open)
            {
                mustCloseConnection = true;
                connection.Open();
            }
            else
            {
                mustCloseConnection = false;
            }

            // Associate the connection with the command
            command.Connection = connection;
            command.CommandTimeout = TiempoEsperaEjecucion;

            // Set the command text (stored procedure name or SQL statement)
            command.CommandText = commandText;

            // If we were provided a transaction, assign it
            if (transaction != null)
            {
                if (transaction.Connection == null) throw new ArgumentException("The transaction was rollbacked or commited, please provide an open transaction.", "transaction");
                command.Transaction = transaction;
            }

            // Set the command type
            command.CommandType = commandType;

            // Attach the command parameters if they are provided
            if (commandParameters != null)
            {
                AttachParameters(command, commandParameters);
            }
            return;
        }

        private static void AttachParameters(SqlCommand command, SqlParameter[] commandParameters)
        {
            if (commandParameters == null)
            {
                return;
            }
            foreach (SqlParameter p in commandParameters)
            {
                //check for derived output value with no value assigned
                if ((p.Direction == ParameterDirection.InputOutput) && (p.Value == null))
                {
                    p.Value = DBNull.Value;
                }

                command.Parameters.Add(p);
            }
        }
    }

    /// <summary>
    /// SqlHelperParameterCache provides functions to leverage a static cache of procedure parameters, and the
    /// ability to discover parameters for stored procedures at run-time.
    /// </summary>
    public sealed class SqlHelperParameterCache
    {
        #region private methods, variables, and constructors

        //Since this class provides only static methods, make the default constructor private to prevent 
        //instances from being created with "new SqlHelperParameterCache()"
        private SqlHelperParameterCache() { }

        private static Hashtable paramCache = Hashtable.Synchronized(new Hashtable());

        /// <summary>
        /// Resolve at run time the appropriate set of SqlParameters for a stored procedure
        /// </summary>
        /// <param name="connection">A valid SqlConnection object</param>
        /// <param name="spName">The name of the stored procedure</param>
        /// <param name="includeReturnValueParameter">Whether or not to include their return value parameter</param>
        /// <returns>The parameter array discovered.</returns>
        private static SqlParameter[] DiscoverSpParameterSet(SqlConnection connection, string spName, bool includeReturnValueParameter)
        {
            if (connection == null) throw new ArgumentNullException("connection");
            if (spName == null || spName.Length == 0) throw new ArgumentNullException("spName");

            SqlCommand cmd = new SqlCommand(spName, connection);
            cmd.CommandType = CommandType.StoredProcedure;

            connection.Open();
            SqlCommandBuilder.DeriveParameters(cmd);
            connection.Close();

            if (!includeReturnValueParameter)
            {
                cmd.Parameters.RemoveAt(0);
            }

            SqlParameter[] discoveredParameters = new SqlParameter[cmd.Parameters.Count];

            cmd.Parameters.CopyTo(discoveredParameters, 0);

            // Init the parameters with a DBNull value
            foreach (SqlParameter discoveredParameter in discoveredParameters)
            {
                discoveredParameter.Value = DBNull.Value;
            }
            return discoveredParameters;
        }

        /// <summary>
        /// Deep copy of cached SqlParameter array
        /// </summary>
        /// <param name="originalParameters"></param>
        /// <returns></returns>
        private static SqlParameter[] CloneParameters(SqlParameter[] originalParameters)
        {
            SqlParameter[] clonedParameters = new SqlParameter[originalParameters.Length];

            for (int i = 0, j = originalParameters.Length; i < j; i++)
            {
                clonedParameters[i] = (SqlParameter)((ICloneable)originalParameters[i]).Clone();
            }

            return clonedParameters;
        }

        #endregion private methods, variables, and constructors

        #region caching functions

        /// <summary>
        /// Add parameter array to the cache
        /// </summary>
        /// <param name="connectionString">A valid connection string for a SqlConnection</param>
        /// <param name="commandText">The stored procedure name or T-SQL command</param>
        /// <param name="commandParameters">An array of SqlParamters to be cached</param>
        public static void CacheParameterSet(string connectionString, string commandText, params SqlParameter[] commandParameters)
        {
            if (connectionString == null || connectionString.Length == 0) throw new ArgumentNullException("connectionString");
            if (commandText == null || commandText.Length == 0) throw new ArgumentNullException("commandText");

            string hashKey = connectionString + ":" + commandText;

            paramCache[hashKey] = commandParameters;
        }

        /// <summary>
        /// Retrieve a parameter array from the cache
        /// </summary>
        /// <param name="connectionString">A valid connection string for a SqlConnection</param>
        /// <param name="commandText">The stored procedure name or T-SQL command</param>
        /// <returns>An array of SqlParamters</returns>
        public static SqlParameter[] GetCachedParameterSet(string connectionString, string commandText)
        {
            if (connectionString == null || connectionString.Length == 0) throw new ArgumentNullException("connectionString");
            if (commandText == null || commandText.Length == 0) throw new ArgumentNullException("commandText");

            string hashKey = connectionString + ":" + commandText;

            SqlParameter[] cachedParameters = paramCache[hashKey] as SqlParameter[];
            if (cachedParameters == null)
            {
                return null;
            }
            else
            {
                return CloneParameters(cachedParameters);
            }
        }

        #endregion caching functions

        #region Parameter Discovery Functions

        /// <summary>
        /// Retrieves the set of SqlParameters appropriate for the stored procedure
        /// </summary>
        /// <remarks>
        /// This method will query the database for this information, and then store it in a cache for future requests.
        /// </remarks>
        /// <param name="connectionString">A valid connection string for a SqlConnection</param>
        /// <param name="spName">The name of the stored procedure</param>
        /// <returns>An array of SqlParameters</returns>
        public static SqlParameter[] GetSpParameterSet(string connectionString, string spName)
        {
            return GetSpParameterSet(connectionString, spName, false);
        }

        /// <summary>
        /// Retrieves the set of SqlParameters appropriate for the stored procedure
        /// </summary>
        /// <remarks>
        /// This method will query the database for this information, and then store it in a cache for future requests.
        /// </remarks>
        /// <param name="connectionString">A valid connection string for a SqlConnection</param>
        /// <param name="spName">The name of the stored procedure</param>
        /// <param name="includeReturnValueParameter">A bool value indicating whether the return value parameter should be included in the results</param>
        /// <returns>An array of SqlParameters</returns>
        public static SqlParameter[] GetSpParameterSet(string connectionString, string spName, bool includeReturnValueParameter)
        {
            if (connectionString == null || connectionString.Length == 0) throw new ArgumentNullException("connectionString");
            if (spName == null || spName.Length == 0) throw new ArgumentNullException("spName");

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                return GetSpParameterSetInternal(connection, spName, includeReturnValueParameter);
            }
        }

        /// <summary>
        /// Retrieves the set of SqlParameters appropriate for the stored procedure
        /// </summary>
        /// <remarks>
        /// This method will query the database for this information, and then store it in a cache for future requests.
        /// </remarks>
        /// <param name="connection">A valid SqlConnection object</param>
        /// <param name="spName">The name of the stored procedure</param>
        /// <returns>An array of SqlParameters</returns>
        internal static SqlParameter[] GetSpParameterSet(SqlConnection connection, string spName)
        {
            return GetSpParameterSet(connection, spName, false);
        }

        /// <summary>
        /// Retrieves the set of SqlParameters appropriate for the stored procedure
        /// </summary>
        /// <remarks>
        /// This method will query the database for this information, and then store it in a cache for future requests.
        /// </remarks>
        /// <param name="connection">A valid SqlConnection object</param>
        /// <param name="spName">The name of the stored procedure</param>
        /// <param name="includeReturnValueParameter">A bool value indicating whether the return value parameter should be included in the results</param>
        /// <returns>An array of SqlParameters</returns>
        internal static SqlParameter[] GetSpParameterSet(SqlConnection connection, string spName, bool includeReturnValueParameter)
        {
            if (connection == null) throw new ArgumentNullException("connection");
            using (SqlConnection clonedConnection = (SqlConnection)((ICloneable)connection).Clone())
            {
                return GetSpParameterSetInternal(clonedConnection, spName, includeReturnValueParameter);
            }
        }

        /// <summary>
        /// Retrieves the set of SqlParameters appropriate for the stored procedure
        /// </summary>
        /// <param name="connection">A valid SqlConnection object</param>
        /// <param name="spName">The name of the stored procedure</param>
        /// <param name="includeReturnValueParameter">A bool value indicating whether the return value parameter should be included in the results</param>
        /// <returns>An array of SqlParameters</returns>
        private static SqlParameter[] GetSpParameterSetInternal(SqlConnection connection, string spName, bool includeReturnValueParameter)
        {
            if (connection == null) throw new ArgumentNullException("connection");
            if (spName == null || spName.Length == 0) throw new ArgumentNullException("spName");

            string hashKey = connection.ConnectionString + ":" + spName + (includeReturnValueParameter ? ":include ReturnValue Parameter" : "");

            SqlParameter[] cachedParameters;

            cachedParameters = paramCache[hashKey] as SqlParameter[];
            if (cachedParameters == null)
            {
                SqlParameter[] spParameters = DiscoverSpParameterSet(connection, spName, includeReturnValueParameter);
                paramCache[hashKey] = spParameters;
                cachedParameters = spParameters;
            }

            return CloneParameters(cachedParameters);
        }

        #endregion Parameter Discovery Functions

    }

}
