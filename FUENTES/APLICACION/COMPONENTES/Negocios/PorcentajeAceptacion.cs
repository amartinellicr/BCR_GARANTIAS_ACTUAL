﻿using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Text;
using System.Xml;
using System.Collections.Specialized;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Administra las acciones a seguir con los porcentajes de aceptacion
    /// </summary>

    public class PorcentajeAceptacion
    {
        //FALTA AGREGAR EL METODO DE INSERT DEL HISTORIAL DE PORCENTAJE ACEPTACION


        #region Metodos Públicos

        /// <summary>
        /// Inserta un registro de porcentaje de aceptacion
        /// </summary>
        /// <param name="entidadPorcentajeAceptacion">Entidad de porcentaje de aceptacion.</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public void Insertar(clsPorcentajeAceptacion entidadPorcentajeAceptacion, string usuario, string ip)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piCodigo_Tipo_Garantia", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Mitigador", SqlDbType.Int),
                        new SqlParameter("pbIndicador_Sin_Calificacion", SqlDbType.Bit),
                        new SqlParameter("pdPorcentaje_Aceptacion", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Cero_Tres", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Cuatro", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Cinco", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Seis", SqlDbType.Decimal),
                        new SqlParameter("psUsuario_Inserto", SqlDbType.VarChar,30),         
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                parameters[0].Value = entidadPorcentajeAceptacion.CodigoTipoGarantia;
                parameters[1].Value = entidadPorcentajeAceptacion.CodigoTipoMitigador;
                parameters[2].Value = entidadPorcentajeAceptacion.IndicadorSinCalificacion;
                parameters[3].Value = entidadPorcentajeAceptacion.PorcentajeAceptacion;
                parameters[4].Value = entidadPorcentajeAceptacion.PorcentajeCeroTres;
                parameters[5].Value = entidadPorcentajeAceptacion.PorcentajeCuatro;
                parameters[6].Value = entidadPorcentajeAceptacion.PorcentajeCinco;
                parameters[7].Value = entidadPorcentajeAceptacion.PorcentajeSeis;
                parameters[8].Value = usuario;
                parameters[9].Direction = ParameterDirection.Output;

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Insertar_Porcentaje_Aceptacion", parameters);

                    respuestaObtenida = parameters[9].Value.ToString();
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
                            throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoPorcentajeAceptacion, Mensajes.ASSEMBLY));
                        }
                    }
                }
            }
            catch (ExcepcionBase ex)
            {
               UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoPorcentajeAceptacionDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                throw ex;
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoPorcentajeAceptacionDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoPorcentajeAceptacion, Mensajes.ASSEMBLY));
            }

            #region Inserción en Bitácora

            Bitacora oBitacora = new Bitacora();

            #region Armar String de Inserción del registro

            string insertaPorcentajeAceptacion = "INSERT INTO dbo.CAT_PORCENTAJE_ACEPTACION" +
              "(Codigo_Tipo_Garantia,Codigo_Tipo_Mitigador,Indicador_Sin_Calificacion,Porcentaje_Aceptacion,Porcentaje_Cero_Tres,Porcentaje_Cuatro,Porcentaje_Cinco,"+ 
				"Porcentaje_Seis,Usuario_Inserto)" +

              "VALUES (" + entidadPorcentajeAceptacion.CodigoTipoGarantia.ToString() + "," + entidadPorcentajeAceptacion.CodigoTipoMitigador.ToString() + "," + ((entidadPorcentajeAceptacion.IndicadorSinCalificacion) ? "1" : "0") + "," +
              entidadPorcentajeAceptacion.PorcentajeAceptacion.ToString() + "," + entidadPorcentajeAceptacion.PorcentajeCeroTres.ToString() + "," + entidadPorcentajeAceptacion.PorcentajeCuatro.ToString() + "," +
              entidadPorcentajeAceptacion.PorcentajeCinco.ToString() + "," + entidadPorcentajeAceptacion.PorcentajeSeis.ToString() + "," + usuario + ")";

            #endregion

            //HACER UN REGISTRO POR CAMPO

            oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                1, null, string.Empty, string.Empty, insertaPorcentajeAceptacion, string.Empty,
                clsPorcentajeAceptacion._codigoTipoGarantia, string.Empty, entidadPorcentajeAceptacion.CodigoTipoGarantia.ToString());

            oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
               1, null, string.Empty, string.Empty, insertaPorcentajeAceptacion, string.Empty,
               clsPorcentajeAceptacion._codigoTipoMitigador, string.Empty, entidadPorcentajeAceptacion.CodigoTipoMitigador.ToString());

            oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
              1, null, string.Empty, string.Empty, insertaPorcentajeAceptacion, string.Empty,
              clsPorcentajeAceptacion._indicadorSinCalificacion, string.Empty, ((entidadPorcentajeAceptacion.IndicadorSinCalificacion) ? "1" : "0"));

            oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
             1, null, string.Empty, string.Empty, insertaPorcentajeAceptacion, string.Empty,
             clsPorcentajeAceptacion._porcentajeAceptacion, string.Empty, entidadPorcentajeAceptacion.PorcentajeAceptacion.ToString());

            //AGREGAR VALIDACION CUANDO ES CON INDICADOR, EN ESTE REQUERIMIENTO NO SE CONTEMPLA TODAVIA LA CALIFICACION.

            //oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
            //1, null, string.Empty, string.Empty, insertaPorcentajeAceptacion, string.Empty,
            //clsPorcentajeAceptacion._porcentajeCeroTres, string.Empty, entidadPorcentajeAceptacion.PorcentajeCeroTres.ToString());

            //oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
            // 1, null, string.Empty, string.Empty, insertaPorcentajeAceptacion, string.Empty,
            // clsPorcentajeAceptacion._porcentajeCuatro, string.Empty, entidadPorcentajeAceptacion.PorcentajeCuatro.ToString());

            //oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
            //1, null, string.Empty, string.Empty, insertaPorcentajeAceptacion, string.Empty,
            //clsPorcentajeAceptacion._porcentajeCinco, string.Empty, entidadPorcentajeAceptacion.PorcentajeCinco.ToString());

            //oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
            //  1, null, string.Empty, string.Empty, insertaPorcentajeAceptacion, string.Empty,
            //  clsPorcentajeAceptacion._porcentajeSeis, string.Empty, entidadPorcentajeAceptacion.PorcentajeSeis.ToString());

        
            #endregion

           #region Insercion en el Histórico de Porcentaje de Aceptacion

            HistoricoPorcentajeAceptacion oHistorico = new HistoricoPorcentajeAceptacion();

            oHistorico.InsertarHistorico(usuario, 1, insertaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                clsPorcentajeAceptacion._codigoTipoGarantia, string.Empty, entidadPorcentajeAceptacion.CodigoTipoGarantia.ToString());

            oHistorico.InsertarHistorico(usuario, 1, insertaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                clsPorcentajeAceptacion._codigoTipoMitigador, string.Empty, entidadPorcentajeAceptacion.CodigoTipoMitigador.ToString());

            oHistorico.InsertarHistorico(usuario, 1, insertaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                   clsPorcentajeAceptacion._indicadorSinCalificacion, string.Empty, ((entidadPorcentajeAceptacion.IndicadorSinCalificacion) ? "1" : "0"));

            oHistorico.InsertarHistorico(usuario, 1, insertaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                   clsPorcentajeAceptacion._porcentajeAceptacion, string.Empty, entidadPorcentajeAceptacion.PorcentajeAceptacion.ToString());

            //   oHistorico.InsertarHistorico(usuario, 1, insertaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador, 
            //clsPorcentajeAceptacion._porcentajeCeroTres,string.Empty, entidadPorcentajeAceptacion.PorcentajeCeroTres.ToString());

            //   oHistorico.InsertarHistorico(usuario, 1, insertaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador, 
            // clsPorcentajeAceptacion._porcentajeCuatro,string.Empty, entidadPorcentajeAceptacion.PorcentajeCuatro.ToString());

            // oHistorico.InsertarHistorico(usuario, 1, insertaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador, 
            //clsPorcentajeAceptacion._porcentajeCinco,string.Empty, entidadPorcentajeAceptacion.PorcentajeCinco.ToString());

            // oHistorico.InsertarHistorico(usuario, 1, insertaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador, 
            //clsPorcentajeAceptacion._porcentajeSeis,string.Empty, entidadPorcentajeAceptacion.PorcentajeSeis.ToString());
        
        

            #endregion

        }



        /// <summary>
        /// Modifica un registro del tipo porcentaje de aceptacion 
        /// </summary>
        /// <param name="entidadPorcentajeAceptacion">Entidad del tipo de porcentaje de aceptacion que posee los datos a modificar</param>
        /// <param name="entidadPorcentajeAceptacionAnterior">Entidad del tipo de porcentaje de aceptacion que posee los datos originales</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public void Modificar(clsPorcentajeAceptacion entidadPorcentajeAceptacion, clsPorcentajeAceptacion entidadPorcentajeAceptacionAnterior ,string usuario, string ip)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };
            string modificaPorcentajeAceptacion = string.Empty;

            if (entidadPorcentajeAceptacion != null)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piCodigo_Porcentaje_Aceptacion", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Garantia", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Mitigador", SqlDbType.Int),
                        new SqlParameter("pbIndicador_Sin_Calificacion", SqlDbType.Bit),
                        new SqlParameter("pdPorcentaje_Aceptacion", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Cero_Tres", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Cuatro", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Cinco", SqlDbType.Decimal),
                        new SqlParameter("pdPorcentaje_Seis", SqlDbType.Decimal),
                        new SqlParameter("psUsuario_Modifico", SqlDbType.VarChar,30), 
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = entidadPorcentajeAceptacion.CodigoPorcentajeAceptacion;
                    parameters[1].Value = entidadPorcentajeAceptacion.CodigoTipoGarantia;
                    parameters[2].Value = entidadPorcentajeAceptacion.CodigoTipoMitigador;
                    parameters[3].Value = entidadPorcentajeAceptacion.IndicadorSinCalificacion;
                    parameters[4].Value = entidadPorcentajeAceptacion.PorcentajeAceptacion;
                    parameters[5].Value = entidadPorcentajeAceptacion.PorcentajeCeroTres;
                    parameters[6].Value = entidadPorcentajeAceptacion.PorcentajeCuatro;
                    parameters[7].Value = entidadPorcentajeAceptacion.PorcentajeCinco;
                    parameters[8].Value = entidadPorcentajeAceptacion.PorcentajeSeis;
                    parameters[9].Value = usuario;

                    parameters[10].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Modificar_Porcentaje_Aceptacion", parameters);

                        respuestaObtenida = parameters[10].Value.ToString();
                    }

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                        //if (strMensajeObtenido[0].CompareTo("0") != 0)
                        //{
                        //    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorModificandoPorcentajeAceptacion, Mensajes.ASSEMBLY));
                        //}
                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {
                            if (strMensajeObtenido[0].CompareTo("1") == 0)
                            {
                                throw new ExcepcionBase(strMensajeObtenido[2]);
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorInsertandoPorcentajeAceptacion, Mensajes.ASSEMBLY));
                            }
                        }


                    }
                }
                catch (ExcepcionBase ex)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorModificandoPorcentajeAceptacionDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw ex;
                }
                catch (Exception ex)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorModificandoPorcentajeAceptacionDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorModificandoPorcentajeAceptacion, Mensajes.ASSEMBLY));
                }

                #region Inserción en Bitácora

                Bitacora oBitacora = new Bitacora();

                //SE DEBEN AGREGAR TODOS LOS CAMPOS QUE SE VAN A MODIFICAR

                string actualizacionCodigoTipoGarantia = ((entidadPorcentajeAceptacion.CodigoTipoGarantia.CompareTo(entidadPorcentajeAceptacionAnterior.CodigoTipoGarantia) != 0) ? (" Codigo_Tipo_Garantia = " + entidadPorcentajeAceptacion.CodigoTipoGarantia + ",") :string.Empty );
                string actualizacionCoditoTipoMitigador = ((entidadPorcentajeAceptacion.CodigoTipoMitigador.CompareTo(entidadPorcentajeAceptacionAnterior.CodigoTipoMitigador) != 0) ? (" Codigo_Tipo_Mitigador = " + entidadPorcentajeAceptacion.CodigoTipoMitigador + ",") :string.Empty );
                string actualizacionIndicadorSinCalificacion = ((entidadPorcentajeAceptacion.IndicadorSinCalificacion.CompareTo(entidadPorcentajeAceptacionAnterior.IndicadorSinCalificacion) != 0) ? (" Indicador_Sin_Calificacion = " + entidadPorcentajeAceptacion.IndicadorSinCalificacion + ",") :string.Empty );
                string actualizacionPorcentajeAceptacion = ((entidadPorcentajeAceptacion.PorcentajeAceptacion.CompareTo(entidadPorcentajeAceptacionAnterior.PorcentajeAceptacion) != 0) ? (" Porcentaje_Aceptacion = " + entidadPorcentajeAceptacion.PorcentajeAceptacion + ",") :string.Empty );
                string actualizacionPorcentajeCeroTres = ((entidadPorcentajeAceptacion.PorcentajeCeroTres.CompareTo(entidadPorcentajeAceptacionAnterior.PorcentajeCeroTres) != 0) ? (" Porcentaje_Cero_Tres = " + entidadPorcentajeAceptacion.PorcentajeCeroTres + ",") :string.Empty );
                string actualizacionPorcentajeCuatro = ((entidadPorcentajeAceptacion.PorcentajeCuatro.CompareTo(entidadPorcentajeAceptacionAnterior.PorcentajeCuatro) != 0) ? (" Porcentaje_Cuatro = " + entidadPorcentajeAceptacion.PorcentajeCuatro + ",") :string.Empty );
                string actualizacionPorcentajeCinco = ((entidadPorcentajeAceptacion.PorcentajeCinco.CompareTo(entidadPorcentajeAceptacionAnterior.PorcentajeCinco) != 0) ? (" Porcentaje_Cinco= " + entidadPorcentajeAceptacion.PorcentajeCinco + ",") :string.Empty );
                string actualizacionPorcentajeSeis = ((entidadPorcentajeAceptacion.PorcentajeSeis.CompareTo(entidadPorcentajeAceptacionAnterior.PorcentajeSeis) != 0) ? (" Porcentaje_Seis = " + entidadPorcentajeAceptacion.PorcentajeSeis + ",") :string.Empty );
                string actualizacionUsuarioModifico = ((entidadPorcentajeAceptacion.UsuarioModifico.CompareTo(entidadPorcentajeAceptacionAnterior.UsuarioModifico) != 0) ? (" Usuario_Modifico = " + entidadPorcentajeAceptacion.PorcentajeSeis + ",") :string.Empty );


                //FALTAN AGREGAR LOS MAS CAMPOS 

                if ((actualizacionCodigoTipoGarantia.Length > 0) || (actualizacionCoditoTipoMitigador.Length > 0) ||  (actualizacionIndicadorSinCalificacion.Length > 0) || (actualizacionPorcentajeAceptacion.Length > 0) )
                {
                    //string camposAjustados =   actualizacionCodigoTipoGarantia +  actualizacionCoditoTipoMitigador + actualizacionIndicadorSinCalificacion + actualizacionPorcentajeAceptacion 
                    //                           +  actualizacionPorcentajeCeroTres + actualizacionPorcentajeCuatro +  actualizacionPorcentajeCinco + actualizacionPorcentajeSeis +   actualizacionUsuarioModifico       ;
                   
                    string camposAjustados = actualizacionCodigoTipoGarantia + actualizacionCoditoTipoMitigador + actualizacionIndicadorSinCalificacion + actualizacionPorcentajeAceptacion + actualizacionUsuarioModifico;
                    
                    camposAjustados = camposAjustados.TrimEnd(",".ToCharArray());

                    modificaPorcentajeAceptacion = "UPDATE dbo.CAT_PORCENTAJE_ACEPTACION SET" + camposAjustados +
                        " WHERE	Codigo_Porcentaje_Aceptacion = " + entidadPorcentajeAceptacion.CodigoPorcentajeAceptacion.ToString();

                    if (actualizacionCodigoTipoGarantia.Length > 0)
                    {
                        oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                            2, null, string.Empty, string.Empty, modificaPorcentajeAceptacion, string.Empty,
                            clsPorcentajeAceptacion._codigoTipoGarantia, entidadPorcentajeAceptacionAnterior.CodigoTipoGarantia.ToString(), entidadPorcentajeAceptacion.CodigoTipoGarantia.ToString());
                    }

                    if (actualizacionCoditoTipoMitigador.Length > 0)
                    {
                        oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                            2, null, string.Empty, string.Empty, modificaPorcentajeAceptacion, string.Empty,
                            clsPorcentajeAceptacion._codigoTipoMitigador, entidadPorcentajeAceptacionAnterior.CodigoTipoMitigador.ToString(), entidadPorcentajeAceptacion.CodigoTipoMitigador.ToString());
                    }

                     if (actualizacionIndicadorSinCalificacion.Length > 0)
                    {
                        oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                            2, null, string.Empty, string.Empty, modificaPorcentajeAceptacion, string.Empty,
                            clsPorcentajeAceptacion._indicadorSinCalificacion, ((entidadPorcentajeAceptacionAnterior.IndicadorSinCalificacion)? "1":"0"),  ((entidadPorcentajeAceptacion.IndicadorSinCalificacion)?"1":"0") );
                    }

                     if (actualizacionPorcentajeAceptacion.Length > 0)
                     {
                         oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                             2, null, string.Empty, string.Empty, modificaPorcentajeAceptacion, string.Empty,
                             clsPorcentajeAceptacion._porcentajeAceptacion, entidadPorcentajeAceptacionAnterior.PorcentajeAceptacion.ToString(), entidadPorcentajeAceptacion.PorcentajeAceptacion.ToString());
                     }                  
                    //FALTAN LOS OTROS CAMPOS
                }

                #endregion


                #region Insercion en el Histórico de Porcentaje de Aceptacion

                HistoricoPorcentajeAceptacion oHistorico = new HistoricoPorcentajeAceptacion();

                if ((actualizacionCodigoTipoGarantia.Length > 0) || (actualizacionCoditoTipoMitigador.Length > 0) || (actualizacionPorcentajeAceptacion.Length > 0))
                {

                    if (actualizacionCodigoTipoGarantia.Length > 0)
                    {
                        oHistorico.InsertarHistorico(usuario, 2, modificaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador, 
                            clsPorcentajeAceptacion._codigoTipoGarantia, entidadPorcentajeAceptacionAnterior.CodigoTipoGarantia.ToString(),entidadPorcentajeAceptacion.CodigoTipoGarantia.ToString() );
                    }

                    if (actualizacionCoditoTipoMitigador.Length > 0)
                    {
                        oHistorico.InsertarHistorico(usuario, 2, modificaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador, 
                            clsPorcentajeAceptacion._codigoTipoMitigador,entidadPorcentajeAceptacionAnterior.CodigoTipoMitigador.ToString(), entidadPorcentajeAceptacion.CodigoTipoMitigador.ToString());

                    }

                    if (actualizacionIndicadorSinCalificacion.Length > 0)
                    {
                        oHistorico.InsertarHistorico(usuario, 2, modificaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                            clsPorcentajeAceptacion._indicadorSinCalificacion, (entidadPorcentajeAceptacionAnterior.IndicadorSinCalificacion) ? "1" : "0", (entidadPorcentajeAceptacion.IndicadorSinCalificacion) ? "1" : "0");

                    }

                    if (actualizacionPorcentajeAceptacion.Length > 0)
                    {
                        oHistorico.InsertarHistorico(usuario, 2, modificaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador, 
                            clsPorcentajeAceptacion._porcentajeAceptacion, entidadPorcentajeAceptacionAnterior.PorcentajeAceptacion.ToString(), entidadPorcentajeAceptacion.PorcentajeAceptacion.ToString());
                    } 

                    //FALTAN LOS OTROS CAMPOS                 

                }


                #endregion

            }
        }


        /// <summary>
        /// Elimina un registro del tipo de porcentaje de aceptacion
        /// </summary>
        /// <param name="entidadPorcentajeAceptacion">Entidad del tipo de porcentaje de aceptacion que posee los datos a eliminar</param>
        /// <param name="usuario">Usuario que elimina el registro</param>
        /// <param name="ip">Dirección desde donde se elimina el registro</param>
        public void Eliminar(clsPorcentajeAceptacion entidadPorcentajeAceptacion, string usuario, string ip)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (entidadPorcentajeAceptacion != null)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piCodigo_Porcentaje_Aceptacion", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = entidadPorcentajeAceptacion.CodigoPorcentajeAceptacion;
                    parameters[1].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Eliminar_Porcentaje_Aceptacion", parameters);

                        respuestaObtenida = parameters[1].Value.ToString();
                    }

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {
                            throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorEliminandoPorcentajeAceptacion, Mensajes.ASSEMBLY));
                        }
                    }
                }
                catch (Exception ex)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorEliminandoPorcentajeAceptacionDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorEliminandoPorcentajeAceptacion, Mensajes.ASSEMBLY));
                }

                #region Inserción en Bitácora

                Bitacora oBitacora = new Bitacora();

                string eliminaPorcentajeAceptacion = "DELETE  FROM dbo.CAT_PORCENTAJE_ACEPTACION" +
                    " WHERE	Codigo_Porcentaje_Aceptacion = " + entidadPorcentajeAceptacion.CodigoPorcentajeAceptacion.ToString();
               

                oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                 3, null, string.Empty, string.Empty, eliminaPorcentajeAceptacion, string.Empty,
                 clsPorcentajeAceptacion._codigoTipoGarantia, string.Empty, entidadPorcentajeAceptacion.CodigoTipoGarantia.ToString());

                oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                   3, null, string.Empty, string.Empty, eliminaPorcentajeAceptacion, string.Empty,
                   clsPorcentajeAceptacion._codigoTipoMitigador, string.Empty, entidadPorcentajeAceptacion.CodigoTipoMitigador.ToString());

                oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                  3, null, string.Empty, string.Empty, eliminaPorcentajeAceptacion, string.Empty,
                  clsPorcentajeAceptacion._indicadorSinCalificacion, string.Empty, (entidadPorcentajeAceptacion.IndicadorSinCalificacion) ? "1" : "0");

                oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                 3, null, string.Empty, string.Empty, eliminaPorcentajeAceptacion, string.Empty,
                 clsPorcentajeAceptacion._porcentajeAceptacion, string.Empty, entidadPorcentajeAceptacion.PorcentajeAceptacion.ToString());

                //oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                //3, null, string.Empty, string.Empty, eliminaPorcentajeAceptacion, string.Empty,
                //clsPorcentajeAceptacion._porcentajeCeroTres, string.Empty, entidadPorcentajeAceptacion.PorcentajeCeroTres.ToString());

                //oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                // 3, null, string.Empty, string.Empty, eliminaPorcentajeAceptacion, string.Empty,
                // clsPorcentajeAceptacion._porcentajeCuatro, string.Empty,  entidadPorcentajeAceptacion.PorcentajeCuatro.ToString());

                //oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                //3, null, string.Empty, string.Empty, eliminaPorcentajeAceptacion, string.Empty,
                //clsPorcentajeAceptacion._porcentajeCinco, string.Empty, entidadPorcentajeAceptacion.PorcentajeCinco.ToString());

                //oBitacora.InsertarBitacora(clsPorcentajeAceptacion._catTipoPorcentajeAceptacion, usuario, ip, null,
                //  3, null, string.Empty, string.Empty, eliminaPorcentajeAceptacion, string.Empty,
                //  clsPorcentajeAceptacion._porcentajeSeis, string.Empty, entidadPorcentajeAceptacion.PorcentajeSeis.ToString());
                #endregion

                #region Insercion en el Histórico de Porcentaje de Aceptacion

                HistoricoPorcentajeAceptacion oHistorico = new HistoricoPorcentajeAceptacion();

                oHistorico.InsertarHistorico(usuario, 3, eliminaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                    clsPorcentajeAceptacion._codigoTipoGarantia,string.Empty, entidadPorcentajeAceptacion.PorcentajeAceptacion.ToString());

                oHistorico.InsertarHistorico(usuario, 3, eliminaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                clsPorcentajeAceptacion._codigoTipoMitigador, string.Empty, entidadPorcentajeAceptacion.CodigoTipoMitigador.ToString());

                oHistorico.InsertarHistorico(usuario, 3, eliminaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                clsPorcentajeAceptacion._indicadorSinCalificacion, string.Empty, (entidadPorcentajeAceptacion.IndicadorSinCalificacion) ? "1" : "0");

                oHistorico.InsertarHistorico(usuario, 3, eliminaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                clsPorcentajeAceptacion._porcentajeAceptacion, string.Empty, entidadPorcentajeAceptacion.PorcentajeAceptacion.ToString());

                //oHistorico.InsertarHistorico(usuario, 3, eliminaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                //clsPorcentajeAceptacion._porcentajeCeroTres, string.Empty, entidadPorcentajeAceptacion.PorcentajeCeroTres.ToString());

                //oHistorico.InsertarHistorico(usuario, 3, eliminaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                //clsPorcentajeAceptacion._porcentajeCuatro, string.Empty, entidadPorcentajeAceptacion.PorcentajeCuatro.ToString());

                //oHistorico.InsertarHistorico(usuario, 3, eliminaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                //clsPorcentajeAceptacion._porcentajeCinco, string.Empty, entidadPorcentajeAceptacion.PorcentajeCinco.ToString());

                //  oHistorico.InsertarHistorico(usuario, 3, eliminaPorcentajeAceptacion, entidadPorcentajeAceptacion.CodigoTipoGarantia, entidadPorcentajeAceptacion.CodigoTipoMitigador,
                //clsPorcentajeAceptacion._porcentajeSeis, string.Empty, entidadPorcentajeAceptacion.PorcentajeSeis.ToString());


                #endregion

            }
        }

        /// <summary>
        /// Obtiene el porcentaje de aceptacion,
        /// </summary>
        /// <param name="codigoPorcentajeAceptacion">Consecutivo del registro, si es null jala todos los registros</param>
        /// <param name="codigoTipoGarantia">Consecutivo catalogo tipo de garantia</param>
        /// <param name="codigoTipoMitigador">Consecutivo catalogo tipo de mitigador</param>
        ///  <param name="accion">Consulta a realizar: --1.Consecutivo 2.Tipo Garantia 3. Tipo de Mitigador 4. Tipo Garantia y Tipo Mitigador</param>
        /// <returns>Enditad del tipo Porcentaje de aceptacion</returns>
        public DataSet ObtenerDatosPorcentajeAceptacion(int? codigoPorcentajeAceptacion,int? codigoTipoGarantia, int? codigoTipoMitigador, int accion)
        {
            DataSet dsDatosPorcentajeAceptacion = new DataSet();
            try
            {

                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piConsecutivo_Registro", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Garantia", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Mitigador", SqlDbType.Int),

                        new SqlParameter("piAccion", SqlDbType.Int),                      
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                //if (codigoPorcentajeAceptacion == 0)
                //{
                //    parameters[0].Value = null;
                //}
                //else
                //{
                //    parameters[0].Value = codigoPorcentajeAceptacion;
                //}

                //if (codigoTipoGarantia == 0)
                //{
                //    parameters[1].Value = null;
                //}
                //else
                //{
                //    parameters[1].Value = codigoTipoGarantia;
                //}
                //if (codigoTipoMitigador == 0)
                //{
                //    parameters[2].Value = null;
                //}
                //else
                //{
                //    parameters[2].Value = codigoTipoMitigador;
                //}

                parameters[0].Value =((codigoPorcentajeAceptacion.HasValue) ? codigoPorcentajeAceptacion : null);
                parameters[1].Value = ((codigoTipoGarantia.HasValue) ? codigoTipoGarantia : null); ;
                parameters[2].Value = ((codigoTipoMitigador.HasValue) ? codigoTipoMitigador : null); ;  
                parameters[3].Value = accion;                           
                parameters[4].Value = null;
                parameters[4].Direction = ParameterDirection.Output;


                SqlParameter[] parametrosSalida = new SqlParameter[] { };

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();
                    dsDatosPorcentajeAceptacion = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "Consultar_Porcentaje_Aceptacion", parameters, 0);
                }
            }
            catch (Exception ex)
            {
                StringCollection parametros = new StringCollection();
                parametros.Add(codigoPorcentajeAceptacion.ToString());
              
                parametros.Add(("El error se da al obtener la información de la base de datos: " + ex.Message));


                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaPorcentajeAceptacionDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                dsDatosPorcentajeAceptacion = null;
            }
            return dsDatosPorcentajeAceptacion;
        }


        /// <summary>
        /// Obtiene el porcentaje de aceptacion,
        /// </summary>
        /// <param name="codigoPorcentajeAceptacion">Consecutivo del registro, si es null jala todos los registros</param>
        /// <param name="codigoTipoGarantia">Consecutivo catalogo tipo de garantia</param>
        /// <param name="codigoTipoMitigador">Consecutivo catalogo tipo de mitigador</param>
        ///  <param name="accion">Consulta a realizar: --1.Consecutivo 2.Tipo Garantia 3. Tipo de Mitigador 4. Tipo Garantia y Tipo Mitigador</param>
        /// <returns>Enditad del tipo Porcentaje de aceptacion</returns>
        public Decimal ObtenerValorPorcentajeAceptacion(int? codigoPorcentajeAceptacion, int? codigoTipoGarantia, int? codigoTipoMitigador, int accion)
        {
            Decimal porcentajeAceptacionCalculado=0;
            Decimal porAcepCal;

            try
            {

                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piConsecutivo_Registro", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Garantia", SqlDbType.Int),
                        new SqlParameter("piCodigo_Tipo_Mitigador", SqlDbType.Int),

                        new SqlParameter("piAccion", SqlDbType.Int),                      
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                parameters[0].Value = ((codigoPorcentajeAceptacion.HasValue) ? codigoPorcentajeAceptacion : null);
                parameters[1].Value = ((codigoTipoGarantia.HasValue) ? codigoTipoGarantia : null); ;
                parameters[2].Value = ((codigoTipoMitigador.HasValue) ? codigoTipoMitigador : null); ;
                parameters[3].Value = accion;
                parameters[4].Value = null;
                parameters[4].Direction = ParameterDirection.Output;


                SqlParameter[] parametrosSalida = new SqlParameter[] { };

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();
                    object datoRetornado = AccesoBD.ExecuteScalar(CommandType.StoredProcedure,"Consultar_Porcentaje_Aceptacion",parameters);

                    porcentajeAceptacionCalculado = (Decimal.TryParse(datoRetornado.ToString(), out porAcepCal) ? porAcepCal : 0);
                       
                }
            }
            catch (Exception ex)
            {
                StringCollection parametros = new StringCollection();
                parametros.Add(codigoTipoMitigador.ToString());
                parametros.Add(accion.ToString());
                parametros.Add(("El error se da al obtener la información de la base de datos: " + ex.Message));

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaPorcentajeAceptacionDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                porcentajeAceptacionCalculado = 0;
            }
            return porcentajeAceptacionCalculado;
        }

        #endregion  //FIN METODOS PUBLICOS

    }//FIN
}//FIN