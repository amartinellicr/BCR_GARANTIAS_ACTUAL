using System;
using System.Collections.Generic;
using System.Text;

namespace BCR.GARANTIAS.Comun
{
    [Serializable]
    public class Enumeradores
    {
        #region Orden de Inconsistencias
        /// <summary>
        /// Determina el orden en que se almacenán las inconsistencia dentro de la lista
        /// </summary>
        public enum Inconsistencias
        {
            FechaPresentacion           = 0,
            IndicadorInscripcion        = 1,
            MontoMitigador              = 2,
            PorcentajeAceptacion        = 3,
            Partido                     = 4,
            Finca                       = 5,
            ClaseGarantia               = 6,
            TipoBien                    = 7,
            TipoMitigador               = 8,
            TipoDocumentoLegal          = 9,
            GradoGravamen               = 10,
            ValuacionesTerreno          = 11,
            ValuacionesNoTerreno        = 12,
            FechaUltimoSeguimiento      = 13,
            FechaConstruccion           = 14,
            DatosAvaluosIncorrectos     = 15,
            FechaVencimiento            = 16,
            FechaPrescripcion           = 17,
            ValidezMontoTasActTerreno   = 18,
            ValidezMontoTasActNoTerreno = 19,
            FechaConstitucion           = 20,
            ListaOperaciones            = 21,
            PolizaInvalida              = 22,
            InfraSeguro                 = 23,
            AcreenciasDiferentes        = 24,
            MontoPolizaMenor            = 25,
            VencimientoPolizaMenor      = 26,
            MontoAcreenciaInvalido      = 27,
            IdAcreedorDiferente         = 28,
            NombreAcreedorDiferente     = 29,
            DatosAcreedorDiferentes     = 30,
            FechaValuacionMayor         = 31,
            TipoMitigadorNoAsignado     = 32,
            PolizaNoAsociada            = 33,
            PorcentajeAceptacionMayorCalculado  = 34,
            PolizaAsociadaVencimientoMenor      = 35,
            PolizaAsociadaMontoMenor    = 36,
            FechaSeguimientoMayor       = 37,
            PolizaAsociada              = 38,
            PolizaInvalidaTipoBienPoliza = 39,
            MontoPolizaNoCubreBien      = 40,
            CoberturasObligatoriasInvalidas = 41,
            //agregar mas indicadores para que no se se caiga. 

            //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
            PorcAceptTerrenoCalcNoAnotadaNoInscrita = 42,
            PorcAceptTerrenoCalcAnotada = 43,
            PorcAceptTerrenoCalcFechaUltimoSeguimiento = 44,
            PorcAceptTerrenoCalcFechaValuacion = 45,
            PorcAceptTerrenoMayorCalculado = 46,

            PorcAceptNoTerrenoCalcNoAnotadaNoInscrita = 47,
            PorcAceptNoTerrenoCalcAnotada = 48,
            PorcAceptNoTerrenoCalcFechaUltimoSeguimiento = 49,
            PorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo = 50,
            PorcAceptNoTerrenoCalcFechaValuacion = 51,
            PorcAceptNoTerrenoCalcFechaUltimoSeguimientoNoVehiculos = 52,
            PorcAceptNoTerrenoMayorCalculado = 53
        }
        #endregion Orden de Inconsistencias

        #region Tipos de Operaciones

        public enum Tipos_Operaciones
        {
            Directa     = 1,
            Contrato    = 2,
            Tarjeta     = 3,
            Todos       = 4
        }

        #endregion Tipos de Operaciones

        #region Tipos de Garantía Real

        public enum Tipos_Garantia_Real
        {
            Ninguna             = 0,
            Hipoteca            = 1,
            Cedula_Hipotecaria  = 2,
            Prenda              = 3
        }

        #endregion Tipos de Garantía Real

        #region Tipos de Acción Realizada

        public enum Tipos_Accion
        {
            Ninguna     = 0,
            Insertar    = 1,
            Modificar   = 2,
            Borrar      = 3
        }

        #endregion Tipos de Acción Realizada

        #region Catálogos usados por el mantenimiento de garantías reales

        /*
            <add key="CAT_TIPO_PERSONA" value="1"/>
            <add key="CAT_CLASE_GARANTIA" value="7"/>
            <add key="CAT_TIPOS_DOCUMENTOS" value="8"/>
            <add key="CAT_INSCRIPCION" value="9"/>
            <add key="CAT_GRADO_GRAVAMEN" value="10"/>
            <add key="CAT_OPERACION_ESPECIAL" value="11"/>
            <add key="CAT_TIPO_BIEN" value="12"/>
            <add key="CAT_LIQUIDEZ" value="13"/>
            <add key="CAT_TENENCIA" value="14"/>
            <add key="CAT_MONEDA" value="15"/>
            <add key="CAT_TIPO_MITIGADOR" value="22"/>
            <add key="CAT_TIPO_GARANTIA_REAL" value="23"/>
        */

        public enum Catalogos_Garantias_Reales
        {
            CAT_TIPO_PERSONA        = 1,
            CAT_CLASE_GARANTIA      = 7,
            CAT_TIPOS_DOCUMENTOS    = 8,
            CAT_INSCRIPCION         = 9,
            CAT_GRADO_GRAVAMEN      = 10,
            CAT_OPERACION_ESPECIAL  = 11,
            CAT_TIPO_BIEN           = 12,
            CAT_LIQUIDEZ            = 13,
            CAT_TENENCIA            = 14,
            CAT_MONEDA              = 15,
            CAT_TIPO_MITIGADOR      = 22,
            CAT_TIPO_GARANTIA_REAL  = 23
        }

        #endregion Catálogos usados por el mantenimiento de garantías reales

        #region Nombre de los archivos SEGUI generados por la aplicación

        public enum Nombre_Archivos_SEGUI
        {
            Deudores                            = 1,
            DEUDORES_FCP                        = 2,
            GarantiasFiduciarias                = 3,
            GarantiasFiduciariasInfoCompleta    = 4,
            GarantiasFiduciariasContratos       = 5,
            GarantiasReales                     = 6,
            GarantiasRealesInfoCompleta         = 7,
            GarantiasRealesContratos            = 8,
            GarantiasValor                      = 9,
            GarantiasValorInfoCompleta          = 10,
            GarantiasValorContratos             = 11,
            Contratos                           = 12,
            Giros                               = 13
        }

        #endregion Nombre de los archivos SEGUI generados por la aplicación

        #region Tipos de Valuadores
        /// <summary>
        /// Tipos de valuadores manejadosp or el sistema
        /// </summary>
        public enum TiposValuadores
        {
            Perito  = 1,
            Empresa = 2
        }

        #endregion Tipos de Valuadores

        #region Lista de Controles Web de Garantías Reales
        /// <summary>
        /// Establece la lista de controles web, de las garantías reales, que serán manipulados por la clase entidad
        /// </summary>
        public enum ControlesWebGarantiasReales
        {
            FechaPresentacion = 0,
            IndicadorInscripcion = 1,
            MontoMitigador = 2,
            PorcentajeAceptacion = 3,
            TipoBien = 4,
            TipoMitigador = 5,
            MontoUltimaTasacionTerreno = 6,
            MontoUltimaTasacionNoTerreno = 7,
            FechaUltimoSeguimiento = 8,
            FechaConstruccion = 9
        }
        #endregion Lista de Controles Web de Garantías Reales

        #region Tipos de Trama de las Coberturas

        public enum Tipos_Trama_Cobertura
        {
            Ninguna = 0,
            PorAsignar = 1,
            Asignada = 2
        }

        #endregion Tipos de Trama de las Coberturas
    }
}
