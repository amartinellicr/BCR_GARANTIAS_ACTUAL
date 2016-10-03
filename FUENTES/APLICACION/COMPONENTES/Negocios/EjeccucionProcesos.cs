using System;
using System.Text;
using System.Data;
using System.Xml;
using System.Data.SqlClient;

using BCR.GARANTIAS.Entidades;
using BCR.GARANTIAS.Comun;
using BCRGARANTIAS.Datos;

namespace BCRGARANTIAS.Negocios
{
    public class EjeccucionProcesos
    {
        #region Constantes

        private const string _codigo = "CODIGO";
        private const string _mensaje = "MENSAJE";
        private const string _resultados = "RESULTADOS";
        private const string _resultado = "RESULTADO";

        #endregion Constantes


        /// <summary>
        /// Realiza la consulta a nivel dde base de datos del resultado de la ejecución de los procesos de réplica
        /// </summary>
        /// <param name="fechaInicial">Fecha desde la cual se desea obtener la información</param>
        /// <param name="fechaFinal">Fecha hasta la cual se desea obtener la información</param>
        /// <param name="codigoProceso">Código del proceso del que se desea obtener datos</param>
        /// <param name="indicadorResultado">Indicador del resultado obtenido dusrante la ejecución</param>
        /// <returns>Lista del detalle del resultado de la ejecución del proceso</returns>
        public clsEjecucionProcesos<clsEjecucionProceso> Obtener_Resultado_Ejecucion_Proceso(DateTime fechaInicial, DateTime fechaFinal, string codigoProceso, string indicadorResultado)
        {
            XmlReader oRetornoDEP = null;
            XmlDocument xmlTrama = new XmlDocument();
            XmlNode nodoResultados;
            clsEjecucionProcesos<clsEjecucionProceso> listaProcesosEjecutados = null;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerDEP = string.Empty;
            string codErrorObtenido = string.Empty;

            StringBuilder sbDEP = new StringBuilder();

            try
            {
                SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("pdFechaInicial", SqlDbType.DateTime),
                        new SqlParameter("pdFechaFinal", SqlDbType.DateTime),
                        new SqlParameter("psCodigoProceso", SqlDbType.VarChar, 20),
                        new SqlParameter("piIndicador", SqlDbType.Bit),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                parameters[0].Value = fechaInicial;
                parameters[1].Value = fechaFinal;

                if (codigoProceso.Length > 0)
                {
                    parameters[2].Value = codigoProceso;
                }
                else
                {
                    parameters[2].Value = DBNull.Value;
                }

                if (indicadorResultado.Length > 0)
                {
                    parameters[3].Value = ((indicadorResultado.CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    parameters[3].Value = DBNull.Value;
                }

                parameters[4].Value = null;
                parameters[4].Direction = ParameterDirection.Output;


                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    //Ejecuta el comando
                    oRetornoDEP = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Obtener_Resultado_Ejecucion_Procesos_Replica", parameters);



                    if (oRetornoDEP != null)
                    {
                        while (oRetornoDEP.Read())
                        {
                            sbDEP.AppendLine(oRetornoDEP.ReadOuterXml());
                        }

                        vsObtenerDEP = sbDEP.ToString();

                        if (vsObtenerDEP.Length > 0)
                        {
                            strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerDEP);
                            if (strMensajeObtenido.Length > 1)
                            {
                                if (strMensajeObtenido[0].CompareTo("0") == 0)
                                {
                                    if (vsObtenerDEP.Length > 0)
                                    {
                                        xmlTrama.LoadXml(vsObtenerDEP);

                                        if (xmlTrama != null)
                                        {
                                            nodoResultados = xmlTrama.SelectSingleNode("//" + _resultados);

                                            if ((nodoResultados != null) && (nodoResultados.HasChildNodes))
                                            {
                                                clsEjecucionProceso entidadEjecucionProceso;
                                                listaProcesosEjecutados = new clsEjecucionProcesos<clsEjecucionProceso>();

                                                foreach (XmlNode nodoResultado in nodoResultados.ChildNodes)
                                                {
                                                    entidadEjecucionProceso = new clsEjecucionProceso(nodoResultado.OuterXml);

                                                    listaProcesosEjecutados.Agregar(entidadEjecucionProceso);
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorObteniendoResultadosEjecucion, Mensajes.ASSEMBLY));
                                    }
                                }
                                else
                                {
                                    if (strMensajeObtenido[0].CompareTo("1") == 0)
                                    {
                                        listaProcesosEjecutados = null;
                                    }
                                    else
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorObteniendoResultadosEjecucion, Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorObteniendoResultadosEjecucion, Mensajes.ASSEMBLY));
                            }
                        }
                        else
                        {
                            throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorObteniendoResultadosEjecucion, Mensajes.ASSEMBLY));
                        }
                    }
                    else
                    {
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorObteniendoResultadosEjecucion, Mensajes.ASSEMBLY));
                    }

                    oConexion.Close();
                    oConexion.Dispose();
                }
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoResultadosEjecucionDetalle, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes._errorObteniendoResultadosEjecucion, Mensajes.ASSEMBLY)));
            }

            return listaProcesosEjecutados;
        }

    }
}
