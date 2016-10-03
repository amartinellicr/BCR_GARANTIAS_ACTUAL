using System;
using System.Data;
using System.Collections.Specialized;
using System.Data.SqlClient;
using System.Diagnostics;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;


namespace BCRGARANTIAS.Negocios
{
    public class HistoricoPorcentajeAceptacion
    {
        #region Variables Globales
        BitacoraBD moBitacoraBD = new BitacoraBD();

        #endregion

        #region Metodos Públicos

        public void InsertarHistorico(string codigoUsuario, int codigoAcccion, string codigoConsulta, int codigoTipoGarantia,
            int codigoTipoMitigador, string descripcionCampoAfectado, string estadoAnteriorCampoAfectado, string estadoActualCampoAfectado)
        {
            try
            {
                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("Insertar_Historico_Porcentaje_Aceptacion", oConexion))
                    {
                        //declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        oComando.Parameters.AddWithValue("@psCodigo_Usuario", codigoUsuario);
                        oComando.Parameters.AddWithValue("@piCodigo_Accion", codigoAcccion);
                        oComando.Parameters.AddWithValue("@piCodigo_Consulta", codigoConsulta);
                        oComando.Parameters.AddWithValue("@piCodigo_Tipo_Garantia", codigoTipoGarantia);
                        oComando.Parameters.AddWithValue("@piCodigo_Tipo_Mitigador", codigoTipoMitigador);
                        oComando.Parameters.AddWithValue("@psDescripcion_Campo_Afectado", (descripcionCampoAfectado.Length == 0) ? "-" : descripcionCampoAfectado);
                        oComando.Parameters.AddWithValue("@psEstado_Anterior_Campo_Afectado", (estadoAnteriorCampoAfectado.Length == 0) ? "-" : estadoAnteriorCampoAfectado);
                        oComando.Parameters.AddWithValue("@psEstado_Actual_Campo_Afectado", (estadoActualCampoAfectado.Length == 0) ? "-" : estadoActualCampoAfectado);

                        //Abre la conexion
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }
            }
            catch
            {
                throw;
            }

        }


        /// <summary>
        /// Obtiene el historico del porcentaje de aceptacion,
        /// </summary>
        /// <param name="codigoPorcentajeAceptacion">Consecutivo del registro, si es null jala todos los registros</param>
        /// <returns>Enditad del tipo Porcentaje de aceptacion</returns>
        public DataSet ObtenerDatosHistorico(clsHistoricoPorcentajeAceptacion eHistorico, DateTime fechaInicio, DateTime fechaFinal)
        {
            DataSet dsDatosHistorico = new DataSet();
            try
            {

                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piCodigo_Tipo_Garantia", SqlDbType.Int),  
                        new SqlParameter("piCodigo_Tipo_Mitigador", SqlDbType.Int),     
                        new SqlParameter("piCodigo_Catalago_Garantia", SqlDbType.Int),     
                        new SqlParameter("piCodigo_Catalago_Mitigador", SqlDbType.Int),     
                        new SqlParameter("psCodigo_Usuario", SqlDbType.VarChar),     
                        new SqlParameter("pdtFecha_Inicio", SqlDbType.DateTime),   
                        new SqlParameter("pdtFecha_Final", SqlDbType.DateTime)                     
                    };

                if ( eHistorico.CodigoTipoGarantia == -1)
                {
                     parameters[0].Value = null;
                }
                else
                {
                  parameters[0].Value = eHistorico.CodigoTipoGarantia;
                }

                if (eHistorico.CodigoTipoMitigador == -1)
                {
                    parameters[1].Value = null;
                }
                else
                {
                      parameters[1].Value = eHistorico.CodigoTipoMitigador;
                }
          
                parameters[2].Value = eHistorico.CodigoCatalogoGarantia;
                parameters[3].Value = eHistorico.CodigoCatalogoMitigador;
                parameters[4].Value = (eHistorico.CodigoUsuario.Trim().Length == 0) ? null: eHistorico.CodigoUsuario;
                parameters[5].Value = fechaInicio;
                parameters[6].Value = fechaFinal;    
                
                SqlParameter[] parametrosSalida = new SqlParameter[] { };

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();
                    dsDatosHistorico = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "Consultar_Historico_Porcentaje_Aceptacion", parameters, 0);

                    oConexion.Close();
                    oConexion.Dispose();
                }
            }
            catch (Exception ex)
            {
                StringCollection parametros = new StringCollection();
                parametros.Add(eHistorico.CodigoTipoGarantia.ToString());
                parametros.Add(eHistorico.CodigoTipoMitigador.ToString());
                parametros.Add(eHistorico.CodigoCatalogoGarantia.ToString());
                parametros.Add(eHistorico.CodigoCatalogoMitigador.ToString());

                parametros.Add(("El error se da al obtener la información de la base de datos: " + ex.Message));

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaHistorialPorcentajeAceptacionDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                dsDatosHistorico = null;
            }
            return dsDatosHistorico;
        }
        
        #endregion

    }//FIN
}//FIN 
