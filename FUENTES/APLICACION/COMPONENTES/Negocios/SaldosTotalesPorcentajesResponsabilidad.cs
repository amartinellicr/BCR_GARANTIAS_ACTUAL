using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Collections.Specialized;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;


namespace BCRGARANTIAS.Negocios
{
    public class SaldosTotalesPorcentajesResponsabilidad
    {
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };

        #endregion Variables Globales

        #region Metodos Públicos

        /// <summary>
        /// Inserta un registro de saldo total y porcentaje de responsabilidad
        /// </summary>
        /// <param name="entidadSaldoTotalPorcentajeResp">Entidad de saldo total y porcentaje de responsabilidad.</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public void Insertar(clsSaldoTotalPorcentajeResponsabilidad entidadSaldoTotalPorcentajeResponsabilidad, string usuario, string ip)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            try
            {
                SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("piConsecutivo_Operacion", SqlDbType.BigInt),
                        new SqlParameter("piConsecutivo_Garantia", SqlDbType.BigInt),
                        new SqlParameter("piCodigo_Tipo_Garantia", SqlDbType.SmallInt),
                        new SqlParameter("pdSaldo_Actual_Ajustado", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Responsabilidad_Ajustado", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Responsabilidad_Calculado", SqlDbType.Decimal),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar,30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };
                              
                parameters[0].Value = entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoOperacion;
                parameters[1].Value = entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoGarantia;
                parameters[2].Value = entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia;
                parameters[3].Value = entidadSaldoTotalPorcentajeResponsabilidad.SaldoActualAjustado;
                parameters[4].Value = entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadAjustado;
                parameters[5].Value = entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadCalculado;
                parameters[6].Value = usuario;
                parameters[7].Direction = ParameterDirection.Output;


                AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Insertar_Saldo_Total_Porcentaje_Responsabilidad", parameters);

                respuestaObtenida = parameters[7].Value.ToString();


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
                            throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoSaldoTotalPr, Mensajes.ASSEMBLY));
                        }
                    }
                }
            }
            catch (ExcepcionBase ex)
            {
                string datoGarantia = string.Format("{0}, Tipo Garantia: {1}", entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString());

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                StringCollection parametro = new StringCollection();
                parametro.Add(datoGarantia);
                parametro.Add(entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga);
                parametro.Add(detalleTecnico);
                
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoSaldoTotalPrDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                throw ex;
            }
            catch (SqlException ex)
            {
                string datoGarantia = string.Format("{0}, Tipo Garantia: {1}", entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString());

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                StringCollection parametro = new StringCollection();
                parametro.Add(datoGarantia);
                parametro.Add(entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga);
                parametro.Add(detalleTecnico);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoSaldoTotalPrDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoSaldoTotalPr, Mensajes.ASSEMBLY));
            }
            catch (Exception ex)
            {
                string datoGarantia = string.Format("{0}, Tipo Garantia: {1}", entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString());

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                StringCollection parametro = new StringCollection();
                parametro.Add(datoGarantia);
                parametro.Add(entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga);
                parametro.Add(detalleTecnico);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoSaldoTotalPrDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoSaldoTotalPr, Mensajes.ASSEMBLY));
            }

            #region Inserción en Bitácora

            Bitacora oBitacora = new Bitacora();

            #region Armar String de Inserción del registro

            listaCampos = new string[] {clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp,
                                        clsSaldoTotalPorcentajeResponsabilidad._consecutivoOperacion, clsSaldoTotalPorcentajeResponsabilidad._consecutivoGarantia, 
                                        clsSaldoTotalPorcentajeResponsabilidad._codigoTipoGarantia, clsSaldoTotalPorcentajeResponsabilidad._saldoActualAjustado,
                                        clsSaldoTotalPorcentajeResponsabilidad._porcentajeResponsabilidadAjustado, clsSaldoTotalPorcentajeResponsabilidad._porcentajeResponsabilidadCalculado,
                                        entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoOperacion.ToString(), entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoGarantia.ToString(),
                                        entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString(),  entidadSaldoTotalPorcentajeResponsabilidad.SaldoActualAjustado.ToString(),
                                        entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadAjustado.ToString(),
                                        entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadCalculado.ToString()};

            string insertaPorcentajeAceptacion = string.Format("INSERT INTO dbo.{0} ({1}, {2}, {3}, {4}, {5}, {6}) VALUES( {7}, {8}, {9}, {10}, {11})", listaCampos);

            #endregion

            oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
                1, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, insertaPorcentajeAceptacion, string.Empty,
                clsSaldoTotalPorcentajeResponsabilidad._consecutivoOperacion, string.Empty, entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoOperacion.ToString());

            oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
               1, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, insertaPorcentajeAceptacion, string.Empty,
               clsSaldoTotalPorcentajeResponsabilidad._consecutivoGarantia, string.Empty, entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoGarantia.ToString());

            oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
              1, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, insertaPorcentajeAceptacion, string.Empty,
              clsSaldoTotalPorcentajeResponsabilidad._codigoTipoGarantia, string.Empty, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString());

            oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
             1, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, insertaPorcentajeAceptacion, string.Empty,
             clsSaldoTotalPorcentajeResponsabilidad._saldoActualAjustado, string.Empty, ((entidadSaldoTotalPorcentajeResponsabilidad.SaldoActualAjustado > -1) ? entidadSaldoTotalPorcentajeResponsabilidad.SaldoActualAjustado.ToString("N2") : "-1"));

            oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
             1, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, insertaPorcentajeAceptacion, string.Empty,
             clsSaldoTotalPorcentajeResponsabilidad._porcentajeResponsabilidadAjustado, string.Empty, ((entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadAjustado > -1) ? entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadAjustado.ToString("N2") : "-1"));

            oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
            1, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, insertaPorcentajeAceptacion, string.Empty,
            clsSaldoTotalPorcentajeResponsabilidad._porcentajeResponsabilidadCalculado, string.Empty, ((entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadCalculado > -1) ? entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadCalculado.ToString("N2") : "-1"));


            #endregion

        }


        /// <summary>
        /// Modifica un registro del saldo total y porcentaje de responsabilidad
        /// </summary>
        /// <param name="entidadSaldoTotalPorcentajeResponsabilidad">Entidad del tipo de saldo total y porcentaje de responsabilidad que posee los datos a modificar</param>
        /// <param name="entidadSaldoTotalPorcentajeResponsabilidadAnterior">Entidad del tipo de saldo total y porcentaje de responsabilidad que posee los datos originales</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public void Modificar(clsSaldoTotalPorcentajeResponsabilidad entidadSaldoTotalPorcentajeResponsabilidad, clsSaldoTotalPorcentajeResponsabilidad entidadSaldoTotalPorcentajeResponsabilidadAnterior, string usuario, string ip)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };
            string modificaPorcentajeAceptacion = string.Empty;

            if (entidadSaldoTotalPorcentajeResponsabilidad != null)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("piConsecutivo_Operacion", SqlDbType.BigInt),
                        new SqlParameter("piConsecutivo_Garantia", SqlDbType.BigInt),
                        new SqlParameter("piCodigo_Tipo_Garantia", SqlDbType.SmallInt),
                        new SqlParameter("pdSaldo_Actual_Ajustado", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Responsabilidad_Ajustado", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Responsabilidad_Calculado", SqlDbType.Decimal),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar,30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoOperacion;
                    parameters[1].Value = entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoGarantia;
                    parameters[2].Value = entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia;
                    parameters[3].Value = entidadSaldoTotalPorcentajeResponsabilidad.SaldoActualAjustado;
                    parameters[4].Value = entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadAjustado;
                    parameters[5].Value = entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadCalculado;
                    parameters[6].Value = usuario;
                    parameters[7].Direction = ParameterDirection.Output;


                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Modificar_Saldo_Total_Porcentaje_Responsabilidad", parameters);

                    respuestaObtenida = parameters[7].Value.ToString();


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
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorModificandoSaldoTotalPr, Mensajes.ASSEMBLY));
                            }
                        }


                    }
                }
                catch (ExcepcionBase ex)
                {
                    string datoGarantia = string.Format("{0}, Tipo Garantia: {1}", entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString());

                    string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                    StringCollection parametro = new StringCollection();
                    parametro.Add(datoGarantia);
                    parametro.Add(entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga);
                    parametro.Add(detalleTecnico);

                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorModificandoSaldoTotalPrDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    throw ex;
                }
                catch (SqlException ex)
                {
                    string datoGarantia = string.Format("{0}, Tipo Garantia: {1}", entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString());

                    string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                    StringCollection parametro = new StringCollection();
                    parametro.Add(datoGarantia);
                    parametro.Add(entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga);
                    parametro.Add(detalleTecnico);

                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorModificandoSaldoTotalPrDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorModificandoSaldoTotalPr, Mensajes.ASSEMBLY));
                }
                catch (Exception ex)
                {
                    string datoGarantia = string.Format("{0}, Tipo Garantia: {1}", entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString());

                    string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                    StringCollection parametro = new StringCollection();
                    parametro.Add(datoGarantia);
                    parametro.Add(entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga);
                    parametro.Add(detalleTecnico);

                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorModificandoSaldoTotalPrDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorModificandoSaldoTotalPr, Mensajes.ASSEMBLY));
                }

                #region Inserción en Bitácora

                Bitacora oBitacora = new Bitacora();

                string actualizacionSaldoTotal = (((entidadSaldoTotalPorcentajeResponsabilidad.SaldoActualAjustado != entidadSaldoTotalPorcentajeResponsabilidadAnterior.SaldoActualAjustado) && (entidadSaldoTotalPorcentajeResponsabilidad.SaldoActualAjustado > -1)) ? (string.Format("{0} = {1}, ", clsSaldoTotalPorcentajeResponsabilidad._saldoActualAjustado, entidadSaldoTotalPorcentajeResponsabilidad.SaldoActualAjustado.ToString())) : string.Empty);
                string actualizacionProcentajeResponsabilidad = (((entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadAjustado != entidadSaldoTotalPorcentajeResponsabilidadAnterior.PorcentajeResponsabilidadAjustado) && (entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadAjustado > -1)) ? (string.Format("{0} = {1} ", clsSaldoTotalPorcentajeResponsabilidad._porcentajeResponsabilidadAjustado, entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadAjustado.ToString())) : string.Empty);
                string actualizacionProcentajeResponsabilidadCalculado = (((entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadCalculado != entidadSaldoTotalPorcentajeResponsabilidadAnterior.PorcentajeResponsabilidadCalculado) && (entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadCalculado > -1)) ? (string.Format("{0} = {1} ", clsSaldoTotalPorcentajeResponsabilidad._porcentajeResponsabilidadCalculado, entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadCalculado.ToString())) : string.Empty);
                                
                if ((actualizacionSaldoTotal.Length > 0) || (actualizacionProcentajeResponsabilidad.Length > 0) || (actualizacionProcentajeResponsabilidadCalculado.Length > 0))
                {
                    listaCampos = new string[] {actualizacionSaldoTotal, actualizacionProcentajeResponsabilidad, actualizacionProcentajeResponsabilidadCalculado };

                    string camposAjustados = string.Format("{0}{1}{2}", listaCampos);

                    camposAjustados = camposAjustados.TrimEnd(",".ToCharArray());

                    listaCampos = new string[] {clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp,
                                                camposAjustados,
                                                clsSaldoTotalPorcentajeResponsabilidad._consecutivoOperacion, entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoOperacion.ToString(),
                                                clsSaldoTotalPorcentajeResponsabilidad._consecutivoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoGarantia.ToString(),
                                                clsSaldoTotalPorcentajeResponsabilidad._codigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString()};

                    modificaPorcentajeAceptacion = string.Format("UPDATE dbo.{0} SET {1} WHERE {2} = {3} AND {4} = {5} AND {6} = {7}", listaCampos);

                    if (actualizacionSaldoTotal.Length > 0)
                    {
                        oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
                            2, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, modificaPorcentajeAceptacion, string.Empty,
                            clsSaldoTotalPorcentajeResponsabilidad._saldoActualAjustado, entidadSaldoTotalPorcentajeResponsabilidadAnterior.SaldoActualAjustado.ToString("N2"), entidadSaldoTotalPorcentajeResponsabilidad.SaldoActualAjustado.ToString("N2"));
                    }

                    if (actualizacionProcentajeResponsabilidad.Length > 0)
                    {
                        oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
                            2, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, modificaPorcentajeAceptacion, string.Empty,
                            clsSaldoTotalPorcentajeResponsabilidad._porcentajeResponsabilidadAjustado, entidadSaldoTotalPorcentajeResponsabilidadAnterior.PorcentajeResponsabilidadAjustado.ToString("N2"), entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadAjustado.ToString("N2"));
                    }

                    if (actualizacionProcentajeResponsabilidadCalculado.Length > 0)
                    {
                        oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
                            2, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, modificaPorcentajeAceptacion, string.Empty,
                            clsSaldoTotalPorcentajeResponsabilidad._porcentajeResponsabilidadCalculado, entidadSaldoTotalPorcentajeResponsabilidadAnterior.PorcentajeResponsabilidadCalculado.ToString("N2"), entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadCalculado.ToString("N2"));
                    }
                }

                #endregion
            }
        }


        /// <summary>
        /// Elimina un registro del tipo de saldo total y porcentaje de responsabilidad
        /// </summary>
        /// <param name="entidadSaldoTotalPorcentajeResponsabilidad">Entidad del tipo de saldo total y porcentaje de responsabilidad que posee los datos a eliminar</param>
        /// <param name="usuario">Usuario que elimina el registro</param>
        /// <param name="ip">Dirección desde donde se elimina el registro</param>
        public void Eliminar(clsSaldoTotalPorcentajeResponsabilidad entidadSaldoTotalPorcentajeResponsabilidad, string usuario, string ip)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (entidadSaldoTotalPorcentajeResponsabilidad != null)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("piConsecutivo_Operacion", SqlDbType.BigInt),
                        new SqlParameter("piConsecutivo_Garantia", SqlDbType.BigInt),
                        new SqlParameter("piCodigo_Tipo_Garantia", SqlDbType.SmallInt),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar,30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoOperacion;
                    parameters[1].Value = entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoGarantia;
                    parameters[2].Value = entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia;
                    parameters[3].Value = usuario;
                    parameters[4].Direction = ParameterDirection.Output;


                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Eliminar_Saldo_Total_Porcentaje_Responsabilidad", parameters);

                    respuestaObtenida = parameters[4].Value.ToString();


                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {
                            throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorEliminandoSaldoTotalPr, Mensajes.ASSEMBLY));
                        }
                    }
                }
                catch (SqlException ex)
                {
                    string datoGarantia = string.Format("{0}, Tipo Garantia: {1}", entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString());

                    string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                    StringCollection parametro = new StringCollection();
                    parametro.Add(datoGarantia);
                    parametro.Add(entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga);
                    parametro.Add(detalleTecnico);

                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorEliminandoSaldoTotalPrDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorEliminandoSaldoTotalPr, Mensajes.ASSEMBLY));
                }
                catch (Exception ex)
                {
                    string datoGarantia = string.Format("{0}, Tipo Garantia: {1}", entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString());

                    string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                    StringCollection parametro = new StringCollection();
                    parametro.Add(datoGarantia);
                    parametro.Add(entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga);
                    parametro.Add(detalleTecnico);

                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorEliminandoSaldoTotalPrDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorEliminandoSaldoTotalPr, Mensajes.ASSEMBLY));
                }

                #region Inserción en Bitácora

                Bitacora oBitacora = new Bitacora();

                listaCampos = new string[] {clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp,
                                            clsSaldoTotalPorcentajeResponsabilidad._consecutivoOperacion, entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoOperacion.ToString(),
                                            clsSaldoTotalPorcentajeResponsabilidad._consecutivoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoGarantia.ToString(),
                                            clsSaldoTotalPorcentajeResponsabilidad._codigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString()};

                string eliminaPorcentajeAceptacion = string.Format("DELETE FROM dbo.{0} WHERE {1} = {2} AND {3} = {4} AND {5} = {6}", listaCampos);

                oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
                 3, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, eliminaPorcentajeAceptacion, string.Empty,
                 clsSaldoTotalPorcentajeResponsabilidad._saldoActualAjustado, entidadSaldoTotalPorcentajeResponsabilidad.SaldoActualAjustado.ToString(), string.Empty);

                oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
                   3, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, eliminaPorcentajeAceptacion, string.Empty,
                   clsSaldoTotalPorcentajeResponsabilidad._porcentajeResponsabilidadAjustado, entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadAjustado.ToString(), string.Empty);

                oBitacora.InsertarBitacora(clsSaldoTotalPorcentajeResponsabilidad._entidadSaldoTotalPorcentajeResp, usuario, ip, null,
                  3, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia, entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga, eliminaPorcentajeAceptacion, string.Empty,
                  clsSaldoTotalPorcentajeResponsabilidad._porcentajeResponsabilidadCalculado, entidadSaldoTotalPorcentajeResponsabilidad.PorcentajeResponsabilidadCalculado.ToString(), string.Empty);

                #endregion
            }
        }

        /// <summary>
        /// Obtiene el saldo total y porcentaje de responsabilidad
        /// </summary>
        /// <param name="entidadSaldoTotalPorcentajeResponsabilidad">Entidad del tipo de saldo total y porcentaje de responsabilidad que posee los datos a consultar</param>
        /// <param name="usuario">Usuario que realiza la consulta el registro</param>
        /// <returns>Enditad del tipo saldo total y porcentaje de responsabilidad</returns>
        public clsSaldoTotalPorcentajeResponsabilidad ObtenerDatosSaldoTotalPorcentajeResponsabilidad(clsSaldoTotalPorcentajeResponsabilidad entidadSaldoTotalPorcentajeResponsabilidad, string usuario)
        {
            DataSet dsDatosObtenidos = new DataSet();
            clsSaldoTotalPorcentajeResponsabilidad entidadRetornada = new clsSaldoTotalPorcentajeResponsabilidad();
            try
            {

                SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("piConsecutivo_Garantia", SqlDbType.BigInt),
                        new SqlParameter("piCodigo_Tipo_Garantia", SqlDbType.SmallInt),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar,30)
                    };

                parameters[0].Value = entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoGarantia;
                parameters[1].Value = entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia;
                parameters[2].Value = usuario;
                

                SqlParameter[] parametrosSalida = new SqlParameter[] { };

                dsDatosObtenidos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "Consultar_Saldo_Total_Porcentaje_Responsabilidad", parameters, 0);

                if((dsDatosObtenidos != null) && (dsDatosObtenidos.Tables.Count > 0) && (dsDatosObtenidos.Tables[0].Rows.Count > 0))
                {
                    entidadRetornada = new clsSaldoTotalPorcentajeResponsabilidad(dsDatosObtenidos);
                }                
            }
            catch (SqlException ex)
            {
                string datoGarantia = string.Format("{0}, Tipo Garantia: {1}", entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString());

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                StringCollection parametro = new StringCollection();
                parametro.Add(datoGarantia);
                parametro.Add(entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga);
                parametro.Add(detalleTecnico);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConsultandoSaldoTotalPrDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);
           }
            catch (Exception ex)
            {
                string datoGarantia = string.Format("{0}, Tipo Garantia: {1}", entidadSaldoTotalPorcentajeResponsabilidad.IdentificacionGarantia, entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia.ToString());

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                StringCollection parametro = new StringCollection();
                parametro.Add(datoGarantia);
                parametro.Add(entidadSaldoTotalPorcentajeResponsabilidad.OperacionLarga);
                parametro.Add(detalleTecnico);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConsultandoSaldoTotalPrDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }

            return entidadRetornada;
        }


        /// <summary>
        /// Obtiene el saldo total y porcentaje de responsabilidad de las operaciones relacionadas a una determinada garantía fiduciaria
        /// </summary>
        /// <param name="entidadGarantiaFiduciaria">Entidad del tipo garantía fiduciaria que posee los datos a consultar</param>
        /// <param name="usuario">Usuario que realiza la consulta el registro</param>
        /// <returns>Enditad del tipo lista de entidades del tipo saldo total y porcentaje de responsabilidad</returns>
        public clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> ObtenerOperacionesPorGarantiaFiduciaria(clsGarantiaFiduciaria entidadGarantiaFiduciaria, string usuario)
        {
            DataSet dsDatosObtenidos = new DataSet();
            clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> entidadRetornada = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>();

            try
            {

                SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("pdIdentificacion_Fiador", SqlDbType.Decimal),
                        new SqlParameter("piTipo_Persona_Fiador", SqlDbType.SmallInt),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar,30)
                    };

  
                parameters[0].Value = entidadGarantiaFiduciaria.IndentificacionSicc;
                parameters[1].Value = entidadGarantiaFiduciaria.CodigoTipoPersonaFiador;
                parameters[2].Value = usuario;


                SqlParameter[] parametrosSalida = new SqlParameter[] { };

                dsDatosObtenidos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "Obtener_Operaciones_por_Garantia_Fiduciaria", parameters, 0);

                if ((dsDatosObtenidos != null) && (dsDatosObtenidos.Tables.Count > 0) && (dsDatosObtenidos.Tables[0].Rows.Count > 0))
                {
                    entidadRetornada = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>(dsDatosObtenidos);
                }
            }
            catch (SqlException ex)
            {
                string datoGarantia = string.Format("'{0}', Tipo Persona: {1}", entidadGarantiaFiduciaria.IndentificacionSicc.ToString(), entidadGarantiaFiduciaria.CodigoTipoPersonaFiador.ToString());

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                StringCollection parametro = new StringCollection();
                parametro.Add(datoGarantia);
                parametro.Add(detalleTecnico);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConsultandoOperacionesRelacionadasGarantiaDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }
            catch (Exception ex)
            {
                string datoGarantia = string.Format("'{0}', Tipo Persona: {1}", entidadGarantiaFiduciaria.IndentificacionSicc.ToString(), entidadGarantiaFiduciaria.CodigoTipoPersonaFiador.ToString());

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                StringCollection parametro = new StringCollection();
                parametro.Add(datoGarantia);
                parametro.Add(detalleTecnico);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConsultandoOperacionesRelacionadasGarantiaDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }

            return entidadRetornada;
        }


        /// <summary>
        /// Obtiene el saldo total y porcentaje de responsabilidad de las operaciones relacionadas a una determinada garantía real
        /// </summary>
        /// <param name="entidadGarantiaReal">Entidad del tipo garantía real que posee los datos a consultar</param>
        /// <param name="usuario">Usuario que realiza la consulta el registro</param>
        /// <returns>Enditad del tipo lista de entidades del tipo saldo total y porcentaje de responsabilidad</returns>
        public clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> ObtenerOperacionesPorGarantiaReal(clsGarantiaReal entidadGarantiaReal, string usuario)
        {
            DataSet dsDatosObtenidos = new DataSet();
            clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> entidadRetornada = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>();

            try
            {

                SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("psIdentificacion_Bien", SqlDbType.VarChar,25),
                        new SqlParameter("piCodigo_Clase_Garantia", SqlDbType.SmallInt),
                        new SqlParameter("piCodigo_Partido", SqlDbType.SmallInt),
                        new SqlParameter("psCodigo_Grado", SqlDbType.VarChar,2),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar,30)
                    };


                parameters[0].Value = ((entidadGarantiaReal.CodTipoGarantiaReal == ((short) Enumeradores.Tipos_Garantia_Real.Prenda)) ? entidadGarantiaReal.NumPlacaBien : entidadGarantiaReal.NumeroFinca);
                parameters[1].Value = entidadGarantiaReal.CodClaseGarantia;
                parameters[2].IsNullable = true;
                parameters[2].Value = ((entidadGarantiaReal.CodTipoGarantiaReal != ((short)Enumeradores.Tipos_Garantia_Real.Prenda)) ? entidadGarantiaReal.CodPartido : ((object) DBNull.Value));
                parameters[3].IsNullable = true;
                parameters[3].Value = ((entidadGarantiaReal.CodTipoGarantiaReal == ((short)Enumeradores.Tipos_Garantia_Real.Cedula_Hipotecaria)) ? entidadGarantiaReal.CodGrado : ((object)DBNull.Value));
                parameters[4].Value = usuario;

                SqlParameter[] parametrosSalida = new SqlParameter[] { };

                dsDatosObtenidos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "Obtener_Operaciones_por_Garantia_Real", parameters, 0);

                if ((dsDatosObtenidos != null) && (dsDatosObtenidos.Tables.Count > 0) && (dsDatosObtenidos.Tables[0].Rows.Count > 0))
                {
                    entidadRetornada = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>(dsDatosObtenidos);
                }
            }
            catch (SqlException ex)
            {
                string datoGarantia = string.Format("'{0}'", entidadGarantiaReal.GarantiaRealBitacora);

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                StringCollection parametro = new StringCollection();
                parametro.Add(datoGarantia);
                parametro.Add(detalleTecnico);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConsultandoOperacionesRelacionadasGarantiaDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }
            catch (Exception ex)
            {
                string datoGarantia = string.Format("'{0}'", entidadGarantiaReal.GarantiaRealBitacora);

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                StringCollection parametro = new StringCollection();
                parametro.Add(datoGarantia);
                parametro.Add(detalleTecnico);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConsultandoOperacionesRelacionadasGarantiaDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }

            return entidadRetornada;
        }

        /// <summary>
        /// Obtiene el saldo total y porcentaje de responsabilidad de las operaciones relacionadas a una determinada garantía valor
        /// </summary>
        /// <param name="entidadGarantiaValor">Entidad del tipo garantía valor que posee los datos a consultar</param>
        /// <param name="usuario">Usuario que realiza la consulta el registro</param>
        /// <returns>Enditad del tipo lista de entidades del tipo saldo total y porcentaje de responsabilidad</returns>
        public clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> ObtenerOperacionesPorGarantiaReal(clsGarantiaValor entidadGarantiaValor, string usuario)
        {
            DataSet dsDatosObtenidos = new DataSet();
            clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> entidadRetornada = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>();

            try
            {

                SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("psNumero_Seguridad", SqlDbType.VarChar,25),
                        new SqlParameter("piCodigo_Clase_Garantia", SqlDbType.SmallInt),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar,30)
                    };


                parameters[0].Value = entidadGarantiaValor.NumeroSeguridad;
                parameters[1].Value = entidadGarantiaValor.CodigoClaseGarantia;
                parameters[4].Value = usuario;

                SqlParameter[] parametrosSalida = new SqlParameter[] { };

                dsDatosObtenidos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "Obtener_Operaciones_por_Garantia_Valor", parameters, 0);

                if ((dsDatosObtenidos != null) && (dsDatosObtenidos.Tables.Count > 0) && (dsDatosObtenidos.Tables[0].Rows.Count > 0))
                {
                    entidadRetornada = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>(dsDatosObtenidos);
                }
            }
            catch (SqlException ex)
            {
                string datoGarantia = string.Format("'{0}'. Clase Garantía: {1}", entidadGarantiaValor.NumeroSeguridad, entidadGarantiaValor.CodigoClaseGarantia.ToString());

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                StringCollection parametro = new StringCollection();
                parametro.Add(datoGarantia);
                parametro.Add(detalleTecnico);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConsultandoOperacionesRelacionadasGarantiaDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }
            catch (Exception ex)
            {
                string datoGarantia = string.Format("'{0}'. Clase Garantía: {1}", entidadGarantiaValor.NumeroSeguridad, entidadGarantiaValor.CodigoClaseGarantia.ToString());

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                StringCollection parametro = new StringCollection();
                parametro.Add(datoGarantia);
                parametro.Add(detalleTecnico);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConsultandoOperacionesRelacionadasGarantiaDetalle, parametro, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }

            return entidadRetornada;
        }


        /// <summary>
        /// Replica el porcentaje de responsabilidad de una misma garantía entre las operaciones relacionadas a la misma
        /// </summary>
        /// <param name="entidadSaldoTotalPorcentajeResponsabilidad">Entidad del tipo saldo total y porcentaje de responsabilidad que posee los datos a normalizar</param>
        /// <returns>Enditad del tipo lista de entidades del tipo saldo total y porcentaje de responsabilidad</returns>
        public bool NormalizarPorcentajeResponsabilidad(clsSaldoTotalPorcentajeResponsabilidad entidadSaldoTotalPorcentajeResponsabilidad)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            bool procesoExitoso = true;

            try
            {

                SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("piConsecutivo_Operacion", SqlDbType.BigInt),
                        new SqlParameter("piConsecutivo_Garantia", SqlDbType.BigInt),
                        new SqlParameter("piCodigo_Tipo_Garantia", SqlDbType.SmallInt),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                parameters[0].Value = entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoOperacion;
                parameters[1].Value = entidadSaldoTotalPorcentajeResponsabilidad.ConsecutivoGarantia;
                parameters[2].Value = entidadSaldoTotalPorcentajeResponsabilidad.CodigoTipoGarantia;
                parameters[3].Direction = ParameterDirection.Output;


                AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Normalizar_Datos_Porcentaje_Responsabilidad", parameters);

                respuestaObtenida = parameters[4].Value.ToString();


                if (respuestaObtenida.Length > 0)
                {
                    strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                    if (strMensajeObtenido[0].CompareTo("0") != 0)
                    {
                        procesoExitoso = false;
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorNormalizandoOperacionesRelacionadasAGarantia, Mensajes.ASSEMBLY));
                    }
                }
            }
            catch (SqlException ex)
            {
                procesoExitoso = false;
                                
                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);
                                
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorNormalizandoOperacionesRelacionadasAGarantiaDetalle, detalleTecnico, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }
            catch (Exception ex)
            {
                procesoExitoso = false;

                string detalleTecnico = string.Format("Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorNormalizandoOperacionesRelacionadasAGarantiaDetalle, detalleTecnico, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }

            return procesoExitoso;
        }


        #endregion  //FIN METODOS PUBLICOS
    }
}
