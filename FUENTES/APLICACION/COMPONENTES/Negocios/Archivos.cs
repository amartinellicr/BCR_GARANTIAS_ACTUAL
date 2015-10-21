using System.Web;
using System.IO;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Configuration;
using System.Security.AccessControl;
using System.Security.Permissions;
using System.Security.Principal;
using System.Xml;
using System.Text;


using BCRGarantias.Contenedores;
using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Comun;
using System;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Archivos.
    /// </summary>
    public class Archivos
    {
        #region Variables Globales

        DataSet dsDatos = new DataSet();

        private const int tiempo_Espera_Ejecucion = 300;

        #endregion

        #region Deudores
        /// <summary>
        /// Este método genera el archivo de deudores en formato TXT
        /// </summary>
        public void GenerarDeudoresTXT(string strRutaDestino, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Deudores") : (strRutaDestino + "Deudores.txt");

            try
            {
                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarInfoDeudores", null, tiempo_Espera_Ejecucion);

            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Deudores)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Deudores)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Deudores)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Deudores)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Deudores)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Deudores)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        if (Directory.Exists(strRutaDestino))
                        {
                            FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRutaDestino);
                            Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, fileName);
                        }

                        //Escribe el encabezado del archivo
                        writer.WriteLine("CEDULA_DEUDOR\tTIPO_PERSONA_DEUDOR\tCONDICIONES_ESPECIALES\tTIPO_ASIGNACION\tNIVEL_CAPACIDAD_PAGO\tINDICADOR_GENERADOR_DIVISAS\tINDICADOR_VINCULADO_ENTIDAD\tSENSIBILIDAD_TIPO_CAMBIO\tFECHA_VALUACION");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["CEDULA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CONDICIONES_ESPECIALES"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_ASIGNACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NIVEL_CAPACIDAD_PAGO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INDICADOR_GENERADOR_DIVISAS"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INDICADOR_VINCULADO_ENTIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["SENSIBILIDAD_TIPO_CAMBIO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VALUACION"].ToString()
                                            );
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Deudores)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Deudores)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }

        /// <summary>
        /// Este método genera el archivo de contratos en formato TXT
        /// </summary>
        public void GenerarDeudoresFCPTXT(string strRutaDestino, DataSet dsArchivoFuente)
        {
            string fileName = strRutaDestino + "DEUDORES_FCP.txt";

            string strConsulta = " SELECT D.cedula_deudor, CP.fecha_capacidad_pago " +
                " FROM dbo.GAR_DEUDOR D WITH(NOLOCK) " +
                " LEFT OUTER JOIN dbo.GAR_CAPACIDAD_PAGO CP WITH(NOLOCK) " +
                " ON CP.cedula_deudor = D.cedula_deudor " +
                " AND CP.fecha_capacidad_pago = (SELECT MAX(fecha_capacidad_pago) FROM dbo.GAR_CAPACIDAD_PAGO GCP WITH(NOLOCK) WHERE GCP.cedula_deudor = CP.cedula_deudor) ";

            try
            {
                dsDatos = AccesoBD.ExecuteDataSet(CommandType.Text, strConsulta, null, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.DEUDORES_FCP)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.DEUDORES_FCP)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.DEUDORES_FCP)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
            }
            else
            {
                DataTable dtDatosBD = dsDatos.Tables["Datos"].Copy();
                DataTable dtXLS = null;

                /* Se toma la primera tabla que posea datos como la valida */
                foreach (DataTable dt in dsArchivoFuente.Tables)
                {
                    if ((dt.Columns.Contains("CEDULA")) && (dt.Columns.Contains("NOMBRE")) && (dt.Rows.Count > 0))
                    {
                        dtXLS = dt.Copy();
                        break;
                    }
                }

                if ((dtXLS != null) && (dtXLS.Rows.Count > 0))
                {
                    dtXLS.TableName = "Deudores";
                    dtXLS.Columns.Add("indEsDeduor", Type.GetType("System.Int16"));
                    dtXLS.Columns.Add("fecCapacidadPago", Type.GetType("System.String"));
                    dtXLS.AcceptChanges();

                    foreach (DataRow drDeudor in dtXLS.Rows)
                    {
                        DataRow[] drDatosBD = dtDatosBD.Select("cedula_deudor = '" + drDeudor["CEDULA"].ToString() + "'");

                        if (drDatosBD.Length > 0)
                        {
                            DateTime dtFCP;
                            drDeudor["indEsDeduor"] = 1;
                            drDeudor["fecCapacidadPago"] = (!drDatosBD[0].IsNull("fecha_capacidad_pago")) ? ((DateTime.TryParse(drDatosBD[0]["fecha_capacidad_pago"].ToString(), out dtFCP)) ? dtFCP.ToString("dd/MM/yyyy") : string.Empty) : string.Empty;
                        }
                        else
                        {
                            drDeudor["indEsDeduor"] = 0;
                            drDeudor["fecCapacidadPago"] = string.Empty;
                        }

                        drDeudor.AcceptChanges();
                    }

                    dtXLS.AcceptChanges();
                }
                else
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ENCABEZADOS_ARCHIVO_FUENTE, Mensajes.ASSEMBLY));
                }

                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        if (Directory.Exists(strRutaDestino))
                        {
                            FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRutaDestino);
                            Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, fileName);
                        }

                        //Escribe el encabezado del archivo
                        writer.WriteLine("CEDULA\tNOMBRE\tES_DEUDOR\tFECHA_CAPACIDAD_PAGO");

                        if (dtXLS != null)
                        {
                            for (int i = 0; i <= dtXLS.Rows.Count - 1; i++)
                            {
                                writer.WriteLine(dtXLS.Rows[i]["CEDULA"].ToString() + "\t" +
                                                 dtXLS.Rows[i]["NOMBRE"].ToString() + "\t" +
                                                ((dtXLS.Rows[i]["indEsDeduor"].ToString().CompareTo("1") == 0) ? "SI" : ((dtXLS.Rows[i]["indEsDeduor"].ToString().CompareTo("0") == 0) ? "NO" : string.Empty)) + "\t" +
                                                 dtXLS.Rows[i]["fecCapacidadPago"].ToString() + "\t"
                                                );
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.DEUDORES_FCP)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                }
            }
        }

        #endregion

        #region Garantias Fiduciarias
        /// <summary>
        /// Este método genera el archivo de garantías fiduciarias en formato TXT
        /// </summary>
        public void GenerarGarantiasFiduciariasTXT(string strRutaDestino, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "GarFid") : (strRutaDestino + "GarFid.txt");

            string strFiltros = string.Empty;

            try
            {
                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarInfoGarantiasFiduciarias", null, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciarias)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciarias)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciarias)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciarias)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciarias)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciarias)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        //Escribe el encabezado del archivo
                        writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tCEDULA_FIADOR\tTIPO_PERSONA_FIADOR\tFECHA_VERIFICACION_ASALARIADO\tSALARIO_NETO_FIADOR\tTIPO_MITIGADOR_RIESGO\tTIPO_DOCUMENTO_LEGAL\tMONTO_MITIGADOR\tPORCENTAJE_RESPONSABILIDAD\tTIPO_PERSONA_ACREEDOR\tCEDULA_ACREEDOR\tOPERACION_ESPECIAL\tNOMBRE_FIADOR\tCEDULA_DEUDOR\tNOMBRE_DEUDOR\tOFICINA_DEUDOR\tBIN\tCODIGO_INTERNO_SISTAR");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["CONTABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PRODUCTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_FIADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_FIADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VERIFICACION_ASALARIADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["SALARIO_NETO_FIADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_MITIGADOR_RIESGO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_DOCUMENTO_LEGAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_RESPONSABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION_ESPECIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_FIADOR"].ToString().Replace("\r\n", " ") + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_DEUDOR"].ToString().Replace("\r\n", " ") + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA_DEUDOR"].ToString() + "\t" +
                                             string.Empty + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CODIGO_INTERNO_SISTAR"].ToString() + "\t"
                                            );
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciarias)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciarias)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }

        /// <summary>
        /// Este método genera el archivo de garantías fiduciarias, con la información completa, en formato TXT
        /// </summary>
        public void GenerarGarantiasFiduciariasInfoCompletaTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "GarantiasFiduciariasInfoCompleta") : (strRutaDestino + "GarantiasFiduciariasInfoCompleta.txt");

            string strFiltros = string.Empty;

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                new SqlParameter("IDUsuario", SqlDbType.VarChar, 20)};

                parameters[0].Value = strIDUsuario;

                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarGarantiasFiduciariasInfoCompleta", parameters, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasInfoCompleta)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasInfoCompleta)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasInfoCompleta)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasInfoCompleta)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasInfoCompleta)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasInfoCompleta)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        //Escribe el encabezado del archivo
                        writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tCEDULA_FIADOR\tTIPO_PERSONA_FIADOR\tFECHA_VERIFICACION_ASALARIADO\tSALARIO_NETO_FIADOR\tTIPO_MITIGADOR_RIESGO\tTIPO_DOCUMENTO_LEGAL\tMONTO_MITIGADOR\tPORCENTAJE_RESPONSABILIDAD\tTIPO_PERSONA_ACREEDOR\tCEDULA_ACREEDOR\tOPERACION_ESPECIAL\tNOMBRE_FIADOR\tCEDULA_DEUDOR\tNOMBRE_DEUDOR\tOFICINA_DEUDOR\tBIN\tCODIGO_INTERNO_SISTAR");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["CONTABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PRODUCTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_FIADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_FIADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VERIFICACION_ASALARIADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["SALARIO_NETO_FIADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_MITIGADOR_RIESGO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_DOCUMENTO_LEGAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_RESPONSABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION_ESPECIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_FIADOR"].ToString().Replace("\r\n", " ") + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_DEUDOR"].ToString().Replace("\r\n", " ") + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["BIN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CODIGO_INTERNO_SISTAR"].ToString() + "\t"
                                            );
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasInfoCompleta)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasInfoCompleta)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }

        /// <summary>
        /// Este método genera el archivo de garantías fiduciarias de contratos en formato TXT
        /// </summary>
        public void GenerarGarantiasFiduciariasContratosTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "GarFiaCo") : (strRutaDestino + "GarFiaCo.txt");

            string strFiltros = string.Empty;

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                new SqlParameter("IDUsuario", SqlDbType.VarChar, 20)};

                parameters[0].Value = strIDUsuario;

                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarInfoGarantiasFiduciariasContratos", parameters, tiempo_Espera_Ejecucion);

            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasContratos)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasContratos)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasContratos)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasContratos)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasContratos)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasContratos)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        //Escribe el encabezado del archivo
                        writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tCEDULA_FIADOR\tTIPO_PERSONA_FIADOR\tFECHA_VERIFICACION_ASALARIADO\tSALARIO_NETO_FIADOR\tTIPO_MITIGADOR_RIESGO\tTIPO_DOCUMENTO_LEGAL\tMONTO_MITIGADOR\tPORCENTAJE_RESPONSABILIDAD\tTIPO_PERSONA_ACREEDOR\tCEDULA_ACREEDOR\tOPERACION_ESPECIAL\tNOMBRE_FIADOR\tCEDULA_DEUDOR\tNOMBRE_DEUDOR\tOFICINA_DEUDOR\tBIN\tCODIGO_INTERNO_SISTAR\tES_CONTRATO_VENCIDO");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["CONTABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PRODUCTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_FIADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_FIADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VERIFICACION_ASALARIADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["SALARIO_NETO_FIADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_MITIGADOR_RIESGO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_DOCUMENTO_LEGAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_RESPONSABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION_ESPECIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_FIADOR"].ToString().Replace("\r\n", " ") + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_DEUDOR"].ToString().Replace("\r\n", " ") + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["BIN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CODIGO_INTERNO_SISTAR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["ES_CONTRATO_VENCIDO"].ToString() + "\t"
                                            );

                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasContratos)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasContratos)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }
        #endregion

        #region Garantias Reales
        /// <summary>
        /// Este método genera el archivo de garantías reales en formato TXT
        /// </summary>
        public void GenerarGarantiasRealesTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "GarRea") : (strRutaDestino + "GarRea.txt");

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 20), 
                new SqlParameter("piEjecutarParte", SqlDbType.TinyInt)
                };

                parameters[0].Value = strIDUsuario;
                parameters[1].Value = 0;

                AccesoBD.ExecuteNonQuery("pa_GenerarInfoGarantiasReales", parameters);

                parameters[0].Value = strIDUsuario;
                parameters[1].Value = 1;

                AccesoBD.ExecuteNonQuery("pa_GenerarInfoGarantiasReales", parameters);

                parameters[0].Value = strIDUsuario;
                parameters[1].Value = 2;

                AccesoBD.ExecuteNonQuery("pa_GenerarInfoGarantiasReales", parameters);

                parameters[0].Value = strIDUsuario;
                parameters[1].Value = 3;

                AccesoBD.ExecuteNonQuery("pa_GenerarInfoGarantiasReales", parameters);

                parameters[0].Value = strIDUsuario;
                parameters[1].Value = 4;

                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarInfoGarantiasReales", parameters, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasReales)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasReales)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasReales)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasReales)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasReales)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasReales)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        if (Directory.Exists(strRutaDestino))
                        {
                            FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRutaDestino);
                            Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, fileName);
                        }

                        //Escribe el encabezado del archivo
                        writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tTIPO_BIEN\tCODIGO_BIEN\tTIPO_MITIGADOR\tTIPO_DOCUMENTO_LEGAL\tMONTO_MITIGADOR\tFECHA_PRESENTACION\tINDICADOR_INSCRIPCION\tPORCENTAJE_DE_ACEPTACION\tFECHA_CONSTITUCION\tGRADO_GRAVAMEN\tTIPO_PERSONA_ACREEDOR\tCEDULA_ACREEDOR\tFECHA_VENCIMIENTO\tOPERACION_ESPECIAL\tFECHA_VALUACION\tCEDULA_EMPRESA\tTIPO_PERSONA_EMPRESA\tCEDULA_PERITO\tTIPO_PERSONA_PERITO\tMONTO_ULTIMA_TASACION_TERRENO\tMONTO_ULTIMA_TASACION_NO_TERRENO\tMONTO_TASACION_ACTUALIZADA_TERRENO\tMONTO_TASACION_ACTUALIZADA_NO_TERRENO\tFECHA_ULTIMO_SEGUIMIENTO\tMONTO_TOTAL_AVALUO\tFECHA_CONSTRUCCION\tCOD_GRADO\tCEDULA_HIPOTECARIA\tCEDULA_DEUDOR\tNOMBRE_DEUDOR\tOFICINA_DEUDOR\tTIPO_GARANTIA\tCODIGO_SAP\tMONTO_POLIZA\tFECHA_VENCIMIENTO_POLIZA\tTIPO_POLIZA_SUGEF\tINDICADOR_POLIZA");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["CONTABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PRODUCTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_BIEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CODIGO_BIEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_DOCUMENTO_LEGAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_PRESENTACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INDICADOR_INSCRIPCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_ACEPTACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_CONSTITUCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["GRADO_GRAVAMEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VENCIMIENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION_ESPECIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VALUACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_EMPRESA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_EMPRESA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_PERITO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_PERITO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_ULTIMA_TASACION_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_ULTIMA_TASACION_NO_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_TASACION_ACTUALIZADA_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_TASACION_ACTUALIZADA_NO_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_ULTIMO_SEGUIMIENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_TOTAL_AVALUO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_CONSTRUCCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["COD_GRADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_HIPOTECARIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_GARANTIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CODIGO_SAP"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_POLIZA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VENCIMIENTO_POLIZA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_POLIZA_SUGEF"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INDICADOR_POLIZA"].ToString() + "\t"
                                            );
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasReales)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasReales)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }

        /// <summary>
        /// Este método genera el archivo de garantías reales, con la información completa, en formato TXT
        /// </summary>
        public void GenerarGarantiasRealesInfoCompletaTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "GarantiasRealesInfoCompleta") : (strRutaDestino + "GarantiasRealesInfoCompleta.txt");

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                new SqlParameter("IDUsuario", SqlDbType.VarChar, 20), 
                new SqlParameter("piEjecutarParte", SqlDbType.Bit)
                };

                parameters[0].Value = strIDUsuario;
                parameters[1].Value = false;

                AccesoBD.ExecuteNonQuery("pa_GenerarGarantiasRealesInfoCompleta", parameters);

                parameters[1].Value = true;

                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarGarantiasRealesInfoCompleta", parameters, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesInfoCompleta)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesInfoCompleta)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesInfoCompleta)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesInfoCompleta)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesInfoCompleta)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesInfoCompleta)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        if (Directory.Exists(strRutaDestino))
                        {
                            FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRutaDestino);
                            Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, fileName);
                        }

                        //Escribe el encabezado del archivo
                        writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tTIPO_BIEN\tCODIGO_BIEN\tTIPO_MITIGADOR\tTIPO_DOCUMENTO_LEGAL\tMONTO_MITIGADOR\tFECHA_PRESENTACION\tINDICADOR_INSCRIPCION\tPORCENTAJE_DE_ACEPTACION\tFECHA_CONSTITUCION\tGRADO_GRAVAMEN\tTIPO_PERSONA_ACREEDOR\tCEDULA_ACREEDOR\tFECHA_VENCIMIENTO\tOPERACION_ESPECIAL\tFECHA_VALUACION\tCEDULA_EMPRESA\tTIPO_PERSONA_EMPRESA\tCEDULA_PERITO\tTIPO_PERSONA_PERITO\tMONTO_ULTIMA_TASACION_TERRENO\tMONTO_ULTIMA_TASACION_NO_TERRENO\tMONTO_TASACION_ACTUALIZADA_TERRENO\tMONTO_TASACION_ACTUALIZADA_NO_TERRENO\tFECHA_ULTIMO_SEGUIMIENTO\tMONTO_TOTAL_AVALUO\tFECHA_CONSTRUCCION\tCOD_GRADO\tCEDULA_HIPOTECARIA\tCEDULA_DEUDOR\tNOMBRE_DEUDOR\tOFICINA_DEUDOR\tTIPO_GARANTIA");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["CONTABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PRODUCTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_BIEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CODIGO_BIEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_DOCUMENTO_LEGAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_PRESENTACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INDICADOR_INSCRIPCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_ACEPTACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_CONSTITUCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["GRADO_GRAVAMEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VENCIMIENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION_ESPECIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VALUACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_EMPRESA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_EMPRESA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_PERITO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_PERITO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_ULTIMA_TASACION_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_ULTIMA_TASACION_NO_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_TASACION_ACTUALIZADA_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_TASACION_ACTUALIZADA_NO_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_ULTIMO_SEGUIMIENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_TOTAL_AVALUO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_CONSTRUCCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["COD_GRADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_HIPOTECARIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_GARANTIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CODIGO_SAP"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_POLIZA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VENCIMIENTO_POLIZA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_POLIZA_SUGEF"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INDICADOR_POLIZA"].ToString() + "\t"
                                            );
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesInfoCompleta)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesInfoCompleta)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }

        /// <summary>
        /// Este método genera el archivo de garantías reales asociadas a los contratos en formato TXT
        /// </summary>
        public void GenerarGarantiasRealesContratosTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "GarReaCo") : (strRutaDestino + "GarReaCo.txt");

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 20), 
                new SqlParameter("piEjecutarParte", SqlDbType.TinyInt)
                };

                parameters[0].Value = strIDUsuario;
                parameters[1].Value = 0;

                AccesoBD.ExecuteNonQuery("pa_GenerarInfoGarantiasRealesContratos", parameters);

                parameters[0].Value = strIDUsuario;
                parameters[1].Value = 1;

                AccesoBD.ExecuteNonQuery("pa_GenerarInfoGarantiasRealesContratos", parameters);

                parameters[0].Value = strIDUsuario;
                parameters[1].Value = 2;

                AccesoBD.ExecuteNonQuery("pa_GenerarInfoGarantiasRealesContratos", parameters);

                parameters[0].Value = strIDUsuario;
                parameters[1].Value = 3;

                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarInfoGarantiasRealesContratos", parameters, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesContratos)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesContratos)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesContratos)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesContratos)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesContratos)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesContratos)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        if (Directory.Exists(strRutaDestino))
                        {
                            FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRutaDestino);
                            Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, fileName);
                        }

                        //Escribe el encabezado del archivo
                        writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tTIPO_BIEN\tCODIGO_BIEN\tTIPO_MITIGADOR\tTIPO_DOCUMENTO_LEGAL\tMONTO_MITIGADOR\tFECHA_PRESENTACION\tINDICADOR_INSCRIPCION\tPORCENTAJE_DE_ACEPTACION\tFECHA_CONSTITUCION\tGRADO_GRAVAMEN\tTIPO_PERSONA_ACREEDOR\tCEDULA_ACREEDOR\tFECHA_VENCIMIENTO\tOPERACION_ESPECIAL\tFECHA_VALUACION\tCEDULA_EMPRESA\tTIPO_PERSONA_EMPRESA\tCEDULA_PERITO\tTIPO_PERSONA_PERITO\tMONTO_ULTIMA_TASACION_TERRENO\tMONTO_ULTIMA_TASACION_NO_TERRENO\tMONTO_TASACION_ACTUALIZADA_TERRENO\tMONTO_TASACION_ACTUALIZADA_NO_TERRENO\tFECHA_ULTIMO_SEGUIMIENTO\tMONTO_TOTAL_AVALUO\tFECHA_CONSTRUCCION\tCOD_GRADO\tCEDULA_HIPOTECARIA\tCEDULA_DEUDOR\tNOMBRE_DEUDOR\tOFICINA_DEUDOR\tTIPO_GARANTIA\tESTA_VENCIDO\tCODIGO_SAP\tMONTO_POLIZA\tFECHA_VENCIMIENTO_POLIZA\tTIPO_POLIZA_SUGEF\tINDICADOR_POLIZA");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["CONTABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PRODUCTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_BIEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CODIGO_BIEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_DOCUMENTO_LEGAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_PRESENTACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INDICADOR_INSCRIPCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_ACEPTACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_CONSTITUCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["GRADO_GRAVAMEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VENCIMIENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION_ESPECIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VALUACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_EMPRESA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_EMPRESA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_PERITO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_PERITO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_ULTIMA_TASACION_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_ULTIMA_TASACION_NO_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_TASACION_ACTUALIZADA_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_TASACION_ACTUALIZADA_NO_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_ULTIMO_SEGUIMIENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_TOTAL_AVALUO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_CONSTRUCCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["COD_GRADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_HIPOTECARIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_GARANTIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["ES_CONTRATO_VENCIDO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CODIGO_SAP"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_POLIZA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VENCIMIENTO_POLIZA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_POLIZA_SUGEF"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INDICADOR_POLIZA"].ToString() + "\t"  
                                             //descomentar para el pase a pruebas con poliza
                                            ); 
                                            //se debe comentar la parde de POLIZAS para hacer la prueba del archivo GaReaco
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesContratos)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesContratos)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }

        /// <summary>
        /// Este método genera el archivo de los registros generados por el proceso del cálculo del monto de la tasación actualziada del terreno y no terreno, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public void GenerarRespaldoRegistrosCalculadosTXT(string strRutaDestino, bool bEsServicioWindows)
        {
            XmlDocument xmlTrama = new XmlDocument();

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerCM = string.Empty;
            string fileName;
            StringBuilder sbCM = new StringBuilder();

            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Cálculo de MTAT y MTANT") : (strRutaDestino + "Cálculo de MTAT y MTANT.txt");

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { };

                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "Consultar_Registros_Calculo_MTAT_MTANT", parameters, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes._errorObteniendoRegistrosCalculoMTATMTANTDetalle, sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoRegistrosCalculoMTATMTANTDetalle, sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes._errorObteniendoRegistrosCalculoMTATMTANT);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes._errorObteniendoRegistrosCalculoMTATMTANTDetalle, ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoRegistrosCalculoMTATMTANTDetalle, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes._errorObteniendoRegistrosCalculoMTATMTANT);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes._errorObteniendoRegistrosCalculoMTATMTANTDetalle, "No se obtuvieron datos.", Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoRegistrosCalculoMTATMTANTDetalle, "No se obtuvieron datos.", Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes._errorObteniendoRegistrosCalculoMTATMTANT);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = new StreamWriter(File.Create(fileName), Encoding.Unicode))
                    {
                        //Escribe el encabezado del archivo
                        writer.WriteLine("FECHA_HORA\tID_GARANTIA\tTIPO_GARANTIA_REAL\tCLASE_GARANTIA\tSEMESTRE_CALCULADO\tFECHA_VALUACION\tMTO_ULTIMA_TASACION_TERRENO\tMTO_ULTIMA_TASACION_NO_TERRENO\tTIPO_CAMBIO\tIPC\tTIPO_CAMBIO_ANTERIOR\tIPC_ANTERIOR\tFACTOR_TIPO_CAMBIO\tFACTOR_IPC\tPORCENTAJE_DEPRECIACION_SEMESTRAL\tMTO_TASACION_ACTUALIZADA_TERRENO\tMTO_TASACION_ACTUALIZADA_NO_TERRENO\tNUMERO_REGISTRO\tCODIGO_OPERACION\tCODIGO_GARANTIA\tTIPO_BIEN\tTOTAL_SEMESTRES_CALCULAR\tUSUARIO\tPORCENTAJE_ACEPTACION_BASE\tPORCENTAJE_ACEPTACION_TERRENO\tPORCENTAJE_ACEPTACION_NO_TERRENO\tPORCENTAJE_ACEPTACION_TERRENO_CALCULADO\tPORCENTAJE_ACEPTACION_NO_TERRENO_CALCULADO");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["FECHA_HORA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["ID_GARANTIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_GARANTIA_REAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CLASE_GARANTIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["SEMESTRE_CALCULADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VALUACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MTO_ULTIMA_TASACION_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MTO_ULTIMA_TASACION_NO_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_CAMBIO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["IPC"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_CAMBIO_ANTERIOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["IPC_ANTERIOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FACTOR_TIPO_CAMBIO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FACTOR_IPC"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_DEPRECIACION_SEMESTRAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MTO_TASACION_ACTUALIZADA_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MTO_TASACION_ACTUALIZADA_NO_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NUMERO_REGISTRO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CODIGO_OPERACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CODIGO_GARANTIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_BIEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TOTAL_SEMESTRES_CALCULAR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["USUARIO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_ACEPTACION_BASE"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_ACEPTACION_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_ACEPTACION_NO_TERRENO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_ACEPTACION_TERRENO_CALCULADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_ACEPTACION_NO_TERRENO_CALCULADO"].ToString() + "\t"
                                            );
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes._errorObteniendoRegistrosCalculoMTATMTANTDetalle, ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoRegistrosCalculoMTATMTANTDetalle, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes._errorObteniendoRegistrosCalculoMTATMTANT);
                    }
                }
            }
        }


        #endregion

        #region Garantias de Valor
        /// <summary>
        /// Este método genera el archivo de garantías de valor en formato TXT
        /// </summary>
        public void GenerarGarantiasValorTXT(string strRutaDestino, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "GarVal") : (strRutaDestino + "GarVal.txt");

            try
            {
                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarInfoGarantiasValor", null, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValor)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValor)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValor)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValor)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValor)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValor)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        if (Directory.Exists(strRutaDestino))
                        {
                            FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRutaDestino);
                            Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, fileName);
                        }

                        //Escribe el encabezado del archivo
                        writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tNUMERO_SEGURIDAD\tTIPO_MITIGADOR\tTIPO_DOCUMENTO_LEGAL\tMONTO_MITIGADOR\tFECHA_PRESENTACION\tINDICADOR_INSCRIPCION\tPORCENTAJE_RESPONSABILIDAD\tFECHA_CONSTITUCION\tGRADO_GRAVAMEN\tGRADO_PRIORIDAD\tMONTO_PRIORIDAD\tTIPO_PERSONA_ACREEDOR\tCEDULA_ACREEDOR\tFECHA_VENCIMIENTO\tOPERACION_ESPECIAL\tCLASIFICACION_INSTRUMENTO\tINSTRUMENTO\tSERIE_INSTRUMENTO\tTIPO_PERSONA_EMISOR\tCEDULA_EMISOR\tPREMIO\tISIN\tVALOR_FACIAL\tMONEDA_VALOR_FACIAL\tVALOR_MERCADO\tMONEDA_VALOR_MERCADO\tMONTO_RESPONSABILIDAD\tMONEDA_GARANTIA\tCEDULA_DEUDOR\tNOMBRE_DEUDOR\tOFICINA_DEUDOR");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["CONTABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PRODUCTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NUMERO_SEGURIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_DOCUMENTO_LEGAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_PRESENTACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INDICADOR_INSCRIPCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_RESPONSABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_CONSTITUCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["GRADO_GRAVAMEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["GRADO_PRIORIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_PRIORIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VENCIMIENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION_ESPECIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CLASIFICACION_INSTRUMENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INSTRUMENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["SERIE_INSTRUMENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_EMISOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_EMISOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PREMIO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["ISIN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["VALOR_FACIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA_VALOR_FACIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["VALOR_MERCADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA_VALOR_MERCADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_RESPONSABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA_GARANTIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA_DEUDOR"].ToString() + "\t"
                                            );
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValor)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValor)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }

        /// <summary>
        /// Este método genera el archivo de garantías de valor, con la información completa, en formato TXT
        /// </summary>
        public void GenerarGarantiasValorInfoCompletaTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "GarantiasValorInfoCompleta") : (strRutaDestino + "GarantiasValorInfoCompleta.txt");

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                new SqlParameter("IDUsuario", SqlDbType.VarChar, 20)
                };

                parameters[0].Value = strIDUsuario;

                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarGarantiasValorInfoCompleta", parameters, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorInfoCompleta)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorInfoCompleta)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorInfoCompleta)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorInfoCompleta)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorInfoCompleta)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorInfoCompleta)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        if (Directory.Exists(strRutaDestino))
                        {
                            FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRutaDestino);
                            Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, fileName);
                        }

                        //Escribe el encabezado del archivo
                        writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tNUMERO_SEGURIDAD\tTIPO_MITIGADOR\tTIPO_DOCUMENTO_LEGAL\tMONTO_MITIGADOR\tFECHA_PRESENTACION\tINDICADOR_INSCRIPCION\tPORCENTAJE_RESPONSABILIDAD\tFECHA_CONSTITUCION\tGRADO_GRAVAMEN\tGRADO_PRIORIDAD\tMONTO_PRIORIDAD\tTIPO_PERSONA_ACREEDOR\tCEDULA_ACREEDOR\tFECHA_VENCIMIENTO\tOPERACION_ESPECIAL\tCLASIFICACION_INSTRUMENTO\tINSTRUMENTO\tSERIE_INSTRUMENTO\tTIPO_PERSONA_EMISOR\tCEDULA_EMISOR\tPREMIO\tISIN\tVALOR_FACIAL\tMONEDA_VALOR_FACIAL\tVALOR_MERCADO\tMONEDA_VALOR_MERCADO\tMONTO_RESPONSABILIDAD\tMONEDA_GARANTIA\tCEDULA_DEUDOR\tNOMBRE_DEUDOR\tOFICINA_DEUDOR");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["CONTABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PRODUCTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NUMERO_SEGURIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_DOCUMENTO_LEGAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_PRESENTACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INDICADOR_INSCRIPCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_RESPONSABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_CONSTITUCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["GRADO_GRAVAMEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["GRADO_PRIORIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_PRIORIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VENCIMIENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION_ESPECIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CLASIFICACION_INSTRUMENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INSTRUMENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["SERIE_INSTRUMENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_EMISOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_EMISOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PREMIO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["ISIN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["VALOR_FACIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA_VALOR_FACIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["VALOR_MERCADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA_VALOR_MERCADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_RESPONSABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA_GARANTIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA_DEUDOR"].ToString() + "\t"
                                            );
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorInfoCompleta)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorInfoCompleta)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }

        /// <summary>
        /// Este método genera el archivo de garantías de valor asociadas a contratos en formato TXT
        /// </summary>
        public void GenerarGarantiasValorContratosTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "GarValCo") : (strRutaDestino + "GarValCo.txt");

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                new SqlParameter("@IDUsuario", SqlDbType.VarChar, 20)              
                };

                parameters[0].Value = strIDUsuario;

                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarInfoGarantiasValorContratos", parameters, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorContratos)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorContratos)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorContratos)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorContratos)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorContratos)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorContratos)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        if (Directory.Exists(strRutaDestino))
                        {
                            FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRutaDestino);
                            Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, fileName);
                        }

                        //Escribe el encabezado del archivo
                        writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tNUMERO_SEGURIDAD\tTIPO_MITIGADOR\tTIPO_DOCUMENTO_LEGAL\tMONTO_MITIGADOR\tFECHA_PRESENTACION\tINDICADOR_INSCRIPCION\tPORCENTAJE_RESPONSABILIDAD\tFECHA_CONSTITUCION\tGRADO_GRAVAMEN\tGRADO_PRIORIDAD\tMONTO_PRIORIDAD\tTIPO_PERSONA_ACREEDOR\tCEDULA_ACREEDOR\tFECHA_VENCIMIENTO\tOPERACION_ESPECIAL\tCLASIFICACION_INSTRUMENTO\tINSTRUMENTO\tSERIE_INSTRUMENTO\tTIPO_PERSONA_EMISOR\tCEDULA_EMISOR\tPREMIO\tISIN\tVALOR_FACIAL\tMONEDA_VALOR_FACIAL\tVALOR_MERCADO\tMONEDA_VALOR_MERCADO\tMONTO_RESPONSABILIDAD\tMONEDA_GARANTIA\tCEDULA_DEUDOR\tNOMBRE_DEUDOR\tOFICINA_DEUDOR\tES_CONTRATO_VENCIDO");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["CONTABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PRODUCTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NUMERO_SEGURIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_DOCUMENTO_LEGAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_MITIGADOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_PRESENTACION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INDICADOR_INSCRIPCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PORCENTAJE_RESPONSABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_CONSTITUCION"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["GRADO_GRAVAMEN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["GRADO_PRIORIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_PRIORIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_ACREEDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["FECHA_VENCIMIENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OPERACION_ESPECIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CLASIFICACION_INSTRUMENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["INSTRUMENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["SERIE_INSTRUMENTO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["TIPO_PERSONA_EMISOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_EMISOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["PREMIO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["ISIN"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["VALOR_FACIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA_VALOR_FACIAL"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["VALOR_MERCADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA_VALOR_MERCADO"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONTO_RESPONSABILIDAD"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["MONEDA_GARANTIA"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["CEDULA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["NOMBRE_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["OFICINA_DEUDOR"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["ES_CONTRATO_VENCIDO"].ToString() + "\t"
                                            );
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorContratos)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorContratos)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }
        #endregion

        #region Archivo de Contratos

        /// <summary>
        /// Este método genera el archivo de contratos en formato TXT
        /// </summary>
        public void GenerarArchivoContratosTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Contratos") : (strRutaDestino + "Contratos.txt");

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                new SqlParameter("IDUsuario", SqlDbType.VarChar, 20)
                };

                parameters[0].Value = strIDUsuario;

                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarInfoContratos", parameters, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Contratos)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Contratos)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Contratos)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Contratos)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Contratos)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Contratos)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        if (Directory.Exists(strRutaDestino))
                        {
                            FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRutaDestino);
                            Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, fileName);
                        }

                        //Escribe el encabezado del archivo
                        writer.WriteLine("prmca_pco_ofici\tprmca_pco_moned\tprmca_pco_produc\tprmca_pnu_contr\tprmca_pmo_maxim\tprmca_pmo_utiliz\tprmca_pmo_reserv\tprmca_psa_discon\tprmca_psa_conta\tsaldo_actual_giros\tmonto_mitigador");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["prmca_pco_ofici"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmca_pco_moned"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmca_pco_produc"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmca_pnu_contr"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmca_pmo_maxim"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmca_pmo_utiliz"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmca_pmo_reserv"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmca_psa_discon"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmca_psa_conta"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["saldo_actual_giros"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["monto_mitigador"].ToString() + "\t"
                                            );
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Contratos)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Contratos)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }

        #endregion

        #region Archivo de Giros

        /// <summary>
        /// Este método genera el archivo de giros en formato TXT
        /// </summary>
        public void GenerarArchivoGirosTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            string fileName;
            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Giros") : (strRutaDestino + "Giros.txt");

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                new SqlParameter("IDUsuario", SqlDbType.VarChar, 20)
                };

                parameters[0].Value = strIDUsuario;

                dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_GenerarInfoGiros", parameters, tiempo_Espera_Ejecucion);
            }
            catch (SqlException sqlEx)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Giros)), sqlEx.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Giros)), sqlEx.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }
            catch (Exception ex)
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Giros)), ex.Message, Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Giros)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI);
                }
            }

            if ((dsDatos == null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) <= 0))
            {
                if (bEsServicioWindows)
                {
                    throw new Exception(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Giros)), Mensajes.ASSEMBLY));
                }
                else
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Giros)), Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                    throw new Exception(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter writer = File.CreateText(fileName))
                    {
                        if (Directory.Exists(strRutaDestino))
                        {
                            FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRutaDestino);
                            Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, fileName);
                        }

                        //Escribe el encabezado del archivo
                        writer.WriteLine("prmca_pco_ofici\tprmca_pco_moned\tprmca_pco_produc\tprmca_pnu_contr\tprmoc_pco_ofici\tprmoc_pco_moned\tprmoc_pco_produ\tprmoc_pnu_oper\tprmoc_psa_actual");
                        for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                        {
                            writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["prmca_pco_ofici"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmca_pco_moned"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmca_pco_produc"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmca_pnu_contr"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmoc_pco_ofici"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmoc_pco_moned"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmoc_pco_produ"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmoc_pnu_oper"].ToString() + "\t" +
                                             dsDatos.Tables["Datos"].Rows[i]["prmoc_psa_actual"].ToString() + "\t"
                                            );
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (bEsServicioWindows)
                    {
                        throw new Exception(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Giros)), ex.Message, Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE, (Enum.GetName(typeof(Enumeradores.Nombre_Archivos_SEGUI), Enumeradores.Nombre_Archivos_SEGUI.Giros)), ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        throw new Exception(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI);
                    }
                }
            }
        }

        #endregion

        #region Inconsistencias

        #region Error de Inscripción

        /// <summary>
        /// Este método genera el archivo de inconsistencias del indicador de inscripción, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public void GenerarErrorInscripcionTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            XmlReader oRetornoGR = null;
            XmlReader oRetornoGV = null;
            XmlDocument xmlTrama = new XmlDocument();
            XmlNodeList xmlInconsistencias;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerGR = string.Empty;
            string vsObtenerGV = string.Empty;
            string fileName;
            StringBuilder sbGR = new StringBuilder();
            StringBuilder sbGV = new StringBuilder();

            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Error de Inscripción") : (strRutaDestino + "Error de Inscripción.txt");

            try
            {
                using (StreamWriter writer = new StreamWriter(File.Create(fileName), Encoding.Unicode))
                {

                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                    parameters[0].Value = strIDUsuario;
                    parameters[1].Value = null;
                    parameters[1].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        //Ejecuta el comando
                        oRetornoGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "pa_Inconsistencias_Indicador_Inscripcion_Garantias_Reales", parameters);

                        if (oRetornoGR != null)
                        {
                            while (oRetornoGR.Read())
                            {
                                sbGR.AppendLine(oRetornoGR.ReadOuterXml());
                            }

                            vsObtenerGR = sbGR.ToString();

                            if (vsObtenerGR.Length > 0)
                            {
                                strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerGR);
                                if (strMensajeObtenido.Length > 1)
                                {
                                    if (strMensajeObtenido[0].CompareTo("0") != 0)
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al indicador de inscripción", Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al indicador de inscripción", Mensajes.ASSEMBLY));
                            }
                        }
                    }

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        //Ejecuta el comando
                        oRetornoGV = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "pa_Inconsistencias_Indicador_Inscripcion_Garantias_Valor", parameters);

                        if (oRetornoGV != null)
                        {
                            while (oRetornoGV.Read())
                            {
                                sbGV.AppendLine(oRetornoGV.ReadOuterXml());
                            }

                            vsObtenerGV = sbGV.ToString();

                            if (vsObtenerGV.Length > 0)
                            {
                                strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerGV);
                                if (strMensajeObtenido.Length > 1)
                                {
                                    if (strMensajeObtenido[0].CompareTo("0") != 0)
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al indicador de inscripción", Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al indicador de inscripción", Mensajes.ASSEMBLY));
                            }
                        }
                    }

                    //Escribe el encabezado del archivo
                    writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tTIPO_BIEN\tCODIGO_BIEN\tTIPO_MITIGADOR\tTIPO_DOCUMENTO_LEGAL\tTIPO_INCONSISTENCIA\tTIPO_GARANTIA\tDESCRIPCION_TIPO_GARANTIA\tNUMERO_SEGURIDAD\tTIPO_INSTRUMENTO");

                    xmlTrama.LoadXml(vsObtenerGR);

                    if (xmlTrama != null)
                    {
                        xmlInconsistencias = xmlTrama.SelectSingleNode("//DETALLE").ChildNodes;

                        if (xmlInconsistencias != null)
                        {
                            foreach (XmlNode Inconsistencia in xmlInconsistencias)
                            {
                                if (Inconsistencia.HasChildNodes)
                                {
                                    writer.WriteLine(Inconsistencia.InnerText);
                                }

                                #region Obsoleto
                                //writer.WriteLine(
                                //    ((xmlTrama.SelectSingleNode("//CONTABILIDAD") != null) ? xmlTrama.SelectSingleNode("//CONTABILIDAD").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//OFICINA") != null) ? xmlTrama.SelectSingleNode("//OFICINA").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//MONEDA") != null) ? xmlTrama.SelectSingleNode("//MONEDA").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//PRODUCTO") != null) ? xmlTrama.SelectSingleNode("//PRODUCTO").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//OPERACION") != null) ? xmlTrama.SelectSingleNode("//OPERACION").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//TIPO_BIEN") != null) ? xmlTrama.SelectSingleNode("//TIPO_BIEN").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//CODIGO_BIEN") != null) ? xmlTrama.SelectSingleNode("//CODIGO_BIEN").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//TIPO_MITIGADOR") != null) ? xmlTrama.SelectSingleNode("//TIPO_MITIGADOR").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//TIPO_DOCUMENTO_LEGAL") != null) ? xmlTrama.SelectSingleNode("//TIPO_DOCUMENTO_LEGAL").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//TIPO_INCONSISTENCIA") != null) ? xmlTrama.SelectSingleNode("//TIPO_INCONSISTENCIA").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//TIPO_GARANTIA") != null) ? xmlTrama.SelectSingleNode("//TIPO_GARANTIA").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//DESCRIPCION_TIPO_GARANTIA") != null) ? xmlTrama.SelectSingleNode("//DESCRIPCION_TIPO_GARANTIA").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//NUMERO_SEGURIDAD") != null) ? xmlTrama.SelectSingleNode("//NUMERO_SEGURIDAD").InnerText : string.Empty) + "\t" +
                                //    ((xmlTrama.SelectSingleNode("//TIPO_INSTRUMENTO") != null) ? xmlTrama.SelectSingleNode("//TIPO_INSTRUMENTO").InnerText : string.Empty) + "\t"
                                //);

                                #endregion Obsoleto
                            }
                        }
                    }

                    xmlTrama.LoadXml(vsObtenerGV);

                    if (xmlTrama != null)
                    {
                        xmlInconsistencias = xmlTrama.SelectSingleNode("//DETALLE").ChildNodes;

                        if (xmlInconsistencias != null)
                        {
                            foreach (XmlNode Inconsistencia in xmlInconsistencias)
                            {
                                if (Inconsistencia.HasChildNodes)
                                {
                                    writer.WriteLine(Inconsistencia.InnerText);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS_DETALLE, "al indicador de inscripción", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al indicador de inscripción", Mensajes.ASSEMBLY)));
            }
        }

        #endregion Error de Inscripción

        #region Error de Partido y Finca

        /// <summary>
        /// Este método genera el archivo de inconsistencias del partido y la finca, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public void GenerarErrorPartidoyFincaTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            XmlReader oRetornoGR = null;
            XmlDocument xmlTrama = new XmlDocument();
            XmlNodeList xmlInconsistencias;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerGR = string.Empty;
            string fileName;
            StringBuilder sbGR = new StringBuilder();

            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Error Partido y Finca") : (strRutaDestino + "Error Partido y Finca.txt");

            try
            {
                using (StreamWriter writer = new StreamWriter(File.Create(fileName), Encoding.Unicode))
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                    parameters[0].Value = strIDUsuario;
                    parameters[1].Value = null;
                    parameters[1].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        //Ejecuta el comando
                        oRetornoGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "pa_Inconsistencias_Partido_Finca", parameters);

                        if (oRetornoGR != null)
                        {
                            while (oRetornoGR.Read())
                            {
                                sbGR.AppendLine(oRetornoGR.ReadOuterXml());
                            }

                            vsObtenerGR = sbGR.ToString();

                            if (vsObtenerGR.Length > 0)
                            {
                                strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerGR);
                                if (strMensajeObtenido.Length > 1)
                                {
                                    if (strMensajeObtenido[0].CompareTo("0") != 0)
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al partido y finca", Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al partido y finca", Mensajes.ASSEMBLY));
                            }
                        }
                    }


                    //Escribe el encabezado del archivo
                    writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tDEUDOR\tNOMBRE_DEUDOR\tTIPO_GARANTIA_REAL\tCLASE_GARANTIA\tGARANTIA_REAL\tTIPO_INCONSISTENCIA");

                    xmlTrama.LoadXml(vsObtenerGR);

                    if (xmlTrama != null)
                    {
                        xmlInconsistencias = xmlTrama.SelectSingleNode("//DETALLE").ChildNodes;

                        if (xmlInconsistencias != null)
                        {
                            foreach (XmlNode Inconsistencia in xmlInconsistencias)
                            {
                                if (Inconsistencia.HasChildNodes)
                                {
                                    writer.WriteLine(Inconsistencia.InnerText);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS_DETALLE, "al partido y finca", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al partido y finca", Mensajes.ASSEMBLY)));
            }
        }

        #endregion Error de Partido y Finca

        #region Error Tipo de Garantía Real

        /// <summary>
        /// Este método genera el archivo de inconsistencias del tipo de garantía real, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public void GenerarErrorTipoGarantiaRealTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            XmlReader oRetornoGR = null;
            XmlDocument xmlTrama = new XmlDocument();
            XmlNodeList xmlInconsistencias;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerGR = string.Empty;
            string fileName;
            StringBuilder sbGR = new StringBuilder();

            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Error Tipo Garantía Real") : (strRutaDestino + "Error Tipo Garantía Real.txt");

            try
            {
                using (StreamWriter writer = new StreamWriter(File.Create(fileName), Encoding.Unicode))
                {

                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                    parameters[0].Value = strIDUsuario;
                    parameters[1].Value = null;
                    parameters[1].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        //Ejecuta el comando
                        oRetornoGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Inconsistencias_Tipo_Garantia_Real", parameters);

                        if (oRetornoGR != null)
                        {
                            while (oRetornoGR.Read())
                            {
                                sbGR.AppendLine(oRetornoGR.ReadOuterXml());
                            }

                            vsObtenerGR = sbGR.ToString();

                            if (vsObtenerGR.Length > 0)
                            {
                                strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerGR);
                                if (strMensajeObtenido.Length > 1)
                                {
                                    if (strMensajeObtenido[0].CompareTo("0") != 0)
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al tipo de garantía real", Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al tipo de garantía real", Mensajes.ASSEMBLY));
                            }
                        }
                    }


                    //Escribe el encabezado del archivo
                    writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tTIPO_GARANTIA_REAL\tGARANTIA_REAL\tCLASE_GARANTIA\tTIPO_BIEN\tTIPO_MITIGADOR_RIESGO\tTIPO_DOCUMENTO_LEGAL\tGRADO_GRAVAMEN\tTIPO_INCONSISTENCIA");

                    xmlTrama.LoadXml(vsObtenerGR);

                    if (xmlTrama != null)
                    {
                        xmlInconsistencias = xmlTrama.SelectSingleNode("//DETALLE").ChildNodes;

                        if (xmlInconsistencias != null)
                        {
                            foreach (XmlNode Inconsistencia in xmlInconsistencias)
                            {
                                if (Inconsistencia.HasChildNodes)
                                {
                                    writer.WriteLine(Inconsistencia.InnerText);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS_DETALLE, "al tipo de garantía real", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al tipo de garantía real", Mensajes.ASSEMBLY)));
            }
        }

        #endregion Error Tipo de Garantía Real

        #region Error de Valuaciones

        /// <summary>
        /// Este método genera el archivo de inconsistencias de los avalúos, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public void GenerarErrorValuacionesTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            XmlReader oRetornoGR = null;
            XmlDocument xmlTrama = new XmlDocument();
            XmlNodeList xmlInconsistencias;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerGR = string.Empty;
            string fileName;
            StringBuilder sbGR = new StringBuilder();

            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Error de Valuaciones") : (strRutaDestino + "Error de Valuaciones.txt");

            try
            {
                using (StreamWriter writer = new StreamWriter(File.Create(fileName), Encoding.Unicode))
                {

                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                    parameters[0].Value = strIDUsuario;
                    parameters[1].Value = null;
                    parameters[1].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        //Ejecuta el comando
                        oRetornoGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Inconsistencias_Valuaciones_Garantia_Real", parameters);

                        if (oRetornoGR != null)
                        {
                            while (oRetornoGR.Read())
                            {
                                sbGR.AppendLine(oRetornoGR.ReadOuterXml());
                            }

                            vsObtenerGR = sbGR.ToString();

                            if (vsObtenerGR.Length > 0)
                            {
                                strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerGR);
                                if (strMensajeObtenido.Length > 1)
                                {
                                    if (strMensajeObtenido[0].CompareTo("0") != 0)
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "de los avalúos", Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "de los avalúos", Mensajes.ASSEMBLY));
                            }
                        }
                    }


                    //Escribe el encabezado del archivo
                    writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tCONTRATO\tTIPO_GARANTIA_REAL\tGARANTIA_REAL\tCLASE_GARANTIA\t%_ACEPTACION\tFECHA_VALUACION\tFECHA_PRESENTACION\t_FECHA_ULTIMO_SEGUIMIENTO\tMONTO_TOTAL_AVALUO\tMTO_ULTIMA_TASACION_TERRENO\tMTO_TASACION_ACTUALIZADA_TERRENO\tMTO_ULTIMA_TASACION_NO_TERRENO\tMTO_TASACION_ACTUALIZADA_NO_TERRENO\tTIPO_INCONSISTENCIA");

                    xmlTrama.LoadXml(vsObtenerGR);

                    if (xmlTrama != null)
                    {
                        xmlInconsistencias = xmlTrama.SelectSingleNode("//DETALLE").ChildNodes;

                        if (xmlInconsistencias != null)
                        {
                            foreach (XmlNode Inconsistencia in xmlInconsistencias)
                            {
                                if (Inconsistencia.HasChildNodes)
                                {
                                    writer.WriteLine(Inconsistencia.InnerText);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS_DETALLE, "a los avalúos", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "a los avalúos", Mensajes.ASSEMBLY)));
            }
        }

        #endregion Error de Valuaciones

        #region Error de Clase de Garantía

        /// <summary>
        /// Este método genera el archivo de inconsistencias de la clase de garantía diferente entre registros de una misma finca o prenda, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public void GenerarErrorClaseGarantiaRealTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            XmlReader oRetornoGR = null;
            XmlDocument xmlTrama = new XmlDocument();
            XmlNodeList xmlInconsistencias;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerGR = string.Empty;
            string fileName;
            StringBuilder sbGR = new StringBuilder();

            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Error en Clase de Garantía") : (strRutaDestino + "Error en Clase de Garantía.txt");

            try
            {
                using (StreamWriter writer = new StreamWriter(File.Create(fileName), Encoding.Unicode))
                {

                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                    parameters[0].Value = strIDUsuario;
                    parameters[1].Value = null;
                    parameters[1].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        //Ejecuta el comando
                        oRetornoGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Inconsistencias_Clase_Garantia_Real", parameters);

                        if (oRetornoGR != null)
                        {
                            while (oRetornoGR.Read())
                            {
                                sbGR.AppendLine(oRetornoGR.ReadOuterXml());
                            }

                            vsObtenerGR = sbGR.ToString();

                            if (vsObtenerGR.Length > 0)
                            {
                                strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerGR);
                                if (strMensajeObtenido.Length > 1)
                                {
                                    if (strMensajeObtenido[0].CompareTo("0") != 0)
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "a la clases de garantía", Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "a la clases de garantía", Mensajes.ASSEMBLY));
                            }
                        }
                    }

                    //Escribe el encabezado del archivo
                    writer.WriteLine("FINCA\tPARTIDO\tCLASE_BIEN\tPLACA\tCLASE_GARANTIA\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tCONTRATO\tFECHA_VALUACION_SICC\tFECHA_VALUACION\tMONTO_TOTAL_AVALUO\tMONTO_MITIGADOR_RIESGO\tTIPO_BIEN\tTIPO_MITIGADOR_RIESGO");

                    xmlTrama.LoadXml(vsObtenerGR);

                    if (xmlTrama != null)
                    {
                        xmlInconsistencias = xmlTrama.SelectSingleNode("//DETALLE").ChildNodes;

                        if (xmlInconsistencias != null)
                        {
                            foreach (XmlNode Inconsistencia in xmlInconsistencias)
                            {
                                if (Inconsistencia.HasChildNodes)
                                {
                                    writer.WriteLine(Inconsistencia.InnerText);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS_DETALLE, "a la clases de garantía", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "a la clases de garantía", Mensajes.ASSEMBLY)));
            }
        }

        #endregion Error de Clase de Garantía

        #region Error con Pólizas de las Garantías Reales

        /// <summary>
        /// Este método genera el archivo de inconsistencias de las pólizas de las garantías reales, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public void GenerarErrorPolizasGarantiaRealTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            XmlReader oRetornoGR = null;
            XmlDocument xmlTrama = new XmlDocument();
            XmlNodeList xmlInconsistencias;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerGR = string.Empty;
            string fileName;
            StringBuilder sbGR = new StringBuilder();

            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Errores en Pólizas") : (strRutaDestino + "Errores en Pólizas.txt");

            try
            {
                using (StreamWriter writer = new StreamWriter(File.Create(fileName), Encoding.Unicode))
                {

                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                    parameters[0].Value = strIDUsuario;
                    parameters[1].Value = null;
                    parameters[1].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        //Ejecuta el comando
                        oRetornoGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Inconsistencias_Polizas_Garantias_Reales", parameters);

                        if (oRetornoGR != null)
                        {
                            while (oRetornoGR.Read())
                            {
                                sbGR.AppendLine(oRetornoGR.ReadOuterXml());
                            }

                            vsObtenerGR = sbGR.ToString();

                            if (vsObtenerGR.Length > 0)
                            {
                                strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerGR);
                                if (strMensajeObtenido.Length > 1)
                                {
                                    if (strMensajeObtenido[0].CompareTo("0") != 0)
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "a la póliza de garantía", Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "a la póliza de garantía", Mensajes.ASSEMBLY));
                            }
                        }
                    }

                    //Escribe el encabezado del archivo
                    writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tCONTRATO\tTIPO_GARANTIA_REAL\tTIPO_BIEN\tGARANTIA_REAL\tCLASE_GARANTIA\tMONTO_TOTAL_AVALUO\tCODIGO_SAP\tACREEDOR\tNOMBRE_ACREEDOR\tMONTO_POLIZA\tFECHA_VENCIMIENTO_POLIZA\tTIPO_INCONSISTENCIA");

                    xmlTrama.LoadXml(vsObtenerGR);

                    if (xmlTrama != null)
                    {
                        xmlInconsistencias = xmlTrama.SelectSingleNode("//DETALLE").ChildNodes;

                        if (xmlInconsistencias != null)
                        {
                            foreach (XmlNode Inconsistencia in xmlInconsistencias)
                            {
                                if (Inconsistencia.HasChildNodes)
                                {
                                    writer.WriteLine(Inconsistencia.InnerText);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS_DETALLE, "a la póliza de garantía", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "a la póliza de garantía", Mensajes.ASSEMBLY)));
            }
        }

        #endregion Error con Pólizas de las Garantías Reales

        #region Errores de Porcentaje de Aceptacion
        /// <summary>
        /// Este método genera el archivo de inconsistencias de los porcentajes de aceptacion, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public void GenerarErrorPorcentajeAceptacionRealTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            XmlReader oRetornoGR = null;
            XmlDocument xmlTrama = new XmlDocument();
            XmlNodeList xmlInconsistencias;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerGR = string.Empty;
            string fileName;
            StringBuilder sbGR = new StringBuilder();

            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Errores en Porcentaje de Aceptación") : (strRutaDestino + "Errores en Porcentaje de Aceptación.txt");

            try
            {
                using (StreamWriter writer = new StreamWriter(File.Create(fileName), Encoding.Unicode))
                {

                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                    parameters[0].Value = strIDUsuario;
                    parameters[1].Value = null;
                    parameters[1].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        //Ejecuta el comando
                        oRetornoGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Inconsistencias_Porcentaje_Aceptacion_Real", parameters);

                        if (oRetornoGR != null)
                        {
                            while (oRetornoGR.Read())
                            {
                                sbGR.AppendLine(oRetornoGR.ReadOuterXml());
                            }

                            vsObtenerGR = sbGR.ToString();

                            if (vsObtenerGR.Length > 0)
                            {
                                strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerGR);
                                if (strMensajeObtenido.Length > 1)
                                {
                                    if (strMensajeObtenido[0].CompareTo("0") != 0)
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al porcentaje de aceptación", Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al porcentaje de aceptación", Mensajes.ASSEMBLY));
                            }
                        }
                    }

                    //Escribe el encabezado del archivo
                    writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tCONTRATO\tID_GARANTIA\tMONTO_MITIGADOR\tPORCENTAJE_ACEPTACION\tPORCENTAJE_ACEPTACION_CALCULADO\tCONDICION\tTIPO_INCONSISTENCIA");

                    xmlTrama.LoadXml(vsObtenerGR);

                    if (xmlTrama != null)
                    {
                        xmlInconsistencias = xmlTrama.SelectSingleNode("//DETALLE").ChildNodes;

                        if (xmlInconsistencias != null)
                        {
                            foreach (XmlNode Inconsistencia in xmlInconsistencias)
                            {
                                if (Inconsistencia.HasChildNodes)
                                {
                                    writer.WriteLine(Inconsistencia.InnerText);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS_DETALLE, "al porcentaje de aceptación", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_INCONSISTENCIAS, "al porcentaje de aceptación", Mensajes.ASSEMBLY)));
            }
        }

        #endregion

        #endregion Inconsistencias

        #region Alertas

        /// <summary>
        /// Este método genera el archivo de alertas del indicador de inscripción, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="codCatalogoIndIns">Código del catálogo del indicador de inscripción</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public void GenerarAlertasInscripcionTXT(string strRutaDestino, string strIDUsuario, int codCatalogoIndIns, bool bEsServicioWindows)
        {
            XmlReader oRetornoGR = null;
            XmlDocument xmlTrama = new XmlDocument();
            XmlNodeList xmlAlertas;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerGR = string.Empty;
            string fileName;
            StringBuilder sbGR = new StringBuilder();

            fileName = (bEsServicioWindows) ? nombreArchivo(strRutaDestino, "Indicadores de Inscripción por Cambiar") : (strRutaDestino + "Indicadores de Inscripción por Cambiar.txt");

            try
            {
                using (StreamWriter writer = new StreamWriter(File.Create(fileName), Encoding.Unicode))
                {

                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("piCatalogo_Ind_Ins", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                    parameters[0].Value = strIDUsuario;
                    parameters[1].Value = codCatalogoIndIns;
                    parameters[2].Value = null;
                    parameters[2].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        //Ejecuta el comando
                        oRetornoGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "pa_Alertas_Indicador_Inscripcion_Garantias_Reales", parameters);

                        if (oRetornoGR != null)
                        {
                            while (oRetornoGR.Read())
                            {
                                sbGR.AppendLine(oRetornoGR.ReadOuterXml());
                            }

                            vsObtenerGR = sbGR.ToString();

                            if (vsObtenerGR.Length > 0)
                            {
                                strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerGR);
                                if (strMensajeObtenido.Length > 1)
                                {
                                    if (strMensajeObtenido[0].CompareTo("0") != 0)
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorObteniendoAlertas, "al indicador de inscripción", Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorObteniendoAlertas, "al indicador de inscripción", Mensajes.ASSEMBLY));
                            }
                        }
                    }

                    //Escribe el encabezado del archivo
                    writer.WriteLine("CONTABILIDAD\tOFICINA\tMONEDA\tPRODUCTO\tOPERACION\tTIPO_BIEN\tCODIGO_BIEN\tTIPO_MITIGADOR\tTIPO_DOCUMENTO_LEGAL\tMONTO_MITIGADOR\tPORCENTAJE_ACEPTACION\tTIPO_GARANTIA\tDESCRIPCION_TIPO_GARANTIA\tINDICADOR_INSCRIPCION\tDIAS_ACUMULADOS");

                    xmlTrama.LoadXml(vsObtenerGR);

                    if (xmlTrama != null)
                    {
                        xmlAlertas = xmlTrama.SelectSingleNode("//DETALLE").ChildNodes;

                        if (xmlAlertas != null)
                        {
                            foreach (XmlNode Alerta in xmlAlertas)
                            {
                                if (Alerta.HasChildNodes)
                                {
                                    writer.WriteLine(Alerta.InnerText);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoAlertasDetalle, "al indicador de inscripción", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes._errorObteniendoAlertas, "al indicador de inscripción", Mensajes.ASSEMBLY)));
            }
        }

        #endregion Alertas

        #region Bitacora

        /// <summary>
        /// Este método genera el archivo de cambios en las garantias de forma masiva en formato TXT 
        /// </summary>
        public string GenerarInformacionCambiosGarantiasTXT(string strRutaDestino,int accion,DateTime fechaInicio,DateTime fechaFin)
        {            
            string fileName;

            fileName =  nombreArchivo(strRutaDestino, "Archivo de Cambios en Garantías");         

            try
            {
                using (StreamWriter writer = new StreamWriter(File.Create(fileName), Encoding.Unicode))
                {

                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piAccion", SqlDbType.Int),
                        new SqlParameter("pdtFecha_Inicio", SqlDbType.DateTime),
                        new SqlParameter("pdtFecha_Fin", SqlDbType.DateTime)
                    };

                    parameters[0].Value = accion;                
                    parameters[1].Value = fechaInicio;
                    parameters[2].Value = fechaFin;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        //Ejecuta el comando
                        dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "Generar_Informacion_Cambios_Garantias", parameters, tiempo_Espera_Ejecucion);

                        if ((dsDatos != null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1 ) >= 0))
                        {
                            //Escribe el encabezado del archivo
                            writer.WriteLine("GARANTIA\tTIPO_GARANTIA\tOPERACION_CREDITICIA\tACCION_REALIZADA\tCAMPO\tVALOR_PASADO\tVALOR_ACTUAL\tFECHA_MODIFICACION\tUSUARIO\tNOMBRE");

                            for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count-1; i++)
                            {
                                writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["GARANTIA"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["TIPO_GARANTIA"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["OPERACION_CREDITICIA"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["ACCION_REALIZADA"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["CAMPO"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["VALOR_PASADO"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["VALOR_ACTUAL"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["FECHA_MODIFICACION"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["USUARIO"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["NOMBRE"].ToString() + "\t"                                           
                                                );
                            }                             
                        }
                    }
                }

                return fileName;
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoAlertasDetalle, "al indicador de inscripción", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes._errorObteniendoAlertas, "al indicador de inscripción", Mensajes.ASSEMBLY)));
            }
        }

        /// <summary>
        /// Este método genera el archivo de cambios en las garantias de forma individual en formato TXT 
        /// </summary>
        public string GenerarInformacionCambiosGarantiasTXT(string strRutaDestino,string strGarantia)
        {          
            string fileName;

            fileName = nombreArchivo(strRutaDestino, "Archivo de Cambios en Garantías");

            try
            {
                using (StreamWriter writer = new StreamWriter(File.Create(fileName), Encoding.Unicode))
                {

                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piOperacion_Crediticia", SqlDbType.VarChar,30),
                        new SqlParameter("piCod_Garantia", SqlDbType.VarChar,30),
                        new SqlParameter("piAccion", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                    parameters[0].Value = "";
                    parameters[1].Value = strGarantia;          
                    parameters[2].Value = 2; //1: Consulta Garantias Asociadas 2:Consulta archivo txt
                    parameters[3].Value = null;
                    parameters[3].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        //Ejecuta el comando
                        dsDatos = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "Consultar_Cambios_Garantias", parameters, tiempo_Espera_Ejecucion);

                        if ((dsDatos != null) || ((dsDatos != null) && (dsDatos.Tables["Datos"].Rows.Count - 1) >= 0))
                        {
                            //Escribe el encabezado del archivo
                            writer.WriteLine("GARANTIA\tTIPO_GARANTIA\tOPERACION_CREDITICIA\tACCION_REALIZADA\tCAMPO\tVALOR_PASADO\tVALOR_ACTUAL\tFECHA_MODIFICACION\tUSUARIO\tNOMBRE");

                            for (int i = 0; i <= dsDatos.Tables["Datos"].Rows.Count - 1; i++)
                            {
                                writer.WriteLine(dsDatos.Tables["Datos"].Rows[i]["GARANTIA"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["TIPO_GARANTIA"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["OPERACION_CREDITICIA"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["ACCION_REALIZADA"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["CAMPO"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["VALOR_PASADO"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["VALOR_ACTUAL"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["FECHA_MODIFICACION"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["USUARIO"].ToString() + "\t" +
                                                 dsDatos.Tables["Datos"].Rows[i]["NOMBRE"].ToString() + "\t"
                                                );
                            }
                        }                     
                    }  
                }

                return fileName;
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoAlertasDetalle, "al indicador de inscripción", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes._errorObteniendoAlertas, "al indicador de inscripción", Mensajes.ASSEMBLY)));
            }
        }

        #endregion

        #region Métodos privados

        /// <sumary>
        /// Método para determinar la ruta y el nombre del archivo generado
        /// </sumary>
        private string nombreArchivo(string rutaDestino, string nombreArchivo)
        {
            string nombreCompleto;
            string horaHoy;

            /*
             * Para determinar el nombre de archvio se utiliza la fecha y la hora.
             * Es importante notar que la hora va en mayúsculas para que devuelva
             * El formato de 24 horas.
             */
            horaHoy = DateTime.Now.ToString("ddMMMyyyy HH:mm");
            horaHoy = horaHoy.Replace(" ", "_");
            horaHoy = horaHoy.Replace(":", "");

            nombreCompleto = "";

            nombreCompleto = rutaDestino + nombreArchivo + "_" + horaHoy + ".txt";

            return nombreCompleto;
        }

        /// <summary>
        /// Método que filtar las tarjetas según el estado que estas posean.
        /// </summary>
        private void FiltraEstadoTarjetas()
        {
            string strFiltros = string.Empty;
            string strConsulta = "select * from GAR_GIROS_GARANTIAS_FIDUCIARIAS where cod_tipo_documento_legal is not null ";

            DataSet dsDatosFiltrados = new DataSet();
            DataTable dtDatosFiltrados = new DataTable("Datos");

            if ((ConfigurationManager.AppSettings["EstadosExcluyentesTarjeta"] != null)
              && (ConfigurationManager.AppSettings["EstadosExcluyentesTarjeta"].ToString() != string.Empty))
            {
                strFiltros = ConfigurationManager.AppSettings["EstadosExcluyentesTarjeta"].ToString();

                string[] astrFiltros = strFiltros.Split(",".ToCharArray());

                if (astrFiltros.Length > 0)
                {
                    if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Datos"].Rows.Count > 0))
                    {
                        for (int nIndice = 0; nIndice < astrFiltros.Length; nIndice++)
                        {
                            if (nIndice == 0)
                            {
                                if (astrFiltros.Length == 1)
                                {
                                    strConsulta += " and (cod_estado_tarjeta not like '" + astrFiltros[nIndice].ToString() + "')";
                                }
                                else
                                {
                                    strConsulta += " and (cod_estado_tarjeta not like '" + astrFiltros[nIndice].ToString() + "'";
                                }
                            }
                            else
                            {
                                if (nIndice == (astrFiltros.Length - 1))
                                {
                                    strConsulta += " and cod_estado_tarjeta not like '" + astrFiltros[nIndice].ToString() + "')";
                                }
                                else
                                {
                                    strConsulta += " and cod_estado_tarjeta not like '" + astrFiltros[nIndice].ToString() + "'";
                                }
                            }
                        }

                        dsDatos = AccesoBD.ejecutarConsulta(strConsulta);
                    }
                }

            }
        }

        #endregion
    }
}

