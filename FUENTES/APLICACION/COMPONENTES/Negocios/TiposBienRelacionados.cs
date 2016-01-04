using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Administra las acciones a seguir con los tipos de bienes asociados a los tipos de pólizas SAP y SUGEF.
    /// </summary>
    public class TiposBienRelacionados
    {
        #region Métodos Públicos

        /// <summary>
        /// Inserta un registro del tipo de bien asociado a un tipo de póliza SAP y un tipo de póliza SUGEF
        /// </summary>
        /// <param name="entidadTipoBienRelacionado">Entidad del tipo de bien relacionado que posee los datos a insertar</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        /// <param name="catalogoTipoBien">Código del cátologo del tipo de bien</param>
        /// <param name="catalogoTipoPolizaSap">Código del catálogo del tipo de póliza SAP</param>
        public void Crear(clsTipoBienRelacionado entidadTipoBienRelacionado, string usuario, string ip, string catalogoTipoBien, string catalogoTipoPolizaSap)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (entidadTipoBienRelacionado != null)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piCodigo_Tipo_Bien", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Poliza_Sap", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Poliza_Sugef", SqlDbType.Int),
                        new SqlParameter("piCatalogo_Tipo_Poliza", SqlDbType.Int),
                        new SqlParameter("piCatalogo_Tipo_Bien", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = entidadTipoBienRelacionado.TipoBien;
                    parameters[1].Value = entidadTipoBienRelacionado.TipoPolizaSap;
                    parameters[2].Value = entidadTipoBienRelacionado.TipoPolizaSugef;
                    parameters[3].Value = catalogoTipoPolizaSap;
                    parameters[4].Value = catalogoTipoBien;
                    parameters[5].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Insertar_Tipo_Bien_Relacionado", parameters);

                        respuestaObtenida = parameters[5].Value.ToString();

                        oConexion.Close();
                        oConexion.Dispose();
                    }

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {

                            if (strMensajeObtenido[0].CompareTo("1") == 0)
                            {

                                throw new ExcepcionBase(strMensajeObtenido[3]);
                            }
                            else
                            {

                                if ((strMensajeObtenido[0].CompareTo("2") == 0) ||
                                    (strMensajeObtenido[0].CompareTo("3") == 0) || (strMensajeObtenido[0].CompareTo("4") == 0))
                                {
                                    throw new ExcepcionBase(strMensajeObtenido[2]);

                                }
                                else
                                {
                                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoTipoBienRelacionado, Mensajes.ASSEMBLY));
                                }
                            }
                        }
                    }
                }
                catch (ExcepcionBase ex)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoTipoBienRelacionadoDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw ex;
                }
                catch (Exception ex)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoTipoBienRelacionadoDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoTipoBienRelacionado, Mensajes.ASSEMBLY));
                }

                #region Inserción en Bitácora

                Bitacora oBitacora = new Bitacora();

                #region Inserción de Tipo de Bien Relacionado

                #region Armar String de Inserción del registro

                string insertaTiposPolizasXTipoBien = "INSERT INTO dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN" +
                  "(Codigo_Tipo_Poliza_Sap, Codigo_Tipo_Poliza_Sugef, Codigo_Tipo_Bien)" +
                  "VALUES (" + entidadTipoBienRelacionado.TipoPolizaSap.ToString() + "," + entidadTipoBienRelacionado.TipoPolizaSap.ToString() + "," +
                    entidadTipoBienRelacionado.TipoBien.ToString() + ")";

                #endregion

                oBitacora.InsertarBitacora(clsTipoBienRelacionado._tiposPolizasXTipoBien, usuario, ip, null,
                    1, null, string.Empty, string.Empty, insertaTiposPolizasXTipoBien, string.Empty,
                    clsTipoBienRelacionado._codigoTipoPolizaSap, string.Empty, entidadTipoBienRelacionado.TipoPolizaSap.ToString());

                oBitacora.InsertarBitacora(clsTipoBienRelacionado._tiposPolizasXTipoBien, usuario, ip, null,
                    1, null, string.Empty, string.Empty, insertaTiposPolizasXTipoBien, string.Empty,
                    clsTipoBienRelacionado._codigoTipoPolizaSugef, string.Empty, entidadTipoBienRelacionado.TipoPolizaSap.ToString());

                oBitacora.InsertarBitacora(clsTipoBienRelacionado._tiposPolizasXTipoBien, usuario, ip, null,
                    1, null, string.Empty, string.Empty, insertaTiposPolizasXTipoBien, string.Empty,
                    clsTipoBienRelacionado._codigoTipoBien, string.Empty, entidadTipoBienRelacionado.TipoBien.ToString());


                #endregion

                #endregion
            }
        }

        /// <summary>
        /// Modifica un registro del tipo de bien asociado a un tipo de póliza SAP y un tipo de póliza SUGEF
        /// </summary>
        /// <param name="entidadTipoBienRelacionado">Entidad del tipo de bien relacionado que posee los datos a modificar</param>
        /// <param name="entidadTipoBienRelacionadoAnterior">Entidad del tipo de bien relacionado que posee los datos originales</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        /// <param name="catalogoTipoBien">Código del cátologo del tipo de bien</param>
        /// <param name="catalogoTipoPolizaSap">Código del catálogo del tipo de póliza SAP</param>
        public void Modificar(clsTipoBienRelacionado entidadTipoBienRelacionado, clsTipoBienRelacionado entidadTipoBienRelacionadoAnterior, string usuario, string ip, string catalogoTipoBien, string catalogoTipoPolizaSap)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (entidadTipoBienRelacionado != null)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piConsecutivo_Relacion", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Bien", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Poliza_Sap", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Poliza_Sugef", SqlDbType.Int),
                        new SqlParameter("piCatalogo_Tipo_Poliza", SqlDbType.Int),
                        new SqlParameter("piCatalogo_Tipo_Bien", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = entidadTipoBienRelacionado.ConsecutivoRelacion;
                    parameters[1].Value = entidadTipoBienRelacionado.TipoBien;
                    parameters[2].Value = entidadTipoBienRelacionado.TipoPolizaSap;
                    parameters[3].Value = entidadTipoBienRelacionado.TipoPolizaSugef;
                    parameters[4].Value = catalogoTipoPolizaSap;
                    parameters[5].Value = catalogoTipoBien;
                    parameters[6].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Modificar_Tipo_Bien_Relacionado", parameters);

                        respuestaObtenida = parameters[6].Value.ToString();

                        oConexion.Close();
                        oConexion.Dispose();
                    }

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                       // if (strMensajeObtenido[0].CompareTo("0") != 0)
                       // {
                        //    if ((strMensajeObtenido[0].CompareTo("1") == 0) || (strMensajeObtenido[0].CompareTo("2") == 0) ||
                              //  (strMensajeObtenido[0].CompareTo("3") == 0) || (strMensajeObtenido[0].CompareTo("4") == 0))
                        //    {
                        //        throw new ExcepcionBase(strMensajeObtenido[2]);
                         //   }
                        //    else
                        //    {
                         //       throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorModificandoTipoBienRelacionado, Mensajes.ASSEMBLY));
                         //   }
                        //}

                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {

                            if (strMensajeObtenido[0].CompareTo("1") == 0)
                            {

                                throw new ExcepcionBase(strMensajeObtenido[3]);
                            }
                            else
                            {

                                if ((strMensajeObtenido[0].CompareTo("2") == 0) ||
                                    (strMensajeObtenido[0].CompareTo("3") == 0) || (strMensajeObtenido[0].CompareTo("4") == 0))
                                {
                                    throw new ExcepcionBase(strMensajeObtenido[2]);

                                }
                                else
                                {
                                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorModificandoTipoBienRelacionado, Mensajes.ASSEMBLY));
                                }
                            }
                        }
                    }
                }
                catch (ExcepcionBase ex)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorModificandoTipoBienRelacionadoDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw ex;
                }
                catch (Exception ex)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorModificandoTipoBienRelacionadoDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorModificandoTipoBienRelacionado, Mensajes.ASSEMBLY));
                }

                #region Inserción en Bitácora

                Bitacora oBitacora = new Bitacora();

                #region Inserción de Tipo de Bien Relacionado

                string actualizacionTipoPolizaSap = ((entidadTipoBienRelacionado.TipoPolizaSap != entidadTipoBienRelacionadoAnterior.TipoPolizaSap) ? (" Codigo_Tipo_Poliza_Sap = " + entidadTipoBienRelacionado.TipoPolizaSap.ToString() + ",") : string.Empty);
                string actualizacionTipoPolizaSugef = ((entidadTipoBienRelacionado.TipoPolizaSugef != entidadTipoBienRelacionadoAnterior.TipoPolizaSugef) ? (" Codigo_Tipo_Poliza_Sugef = " + entidadTipoBienRelacionado.TipoPolizaSugef.ToString() + ",") : string.Empty);
                string actualizacionTipoBien = ((entidadTipoBienRelacionado.TipoBien != entidadTipoBienRelacionadoAnterior.TipoBien) ? (" Codigo_Tipo_Bien = " + entidadTipoBienRelacionado.TipoBien.ToString() + ",") : string.Empty);

                if ((actualizacionTipoPolizaSap.Length > 0) || (actualizacionTipoPolizaSugef.Length > 0) || (actualizacionTipoBien.Length > 0))
                {
                    string camposAjustados = actualizacionTipoPolizaSap + actualizacionTipoPolizaSugef + actualizacionTipoBien;
                    camposAjustados = camposAjustados.TrimEnd(",".ToCharArray());

                    string modificaTiposPolizasXTipoBien = "UPDATE dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN SET" + camposAjustados +
                        " WHERE	ConsecutivoRelacion = " + entidadTipoBienRelacionado.ConsecutivoRelacion.ToString();

                    if (actualizacionTipoPolizaSap.Length > 0)
                    {
                        oBitacora.InsertarBitacora(clsTipoBienRelacionado._tiposPolizasXTipoBien, usuario, ip, null,
                            2, null, string.Empty, string.Empty, modificaTiposPolizasXTipoBien, string.Empty,
                            clsTipoBienRelacionado._codigoTipoPolizaSap, entidadTipoBienRelacionadoAnterior.TipoPolizaSap.ToString(), entidadTipoBienRelacionado.TipoPolizaSap.ToString());
                    }

                    if (actualizacionTipoPolizaSugef.Length > 0)
                    {
                        oBitacora.InsertarBitacora(clsTipoBienRelacionado._tiposPolizasXTipoBien, usuario, ip, null,
                            2, null, string.Empty, string.Empty, modificaTiposPolizasXTipoBien, string.Empty,
                            clsTipoBienRelacionado._codigoTipoPolizaSugef, entidadTipoBienRelacionadoAnterior.TipoPolizaSugef.ToString(), entidadTipoBienRelacionado.TipoPolizaSugef.ToString());
                    }

                    if (actualizacionTipoBien.Length > 0)
                    {
                        oBitacora.InsertarBitacora(clsTipoBienRelacionado._tiposPolizasXTipoBien, usuario, ip, null,
                            2, null, string.Empty, string.Empty, modificaTiposPolizasXTipoBien, string.Empty,
                            clsTipoBienRelacionado._codigoTipoBien, entidadTipoBienRelacionadoAnterior.TipoBien.ToString(), entidadTipoBienRelacionado.TipoBien.ToString());
                    }
                }

                #endregion

                #endregion
            }
        }

        /// <summary>
        /// Elimina un registro del tipo de bien asociado a un tipo de póliza SAP y un tipo de póliza SUGEF
        /// </summary>
        /// <param name="entidadTipoBienRelacionado">Entidad del tipo de bien relacionado que posee los datos a eliminar</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public void Eliminar(clsTipoBienRelacionado entidadTipoBienRelacionado, string usuario, string ip)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (entidadTipoBienRelacionado != null)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piConsecutivo_Relacion", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = entidadTipoBienRelacionado.ConsecutivoRelacion;
                    parameters[1].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Eliminar_Tipo_Bien_Relacionado", parameters);

                        respuestaObtenida = parameters[1].Value.ToString();

                        oConexion.Close();
                        oConexion.Dispose();
                    }

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {
                            if (strMensajeObtenido[0].CompareTo("1") == 0)
                            {
                                throw new ExcepcionBase(strMensajeObtenido[2]);
                            }
                            else
                            {
                                throw new Exception(Mensajes.Obtener(Mensajes._errorEliminandoTipoBienRelacionado, Mensajes.ASSEMBLY));
                            }
                        }
                    }
                }
                catch (ExcepcionBase exb)
                {
                    throw exb;
                }
                catch (Exception ex)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorEliminandoTipoBienRelacionadoDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorEliminandoTipoBienRelacionado, Mensajes.ASSEMBLY));
                }

                #region Inserción en Bitácora

                Bitacora oBitacora = new Bitacora();

                #region Inserción de Tipo de Bien Relacionado


                string eliminaTiposPolizasXTipoBien = "DELETE  FROM dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN" +
                    " WHERE	ConsecutivoRelacion = " + entidadTipoBienRelacionado.ConsecutivoRelacion.ToString();

                oBitacora.InsertarBitacora(clsTipoBienRelacionado._tiposPolizasXTipoBien, usuario, ip, null,
                    3, null, string.Empty, string.Empty, eliminaTiposPolizasXTipoBien, string.Empty,
                    clsTipoBienRelacionado._codigoTipoPolizaSap, entidadTipoBienRelacionado.TipoPolizaSap.ToString(), string.Empty);

                oBitacora.InsertarBitacora(clsTipoBienRelacionado._tiposPolizasXTipoBien, usuario, ip, null,
                    3, null, string.Empty, string.Empty, eliminaTiposPolizasXTipoBien, string.Empty,
                    clsTipoBienRelacionado._codigoTipoPolizaSugef, entidadTipoBienRelacionado.TipoPolizaSugef.ToString(), string.Empty);

                oBitacora.InsertarBitacora(clsTipoBienRelacionado._tiposPolizasXTipoBien, usuario, ip, null,
                    3, null, string.Empty, string.Empty, eliminaTiposPolizasXTipoBien, string.Empty,
                    clsTipoBienRelacionado._codigoTipoBien, entidadTipoBienRelacionado.TipoBien.ToString(), string.Empty);

                #endregion

                #endregion
            }
        }

        /// <summary>
        /// Obtiene la lista de relaciones existentes entre el tipo de bien y los tipos de pólizas
        /// </summary>
        /// <param name="tipoBien">Código del tipo de bien del cual se requieren las relaciones, el dato puede ser nulo.</param>
        /// <param name="tipoPolizaSap">Código del tipo de póliza SAP del cual se requieren las relaciones, el dato puede ser nulo.</param>
        /// <param name="tipoPolizaSugef">Código del tipo de póliza SUGEF del cual se requieren las relaciones, el dato puede ser nulo.</param>
        /// <returns>Enditad del tipo índice de actualización de avalúos</returns>
        public clsTiposBienRelacionados<clsTipoBienRelacionado> ObtenerTiposBienRelacionados(int? tipoBien, int? tipoPolizaSap, int? tipoPolizaSugef, string catalogoTipoBien, string catalogoTipoPolizaSap)
        {
            clsTiposBienRelacionados<clsTipoBienRelacionado> entidadTiposBienRelacionados = null;

            string tramaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piCodigo_Tipo_Bien", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Poliza_Sap", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Poliza_Sugef", SqlDbType.Int),
                        new SqlParameter("piCatalogo_Tipo_Poliza", SqlDbType.Int),
                        new SqlParameter("piCatalogo_Tipo_Bien", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                 };

                parameters[0].Value = ((tipoBien.HasValue) ? tipoBien : null);
                parameters[1].Value = ((tipoPolizaSap.HasValue) ? tipoPolizaSap : null);
                parameters[2].Value = ((tipoPolizaSugef.HasValue) ? tipoPolizaSugef : null);
                parameters[3].Value = catalogoTipoPolizaSap;
                parameters[4].Value = catalogoTipoBien;
                parameters[5].Direction = ParameterDirection.Output;

                SqlParameter[] parametrosSalida = new SqlParameter[] { };

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    tramaObtenida = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Consultar_Tipo_Bien_Relacionado", out parametrosSalida, parameters);

                    oConexion.Close();
                    oConexion.Dispose();
                }
            }
            catch (Exception ex)
            {
                entidadTiposBienRelacionados = new clsTiposBienRelacionados<clsTipoBienRelacionado>();

                entidadTiposBienRelacionados.ErrorDatos = true;
                entidadTiposBienRelacionados.DescripcionError = Mensajes.Obtener(Mensajes._errorCargaTipoBienRelacionado, Mensajes.ASSEMBLY);

                string desError = "Error al obtener la trama: " + ex.Message;
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaTipoBienRelacionadDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                tramaObtenida = string.Empty;
            }

            if (tramaObtenida.Length > 0)
            {
                entidadTiposBienRelacionados = new clsTiposBienRelacionados<clsTipoBienRelacionado>(tramaObtenida);
            }

            return entidadTiposBienRelacionados;
        }

        #endregion
    }
}
