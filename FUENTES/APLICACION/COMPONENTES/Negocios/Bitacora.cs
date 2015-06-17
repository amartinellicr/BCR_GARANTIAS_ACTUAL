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
        /// M�todo que se encarga de insertar en bit�cora los datos requeridos
        /// </summary>
        /// <param name="strTabla">Descripci�n de la tabla en la que se realiza la operaci�n</param>
        /// <param name="strUsuario">C�digo del usuario que realiza la operaci�n</param>
        /// <param name="strIP">Direcci�n IP de la m�quina donde se realiza la operaci�n</param>
        /// <param name="nOficina">C�digo de la oficina donde se realiza la operaci�n</param>
        /// <param name="nOperacion">C�digo de la operaci�n que es realizada</param>
        /// <param name="nTipoGarantia">C�digo del tipo de garant�a que es utilizada</param>
        /// <param name="nGarantia">C�digo de la garant�a utilizada</param>
        /// <param name="nOperacionCrediticia">C�digo de la operaci�n crediticia realizada</param>
        /// <param name="strConsulta">Consulta realizada</param>
        /// <param name="strConsulta2">Consulta realizada</param>
        /// <param name="strCampoAfectado">Descripci�n del campo que ha sido afectado</param>
        /// <param name="strEstadoAnteriorCampoAfectado">Informaci�n que posee el campo antes de actualizarse</param>
        /// <param name="strEstadoActualCampoAfectado">Informaci�n que posee el campo luego de ser actualizado</param>
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
        /// Funci�n que retorna todos los datos que posee la bit�cora
        /// </summary>
        /// <param name="strUsuario">Identificaci�n del usuario del que se requieren los datos</param>
        /// <param name="strIP">N�mero de la IP de la que se requieren los datos</param>
        /// <param name="strOperacion">C�digo de la operaci�n que se desea, a saber: 1 - Inserci�n, 2 - Modificaci�n y 3 - Eliminaci�n</param>
        /// <param name="strFechaInicial">Fecha apartir de la que se requieren los datos</param>
        /// <param name="strFechaFinal">Fecha en la que termina la solicitud de datos</param>
        /// <param name="nMantenimiento">N�mero del mantenimiento del que se desean los datos</param>
        /// <param name="strCriterioOrdenacion">Criterio por el cual se ordenaran los datos</param>
        /// <returns>Dataset con la informaci�n recopilada</returns>
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
                parametros.Add(("El error se da al obtener la informaci�n de la base de datos: " + ex.Message));

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS_DETALLE, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);
        
                dsDatosCambioGarantia = null;
            }         
            return dsDatosCambioGarantia;
        }


    }//
}//
