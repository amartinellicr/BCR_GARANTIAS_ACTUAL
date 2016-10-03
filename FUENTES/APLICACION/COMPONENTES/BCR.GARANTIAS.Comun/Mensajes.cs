using System;
using System.Collections.Specialized;

namespace BCR.GARANTIAS.Comun
{
	/// <summary>
	/// Clase mediante la cual se obtienen los mensajes genéricos del sistema
	/// Creado por Rodrigo Zumbado Moreira
	/// </summary>
	public class Mensajes
	{
		#region Constantes
        public const string ASSEMBLY                    = "BCR.GARANTIAS.Comun.dll";
		protected const string ARCHIVO_RECURSOS         = "Mensajes";
		protected const string ERROR_OBTENIENDO_MENSAJE = "Error obteniendo mensaje";
		private const string PRIMER_PARAMETRO           = "@1";
		private const string SEGUNDO_PARAMETRO          = "@2";

        /// <summary>
        /// Códigos de error del proceso de generación de archivos SEGUI
        /// </summary>
        public const string CODIGO_ERROR_ARCHIVO_SEGUI_VACIO                = "CODIGO_1";
        public const string CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI              = "CODIGO_2";
        public const string CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI    = "CODIGO_3";
        public const string CODIGO_ERROR_GENERAL_GENERANDO_ARCHIVOS_SEGUI   = "CODIGO_4";
        public const string CODIGO_GENERACION_CORRECTA_ARCHIVOS_SEGUI       = "CODIGO_5";
     

        #endregion

		#region Constantes para accesar los mensajes
		public const string ERROR_CAMPOS_ORDENAR                                    = "ERROR_CAMPOS_ORDENAR";
		public const string ERROR_LLAVE_REPETIDA                                    = "ERROR_LLAVE_REPETIDA";
		public const string ERROR_REGISTRO_TIENE_HIJOS                              = "ERROR_REGISTRO_TIENE_HIJOS";
		public const string ERROR_CAMPOS_AGRUPAR                                    = "ERROR_CAMPOS_AGRUPAR";
		public const string ERROR_ASSEMBLY_MAPEO                                    = "ERROR_ASSEMBLY_MAPEO";
		public const string ERROR_MAPEO_NO_ENCONTRADO                               = "ERROR_MAPEO_NO_ENCONTRADO";
		public const string ERROR_INSERTANDO                                        = "ERROR_INSERTANDO";
		public const string ERROR_ELIMINANDO                                        = "ERROR_ELIMINANDO";
		public const string ERROR_MODIFICANDO                                       = "ERROR_MODIFICANDO";
		public const string ERROR_OBTENIENDO                                        = "ERROR_OBTENIENDO";
		public const string ERROR_CAMPO_NO_NULO                                     = "ERROR_CAMPO_NO_NULO";
		public const string ERROR_FABRICA_DAL                                       = "ERROR_FABRICA_DAL";
		public const string ERROR_DETERMINANDO_BASEDATOS                            = "ERROR_DETERMINANDO_BASEDATOS";
		public const string ERROR_CONFIGURACION_CONEXION                            = "ERROR_CONFIGURACION_CONEXION";
		public const string ERROR_ACCESANDO_RECURSOS                                = "ERROR_ACCESANDO_RECURSOS";

        public const string ERROR_MODIFICANDO_DEUDOR                                = "ERROR_MODIFICANDO_DEUDOR";
        public const string ERROR_MODIFICANDO_DEUDOR_DETALLE                        = "ERROR_MODIFICANDO_DEUDOR_DETALLE";
        public const string ERROR_INSERTANDO_CAPACIDAD_DE_PAGO                      = "ERROR_INSERTANDO_CAPACIDAD_DE_PAGO";
        public const string ERROR_INSERTANDO_CAPACIDAD_DE_PAGO_DETALLE              = "ERROR_INSERTANDO_CAPACIDAD_DE_PAGO_DETALLE";
        public const string ERROR_ELIMINANDO_CAPACIDAD_DE_PAGO                      = "ERROR_ELIMINANDO_CAPACIDAD_DE_PAGO";
        public const string ERROR_ELIMINANDO_CAPACIDAD_DE_PAGO_DETALLE              = "ERROR_ELIMINANDO_CAPACIDAD_DE_PAGO_DETALLE";

        public const string ERROR_OBTENIENDO_DATOS_DEUDOR                           = "ERROR_OBTENIENDO_DATOS_DEUDOR";
        public const string ERROR_FALTAN_PARAMETROS                                 = "ERROR_FALTAN_PARAMETROS";
        public const string ERROR_OBTENIENDO_DATOS_DEUDOR_DETALLE                   = "ERROR_OBTENIENDO_DATOS_DEUDOR_DETALLE";

        public const string ERROR_OBTENIENDO_INCONSISTENCIAS                        = "ERROR_OBTENIENDO_INCONSISTENCIAS";
        public const string ERROR_OBTENIENDO_INCONSISTENCIAS_DETALLE                = "ERROR_OBTENIENDO_INCONSISTENCIAS_DETALLE";
        public const string ERROR_OBTENIENDO_DATOS_ARCHIVO_CONFIGURACION_DETALLE    = "ERROR_OBTENIENDO_DATOS_ARCHIVO_CONFIGURACION_DETALLE";
        public const string ERROR_GENERAL_APLICACION                                = "ERROR_GENERAL_APLICACION";
        public const string ERROR_GENERAL_APLICACION_DETALLE                        = "ERROR_GENERAL_APLICACION_DETALLE";
        public const string ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS                 = "ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS";
        public const string ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS_DETALLE         = "ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS_DETALLE";
 
        public const string ERROR_VALIDANDO_DATOS                                   = "ERROR_VALIDANDO_DATOS";
        public const string ERROR_VALIDANDO_DATOS_DETALLE                           = "ERROR_VALIDANDO_DATOS_DETALLE";
        public const string ERROR_ACCESO_DENEGADO                                   = "ERROR_ACCESO_DENEGADO";
        public const string ERROR_CARGANDO_PAGINA                                   = "ERROR_CARGANDO_PAGINA";
        public const string ERROR_CARGANDO_PAGINA_DETALLE                           = "ERROR_CARGANDO_PAGINA_DETALLE";
        public const string ERROR_CARGANDO_DATOS                                    = "ERROR_CARGANDO_DATOS";
        public const string ERROR_VALIDANDO_OPERACION                               = "ERROR_VALIDANDO_OPERACION";
        public const string ERROR_CARGANDO_DATOS_DETALLE                            = "ERROR_CARGANDO_DATOS_DETALLE";
        public const string ERROR_VALIDANDO_OPERACION_DETALLE                       = "ERROR_VALIDANDO_OPERACION_DETALLE";
        public const string ERROR_SETEANDO_CAMPOS                                   = "ERROR_SETEANDO_CAMPOS";
        public const string ERROR_SETEANDO_CAMPOS_DETALLE                           = "ERROR_SETEANDO_CAMPOS_DETALLE";
        public const string ERROR_MODIFICANDO_GARANTIA                              = "ERROR_MODIFICANDO_GARANTIA";
        public const string ERROR_MODIFICANDO_GARANTIA_DETALLE                      = "ERROR_MODIFICANDO_GARANTIA_DETALLE";
        public const string ERROR_ELIMINANDO_GARANTIA                               = "ERROR_ELIMINANDO_GARANTIA";
        public const string ERROR_ELIMINANDO_GARANTIA_DETALLE                       = "ERROR_ELIMINANDO_GARANTIA_DETALLE";
        public const string ERROR_CARGANDO_DATOS_GARANTIAS                          = "ERROR_CARGANDO_DATOS_GARANTIAS";
        public const string ERROR_CARGANDO_DATOS_GARANTIAS_DETALLE                  = "ERROR_CARGANDO_DATOS_GARANTIAS_DETALLE";
        public const string ERROR_GUARDANDO_SESION                                  = "ERROR_GUARDANDO_SESION";
        public const string ERROR_GUARDANDO_SESION_DETALLE                          = "ERROR_GUARDANDO_SESION_DETALLE";
        public const string ERROR_CARGANDO_SESION                                   = "ERROR_CARGANDO_SESION";
        public const string ERROR_CARGANDO_SESION_DETALLE                           = "ERROR_CARGANDO_SESION_DETALLE";
        public const string ERROR_OBTENIENDO_DATOS_AVALUO                           = "ERROR_OBTENIENDO_DATOS_AVALUO";
        public const string ERROR_OBTENIENDO_DATOS_AVALUO_DETALLE                   = "ERROR_OBTENIENDO_DATOS_AVALUO_DETALLE";
        public const string ERROR_MONTO_MITIGADOR_CALCULADO_MAYOR                   = "ERROR_MONTO_MITIGADOR_CALCULADO_MAYOR";
        public const string ERROR_MONTO_MITIGADOR_CALCULADO_MENOR                   = "ERROR_MONTO_MITIGADOR_CALCULADO_MENOR";
        public const string ERROR_DATO_REQUERIDO                                    = "ERROR_DATO_REQUERIDO";
        public const string ERROR_ALMACENANDO_BITACORA                              = "ERROR_ALMACENANDO_BITACORA";
        public const string ERROR_ALMACENANDO_BITACORA_DETALLE                      = "ERROR_ALMACENANDO_BITACORA_DETALLE";
        public const string ERROR_CARGA_CATALOGOS                                   = "ERROR_CARGA_CATALOGOS";
        public const string ERROR_CARGA_CATALOGOS_DETALLE                           = "ERROR_CARGA_CATALOGOS_DETALLE";
        public const string ERROR_INGRESANDO                                        = "ERROR_INGRESANDO";
        public const string ERROR_CARGANDO_DATOS_OPERACION                          = "ERROR_CARGANDO_DATOS_OPERACION";
        public const string ERROR_CARGANDO_DATOS_OPERACION_DETALLE                  = "ERROR_CARGANDO_DATOS_OPERACION_DETALLE";
       
        public const string MODIFICACION_SATISFACTORIA_GARANTIA                     = "MODIFICACION_SATISFACTORIA_GARANTIA";
        public const string ELIMINACION_SATISFACTORIA_GARANTIA                      = "ELIMINACION_SATISFACTORIA_GARANTIA";

        public const string ERROR_ARCHIVO_SEGUI_VACIO                               = "ERROR_ARCHIVO_SEGUI_VACIO";
        public const string ERROR_ARCHIVO_SEGUI_VACIO_DETALLE                       = "ERROR_ARCHIVO_SEGUI_VACIO_DETALLE";
        public const string ERROR_CREANDO_ARCHIVO_SEGUI                             = "ERROR_CREANDO_ARCHIVO_SEGUI";
        public const string ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE                     = "ERROR_CREANDO_ARCHIVO_SEGUI_DETALLE";
        public const string ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI                   = "ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI";
        public const string ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE           = "ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI_DETALLE";
        public const string ERROR_ENCABEZADOS_ARCHIVO_FUENTE                        = "ERROR_ENCABEZADOS_ARCHIVO_FUENTE";
        public const string ERROR_GENERAL_GENERANDO_ARCHIVOS_SEGUI                  = "ERROR_GENERAL_GENERANDO_ARCHIVOS_SEGUI";
        public const string ERROR_SUBIENDO_ARCHIVO_FUENTE                           = "ERROR_SUBIENDO_ARCHIVO_FUENTE";
        public const string ERROR_SUBIENDO_ARCHIVO_FUENTE_DETALLE                   = "ERROR_SUBIENDO_ARCHIVO_FUENTE_DETALLE";
        public const string ERROR_TIPO_ARCHIVO                                      = "ERROR_TIPO_ARCHIVO";
        public const string ERROR_CARGANDO_ARCHIVO                                  = "ERROR_CARGANDO_ARCHIVO";
        public const string ERROR_CARGANDO_ARCHIVO_DETALLE                          = "ERROR_CARGANDO_ARCHIVO_DETALLE";
        public const string ERROR_ARCHIVO_NO_PORPORCIONADO                          = "ERROR_ARCHIVO_NO_PORPORCIONADO";

        public const string ERROR_OBTENIENDO_OPERACIONES_ASOCIADAS                  = "ERROR_OBTENIENDO_OPERACIONES_ASOCIADAS";
        public const string ERROR_OBTENIENDO_OPERACIONES_ASOCIADAS_DETALLE          = "ERROR_OBTENIENDO_OPERACIONES_ASOCIADAS_DETALLE";

        public const string GENERACION_CORRECTA_ARCHIVOS_SEGUI                      = "GENERACION_CORRECTA_ARCHIVOS_SEGUI";
        
        public const string _errorConsultaGiro                                      = "ERROR_CONSULTA_GIRO";
        public const string _errorCargandoAvaluoDetalle                             = "ERROR_CARGANDO_DATOS_AVALUO_DETALLE";

        public const string _errorDatosArchivoConfiguracion                         = "ERROR_DATOS_ARCHIVO_CONFIGURACION";
        public const string _errorDatosArchivoConfiguracionDetalle                  = "ERROR_DATOS_ARCHIVO_CONFIGURACION_DETALLE";

        public const string _errorCargaListaValuadores                              = "ERROR_CARGA_LISTA_VALUADORES";
        public const string _errorCargaListaValuadoresDetalle                       = "ERROR_CARGA_LISTA_VALUADORES_DETALLE";

        public const string _errorCargandoParametrosCalculoDetalle                  = "ERROR_CARGANDO_PARAMETROS_CALCULO_DETALLE";
        public const string _errorAplicandoCalculoMontoTATTANT                      = "ERROR_APLICANDO_CALCULO_MONTO_TAT_TANT";
        public const string _errorAplicandoCalculoMontoTATTANTDetalle               = "ERROR_APLICANDO_CALCULO_MONTO_TAT_TANT_DETALLE";
        public const string _errorAplicandoCalculoMontoTATTANTDetalleServicioWindows = "ERROR_APLICANDO_CALCULO_MONTO_TANT_DETALLE_SERVICIO_WINDOWS";

        public const string _errorObteniendoResultadosEjecucion                     = "ERROR_OBTENIENDO_RESULTADOS_EJECUCION";
        public const string _errorObteniendoResultadosEjecucionDetalle              = "ERROR_OBTENIENDO_RESULTADOS_EJECUCION_DETALLE";

        public const string _errorCargaGarantias                                    = "ERROR_CARGA_GARANTIAS";
        public const string _errorCargaGarantiasDetalle                             = "ERROR_CARGA_GARANTIAS_DETALLE";

        public const string _errorModificandoAvaluosDetalle                         = "ERROR_MODIFICANDO_AVALUOS_DETALLE";

        public const string _errorObteniendoAlertas                                 = "ERROR_OBTENIENDO_ALERTAS";
        public const string _errorObteniendoAlertasDetalle                          = "ERROR_OBTENIENDO_ALERTAS_DETALLE";
        public const string _errorDescargandoArchivosAlertas                        = "ERROR_DESCARGA_ARCHIVOS_ALERTAS";
        public const string _errorDescargandoArchivosAlertasDetalle                 = "ERROR_DESCARGA_ARCHIVOS_ALERTAS_DETALLE";

        public const string _errorCalculandoMontoMitigador                          = "ERROR_CALCULANDO_MONTO_MITIGADOR";
        public const string _errorCalculandoMontoMitigadorDetalle                   = "ERROR_CALCULANDO_MONTO_MITIGADOR_DETALLE";

        public const string _errorConvirtiendoDatoDetalle                           = "ERROR_CONVIRTIENDO_DATO_DETALLE";

        public const string _errorCargaIndicesActAvaluos                            = "ERROR_CARGA_INDICES_ACT_AVALUOS";
        public const string _errorCargaIndicesActAvaluosDetalle                     = "ERROR_CARGA_INDICES_ACT_AVALUOS_DETALLE";
        public const string _errorInsertandoIndicesActAvaluos                       = "ERROR_INSERTANDO_INDICE_ACT_AVALUOS";
        public const string _errorInsertandoIndicesActAvaluosDetalle                = "ERROR_INSERTANDO_INDICE_ACT_AVALUOS_DETALLE";
        public const string _errorCargaSemestreActAvaluos                           = "ERROR_CARGA_SEMESTRE_ACT_AVALUOS";
        public const string _errorCargaSemestreActAvaluosDetalle                    = "ERROR_CARGA_SEMESTRE_ACT_AVALUOS_DETALLE";
        public const string _errorObteniendoSemestreACalcular                       = "ERROR_OBTENIENDO_SEMESTRES_A_CALCULAR";
        public const string _errorObteniendoSemestreACalcularDetalle                = "ERROR_OBTENIENDO_SEMESTRES_A_CALCULAR_DETALLE";

        public const string _errorInsertandoSemestresCalculados                     = "ERROR_INSERTANDO_SEMESTRES_CALCULADOS";
        public const string _errorInsertandoSemestresCalculadosDetalle              = "ERROR_INSERTANDO_SEMESTRES_CALCULADOS_DETALLE";

        public const string _errorObteniendoRegistrosCalculoMTATMTANT               = "ERROR_OBTENIENDO_REGISTROS_CALCULO_MTAT_MTANT";
        public const string _errorObteniendoRegistrosCalculoMTATMTANTDetalle        = "ERROR_OBTENIENDO_REGISTROS_CALCULO_MTAT_MTANT_DETALLE";
        public const string _errorEliminandoSemestresCalculados                     = "ERROR_ELIMINANDO_SEMESTRES_CALCULADOS";
        public const string _errorEliminandoSemestresCalculadosDetalle              = "ERROR_ELIMINANDO_SEMESTRES_CALCULADOS_DETALLE";
        public const string _errorDatosAvaluoRequeridos                             = "ERROR_DATOS_AVALUO_REQUERIDO";

        public const string _errorNormalizandoAvaluo                                = "ERROR_NORMALIZANDO_AVALUO";
        public const string _errorNormalizandoAvaluoDetalle                         = "ERROR_NORMALIZANDO_AVALUO_DETALLE";

        public const string _errorCargaTipoBienRelacionado                          = "ERROR_CARGA_TIPO_BIEN_RELACIONADO";
        public const string _errorCargaTipoBienRelacionadDetalle                    = "ERROR_CARGA_TIPO_BIEN_RELACIONADO_DETALLE";
        public const string _errorInsertandoTipoBienRelacionado                     = "ERROR_INSERTANDO_TIPO_BIEN_RELACIONADO";
        public const string _errorInsertandoTipoBienRelacionadoDetalle              = "ERROR_INSERTANDO_TIPO_BIEN_RELACIONADO_DETALLE";
        public const string _errorModificandoTipoBienRelacionado                    = "ERROR_MODIFICANDO_TIPO_BIEN_RELACIONADO";
        public const string _errorModificandoTipoBienRelacionadoDetalle             = "ERROR_MODIFICANDO_TIPO_BIEN_RELACIONADO_DETALLE";
        public const string _errorEliminandoTipoBienRelacionado                     = "ERROR_ELIMINANDO_TIPO_BIEN_RELACIONADO";
        public const string _errorEliminandoTipoBienRelacionadoDetalle              = "ERROR_ELIMINANDO_TIPO_BIEN_RELACIONADO_DETALLE";

        public const string _errorCargaTipoPolizaSugef                              = "ERROR_CARGA_TIPO_POLIZA_SUGEF";
        public const string _errorCargaTipoPolizaSugefDetalle                       = "ERROR_CARGA_TIPO_POLIZA_SUGEF_DETALLE";
        public const string _errorInsertandoTipoPolizaSugef                         = "ERROR_INSERTANDO_TIPO_POLIZA_SUGEF";
        public const string _errorInsertandoTipoPolizaSugefDetalle                  = "ERROR_INSERTANDO_TIPO_POLIZA_SUGEF_DETALLE";
        public const string _errorModificandoTipoPolizaSugef                        = "ERROR_MODIFICANDO_TIPO_POLIZA_SUGEF";
        public const string _errorModificandoTipoPolizaSugefDetalle                 = "ERROR_MODIFICANDO_TIPO_POLIZA_SUGEF_DETALLE";
        public const string _errorEliminandoTipoPolizaSugef                         = "ERROR_ELIMINANDO_TIPO_POLIZA_SUGEF";
        public const string _errorEliminandoTipoPolizaSugefDetalle                  = "ERROR_ELIMINANDO_TIPO_POLIZA_SUGEF_DETALLE";

        public const string _errorCargaPolizaSap                                    = "ERROR_CARGA_POLIZA_SAP";
        public const string _errorCargaPolizaSapDetalle                             = "ERROR_CARGA_POLIZA_SAP_DETALLE";

        public const string _errorObteniendoPolizasSap                              = "ERROR_OBTENIENDO_POLIZAS_SAP";
        public const string _errorObteniendoPolizasSapDetalle                       = "ERROR_OBTENIENDO_POLIZAS_SAP_DETALLE";

        public const string _errorCargaPorcentajeAceptacion                         = "ERROR_CARGA_PORCENTAJE_ACEPTACION";
        public const string _errorCargaPorcentajeAceptacionDetalle                  = "ERROR_CARGA_PORCENTAJE_ACEPTACION_DETALLE";
        public const string _errorInsertandoPorcentajeAceptacion                    = "ERROR_INSERTANDO_PORCENTAJE_ACEPTACION";
        public const string _errorInsertandoPorcentajeAceptacionDetalle             = "ERROR_INSERTANDO_PORCENTAJE_ACEPTACION_DETALLE";
        public const string _errorModificandoPorcentajeAceptacion                   = "ERROR_MODIFICANDO_PORCENTAJE_ACEPTACION";
        public const string _errorModificandoPorcentajeAceptacionDetalle            = "ERROR_MODIFICANDO_PORCENTAJE_ACEPTACION_DETALLE";
        public const string _errorEliminandoPorcentajeAceptacion                    = "ERROR_ELIMINANDO_PORCENTAJE_ACEPTACION";
        public const string _errorEliminandoPorcentajeAceptacionDetalle             = "ERROR_ELIMINANDO_PORCENTAJE_ACEPTACION_DETALLE";

     
        public const string _errorCargaHistorialPorcentajeAceptacion                = "ERROR_CARGA_HISTORICO_PORCENTAJE_ACEPTACION";
        public const string _errorCargaHistorialPorcentajeAceptacionDetalle         = "ERROR_CARGA_HISTORICO_PORCENTAJE_ACEPTACION_DETALLE";


        public const string _errorCargaCoberturaPolizaSap                           = "ERROR_CARGA_COBERTURA_POLIZA_SAP";
        public const string _errorCargaCoberturaPolizaSapDetalle                    = "ERROR_COBERTURA_CARGA_POLIZA_SAP_DETALLE";

        public const string _errorObteniendoCoberturasPolizasSap                    = "ERROR_OBTENIENDO_COBERTURAS_POLIZAS_SAP";
        public const string _errorObteniendoCoberturasPolizasSapDetalle             = "ERROR_OBTENIENDO_COBERTURAS_POLIZAS_SAP_DETALLE";

        //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
        public const string _errorPorcAceptTerrenoCalcNoAnotadaNoInscrita                       = "ERROR_PORC_ACEPT_TERRENO_CALC_NO_ANOTADA_NO_INSCRITA";
        public const string _errorPorcAceptTerrenoCalcAnotada                                   = "ERROR_PORC_ACEPT_TERRENO_CALC_ANOTADA";
        public const string _errorPorcAceptTerrenoCalcFechaUltimoSeguimiento                    = "ERROR_PORC_ACEPT_TERRENO_CALC_FECHA_ULTIMO_SEGUIMIENTO";
        public const string _errorPorcAceptTerrenoCalcFechaValuacion                            = "ERROR_PORC_ACEPT_TERRENO_CALC_FECHA_VALUACION";

        public const string _errorPorcAceptNoTerrenoCalcNoAnotadaNoInscrita                     = "ERROR_PORC_ACEPT_NO_TERRENO_CALC_NO_ANOTADA_NO_INSCRITA";
        public const string _errorPorcAceptNoTerrenoCalcAnotada                                 = "ERROR_PORC_ACEPT_NO_TERRENO_CALC_ANOTADA";
        public const string _errorPorcAceptNoTerrenoCalcFechaUltimoSeguimiento                  = "ERROR_PORC_ACEPT_NO_TERRENO_CALC_FECHA_ULTIMO_SEGUIMIENTO";
        public const string _errorPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo  = "ERROR_PORC_ACEPT_NO_TERRENO_CALC_FECHA_ULTIMO_SEGUIMIENTO_MAQUINARIA_EQUIPO";
        public const string _errorPorcAceptNoTerrenoCalcFechaValuacion                          = "ERROR_PORC_ACEPT_NO_TERRENO_CALC_FECHA_VALUACION";

        public const string _errorInsertandoGarantia                                            = "ERROR_INSERTANDO_GARANTIA";
        public const string _errorInsertandoGarantiaDetalle                                     = "ERROR_INSERTANDO_GARANTIA_DETALLE";

        public const string _errorValidandoTarjeta                                              = "ERROR_VALIDANDO_TARJETA";
        public const string _errorValidandoTarjetaDetalle                                       = "ERROR_VALIDANDO_TARJETA_DETALLE";
        public const string _errorConexionWebServices                                           = "ERROR_CONEXION_WEB_SERVICES";
        public const string _errorConexionWebServicesDetalle                                    = "ERROR_CONEXION_WEB_SERVICE_DETALLE";
        public const string _errorInterfaceSistar                                               = "ERROR_INTERFAZ_SISTAR";
        public const string _errorInterfaceSistarDetalle                                        = "ERROR_INTERFAZ_SISTAR_DETALLE";
        public const string _errorTramaSistar                                                   = "ERROR_TRAMA_SISTAR";
        public const string _errorObteniendoTipoCambioBCCR                                      = "ERROR_OBTENIENDO_TIPO_CAMBIO_BCCR";
        public const string _errorObteniendoTipoCambioBCCRFechas                                = "ERROR_OBTENIENDO_TIPO_CAMBIO_BCCR_FECHAS";

        public const string _errorInsertandoSaldoTotalPr                                        = "ERROR_INSERTANDO_SALDO_TOTAL_PR";
        public const string _errorInsertandoSaldoTotalPrDetalle                                 = "ERROR_INSERTANDO_SALDO_TOTAL_PR_DETALLE";
        public const string _errorModificandoSaldoTotalPr                                       = "ERROR_MODIFICANDO_SALDO_TOTAL_PR";
        public const string _errorModificandoSaldoTotalPrDetalle                                = "ERROR_MODIFICANDO_SALDO_TOTAL_PR_DETALLE";
        public const string _errorEliminandoSaldoTotalPr                                        = "ERROR_ELIMINANDO_SALDO_TOTAL_PR";
        public const string _errorEliminandoSaldoTotalPrDetalle                                 = "ERROR_ELIMINANDO_SALDO_TOTAL_PR_DETALLE";
        public const string _errorConsultandoSaldoTotalPrDetalle                                = "ERROR_CONSULTANDO_SALDO_TOTAL_PR_DETALLE";
        public const string _errorConsultandoOperacionesRelacionadasGarantiaDetalle             = "ERROR_CONSULTANDO_OPERACIONES_RELACIONADAS_A_GARANTIA_DETALLE";
        public const string _errorNormalizandoOperacionesRelacionadasAGarantia                  = "ERROR_NORMALIZANDO_OPERACIONES_RELACIONADAS_A_GARANTIA";
        public const string _errorNormalizandoOperacionesRelacionadasAGarantiaDetalle           = "ERROR_NORMALIZANDO_OPERACIONES_RELACIONADAS_A_GARANTIA_DETALLE";

        public const string _errorAplicandoCalculoDistribucionPrDetalle                         = "ERROR_APLICANDO_CALCULO_DISTRIBUCION_PR_DETALLE";
        public const string _errorAplicandoCalculoDistribucionPr                                = "ERROR_APLICANDO_CALCULO_DISTRIBUCION_PR";
        public const string _errorObteniendoOperacionesGarantias                                = "ERROR_OBTENIENDO_OPERACIONES_GARANTIAS";
        public const string _errorObteniendoOperacionesGarantiasDetalle                         = "ERROR_OBTENIENDO_OPERACIONES_GARANTIAS_DETALLE";

        /// <summary>
        /// Error generado cuando se va a enviar un correo electrónico
        /// </summary>
        public const string ERROR_CORREO_ATTACHMENT = "ERROR_ARCHIVO_NO_EXISTE";
        /// <summary>
        /// Error generado cuando se va a enviar un correo electrónico
        /// </summary>
        public const string ERROR_SEND_MAIL = "ERROR_SERVIDOR_NO_EXISTE";
       
		#endregion

		#region Constructores
		/// <summary>
		/// Constructor por defecto
		/// </summary>
		public Mensajes() {}
		#endregion

		#region Métodos
		/// <summary>
		/// Obtiene un mensaje a través de un archivo de recursos específico
		/// </summary>
		/// <param name="llave">Llave para buscar el mensaje</param>
		/// <returns>Retorna el mensaje respectivo</returns>
		public static string Obtener(string llave, string asembly)
		{
			try
			{
				//string assemblyMensaje = ConfigurationManager.AppSettings ["ASSEMBLY_MENSAJES"];
                string assemblyMensaje = asembly;
				string mensaje = RecursosManager.Obtener(llave, assemblyMensaje, ARCHIVO_RECURSOS);
				return mensaje;
			}
			catch (Exception e)
			{
                string errorEsuscitado = ERROR_OBTENIENDO_MENSAJE + " (Llave no encontrada: " + llave + "). Detalle Técnico: " + e.Message;
                throw new ExcepcionBase(errorEsuscitado, e);
			}
		}

        public static string Obtener(string llave, string primerParametro, string asembly)
		{
			try
			{
                string mensaje = Obtener(llave, asembly);
				mensaje = mensaje.Replace (PRIMER_PARAMETRO, primerParametro);
				return mensaje;
			}
			catch (ExcepcionBase e)
			{
                string errorEsuscitado = ERROR_OBTENIENDO_MENSAJE + " (Llave no encontrada: " + llave + "). Detalle Técnico: " + e.Message;
                throw new ExcepcionBase(errorEsuscitado, e);
            }
		}

        public static string Obtener(string llave, string primerParametro, string segundoParametro, string asembly)
		{
			try
			{
                string mensaje = Obtener(llave, asembly);
				mensaje = mensaje.Replace (PRIMER_PARAMETRO,primerParametro);
				mensaje = mensaje.Replace (SEGUNDO_PARAMETRO, segundoParametro);
				return mensaje;
			}
			catch (ExcepcionBase e)
			{
                string errorEsuscitado = ERROR_OBTENIENDO_MENSAJE + " (Llave no encontrada: " + llave + "). Detalle Técnico: " + e.Message;
                throw new ExcepcionBase(errorEsuscitado, e);
            }
		}

        public static string Obtener(string llave, StringCollection parametros, string asembly)
		{
			int i = 1;
			try
			{
                string mensaje = Obtener(llave, asembly);
			
				foreach (string parametro in parametros)
				{
					mensaje = mensaje.Replace("@" + i.ToString(), parametro); 
					i++;
				}
				return (mensaje);
			}
			catch (ExcepcionBase e)
			{
                string errorEsuscitado = ERROR_OBTENIENDO_MENSAJE + " (Llave no encontrada: " + llave + "). Detalle Técnico: " + e.Message;
                throw new ExcepcionBase(errorEsuscitado, e);
            }
		}
		#endregion
	}
}