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
    /// Administra las acciones a seguir con los tipos de pólizas SUGEF.
    /// </summary>
    public class TiposPolizasSugef
    {
        #region Métodos Públicos

        /// <summary>
        /// Inserta un registro del tipo de póliza SUGEF
        /// </summary>
        /// <param name="codigoTipoPolizaSugef">Código del tipo de póliza SUGEF.</param>
        /// <param name="nombreTiopPolizaSugef">Nombre del tipo de póliza SUGEF.</param>
        /// <param name="descripcionTiopPolizaSugef">Descripción del tipo de póliza SUGEF.</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public void Crear(int codigoTipoPolizaSugef, string nombreTiopPolizaSugef, string descripcionTiopPolizaSugef, string usuario, string ip)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piConsecutivo_Registro", SqlDbType.Int),
                        new SqlParameter("psNombre_Tipo_Poliza", SqlDbType.VarChar, 50),
                        new SqlParameter("psDescripcion_Tipo_Poliza", SqlDbType.VarChar, 500),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                parameters[0].Value = codigoTipoPolizaSugef;
                parameters[1].Value = nombreTiopPolizaSugef;
                parameters[2].Value = descripcionTiopPolizaSugef;
                parameters[3].Direction = ParameterDirection.Output;

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Insertar_Tipo_Poliza_Sugef", parameters);

                    respuestaObtenida = parameters[3].Value.ToString();

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
                            throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoTipoPolizaSugef, Mensajes.ASSEMBLY));
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
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoTipoPolizaSugefDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoTipoPolizaSugef, Mensajes.ASSEMBLY));
            }

            #region Inserción en Bitácora

            Bitacora oBitacora = new Bitacora();

            #region Armar String de Inserción del registro

            string insertaTipoPolizasSugef = "INSERT INTO dbo.CAT_TIPOS_POLIZAS_SUGEF" +
              "(Codigo_Tipo_Poliza_Sugef, Nombre_Tipo_Poliza, Descripcion_Tipo_Poliza)" +
              "VALUES (" + codigoTipoPolizaSugef.ToString() + "," + nombreTiopPolizaSugef + "," + descripcionTiopPolizaSugef + ")";

            #endregion

            oBitacora.InsertarBitacora(clsTipoPolizaSugef._tipoPolizaSugef, usuario, ip, null,
                1, null, string.Empty, string.Empty, insertaTipoPolizasSugef, string.Empty,
                clsTipoPolizaSugef._codigoTipoPolizaSugef, string.Empty, codigoTipoPolizaSugef.ToString());

            oBitacora.InsertarBitacora(clsTipoPolizaSugef._tipoPolizaSugef, usuario, ip, null,
                1, null, string.Empty, string.Empty, insertaTipoPolizasSugef, string.Empty,
                clsTipoPolizaSugef._nombreTipoPolizaSugef, string.Empty, nombreTiopPolizaSugef);

            oBitacora.InsertarBitacora(clsTipoPolizaSugef._tipoPolizaSugef, usuario, ip, null,
                1, null, string.Empty, string.Empty, insertaTipoPolizasSugef, string.Empty,
                clsTipoPolizaSugef._descripcionTipoPolizaSugef, string.Empty, descripcionTiopPolizaSugef);

            #endregion
        }

        /// <summary>
        /// Modifica un registro del tipo de póliza SUGEF
        /// </summary>
        /// <param name="entidadTipoPolizaSugef">Entidad del tipo de póliza SUGEF que posee los datos a modificar</param>
        /// <param name="entidadTipoPolizaSugefAnterior">Entidad del tipo de póliza SUGEF que posee los datos originales</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public void Modificar(clsTipoPolizaSugef entidadTipoPolizaSugef, clsTipoPolizaSugef entidadTipoPolizaSugefAnterior, string usuario, string ip)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (entidadTipoPolizaSugef != null)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piConsecutivo_Registro", SqlDbType.Int),
                        new SqlParameter("psNombre_Tipo_Poliza", SqlDbType.VarChar, 50),
                        new SqlParameter("psDescripcion_Tipo_Poliza", SqlDbType.VarChar, 500),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = entidadTipoPolizaSugef.TipoPolizaSugef;
                    parameters[1].Value = entidadTipoPolizaSugef.NombreTipoPolizaSugef;
                    parameters[2].Value = ((entidadTipoPolizaSugef.DescripcionTipoPolizaSugef.Length > 0) ? entidadTipoPolizaSugef.DescripcionTipoPolizaSugef : null);
                    parameters[3].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Modificar_Tipo_Poliza_Sugef", parameters);

                        respuestaObtenida = parameters[3].Value.ToString();

                        oConexion.Close();
                        oConexion.Dispose();
                    }

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {
                            throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorModificandoTipoPolizaSugef, Mensajes.ASSEMBLY));
                        }
                    }
                }
                catch (Exception ex)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorModificandoTipoPolizaSugefDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorModificandoTipoPolizaSugef, Mensajes.ASSEMBLY));
                }

                #region Inserción en Bitácora

                Bitacora oBitacora = new Bitacora();


                string actualizacionNombreTipoPolizaSugef = ((entidadTipoPolizaSugef.NombreTipoPolizaSugef.CompareTo(entidadTipoPolizaSugefAnterior.NombreTipoPolizaSugef) != 0) ? (" Nombre_Tipo_Poliza = " + entidadTipoPolizaSugef.NombreTipoPolizaSugef + ",") : string.Empty);
                string actualizacionDescripcionTipoPolizaSugef = ((entidadTipoPolizaSugef.DescripcionTipoPolizaSugef.CompareTo(entidadTipoPolizaSugefAnterior.DescripcionTipoPolizaSugef) != 0) ? (" Descripcion_Tipo_Poliza = " + entidadTipoPolizaSugef.DescripcionTipoPolizaSugef) : string.Empty);

                if ((actualizacionNombreTipoPolizaSugef.Length > 0) || (actualizacionDescripcionTipoPolizaSugef.Length > 0))
                {
                    string camposAjustados = actualizacionNombreTipoPolizaSugef + actualizacionDescripcionTipoPolizaSugef;
                    camposAjustados = camposAjustados.TrimEnd(",".ToCharArray());

                    string modificaTiposPolizasSugef = "UPDATE dbo.CAT_TIPOS_POLIZAS_SUGEF SET" + camposAjustados +
                        " WHERE	Codigo_Tipo_Poliza_Sugef = " + entidadTipoPolizaSugef.TipoPolizaSugef.ToString();

                    if (actualizacionNombreTipoPolizaSugef.Length > 0)
                    {
                        oBitacora.InsertarBitacora(clsTipoPolizaSugef._tipoPolizaSugef, usuario, ip, null,
                            2, null, string.Empty, string.Empty, modificaTiposPolizasSugef, string.Empty,
                            clsTipoPolizaSugef._nombreTipoPolizaSugef, entidadTipoPolizaSugefAnterior.NombreTipoPolizaSugef, entidadTipoPolizaSugef.NombreTipoPolizaSugef);
                    }

                    if (actualizacionDescripcionTipoPolizaSugef.Length > 0)
                    {
                        oBitacora.InsertarBitacora(clsTipoPolizaSugef._tipoPolizaSugef, usuario, ip, null,
                            2, null, string.Empty, string.Empty, modificaTiposPolizasSugef, string.Empty,
                            clsTipoPolizaSugef._descripcionTipoPolizaSugef, entidadTipoPolizaSugefAnterior.DescripcionTipoPolizaSugef, entidadTipoPolizaSugef.DescripcionTipoPolizaSugef);
                    }
                }


                #endregion
            }
        }

        /// <summary>
        /// Elimina un registro del tipo de póliza SUGEF
        /// </summary>
        /// <param name="entidadTipoPolizaSugef">Entidad del tipo de póliza SUGEF que posee los datos a modificar</param>
        /// <param name="usuario">Usuario que elimina el registro</param>
        /// <param name="ip">Dirección desde donde se elimina el registro</param>
        public void Eliminar(clsTipoPolizaSugef entidadTipoPolizaSugef, string usuario, string ip)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (entidadTipoPolizaSugef != null)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piConsecutivo_Registro", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = entidadTipoPolizaSugef.TipoPolizaSugef;
                    parameters[1].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Eliminar_Tipo_Poliza_Sugef", parameters);

                        respuestaObtenida = parameters[1].Value.ToString();

                        oConexion.Close();
                        oConexion.Dispose();
                    }

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {
                            throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorEliminandoTipoPolizaSugef, Mensajes.ASSEMBLY));
                        }
                    }
                }
                catch (Exception ex)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorEliminandoTipoPolizaSugefDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorEliminandoTipoPolizaSugef, Mensajes.ASSEMBLY));
                }

                #region Inserción en Bitácora

                Bitacora oBitacora = new Bitacora();

                string eliminaTipoPolizasSugef = "DELETE  FROM dbo.CAT_TIPOS_POLIZAS_SUGEF" +
                    " WHERE	Codigo_Tipo_Poliza_Sugef = " + entidadTipoPolizaSugef.TipoPolizaSugef.ToString();

                oBitacora.InsertarBitacora(clsTipoPolizaSugef._tipoPolizaSugef, usuario, ip, null,
                    3, null, string.Empty, string.Empty, eliminaTipoPolizasSugef, string.Empty,
                    clsTipoPolizaSugef._codigoTipoPolizaSugef, entidadTipoPolizaSugef.TipoPolizaSugef.ToString(), string.Empty);

                oBitacora.InsertarBitacora(clsTipoPolizaSugef._tipoPolizaSugef, usuario, ip, null,
                    3, null, string.Empty, string.Empty, eliminaTipoPolizasSugef, string.Empty,
                    clsTipoPolizaSugef._nombreTipoPolizaSugef, entidadTipoPolizaSugef.NombreTipoPolizaSugef, string.Empty);

                oBitacora.InsertarBitacora(clsTipoPolizaSugef._tipoPolizaSugef, usuario, ip, null,
                    3, null, string.Empty, string.Empty, eliminaTipoPolizasSugef, string.Empty,
                    clsTipoPolizaSugef._descripcionTipoPolizaSugef, entidadTipoPolizaSugef.DescripcionTipoPolizaSugef, string.Empty);

                #endregion
            }
        }

        /// <summary>
        /// Obtiene la lista de tipos de pólizas SUGEF
        /// </summary>
        /// <param name="tipoPolizaSugef">Código del tipo de póliza SUGEF del cual se requiere la información, el dato puede ser nulo.</param>
        /// <param name="indicadorRegistroBlanco">Indicador que determina si se requiere la opción en blanco, donde True: Se obtiene, False: No se obtiene.</param>
        /// <param name="consecutivoSiguiente">Obtiene el siguiente consecutivo a insertar.</param>
        /// <returns>Enditad del tipo índice de actualización de avalúos</returns>
        public clsTiposPolizasSugef<clsTipoPolizaSugef> ObtenerTiposPolizasSugef(int? tipoPolizaSugef, bool indicadorRegistroBlanco, out int consecutivoSiguiente)
        {
            clsTiposPolizasSugef<clsTipoPolizaSugef> entidadTiposPolizasSugef = null;

            string tramaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            int consecutivoRetornado = -1;

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piConsecutivo_Registro", SqlDbType.Int),
                        new SqlParameter("pbRegistro_Blanco", SqlDbType.Bit),
                        new SqlParameter("piConsecutivo_Proximo_Registro", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                 };

                parameters[0].Value = ((tipoPolizaSugef.HasValue) ? ((object)tipoPolizaSugef) : ((object)DBNull.Value));
                parameters[1].Value = ((indicadorRegistroBlanco) ? 1 : 0);
                parameters[2].Direction = ParameterDirection.Output;
                parameters[3].Direction = ParameterDirection.Output;

                SqlParameter[] parametrosSalida = new SqlParameter[] { };

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    tramaObtenida = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Consultar_Tipo_Poliza_Sugef", out parametrosSalida, parameters);

                    if ((parameters[2].Value != null) && (parameters[2].Value.ToString().Length > 0))
                    {
                        int consecutivoNuevo;

                        consecutivoRetornado = ((int.TryParse(parameters[2].Value.ToString(), out consecutivoNuevo)) ? consecutivoNuevo : -1);
                    }

                    oConexion.Close();
                    oConexion.Dispose();
                }
            }
            catch (Exception ex)
            {
                entidadTiposPolizasSugef = new clsTiposPolizasSugef<clsTipoPolizaSugef>();

                entidadTiposPolizasSugef.ErrorDatos = true;
                entidadTiposPolizasSugef.DescripcionError = Mensajes.Obtener(Mensajes._errorCargaTipoPolizaSugef, Mensajes.ASSEMBLY);

                string desError = "Error al obtener la trama: " + ex.Message;
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaTipoPolizaSugefDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                tramaObtenida = string.Empty;
            }

            if (tramaObtenida.Length > 0)
            {
                entidadTiposPolizasSugef = new clsTiposPolizasSugef<clsTipoPolizaSugef>(tramaObtenida);
            }

            consecutivoSiguiente = consecutivoRetornado;

            return entidadTiposPolizasSugef;
        }

        #endregion
    }
}
