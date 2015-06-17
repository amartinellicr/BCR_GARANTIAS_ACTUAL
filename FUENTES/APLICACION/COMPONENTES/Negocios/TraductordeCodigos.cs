using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Configuration;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;
using System.Collections;

namespace BCRGARANTIAS.Negocios
{
    public class TraductordeCodigos
    {
        #region Variables Globales

        //DataSet dsCatalogos = new DataSet();
        DataTable dtElementos = new DataTable();
        //DataTable dtInstrumentos = new DataTable();

        #endregion

        #region M�todos P�blicos Especiales

        #region Obtener la C�dula del Fiador, a partir del c�digo de garant�a fiduciaria

        /// <summary>
        /// Funci�n que se encarga de obtener la c�dula del fiador seg�n un c�digo de garant�a fiduciaria espec�fico
        /// </summary>
        /// <param name="strCodigoGarFidu">String que posee el c�digo de la garant�a fiduciaria</param>
        /// <returns>String con el n�mero de c�duladel fiador</returns>
        public string ObtenerCedulaFiadorGarFidu(string strCodigoGarFidu)
        {
            string strCedulaFiador = "[" + strCodigoGarFidu + "]";

            try
            {
                if (strCodigoGarFidu != string.Empty)
                {
                    DataSet dsGarantFiduc = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_fiduciaria.CEDULA_FIADOR +
                        " from GAR_GARANTIA_FIDUCIARIA" +
                        " where " + ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA + " = " + strCodigoGarFidu);

                    if ((dsGarantFiduc != null) && (dsGarantFiduc.Tables.Count > 0) && (dsGarantFiduc.Tables[0].Rows.Count > 0))
                    {
                        if (!dsGarantFiduc.Tables[0].Rows[0].IsNull(ContenedorGarantia_fiduciaria.CEDULA_FIADOR))
                        {
                            strCedulaFiador = dsGarantFiduc.Tables[0].Rows[0][ContenedorGarantia_fiduciaria.CEDULA_FIADOR].ToString();
                        }
                    }
                }
            }
            catch
            {
                throw;
            }

            return strCedulaFiador;
        }

        #endregion

        #region Obtener la C�dula del Deudor, apartir del c�digo de operaci�n crediticia

        /// <summary>
        /// Funci�n que se encarga de obtener la c�dula del deudor de una operaci�n crediticia espec�fica
        /// </summary>
        /// <param name="strCodigoOperacionCrediticia">String que posee el c�digo de operaci�n crediticia</param>
        /// <returns>String que posee la c�dula del deudor</returns>
        public string ObtenerCedulaDeudor(string strCodigoOperacionCrediticia)
        {
            string strCedulaDeudor = "[" + strCodigoOperacionCrediticia + "]";

            try
            {
                if (strCodigoOperacionCrediticia != string.Empty)
                {
                    DataSet dsOperaciones = AccesoBD.ejecutarConsulta("select " + ContenedorOperacion.CEDULA_DEUDOR +
                        " from " + ContenedorOperacion.NOMBRE_ENTIDAD +
                        " where " + ContenedorOperacion.COD_OPERACION + " = " + strCodigoOperacionCrediticia);

                    if ((dsOperaciones != null) && (dsOperaciones.Tables.Count > 0) && (dsOperaciones.Tables[0].Rows.Count > 0))
                    {
                        if (!dsOperaciones.Tables[0].Rows[0].IsNull(ContenedorOperacion.CEDULA_DEUDOR))
                        {
                            strCedulaDeudor = dsOperaciones.Tables[0].Rows[0][ContenedorOperacion.CEDULA_DEUDOR].ToString();
                        }
                    }
                }
            }
            catch
            {
				throw;
            }

            return strCedulaDeudor;
        }
        #endregion

        #region Obtener la C�dula del Fiador y del Deudor de una Tarjeta

        /// <summary>
        /// Funci�n que se encarga de obtener la c�dula del fiador seg�n un c�digo de garant�a fiduciaria espec�fico
        /// </summary>
        /// <param name="strCodigoGarFiduTar">String que posee el c�digo de la garant�a fiduciaria</param>
        /// <returns>String con el n�mero de c�dula del fiador</returns>
        public string ObtenerCedulaFiadorGarFiduTar(string strCodigoGarFiduTar)
        {
            string strCedulaFiadorTar = "[" + strCodigoGarFiduTar + "]";

            try
            {
                if (strCodigoGarFiduTar != string.Empty)
                {
                    DataSet dsGarantFiduc = AccesoBD.ejecutarConsulta("select " + ContenedorGarantia_fiduciaria.CEDULA_FIADOR +
                        " from TAR_GARANTIA_FIDUCIARIA" +
                        " where " + ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA + " = " + strCodigoGarFiduTar);

                    if ((dsGarantFiduc != null) && (dsGarantFiduc.Tables.Count > 0) && (dsGarantFiduc.Tables[0].Rows.Count > 0))
                    {
                        if (!dsGarantFiduc.Tables[0].Rows[0].IsNull(ContenedorGarantia_fiduciaria.CEDULA_FIADOR))
                        {
                            strCedulaFiadorTar = dsGarantFiduc.Tables[0].Rows[0][ContenedorGarantia_fiduciaria.CEDULA_FIADOR].ToString();
                        }
                    }
                }
            }
            catch
            {
                throw;
            }

            return strCedulaFiadorTar;
        }

        /// <summary>
        /// Funci�n que retorna la c�duladel deudor de una tarjeta espec�fica
        /// </summary>
        /// <param name="strNumeroTarjeta">String que posee el n�mero de la tarje</param>
        /// <returns>String que posee la c�dula del deudor de la tarjeta</returns>
        public string ObtenerCedulaDeudorTarjeta(string strNumeroTarjeta)
        {
            string strCedulaDeudorTar = "[" + strNumeroTarjeta + "]";

            try
            {
                if (strNumeroTarjeta != string.Empty)
                {
                    DataSet dsTarjeta = AccesoBD.ejecutarConsulta("select " + ContenedorTarjeta.CEDULA_DEUDOR +
                        " from " + ContenedorTarjeta.NOMBRE_ENTIDAD +
                        " where " + ContenedorTarjeta.COD_TARJETA + " = " + strNumeroTarjeta);

                    if ((dsTarjeta != null) && (dsTarjeta.Tables.Count > 0) && (dsTarjeta.Tables[0].Rows.Count > 0))
                    {
                        if (!dsTarjeta.Tables[0].Rows[0].IsNull(ContenedorTarjeta.CEDULA_DEUDOR))
                        {
                            strCedulaDeudorTar = dsTarjeta.Tables[0].Rows[0][ContenedorTarjeta.CEDULA_DEUDOR].ToString();
                        }
                    }
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

        #region M�todos P�blicos

        #region Carga de datos en tablas globales

        /// <summary>
        /// M�todo que se encarga de cargar los datos en las diferente tablas globlales utilizadas
        /// </summary>
        private void CargarDatos()
        {
            //dsCatalogos = AccesoBD.ejecutarConsulta("select " + ContenedorCatalogo.CAT_CATALOGO + "," +
            //    ContenedorCatalogo.CAT_DESCRIPCION +
            //    " from " + ContenedorCatalogo.NOMBRE_ENTIDAD);

            dtElementos = AccesoBD.ejecutarConsulta("select " + ContenedorElemento.CAT_CAMPO + "," +
                ContenedorElemento.CAT_CATALOGO + "," + ContenedorElemento.CAT_DESCRIPCION + "," +
                ContenedorElemento.CAT_ELEMENTO +
                " from " + ContenedorElemento.NOMBRE_ENTIDAD).Tables[0];

            //dtInstrumentos = AccesoBD.ejecutarConsulta("select " + ContenedorInstrumentos.COD_INSTRUMENTO + "," +
            //    ContenedorInstrumentos.DES_INSTRUMENTO +
            //    " from " + ContenedorInstrumentos.NOMBRE_ENTIDAD).Tables[0];
        }

        #endregion

        #region Clase de Garant�as

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo de la clase de garant�a
        /// </summary>
        /// <param name="nCodigoClaseGarantia">Entero que posee el c�digo de la clase de garant�a</param>
        /// <returns>String con la descripci�n de la clase de garant�a</returns>
        public string TraducirClaseGarantia(int nCodigoClaseGarantia)
        {
            string strDescripcion = "-";

            if (nCodigoClaseGarantia != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_CLASE_GARANTIA"];

                DataRow[] drClaseGarantia = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoClaseGarantia.ToString() + "'");

                if (drClaseGarantia.Length > 0)
                {
                    strDescripcion = drClaseGarantia[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }
            return strDescripcion;
        }
        #endregion

        #region Tipos de Garant�as

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de garant�a
        /// </summary>
        /// <param name="nCodigoTipoGarantia">Entero que posee el c�digo del tipo de garant�a</param>
        /// <returns>String con la descripci�n del tipo de garant�a</returns>
        public string TraducirTipoGarantia(int nCodigoTipoGarantia)
        {
            string strDescripcion = "-";

            if (nCodigoTipoGarantia != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_GARANTIA"];

                DataRow[] drTipoGarantia = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoGarantia.ToString() + "'");

                if (drTipoGarantia.Length > 0)
                {
                    strDescripcion = drTipoGarantia[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Persona

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de persona
        /// </summary>
        /// <param name="nCodigoTipoFiador">Entero que posee el c�digo del tipo de persona</param>
        /// <returns>String con la descripci�n del tipo de persona</returns>
        public string TraducirTipoPersona(int nCodigoTipoPersona)
        {
            string strDescripcion = "-";

            if (nCodigoTipoPersona != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_PERSONA"];

                DataRow[] drTipoPersona = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoPersona.ToString() + "'");

                if (drTipoPersona.Length > 0)
                {
                    strDescripcion = drTipoPersona[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Mitigador

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de mitigador
        /// </summary>
        /// <param name="nCodigoTipoMitigador">Entero que posee el c�digo del tipo de mitigador</param>
        /// <returns>String con la descripci�n del tipo de mitigador</returns>
        public string TraducirTipoMitigador(int nCodigoTipoMitigador)
        {
            string strDescripcion = "-";

            if (nCodigoTipoMitigador != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_MITIGADOR"];

                DataRow[] drTipoMitigador = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoMitigador.ToString() + "'");

                if (drTipoMitigador.Length > 0)
                {
                    strDescripcion = drTipoMitigador[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Documento

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de documento
        /// </summary>
        /// <param name="nCodigoTipoDocumento">Entero que posee el c�digo del tipo de documento</param>
        /// <returns>String con la descripci�n del tipo de documento</returns>
        public string TraducirTipoDocumento(int nCodigoTipoDocumento)
        {
            string strDescripcion = "-";

            if (nCodigoTipoDocumento != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPOS_DOCUMENTOS"];

                DataRow[] drTipoDocumento = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoDocumento.ToString() + "'");

                if (drTipoDocumento.Length > 0)
                {
                    strDescripcion = drTipoDocumento[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Operaci�n Especial

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de operaci�n especial
        /// </summary>
        /// <param name="nCodigoTipoOperacionEspecial">Entero que posee el c�digo del tipo de operaci�n especial</param>
        /// <returns>String con la descripci�n del tipo de operaci�n especial</returns>
        public string TraducirTipoOperacionEspecial(int nCodigoTipoOperacionEspecial)
        {
            string strDescripcion = "-";

            if (nCodigoTipoOperacionEspecial != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_OPERACION_ESPECIAL"];

                DataRow[] drTipoOperacionEspecial = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoOperacionEspecial.ToString() + "'");

                if (drTipoOperacionEspecial.Length > 0)
                {
                    strDescripcion = drTipoOperacionEspecial[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Moneda

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de moneda
        /// </summary>
        /// <param name="nCodigoTipoMoneda">Entero que posee el c�digo del tipo de moneda</param>
        /// <returns>String con la descripci�n del tipo de moneda</returns>
        public string TraducirTipoMoneda(int nCodigoTipoMoneda)
        {
            string strDescripcion = "-";

            if (nCodigoTipoMoneda != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_MONEDA"];

                DataRow[] drTipoMoneda = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoMoneda.ToString() + "'");

                if (drTipoMoneda.Length > 0)
                {
                    strDescripcion = drTipoMoneda[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Capacidad de Pago

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de capacidad de pago
        /// </summary>
        /// <param name="nCodigoTipoCapacidadPago">Entero que posee el c�digo del tipo de capacidad de pago</param>
        /// <returns>String con la descripci�n del tipo de capacidad de pago</returns>
        public string TraducirTipoCapacidadPago(int nCodigoTipoCapacidadPago)
        {
            string strDescripcion = "-";

            if (nCodigoTipoCapacidadPago != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_CAPACIDAD_PAGO"];

                DataRow[] drTipoCapacidadPago = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoCapacidadPago.ToString() + "'");

                if (drTipoCapacidadPago.Length > 0)
                {
                    strDescripcion = drTipoCapacidadPago[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Condici�n Especial

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de condici�n especial
        /// </summary>
        /// <param name="nCodigoTipoCondicionEspecial">Entero que posee el c�digo del tipo de condici�n especial</param>
        /// <returns>String con la descripci�n del tipo de condici�n especial</returns>
        public string TraducirTipoCondicionEspecial(int nCodigoTipoCondicionEspecial)
        {
            string strDescripcion = "-";

            if (nCodigoTipoCondicionEspecial != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_CONDICION_ESPECIAL"];

                DataRow[] drTipoCondicionEspecial = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoCondicionEspecial.ToString() + "'");

                if (drTipoCondicionEspecial.Length > 0)
                {
                    strDescripcion = drTipoCondicionEspecial[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region C�digo de Empresa

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo de empresa
        /// </summary>
        /// <param name="nCodigoEmpresa">Entero que posee el c�digo de empresa</param>
        /// <returns>String con la descripci�n de empresa</returns>
        public string TraducirCodigoEmpresa(int nCodigoEmpresa)
        {
            string strDescripcion = "-";

            if (nCodigoEmpresa != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_CODIGO_EMPRESA"];

                DataRow[] drCodigoEmpresa = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoEmpresa.ToString() + "'");

                if (drCodigoEmpresa.Length > 0)
                {
                    strDescripcion = drCodigoEmpresa[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Empresa

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de empresa
        /// </summary>
        /// <param name="nCodigoTipoEmpresa">Entero que posee el c�digo del tipo de empresa</param>
        /// <returns>String con la descripci�n del tipo de empresa</returns>
        public string TraducirTipoEmpresa(int nCodigoTipoEmpresa)
        {
            string strDescripcion = "-";

            if (nCodigoTipoEmpresa != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_EMPRESA"];

                DataRow[] drTipoEmpresa = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoEmpresa.ToString() + "'");

                if (drTipoEmpresa.Length > 0)
                {
                    strDescripcion = drTipoEmpresa[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Indicador de Inscripci�n

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de inscripci�n
        /// </summary>
        /// <param name="nCodigoTipoInscripcion">Entero que posee el c�digo del tipo de inscripci�n</param>
        /// <returns>String con la descripci�n del tipo de inscripci�n</returns>
        public string TraducirTipoInscripcion(int nCodigoTipoInscripcion)
        {
            string strDescripcion = "-";

            if (nCodigoTipoInscripcion != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_INSCRIPCION"];

                DataRow[] drTipoInscripcion = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoInscripcion.ToString() + "'");

                if (drTipoInscripcion.Length > 0)
                {
                    strDescripcion = drTipoInscripcion[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }

        #endregion

        #region Grados de Gravamen

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del grado de gravamen
        /// </summary>
        /// <param name="nCodigoGradoGravamen">Entero que posee el c�digo del grado de gravamen</param>
        /// <returns>String con la descripci�n del grado de gravamen</returns>
        public string TraducirGradoGravamen(int nCodigoGradoGravamen)
        {
            string strDescripcion = "-";

            if (nCodigoGradoGravamen != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_GRADO_GRAVAMEN"];

                DataRow[] drGradoGravamen = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoGradoGravamen.ToString() + "'");

                if (drGradoGravamen.Length > 0)
                {
                    strDescripcion = drGradoGravamen[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Bien

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de bien
        /// </summary>
        /// <param name="nCodigoTipoBien">Entero que posee el c�digo del tipo de bien</param>
        /// <returns>String con la descripci�n del tipo de bien</returns>
        public string TraducirTipoBien(int nCodigoTipoBien)
        {
            string strDescripcion = "-";

            if (nCodigoTipoBien != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_BIEN"];

                DataRow[] drTipoBien = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoBien.ToString() + "'");

                if (drTipoBien.Length > 0)
                {
                    strDescripcion = drTipoBien[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de L�quidez

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de l�quidez
        /// </summary>
        /// <param name="nCodigoTipoLiquidez">Entero que posee el c�digo del tipo de l�quidez</param>
        /// <returns>String con la descripci�n del tipo de l�quidez</returns>
        public string TraducirTipoLiquidez(int nCodigoTipoLiquidez)
        {
            string strDescripcion = "-";

            if (nCodigoTipoLiquidez != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_LIQUIDEZ"];

                DataRow[] drTipoLiquidez = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoLiquidez.ToString() + "'");

                if (drTipoLiquidez.Length > 0)
                {
                    strDescripcion = drTipoLiquidez[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Tenencia

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de tenencia
        /// </summary>
        /// <param name="nCodigoTipoTenencia">Entero que posee el c�digo del tipo de tenencia</param>
        /// <returns>String con la descripci�n del tipo de tenencia</returns>
        public string TraducirTipoTenencia(int nCodigoTipoTenencia)
        {
            string strDescripcion = "-";

            if (nCodigoTipoTenencia != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TENENCIA"];

                DataRow[] drTipoTenencia = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoTenencia.ToString() + "'");

                if (drTipoTenencia.Length > 0)
                {
                    strDescripcion = drTipoTenencia[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Recomendaci�n de Peritos

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de recomendaci�n de peritos
        /// </summary>
        /// <param name="nCodigoTipoRecomendacionPerito">Entero que posee el c�digo del tipo de recomendaci�n de peritos</param>
        /// <returns>String con la descripci�n del tipo de recomendaci�n de peritos</returns>
        public string TraducirTipoRecomendacionPerito(int nCodigoTipoRecomendacionPerito)
        {
            string strDescripcion = "-";

            if (nCodigoTipoRecomendacionPerito != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_RECOMENDACION_PERITO"];

                DataRow[] drTipoRecomendacionPerito = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoRecomendacionPerito.ToString() + "'");

                if (drTipoRecomendacionPerito.Length > 0)
                {
                    strDescripcion = drTipoRecomendacionPerito[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }
            
            return strDescripcion;
        }

        #endregion

        #region Tipos de Inspecci�n de 3 Meses

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de inspecci�n de 3 meses
        /// </summary>
        /// <param name="nCodigoTipoInspeccion3Meses">Entero que posee el c�digo del tipo de inspecci�n de 3 meses</param>
        /// <returns>String con la descripci�n del tipo de inspecci�n de 3 meses</returns>
        public string TraducirTipoInspeccion3Meses(int nCodigoTipoInspeccion3Meses)
        {
            string strDescripcion = "-";

            if (nCodigoTipoInspeccion3Meses != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_INSPECCION_3_MESES"];

                DataRow[] drTipoInspeccion3Meses = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoInspeccion3Meses.ToString() + "'");

                if (drTipoInspeccion3Meses.Length > 0)
                {
                    strDescripcion = drTipoInspeccion3Meses[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }

        #endregion

        #region Tipos de Clasificaci�n de Instrumentos

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de clasificaci�n de instrumentos
        /// </summary>
        /// <param name="nCodigoTipoClasificacionInstrumento">Entero que posee el c�digo del tipo de clasificaci�n de instrumentos</param>
        /// <returns>String con la descripci�n del tipo de clasificaci�n de instrumentos</returns>
        public string TraducirTipoClasificacionInstrumento(int nCodigoTipoClasificacionInstrumento)
        {
            string strDescripcion = "-";

            if (nCodigoTipoClasificacionInstrumento != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_CLASIFICACION_INSTRUMENTO"];

                DataRow[] drTipoClasificacionInstrumento = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoClasificacionInstrumento.ToString() + "'");

                if (drTipoClasificacionInstrumento.Length > 0)
                {
                    strDescripcion = drTipoClasificacionInstrumento[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }

        #endregion

        #region Tipos de Asignaci�n

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de asignaci�n
        /// </summary>
        /// <param name="nCodigoTipoAsignacion">Entero que posee el c�digo del tipo de asignaci�n</param>
        /// <returns>String con la descripci�n del tipo de asignaci�n</returns>
        public string TraducirTipoAsignacion(int nCodigoTipoAsignacion)
        {
            string strDescripcion = "-";

            if (nCodigoTipoAsignacion != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_ASIGNACION"];

                DataRow[] drTipoAsignacion = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoAsignacion.ToString() + "'");

                if (drTipoAsignacion.Length > 0)
                {
                    strDescripcion = drTipoAsignacion[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Generador

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de generador
        /// </summary>
        /// <param name="nCodigoTipoGenerador">Entero que posee el c�digo del tipo de generador</param>
        /// <returns>String con la descripci�n del tipo de generador</returns>
        public string TraducirTipoGenerador(int nCodigoTipoGenerador)
        {
            string strDescripcion = "-";

            if (nCodigoTipoGenerador != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_GENERADOR"];

                DataRow[] drTipoGenerador = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoGenerador.ToString() + "'");

                if (drTipoGenerador.Length > 0)
                {
                    strDescripcion = drTipoGenerador[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Vinculado a Entidad

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de vinculado a entidad
        /// </summary>
        /// <param name="nCodigoTipoVinculadoEntidad">Entero que posee el c�digo del tipo de vinculado a entidad</param>
        /// <returns>String con la descripci�n del tipo de vinculado a entidad</returns>
        public string TraducirTipoVinculadoEntidad(int nCodigoTipoVinculadoEntidad)
        {
            string strDescripcion = "-";

            if (nCodigoTipoVinculadoEntidad != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_VINCULADO_ENTIDAD"];

                DataRow[] drTipoVinculadoEntidad = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoVinculadoEntidad.ToString() + "'");

                if (drTipoVinculadoEntidad.Length > 0)
                {
                    strDescripcion = drTipoVinculadoEntidad[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Garant�a Real

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de garant�a real
        /// </summary>
        /// <param name="nCodigoTipoGarantiaReal">Entero que posee el c�digo del tipo de garant�a real</param>
        /// <returns>String con la descripci�n del tipo de garant�a real</returns>
        public string TraducirTipoGarantiaReal(int nCodigoTipoGarantiaReal)
        {
            string strDescripcion = "-";

            if (nCodigoTipoGarantiaReal != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_GARANTIA_REAL"];

                DataRow[] drTipoGarantiaReal = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoGarantiaReal.ToString() + "'");

                if (drTipoGarantiaReal.Length > 0)
                {
                    strDescripcion = drTipoGarantiaReal[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Tiene Capacidad

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de tiene capacidad
        /// </summary>
        /// <param name="nCodigoTipoTieneCapacidad">Entero que posee el c�digo del tipo de tiene capacidad</param>
        /// <returns>String con la descripci�n del tipo de tiene capacidad</returns>
        public string TraducirTipoTieneCapacidad(int nCodigoTipoTieneCapacidad)
        {
            string strDescripcion = "-";

            if (nCodigoTipoTieneCapacidad != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIENE_CAPACIDAD"];

                DataRow[] drTipoTieneCapacidad = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoTieneCapacidad.ToString() + "'");

                if (drTipoTieneCapacidad.Length > 0)
                {
                    strDescripcion = drTipoTieneCapacidad[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Estado

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de estado
        /// </summary>
        /// <param name="nCodigoTipoEstado">Entero que posee el c�digo del tipo de estado</param>
        /// <returns>String con la descripci�n del tipo de estado</returns>
        public string TraducirTipoEstado(int nCodigoTipoEstado)
        {
            string strDescripcion = "-";

            if (nCodigoTipoEstado != -1)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPOS_ESTADO"];

                DataRow[] drTipoEstado = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + nCodigoTipoEstado.ToString() + "'");

                if (drTipoEstado.Length > 0)
                {
                    strDescripcion = drTipoEstado[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Cat�logos

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de cat�logo
        /// </summary>
        /// <param name="nCodigoTipoCatalogo">Entero que posee el c�digo del tipo de cat�logo</param>
        /// <returns>String con la descripci�n del tipo de cat�logo</returns>
        public string TraducirTipoCatalogo(int nCodigoTipoCatalogo)
        {
            string strDescripcion = "-";

            if (nCodigoTipoCatalogo != -1)
            {
                DataTable dtCatalogos = new DataTable();

                dtCatalogos = AccesoBD.ejecutarConsulta("select " + ContenedorCatalogo.CAT_CATALOGO + "," +
                    ContenedorCatalogo.CAT_DESCRIPCION +
                    " from " + ContenedorCatalogo.NOMBRE_ENTIDAD).Tables[0];

                DataRow[] drTipoCatalogo = dtCatalogos.Select(ContenedorCatalogo.CAT_CATALOGO + " = " + nCodigoTipoCatalogo.ToString());

                if (drTipoCatalogo.Length > 0)
                {
                    strDescripcion = drTipoCatalogo[0][ContenedorCatalogo.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region C�digo del Instrumento

        /// <summary>
        /// Funci�n que permite obtener la descripci�n del instrumento, seg�n el c�digo otorgado
        /// </summary>
        /// <param name="strCodigoInstrumento">String que posee el c�digo del instrumento</param>
        /// <returns>String con la descripci�n del instrumento</returns>
        public string TraducirCodigoInstrumento(string strCodigoInstrumento)
        {
            string strCodigoInstrumentoObt = "-";

            if (strCodigoInstrumento != string.Empty)
            {
                DataTable dtInstrumentos = new DataTable();

                if (strCodigoInstrumento != string.Empty)
                {
                    dtInstrumentos = AccesoBD.ejecutarConsulta("select " + ContenedorInstrumentos.DES_INSTRUMENTO +
                           " from " + ContenedorInstrumentos.NOMBRE_ENTIDAD +
                           " where " + ContenedorInstrumentos.COD_INSTRUMENTO + " = '" + strCodigoInstrumento + "'").Tables[0];

                    if ((dtInstrumentos != null) && (dtInstrumentos.Rows.Count > 0) 
                       && (!dtInstrumentos.Rows[0].IsNull(ContenedorInstrumentos.DES_INSTRUMENTO)))
                    {
                        strCodigoInstrumentoObt = dtInstrumentos.Rows[0][ContenedorInstrumentos.DES_INSTRUMENTO].ToString();
                    }
                }
            }

            return strCodigoInstrumentoObt;
        }

        #endregion

        #region Tipos de Estado de Tarjeta

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de estado de la tarjeta
        /// </summary>
        /// <param name="strCodigoTipoEstado">String que posee el c�digo del tipo de estado de la tarjeta</param>
        /// <returns>String con la descripci�n del tipo de estado de la tarjeta</returns>
        public string TraducirCodigoEstadoTarjeta(string strCodigoTipoEstado)
        {
            string strDescripcion = "-";

            if (strCodigoTipoEstado != string.Empty)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_ESTADO_TARJETA"];

                DataRow[] drTipoEstado = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + strCodigoTipoEstado + "'");

                if (drTipoEstado.Length > 0)
                {
                    strDescripcion = drTipoEstado[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
            }

            return strDescripcion;
        }
        #endregion

        #region Tipos de Garantia de Tarjeta

        /// <summary>
        /// Funci�n que retorna la descripci�n correspondiente al c�digo del tipo de garant�a de la tarjeta
        /// </summary>
        /// <param name="strCodigoTipoEstado">String que posee el c�digo del tipo de garant�a de la tarjeta</param>
        /// <returns>String con la descripci�n del tipo de garant�a de la tarjeta</returns>
        public string TraducirCodigoTipoGarantiaTarjeta(string strCodigoTipoGarantia)
        {
            string strDescripcion = "-";

            if (strCodigoTipoGarantia != string.Empty)
            {
                CargarDatos();

                string strIndiceCatalogo = ConfigurationManager.AppSettings["CAT_TIPO_GARANTIA_TARJETA"];

                DataRow[] drTipoEstado = dtElementos.Select(ContenedorElemento.CAT_CATALOGO + " = " + strIndiceCatalogo
                    + " and " + ContenedorElemento.CAT_CAMPO + " = '" + (strCodigoTipoGarantia.PadLeft(2, '0')) + "'");

                if (drTipoEstado.Length > 0)
                {
                    strDescripcion = drTipoEstado[0][ContenedorElemento.CAT_DESCRIPCION].ToString();
                }
                else
                {
                    strDescripcion = TraducirTipoGarantia(Convert.ToInt32(strCodigoTipoGarantia));
                }
            }

            return strDescripcion;
        }
        #endregion

        #endregion
    }
}
