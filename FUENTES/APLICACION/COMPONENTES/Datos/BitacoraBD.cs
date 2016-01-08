using System;
using System.Data.SqlClient;
using System.Data;


namespace BCRGARANTIAS.Datos
{
    public class BitacoraBD: AccesoBD
    {
        #region "Bitacora de Base de datos"
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
            try
            {
                SqlConnection oConexion = new SqlConnection(ObtenerConnectionString());
                SqlCommand oComando = null;

                oComando = new SqlCommand("pa_InsertarBitacora", oConexion);

                SqlDataAdapter oDataAdapter = new SqlDataAdapter();

                //declara las propiedades del comando
                oComando.CommandType = CommandType.StoredProcedure;
                oComando.CommandTimeout = 120;

                if (nOficina != null)
                {
                    nOficina = (int)nOficina;
                }

                if (strConsulta == string.Empty)
                {
                    strConsulta = "-";
                }

                if (strConsulta2 == string.Empty)
                {
                    strConsulta2 = "-";
                }

                if (nTipoGarantia != null)
                {
                    nTipoGarantia = (int)nTipoGarantia;
                }

                if (strGarantia == string.Empty)
                {
                    strGarantia = "-";
                }

                if (strOperacionCrediticia == string.Empty)
                {
                    strOperacionCrediticia = "-";
                }

                if (strCampoAfectado == string.Empty)
                {
                    strCampoAfectado = "-";
                }

                if (strEstadoAnteriorCampoAfectado == string.Empty)
                {
                    strEstadoAnteriorCampoAfectado = "-";
                }

                if (strEstadoActualCampoAfectado == string.Empty)
                {
                    strEstadoActualCampoAfectado = "-";
                }

                oComando.Parameters.AddWithValue("@strTabla", strTabla);
                oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
                oComando.Parameters.AddWithValue("@strIP", strIP);
                oComando.Parameters.AddWithValue("@nOficina", nOficina);
                oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
                oComando.Parameters.AddWithValue("@nTipoGarantia", nTipoGarantia);
                oComando.Parameters.AddWithValue("@strGarantia", strGarantia);
                oComando.Parameters.AddWithValue("@strOperacionCrediticia", strOperacionCrediticia);
                oComando.Parameters.AddWithValue("@strConsulta", strConsulta);
                oComando.Parameters.AddWithValue("@strConsulta2", strConsulta2);
                oComando.Parameters.AddWithValue("@strCampoAfectado", strCampoAfectado);
                oComando.Parameters.AddWithValue("@strEstadoAnteriorCampoAfectado", strEstadoAnteriorCampoAfectado);
                oComando.Parameters.AddWithValue("@strEstadoActualCampoAfectado", strEstadoActualCampoAfectado);

                //Abre la conexion
                oConexion.Open();
                oDataAdapter.InsertCommand = oComando;
                oDataAdapter.InsertCommand.Connection = oConexion;

                oComando.ExecuteNonQuery();

                oConexion.Close();
            }
            catch 
            {
                throw;
            }
        }

        /// <summary>
        /// Función que se encarga de seleccionar la tabla, si aplica, de la que se desean los datos y 
        /// retorna la información recopilada de la bitácora.
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

            DateTime dFechaInicial = new DateTime();
            DateTime dFechaFinal = new DateTime();

            try
            {
                SqlConnection oConexion = new SqlConnection(ObtenerConnectionString());
                SqlCommand oComando = null;

                oComando = new SqlCommand("pa_Rpt_Bitacora", oConexion);

                SqlDataAdapter oDataAdapter = new SqlDataAdapter();

                //declara las propiedades del comando
                oComando.CommandType = CommandType.StoredProcedure;
                oComando.CommandTimeout = 120;

                if (strUsuario != string.Empty)
                {
                    oComando.Parameters.AddWithValue("strCodigoUsuario", strUsuario);
                }

                if ((strFechaInicial != string.Empty) && (strFechaFinal != string.Empty))
                {
                    dFechaInicial = Convert.ToDateTime(strFechaInicial);
                    dFechaFinal = Convert.ToDateTime(strFechaFinal);

                    if (strFechaInicial.CompareTo(strFechaFinal) == 0)
                    {
                        dFechaFinal = dFechaFinal.AddDays(1);
                    }

                    oComando.Parameters.AddWithValue("dFechaInicial", dFechaInicial);
                    oComando.Parameters.AddWithValue("dFechaFinal", dFechaFinal);
                }

                if (strOperacion.CompareTo("-1") != 0)
                {
                    oComando.Parameters.AddWithValue("nCodigoOperacion", strOperacion);
                }

                if (strIP != string.Empty)
                {
                    oComando.Parameters.AddWithValue("strNumeroIP", strIP);
                }

                
                oComando.Parameters.AddWithValue("strDescTabla", nMantenimiento.ToString());
                

                if (strCriterioOrdenacion != string.Empty)
                {
                    oComando.Parameters.AddWithValue("strCriterioOrden", strCriterioOrdenacion);
                }

                //Abre la conexion
                oConexion.Open();
                oDataAdapter.SelectCommand = oComando;
                oDataAdapter.SelectCommand.Connection = oConexion;
                oDataAdapter.Fill(dsDatosBitacora); //, "Datos");

                oConexion.Close();
                
            }
            catch
            {
                throw;
            }

            return dsDatosBitacora;


            //DataSet dsPrimerConsulta = new DataSet();
            //DataSet dsSegundaConsulta = new DataSet();
            //DataSet dsTerceraConsulta = new DataSet();
            //DataSet dsCuartaConsulta = new DataSet();
            //DataSet dsResultadoConsulta = new DataSet();


            //dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, nMantenimiento.ToString(), 0, strCriterioOrdenacion);
            //if (nMantenimiento != -1)
            //{
            //    switch (nMantenimiento)
            //    {
            //        //Garantías Fiduciarias
            //        case 1: dsPrimerConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, "GAR_GARANTIA_FIDUCIARIA", 0, strCriterioOrdenacion);
            //            dsSegundaConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorGarantias_fiduciarias_x_operacion.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            dsResultadoConsulta = CombinarDatosObtenidos(dsPrimerConsulta, dsSegundaConsulta);
            //            break;

            //        //Garantías de Tarjetas
            //        case 2: dsPrimerConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, "TAR_GARANTIA_FIDUCIARIA", 0, strCriterioOrdenacion);
            //            dsSegundaConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorTarjeta.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            dsResultadoConsulta = CombinarDatosObtenidos(dsPrimerConsulta, dsSegundaConsulta);
            //            dsTerceraConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorGarantias_fiduciarias_x_tarjeta.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            dsResultadoConsulta = CombinarDatosObtenidos(dsResultadoConsulta, dsTerceraConsulta);
            //            dsCuartaConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorGarantias_x_perfil_x_tarjeta.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            dsResultadoConsulta = CombinarDatosObtenidos(dsResultadoConsulta, dsCuartaConsulta);
            //            break;

            //        //Garantías Reales
            //        case 3: dsPrimerConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorGarantia_real.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            dsSegundaConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorGarantias_reales_x_operacion.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            dsResultadoConsulta = CombinarDatosObtenidos(dsPrimerConsulta, dsSegundaConsulta);
            //            break;

            //        //Garantías de Valor
            //        case 4: dsPrimerConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorGarantia_valor.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            dsSegundaConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorGarantias_valor_x_operacion.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            dsResultadoConsulta = CombinarDatosObtenidos(dsPrimerConsulta, dsSegundaConsulta);
            //            break;

            //        //Garantías X Giro
            //        case 5: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorGarantias_x_giro.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            break;

            //        //Capacidad de Pago
            //        case 6: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorCapacidad_pago.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            break;

            //        //Deudores de Garantías Fiduciarias
            //        case 7: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorDeudor.NOMBRE_ENTIDAD, Convert.ToInt32(ConfigurationManager.AppSettings["GARANTIA_FIDUCIARIA"]), strCriterioOrdenacion);
            //            break;

            //        //Deudores de Garantías Reales
            //        case 8: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorDeudor.NOMBRE_ENTIDAD, Convert.ToInt32(ConfigurationManager.AppSettings["GARANTIA_REAL"]), strCriterioOrdenacion);
            //            break;

            //        //Deudores de Garantías de Valor
            //        case 9: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorDeudor.NOMBRE_ENTIDAD, Convert.ToInt32(ConfigurationManager.AppSettings["GARANTIA_VALOR"]), strCriterioOrdenacion);
            //            break;

            //        //Histórico de Ingresos
            //        case 10: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorValuaciones_fiador.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            break;

            //        //Mantenimiento de Valuaciones
            //        case 11: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorValuaciones_reales.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            break;

            //        //Peritos
            //        case 12: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorPerito.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            break;

            //        //Empresas
            //        case 13: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorEmpresa.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            break;

            //        //Catálogos
            //        case 14: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorElemento.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            break;

            //        //Perfiles
            //        case 15: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorPerfil.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            break;

            //        //Roles por Perfil
            //        case 16: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorRoles_x_perfil.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            break;

            //        //Usuarios
            //        case 17: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, ContenedorUsuario.NOMBRE_ENTIDAD, 0, strCriterioOrdenacion);
            //            break;

            //        //Todos los datos filtrados filtrados por los valores dados
            //        default: dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, string.Empty, 0, strCriterioOrdenacion);
            //            break;
            //    }
            //}
            //else
            //{
            //    dsResultadoConsulta = ObtenerDatosBitacora(strUsuario, strIP, strOperacion, strFechaInicial, strFechaFinal, string.Empty, 0, strCriterioOrdenacion);
            //}
            
            //return dsResultadoConsulta;
        }

        /// <summary>
        /// Función que retorna todos los datos que posee la bitácora
        /// </summary>
        /// <param name="strUsuario">Identificación del usuario del que se requieren los datos</param>
        /// <param name="strIP">Número de la IP de la que se requieren los datos</param>
        /// <param name="strOperacion">Código de la operación que se desea, a saber: 1 - Inserción, 2 - Modificación y 3 - Eliminación</param>
        /// <param name="strFechaInicial">Fecha apartir de la que se requieren los datos</param>
        /// <param name="strFechaFinal">Fecha en la que termina la solicitud de datos</param>
        /// <param name="strNombreTabla">Nombre de la tabla de la que se desean los datos</param>
        /// <param name="strCriterioOrdenacion">Criterio por el cual se ordenaran los datos</param>
        /// <returns>Dataset con la información recopilada</returns>
        private DataSet ObtenerDatosBitacora(string strUsuario, string strIP, string strOperacion,
                        string strFechaInicial, string strFechaFinal, string strNombreTabla, int nTipoGarantia, string strCriterioOrdenacion)
        {
            DataSet dsDatosBitacora = new DataSet();

            DateTime dFechaInicial = new DateTime();
            DateTime dFechaFinal = new DateTime();

            try
            {
                SqlConnection oConexion = new SqlConnection(ObtenerConnectionString());
                SqlCommand oComando = null;

                oComando = new SqlCommand("pa_Rpt_Bitacora", oConexion);

                SqlDataAdapter oDataAdapter = new SqlDataAdapter();

                //declara las propiedades del comando
                oComando.CommandType = CommandType.StoredProcedure;
                oComando.CommandTimeout = 120;

                if (strUsuario != string.Empty)
                {
                    oComando.Parameters.AddWithValue("strCodigoUsuario", strUsuario);
                }

                if ((strFechaInicial != string.Empty) && (strFechaFinal != string.Empty))
                {
                    dFechaInicial = Convert.ToDateTime(strFechaInicial);
                    dFechaFinal = Convert.ToDateTime(strFechaFinal);

                    if (strFechaInicial.CompareTo(strFechaFinal) == 0)
                    {
                        dFechaFinal = dFechaFinal.AddDays(1);
                    }

                    oComando.Parameters.AddWithValue("dFechaInicial", dFechaInicial);//dFechaInicial.Year.ToString() + "-" + dFechaInicial.Month.ToString() + "-" + dFechaInicial.Day.ToString()));
                    oComando.Parameters.AddWithValue("dFechaFinal", dFechaFinal);//dFechaFinal.Year.ToString() + "-" + dFechaFinal.Month.ToString() + "-" + dFechaFinal.Day.ToString()));
                }

                if (strOperacion.CompareTo("-1") != 0)
                {
                    oComando.Parameters.AddWithValue("nCodigoOperacion", strOperacion);
                }

                if (strIP != string.Empty)
                {
                    oComando.Parameters.AddWithValue("strNumeroIP", strIP);
                }

                if (strNombreTabla != string.Empty)
                {
                    oComando.Parameters.AddWithValue("strDescTabla", strNombreTabla);
                }

                if (strCriterioOrdenacion != string.Empty)
                {
                    oComando.Parameters.AddWithValue("strCriterioOrden", strCriterioOrdenacion);
                }

                

                //Abre la conexion
                oConexion.Open();
                oDataAdapter.SelectCommand = oComando;
                oDataAdapter.SelectCommand.Connection = oConexion;
                oDataAdapter.Fill(dsDatosBitacora); //, "Datos");
                 
                oConexion.Close();
                //string strConsultaBitacora = "select " + ContenedorBitacora.DES_TABLA + "," +
                //        ContenedorBitacora.COD_USUARIO + "," + ContenedorBitacora.COD_OPERACION + "," +
                //        ContenedorBitacora.COD_IP + "," + ContenedorBitacora.COD_GARANTIA + "," +
                //        ContenedorBitacora.COD_OPERACION_CREDITICIA + "," + ContenedorBitacora.COD_TIPO_GARANTIA + "," +
                //        ContenedorBitacora.FECHA_HORA + "," + ContenedorBitacora.COD_CONSULTA + "," +
                //        ContenedorBitacora.COD_CONSULTA2 + "," + ContenedorBitacora.DES_CAMPO_AFECTADO + "," +
                //        ContenedorBitacora.EST_ANTERIOR_CAMPO_AFECTADO + "," + ContenedorBitacora.EST_ACTUAL_CAMPO_AFECTADO +
                //        " from " + ContenedorBitacora.NOMBRE_ENTIDAD;

                //if (strUsuario != string.Empty)
                //{
                //    strConsultaBitacora += " where " + ContenedorBitacora.COD_USUARIO + " = '" + strUsuario + "'";

                //    if (strIP != string.Empty)
                //    {
                //        strConsultaBitacora += " and " + ContenedorBitacora.COD_IP + " = '" + strIP + "'";
                //    }

                //    if ((strOperacion != string.Empty) && (strOperacion.CompareTo("-1") != 0))
                //    {
                //        strConsultaBitacora += " and " + ContenedorBitacora.COD_OPERACION + " = " + strOperacion;
                //    }

                //    if ((strFechaInicial != string.Empty) && (strFechaFinal != string.Empty))
                //    {
                //        dFechaInicial = Convert.ToDateTime(strFechaInicial);
                //        dFechaFinal = Convert.ToDateTime(strFechaFinal);

                //        if (strFechaInicial.CompareTo(strFechaFinal) == 0)
                //        {
                //            dFechaFinal = dFechaFinal.AddDays(1);
                //        }

                //        strFechaInicial = dFechaInicial.ToString("yyyyMMdd");//new SqlDateTime(dFechaInicial).ToString();
                //        strFechaFinal = dFechaFinal.ToString("yyyyMMdd"); //new SqlDateTime(dFechaFinal).ToString();

                //        strConsultaBitacora += " and " + ContenedorBitacora.FECHA_HORA + " between '" + strFechaInicial + "' and '" +
                //           strFechaFinal + "'";

                //        //strConsultaBitacora += " and " + ContenedorBitacora.FECHA_HORA + " between convert(datetime,'" + dFechaInicial.Year.ToString() + "/" +
                //        //    dFechaInicial.Month.ToString() + "/" + dFechaInicial.Day.ToString() + "') and convert(datetime,'" +
                //        //    dFechaFinal.Year.ToString() + "/" + dFechaFinal.Month.ToString() + "/" + dFechaFinal.Day.ToString() + "')";
                //    }

                //    if (strNombreTabla != string.Empty)
                //    {
                //        strConsultaBitacora += " and " + ContenedorBitacora.DES_TABLA + " = '" + strNombreTabla + "'";

                //        if (nTipoGarantia != 0)
                //        {
                //            strConsultaBitacora += " and " + ContenedorBitacora.COD_TIPO_GARANTIA + " = " + nTipoGarantia.ToString();
                //        }
                //    }
                //}
                //else if (strIP != string.Empty)
                //{
                //    strConsultaBitacora += " where " + ContenedorBitacora.COD_IP + " = '" + strIP + "'";

                //    if ((strOperacion != string.Empty) && (strOperacion.CompareTo("-1") != 0))
                //    {
                //        strConsultaBitacora += " and " + ContenedorBitacora.COD_OPERACION + " = " + strOperacion;
                //    }

                //    if ((strFechaInicial != string.Empty) && (strFechaFinal != string.Empty))
                //    {

                //        dFechaInicial = Convert.ToDateTime(strFechaInicial);
                //        dFechaFinal = Convert.ToDateTime(strFechaFinal);

                //        if (strFechaInicial.CompareTo(strFechaFinal) == 0)
                //        {
                //            dFechaFinal = dFechaFinal.AddDays(1);
                //        }

                //        strFechaInicial = dFechaInicial.ToString("yyyyMMdd");//new SqlDateTime(dFechaInicial).ToString();
                //        strFechaFinal = dFechaFinal.ToString("yyyyMMdd"); //new SqlDateTime(dFechaFinal).ToString();

                //        strConsultaBitacora += " and " + ContenedorBitacora.FECHA_HORA + " between '" + strFechaInicial + "' and '" +
                //           strFechaFinal + "'";


                //        //strConsultaBitacora += " and " + ContenedorBitacora.FECHA_HORA + " between convert(datetime,'" + dFechaInicial.Year.ToString() + "/" +
                //        //    dFechaInicial.Month.ToString() + "/" + dFechaInicial.Day.ToString() + "') and convert(datetime,'" +
                //        //    dFechaFinal.Year.ToString() + "/" + dFechaFinal.Month.ToString() + "/" + dFechaFinal.Day.ToString() + "')";
                //    }

                //    if (strNombreTabla != string.Empty)
                //    {
                //        strConsultaBitacora += " and " + ContenedorBitacora.DES_TABLA + " = '" + strNombreTabla + "'";

                //        if (nTipoGarantia != 0)
                //        {
                //            strConsultaBitacora += " and " + ContenedorBitacora.COD_TIPO_GARANTIA + " = " + nTipoGarantia.ToString();
                //        }
                //    }
                //}
                //else if ((strOperacion != string.Empty) && (strOperacion.CompareTo("-1") != 0))
                //{
                //    strConsultaBitacora += " where " + ContenedorBitacora.COD_OPERACION + " = " + strOperacion;

                //    if ((strFechaInicial != string.Empty) && (strFechaFinal != string.Empty))
                //    {

                //        dFechaInicial = Convert.ToDateTime(strFechaInicial);
                //        dFechaFinal = Convert.ToDateTime(strFechaFinal);

                //        if (strFechaInicial.CompareTo(strFechaFinal) == 0)
                //        {
                //            dFechaFinal = dFechaFinal.AddDays(1);
                //        }

                //        strFechaInicial = dFechaInicial.ToString("yyyyMMdd");//new SqlDateTime(dFechaInicial).ToString();
                //        strFechaFinal = dFechaFinal.ToString("yyyyMMdd"); //new SqlDateTime(dFechaFinal).ToString();

                //        strConsultaBitacora += " and " + ContenedorBitacora.FECHA_HORA + " between '" + strFechaInicial + "' and '" +
                //           strFechaFinal + "'";

                //        //strConsultaBitacora += " and " + ContenedorBitacora.FECHA_HORA + " between convert(datetime,'" + dFechaInicial.Year.ToString() + "/" +
                //        //    dFechaInicial.Month.ToString() + "/" + dFechaInicial.Day.ToString() + "') and convert(datetime,'" +
                //        //    dFechaFinal.Year.ToString() + "/" + dFechaFinal.Month.ToString() + "/" + dFechaFinal.Day.ToString() + "')";
                //    }

                //    if (strNombreTabla != string.Empty)
                //    {
                //        strConsultaBitacora += " and " + ContenedorBitacora.DES_TABLA + " = '" + strNombreTabla + "'";

                //        if (nTipoGarantia != 0)
                //        {
                //            strConsultaBitacora += " and " + ContenedorBitacora.COD_TIPO_GARANTIA + " = " + nTipoGarantia.ToString();
                //        }
                //    }
                //}
                //else if ((strFechaInicial != string.Empty) && (strFechaFinal != string.Empty))
                //{
                //    dFechaInicial = Convert.ToDateTime(strFechaInicial);
                //    dFechaFinal = Convert.ToDateTime(strFechaFinal);

                //    if (strFechaInicial.CompareTo(strFechaFinal) == 0)
                //    {
                //        dFechaFinal = dFechaFinal.AddDays(1);
                //    }

                //    strFechaInicial = dFechaInicial.ToString("yyyyMMdd");//new SqlDateTime(dFechaInicial).ToString();
                //    strFechaFinal = dFechaFinal.ToString("yyyyMMdd"); //new SqlDateTime(dFechaFinal).ToString();

                //    strConsultaBitacora += " and " + ContenedorBitacora.FECHA_HORA + " between '" + strFechaInicial + "' and '" +
                //       strFechaFinal + "'";

                //    //strConsultaBitacora += " where " + ContenedorBitacora.FECHA_HORA + " between convert(datetime,'" + dFechaInicial.Year.ToString() + "/" +
                //    //    dFechaInicial.Month.ToString() + "/" + dFechaInicial.Day.ToString() + "') and convert(datetime,'" +
                //    //    dFechaFinal.Year.ToString() + "/" + dFechaFinal.Month.ToString() + "/" + dFechaFinal.Day.ToString() + "')";
                //}
                //else if (strNombreTabla != string.Empty)
                //{
                //    strConsultaBitacora += " where " + ContenedorBitacora.DES_TABLA + " = '" + strNombreTabla + "'";

                //    if (nTipoGarantia != 0)
                //    {
                //        strConsultaBitacora += " and " + ContenedorBitacora.COD_TIPO_GARANTIA + " = " + nTipoGarantia.ToString();
                //    }
                //}
                //else
                //{
                //    return null;
                //}

                //if ((strCriterioOrdenacion != string.Empty) && (strCriterioOrdenacion.CompareTo("-1") != 0))
                //{
                //    strConsultaBitacora += " order by " + strCriterioOrdenacion;
                //}
                //else
                //{
                //    strConsultaBitacora += " order by " + ContenedorBitacora.COD_USUARIO;
                //}

                //dsDatosBitacora = AccesoBD.ejecutarConsulta(strConsultaBitacora);
            }
            catch
            {
                throw;
            }

            return dsDatosBitacora.Clone();
        }


        /// <summary>
        /// Función que permite obtener un sólo DataSet apartir de dos
        /// </summary>
        /// <param name="dsPrimero">Primero de los DataSet</param>
        /// <param name="dsSegundo">Segundo de los DataSet</param>
        /// <returns>DataSet que posee, según sea el caso, la información que contienen los dos de entrada</returns>
        private DataSet CombinarDatosObtenidos(DataSet dsPrimero, DataSet dsSegundo)
        {
            if ((dsPrimero != null) && (dsPrimero.Tables.Count > 0) && (dsPrimero.Tables[0].Rows.Count > 0))
            {
                if ((dsSegundo != null) && (dsSegundo.Tables.Count > 0) && (dsSegundo.Tables[0].Rows.Count > 0))
                {
                    dsPrimero.Tables[0].Merge(dsSegundo.Tables[0], true);
                    dsPrimero.AcceptChanges();
                }
            }
            else
            {
                if ((dsSegundo != null) && (dsSegundo.Tables.Count > 0) && (dsSegundo.Tables[0].Rows.Count > 0))
                {
                    return dsSegundo;
                }
                else
                {
                    return null;
                }
            }

            return dsPrimero;
        }
        #endregion

        #region "Bitacora de procesos"
        public void IngresaEjecucionProceso( 
                string tcocproceso, 
                DateTime tfecEjecucion,
                string tdesObservacion,
                bool tindError)
        {
            SqlParameter[] parameters = new SqlParameter[] { 
                new SqlParameter("tcocProceso", SqlDbType.VarChar, 20),
                new SqlParameter("tfecEjecucion", SqlDbType.DateTime),
                new SqlParameter("tdesObservacion", SqlDbType.VarChar, 4000),
                new SqlParameter("tindError", SqlDbType.Bit)
            };

            parameters[0].Value = tcocproceso;
            parameters[1].Value = tfecEjecucion;
            parameters[2].Value = tdesObservacion;
            parameters[3].Value = tindError;

            //parameters = new SqlParameterCollection(

            //parameters.Add(new SqlParameter("tcocProceso", tcocproceso, SqlDbType.VarChar, 20));
            //parameters.Add(new SqlParameter("tfecEjecucion", tfecEjecucion, SqlDbType.DateTime, 20));
            //parameters.Add(new SqlParameter("tdesObservacion", tdesObservacion, SqlDbType.VarChar, 254));
            //parameters.Add(new SqlParameter("tindError", tindError, SqlDbType.Bit, 20));


            ExecuteNonQuery("pa_RegistroEjecucionProceso", parameters);

        }
        #endregion
    }

}
