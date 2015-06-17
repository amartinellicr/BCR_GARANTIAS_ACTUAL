using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlTypes;
using System.Collections.Specialized;
using System.Xml;
using System.Data.SqlClient;
using System.Diagnostics;

using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;


namespace BCRGARANTIAS.Negocios
{
    public class Bitacora
    {
        #region Variables Globales
            BitacoraBD moBitacoraBD = new BitacoraBD();

        #endregion


        /// <summary>
        /// Método que se encarga de insertar en bitácora los datos requeridos
        /// </summary>
        /// <param name="strTabla">Descripción de la tabla en la que se realiza la operación</param>
        /// <param name="strUsuario">Código del usuario que realiza la operación</param>
        /// <param name="strIP">Dirección IP de la máquina donde se realiza la operación</param>
        /// <param name="nOficina">Código de la oficina donde se realiza la operación</param>
        /// <param name="nOperacion">Código de la operación que es realizada</param>
        /// <param name="nTipoGarantia">Código del tipo de garantía que es utilizada</param>
        /// <param name="nGarantia">Código de la garantía utilizada</param>
        /// <param name="nOperacionCrediticia">Código de la operación crediticia realizada</param>
        /// <param name="strConsulta">Consulta realizada</param>
        /// <param name="strConsulta2">Consulta realizada</param>
        /// <param name="strCampoAfectado">Descripción del campo que ha sido afectado</param>
        /// <param name="strEstadoAnteriorCampoAfectado">Información que posee el campo antes de actualizarse</param>
        /// <param name="strEstadoActualCampoAfectado">Información que posee el campo luego de ser actualizado</param>
        public void InsertarBitacora(string strTabla, string strUsuario, string strIP, int? nOficina, int nOperacion,
            int? nTipoGarantia, string strGarantia, string strOperacionCrediticia, string strConsulta, string strConsulta2,
            string strCampoAfectado, string strEstadoAnteriorCampoAfectado, string strEstadoActualCampoAfectado)
        {

            if (nOficina != null)
            {
                nOficina = (int)nOficina;
            }   

            moBitacoraBD.InsertarBitacora(strTabla, strUsuario, strIP, nOficina, nOperacion, nTipoGarantia,
                strGarantia, strOperacionCrediticia, strConsulta, strConsulta2, strCampoAfectado,
                strEstadoAnteriorCampoAfectado, strEstadoActualCampoAfectado);
        }

      
        /// <summary>
        /// Función que retorna todos los datos que posee la bitácora
        /// </summary>
        /// <param name="strUsuario">Identificación del usuario del que se requieren los datos</param>
        /// <param name="strIP">Número de la IP de la que se requieren los datos</param>
        /// <param name="strOperacion">Código de la operación que se desea, a saber: 1 - Inserción, 2 - Modificación y 3 - Eliminación</param>
        /// <param name="strFechaInicial">Fecha apartir de la que se requieren los datos</param>
        /// <param name="strFechaFinal">Fecha en la que termina la solicitud de datos</param>
        /// <param name="nMantenimiento">Número del mantenimiento del que se desean los datos</param>
        /// <param name="strCriterioOrdenacion">Criterio por el cual se ordenaran los datos</param>
        /// <returns>Dataset con la información recopilada</returns>
        public DataSet GenerarConsultaBD(string strUsuario, string strIP, string strOperacion,
                        string strFechaInicial, string strFechaFinal, int nMantenimiento, string strCriterioOrdenacion)
        {
            DataSet dsDatosBitacora = new DataSet();

            dsDatosBitacora = moBitacoraBD.GenerarConsultaBD(strUsuario, strIP, strOperacion, strFechaInicial,
                                                         strFechaFinal, nMantenimiento, strCriterioOrdenacion);

            return dsDatosBitacora;
        }

        

        //LISTA
        public DataSet ObtenerDatosCambioGarantia(string strOperacionCredicitia, string strGarantia) 
        {            
            DataSet dsDatosCambioGarantia = new DataSet();
            try
            {    

                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piOperacion_Crediticia", SqlDbType.VarChar,30),
                        new SqlParameter("piCod_Garantia", SqlDbType.VarChar,30),    
                        new SqlParameter("piAccion", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                parameters[0].Value = strOperacionCredicitia;
                parameters[1].Value = strGarantia;
                parameters[2].Value = 1; //1: Consulta Garantias Asociadas 2:Consulta archivo txt
                parameters[3].Value = null;
                parameters[3].Direction = ParameterDirection.Output;


                SqlParameter[] parametrosSalida = new SqlParameter[] { };

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();                    
                    dsDatosCambioGarantia = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "Consultar_Cambios_Garantias", parameters, 0);
                }
            }
            catch (Exception ex)
            {
                StringCollection parametros = new StringCollection();
                parametros.Add(strOperacionCredicitia);
                parametros.Add(strGarantia);
                parametros.Add(("El error se da al obtener la información de la base de datos: " + ex.Message));

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS_DETALLE, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);
        
                dsDatosCambioGarantia = null;
            }         
            return dsDatosCambioGarantia;
        }


    }//
}//
