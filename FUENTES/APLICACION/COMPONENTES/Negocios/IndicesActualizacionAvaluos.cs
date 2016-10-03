using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    public class IndicesActualizacionAvaluos
    {
        #region M�todos P�blicos

        /// <summary>
        /// Inserta un registro de los �ndices de actualizaci�n de aval�os 
        /// </summary>
        /// <param name="entidadIndicePreciosConsumidor">Entidad del tipo �ndices de actualizaci�n de aval�os que posee los datos a insertar</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Direcci�n desde donde se ingresa el registro</param>
        public void Crear(clsIndiceActualizacionAvaluo entidadIndicePreciosConsumidor, string usuario, string ip)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (entidadIndicePreciosConsumidor != null)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("pdFechaHora", SqlDbType.DateTime),
                        new SqlParameter("pmTipo_Cambio", SqlDbType.Decimal),
                        new SqlParameter("pmIndice_Precios_Consumidor", SqlDbType.Decimal),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = entidadIndicePreciosConsumidor.FechaHora;
                    parameters[1].Value = entidadIndicePreciosConsumidor.TipoCambio;
                    parameters[2].Value = entidadIndicePreciosConsumidor.IndicePreciosConsumidor;
                    parameters[3].Value = usuario;
                    parameters[4].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Insertar_Indice_Actualizacion_Avaluo", parameters);

                        respuestaObtenida = parameters[4].Value.ToString();

                        oConexion.Close();
                        oConexion.Dispose();
                    }

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {
                            throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoIndicesActAvaluos, Mensajes.ASSEMBLY));
                        }
                    }
                }
                catch (Exception ex)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoIndicesActAvaluosDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoIndicesActAvaluos, Mensajes.ASSEMBLY));
                }

                #region Inserci�n en Bit�cora

                Bitacora oBitacora = new Bitacora();

                    #region Inserci�n de Indice de Actualizaci�n de Aval�os

                    #region Armar String de Inserci�n del registro

                string[] listaCampos = new string[] { clsIndiceActualizacionAvaluo._indicesActualizacionAvaluo,
                                                      clsIndiceActualizacionAvaluo._fechaHora, clsIndiceActualizacionAvaluo._tipoCambio, clsIndiceActualizacionAvaluo._indicesActualizacionAvaluo,
                                                      entidadIndicePreciosConsumidor.FechaHora.ToString("dd/MM/yyyy HH:mm:ss"),
                                                      entidadIndicePreciosConsumidor.TipoCambio.ToString(),
                                                      entidadIndicePreciosConsumidor.IndicePreciosConsumidor.ToString()};

                string insertaIndiceActAvaluo = string.Format("INSERT INTO dbo.{0} ({1}, {2}, {3} VALUES ({4}, {5}, {6})", listaCampos);

                    #endregion

                    oBitacora.InsertarBitacora(clsIndiceActualizacionAvaluo._indicesActualizacionAvaluo, usuario, ip, null,
                        1, null, string.Empty, string.Empty, insertaIndiceActAvaluo, string.Empty,
                        clsIndiceActualizacionAvaluo._fechaHora, string.Empty, entidadIndicePreciosConsumidor.FechaHora.ToString("dd/MM/yyyy HH:mm:ss"));

                    oBitacora.InsertarBitacora(clsIndiceActualizacionAvaluo._indicesActualizacionAvaluo, usuario, ip, null,
                        1, null, string.Empty, string.Empty, insertaIndiceActAvaluo, string.Empty,
                        clsIndiceActualizacionAvaluo._tipoCambio, string.Empty, entidadIndicePreciosConsumidor.TipoCambio.ToString());

                    oBitacora.InsertarBitacora(clsIndiceActualizacionAvaluo._indicesActualizacionAvaluo, usuario, ip, null,
                        1, null, string.Empty, string.Empty, insertaIndiceActAvaluo, string.Empty,
                        clsIndiceActualizacionAvaluo._indicePreciosConsumidor, string.Empty, entidadIndicePreciosConsumidor.IndicePreciosConsumidor.ToString());


                    #endregion

                #endregion
            }
        }

        /// <summary>
        /// Obtiene el historial de �ndices de actualizaci�n de aval�os o el �ltimo registro ingresado
        /// </summary>
        /// <param name="tipoConculta">Indica si se obtiene el m�s reciente (0) o se obtiene el hist�rico (1) o se obtiene la lista de a�os registrados (2).</param>
        /// <param name="anno">A�o del que se requieren los registros</param>
        /// <param name="mes">Mes del que se requieren los registros</param>
        /// <returns>Enditad del tipo �ndice de actualizaci�n de aval�os</returns>
        public clsIndicesActualizacionAvaluos<clsIndiceActualizacionAvaluo> ObtenerIndicesActualizacionAvaluos(int tipoConculta, int anno, int mes)
        {
            clsIndicesActualizacionAvaluos<clsIndiceActualizacionAvaluo> entidadIndices = null;

            string tramaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if ((anno > 0) && (mes > 0))
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piAnno", SqlDbType.Int),
                        new SqlParameter("piMes", SqlDbType.TinyInt),
                        new SqlParameter("piTipo_Conculta", SqlDbType.TinyInt)
                    };

                    parameters[0].Value = anno;
                    parameters[1].Value = mes;
                    parameters[2].Value = tipoConculta; //El 0 (cero) indica que se consulta el m�s reciente, el 1 el hist�rico y el 2 la lista de a�os.

                    SqlParameter[] parametrosSalida = new SqlParameter[] { };

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        tramaObtenida = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Consultar_Indice_Actualizacion_Avaluo", out parametrosSalida, parameters);

                        oConexion.Close();
                        oConexion.Dispose();
                    }
                }
                catch (Exception ex)
                {
                    entidadIndices = new clsIndicesActualizacionAvaluos<clsIndiceActualizacionAvaluo>();

                    entidadIndices.ErrorDatos = true;
                    entidadIndices.DescripcionError = Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluos, Mensajes.ASSEMBLY);

                    string desError = "Error al obtener la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluosDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    tramaObtenida = string.Empty;
                }
            }

            if (tramaObtenida.Length > 0)
            {
                entidadIndices = new clsIndicesActualizacionAvaluos<clsIndiceActualizacionAvaluo>(tramaObtenida);
            }

            return entidadIndices;
        }

        #endregion
    }
}
