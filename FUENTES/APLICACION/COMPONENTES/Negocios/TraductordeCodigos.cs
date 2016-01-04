using System;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    public class TraductordeCodigos
    {
        #region Variables Globales

        DataTable dtElementos = new DataTable();

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };

        #endregion

        #region Constructor

        public TraductordeCodigos()
        {
            CargarDatos();
        }

        #endregion Constructor

        #region Métodos Públicos Especiales

        #region Obtener la Cédula del Fiador, a partir del código de garantía fiduciaria

        /// <summary>
        /// Función que se encarga de obtener la cédula del fiador según un código de garantía fiduciaria específico
        /// </summary>
        /// <param name="strCodigoGarFidu">String que posee el código de la garantía fiduciaria</param>
        /// <returns>String con el número de céduladel fiador</returns>
        public string ObtenerCedulaFiadorGarFidu(string strCodigoGarFidu)
        {
            string strCedulaFiador = "[" + strCodigoGarFidu + "]";

            try
            {
                if (strCodigoGarFidu.Length > 0)
                {
                    listaCampos = new string[] { clsGarantiaFiduciaria._cedulaFiador,
                                                 clsGarantiaFiduciaria._entidadGarantiaFiduciaria,
                                                 clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, strCodigoGarFidu};

                    sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                    SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("ReturnValue", SqlDbType.VarChar) };

                    parameters[0].Direction = ParameterDirection.ReturnValue;

                    AccesoBD.ExecuteNonQuery(CommandType.Text, sentenciaSql, parameters);

                    strCedulaFiador = ((string) parameters[0].Value);

                    //DataSet dsGarantFiduc = AccesoBD.ejecutarConsulta(sentenciaSql);

                    //if ((dsGarantFiduc != null) && (dsGarantFiduc.Tables.Count > 0) && (dsGarantFiduc.Tables[0].Rows.Count > 0))
                    //{
                    //    if (!dsGarantFiduc.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._cedulaFiador))
                    //    {
                    //        strCedulaFiador = dsGarantFiduc.Tables[0].Rows[0][clsGarantiaFiduciaria._cedulaFiador].ToString();
                    //    }
                    //}
                }
            }
            catch
            {
                throw;
            }

            return strCedulaFiador;
        }

        #endregion

        #region Obtener la Cédula del Deudor, apartir del código de operación crediticia

        /// <summary>
        /// Función que se encarga de obtener la cédula del deudor de una operación crediticia específica
        /// </summary>
        /// <param name="strCodigoOperacionCrediticia">String que posee el código de operación crediticia</param>
        /// <returns>String que posee la cédula del deudor</returns>
        public string ObtenerCedulaDeudor(string strCodigoOperacionCrediticia)
        {
            string strCedulaDeudor = "[" + strCodigoOperacionCrediticia + "]";

            try
            {
                if (strCodigoOperacionCrediticia.Length > 0)
                {
                    listaCampos = new string[] { clsOperacionCrediticia._cedulaDeudor,
                                                 clsOperacionCrediticia._entidadOperacion,
                                                 clsOperacionCrediticia._consecutivoOperacion, strCodigoOperacionCrediticia};

                    sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                    SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("ReturnValue", SqlDbType.VarChar) };

                    parameters[0].Direction = ParameterDirection.ReturnValue;

                    AccesoBD.ExecuteNonQuery(CommandType.Text, sentenciaSql, parameters);

                    strCedulaDeudor = ((string)parameters[0].Value);

                    //DataSet dsOperaciones = AccesoBD.ejecutarConsulta(sentenciaSql);

                    //if ((dsOperaciones != null) && (dsOperaciones.Tables.Count > 0) && (dsOperaciones.Tables[0].Rows.Count > 0))
                    //{
                    //    if (!dsOperaciones.Tables[0].Rows[0].IsNull(clsOperacionCrediticia._cedulaDeudor))
                    //    {
                    //        strCedulaDeudor = dsOperaciones.Tables[0].Rows[0][clsOperacionCrediticia._cedulaDeudor].ToString();
                    //    }
                    //}
                }
            }
            catch
            {
				throw;
            }

            return strCedulaDeudor;
        }
        #endregion

        #region Obtener la Cédula del Fiador y del Deudor de una Tarjeta

        /// <summary>
        /// Función que se encarga de obtener la cédula del fiador según un código de garantía fiduciaria específico
        /// </summary>
        /// <param name="strCodigoGarFiduTar">String que posee el código de la garantía fiduciaria</param>
        /// <returns>String con el número de cédula del fiador</returns>
        public string ObtenerCedulaFiadorGarFiduTar(string strCodigoGarFiduTar)
        {
            string strCedulaFiadorTar = "[" + strCodigoGarFiduTar + "]";

            try
            {
                if (strCodigoGarFiduTar != string.Empty)
                {

                    listaCampos = new string[] { clsGarantiaFiduciariaTarjeta._cedulaFiador,
                                                 clsGarantiaFiduciariaTarjeta._entidadGarantiaFiduciariaTarjeta,
                                                 clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria, strCodigoGarFiduTar};

                    sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                    SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("ReturnValue", SqlDbType.VarChar) };

                    parameters[0].Direction = ParameterDirection.ReturnValue;

                    AccesoBD.ExecuteNonQuery(CommandType.Text, sentenciaSql, parameters);

                    strCedulaFiadorTar = ((string)parameters[0].Value);

                    //DataSet dsGarantFiduc = AccesoBD.ejecutarConsulta(sentenciaSql);

                    //if ((dsGarantFiduc != null) && (dsGarantFiduc.Tables.Count > 0) && (dsGarantFiduc.Tables[0].Rows.Count > 0))
                    //{
                    //    if (!dsGarantFiduc.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._cedulaFiador))
                    //    {
                    //        strCedulaFiadorTar = dsGarantFiduc.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._cedulaFiador].ToString();
                    //    }
                    //}
                }
            }
            catch
            {
                throw;
            }

            return strCedulaFiadorTar;
        }

        /// <summary>
        /// Función que retorna la céduladel deudor de una tarjeta específica
        /// </summary>
        /// <param name="strNumeroTarjeta">String que posee el número de la tarje</param>
        /// <returns>String que posee la cédula del deudor de la tarjeta</returns>
        public string ObtenerCedulaDeudorTarjeta(string strNumeroTarjeta)
        {
            string strCedulaDeudorTar = "[" + strNumeroTarjeta + "]";

            try
            {
                if (strNumeroTarjeta != string.Empty)
                {
                    listaCampos = new string[] { clsTarjeta._cedulaDeudor,
                                                 clsTarjeta._entidadTarjeta,
                                                 clsTarjeta._consecutivoTarjeta, strNumeroTarjeta};

                    sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                    SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("ReturnValue", SqlDbType.VarChar) };

                    parameters[0].Direction = ParameterDirection.ReturnValue;

                    AccesoBD.ExecuteNonQuery(CommandType.Text, sentenciaSql, parameters);

                    strCedulaDeudorTar = ((string)parameters[0].Value);


                    //DataSet dsTarjeta = AccesoBD.ejecutarConsulta(sentenciaSql);

                    //if ((dsTarjeta != null) && (dsTarjeta.Tables.Count > 0) && (dsTarjeta.Tables[0].Rows.Count > 0))
                    //{
                    //    if (!dsTarjeta.Tables[0].Rows[0].IsNull(clsTarjeta._cedulaDeudor))
                    //    {
                    //        strCedulaDeudorTar = dsTarjeta.Tables[0].Rows[0][clsTarjeta._cedulaDeudor].ToString();
                    //    }
                    //}
                }
            }
            catch
            {
                throw;
            }

            return strCedulaDeudorTar;
        }

        #endregion

        #endregion

        #region Métodos Públicos

        #region Carga de datos en tablas globales

        /// <summary>
        /// Método que se encarga de cargar los datos en las diferente tablas globlales utilizadas
        /// </summary>
        private void CargarDatos()
        {
            listaCampos = new string[] {clsElemento._codigoCampo, clsElemento._codigoCatalogo, clsElemento._descripcionElemento, clsElemento._consecutivoElemento,
                                        clsElemento._entidadElemento};

            sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3} FROM dbo.{4}", listaCampos);

            dtElementos = AccesoBD.ejecutarConsulta(sentenciaSql).Tables[0];

         }

        #endregion

        #region Clase de Garantías

        /// <summary>
        /// Función que retorna la descripción correspondiente al código de la clase de garantía
        /// </summary>
        /// <param name="nCodigoClaseGarantia">Entero que posee el código de la clase de garantía</param>
        /// <returns>String con la descripción de la clase de garantía</returns>
        public string TraducirClaseGarantia(int nCodigoClaseGarantia)
        {
            string strDescripcion = "-";

            if (nCodigoClaseGarantia != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_CLASE_GARANTIA"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoClaseGarantia.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drClaseGarantia = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drClaseGarantia.Length > 0) ? drClaseGarantia[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Garantías

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de garantía
        /// </summary>
        /// <param name="nCodigoTipoGarantia">Entero que posee el código del tipo de garantía</param>
        /// <returns>String con la descripción del tipo de garantía</returns>
        public string TraducirTipoGarantia(int nCodigoTipoGarantia)
        {
            string strDescripcion = "-";

            if (nCodigoTipoGarantia != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_GARANTIA"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoGarantia.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoGarantia = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoGarantia.Length > 0) ? drTipoGarantia[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Persona

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de persona
        /// </summary>
        /// <param name="nCodigoTipoFiador">Entero que posee el código del tipo de persona</param>
        /// <returns>String con la descripción del tipo de persona</returns>
        public string TraducirTipoPersona(int nCodigoTipoPersona)
        {
            string strDescripcion = "-";

            if (nCodigoTipoPersona != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_PERSONA"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoPersona.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoPersona = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoPersona.Length > 0) ? drTipoPersona[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Mitigador

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de mitigador
        /// </summary>
        /// <param name="nCodigoTipoMitigador">Entero que posee el código del tipo de mitigador</param>
        /// <returns>String con la descripción del tipo de mitigador</returns>
        public string TraducirTipoMitigador(int nCodigoTipoMitigador)
        {
            string strDescripcion = "-";

            if (nCodigoTipoMitigador != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_MITIGADOR"];
                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoMitigador.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoMitigador = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoMitigador.Length > 0) ? drTipoMitigador[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Documento

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de documento
        /// </summary>
        /// <param name="nCodigoTipoDocumento">Entero que posee el código del tipo de documento</param>
        /// <returns>String con la descripción del tipo de documento</returns>
        public string TraducirTipoDocumento(int nCodigoTipoDocumento)
        {
            string strDescripcion = "-";

            if (nCodigoTipoDocumento != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPOS_DOCUMENTOS"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoDocumento.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoDocumento = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoDocumento.Length > 0) ? drTipoDocumento[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Operación Especial

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de operación especial
        /// </summary>
        /// <param name="nCodigoTipoOperacionEspecial">Entero que posee el código del tipo de operación especial</param>
        /// <returns>String con la descripción del tipo de operación especial</returns>
        public string TraducirTipoOperacionEspecial(int nCodigoTipoOperacionEspecial)
        {
            string strDescripcion = "-";

            if (nCodigoTipoOperacionEspecial != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_OPERACION_ESPECIAL"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoOperacionEspecial.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoOperacionEspecial = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoOperacionEspecial.Length > 0) ? drTipoOperacionEspecial[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Moneda

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de moneda
        /// </summary>
        /// <param name="nCodigoTipoMoneda">Entero que posee el código del tipo de moneda</param>
        /// <returns>String con la descripción del tipo de moneda</returns>
        public string TraducirTipoMoneda(int nCodigoTipoMoneda)
        {
            string strDescripcion = "-";

            if (nCodigoTipoMoneda != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_MONEDA"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoMoneda.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoMoneda = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoMoneda.Length > 0) ? drTipoMoneda[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Capacidad de Pago

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de capacidad de pago
        /// </summary>
        /// <param name="nCodigoTipoCapacidadPago">Entero que posee el código del tipo de capacidad de pago</param>
        /// <returns>String con la descripción del tipo de capacidad de pago</returns>
        public string TraducirTipoCapacidadPago(int nCodigoTipoCapacidadPago)
        {
            string strDescripcion = "-";

            if (nCodigoTipoCapacidadPago != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_CAPACIDAD_PAGO"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoCapacidadPago.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoCapacidadPago = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoCapacidadPago.Length > 0) ? drTipoCapacidadPago[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Condición Especial

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de condición especial
        /// </summary>
        /// <param name="nCodigoTipoCondicionEspecial">Entero que posee el código del tipo de condición especial</param>
        /// <returns>String con la descripción del tipo de condición especial</returns>
        public string TraducirTipoCondicionEspecial(int nCodigoTipoCondicionEspecial)
        {
            string strDescripcion = "-";

            if (nCodigoTipoCondicionEspecial != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_CONDICION_ESPECIAL"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoCondicionEspecial.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoCondicionEspecial = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoCondicionEspecial.Length > 0) ? drTipoCondicionEspecial[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Código de Empresa

        /// <summary>
        /// Función que retorna la descripción correspondiente al código de empresa
        /// </summary>
        /// <param name="nCodigoEmpresa">Entero que posee el código de empresa</param>
        /// <returns>String con la descripción de empresa</returns>
        public string TraducirCodigoEmpresa(int nCodigoEmpresa)
        {
            string strDescripcion = "-";

            if (nCodigoEmpresa != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_CODIGO_EMPRESA"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoEmpresa.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drCodigoEmpresa = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drCodigoEmpresa.Length > 0) ? drCodigoEmpresa[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Empresa

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de empresa
        /// </summary>
        /// <param name="nCodigoTipoEmpresa">Entero que posee el código del tipo de empresa</param>
        /// <returns>String con la descripción del tipo de empresa</returns>
        public string TraducirTipoEmpresa(int nCodigoTipoEmpresa)
        {
            string strDescripcion = "-";

            if (nCodigoTipoEmpresa != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_EMPRESA"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoEmpresa.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoEmpresa = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoEmpresa.Length > 0) ? drTipoEmpresa[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Indicador de Inscripción

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de inscripción
        /// </summary>
        /// <param name="nCodigoTipoInscripcion">Entero que posee el código del tipo de inscripción</param>
        /// <returns>String con la descripción del tipo de inscripción</returns>
        public string TraducirTipoInscripcion(int nCodigoTipoInscripcion)
        {
            string strDescripcion = "-";

            if (nCodigoTipoInscripcion != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_INSCRIPCION"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoInscripcion.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoInscripcion = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoInscripcion.Length > 0) ? drTipoInscripcion[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }

        #endregion

        #region Grados de Gravamen

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del grado de gravamen
        /// </summary>
        /// <param name="nCodigoGradoGravamen">Entero que posee el código del grado de gravamen</param>
        /// <returns>String con la descripción del grado de gravamen</returns>
        public string TraducirGradoGravamen(int nCodigoGradoGravamen)
        {
            string strDescripcion = "-";

            if (nCodigoGradoGravamen != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_GRADO_GRAVAMEN"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoGradoGravamen.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drGradoGravamen = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drGradoGravamen.Length > 0) ? drGradoGravamen[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Bien

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de bien
        /// </summary>
        /// <param name="nCodigoTipoBien">Entero que posee el código del tipo de bien</param>
        /// <returns>String con la descripción del tipo de bien</returns>
        public string TraducirTipoBien(int nCodigoTipoBien)
        {
            string strDescripcion = "-";

            if (nCodigoTipoBien != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_BIEN"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoBien.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoBien = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoBien.Length > 0) ? drTipoBien[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Líquidez

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de líquidez
        /// </summary>
        /// <param name="nCodigoTipoLiquidez">Entero que posee el código del tipo de líquidez</param>
        /// <returns>String con la descripción del tipo de líquidez</returns>
        public string TraducirTipoLiquidez(int nCodigoTipoLiquidez)
        {
            string strDescripcion = "-";

            if (nCodigoTipoLiquidez != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_LIQUIDEZ"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoLiquidez.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoLiquidez = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoLiquidez.Length > 0) ? drTipoLiquidez[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Tenencia

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de tenencia
        /// </summary>
        /// <param name="nCodigoTipoTenencia">Entero que posee el código del tipo de tenencia</param>
        /// <returns>String con la descripción del tipo de tenencia</returns>
        public string TraducirTipoTenencia(int nCodigoTipoTenencia)
        {
            string strDescripcion = "-";

            if (nCodigoTipoTenencia != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TENENCIA"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoTenencia.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoTenencia = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoTenencia.Length > 0) ? drTipoTenencia[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Recomendación de Peritos

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de recomendación de peritos
        /// </summary>
        /// <param name="nCodigoTipoRecomendacionPerito">Entero que posee el código del tipo de recomendación de peritos</param>
        /// <returns>String con la descripción del tipo de recomendación de peritos</returns>
        public string TraducirTipoRecomendacionPerito(int nCodigoTipoRecomendacionPerito)
        {
            string strDescripcion = "-";

            if (nCodigoTipoRecomendacionPerito != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_RECOMENDACION_PERITO"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoRecomendacionPerito.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoRecomendacionPerito = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoRecomendacionPerito.Length > 0) ? drTipoRecomendacionPerito[0][clsElemento._descripcionElemento].ToString() : "-");
            }
            
            return strDescripcion;
        }

        #endregion

        #region Tipos de Inspección de 3 Meses

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de inspección de 3 meses
        /// </summary>
        /// <param name="nCodigoTipoInspeccion3Meses">Entero que posee el código del tipo de inspección de 3 meses</param>
        /// <returns>String con la descripción del tipo de inspección de 3 meses</returns>
        public string TraducirTipoInspeccion3Meses(int nCodigoTipoInspeccion3Meses)
        {
            string strDescripcion = "-";

            if (nCodigoTipoInspeccion3Meses != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_INSPECCION_3_MESES"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoInspeccion3Meses.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoInspeccion3Meses = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoInspeccion3Meses.Length > 0) ? drTipoInspeccion3Meses[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }

        #endregion

        #region Tipos de Clasificación de Instrumentos

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de clasificación de instrumentos
        /// </summary>
        /// <param name="nCodigoTipoClasificacionInstrumento">Entero que posee el código del tipo de clasificación de instrumentos</param>
        /// <returns>String con la descripción del tipo de clasificación de instrumentos</returns>
        public string TraducirTipoClasificacionInstrumento(int nCodigoTipoClasificacionInstrumento)
        {
            string strDescripcion = "-";

            if (nCodigoTipoClasificacionInstrumento != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_CLASIFICACION_INSTRUMENTO"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoClasificacionInstrumento.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoClasificacionInstrumento = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoClasificacionInstrumento.Length > 0) ? drTipoClasificacionInstrumento[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }

        #endregion

        #region Tipos de Asignación

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de asignación
        /// </summary>
        /// <param name="nCodigoTipoAsignacion">Entero que posee el código del tipo de asignación</param>
        /// <returns>String con la descripción del tipo de asignación</returns>
        public string TraducirTipoAsignacion(int nCodigoTipoAsignacion)
        {
            string strDescripcion = "-";

            if (nCodigoTipoAsignacion != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_ASIGNACION"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoAsignacion.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoAsignacion = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoAsignacion.Length > 0) ? drTipoAsignacion[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Generador

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de generador
        /// </summary>
        /// <param name="nCodigoTipoGenerador">Entero que posee el código del tipo de generador</param>
        /// <returns>String con la descripción del tipo de generador</returns>
        public string TraducirTipoGenerador(int nCodigoTipoGenerador)
        {
            string strDescripcion = "-";

            if (nCodigoTipoGenerador != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_GENERADOR"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoGenerador.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoGenerador = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoGenerador.Length > 0) ? drTipoGenerador[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Vinculado a Entidad

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de vinculado a entidad
        /// </summary>
        /// <param name="nCodigoTipoVinculadoEntidad">Entero que posee el código del tipo de vinculado a entidad</param>
        /// <returns>String con la descripción del tipo de vinculado a entidad</returns>
        public string TraducirTipoVinculadoEntidad(int nCodigoTipoVinculadoEntidad)
        {
            string strDescripcion = "-";

            if (nCodigoTipoVinculadoEntidad != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_VINCULADO_ENTIDAD"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoVinculadoEntidad.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoVinculadoEntidad = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoVinculadoEntidad.Length > 0) ? drTipoVinculadoEntidad[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Garantía Real

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de garantía real
        /// </summary>
        /// <param name="nCodigoTipoGarantiaReal">Entero que posee el código del tipo de garantía real</param>
        /// <returns>String con la descripción del tipo de garantía real</returns>
        public string TraducirTipoGarantiaReal(int nCodigoTipoGarantiaReal)
        {
            string strDescripcion = "-";

            if (nCodigoTipoGarantiaReal != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_GARANTIA_REAL"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoGarantiaReal.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoGarantiaReal = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoGarantiaReal.Length > 0) ? drTipoGarantiaReal[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Tiene Capacidad

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de tiene capacidad
        /// </summary>
        /// <param name="nCodigoTipoTieneCapacidad">Entero que posee el código del tipo de tiene capacidad</param>
        /// <returns>String con la descripción del tipo de tiene capacidad</returns>
        public string TraducirTipoTieneCapacidad(int nCodigoTipoTieneCapacidad)
        {
            string strDescripcion = "-";

            if (nCodigoTipoTieneCapacidad != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIENE_CAPACIDAD"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoTieneCapacidad.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoTieneCapacidad = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoTieneCapacidad.Length > 0) ? drTipoTieneCapacidad[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Estado

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de estado
        /// </summary>
        /// <param name="nCodigoTipoEstado">Entero que posee el código del tipo de estado</param>
        /// <returns>String con la descripción del tipo de estado</returns>
        public string TraducirTipoEstado(int nCodigoTipoEstado)
        {
            string strDescripcion = "-";

            if (nCodigoTipoEstado != -1)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPOS_ESTADO"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, nCodigoTipoEstado.ToString()};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoEstado = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoEstado.Length > 0) ? drTipoEstado[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Catálogos

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de catálogo
        /// </summary>
        /// <param name="nCodigoTipoCatalogo">Entero que posee el código del tipo de catálogo</param>
        /// <returns>String con la descripción del tipo de catálogo</returns>
        public string TraducirTipoCatalogo(int nCodigoTipoCatalogo)
        {
            string strDescripcion = "-";

            if (nCodigoTipoCatalogo != -1)
            {
                DataTable dtCatalogos = new DataTable();

                listaCampos = new string[] {clsCatalogo._catCatalogo, clsCatalogo._catDescripcion,
                                            clsElemento._entidadElemento};

                sentenciaSql = string.Format("SELECT {0}, {1} FROM dbo.{2}", listaCampos);

                dtCatalogos = AccesoBD.ejecutarConsulta(sentenciaSql).Tables[0];

                listaCampos = new string[] {clsCatalogo._catCatalogo, nCodigoTipoCatalogo.ToString() };

                sentenciaSql = string.Format("{0} = {1}", listaCampos);

                DataRow[] drTipoCatalogo = dtCatalogos.Select(sentenciaSql);

                strDescripcion = ((drTipoCatalogo.Length > 0) ? drTipoCatalogo[0][clsCatalogo._catDescripcion].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Código del Instrumento

        /// <summary>
        /// Función que permite obtener la descripción del instrumento, según el código otorgado
        /// </summary>
        /// <param name="strCodigoInstrumento">String que posee el código del instrumento</param>
        /// <returns>String con la descripción del instrumento</returns>
        public string TraducirCodigoInstrumento(string strCodigoInstrumento)
        {
            string strCodigoInstrumentoObt = "-";

            DataTable dtInstrumentos = new DataTable();

            if (strCodigoInstrumento.Length > 0)
            {
                listaCampos = new string[] {clsInstrumento._descripcionInstrumento,
                                            clsInstrumento._entidadInstrumento,
                                            clsInstrumento._codigoInstrumento, strCodigoInstrumento};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = '{3}'", listaCampos);

                dtInstrumentos = AccesoBD.ejecutarConsulta(sentenciaSql).Tables[0];

                strCodigoInstrumentoObt = (((dtInstrumentos != null) && (dtInstrumentos.Rows.Count > 0) && (!dtInstrumentos.Rows[0].IsNull(clsInstrumento._descripcionInstrumento))) ? dtInstrumentos.Rows[0][clsInstrumento._descripcionInstrumento].ToString() : "-");
            }

            return strCodigoInstrumentoObt;
        }

        #endregion

        #region Tipos de Estado de Tarjeta

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de estado de la tarjeta
        /// </summary>
        /// <param name="strCodigoTipoEstado">String que posee el código del tipo de estado de la tarjeta</param>
        /// <returns>String con la descripción del tipo de estado de la tarjeta</returns>
        public string TraducirCodigoEstadoTarjeta(string strCodigoTipoEstado)
        {
            string strDescripcion = "-";

            if (strCodigoTipoEstado.Length > 0)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_ESTADO_TARJETA"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, strCodigoTipoEstado};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoEstado = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoEstado.Length > 0) ? drTipoEstado[0][clsElemento._descripcionElemento].ToString() : "-");
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Garantia de Tarjeta

        /// <summary>
        /// Función que retorna la descripción correspondiente al código del tipo de garantía de la tarjeta
        /// </summary>
        /// <param name="strCodigoTipoEstado">String que posee el código del tipo de garantía de la tarjeta</param>
        /// <returns>String con la descripción del tipo de garantía de la tarjeta</returns>
        public string TraducirCodigoTipoGarantiaTarjeta(string strCodigoTipoGarantia)
        {
            string strDescripcion = "-";

            if (strCodigoTipoGarantia.Length > 0)
            {
                if ((dtElementos == null) || ((dtElementos != null) && (dtElementos.Rows.Count == 0)))
                {
                    CargarDatos();
                }

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_GARANTIA_TARJETA"];

                listaCampos = new string[] {clsElemento._codigoCatalogo, strIndiceCatalogo,
                                            clsElemento._codigoCampo, (strCodigoTipoGarantia.PadLeft(2, '0'))};

                sentenciaSql = string.Format("{0} = {1} AND {2} = '{3}'", listaCampos);

                DataRow[] drTipoEstado = dtElementos.Select(sentenciaSql);

                strDescripcion = ((drTipoEstado.Length > 0) ? drTipoEstado[0][clsElemento._descripcionElemento].ToString() : TraducirTipoGarantia(Convert.ToInt32(strCodigoTipoGarantia)));
            }

            return strDescripcion;
        }
        #endregion

        #endregion
    }
}
