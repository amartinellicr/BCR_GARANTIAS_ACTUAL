using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Xml;
using System.Text;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;


namespace BCRGARANTIAS.Negocios
{

    /// <summary>
	/// Summary description for Valuaciones_Reales.
	/// </summary>
	public class Valuaciones_Reales
    {

        #region Constantes

        private const string _codigo    = "CODIGO";
        private const string _mensaje   = "MENSAJE";
        private const string _avaluos   = "AVALUOS";
        private const string _avaluo    = "AVALUO";

        #endregion Constantes

        #region Variables Globales

        private string mstrGarantia             = "-";
        private string mstrOperacionCrediticia  = "-";
        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        int nFilasAfectadas = 0;

        #endregion

        #region Metodos Publicos

        public clsValuacionesReales<clsValuacionReal> Obtener_Avaluos(long nGarantia, string codigoBien, bool obtenerMasReciente, int catalogoRP, int catalogoIMT)
        {
            XmlReader oRetornoVGR = null;
            XmlDocument xmlTrama = new XmlDocument();
            XmlNode nodoAvaluos;
            clsValuacionesReales<clsValuacionReal> listaValuacionesReales = null;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerVGR = string.Empty;
            string codErrorObtenido = string.Empty;

            StringBuilder sbVGR = new StringBuilder();

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piGarantia_Real", SqlDbType.BigInt),
                        new SqlParameter("pbObtenerMasReciente", SqlDbType.Bit),
                        new SqlParameter("piCatalogoRP", SqlDbType.Int),
                        new SqlParameter("piCatalogoIMT", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                parameters[0].Value = nGarantia;
                parameters[1].Value = obtenerMasReciente;
                parameters[2].Value = catalogoRP;
                parameters[3].Value = catalogoIMT;
                parameters[4].Value = null;
                parameters[4].Direction = ParameterDirection.Output;


                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    //Ejecuta el comando
                    oRetornoVGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "pa_Obtener_Valuaciones_Reales", parameters);

                    if (oRetornoVGR != null)
                    {
                        while (oRetornoVGR.Read())
                        {
                            sbVGR.AppendLine(oRetornoVGR.ReadOuterXml());
                        }

                        vsObtenerVGR = sbVGR.ToString();

                        if (vsObtenerVGR.Length > 0)
                        {
                            strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerVGR);
                            if (strMensajeObtenido.Length > 1)
                            {
                                if (strMensajeObtenido[0].CompareTo("0") == 0)
                                {
                                    if (vsObtenerVGR.Length > 0)
                                    {
                                        xmlTrama.LoadXml(vsObtenerVGR);

                                        if (xmlTrama != null)
                                        {
                                            nodoAvaluos = xmlTrama.SelectSingleNode("//" + _avaluos);

                                            if ((nodoAvaluos != null) && (nodoAvaluos.HasChildNodes))
                                            {
                                                clsValuacionReal entidadValuacionReal;
                                                listaValuacionesReales = new clsValuacionesReales<clsValuacionReal>();

                                                foreach (XmlNode nodoAvaluo in nodoAvaluos.ChildNodes)
                                                {
                                                    entidadValuacionReal = new clsValuacionReal(nodoAvaluo.OuterXml);
                                                    entidadValuacionReal.CodGarantiaReal = nGarantia;
                                                    entidadValuacionReal.MontoTotalAvaluo = 
                                                          entidadValuacionReal.MontoTasacionActualizadaTerreno 
                                                        + entidadValuacionReal.MontoTasacionActualizadaNoTerreno;

                                                    listaValuacionesReales.Agregar(entidadValuacionReal);
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY));
                                    }
                                }
                                else
                                {
                                    if (strMensajeObtenido[0].CompareTo("1") == 0)
                                    {
                                        listaValuacionesReales = null;
                                    }
                                    else
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY));
                            }
                        }
                        else
                        {
                            throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY));
                        }
                    }
                    else
                    {
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY));
                    }
                }
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY)));
            }

            return listaValuacionesReales;
        }

        /// <summary>
        /// Permite aplicar el proceso del cálculo del monto de la tasación actualizada del no terreno,esto para todos los avalúos más recientes
        /// </summary>
        /// <param name="strUsuario">Identificación del usuario que ejecuta el proceso</param>
        /// <param name="esServicioWindows">Indica si se ejecuta desde l servicio windows o no</param>
        /// <returns></returns>
        public string AplicarCalculoMTANTAvaluos(string strUsuario, bool esServicioWindows)
        {
            //string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };
            string[] respuestasObtenidasBD = new string[5] { string.Empty, string.Empty, string.Empty, string.Empty, string.Empty };

            string vsObtenerVGR = string.Empty;
            string descripcionErrorRetornado = string.Empty;

            StringBuilder sbErroresCalculo = new StringBuilder();

            try
            {
                SqlParameter[] parametrosProcedimiento = new SqlParameter[] { 
                        new SqlParameter("@psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("@piIndicador_Proceso", SqlDbType.TinyInt),
                        new SqlParameter("@psRespuesta", SqlDbType.VarChar,1000)
                    };

                parametrosProcedimiento[0].Value = strUsuario;
                parametrosProcedimiento[1].Value = 1;
                parametrosProcedimiento[2].Value = null;
                parametrosProcedimiento[2].Direction = ParameterDirection.Output;

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    #region Se inicializan objetos de base de datos

                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Aplicar_Calculo_Avaluo_MTAT_MTANT", 0, parametrosProcedimiento);

                    respuestasObtenidasBD[0] = parametrosProcedimiento[2].Value.ToString();

                    #endregion Se inicializan objetos de base de datos

                    #region Se obtienen los registros que participarán en el cálculo

                    parametrosProcedimiento[0].Value = strUsuario;
                    parametrosProcedimiento[1].Value = 2;
                    parametrosProcedimiento[2].Value = null;
                    parametrosProcedimiento[2].Direction = ParameterDirection.Output;

                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Aplicar_Calculo_Avaluo_MTAT_MTANT", 0, parametrosProcedimiento);

                    respuestasObtenidasBD[1] = parametrosProcedimiento[2].Value.ToString();

                    #endregion Se obtienen los registros que participarán en el cálculo

                    #region Se obtienen los montos de las tasaciones actualizadas del terreno y no terreno calculados

                    parametrosProcedimiento[0].Value = strUsuario;
                    parametrosProcedimiento[1].Value = 3;
                    parametrosProcedimiento[2].Value = null;
                    parametrosProcedimiento[2].Direction = ParameterDirection.Output;

                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Aplicar_Calculo_Avaluo_MTAT_MTANT", 0, parametrosProcedimiento);

                    respuestasObtenidasBD[2] = parametrosProcedimiento[2].Value.ToString();

                    #endregion Se obtienen los montos de las tasaciones actualizadas del terreno y no terreno calculados

                    #region Se obtiene el porcentaje de aceptación del terreno calculado

                    parametrosProcedimiento[0].Value = strUsuario;
                    parametrosProcedimiento[1].Value = 4;
                    parametrosProcedimiento[2].Value = null;
                    parametrosProcedimiento[2].Direction = ParameterDirection.Output;

                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Aplicar_Calculo_Avaluo_MTAT_MTANT", 0, parametrosProcedimiento);

                    respuestasObtenidasBD[3] = parametrosProcedimiento[2].Value.ToString();

                    #endregion Se obtiene el porcentaje de aceptación del terreno calculado

                    #region Se obtiene el porcentaje de aceptación del no terreno calculado

                    parametrosProcedimiento[0].Value = strUsuario;
                    parametrosProcedimiento[1].Value = 5;
                    parametrosProcedimiento[2].Value = null;
                    parametrosProcedimiento[2].Direction = ParameterDirection.Output;

                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Aplicar_Calculo_Avaluo_MTAT_MTANT", 0, parametrosProcedimiento);

                    respuestasObtenidasBD[4] = parametrosProcedimiento[2].Value.ToString();

                    #endregion Se obtiene el porcentaje de aceptación del no terreno calculado
                                        
                }

                foreach (string respuestaObtenida in respuestasObtenidasBD)
                {
                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {
                            descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalleServicioWindows, strMensajeObtenido[1], Mensajes.ASSEMBLY);

                            sbErroresCalculo.AppendLine(descripcionErrorRetornado);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                if (!esServicioWindows)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalleServicioWindows, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                }

                descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalleServicioWindows, ex.Message, Mensajes.ASSEMBLY);

                sbErroresCalculo.AppendLine(descripcionErrorRetornado);
            }

            return sbErroresCalculo.ToString();
        }

        /// <summary>
        /// Método que permite la inserción de los semestres calculados dentro de la tabla temporal de la base de datos
        /// </summary>
        /// <param name="tramaSemestres">Trama con los semestres calculados</param>
        /// <param name="strUsuario">Usuario que realizó el cálculo</param>
        /// <returns>La descripción del estado de la transacción final</returns>
        public string InsertarSemetresCalculados(string tramaSemestres, string strUsuario)
        {
            string[] strMensajeObtenido = new string[] { string.Empty };
            string respuestaObtenida = string.Empty;
            string descripcionErrorRetornado = string.Empty;

            StringBuilder sbVGR = new StringBuilder();

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psTrama", SqlDbType.NText),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                parameters[0].Value = tramaSemestres;
                parameters[1].Value = strUsuario;
                parameters[2].Value = null;
                parameters[2].Direction = ParameterDirection.Output;

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    //Ejecuta el comando
                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Insertar_Registro_Calculo_MTAT_MTANT", parameters);

                    respuestaObtenida = parameters[2].Value.ToString();

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);
                        if (strMensajeObtenido.Length > 1)
                        {
                            if (strMensajeObtenido[0].CompareTo("0") == 0)
                            {
                                if (respuestaObtenida.Length == 0)
                                {
                                    descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculados, Mensajes.ASSEMBLY);
                                }
                            }
                            else
                            {
                                if (strMensajeObtenido[0].CompareTo("1") != 0)
                                {
                                    descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculados, Mensajes.ASSEMBLY);

                                    if ((strMensajeObtenido.Length > 1) && (strMensajeObtenido[1] != null) && (strMensajeObtenido[1].Length > 0))
                                    {
                                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculadosDetalle, strMensajeObtenido[1], Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                                    }
                                }
                            }
                        }
                        else
                        {
                            descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculados, Mensajes.ASSEMBLY);
                        }
                    }
                    else
                    {
                        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculados, Mensajes.ASSEMBLY);
                    }
                }
            }
            catch (Exception ex)
            {
                descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculados, Mensajes.ASSEMBLY);
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculadosDetalle, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
            }

            return descripcionErrorRetornado;
        }

        /// <summary>
        /// Método que permite la eliminación de los semestres calculados dentro de la tabla temporal de la base de datos. 
        /// Este método sólo es utilizado por el servicio windows que aplica el cálculode forma automática.
        /// </summary>
        /// <returns>La descripción del estado de la transacción final</returns>
        public string EliminarSemetresCalculados()
        {
            XmlReader oRetornoVGR = null;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string vsObtenerVGR = string.Empty;
            string descripcionErrorRetornado = string.Empty;

            StringBuilder sbVGR = new StringBuilder();

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                parameters[0].Value = null;
                parameters[0].Direction = ParameterDirection.Output;


                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    //Ejecuta el comando
                    oRetornoVGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Eliminar_Registro_Calculo_MTAT_MTANT", parameters);

                    if (oRetornoVGR != null)
                    {
                        while (oRetornoVGR.Read())
                        {
                            sbVGR.AppendLine(oRetornoVGR.ReadOuterXml());
                        }

                        vsObtenerVGR = sbVGR.ToString();

                        if (vsObtenerVGR.Length > 0)
                        {
                            strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerVGR);
                            if (strMensajeObtenido.Length > 1)
                            {
                                if (strMensajeObtenido[0].CompareTo("0") == 0)
                                {
                                    if (vsObtenerVGR.Length == 0)
                                    {
                                        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);
                                    }
                                }
                                else
                                {
                                    if (strMensajeObtenido[0].CompareTo("1") != 0)
                                    {
                                        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);

                                        if ((strMensajeObtenido.Length > 1) && (strMensajeObtenido[1] != null) && (strMensajeObtenido[1].Length > 0))
                                        {
                                            descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculadosDetalle, strMensajeObtenido[1], Mensajes.ASSEMBLY);
                                        }
                                    }
                                }
                            }
                            else
                            {
                                descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);
                            }
                        }
                        else
                        {
                            descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);
                        }
                    }
                    else
                    {
                        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);
                    }
                }
            }
            catch (Exception ex)
            {
                descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculadosDetalle, ex.Message, Mensajes.ASSEMBLY);
                //descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);
                //UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculadosDetalle, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
            }

            return descripcionErrorRetornado;
        }


		#endregion
	}
}
