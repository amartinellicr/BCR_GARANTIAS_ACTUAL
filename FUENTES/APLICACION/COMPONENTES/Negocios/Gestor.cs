using System;
using System.Data;

using BCR.GARANTIAS.Entidades;
using BCR.GARANTIAS.Comun;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Gestor.
    /// </summary>
    public class Gestor
    {
        #region Validacion de clsUsuario
        public static bool ValidarUsuario(string strUsuario, string strPassword)
        {
            Seguridad oSeguridad = new Seguridad();
            return oSeguridad.ValidarUsuario(strUsuario, strPassword);
        }

        public static string ObtenerNombreUsuario(string strUsuario)
        {
            Seguridad oSeguridad = new Seguridad();
            return oSeguridad.ObtenerNombreUsuario(strUsuario);
        }

        public static bool IsInRol(string strUsuario, int nRol)
        {
            Seguridad oSeguridad = new Seguridad();
            return oSeguridad.IsInRol(strUsuario, nRol);
        }
        #endregion

        #region Mantenimiento de clsUsuario
        public static clsUsuario CrearUsuario(string strIdentificacion, string strNuevoUsuario, int nPerfil, string strUsuario, string strIP)
        {
            Usuarios oUsuario = new Usuarios();
            return oUsuario.Crear(strIdentificacion, strNuevoUsuario, nPerfil, strUsuario, strIP);
        }

        public static clsUsuario ModificarUsuario(string strIdentificacion, string strNuevoUsuario, int nPerfil, string strUsuario, string strIP)
        {
            Usuarios oUsuario = new Usuarios();
            return oUsuario.Modificar(strIdentificacion, strNuevoUsuario, nPerfil, strUsuario, strIP);
        }

        public static void EliminarUsuario(string strIdentificacion, string strUsuario, string strIP)
        {
            Usuarios oUsuario = new Usuarios();
            oUsuario.Eliminar(strIdentificacion, strUsuario, strIP);
        }

        public static bool UsuarioExiste(string strIdentificacion)
        {
            Usuarios oUsuario = new Usuarios();
            return oUsuario.UsuarioExiste(strIdentificacion);
        }
        #endregion

        #region Mantenimiento de Perfiles
        public static void CrearPerfil(string strPerfil, string strUsuario, string strIP)
        {
            Perfiles oPerfil = new Perfiles();
            oPerfil.Crear(strPerfil, strUsuario, strIP);
        }

        public static void ModificarPerfil(int nPerfil, string strPerfil, string strUsuario, string strIP)
        {
            Perfiles oPerfil = new Perfiles();
            oPerfil.Modificar(nPerfil, strPerfil, strUsuario, strIP);
        }

        public static void EliminarPerfil(int nPerfil, string strUsuario, string strIP)
        {
            Perfiles oPerfil = new Perfiles();
            oPerfil.Eliminar(nPerfil, strUsuario, strIP);
        }
        #endregion

        #region Mantenimiento de Roles por Perfil
        public static void CrearRolXPerfil(int nPerfil, int nRol, string strUsuario, string strIP)
        {
            RolesXPerfil oPerfil = new RolesXPerfil();
            oPerfil.Crear(nPerfil, nRol, strUsuario, strIP);
        }

        public static void EliminarRolXPerfil(int nPerfil, int nRol, string strUsuario, string strIP)
        {
            RolesXPerfil oPerfil = new RolesXPerfil();
            oPerfil.Eliminar(nPerfil, nRol, strUsuario, strIP);
        }
        #endregion

        #region Mantenimiento de Catalogos
        public static void CrearCampoCatalogo(int nCatalogo, string strCampo, string strDescripcion, string strUsuario, string strIP)
        {
            Catalogos oCatalogo = new Catalogos();
            oCatalogo.Crear(nCatalogo, strCampo, strDescripcion, strUsuario, strIP);
        }

        public static void ModificarCampoCatalogo(int nElemento, string strCampo, string strDescripcion, string strUsuario, string strIP)
        {
            Catalogos oCatalogo = new Catalogos();
            oCatalogo.Modificar(nElemento, strCampo, strDescripcion, strUsuario, strIP);
        }

        public static void EliminarCampoCatalogo(int nElemento, string strUsuario, string strIP)
        {
            Catalogos oCatalogo = new Catalogos();
            oCatalogo.Eliminar(nElemento, strUsuario, strIP);
        }

        /// <summary>
        /// Obtiene la lista de catálogos del mantenimiento de garantías reales
        /// </summary>
        /// <param name="listaCatalogos">Lista de los catálogos que se deben obtener. La lista debe iniciar y finalizar con el caracter "|", así mismo de requerirse más de un catálogo, los valores deben ir separados por dicho caracter.
        /// </param>
        /// <returns>Enditad del tipo catálogos</returns>
        public static clsCatalogos<clsCatalogo> ObtenerCatalogos(string listaCatalogos)
        {
            Catalogos oCatalogo = new Catalogos();
            return oCatalogo.ObtenerCatalogos(listaCatalogos);
        }

        /// <summary>
        /// Obtiene la lista de los códigos ISIN
        /// </summary>
        /// </param>
        /// <returns>DataSet con la lista de los códigos ISIN</returns>
        public static DataSet ObtenerCatalogoIsin()
        {
            Catalogos oCatalogo = new Catalogos();
            return oCatalogo.ObtenerCatalogoIsin();
        }

        /// <summary>
        /// Obtiene la lista de los instrumentos
        /// </summary>
        /// </param>
        /// <returns>DataSet con la información de los intrumentos</returns>
        public static DataSet ObtenerCatalogoInstrumentos()
        {
            Catalogos oCatalogo = new Catalogos();
            return oCatalogo.ObtenerCatalogoInstrumentos();
        }

        #endregion

            #region Mantenimiento de Deudores
        public static void ModificarDeudor(int nTipoPersona, string strCedula, string strNombre,
                                           int nCondicionEspecial, int nTipoAsignacion,
                                           int nGeneradorDivisas, int nVinculadoEntidad, string strUsuario, string strIP,
                                           int nTipoGarantia)
        {
            Deudores oDeudor = new Deudores();
            oDeudor.Modificar(nTipoPersona, strCedula, strNombre, nCondicionEspecial, nTipoAsignacion,
                             nGeneradorDivisas, nVinculadoEntidad, strUsuario, strIP, nTipoGarantia);
        }

        public static string ObtenerNombreDeudor(string strCedula)
        {
            Deudores oDeudor = new Deudores();
            return oDeudor.ObtenerNombreDeudor(strCedula);
        }
        #endregion

        #region Mantenimiento de Peritos
        public static void CrearPerito(string strCedula, string strNombre, int nTipoPersona,
                                       string strTelefono, string strEmail, string strDireccion,
                                       string strUsuario, string strIP)
        {
            Peritos oPerito = new Peritos();
            oPerito.Crear(strCedula, strNombre, nTipoPersona, strTelefono, strEmail, strDireccion, strUsuario, strIP);
        }

        public static void ModificarPerito(string strCedula, string strNombre, int nTipoPersona,
                                           string strTelefono, string strEmail, string strDireccion,
                                           string strUsuario, string strIP)
        {
            Peritos oPerito = new Peritos();
            oPerito.Modificar(strCedula, strNombre, nTipoPersona, strTelefono, strEmail, strDireccion, strUsuario, strIP);
        }

        public static void EliminarPerito(string strCedula, string strUsuario, string strIP)
        {
            Peritos oPerito = new Peritos();
            oPerito.Eliminar(strCedula, strUsuario, strIP);
        }
        #endregion

        #region Mantenimiento de Empresas
        public static void CrearEmpresa(string strCedula, string strNombre, string strTelefono,
                                        string strEmail, string strDireccion, string strUsuario, string strIP)
        {
            Empresas oEmpresa = new Empresas();
            oEmpresa.Crear(strCedula, strNombre, strTelefono, strEmail, strDireccion, strUsuario, strIP);
        }

        public static void ModificarEmpresa(string strCedula, string strNombre, string strTelefono,
                                            string strEmail, string strDireccion, string strUsuario, string strIP)
        {
            Empresas oEmpresa = new Empresas();
            oEmpresa.Modificar(strCedula, strNombre, strTelefono, strEmail, strDireccion, strUsuario, strIP);
        }

        public static void EliminarEmpresa(string strCedula, string strUsuario, string strIP)
        {
            Empresas oEmpresa = new Empresas();
            oEmpresa.Eliminar(strCedula, strUsuario, strIP);
        }
        #endregion

        #region Mantenimiento de Garantias Fiduciarias
        public static void CrearGarantiaFiduciaria(clsGarantiaFiduciaria entidadGarantiaFiduciaria, string direccionIP, string strOperacionCrediticia)
        {
            /*long nOperacion, int nTipoGarantia, int nClaseGarantia, string strCedulaFiador,
                                                    int nTipoFiador, string strNombreFiador, int nTipoMitigador, int nTipoDocumento,
                                                    decimal nMontoMitigador, decimal nPorcentajeResponsabilidad, int nOperacionEspecial,
                                                    int nTipoAcreedor, string strCedulaAcreedor, string strUsuario, string strIP,
                                                    string strOperacionCrediticia, decimal porcentajeAceptacion*/
            Garantias_Fiduciarias oGarantia = new Garantias_Fiduciarias();
            oGarantia.Crear(entidadGarantiaFiduciaria, direccionIP, strOperacionCrediticia);
        }

        public static void ModificarGarantiaFiduciaria(clsGarantiaFiduciaria entidadGarantiaFiduciaria, string strOperacionCrediticia, string direccionIP)
        {
            /*
            long nGarantiaFiduciaria, long nOperacion, string strCedulaFiador, int nTipoFiador,
                                                        string strNombreFiador, int nTipoMitigador, int nTipoDocumento, decimal nMontoMitigador,
                                                        decimal nPorcentajeResponsabilidad, int nOperacionEspecial, int nTipoAcreedor,
                                                        string strCedulaAcreedor, string strUsuario, string strIP,
                                                        string strOperacionCrediticia, decimal porcentajeAceptacion
            */
            Garantias_Fiduciarias oGarantia = new Garantias_Fiduciarias();
            oGarantia.Modificar(entidadGarantiaFiduciaria, strOperacionCrediticia, direccionIP);
        }

        /// <summary>
        /// Método que obtiene el listado de las garantías fiduciarias asociadas a una operación o contrato
        /// </summary>
        /// <param name="tipoOperacion">Tipo de operación</param>
        /// <param name="consecutivoOperacion">Consecutivo de la operación</param>
        /// <param name="codigoContabilidad">Código de la contabilidad</param>
        /// <param name="codigoOficina">Código de la oficina</param>
        /// <param name="codigoMoneda">Código de la moneda</param>
        /// <param name="codigoProducto">Código del producto</param>
        /// <param name="numeroOperacion">Número de la operación o contrato</param>
        /// <param name="cedulaUsuario">Identificación del usuario que realiza la consulta</param>
        /// <returns>Lista de garantías relacionadas</returns>
        public static DataSet ObtenerListaGarantiasFiduciarias(int tipoOperacion, long consecutivoOperacion, int codigoContabilidad, int codigoOficina, int codigoMoneda, int codigoProducto, long numeroOperacion, string cedulaUsuario)
        {
            Garantias_Fiduciarias oGarantia = new Garantias_Fiduciarias();
            return oGarantia.ObtenerListaGarantias(tipoOperacion, consecutivoOperacion, codigoContabilidad, codigoOficina, codigoMoneda, codigoProducto, numeroOperacion, cedulaUsuario);
        }

        public static void EliminarGarantiaFiduciaria(long nGarantiaFiduciaria, long nOperacion, string strUsuario, string strIP,
                                                      string strOperacionCrediticia)
        {
            Garantias_Fiduciarias oGarantia = new Garantias_Fiduciarias();
            oGarantia.Eliminar(nGarantiaFiduciaria, nOperacion, strUsuario, strIP, strOperacionCrediticia);
        }

        /// <summary>
        /// Verifica si la garantía fiduciaria existe
        /// </summary>
        /// <param name="codigoContabilidad">Código de la contabilidad</param>
        /// <param name="codigoOficina">Código de la oficina</param>
        /// <param name="codigoMoneda">Código de la moneda</param>
        /// <param name="codigoProducto">Código del producto</param>
        /// <param name="numeroOperacion">Número de la operación o contrato</param>
        /// <param name="tipoOperacion">Tipo de operación</param>
        /// <param name="cedulaFiador">Cédula del fiador</param>
        /// <param name="tipoPersonaFiador">Tipo de persona del fiador</param>
        /// <returns>True: La garantía existe. False: La garantía no existe</returns>
        public static bool ExisteGarantiaFiduciaria(string codigoContabilidad, string codigoOficina, string codigoMoneda, string codigoProducto, string numeroOperacion, int tipoOperacion, string cedulaFiador, string tipoPersona)
        {
            Garantias_Fiduciarias oGarantia = new Garantias_Fiduciarias();
            return oGarantia.ExisteGarantia(codigoContabilidad, codigoOficina, codigoMoneda, codigoProducto, numeroOperacion, tipoOperacion, cedulaFiador, tipoPersona);
        }

        #endregion

        #region Mantenimiento de Garantias Fiduciarias de Tarjetas

        public static int CrearGarantiaFiduciariaTarjeta(string strTarjeta, int nTipoGarantia, int nClaseGarantia,
                                                        string strCedulaFiador, int nTipoFiador, string strNombreFiador,
                                                        int nTipoMitigador, int nTipoDocumento, decimal nMontoMitigador,
                                                        decimal nPorcentajeResponsabilidad, int nOperacionEspecial,
                                                        int nTipoAcreedor, string strCedulaAcreedor,
                                                        DateTime dFechaExpiracion, decimal nMontoCobertura,
                                                        string strCedulaDeudor, long nBIN, long nCodigoInterno,
                                                        int nMoneda, int nOficinaRegistra,
                                                        string strUsuario, string strIP,
                                                        string strOperacionCrediticia,
                                                        string strObservacion, int nCodigoCatalogo, decimal porcentajeAceptacion)
        {
            Garantias_Fiduciarias_Tarjetas oGarantia = new Garantias_Fiduciarias_Tarjetas();

            return oGarantia.Crear(strTarjeta, nTipoGarantia, nClaseGarantia, strCedulaFiador, nTipoFiador,
                            strNombreFiador, nTipoMitigador, nTipoDocumento, nMontoMitigador, nPorcentajeResponsabilidad,
                            nOperacionEspecial, nTipoAcreedor, strCedulaAcreedor, dFechaExpiracion, nMontoCobertura,
                            strCedulaDeudor, nBIN, nCodigoInterno, nMoneda, nOficinaRegistra, strUsuario, strIP, strOperacionCrediticia,
                            strObservacion, nCodigoCatalogo, porcentajeAceptacion);
        }

        public static void ModificarGarantiaFiduciariaTarjeta(long nGarantiaFiduciaria, long nTarjeta, string strCedulaFiador, int nTipoFiador,
                                                        string strNombreFiador, int nTipoMitigador, int nTipoDocumento, decimal nMontoMitigador,
                                                        decimal nPorcentajeResponsabilidad, int nOperacionEspecial, int nTipoAcreedor,
                                                        string strCedulaAcreedor, DateTime dFechaExpiracion, decimal nMontoCobertura,
                                                        string strUsuario, string strIP,
                                                        string strOperacionCrediticia,
                                                        string strObservacion, decimal porcentajeAceptacion)
        {
            Garantias_Fiduciarias_Tarjetas oGarantia = new Garantias_Fiduciarias_Tarjetas();

            oGarantia.Modificar(nGarantiaFiduciaria, nTarjeta, strCedulaFiador, nTipoFiador,
                                strNombreFiador, nTipoMitigador, nTipoDocumento, nMontoMitigador, nPorcentajeResponsabilidad,
                                nOperacionEspecial, nTipoAcreedor, strCedulaAcreedor, dFechaExpiracion, nMontoCobertura,
                                strUsuario, strIP, strOperacionCrediticia, strObservacion, porcentajeAceptacion);
        }

        public static void EliminarGarantiaFiduciariaTarjeta(long nGarantiaFiduciaria, long nTarjeta, string strUsuario, string strIP,
                                                             string strOperacionCrediticia)
        {
            Garantias_Fiduciarias_Tarjetas oGarantia = new Garantias_Fiduciarias_Tarjetas();

            oGarantia.Eliminar(nGarantiaFiduciaria, nTarjeta, strUsuario, strIP, strOperacionCrediticia);
        }

        public static clsTarjeta ValidarTarjetaSISTAR(string numeroTarjeta)
        {
            Garantias_Fiduciarias_Tarjetas oGarantia = new Garantias_Fiduciarias_Tarjetas();

            return oGarantia.ValidarTarjetaSISTAR(numeroTarjeta);
        }

        public static bool ModificarGarantiaSISTAR(string numeroTarjeta, string garantiaTarjeta)
        {
            Garantias_Fiduciarias_Tarjetas oGarantia = new Garantias_Fiduciarias_Tarjetas();

            return oGarantia.ModificarGarantiaSISTAR(numeroTarjeta, garantiaTarjeta);
        }

        #endregion

        #region Mantenimiento de Garantias Giros
        public static void AsignarGarantias(long nGiro, long nContrato, string strUsuario, string strIP, string strOperacionCrediticia)
        {
            Garantias_Giros oGarantia = new Garantias_Giros();
            oGarantia.AsignarGarantias(nGiro, nContrato, strUsuario, strIP, strOperacionCrediticia);
        }
        #endregion

        #region Mantenimiento de Garantias Reales
        public static void CrearGarantiaReal(long nOperacion, int nTipoGarantia, int nClaseGarantia, int nTipoGarantiaReal,
                                            int nPartido, string strFinca, int nGrado, int nCedulaFiduciaria,
                                            string strClaseBien, string strNumPlaca, int nTipoBien,
                                            int nTipoMitigador, int nTipoDocumento, decimal nMontoMitigador, int nInscripcion,
                                            DateTime dFechaPresentacion, decimal nPorcentaje, int nGradoGravamen, int nOperacionEspecial,
                                            DateTime dFechaConstitucion, DateTime dFechaVencimiento, int nTipoAcreedor,
                                            string strCedulaAcreedor, int nLiquidez, int nTenencia, int nMoneda,
                                            DateTime dFechaPrescripcion, string strUsuario, string strIP,
                                            string strOperacionCrediticia, string strGarantia, decimal porcentajeAceptacion)
        {
            Garantias_Reales oGarantia = new Garantias_Reales();
            oGarantia.Crear(nOperacion, nTipoGarantia, nClaseGarantia, nTipoGarantiaReal, nPartido, strFinca, nGrado,
                            nCedulaFiduciaria, strClaseBien, strNumPlaca, nTipoBien, nTipoMitigador, nTipoDocumento,
                            nMontoMitigador, nInscripcion, dFechaPresentacion, nPorcentaje, nGradoGravamen, nOperacionEspecial,
                            dFechaConstitucion, dFechaVencimiento, nTipoAcreedor, strCedulaAcreedor, nLiquidez,
                            nTenencia, nMoneda, dFechaPrescripcion, strUsuario, strIP, strOperacionCrediticia, strGarantia, porcentajeAceptacion);
        }
         
        public static void ModificarGarantiaReal(clsGarantiaReal datosGarantiaReal, string strUsuario, string strIP,
                            string strOperacionCrediticia, string strGarantia)
        {
            Garantias_Reales oGarantia = new Garantias_Reales();
            oGarantia.Modificar(datosGarantiaReal, strUsuario, strIP, strOperacionCrediticia, strGarantia);
        }

        public static void EliminarGarantiaReal(long nOperacion, long nGarantia, string strUsuario, string strIP,
                                                string strOperacionCrediticia, string strGarantia)
        {
            Garantias_Reales oGarantia = new Garantias_Reales();
            oGarantia.Eliminar(nOperacion, nGarantia, strUsuario, strIP, strOperacionCrediticia, strGarantia);
        }

        /// <summary>
        /// Método que obtiene el listado de las garantías reales asociadas a una operación o contrato
        /// </summary>
        /// <param name="tipoOperacion">Tipo de operación</param>
        /// <param name="consecutivoOperacion">Consecutivo de la operación</param>
        /// <param name="codigoContabilidad">Código de la contabilidad</param>
        /// <param name="codigoOficina">Código de la oficina</param>
        /// <param name="codigoMoneda">Código de la moneda</param>
        /// <param name="codigoProducto">Código del producto</param>
        /// <param name="numeroOperacion">Número de la operación o contrato</param>
        /// <param name="cedulaUsuario">Identificación del usuario que realiza la consulta</param>
        /// <returns>Lista de garantías relacionadas</returns>
        public static DataSet ObtenerListaGarantiasReales(int tipoOperacion, long consecutivoOperacion, int codigoContabilidad, int codigoOficina, int codigoMoneda, int codigoProducto, long numeroOperacion, string cedulaUsuario)
        {
            Garantias_Reales oGarantia = new Garantias_Reales();
            return oGarantia.ObtenerListaGarantias(tipoOperacion, consecutivoOperacion, codigoContabilidad, codigoOficina, codigoMoneda, codigoProducto, numeroOperacion, cedulaUsuario);
        }

        /// <summary>
        /// Permite obtener la información de una garantía específica, así como las posibles inconsistencias que posea.
        /// </summary>
        /// <param name="idOperacion">Consecutivo de la operación de la cual se obtendrá la garantía</param>
        /// <param name="idGarantia">Consecutivo de la garantía de la cual se requiere la información</param>
        /// <param name="desOperacion">Número de operación, bajo el formato Contabilidad - Oficina - Moneda - Producto - Num Operación / Num. Contrato</param>
        /// <param name="desGarantia">Número de garantía, bajo el formato Partido - Finca / Clase - Placa</param>
        /// <param name="identificacionUsuario">Identificación del usuario que realiza la consulta</param>
        /// <returns>Entidad del tipo clsGarantiaReal, con los datos de la garantía consultada</returns>
        public static clsGarantiaReal ObtenerDatosGarantiaReal(long idOperacion, long idGarantia, string desOperacion, string desGarantia,
                                                               string identificacionUsuario, int annosCalculoPrescripcion)
        {
            Garantias_Reales oGarantia = new Garantias_Reales();
            return oGarantia.ObtenerDatosGarantiaReal(idOperacion, idGarantia, desOperacion, desGarantia, identificacionUsuario,
                                                      annosCalculoPrescripcion);
        }
                
        /// <summary>
        /// Obtiene la lista de valuadores del mantenimiento de garantías reales
        /// </summary>
        /// <param name="tipoValuador">Tipo de valuador del cual se obtendrán lo datos</param>
        /// <returns>Enditad del tipo valuadores</returns>
        public static clsValuadores<clsValuador> ObtenerValuadores(Enumeradores.TiposValuadores tipoValuador)
        {
            Garantias_Reales oGarantia = new Garantias_Reales();
            return oGarantia.ObtenerValuadores(tipoValuador);
        }

        /// <summary>
        /// Se encarga de ejecuta el proceso de normalización del avalúo a todos aquellos registros que sean de la misma finca o prenda.
        /// Siebel 1-24206841. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 24/03/2014.
        /// </summary>
        /// <param name="datosGarantiaReal">Contenedor de la información del a garantía y del avalúo</param>
        /// <param name="strUsuario">Usuario que realiza la acción</param>
        /// <param name="strIP">IP de la máquina desde donde se realzia el ajuste</param>
        /// <param name="strOperacionCrediticia">Código de la operación, bajo el formato oficina-moneda-producto-operación/contrato</param>
        /// <param name="strGarantia">Código del bien, bajo el formato Partido/Clase de bien – Finca/Placa)</param>
        public static void NormalizarDatosGarantiaReal(clsGarantiaReal datosGarantiaReal, string strUsuario, string strIP,
                              string strOperacionCrediticia, string strGarantia)
        {
            Garantias_Reales oGarantia = new Garantias_Reales();
            oGarantia.NormalizarDatosGarantiaReal(datosGarantiaReal, strUsuario, strIP, strOperacionCrediticia, strGarantia);
        }

        #endregion

        #region Mantenimiento de Garantias de Valor
        public static void CrearGarantiaValor(long nOperacion, int nTipoGarantia, int nClaseGarantia, string strSeguridad,
                                            DateTime dFechaConstitucion, DateTime dFechaVencimiento,
                                            int nClasificacion, string strInstrumento, string strSerie, int nTipoEmisor,
                                            string strEmisor, decimal nPremio, string strISIN, decimal nValorFacial,
                                            int nMonedaValorFacial, decimal nValorMercado, int nMonedaValorMercado,
                                            int nTenencia, DateTime dFechaPrescripcion, int nTipoMitigador, int nTipoDocumento,
                                            decimal nMontoMitigador, int nInscripcion, /*DateTime dFechaPresentacion, */
                                            decimal nPorcentaje, int nGradoGravamen, int nGradoPrioridades,
                                            decimal nMontoPrioridades, int nOperacionEspecial, int nTipoAcreedor,
                                            string strCedulaAcreedor, string strUsuario, string strIP,
                                            string strOperacionCrediticia, string strDescripcionInstrumento, decimal porcentajeAceptacion)
        {
            Garantias_Valores oGarantia = new Garantias_Valores();
            oGarantia.Crear(nOperacion, nTipoGarantia, nClaseGarantia, strSeguridad, dFechaConstitucion, dFechaVencimiento,
                            nClasificacion, strInstrumento, strSerie, nTipoEmisor, strEmisor, nPremio, strISIN,
                            nValorFacial, nMonedaValorFacial, nValorMercado, nMonedaValorMercado, nTenencia,
                            dFechaPrescripcion, nTipoMitigador, nTipoDocumento, nMontoMitigador, nInscripcion,
                /*dFechaPresentacion,*/ nPorcentaje, nGradoGravamen, nGradoPrioridades, nMontoPrioridades,
                            nOperacionEspecial, nTipoAcreedor, strCedulaAcreedor, strUsuario, strIP, strOperacionCrediticia,
                            strDescripcionInstrumento, porcentajeAceptacion);
        }

        public static void ModificarGarantiaValor(long nOperacion, long nGarantiaValor, int nTipoGarantia, int nClaseGarantia, string strSeguridad,
                                                DateTime dFechaConstitucion, DateTime dFechaVencimiento,
                                                int nClasificacion, string strInstrumento, string strSerie, int nTipoEmisor,
                                                string strEmisor, decimal nPremio, string strISIN, decimal nValorFacial,
                                                int nMonedaValorFacial, decimal nValorMercado, int nMonedaValorMercado,
                                                int nTenencia, DateTime dFechaPrescripcion, int nTipoMitigador, int nTipoDocumento,
                                                decimal nMontoMitigador, int nInscripcion, /*DateTime dFechaPresentacion, */
                                                decimal nPorcentaje, int nGradoGravamen, int nGradoPrioridades,
                                                decimal nMontoPrioridades, int nOperacionEspecial, int nTipoAcreedor,
                                                string strCedulaAcreedor, string strUsuario, string strIP,
                                                string strOperacionCrediticia, string strDescripcionInstrumento,
                                                string strDescInstNuevo, decimal porcentajeAceptacion)
        {
            Garantias_Valores oGarantia = new Garantias_Valores();
            oGarantia.Modificar(nOperacion, nGarantiaValor, nTipoGarantia, nClaseGarantia, strSeguridad, dFechaConstitucion, dFechaVencimiento,
                                nClasificacion, strInstrumento, strSerie, nTipoEmisor, strEmisor, nPremio, strISIN,
                                nValorFacial, nMonedaValorFacial, nValorMercado, nMonedaValorMercado, nTenencia,
                                dFechaPrescripcion, nTipoMitigador, nTipoDocumento, nMontoMitigador, nInscripcion,
                /*dFechaPresentacion,*/ nPorcentaje, nGradoGravamen, nGradoPrioridades, nMontoPrioridades,
                                nOperacionEspecial, nTipoAcreedor, strCedulaAcreedor, strUsuario, strIP, strOperacionCrediticia,
                                strDescripcionInstrumento, strDescInstNuevo, porcentajeAceptacion);
        }

        public static void EliminarGarantiaValor(long nOperacion, long nGarantia, string strUsuario, string strIP,
                                                 string strOperacionCrediticia)
        {
            Garantias_Valores oGarantia = new Garantias_Valores();
            oGarantia.Eliminar(nOperacion, nGarantia, strUsuario, strIP, strOperacionCrediticia);
        }


        public static clsGarantiaValor ObtenerDatosGarantiaValor(long nOperacion, long nGarantia, string strUsuario)
        {
            Garantias_Valores oGarantia = new Garantias_Valores();
            return oGarantia.ObtenerDatosGarantiaValor(nOperacion, nGarantia, strUsuario);
        }

        public static DataSet ObtenerListaGarantiasValor(int tipoOperacion, long consecutivoOperacion, int codigoContabilidad, int codigoOficina, int codigoMoneda, int codigoProducto, long numeroOperacion, string cedulaUsuario)
        {
            Garantias_Valores oGarantia = new Garantias_Valores();
            return oGarantia.ObtenerListaGarantias(tipoOperacion, consecutivoOperacion, codigoContabilidad, codigoOficina, codigoMoneda, codigoProducto, numeroOperacion, cedulaUsuario);
        }

        /// <summary>
        /// Verifica si la garantía valor existe
        /// </summary>
        /// <param name="codigoContabilidad">Código de la contabilidad</param>
        /// <param name="codigoOficina">Código de la oficina</param>
        /// <param name="codigoMoneda">Código de la moneda</param>
        /// <param name="codigoProducto">Código del producto</param>
        /// <param name="numeroOperacion">Número de la operación o contrato</param>
        /// <param name="tipoOperacion">Tipo de operación</param>
        /// <param name="numeroSeguridad">Número de seguridad</param>
        /// <returns>True: La garantía existe. False: La garantía no existe</returns>
        public static bool ExisteGarantiaValor(string codigoContabilidad, string codigoOficina, string codigoMoneda, string codigoProducto, string numeroOperacion, int tipoOperacion, string numeroSeguridad)
        {
            Garantias_Valores oGarantia = new Garantias_Valores();
            return oGarantia.ExisteGarantia(codigoContabilidad, codigoOficina, codigoMoneda, codigoProducto, numeroOperacion, tipoOperacion, numeroSeguridad);
        }

        #endregion

        #region Mantenimiento de Capacidades de Pago
        public static void CrearCapacidadPago(string strCedula, string dFecha, int nCapacidadPago, decimal nSensibilidad,
                                              string strUsuario, string strIP)
        {
            Capacidad_Pago oCapacidad = new Capacidad_Pago();
            oCapacidad.Crear(strCedula, dFecha, nCapacidadPago, nSensibilidad, strUsuario, strIP);
        }

        public static void ModificarCapacidadPago(string strCedula, DateTime dFecha, int nCapacidadPago, decimal nSensibilidad,
                                                  string strUsuario, string strIP)
        {
            Capacidad_Pago oCapacidad = new Capacidad_Pago();
            oCapacidad.Modificar(strCedula, dFecha, nCapacidadPago, nSensibilidad, strUsuario, strIP);
        }

        public static void EliminarCapacidadPago(string strCedula, string dFecha, string strUsuario, string strIP)
        {
            Capacidad_Pago oCapacidad = new Capacidad_Pago();
            oCapacidad.Eliminar(strCedula, dFecha, strUsuario, strIP);
        }
        #endregion

        #region Mantenimiento de Valuaciones de Fiadores
        public static void CrearValuacionFiador(int nGarantiaFiduciaria, string dFecha, decimal nIngresoNeto, int nTieneCapacidad, string strUsuario, string strIP)
        {
            Valuaciones_Fiador oValuacion = new Valuaciones_Fiador();
            oValuacion.Crear(nGarantiaFiduciaria, dFecha, nIngresoNeto, nTieneCapacidad, strUsuario, strIP);
        }

        public static void EliminarValuacionFiador(int nGarantiaFiduciaria, string dFecha, string strUsuario, string strIP)
        {
            Valuaciones_Fiador oValuacion = new Valuaciones_Fiador();
            oValuacion.Eliminar(nGarantiaFiduciaria, dFecha, strUsuario, strIP);
        }

        public static DataSet ObtenerValuacionesFiador(int nGarantiaFiduciaria)
        {
            Valuaciones_Fiador oValuacion = new Valuaciones_Fiador();
            return oValuacion.ObtenerValuaciones(nGarantiaFiduciaria);
        }

        public static bool ExisteFecha(int nGarantiaFiduciaria, string fechaValuacion)
        {
            Valuaciones_Fiador oValuacion = new Valuaciones_Fiador();
            return oValuacion.ExisteFecha(nGarantiaFiduciaria, fechaValuacion);
        }
        #endregion

        #region Mantenimiento de Valuaciones Reales

        public static clsValuacionesReales<clsValuacionReal> Obtener_Avaluos(long nGarantia, string codigoBien, bool obtenerMasReciente, int catalogoRP, int catalogoIMT)
        {
            Valuaciones_Reales oValuacion = new Valuaciones_Reales();
            return oValuacion.Obtener_Avaluos(nGarantia, codigoBien, obtenerMasReciente, catalogoRP, catalogoIMT);
        }

        /// <summary>
        /// Permite aplicar el proceso del cálculo del monto de la tasación actualizada del no terreno,esto para todos los avalúos más recientes
        /// </summary>
        /// <param name="strUsuario">Identificación del usuario que ejecuta el proceso</param>
        /// <param name="esServicioWindows">Indica si se ejecuta desde l servicio windows o no</param>
        /// <returns></returns>
        public static string AplicarCalculoMTANTAvaluos(string strUsuario, bool esServicioWindows)
        {
            Valuaciones_Reales oValuacion = new Valuaciones_Reales();
            return oValuacion.AplicarCalculoMTANTAvaluos(strUsuario, esServicioWindows);
        }

        /// <summary>
        /// Método que permite la inserción de los semestres calculados dentro de la tabla temporal de la base de datos
        /// </summary>
        /// <param name="tramaSemestres">Trama con los semestres calculados</param>
        /// <param name="strUsuario">Usuario que realizó el cálculo</param>
        /// <returns>La descripción del estado de la transacción final</returns>
        public static string InsertarSemetresCalculados(string tramaSemestres, string strUsuario)
        {
            Valuaciones_Reales oValuacion = new Valuaciones_Reales();
            return oValuacion.InsertarSemetresCalculados(tramaSemestres, strUsuario);
        }

        /// <summary>
        /// Método que permite la eliminación de los semestres calculados dentro de la tabla temporal de la base de datos
        /// </summary>
        /// <returns>La descripción del estado de la transacción final</returns>
        public static string EliminarSemetresCalculados()
        {
            Valuaciones_Reales oValuacion = new Valuaciones_Reales();
            return oValuacion.EliminarSemetresCalculados();
        }

        #endregion

        #region Archivos SEGUI
        public static void GenerarDeudoresTXT(string strRutaDestino, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarDeudoresTXT(strRutaDestino, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarDeudoresFCPTXT(string strRutaDestino, DataSet dsArchivoFuente)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarDeudoresFCPTXT(strRutaDestino, dsArchivoFuente);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarGarantiasFiduciariasTXT(string strRutaDestino, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarGarantiasFiduciariasTXT(strRutaDestino, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarGarantiasRealesTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarGarantiasRealesTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarGarantiasValorTXT(string strRutaDestino, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarGarantiasValorTXT(strRutaDestino, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarGarantiasFiduciariasInfoCompletaTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarGarantiasFiduciariasInfoCompletaTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarGarantiasRealesInfoCompletaTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarGarantiasRealesInfoCompletaTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarGarantiasValorInfoCompletaTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarGarantiasValorInfoCompletaTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarGarantiasFiduciariasContratosTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarGarantiasFiduciariasContratosTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarGarantiasRealesContratosTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarGarantiasRealesContratosTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarGarantiasValorContratosTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarGarantiasValorContratosTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarArchivoContratosTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarArchivoContratosTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        public static void GenerarArchivoGirosTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarArchivoGirosTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }
        #endregion

        #region Archivos de Inconsistencias

        /// <summary>
        /// Este método genera el archivo de inconsistencias del indicador de inscripción, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public static void GenerarErrorInscripcionTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarErrorInscripcionTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        /// <summary>
        /// Este método genera el archivo de inconsistencias del partido y la finca, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public static void GenerarErrorPartidoyFincaTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarErrorPartidoyFincaTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        /// <summary>
        /// Este método genera el archivo de inconsistencias del tipo de garantía real, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public static void GenerarErrorTipoGarantiaRealTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarErrorTipoGarantiaRealTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        /// <summary>
        /// Este método genera el archivo de inconsistencias de los avalúos, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public static void GenerarErrorValuacionesTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarErrorValuacionesTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        /// <summary>
        /// Este método genera el archivo de inconsistencias de la clase de garantía diferente entre registros de una misma finca o prenda, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public static void GenerarErrorClaseGarantiaRealTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarErrorClaseGarantiaRealTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        /// <summary>
        /// Este método genera el archivo de inconsistencias de las pólizas de las garantías reales, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public static void GenerarErrorPolizasGarantiaRealTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarErrorPolizasGarantiaRealTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        /// <summary>
        /// Este método genera el archivo de inconsistencias  al porcentaje de aceptacion calculado, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public static void GenerarErrorPorcentajeAceptacionRealTXT(string strRutaDestino, string strIDUsuario, bool bEsServicioWindows)
        {
            try
            {
                Archivos oFile = new Archivos();
                oFile.GenerarErrorPorcentajeAceptacionRealTXT(strRutaDestino, strIDUsuario, bEsServicioWindows);
            }
            catch
            {
                throw;
            }
        }

        #endregion Archivos de Inconsistencias

        #region Archivos de Alertas

        /// <summary>
        /// Este método genera el archivo de alertas del indicador de inscripción, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="strIDUsuario">Usuario que genera el archivo</param>
        /// <param name="codCatalogoIndIns">Código del catálogo del indicador de inscripción</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public static void GenerarAlertasInscripcionTXT(string strRutaDestino, string strIDUsuario, int codCatalogoIndIns, bool bEsServicioWindows)
        {
            Archivos oFile = new Archivos();
            oFile.GenerarAlertasInscripcionTXT(strRutaDestino, strIDUsuario, codCatalogoIndIns, bEsServicioWindows);
        }

        #endregion Archivos de Alertas

        #region Interfaz MQ - SICC
        public static string PRC18(string strReferencia, string strCanal, string strTrans, string strCodigoRespuesta,
                                    string strDescripcion, string strUsuario, string strOficinaOrigen, string strEstacion,
                                    string strFechaHora, string strIspec, string strFijo, string strProximo,
                                    string strAyuda, string strFecha, string strContabilidad, string strOficina,
                                    string strMoneda, string strProducto, string strOperacion, string strClase,
                                    string strNumero)
        {
            CGenerarXML oXML = new CGenerarXML();
            return oXML.PRC18(strReferencia, strCanal, strTrans, strCodigoRespuesta, strDescripcion, strUsuario,
                                strOficinaOrigen, strEstacion, strFechaHora, strIspec, strFijo, strProximo,
                                strAyuda, strFecha, strContabilidad, strOficina, strMoneda, strProducto,
                                strOperacion, strClase, strNumero);
        }
        #endregion

        #region Operaciones Crediticias
        public static long ObtenerConsecutivoOperacion(int nContabilidad, int nOficina, int nMoneda,
                                                        int nProducto, long nOperacion, string strDeudor)
        {
            Operaciones oOperacion = new Operaciones();
            return oOperacion.ObtenerConsecutivoOperacion(nContabilidad, nOficina, nMoneda, nProducto, nOperacion, strDeudor);
        }

        public static clsOperacionCrediticia ValidarOperacion(int nContabilidad, int nOficina, int nMoneda, int nProducto, long nOperacion)
        {
            Operaciones oOperacion = new Operaciones();
            return oOperacion.ValidarOperacion(nContabilidad, nOficina, nMoneda, nProducto, nOperacion);
        }
        #endregion

        #region Tarjetas
        public static int ActualizarEstadoTarjeta(string strNumeroTarjeta, string strEstadoTarjeta, int nTipoGarantia)
        {
            Tarjetas oTarjeta = new Tarjetas();

            return oTarjeta.ActualizarEstadoTarjeta(strNumeroTarjeta, strEstadoTarjeta, nTipoGarantia);
        }

        public static string ObtenerEstadoTarjeta(string strNumeroTarjeta)
        {
            Tarjetas oTarjeta = new Tarjetas();

            return oTarjeta.ObtenerEstadoTarjeta(strNumeroTarjeta);
        }

        public static bool Verifica_Tarjeta_Sistar(decimal nBin)
        {
            Tarjetas oTarjeta = new Tarjetas();

            return oTarjeta.Verifica_Tarjeta_Sistar(nBin);
        }

        public static bool CodigoTipoTarjetaEsPerfil(int nCodigoTipoGarantia)
        {
            Tarjetas oTarjeta = new Tarjetas();

            return oTarjeta.CodigoTipoTarjetaEsPerfil(nCodigoTipoGarantia);
        }
        #endregion

        #region Método AsignarGarantiaTarjeta: asigna la garantía a la tarjeta

        /// <summary>
        /// Asigna el tipo de garantía a la tarjeta en BCR - Garantías
        /// </summary>
        /// <param name="_numeroTarjeta">
        /// Número de tarjeta a la cual se asigna la nueva garantía
        /// </param>
        /// <param name="_codigoGarantiaNuevo">
        /// Código de la garantía que se está asignando a la tarjeta
        /// </param>
        /// <param name="strUsuario">
        /// Usuario que realizó la operación
        /// </param>
        /// <param name="strIP">
        /// Dirección IP de la máquina de donde se realizó la operación
        /// </param>
        /// <param name="_observaciones">
        /// Observaciones de la operación realizada
        /// </param>
        /// <param name="_codigoRespuesta">
        /// Codigo de confirmación enviado por sistar
        /// </param>
        /// <param name="_infoTarjeta">
        /// Información necesaria en caso de tener que ingresar la tarjeta en BCR - Garantías
        /// </param>
        /// <returns>
        /// Entero con el numero de mensaje retornado por la operación
        /// </returns>
        public static int AsignarGarantiaTarjeta(string _numeroTarjeta, string _codigoGarantiaNuevo,
            string strUsuario, string strIP, string _observaciones, string _codigoRespuesta, string[] _infoTarjeta)
        {
            Tarjetas tarjeta = new Tarjetas();

            return tarjeta.AsignarGarantiaTarjeta(_numeroTarjeta, _codigoGarantiaNuevo,
            strUsuario, strIP, _observaciones, _codigoRespuesta, _infoTarjeta);
        }/*fin del método AsignarGarantiaTarjeta*/

        #endregion Método AsignarGarantiaTarjeta: asigna la garantía a la tarjeta

        #region Mantenimiento de Bin de Tarjetas

        /// <summary>
        /// Método que permite insertar un nuevo bin 
        /// </summary>
        /// <param name="nBin">Entero con el número de bin</param>
        /// <param name="strUsuario">Código del usuario que realiza la operación</param>
        /// <param name="strIP">Dirección IP de la máquina donde se realiza la operación</param>
        /// <returns>Código obtenido del procedimiento almacenado</returns>
        public static int InsertarBinTarjeta(int nBin, string strUsuario, string strIP)
        {
            Bin_Tarjeta oBinTarjeta = new Bin_Tarjeta();

            return oBinTarjeta.Insertar_Bin_Tarjeta(nBin, strUsuario, strIP);
        }

        /// <summary>
        /// Método que permite eliminar un bin específico
        /// </summary>
        /// <param name="nBin">Entero con el número de bin</param>
        /// <param name="strUsuario">Código del usuario que realiza la operación</param>
        /// <param name="strIP">Dirección IP de la máquina donde se realiza la operación</param>
        /// <returns>Código obtenido del procedimiento almacenado</returns>
        public static int EliminarBinTarjeta(int nBin, string strUsuario, string strIP)
        {
            Bin_Tarjeta oBinTarjeta = new Bin_Tarjeta();

            return oBinTarjeta.Eliminar_Bin_Tarjeta(nBin, strUsuario, strIP);
        }

        /// <summary>
        /// Función que permite obtener los bines que existen en la BD
        /// </summary>
        /// <returns>Tabla con los bines almacenados en la BD</returns>
        public static DataSet ObtenerListaBin()
        {
            Bin_Tarjeta oBinTarjeta = new Bin_Tarjeta();

            return oBinTarjeta.ObtenerListaBin();
        }
        #endregion

        #region Indices de Actualización de Avalúos

        /// <summary>
        /// Inserta un registro de los índices de actualización de avalúos 
        /// </summary>
        /// <param name="entidadIndicePreciosConsumidor">Entidad del tipo índices de actualización de avalúos que posee los datos a insertar</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public static void InsertarIndiceActualizacionAvaluo(clsIndiceActualizacionAvaluo entidadIndicePreciosConsumidor, string usuario, string ip)
        {
            IndicesActualizacionAvaluos entidadIndicesActualizacionAvaluos = new IndicesActualizacionAvaluos();

            entidadIndicesActualizacionAvaluos.Crear(entidadIndicePreciosConsumidor, usuario, ip);
        }

        /// <summary>
        /// Obtiene el historial de índices de actualización de avalúos o el último registro ingresado
        /// </summary>
        /// <param name="tipoConculta">Indica si se obtiene el más reciente (0) o se obtiene el histórico (1) o se obtiene la lista de años registrados (2).</param>
        /// <param name="anno">Año del que se requieren los registros</param>
        /// <param name="mes">Mes del que se requieren los registros</param>
        /// <returns>Enditad del tipo índice de actualización de avalúos</returns>
        public static clsIndicesActualizacionAvaluos<clsIndiceActualizacionAvaluo> ObtenerIndicesActualizacionAvaluos(int tipoConculta, int anno, int mes)
        {
            IndicesActualizacionAvaluos entidadIndicesActualizacionAvaluos = new IndicesActualizacionAvaluos();

            return entidadIndicesActualizacionAvaluos.ObtenerIndicesActualizacionAvaluos(tipoConculta, anno, mes);
        }

        #endregion Indices de Actualización de Avalúos

        #region Archivo Respaldo del Cálculo MTAT y MTANT

        /// <summary>
        /// Este método genera el archivo de los registros generados por el proceso del cálculo del monto de la tasación actualziada del terreno y no terreno, en formato TXT
        /// </summary>
        /// <param name="strRutaDestino">Dirección de la carpeta en donde se almacenará el archivo</param>
        /// <param name="bEsServicioWindows">Indicador que determina si la solicitud proviene desde la aplicaión web (false) o del servicio
        /// windows de generación autmática de archivos (true)</param>
        public static void GenerarRespaldoRegistrosCalculadosTXT(string strRutaDestino, bool bEsServicioWindows)
        {
            Archivos oFile = new Archivos();
            oFile.GenerarRespaldoRegistrosCalculadosTXT(strRutaDestino, bEsServicioWindows);
        }

        #endregion Archivo Respaldo del Cálculo MTAT y MTANT

        #region Procesos de Réplica

        /// <summary>
        /// Realiza la consulta a nivel dde base de datos del resultado de la ejecución de los procesos de réplica
        /// </summary>
        /// <param name="fechaInicial">Fecha desde la cual se desea obtener la información</param>
        /// <param name="fechaFinal">Fecha hasta la cual se desea obtener la información</param>
        /// <param name="codigoProceso">Código del proceso del que se desea obtener datos</param>
        /// <param name="indicadorResultado">Indicador del resultado obtenido dusrante la ejecución</param>
        /// <returns>Lista del detalle del resultado de la ejecución del proceso</returns>
        public static clsEjecucionProcesos<clsEjecucionProceso> Obtener_Resultado_Ejecucion_Proceso(DateTime fechaInicial, DateTime fechaFinal, string codigoProceso, string indicadorResultado)
        {
            EjeccucionProcesos procesosReplica = new EjeccucionProcesos();

            return procesosReplica.Obtener_Resultado_Ejecucion_Proceso(fechaInicial, fechaFinal, codigoProceso, indicadorResultado);
        }

        #endregion Procesos de Réplica

        #region Bitacora
        public static DataSet ObtenerDatosCambioGarantia(string strOperacionCredicitia, string strGarantia)
        {
            Bitacora oBitacora = new Bitacora();
            return oBitacora.ObtenerDatosCambioGarantia(strOperacionCredicitia, strGarantia);
        }

        public static string GenerarInformacionCambiosGarantiasTXT(string strRutaDestino, int accion, DateTime fechaInicio, DateTime fechaFin)
        {
            Archivos oFile = new Archivos();
            return oFile.GenerarInformacionCambiosGarantiasTXT(strRutaDestino, accion, fechaInicio, fechaFin);
        }

        public static string GenerarInformacionCambiosGarantiasTXT(string strRutaDestino, string strGarantia)
        {
            Archivos oFile = new Archivos();
            return oFile.GenerarInformacionCambiosGarantiasTXT(strRutaDestino, strGarantia);
        }



        #endregion

        #region Tipos de Pólizas SUGEF

        /// <summary>
        /// Inserta un registro del tipo de póliza SUGEF
        /// </summary>
        /// <param name="codigoTipoPolizaSugef">Código del tipo de póliza SUGEF.</param>
        /// <param name="nombreTiopPolizaSugef">Nombre del tipo de póliza SUGEF.</param>
        /// <param name="descripcionTiopPolizaSugef">Descripción del tipo de póliza SUGEF.</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public static void CrearTipoPolizaSugef(int codigoTipoPolizaSugef, string nombreTiopPolizaSugef, string descripcionTiopPolizaSugef, string usuario, string ip)
        {
            TiposPolizasSugef tipoPolizaSugef = new TiposPolizasSugef();
            tipoPolizaSugef.Crear(codigoTipoPolizaSugef, nombreTiopPolizaSugef, descripcionTiopPolizaSugef, usuario, ip);
        }

        /// <summary>
        /// Modifica un registro del tipo de póliza SUGEF
        /// </summary>
        /// <param name="entidadTipoPolizaSugef">Entidad del tipo de póliza SUGEF que posee los datos a modificar</param>
        /// <param name="entidadTipoPolizaSugefAnterior">Entidad del tipo de póliza SUGEF que posee los datos originales</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public static void ModificarTipoPolizaSugef(clsTipoPolizaSugef entidadTipoPolizaSugef, clsTipoPolizaSugef entidadTipoPolizaSugefAnterior, string usuario, string ip)
        {
            TiposPolizasSugef tipoPolizaSugef = new TiposPolizasSugef();
            tipoPolizaSugef.Modificar(entidadTipoPolizaSugef, entidadTipoPolizaSugefAnterior, usuario, ip);
        }

        /// <summary>
        /// Elimina un registro del tipo de póliza SUGEF
        /// </summary>
        /// <param name="entidadTipoPolizaSugef">Entidad del tipo de póliza SUGEF que posee los datos a modificar</param>
        /// <param name="usuario">Usuario que elimina el registro</param>
        /// <param name="ip">Dirección desde donde se elimina el registro</param>
        public static void EliminarTipoPolizaSugef(clsTipoPolizaSugef entidadTipoPolizaSugef, string usuario, string ip)
        {
            TiposPolizasSugef tipoPolizaSugef = new TiposPolizasSugef();
            tipoPolizaSugef.Eliminar(entidadTipoPolizaSugef, usuario, ip);
        }

        /// <summary>
        /// Obtiene la lista de tipos de pólizas SUGEF
        /// </summary>
        /// <param name="tipoPolizaSugef">Código del tipo de póliza SUGEF del cual se requiere la información, el dato puede ser nulo.</param>
        /// <param name="indicadorRegistroBlanco">Indicador que determina si se requiere la opción en blanco, donde True: Se obtiene, False: No se obtiene.</param>
        /// <param name="consecutivoSiguiente">Obtiene el siguiente consecutivo a insertar.</param>
        /// <returns>Enditad del tipo índice de actualización de avalúos</returns>
        public static clsTiposPolizasSugef<clsTipoPolizaSugef> ObtenerTiposPolizasSugef(int? tipoPolizaSugef, bool indicadorRegistroBlanco, out int consecutivoSiguiente)
        {
            TiposPolizasSugef polizaSugef = new TiposPolizasSugef();
            return polizaSugef.ObtenerTiposPolizasSugef(tipoPolizaSugef, indicadorRegistroBlanco, out consecutivoSiguiente);
        }

        #endregion Tipos de Pólizas SUGEF

        #region Tipos de Bien Relacionados a Tipos de Pólizas

        /// <summary>
        /// Inserta un registro del tipo de bien asociado a un tipo de póliza SAP y un tipo de póliza SUGEF
        /// </summary>
        /// <param name="entidadTipoBienRelacionado">Entidad del tipo de bien relacionado que posee los datos a insertar</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        /// <param name="catalogoTipoBien">Código del cátologo del tipo de bien</param>
        /// <param name="catalogoTipoPolizaSap">Código del catálogo del tipo de póliza SAP</param>
        public static void CrearTipoBienRelacionado(clsTipoBienRelacionado entidadTipoBienRelacionado, string usuario, string ip, string catalogoTipoBien, string catalogoTipoPolizaSap)
        {
            TiposBienRelacionados tiposBienRelacionados = new TiposBienRelacionados();
            tiposBienRelacionados.Crear(entidadTipoBienRelacionado, usuario, ip, catalogoTipoBien, catalogoTipoPolizaSap);
        }

        /// <summary>
        /// Modifica un registro del tipo de bien asociado a un tipo de póliza SAP y un tipo de póliza SUGEF
        /// </summary>
        /// <param name="entidadTipoBienRelacionado">Entidad del tipo de bien relacionado que posee los datos a modificar</param>
        /// <param name="entidadTipoBienRelacionadoAnterior">Entidad del tipo de bien relacionado que posee los datos originales</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        /// <param name="catalogoTipoBien">Código del cátologo del tipo de bien</param>
        /// <param name="catalogoTipoPolizaSap">Código del catálogo del tipo de póliza SAP</param>
        public static void ModificarTipoBienRelacionado(clsTipoBienRelacionado entidadTipoBienRelacionado, clsTipoBienRelacionado entidadTipoBienRelacionadoAnterior, string usuario, string ip, string catalogoTipoBien, string catalogoTipoPolizaSap)
        {
            TiposBienRelacionados tiposBienRelacionados = new TiposBienRelacionados();
            tiposBienRelacionados.Modificar(entidadTipoBienRelacionado, entidadTipoBienRelacionadoAnterior, usuario, ip, catalogoTipoBien, catalogoTipoPolizaSap);
        }

        /// <summary>
        /// Elimina un registro del tipo de bien asociado a un tipo de póliza SAP y un tipo de póliza SUGEF
        /// </summary>
        /// <param name="entidadTipoBienRelacionado">Entidad del tipo de bien relacionado que posee los datos a eliminar</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public static void EliminarTipoBienRelacionado(clsTipoBienRelacionado entidadTipoBienRelacionado, string usuario, string ip)
        {
            TiposBienRelacionados tiposBienRelacionados = new TiposBienRelacionados();
            tiposBienRelacionados.Eliminar(entidadTipoBienRelacionado, usuario, ip);
        }

        /// <summary>
        /// Obtiene la lista de relaciones existentes entre el tipo de bien y los tipos de pólizas
        /// </summary>
        /// <param name="tipoBien">Código del tipo de bien del cual se requieren las relaciones, el dato puede ser nulo.</param>
        /// <param name="tipoPolizaSap">Código del tipo de póliza SAP del cual se requieren las relaciones, el dato puede ser nulo.</param>
        /// <param name="tipoPolizaSugef">Código del tipo de póliza SUGEF del cual se requieren las relaciones, el dato puede ser nulo.</param>
        /// <returns>Enditad del tipo índice de actualización de avalúos</returns>
        public static clsTiposBienRelacionados<clsTipoBienRelacionado> ObtenerTiposBienRelacionados(int? tipoBien, int? tipoPolizaSap, int? tipoPolizaSugef, string catalogoTipoBien, string catalogoTipoPolizaSap)
        {
            TiposBienRelacionados tiposBienRelacionados = new TiposBienRelacionados();
            return tiposBienRelacionados.ObtenerTiposBienRelacionados(tipoBien, tipoPolizaSap, tipoPolizaSugef, catalogoTipoBien, catalogoTipoPolizaSap);
        }

        #endregion Tipos de Bien Relacionados a Tipos de Pólizas

        #region Porcentaje de Aceptacion

        /// <summary>
        /// Inserta un registro de porcentaje de aceptacion
        /// </summary>
        /// <param name="codigoTipoGarantia">Código del tipo de garantia .</param>
        /// <param name="codigoTipoMitigador">Código del tio de mitigador de riesgo.</param>
        /// <param name="indicadorSinCalificacion">Indicador si 0: No Aplica Calificacion 1:Sin Calificacion.</param>
        /// <param name="porcentajeAceptacion">Porcentaje Aceptacion.</param>
        /// <param name="porcentajeCeroTres">Porcentaje  0-3.</param>
        /// <param name="porcentajeCuatro">Porcentaje  4.</param>
        /// <param name="porcentajeCinco">Porcentaje  5.</param>
        /// <param name="porcentajeSeis">Porcentaje  6.</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public static void InsertarPorcentajeAceptacion(clsPorcentajeAceptacion entidadPorcentajeAceptacion, string usuario, string ip)
        {
            PorcentajeAceptacion ePorcentajeAceptacion = new PorcentajeAceptacion();
            ePorcentajeAceptacion.Insertar(entidadPorcentajeAceptacion,usuario, ip);
        }

        /// <summary>
        /// Modifica un registro del tipo porcentaje de aceptacion 
        /// </summary>
        /// <param name="entidadPorcentajeAceptacion">Entidad del tipo de porcentaje de aceptacion que posee los datos a modificar</param>
        /// <param name="entidadPorcentajeAceptacionAnterior">Entidad del tipo de porcentaje de aceptacion que posee los datos originales</param>
        /// <param name="usuario">Usuario que inserta el registro</param>
        /// <param name="ip">Dirección desde donde se ingresa el registro</param>
        public static void ModificarPorcentajeAceptacion(clsPorcentajeAceptacion entidadPorcentajeAceptacion, clsPorcentajeAceptacion entidadPorcentajeAceptacionAnterior, string usuario, string ip)
        {
            PorcentajeAceptacion ePorcentajeAceptacion = new PorcentajeAceptacion();
            ePorcentajeAceptacion.Modificar(entidadPorcentajeAceptacion, entidadPorcentajeAceptacionAnterior, usuario, ip);
        }

        /// <summary>
        /// Elimina un registro del tipo de porcentaje de aceptacion
        /// </summary>
        /// <param name="entidadPorcentajeAceptacion">Entidad del tipo de porcentaje de aceptacion que posee los datos a eliminar</param>
        /// <param name="usuario">Usuario que elimina el registro</param>
        /// <param name="ip">Dirección desde donde se elimina el registro</param>
        public static void EliminarPorcentajeAceptacion(clsPorcentajeAceptacion entidadPorcentajeAceptacion, string usuario, string ip)
        {
            PorcentajeAceptacion ePorcentajeAceptacion = new PorcentajeAceptacion();
            ePorcentajeAceptacion.Eliminar(entidadPorcentajeAceptacion, usuario, ip);
        }

        /// <summary>
        /// Obtiene el porcentaje de aceptacion,
        /// </summary>
        /// <param name="codigoPorcentajeAceptacion">Consecutivo del registro, si es null jala todos los registros</param>
        ///   <param name="codigoTipoGarantia">Consecutivo catalogo tipo de garantia</param>
        /// <param name="codigoTipoMitigador">Consecutivo catalogo tipo de mitigador</param>
        ///  <param name="accion">Consulta a realizar: --1.Consecutivo 2.Tipo Garantia 3. Tipo de Mitigador 4. Tipo Garantia y Tipo Mitigador</param>
        /// <returns>Enditad del tipo Porcentaje de aceptacion</returns>
        public static DataSet ObtenerDatosPorcentajeAceptacion(int? codigoPorcentajeAceptacion, int? codigoTipoGarantia, int? codigoTipoMitigador, int accion)
        {
            PorcentajeAceptacion ePorcentajeAceptacion = new PorcentajeAceptacion();
            return ePorcentajeAceptacion.ObtenerDatosPorcentajeAceptacion(codigoPorcentajeAceptacion,codigoTipoGarantia,codigoTipoMitigador,accion );
        }

        public static Decimal ObtenerValorPorcentajeAceptacion(int? codigoPorcentajeAceptacion, int? codigoTipoGarantia, int? codigoTipoMitigador, int accion)
        {
            PorcentajeAceptacion ePorcentajeAceptacion = new PorcentajeAceptacion();
            return ePorcentajeAceptacion.ObtenerValorPorcentajeAceptacion(codigoPorcentajeAceptacion, codigoTipoGarantia, codigoTipoMitigador, accion);
        }

        #endregion

        #region Historico Porcentaje de Aceptacion

        public static DataSet ObtenerDatosHistoricoPorcentajeAceptacion(clsHistoricoPorcentajeAceptacion eHistoricoPorcentajeAceptacion, DateTime fechaInicio, DateTime fechaFinal)
        {
            HistoricoPorcentajeAceptacion oHistorico = new HistoricoPorcentajeAceptacion();
            return oHistorico.ObtenerDatosHistorico(eHistoricoPorcentajeAceptacion, fechaInicio, fechaFinal);
        }

        #endregion
    }
}
