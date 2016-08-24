using System;
using System.Data;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Collections.Specialized;
using System.Diagnostics;
using System.IO;
using System.Configuration;
using System.Globalization;
using System.Data.SqlClient;

using BCR.GARANTIAS.Comun;
using BCRGARANTIAS.Datos;


namespace BCR.GARANTIAS.Entidades
{
    public class clsGarantiaReal
    {
        #region Variables

        #region Operación

        /// <summary>
        /// Código de la contabilidad
        /// </summary>
        private short codContabilidad;

        /// <summary>
        /// Código de la oficina
        /// </summary>
        private short codOficina;

        /// <summary>
        /// Código de la moneda de la operación
        /// </summary>
        private short codMonedaOper;

        /// <summary>
        /// Código del producto
        /// </summary>
        private short codProducto;

        /// <summary>
        /// Número de la operación o contrato
        /// </summary>
        private long numOperacion;

        /// <summary>
        /// Código del tipo de operación crediticia
        /// </summary>
        private short tipoOperacionCred;

        #endregion Operación

        #region Garantía

        /// <summary>
        ///  Consecutivo de la operación
        /// </summary>
        private long codOperacion;

        /// <summary>
        /// Consecutivo de la garantía real
        /// </summary>
        private long codGarantiaReal;

        /// <summary>
        /// Tipo de garantía
        /// </summary>
        private short codTipoGarantia;

        /// <summary>
        /// Clase de la garantía
        /// </summary>
        private short codClaseGarantia;

        /// <summary>
        /// Tipo de garantía real
        /// </summary>
        private short codTipoGarantiaReal;

        /// <summary>
        /// Descripción del tipo de garantía real
        /// </summary>
        private string desTipoGarantiaReal;

        /// <summary>
        /// Código de la garantía real, en formato Partido - Finca (Clase de bien - Placa, según el tipo de garantía real)
        /// </summary>
        private string garantiaReal;

        /// <summary>
        /// Partido
        /// </summary>
        private short codPartido;

        /// <summary>
        /// Número de finca
        /// </summary>
        private string numeroFinca;

        /// <summary>
        /// Código del grado de la cédula hipotecaria
        /// </summary>
        private string codGrado;

        /// <summary>
        /// Número de la cédula hipotecaria
        /// </summary>
        private string cedulaHipotecaria;

        /// <summary>
        /// Clase de bien 
        /// </summary>
        private string codClaseBien;

        /// <summary>
        /// Número de identificación del bien
        /// </summary>
        private string numPlacaBien;

        /// <summary>
        /// Tipo de bien
        /// </summary>
        private short codTipoBien;

        /// <summary>
        /// Tipo de mitigador de riesgo
        /// </summary>
        private short codTipoMitigador;

        /// <summary>
        /// Tipo de documento legal
        /// </summary>
        private short codTipoDocumentoLegal;

        /// <summary>
        /// Monto mitigador
        /// </summary>
        private decimal montoMitigador;

        /// <summary>
        /// Indicador de inscripción
        /// </summary>
        private short codInscripcion;

        /// <summary>
        /// Fecha de presentación ante el Registro
        /// </summary>
        private DateTime fechaPresentacion;

        /// <summary>
        /// Porcentaje de responsabilidad
        /// </summary>
        private decimal porcentajeResponsabilidad;

        /// <summary>
        /// Grado de gravamen
        /// </summary>
        private short codGradoGravamen;

        /// <summary>
        /// Indicador de operación especial
        /// </summary>
        private short codOperacionEspecial;

        /// <summary>
        /// Fecha de constitución
        /// </summary>
        private DateTime fechaConstitucion;

        /// <summary>
        /// Fecha de vencimiento
        /// </summary>
        private DateTime fechaVencimiento;

        /// <summary>
        /// Tipo de persona del acreedor
        /// </summary>
        private short codTipoAcreedor;

        /// <summary>
        /// Indentificación del acreedor
        /// </summary>
        private string cedAcreedor;

        /// <summary>
        /// Código de liquidez
        /// </summary>
        private short codLiquidez;

        /// <summary>
        /// Código de tenencia
        /// </summary>
        private short codTenencia;

        /// <summary>
        /// Código de la moneda de la garantía
        /// </summary>
        private short codMoneda;

        /// <summary>
        /// Fecha de prescripción de la garantía
        /// </summary>
        private DateTime fechaPrescripcion;

        /// <summary>
        /// Indicador del estado del registro
        /// </summary>
        private short codEstado;

        /// <summary>
        /// Descripción del tipo de bien
        /// </summary>
        private string desTipoBien;

        /// <summary>
        /// Descripción del tipo de mitigador
        /// </summary>
        private string desTipoMitigador;

        /// <summary>
        /// Descripción del tipo de documento legal
        /// </summary>
        private string desTipoDocumentoLegal;

        /// <summary>
        /// Descripción del indicador de inscripción
        /// </summary>
        private string desIndicadorInscripcion;

        /// <summary>
        /// Descripción del tipo de grado de gravamen
        /// </summary>
        private string desTipoGradoGravamen;

        /// <summary>
        /// Descripción del tipo de operación especial
        /// </summary>
        private string desTipoOperacionEspecial;

        /// <summary>
        /// Descripción del tipo de persona del acreedor
        /// </summary>
        private string desTipoPersonaAcreedor;

        /// <summary>
        /// Descripción del tipo de liquidez
        /// </summary>
        private string desTipoLiquidez;

        /// <summary>
        /// Descripción del tipo de tenencia
        /// </summary>
        private string desTipoTenencia;

        /// <summary>
        /// Descripción del tipo de moneda de la garantía
        /// </summary>
        private string desTipoMoneda;

        /// <summary>
        /// Descripción del tipo de bien anterior
        /// </summary>
        private string desTipoBienAnterior;

        /// <summary>
        /// Descripción del tipo de mitigador anterior
        /// </summary>
        private string desTipoMitigadorAnterior;

        /// <summary>
        /// Descripción del tipo de documento legal anterior
        /// </summary>
        private string desTipoDocumentoLegalAnterior;

        /// <summary>
        /// Descripción del indicador de inscripción anterior
        /// </summary>
        private string desIndicadorInscripcionAnterior;

        /// <summary>
        /// Descripción del tipo de grado de gravamen anterior
        /// </summary>
        private string desTipoGradoGravamenAnterior;

        /// <summary>
        /// Descripción del tipo de operación especial anterior
        /// </summary>
        private string desTipoOperacionEspecialAnterior;

        /// <summary>
        /// Descripción del tipo de persona del acreedor anterior
        /// </summary>
        private string desTipoPersonaAcreedorAnterior;

        /// <summary>
        /// Descripción del tipo de liquidez anterior
        /// </summary>
        private string desTipoLiquidezAnterior;

        /// <summary>
        /// Descripción del tipo de tenencia anterior
        /// </summary>
        private string desTipoTenenciaAnterior;

        /// <summary>
        /// Descripción del tipo de moneda de la garantía anterior
        /// </summary>
        private string desTipoMonedaAnterior;

        /// <summary>
        /// Código de la garantía real que ser almacenada en la bitácora
        /// </summary>
        private string garantiaRealBitacora;

        /// <summary>
        /// Cédula ultimo Usuario que modificó la garantía
        /// </summary>
        private string usuarioModifico;

        /// <summary>
        /// Nombre del usuario que modificó la garantía
        /// </summary>
        private string nombreUsuarioModifico;

        /// <summary>
        /// Fecha en que se modificó la garantia
        /// </summary>
        private DateTime fechaModifico;

        /// <summary>
        /// Fecha en que se insertó la garantia
        /// </summary>
        private DateTime fechaInserto;

        /// <summary>
        /// Fecha en que se realiza la réplica
        /// </summary>
        private DateTime fechaReplica;

        /// <summary>
        /// Porcentaje de Aceptacion Calculado
        /// </summary>
        private decimal porcentajeAceptacionCalculado;

        /// <summary>
        /// Porcentaje de Aceptacion Calculado Original
        /// </summary>
        private decimal porcentajeAceptacionCalculadoOriginal;

        /// <summary>
        /// Indicador de que el dudor habita la vivienda
        /// </summary>
        private bool indicadorViviendaHabitadaDeudor;

        /// <summary>
        /// Porcentaje de aceptación
        /// </summary>
        private decimal porcentajeAceptacion;

        #endregion Garantía

        #region Avalúos

        /// <summary>
        /// Fecha del avalúo
        /// </summary>
        private DateTime fechaValuacion;

        /// <summary>
        /// Identificación de la empresa que realiza el avalúo
        /// </summary>
        private string cedulaEmpresa;

        /// <summary>
        /// Identificación del perito que realiza el avalúo
        /// </summary>
        private string cedulaPerito;

        /// <summary>
        /// Monto de la última tasación del terreno
        /// </summary>
        private decimal montoUltimaTasacionTerreno;

        /// <summary>
        /// Monto de la última tasación del no terreno
        /// </summary>
        private decimal montoUltimaTasacionNoTerreno;

        /// <summary>
        /// Monto de la tasación actualizada del terreno
        /// </summary>
        private decimal montoTasacionActualizadaTerreno;

        /// <summary>
        /// Monto de la tasación actualizada del no terreno
        /// </summary>
        private decimal montoTasacionActualizadaNoTerreno;

        /// <summary>
        /// Monto total del avalúo
        /// </summary>
        private decimal montoTotalAvaluo;

        /// <summary>
        /// Fecha en que se realiza el último seguimiento
        /// </summary>
        private DateTime fechaUltimoSeguimiento;

        /// <summary>
        /// Fecha en que se contruyó el bien valuado
        /// </summary>
        private DateTime fechaConstruccion;

        /// <summary>
        /// Fecha del avalúo registrado en el SICC para una misma finca o prenda
        /// </summary>
        private DateTime fechaValuacionSICC;

        /// <summary>
        /// Fecha del avalúo registrado en el SICC
        /// </summary>
        private DateTime fechaAvaluoSICC;

        /// <summary>
        /// Monto total del avalúo registrado en el SICC
        /// </summary>
        private decimal montoTotalAvaluoSICC;

        /// <summary>
        /// Fecha del penúltimo avalúo registrado para una garantía específica
        /// </summary>
        private DateTime fechaPenultimoAvaluo;

        /// <summary>
        /// Fecha actual de la base de datos
        /// </summary>
        private DateTime fechaActualBD;

        /// <summary>
        /// Indica si el avalúo ha sido actualizado o no
        /// </summary>
        private bool avaluoActualizado;

        /// <summary>
        /// Fecha del último semestre calculado
        /// </summary>
        private DateTime fechaSemestreCalculado;

        /// <summary>
        /// Monto de la tasación actulizada del terreno calculado
        /// </summary>
        private decimal? montoTasacionActualizadaTerrenoCalculado;

        /// <summary>
        /// Monto de la tasación actulizada del no terreno calculado
        /// </summary>
        private decimal? montoTasacionActualizadaNoTerrenoCalculado;

        /// <summary>
        /// Porcentaje de Aceptación del Terreno
        /// </summary>
        private decimal porcentajeAceptacionTerreno;

        /// <summary>
        /// Porcentaje de Aceptación del No Terreno
        /// </summary>
        private decimal porcentajeAceptacionNoTerreno;

        /// <summary>
        /// Porcentaje de Aceptación del Terreno Calculado
        /// </summary>
        private decimal porcentajeAceptacionTerrenoCalculado;

        /// <summary>
        /// Porcentaje de Aceptación del No Terreno Calculado
        /// </summary>
        private decimal porcentajeAceptacionNoTerrenoCalculado;


        #endregion Avalúos

        #region Inconsistencias

        /// <summary>
        /// Indicador de que se presentó un error con la fecha de presentación
        /// </summary>
        private bool inconsistenciaFechaPresentacion;

        /// <summary>
        /// Indicador de que se presentó un error con indicador de inscripción
        /// </summary>
        private bool inconsistenciaIndicadorInscripcion;

        /// <summary>
        /// Indicador de que se presentó un error con monto mitigador
        /// </summary>
        private short inconsistenciaMontoMitigador;

        /// <summary>
        /// Indicador de que se presentó un error con porcentaje de aceptación
        /// </summary>
        private bool inconsistenciaPorcentajeAceptacion;

        /// <summary>
        /// Indicador de que se presentó un error con el partido
        /// </summary>
        private bool inconsistenciaPartido;

        /// <summary>
        /// Indicador de que se presentó un error con el número de finca
        /// </summary>
        private bool inconsistenciaFinca;

        /// <summary>
        /// Indicador de que se presentó un error con la clase de garantía
        /// </summary>
        private bool inconsistenciaClaseGarantia;

        /// <summary>
        /// Indicador de que se presentó un error con el tipo de bien
        /// </summary>
        private bool inconsistenciaTipoBien;

        /// <summary>
        /// Indicador de que se presentó un error con el tipo de mitigador
        /// </summary>
        private bool inconsistenciaTipoMitigador;

        /// <summary>
        /// Indicador de que se presentó un error con el tipo de documento legal
        /// </summary>
        private bool inconsistenciaTipoDocumentoLegal;

        /// <summary>
        /// Indicador de que se presentó un error con grado de gravamen
        /// </summary>
        private bool inconsistenciaGradoGravamen;

        /// <summary>
        /// Indicador de que se presentó un error con los datos del terreno, según el tipo de bien
        /// </summary>
        private bool inconsistenciaValuacionesTerreno;

        /// <summary>
        /// Indicador de que se presentó un error con los datos del no terreno, según el tipo de bien
        /// </summary>
        private short inconsistenciaValuacionesNoTerreno;

        /// <summary>
        /// Indicador de que se presentó un error con la fecha del último seguimiento del avalúo
        /// </summary>
        private short inconsistenciaFechaUltimoSeguimiento;

        /// <summary>
        /// Indicador de que se presentó un error con la fecha de construcción del avalúo
        /// </summary>
        private short inconsistenciaFechaConstruccion;

        /// <summary>
        /// Indicador de que se presentó un error en que la fecha de valuación y el monto total del avalúo son diferentes a los del SICC
        /// </summary>
        private short inconsistenciaAvaluoDiferenteSicc;

        /// <summary>
        /// Indicador de que se presentó un error con la fecha de vencimiento de la garantía
        /// </summary>
        private short inconsistenciaFechaVencimiento;

        /// <summary>
        /// Indicador de que se presentó un error con la fecha de prescripción de la garantía
        /// </summary>
        private bool inconsistenciaFechaPrescripcion;

        /// <summary>
        /// Indicador de que se presentó un error con la validez del monto de la tasación actualizada del terreno calculado
        /// </summary>
        private short inconsistenciaValidezMontoAvaluoActualizadoTerreno;

        /// <summary>
        /// Indicador de que se presentó un error con la validez del monto de la tasación actualizada del no terreno calculado
        /// </summary>
        private short inconsistenciaValidezMontoAvaluoActualizadoNoTerreno;

        /// <summary>
        /// Indicador de que se presentó un error con el cálculo del monto de la tasación actualizada del no terreno calculado
        /// </summary>
        private short calculoMontoActualizadoTerrenoNoTerreno;

        /// <summary>
        /// Descripción del error técnico que se di con el cálculo del monto de la tasación actualizada del no terreno calculado
        /// </summary>
        private string errorTecnicoCalculoMontoActualizadoTerrenoNoTerreno;

        /// <summary>
        /// Indicador de que se presentó un error con la fecha de constitución de la garantía
        /// </summary>
        private bool inconsistenciaFechaConstitucion;

        /// <summary>
        /// Indicador de que se presentó un error con que la póliza no cubre el bien
        /// </summary>
        private bool inconsistenciaPolizaNoCubreBien;

        /// <summary>
        /// Indicador de que se presentó un error con que la garantía no posee póliza asociada
        /// </summary>
        private bool inconsistenciaGarantiaSinPoliza;

        /// <summary>
        /// Indicador de que se presentó un error con que la póliza asociada es inválida
        /// </summary>
        private bool inconsistenciaPolizaInvalida;

        /// <summary>
        /// Indicador de que se presentó un error con que la póliza está vencida
        /// </summary>
        private bool inconsistenciaPolizaVencida;

        /// <summary>
        /// Indicador de que se presentó un error con que la póliza asociada fue modificada en el SAP
        /// </summary>
        private bool inconsistenciaCambioPoliza;

        /// <summary>
        /// Indicador de que se presentó un error con que el monto de la póliza asociada fue modificado en el SAP
        /// </summary>
        private bool inconsistenciaCambioMontoPoliza;

        /// <summary>
        /// Indicador de que se presentó un error con que la fecha de vencimiento de la póliza asociada fue modificada en el SAP
        /// </summary>
        private bool inconsistenciaCambioFechaVencimiento;

        /// <summary>
        /// Indicador de que se presentó un error con que el monto de la acreencia es diferente entre las operaciones que se ven respaldada por una misma garantía
        /// </summary>
        private bool inconsistenciaMontoAcreenciaDiferente;

        /// <summary>
        /// Indicador de que se presentó un error con que el monto de la póliza es menor al monto de la última tasación del no terreno
        /// </summary>
        private bool inconsistenciaGarantiaInfraSeguro;

        /// <summary>
        /// Indicador de que se presentó un error con que el nombre del acreedor de la póliza asociada fue modificado en el SAP
        /// </summary>
        private bool inconsistenciaCambioAcreedor;

        /// <summary>
        /// Indicador de que se presentó un error con que la identificación de la póliza asociada fue modificada en el SAP
        /// </summary>
        private bool inconsistenciaCambioIdAcreedor;

        /// <summary>
        /// Indicador de que se presentó un error con que los datos del acreedor de la póliza asociada fueron modificados en el SAP
        /// </summary>
        private bool inconsistenciaCambioDatosAcreedor;

        /// <summary>
        /// Indicador de que se presentó un error con que el monto de la acreencia es mayor al monto de la póliza asociada
        /// </summary>
        private bool inconsistenciaMontoAcreenciaInvalido;

        /// <summary>
        /// Indicador de que se presentó un error con que las coberturas obligatorias no han fueron asignadas en su totalidad a la póliza
        /// </summary>
        private bool inconsistenciaCoberturasObligatoriasInvalidas;

        ///////////////////


        /// <summary>
        /// Indicador de que se presentó un error con la fecha de valuacion mayor a 5 años en relacion a la fecha del sistema
        /// </summary>
        private bool inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienUno;

        /// <summary>
        /// Indicador de que se presentó un error con la fecha de ultimo seguimiento es mayor 1 año en realacion a la fecha del sistema
        /// </summary>
        private bool inconsistenciaPorceAcepFechaSeguimientoMayorUnAnno;


        /// <summary>
        /// Indicador de que se presentó un error con la fecha de ultimo seguimiento es mayor 6 meses en realacion a la fecha del sistema   
        /// </summary>
        private bool inconsistenciaPorceAcepFechaSeguimientoMayorSeisMeses;


        /// <summary>
        /// Indicador de que se presentó un error si tiene una poliza asociada
        /// </summary>
        private bool inconsistenciaPorceAcepTipoBienUnoPolizaAsociada;

        /// <summary>
        /// Indicador de que se presentó un error no tiene poliza sociada
        /// </summary>
        private bool inconsistenciaPorceAcepNoPolizaAsociada;

        /// <summary>
        /// Indicador de que se presentó un error si tiene una poliza asociada y la fecha de vencimiento de la poliza es menor a la fecha del sistema
        /// </summary>
        private bool inconsistenciaPorceAcepPolizaFechaVencimientoMenor;

        /// <summary>
        /// Indicador de que se presentó un error con la  fecha de valuacion mayor a 5 años en relacion a la fecha del sistema
        /// </summary>
        private bool inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienTres;

        /// <summary>
        /// Indicador de que se presentó un error  con la fecha de ultimo seguimiento es mayor 1 año en realacion a la fecha del sistema
        /// </summary>
        private bool inconsistenciaPorceAcepFechaSeguimientoMayorUnAnnoBienTres;

        /// <summary>
        /// Indicador de que se presentó un error con la fecha de valuacion MAYOR A 18 MESES FECHA SISTEMA, MIENTAS NO EXISTA DIFERENCIA MAYOR A 3 MESES ENTRE FECHA SEGUIMIENTO Y FECHA DEL SISTEMA
        /// </summary>
        private bool inconsistenciaPorceAcepFechaValuacionMayorDieciochoMeses;

        /// <summary>
        /// Indicador de que se presentó un error si tiene una poliza asociada, fecha de vencimiento es mayor a la fecha del sistema y monto poliza no cubre monto ultima tasacion no terreno
        /// </summary>
        private bool inconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno;

        /// <summary>
        /// Indicador de que se presentó un error si no está relacionado en el catalogo porcentaje de aceptacion 
        /// </summary>
        private bool inconsistenciaPorceAcepTipoMitigadorNoRelacionado;

        /// <summary>
        /// Indicador de que se presentó un error cuando el porcentaje de aceptacion es mayor 
        /// </summary>
        private bool inconsistenciaPorceAcepMayorPorceAcepCalculado;

        private bool inconsistenciaPorceAcepFechaSeguimientoMenorUnAnnoBienCuatro;

        private bool inconsistenciaPorcentajeAceptacionCalculado;

        public bool InconsistenciaPorcentajeAceptacionCalculado
        {
            get { return inconsistenciaPorcentajeAceptacionCalculado; }
            set { inconsistenciaPorcentajeAceptacionCalculado = value; }
        }

        public bool InconsistenciaPorceAcepFechaSeguimientoMenorUnAnnoBienCuatro
        {
            get { return inconsistenciaPorceAcepFechaSeguimientoMenorUnAnnoBienCuatro; }
            set { inconsistenciaPorceAcepFechaSeguimientoMenorUnAnnoBienCuatro = value; }
        }

        //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
        /// <summary>
        /// Indicador de que se presentó un error con el valor del PorAcepTerreno (rango fuera de 0-100 o  mayor al % Aceptación Terreno calculado)
        /// </summary>
        private bool inconsistenciaPorceAcepTerreno;

        /// <summary>
        /// Indicador de que se presentó un error con el valor del PorAcepNoTerreno (rango fuera de 0-100 o  mayor al % Aceptación No Terreno calculado)
        /// </summary>
        private bool inconsistenciaPorceAcepNoTerreno;

        ///////////////////

        //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
        private bool inconsistenciaPorcAceptTerrenoCalcNoAnotadaNoInscrita;
        private bool inconsistenciaPorcAceptTerrenoCalcAnotada;
        private bool inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento;
        private bool inconsistenciaPorcAceptTerrenoCalcFechaValuacion;
        private bool inconsistenciaPorceAcepTerrenoMayorPorceAcepCalculado;

        private bool inconsistenciaPorcAceptNoTerrenoCalcNoAnotadaNoInscrita;
        private bool inconsistenciaPorcAceptNoTerrenoCalcAnotada;
        private bool inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento;
        private bool inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo;
        private bool inconsistenciaPorcAceptNoTerrenoCalcFechaValuacion;
        private bool inconsistenciaPorceAcepNoTerrenoMayorPorceAcepCalculado;

        
        #endregion Inconsistencias

        #region Generales

        /// <summary>
        /// Indicador de que se presentó un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Indicador de que se presentó un error al aplicar las validaciones
        /// </summary>
        private bool errorValidaciones;

        /// <summary>
        /// Descripción del error detectado
        /// </summary>
        private string descripcionError;

        /// <summary>
        /// Indicador que determina si se debe presentar el error mediante la ventana emergente o no
        /// </summary>
        private bool desplegarErrorVentanaEmergente;

        /// <summary>
        /// Lista de errores que se deben desplegar debido a la aplicación de las validaciones
        /// </summary>
        private SortedDictionary<int, string> listaErroresValidaciones;

        /// <summary>
        /// Número de operación, bajo el formato Contabilidad - Oficina - Moneda - Producto - Num Operación / Num. Contrato
        /// </summary>
        private string operacion;

        /// <summary>
        /// Número de garantía, bajo el formato Partido - Finca / Clase - Placa
        /// </summary>
        private string garantia;

        /// <summary>
        /// Lista de los campos de la tabla Garantías que fueron modificados 
        /// </summary>
        private Dictionary<string, string> listaDatosModificadosGarantias;

        /// <summary>
        /// Lista de los campos de la tabla Garantías por Operación que fueron modificados 
        /// </summary>
        private Dictionary<string, string> listaDatosModificadosGarXOper;

        /// <summary>
        /// Lista de los campos de la tabla Valuaciones Reales que fueron modificados 
        /// </summary>
        private Dictionary<string, string> listaDatosModificadosGarValuacionesReales;

        /// <summary>
        /// Trama que se obtiene al realizar la carga de datos
        /// </summary>
        private string tramaInicial;

        /// <summary>
        /// Lista de los campos que pertenecen a la tabla de garantías
        /// </summary>
        private List<string> listaCamposGarantias = new List<string>();

        /// <summary>
        /// Lista de los campos que pertenencen a la tabla de la relación entre la garantía y la operación
        /// </summary>
        private List<string> listaCamposGarantiaOperacion = new List<string>();

        /// <summary>
        /// Lista de los campos que pertenencen a la tabla del avalúo de la garantía
        /// </summary>
        private List<string> listaCamposAvaluoGarantia = new List<string>();

        /// <summary>
        /// Lista de las descripciones de los valores iniciales de los combos
        /// </summary>
        private Dictionary<string, string> listaDescripcionValoresAnterioresCombos;

        /// <summary>
        /// Lista de las descripciones de los valores actuales de los combos
        /// </summary>
        private Dictionary<string, string> listaDescripcionValoresActualesCombos;

        /// <summary>
        /// Lista de mensajes informativos que se deben desplegar debido a la aplicación de las validaciones
        /// </summary>
        private SortedDictionary<int, string> listaMensajesValidaciones;

        /// <summary>
        /// Lista de los campos que pertenencen a la tabla del pólizas relacionadas de la garantía
        /// </summary>
        private List<string> listaCamposPolizaGarantia = new List<string>();

        /// <summary>
        /// Lista de los campos de la tabla Polizas Relacionadas que fueron modificados 
        /// </summary>
        private Dictionary<string, string> listaDatosModificadosGarPoliza;

        /// <summary>
        /// Lista de los campos de la tabla Polizas Relacionadas que serán insertados 
        /// </summary>
        private Dictionary<string, string> listaDatosInsertadosGarPoliza;

        /// <summary>
        /// Lista de los campos de la tabla Polizas Relacionadas que serán eliminados
        /// </summary>
        private Dictionary<string, string> listaDatosEliminadosGarPoliza;

        /// <summary>
        /// Indicador de que se presentó un error de datos requeridos
        /// </summary>
        private bool errorDatosRequeridos;

        #endregion Generales

        #region Operaciones Relacionadas

        /// <summary>
        /// Operaciones en las que participa la garantía consultada
        /// </summary>
        private clsOperacionesCrediticias<clsOperacionCrediticia> operacionesCrediticias;

        /// <summary>
        /// Mensaje que se le despliega al usuario, cuando la garantía está asociada a más de una operación
        /// </summary>
        private string mensajeDatosAvaluosInvalidos = "<script type=\"text/javascript\" language=\"javascript\">MostrarErrorDatosAvaluoInvalidos('@1', '@2');</script>";

        #endregion Operaciones Relacionadas

        #region Parámetros del cálculo

        /// <summary>
        /// Porcentaje usado para el cálculo del monto de la tasación actualizada del no terreno dentro de la cota inferior
        /// </summary>
        private decimal porcentajeLimiteInferior;

        /// <summary>
        /// Porcentaje usado para el cálculo del monto de la tasación actualizada del no terreno dentro de la cota intermedia
        /// </summary>
        private decimal porcentajeLimiteIntermedio;

        /// <summary>
        /// Porcentaje usado para el cálculo del monto de la tasación actualizada del no terreno dentro de la cota superior
        /// </summary>
        private decimal porcentajeLimiteSuperior;

        /// <summary>
        /// Límite de los años que comprende la cota inferior del cálculo del monto de la tasación actualizada del no terreno 
        /// </summary>
        private short annosLimiteInferior;

        /// <summary>
        /// Límite de los años que comprende la cota intermedia del cálculo del monto de la tasación actualizada del no terreno 
        /// </summary>
        private short annosLimiteIntermedio;

        #endregion Parámetros del cálculo

        #region Manipulación de Controles Web

        private Dictionary<int, bool> listaControlesWeb;

        #endregion Manipulación de Controles Web

        #region Cálculo del MTAT y MTANT

        /// <summary>
        /// Lista de semestres que deben ser calculados para traer al presente los montos de las tasaciones actualizadas del terreno y no terreno
        /// </summary>
        private clsSemestres<clsSemestre> listaSemestresCalcular;

        #endregion Cálculo del MTAT y MTANT

        #region Pólizas SAP

        /// <summary>
        /// Lista de pólizas SAP que están asociadas a la operación a la cual está relacionada la garantía real 
        /// </summary>
        private clsPolizasSap<clsPolizaSap> polizasSap;

        /// <summary>
        /// Póliza SAP asignada a la garantía
        /// </summary>
        private clsPolizaSap polizaSapAsociada;

        /// <summary>
        /// Mensaje que se le despliega al usuario, cuando la garantía está asociada a más de una operación y la póliza no cubre el valor del no terreno 
        /// </summary>
        private string mensajeGarantiaInfraSeguro = "<script type=\"text/javascript\" language=\"javascript\">MostrarErrorInfraSeguros('@1', '@2');</script>";

        /// <summary>
        /// Mensaje que se le despliega al usuario, cuando la garantía está asociada a más de una operación y los montos de acreencia son diferentes
        /// </summary>
        private string mensajeMontoAcreenciaDiferente = "<script type=\"text/javascript\" language=\"javascript\">MostrarErrorMontoAcreenciaDiferente('@1', '@2');</script>";

        /// <summary>
        /// Indica si se debe mostrar o no el mensaje correspondiente al problema de la realción entre el tipo de bien y el tipo de póliza SAP
        /// </summary>
        private bool mostrarErrorRelacionTipoBienTipoPolizaSap;

        #endregion Pólizas SAP

        #endregion Variables

        #region Constantes

        //Nombre tablas
        public const string _entidadGarantiaReal = "GAR_GARANTIA_REAL";
        public const string _entidadGarantiaRealXOperacion = "GAR_GARANTIAS_REALES_X_OPERACION";
        public const string _entidadValuacionesReales = "GAR_VALUACIONES_REALES";
        public const string _entidadPolizasRelaciondas = "GAR_POLIZAS_RELACIONADAS";

        //Tags importantes de la trama
        private const string _tagDatos = "DATOS";
        private const string _tagOperacion = "OPERACION";
        private const string _tagGarantia = "GARANTIA";
        private const string _tagInconsistencias = "INCONSISTENCIAS";
        private const string _tagOperacionesAsociadas = "OPERACIONES_ASOCIADAS";
        private const string _tagAvaluoReciente = "AVALUO_MAS_RECIENTE";
        private const string _tagAvaluoSICC = "AVALUO_SICC";
        private const string _tagParametrosCalculo = "PARAM_CALCULO";
        private const string _tagSemestresACalcular = "SEMESTRES_A_CALCULAR";
        private const string _tagSemestre = "SEMESTRE";
        private const string _tagPolizas = "POLIZAS";
        private const string _tagPoliza = "POLIZA";


        //Tags de la parte correspondiente a la operación
        private const string _codContabilidad = "cod_contabilidad";
        private const string _codOficinaOper = "cod_oficina_operacion";
        private const string _codMonedaOper = "cod_moneda_operacion";
        private const string _codProducto = "cod_producto_operacion";
        public const string _numOperacion = "num_operacion";
        public const string _tipoOperacion = "tipo_operacion";

        //Tags de la parte correspondiente a la lista de operaciones en la que participa la garantía
        private const string _contabilidad = "contabilidad";
        private const string _oficina = "oficina";
        private const string _moneda = "moneda";
        private const string _producto = "producto";
        private const string _numeroOperacion = "numeroOperacion";

        //Tags de la parte correspondiente a la garantía
        public const string _codOperacion = "cod_operacion";
        public const string _codGarantiaReal = "cod_garantia_real";
        public const string _codTipoGarantia = "cod_tipo_garantia";
        public const string _codClaseGarantia = "cod_clase_garantia";
        public const string _codTipoGarantiaReal = "cod_tipo_garantia_real";
        private const string _desTipoGarantiaReal = "des_tipo_garantia_real";
        private const string _garantiaReal = "garantia_real";
        public const string _codPartido = "cod_partido";
        public const string _numeroFinca = "numero_finca";
        public const string _codGrado = "cod_grado";
        public const string _cedulaHipotecaria = "cedula_hipotecaria";
        public const string _codClaseBien = "cod_clase_bien";
        public const string _numPlacaBien = "num_placa_bien";
        public const string _codTipoBien = "cod_tipo_bien";
        public const string _codTipoMitigador = "cod_tipo_mitigador";
        public const string _codTipoDocumentoLegal = "cod_tipo_documento_legal";
        public const string _montoMitigador = "monto_mitigador";
        public const string _codInscripcion = "cod_inscripcion";
        public const string _fechaPresentacion = "fecha_presentacion";
        public const string _porcentajeResponsabilidad = "porcentaje_responsabilidad";
        public const string _codGradoGravamen = "cod_grado_gravamen";
        public const string _codOperacionEspecial = "cod_operacion_especial";
        public const string _fechaConstitucion = "fecha_constitucion";
        public const string _fechaVencimiento = "fecha_vencimiento";
        public const string _codTipoAcreedor = "cod_tipo_acreedor";
        public const string _cedAcreedor = "ced_acreedor";
        public const string _codLiquidez = "cod_liquidez";
        public const string _codTenencia = "cod_tenencia";
        public const string _codMoneda = "cod_moneda";
        public const string _fechaPrescripcion = "fecha_prescripcion";
        public const string _codEstado = "cod_estado";
        public const string _porcentajeAceptacion = "Porcentaje_Aceptacion";
        public const string _cedulaAcreedor = "cedula_acreedor";
        private const string _desTipoBien = "des_tipo_bien";
        private const string _desTipoMitigador = "des_tipo_mitigador";
        private const string _desTipoDocumento = "des_tipo_documento";
        private const string _desTipoInscripcion = "des_tipo_inscripcion";
        private const string _desTipoGradoGravamen = "des_tipo_grado_gravamen";
        private const string _desTipoOperacionEspecial = "des_tipo_operacion_especial";
        private const string _desTipoPersona = "des_tipo_persona";
        private const string _desTipoLiquidez = "des_tipo_liquidez";
        private const string _desTipoTenencia = "des_tipo_tenencia";
        private const string _desTipoMoneda = "des_tipo_moneda";
        private const string _desTipoBienAnterior = "des_tipo_bien_anterior";
        private const string _desTipoMitigadorAnterior = "des_tipo_mitigador_anterior";
        private const string _desTipoDocumentoAnterior = "des_tipo_documento_anterior";
        private const string _desTipoInscripcionAnterior = "des_tipo_inscripcion_anterior";
        private const string _desTipoGradoGravamenAnterior = "des_tipo_grado_gravamen_anterior";
        private const string _desTipoOperacionEspecialAnterior = "des_tipo_operacion_especial_anterior";
        private const string _desTipoPersonaAnterior = "des_tipo_persona_anterior";
        private const string _desTipoLiquidezAnterior = "des_tipo_liquidez_anterior";
        private const string _desTipoTenenciaAnterior = "des_tipo_tenencia_anterior";
        private const string _desTipoMonedaAnterior = "des_tipo_moneda_anterior";
        private const string _indicadorPorcentajeResponsabilidadMaximo = "Indicador_Porcentaje_Responsabilidad_Maximo";
        private const string _indicadorCuentaContableEspecial = "Porcentaje_Aceptacion";

        public const string _usuarioInserto = "Usuario_Inserto";
        public const string _usuarioModifico = "Usuario_Modifico";
        private const string _nombreUsuarioModifico = "Nombre_Usuario_Modifico"; //PREGUNTAR
        public const string _fechaModifico = "Fecha_Modifico";
        public const string _fechaInserto = "Fecha_Inserto";
        public const string _fechaReplica = "Fecha_Replica";

        private const string _porcentajeAceptacionCalculado = "Porcentaje_Aceptacion_Calculado";
        private const string _porcentajeAceptacionCalculadoOriginal = "Porcentaje_Aceptacion_Calculado_Original";

        public const string _indicadorViviendaHabitadaDeudor = "Indicador_Vivienda_Habitada_Deudor";
        public const string _identificacionSicc = "Identificacion_Sicc";
        public const string _identificacionAlfanumericaSicc = "Identificacion_Alfanumerica_Sicc";
        public const string _fechaValuacionSicc = "Fecha_Valuacion_SICC";

        public const string _garantiaRealConsulta = "Garantia_Real";

        //Mensajes que se presentarn según la inconsistencia encontrada
        private const string _mensajeFechaPresentacion = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFechaPresentacion) !== 'undefined'){$MensajeFechaPresentacion.dialog('open');} </script>";
        private const string _mensajeIndicadorInscripcionFPFA = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeIndicadorInscripcionFPFA) !== 'undefined'){$MensajeIndicadorInscripcionFPFA.dialog('open');} </script>";
        private const string _mensajeIndicadorInscripcionFCInvalida = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeIndicadorInscripcionFCInvalida) !== 'undefined'){$MensajeIndicadorInscripcionFCInvalida.dialog('open');} </script>";
        private const string _mensajeIndicadorInscripcionInvalido = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeIndicadorInscripcionInvalido) !== 'undefined'){$MensajeIndicadorInscripcionInvalido.dialog('open');} </script>";
        private const string _mensajePartidoInvalido = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePartidoInvalido) !== 'undefined'){$MensajePartidoInvalido.dialog('open');} </script>";
        private const string _mensajeFincaInvalida = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFincaInvalida) !== 'undefined'){$MensajeFincaInvalida.dialog('open');} </script>";
        private const string _mensajeClaseGarantiaInvalida = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeClaseGarantiaInvalida) !== 'undefined'){$MensajeClaseGarantiaInvalida.dialog('open');} </script>";
        private const string _mensajeClaseGarantiaInvalida18 = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeClaseGarantia18) !== 'undefined'){$MensajeClaseGarantia18.dialog('open');} </script>";
        private const string _mensajeClaseGarantiaInvalida19 = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeClaseGarantia19) !== 'undefined'){$MensajeClaseGarantia19.dialog('open');} </script>";
        private const string _mensajeTipoBienInvalido = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeTipoBienInvalido) !== 'undefined'){$MensajeTipoBienInvalido.dialog('open');} </script>";
        private const string _mensajeTipoMitigadorInvalido = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeTipoMitigadorInvalido) !== 'undefined'){$MensajeTipoMitigadorInvalido.dialog('open');} </script>";
        private const string _mensajeTipoDocumentoLegalInvalido = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeTipoDocumentoLegalInvalido) !== 'undefined'){$MensajeTipoDocumentoLegalInvalido.dialog('open');} </script>";
        private const string _mensajeTipoDocumentoLegalInvalidoSegunGG = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeTipoDocumentoLegalInvalidoSegunGradoGravamen) !== 'undefined'){$MensajeTipoDocumentoLegalInvalidoSegunGradoGravamen.dialog('open');} </script>";
        private const string _mensajeGradoGravamenInvalido = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeGradoGravamenInvalido) !== 'undefined'){$MensajeGradoGravamenInvalido.dialog('open');} </script>";
        private const string _mensajePorcentajeAceptacionInvalido = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorcentajeAceptacionInvalido) !== 'undefined'){$MensajePorcentajeAceptacionInvalido.dialog('open');} </script>";
        private const string _mensajePorcentajeAceptacionInvalidoIndIns = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorcentajeAceptacionInvalidoIndIns) !== 'undefined'){$MensajePorcentajeAceptacionInvalidoIndIns.dialog('open');} </script>";
        private const string _mensajeFechaUltimoSeguimientoInvalida = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFechaUltimoSeguimiento) !== 'undefined'){$MensajeFechaUltimoSeguimiento.dialog('open');} </script>";
        private const string _mensajeFechaUltimoSeguimientoFaltante = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFechaUltimoSeguimientoFaltante) !== 'undefined'){$MensajeFechaUltimoSeguimientoFaltante.dialog('open');} </script>";
        private const string _mensajeFechaConstruccionInvalida = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFechaConstruccion) !== 'undefined'){$MensajeFechaConstruccion.dialog('open');} </script>";
        private const string _mensajeFechaConstruccionMayorFechaConstitucion = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFechaConstruccionMayorFechaConstitucion) !== 'undefined'){$MensajeFechaConstruccionMayorFechaConstitucion.dialog('open');} </script>";
        private const string _mensajeFechaVencimientoInvalida = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFechaVencimiento) !== 'undefined'){$MensajeFechaVencimiento.dialog('open');} </script>";
        private const string _mensajeFechaPrescripcionInvalida = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFechaPrescripcion) !== 'undefined'){$MensajeFechaPrescripcion.dialog('open');} </script>";
        private const string _mensajeFechaPrescripcionMenor = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFechaPrescripcionMenor) !== 'undefined'){$camposMensajeFechaPrescripcionMenor = '@1'; MensajeFechaPrescripcionMenor();} </script>";
        private const string _mensajeFechaPrescripcionSinCalcular = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFechaPrescripcionSinCalcular) !== 'undefined'){$MensajeFechaPrescripcionSinCalcular.dialog('open');} </script>";
        private const string _mensajeValuacionTerreno = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValuacionesTerreno) !== 'undefined'){$MensajeValuacionesTerreno.dialog('open');} </script>";
        private const string _mensajeValuacionNoTerreno = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValuacionesNoTerreno) !== 'undefined'){$MensajeValuacionesNoTerreno.dialog('open');} </script>";
        private const string _mensajeValuacionNoTerrenoFecha = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValuacionesNoTerrenoFecha) !== 'undefined'){$MensajeValuacionesNoTerrenoFecha.dialog('open');} </script>";
        private const string _mensajeFechaConstitucionInvalida = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFechaConstitucion) !== 'undefined'){$MensajeFechaConstitucion.dialog('open');} </script>";

        private const string _mensajeMontoUltimaTasacionTerrenoCero = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeMontoUltimaTasacionTerrenoCero) !== 'undefined'){$MensajeMontoUltimaTasacionTerrenoCero.dialog('open');} </script>";
        private const string _mensajeMontoUltimaTasacionNoTerrenoCero = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeMontoUltimaTasacionNoTerrenoCero) !== 'undefined'){$MensajeMontoUltimaTasacionNoTerrenoCero.dialog('open');} </script>";

        private const string _mensajeMontoMitigadorSinAvaluo = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeMontoMitigadorSinAvaluo) !== 'undefined'){$MensajeMontoMitigadorSinAvaluo.dialog('open');} </script>";
        private const string _mensajeMontoMitigadorInvalido = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeMontoMitigadorInvalido) !== 'undefined'){$MensajeMontoMitigadorInvalido.dialog('open');} </script>";
        private const string _mensajeCalculoMontoMitigadorMayor = "<script type=\"text/javascript\" language=\"javascript\">MensajeMontoMitigadorMayor(); </script>";
        private const string _mensajeCalculoMontoMitigadorMenor = "<script type=\"text/javascript\" language=\"javascript\">MensajeMontoMitigadorMenor(); </script>";
        //private const string _mensajeCalculoMontoMitigadorMayor = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeCalculoMontoMitigadorMayor) !== 'undefined'){ if(($$('btnValidarOperacion').attr(\"MMC\")).length > 0) { if($MensajeCalculoMontoMitigadorMayor.indexOf(\"@1\") > 0) { MensajeCalculoMontoMitigadorMayor.replace(\"@1\", ($$('btnValidarOperacion').attr(\"MMC\")));}  } $MensajeCalculoMontoMitigadorMayor.dialog('open');} </script>";
        //private const string _mensajeCalculoMontoMitigadorMenor = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeCalculoMontoMitigadorMenor) !== 'undefined'){ alert($MensajeCalculoMontoMitigadorMenor.innerHTML); if(($$('btnValidarOperacion').attr(\"MMC\")).length > 0) { if($MensajeCalculoMontoMitigadorMenor.indexOf(\"@1\") > 0) { MensajeCalculoMontoMitigadorMenor.replace(\"@1\", ($$('btnValidarOperacion').attr(\"MMC\")));}  } $MensajeCalculoMontoMitigadorMenor.dialog('open');} </script>";

        private const string _mensajeFechaAvaluoNoExisteSICC = "<script type=\"text/javascript\" language=\"javascript\">MensajeFechaValuacionNoExiste(); </script>";
        private const string _mensajeFechaAvaluoDiferenteSICC = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeFechaAvaluoDiferenteSICC) !== 'undefined'){$MensajeFechaAvaluoDiferenteSICC.dialog('open');} </script>";
        private const string _mensajeMontoTotalAvaluoDiferenteSICC = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeMontoTotalAvaluoDiferenteSICC) !== 'undefined'){$MensajeMontoTotalAvaluoDiferenteSICC.dialog('open');} </script>";
        private const string _mensajeMontoTotalizadoAvaluoDiferenteSICC = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeMontoTotalizadoAvaluoDiferenteSICC) !== 'undefined'){$MensajeMontoTotalizadoAvaluoDiferenteSICC.dialog('open');} </script>";
        private const string _mensajeDatosAvaluoDiferenteSICC = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeDatosAvaluoDiferenteSICC) !== 'undefined'){$MensajeDatosAvaluoDiferenteSICC.dialog('open');} </script>";

        private const string _mensajeValidezMtoAvalActTerrenoPorcMay = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValidezMtoAvalActTerrenoPorcMay) !== 'undefined'){$MensajeValidezMtoAvalActTerrenoPorcMay.dialog('open');} </script>";
        private const string _mensajeValidezMtoAvalActTerrenoPorcMen = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValidezMtoAvalActTerrenoPorcMen) !== 'undefined'){$MensajeValidezMtoAvalActTerrenoPorcMen.dialog('open');} </script>";
        private const string _mensajeValidezMtoAvalActTerrenoSinDatos = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValidezMtoAvalActTerrenoSinDatos) !== 'undefined'){$MensajeValidezMtoAvalActTerrenoSinDatos.dialog('open');} </script>";
        private const string _mensajeValidezMtoAvalActTerrenoMontosDiff = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValidezMtoAvalActTerrenoMontosDiff) !== 'undefined'){$MensajeValidezMtoAvalActTerrenoMontosDiff.dialog('open');} </script>";

        private const string _mensajeValidezMtoAvalActNoTerrenoDifSICC = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValidezMtoAvalActNoTerrenoDifSICC) !== 'undefined'){$MensajeValidezMtoAvalActNoTerrenoDifSICC.dialog('open');} </script>";
        private const string _mensajeValidezMtoAvalActNoTerrenoMontosDif = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValidezMtoAvalActNoTerrenoMontosDif) !== 'undefined'){$MensajeValidezMtoAvalActNoTerrenoMontosDif.dialog('open');} </script>";
        private const string _mensajeValidezMtoAvalActNoTerrenoSinDatos = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValidezMtoAvalActNoTerrenoSinDatos) !== 'undefined'){$MensajeValidezMtoAvalActNoTerrenoSinDatos.dialog('open');} </script>";

        private const string _mensajePolizaVencida = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePolizaVencida) !== 'undefined'){$MensajePolizaVencida.dialog('open');} </script>";
        private const string _mensajePolizaInvalida = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePolizaInvalida) !== 'undefined'){$MensajePolizaInvalida.dialog('open');} </script>";
        private const string _mensajeCambioMontoPoliza = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeCambioMontoPoliza) !== 'undefined'){$MensajeCambioMontoPoliza.dialog('open');} </script>";
        private const string _mensajeCambioAcreedorPoliza = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeCambioAcreedorPoliza) !== 'undefined'){$MensajeCambioAcreedorPoliza.dialog('open');} </script>";
        private const string _mensajeCambioCedulaAcreedorPoliza = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeCambioCedulaAcreedorPoliza) !== 'undefined'){$MensajeCambioCedulaAcreedorPoliza.dialog('open');} </script>";
        private const string _mensajeCambioDatosAcreedorPoliza = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeCambioDatosAcreedorPoliza) !== 'undefined'){$MensajeCambioDatosAcreedorPoliza.dialog('open');} </script>";
        private const string _mensajeCambioFechaVencimientoPoliza = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeCambioFechaVencimientoPoliza) !== 'undefined'){$MensajeCambioFechaVencimientoPoliza.dialog('open');} </script>";
        private const string _mensajeMontoAcreenciaInvalido = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeMontoAcreenciaDigitadoInvalido) !== 'undefined'){$MensajeMontoAcreenciaDigitadoInvalido.dialog('open');} </script>";
        private const string _mensajeMontoPolizaMenorMontoUltimaTasacionTerreno = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeMontoPolizaMenorMontoUltimaTasacionNoTerreno) !== 'undefined'){$MensajeMontoPolizaMenorMontoUltimaTasacionNoTerreno.dialog('open');} </script>";
        private const string _mensajePolizaInvalidaRelacionTipoBienPoliza = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePolizaInvalidaRelacionTipoBienPoliza) !== 'undefined'){$MensajePolizaInvalidaRelacionTipoBienPoliza.dialog('open');} </script>";

        private const string _mensajePorceAcepFechaValuacionMayorCincoAnnosBienUno = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepFechaValuacionMayorCincoAnnosBienUno) !== 'undefined'){$MensajePorceAcepFechaValuacionMayorCincoAnnosBienUno.dialog('open');} </script>";
        private const string _mensajePorceAcepFechaSeguimientoMayorUnAnno = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepFechaSeguimientoMayorUnAnno) !== 'undefined'){$MensajePorceAcepFechaSeguimientoMayorUnAnno.dialog('open');} </script>";
        private const string _mensajePorceAcepFechaSeguimientoMayorSeisMeses = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepFechaSeguimientoMayorSeisMeses) !== 'undefined'){$MensajePorceAcepFechaSeguimientoMayorSeisMeses.dialog('open');} </script>";
        private const string _mensajePorceAcepTipoBienUnoPolizaAsociada = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepTipoBienUnoPolizaAsociada) !== 'undefined'){$MensajePorceAcepTipoBienUnoPolizaAsociada.dialog('open');} </script>";
        private const string _mensajePorceAcepNoPolizaAsociada = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepNoPolizaAsociada) !== 'undefined'){$MensajePorceAcepNoPolizaAsociada.dialog('open');} </script>";
        private const string _mensajePorceAcepPolizaFechaVencimientoMenor = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepPolizaFechaVencimientoMenor) !== 'undefined'){$MensajePorceAcepPolizaFechaVencimientoMenor.dialog('open');} </script>";
        private const string _mensajePorceAcepFechaValuacionMayorCincoAnnosBienTres = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepFechaValuacionMayorCincoAnnosBienTres) !== 'undefined'){$MensajePorceAcepFechaValuacionMayorCincoAnnosBienTres.dialog('open');} </script>";
        private const string _mensajePorceAcepFechaSeguimientoMayorUnAnnoBienTres = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepFechaSeguimientoMayorUnAnnoBienTres) !== 'undefined'){$MensajePorceAcepFechaSeguimientoMayorUnAnnoBienTres.dialog('open');} </script>";
        private const string _mensajePorceAcepFechaValuacionMayorDieciochoMeses = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepFechaValuacionMayorDieciochoMeses) !== 'undefined'){$MensajePorceAcepFechaValuacionMayorDieciochoMeses.dialog('open');} </script>";
        private const string _mensajePorceAcepPolizaFechaVencimientoMontoNoTerreno = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepPolizaFechaVencimientoMontoNoTerreno) !== 'undefined'){$MensajePorceAcepPolizaFechaVencimientoMontoNoTerreno.dialog('open');} </script>";
        private const string _mensajePorceAcepTipoMitigadorNoRelacionado = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepTipoMitigadorNoRelacionado) !== 'undefined'){$MensajePorceAcepTipoMitigadorNoRelacionado.dialog('open');} </script>";

        private const string _mensajePorceAcepMayorPorceAcepCalculado = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepMayorPorceAcepCalculado) !== 'undefined'){$MensajePorceAcepMayorPorceAcepCalculado.dialog('open');} </script>";

        private const string _mensajeClaseGarantiaInvalida56 = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeClaseGarantia56) !== 'undefined'){$MensajeClaseGarantia56.dialog('open');} </script>";
        private const string _mensajeClaseGarantiaInvalida57 = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeClaseGarantia57) !== 'undefined'){$MensajeClaseGarantia57.dialog('open');} </script>";
        private const string _mensajeClaseGarantiaInvalida58 = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeClaseGarantia58) !== 'undefined'){$MensajeClaseGarantia58.dialog('open');} </script>";

        private const string _mensajeCoberturasObligatoriasInvalidas = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeCoberturasObligatoriasInvalidas) !== 'undefined'){$MensajeCoberturasObligatoriasInvalidas.dialog('open');} </script>";

        //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
        private const string _mensajePorcAceptTerrenoCalcNoAnotadaNoInscrita = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorcAceptTerrenoCalcNoAnotadaNoInscritaInvalido) !== 'undefined'){$MensajePorcAceptTerrenoCalcNoAnotadaNoInscritaInvalido.dialog('open');} </script>";
        private const string _mensajePorcAceptTerrenoCalcAnotada = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorcAceptTerrenoCalcAnotadaInvalido) !== 'undefined'){$MensajePorcAceptTerrenoCalcAnotadaInvalido.dialog('open');} </script>";
        private const string _mensajePorcAceptTerrenoCalcFechaUltimoSeguimiento = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorcAceptTerrenoCalcFechaUltimoSeguimientoInvalido) !== 'undefined'){$MensajePorcAceptTerrenoCalcFechaUltimoSeguimientoInvalido.dialog('open');} </script>";
        private const string _mensajePorcAceptTerrenoCalcFechaValuacion = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorcAceptTerrenoCalcFechaValuacionInvalido) !== 'undefined'){$MensajePorcAceptTerrenoCalcFechaValuacionInvalido.dialog('open');} </script>";
        private const string _mensajePorceAcepTerrenoMayorPorceAcepTerrenoCalculado = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepTerrenoMayorPorceAcepTerrenoCalculado) !== 'undefined'){$MensajePorceAcepTerrenoMayorPorceAcepTerrenoCalculado.dialog('open');} </script>";


        private const string _mensajePorcAceptNoTerrenoCalcNoAnotadaNoInscrita = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorcAceptNoTerrenoCalcNoAnotadaNoInscritaInvalido) !== 'undefined'){$MensajePorcAceptNoTerrenoCalcNoAnotadaNoInscritaInvalido.dialog('open');} </script>";
        private const string _mensajePorcAceptNoTerrenoCalcAnotada = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorcAceptNoTerrenoCalcAnotadaInvalido) !== 'undefined'){$MensajePorcAceptNoTerrenoCalcAnotadaInvalido.dialog('open');} </script>";
        private const string _mensajePorcAceptNoTerrenoCalcFechaUltimoSeguimiento = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorcAceptNoTerrenoCalcFechaUltimoSeguimientoInvalido) !== 'undefined'){$MensajePorcAceptNoTerrenoCalcFechaUltimoSeguimientoInvalido.dialog('open');} </script>";
        private const string _mensajePorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipoInvalido) !== 'undefined'){$MensajePorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipoInvalido.dialog('open');} </script>";
        private const string _mensajePorcAceptNoTerrenoCalcFechaValuacion = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorcAceptNoTerrenoCalcFechaValuacionInvalido) !== 'undefined'){$MensajePorcAceptNoTerrenoCalcFechaValuacionInvalido.dialog('open');} </script>";
        private const string _mensajePorceAcepNoTerrenoMayorPorceAcepNoTerrenoCalculado = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajePorceAcepNoTerrenoMayorPorceAcepNoTerrenoCalculado) !== 'undefined'){$MensajePorceAcepNoTerrenoMayorPorceAcepNoTerrenoCalculado.dialog('open');} </script>";




        //Tags referentes a la parte del avalúo más reciente
        private const string _fechaValuacion = "fecha_valuacion";
        public const string _cedulaEmpresa = "cedula_empresa";
        public const string _cedulaPerito = "cedula_perito";
        private const string _montoUltimaTasacionTerreno = "monto_ultima_tasacion_terreno";
        private const string _montoUltimaTasacionNoTerreno = "monto_ultima_tasacion_no_terreno";
        private const string _montoTasacionActualizadaTerreno = "monto_tasacion_actualizada_terreno";
        private const string _montoTasacionActualizadaNoTerreno = "monto_tasacion_actualizada_no_terreno";
        private const string _fechaUltimoSeguimiento = "fecha_ultimo_seguimiento";
        private const string _montoTotalAvaluo = "monto_total_avaluo";
        private const string _fechaConstruccion = "fecha_construccion";
        private const string _fechaPenultimoAvaluo = "penultima_fecha_valuacion";
        private const string _fechaActualBD = "fecha_actual";
        private const string _avaluoActualizado = "avaluo_actualizado";
        private const string _fechaSemestreActualizado = "fecha_semestre_actualizado";
        private const string _fechaValuacionSICC = "fecha_valuacion_sicc";

        private const string _porcentajeAceptacionBase = "Porcentaje_Aceptacion_Base";
        private const string _porcentajeAceptacionTerreno = "Porcentaje_Aceptacion_Terreno";
        private const string _porcentajeAceptacionNoTerreno = "Porcentaje_Aceptacion_No_Terreno";
        private const string _porcentajeAceptacionTerrenoCalculado = "Porcentaje_Aceptacion_Terreno_Calculado";
        private const string _porcentajeAceptacionNoTerrenoCalculado = "Porcentaje_Aceptacion_No_Terreno_Calculado";


        //Tags referentes a la parte del avalúo del SICC
        private const string _prmgtFechaValuacion = "prmgt_pfeavaing";
        private const string _prmgtMontoTotalAvaluo = "prmgt_pmoavaing";

        //Tags referentes a los parámetros usados para el cálculo del monto de la tasación actualizada del no terreno
        private const string _porcentajeLimiteInferior = "porcentaje_limite_inferior";
        private const string _porcentajeLimiteIntermedio = "porcentaje_limite_intermedio";
        private const string _porcentajeLimiteSuperior = "porcentaje_limite_superior";
        private const string _annosLimiteInferior = "annos_limite_inferior";
        private const string _annosLimiteIntermedio = "annos_limite_intermedio";
        private const string _annosLimiteSuperior = "annos_limite_superior";
        private const string _mesesPorAnno = "meses_por_anno";
        private const string _diasPorMes = "dias_por_mes";

        //Tags referentes a la trama de los semestres calculados que serán ingresados en la tabla temporal del sistema
        private const string _fechaHoraCalculo = "Fecha_Hora";
        private const string _idGarantiaCalculo = "Id_Garantia";
        private const string _tipoGarantiaRealCalculo = "Tipo_Garantia_Real";
        private const string _claseGarantiaCalculo = "Clase_Garantia";
        private const string _semestreCalculadoCalculo = "Semestre_Calculado";
        private const string _fechaValuacionCalculo = "Fecha_Valuacion";
        private const string _montoUltimaTasacionTerrenoCalculo = "Monto_Ultima_Tasacion_Terreno";
        private const string _montoUltimaTasacionNoTerrenoCalculo = "Monto_Ultima_Tasacion_No_Terreno";
        private const string _tipoCambioCalculo = "Tipo_Cambio";
        private const string _ipcCalculo = "Indice_Precios_Consumidor";
        private const string _tipoCambioAnteriorCalculo = "Tipo_Cambio_Anterior";
        private const string _ipcAnteriorCalculo = "Indice_Precios_Consumidor_Anterior";
        private const string _factorTipoCambioCalculo = "Factor_Tipo_Cambio";
        private const string _factorIpcCalculo = "Factor_IPC";
        private const string _porcentajeDepreciacionSemestralCalculo = "Porcentaje_Depreciacion_Semestral";
        private const string _montoTasacionActualizadaTerrenoCalculo = "Monto_Tasacion_Actualizada_Terreno";
        private const string _montoTasacionActualizadaNoTerrenoCalculo = "Monto_Tasacion_Actualizada_No_Terreno";
        private const string _numeroRegistroCalculo = "Numero_Registro";
        private const string _codigoOperacionCalculo = "Codigo_Operacion";
        private const string _codigoGarantiaCalculo = "Codigo_Garantia";
        private const string _tipoBienCalculo = "Tipo_Bien";
        private const string _totalSemestresCalculo = "Total_Semestres_Calcular";

        //Tags de la parte correspondiente a las pólizas
        public const string _codigoSap = "Codigo_SAP";
        private const string _tipoPoliza = "Tipo_Poliza";
        private const string _montoPoliza = "Monto_Poliza";
        private const string _monedaMontoPoliza = "Moneda_Monto_Poliza";
        private const string _fechaVencimientoPoliza = "Fecha_Vencimiento";
        private const string _cedulaAcreedorPoliza = "Cedula_Acreedor";
        private const string _nombreAcreedorPoliza = "Nombre_Acreedor";
        public const string _montoAcreencia = "Monto_Acreencia";
        private const string _detallePoliza = "Detalle_Poliza";
        private const string _polizaSeleccionada = "Poliza_Seleccionada";
        private const string _montoPolizaColonizado = "Monto_Poliza_Colonizado";
        private const string _tipoBienPoliza = "Tipo_Bien_Poliza";
        private const string _indicadorPolizaExterna = "Indicador_Poliza_Externa";
        private const string _codigoPartido = "Codigo_Partido";
        private const string _identificacionBien = "Identificacion_Bien";
        private const string _codigoTipoCobertura = "Codigo_Tipo_Cobertura";
        private const string _codigoAseguradora = "Codigo_Aseguradora";

        #endregion Constantes

        #region Constructor - Finalizador

        /// <summary>
        /// Constructor básico de la clase
        /// </summary>
        public clsGarantiaReal()
        {
            #region Operación

            codContabilidad = -1;
            codOficina = -1;
            codMonedaOper = -1;
            codProducto = -1;
            numOperacion = -1;
            tipoOperacionCred = -1;

            #endregion Operación

            #region Garantía

            codOperacion = -1;
            codGarantiaReal = -1;
            codTipoGarantia = -1;
            codClaseGarantia = -1;
            codTipoGarantiaReal = -1;
            desTipoGarantiaReal = string.Empty;
            garantiaReal = string.Empty;
            codPartido = -1;
            numeroFinca = string.Empty;
            codGrado = string.Empty;
            cedulaHipotecaria = string.Empty;
            codClaseBien = string.Empty;
            numPlacaBien = string.Empty;
            codTipoBien = -1;
            codTipoMitigador = -1;
            codTipoDocumentoLegal = -1;
            montoMitigador = 0;
            codInscripcion = -1;
            fechaPresentacion = DateTime.MinValue;
            porcentajeResponsabilidad = -1;
            codGradoGravamen = -1;
            codOperacionEspecial = -1;
            fechaConstitucion = DateTime.MinValue;
            fechaVencimiento = DateTime.MinValue;
            codTipoAcreedor = -1;
            cedAcreedor = "4000000019";
            codLiquidez = -1;
            codTenencia = -1;
            codMoneda = -1;
            fechaPrescripcion = DateTime.MinValue;
            codEstado = -1;
            fechaValuacion = DateTime.MinValue;
            montoTotalAvaluo = 0;
            desTipoBien = string.Empty;
            desTipoMitigador = string.Empty;
            desTipoDocumentoLegal = string.Empty;
            desIndicadorInscripcion = string.Empty;
            desTipoGradoGravamen = string.Empty;
            desTipoOperacionEspecial = string.Empty;
            desTipoPersonaAcreedor = string.Empty;
            desTipoLiquidez = string.Empty;
            desTipoTenencia = string.Empty;
            desTipoMoneda = string.Empty;
            desTipoBienAnterior = string.Empty;
            desTipoMitigadorAnterior = string.Empty;
            desTipoDocumentoLegalAnterior = string.Empty;
            desIndicadorInscripcionAnterior = string.Empty;
            desTipoGradoGravamenAnterior = string.Empty;
            desTipoOperacionEspecialAnterior = string.Empty;
            desTipoPersonaAcreedorAnterior = string.Empty;
            desTipoLiquidezAnterior = string.Empty;
            desTipoTenenciaAnterior = string.Empty;
            desTipoMonedaAnterior = string.Empty;

            usuarioModifico = string.Empty;
            nombreUsuarioModifico = string.Empty;
            fechaModifico = DateTime.MinValue;
            fechaInserto = DateTime.MinValue;
            fechaReplica = DateTime.MinValue;

            porcentajeAceptacionCalculado = 0;
            porcentajeAceptacionCalculadoOriginal = 0;

            indicadorViviendaHabitadaDeudor = false;

            porcentajeAceptacion = 0;

            IndicadorPorcentajeResponsabilidadMaximo = false;
            IndicadorCuentaContableEspecial = false;
            IdentificacionGarantia = -1;
            IdentificacionAlfanumericaGarantia = string.Empty;

            #endregion Garantía

            #region Avalúos

            fechaValuacion = new DateTime(1900, 01, 01);
                cedulaEmpresa = string.Empty;
                cedulaPerito = string.Empty;
                montoUltimaTasacionTerreno = 0;
                montoUltimaTasacionNoTerreno = 0;
                montoTasacionActualizadaTerreno = 0;
                montoTasacionActualizadaNoTerreno = 0;
                fechaUltimoSeguimiento = new DateTime(1900, 01, 01);
                montoTotalAvaluo = 0;
                fechaConstruccion = new DateTime(1900, 01, 01);
                fechaValuacionSICC = new DateTime(1900, 01, 01);
                fechaAvaluoSICC = new DateTime(1900, 01, 01);
                montoTotalAvaluoSICC = 0;
                fechaPenultimoAvaluo = new DateTime(1900, 01, 01);
                fechaActualBD = new DateTime(1900, 01, 01);
                avaluoActualizado = false;
                fechaSemestreCalculado = new DateTime(1900, 01, 01);
                montoTasacionActualizadaTerrenoCalculado = null;
                montoTasacionActualizadaNoTerrenoCalculado = null;

                #region RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno

                porcentajeAceptacionTerreno = 0;
                porcentajeAceptacionNoTerreno = 0;
                porcentajeAceptacionTerrenoCalculado = 0;
                porcentajeAceptacionNoTerrenoCalculado = 0;

                #endregion

                #endregion Avalúos

            #region Inconsistencias

            inconsistenciaFechaPresentacion = false;
            inconsistenciaIndicadorInscripcion = false;
            inconsistenciaMontoMitigador = -1;
            inconsistenciaPorcentajeAceptacion = false;
            inconsistenciaPartido = false;
            inconsistenciaFinca = false;
            inconsistenciaClaseGarantia = false;
            inconsistenciaTipoBien = false;
            inconsistenciaTipoMitigador = false;
            inconsistenciaTipoDocumentoLegal = false;
            inconsistenciaGradoGravamen = false;
            inconsistenciaValuacionesTerreno = false;
            inconsistenciaValuacionesNoTerreno = -1;
            inconsistenciaFechaUltimoSeguimiento = 0;
            inconsistenciaFechaConstruccion = 0;
            inconsistenciaAvaluoDiferenteSicc = 0;
            inconsistenciaFechaVencimiento = 0;
            inconsistenciaFechaPrescripcion = false;
            inconsistenciaValidezMontoAvaluoActualizadoTerreno = 0;
            inconsistenciaValidezMontoAvaluoActualizadoNoTerreno = 0;
            calculoMontoActualizadoTerrenoNoTerreno = 0;
            errorTecnicoCalculoMontoActualizadoTerrenoNoTerreno = string.Empty;
            inconsistenciaFechaConstitucion = false;
            inconsistenciaPolizaNoCubreBien = false;
            inconsistenciaGarantiaSinPoliza = false;
            inconsistenciaPolizaInvalida = false;
            inconsistenciaPolizaVencida = false;
            inconsistenciaCambioPoliza = false;
            inconsistenciaCambioMontoPoliza = false;
            inconsistenciaCambioFechaVencimiento = false;
            inconsistenciaMontoAcreenciaDiferente = false;
            inconsistenciaGarantiaInfraSeguro = false;
            inconsistenciaCambioAcreedor = false;
            inconsistenciaCambioIdAcreedor = false;
            inconsistenciaCambioDatosAcreedor = false;
            inconsistenciaMontoAcreenciaInvalido = false;

            inconsistenciaPorceAcepFechaSeguimientoMayorSeisMeses = false;
            inconsistenciaPorceAcepFechaSeguimientoMayorUnAnno = false;
            inconsistenciaPorceAcepFechaSeguimientoMayorUnAnnoBienTres = false;
            inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienUno = false;
            inconsistenciaPorceAcepNoPolizaAsociada = false;
            inconsistenciaPorceAcepPolizaFechaVencimientoMenor = false;
            inconsistenciaPorceAcepTipoBienUnoPolizaAsociada = false;
            inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienTres = false;
            inconsistenciaPorceAcepFechaValuacionMayorDieciochoMeses = false;
            inconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno = false;
            inconsistenciaPorceAcepTipoMitigadorNoRelacionado = false;
            inconsistenciaPorceAcepMayorPorceAcepCalculado = false;

            inconsistenciaPorceAcepFechaSeguimientoMenorUnAnnoBienCuatro = false;
            inconsistenciaPorcentajeAceptacionCalculado = false;

            inconsistenciaCoberturasObligatoriasInvalidas = false;

            //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
            inconsistenciaPorcAceptTerrenoCalcNoAnotadaNoInscrita = false;
            inconsistenciaPorcAceptTerrenoCalcAnotada = false;
            inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento = false;
            inconsistenciaPorcAceptTerrenoCalcFechaValuacion = false;
            inconsistenciaPorceAcepTerrenoMayorPorceAcepCalculado = false;

            inconsistenciaPorcAceptNoTerrenoCalcNoAnotadaNoInscrita = false;
            inconsistenciaPorcAceptNoTerrenoCalcAnotada = false;
            inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento = false;
            inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo = false;
            inconsistenciaPorcAceptNoTerrenoCalcFechaValuacion = false;
            inconsistenciaPorceAcepNoTerrenoMayorPorceAcepCalculado = false;


            #endregion Inconsistencias

            #region Generales

            garantia = string.Empty;
            errorDatos = false;
            errorValidaciones = false;
            descripcionError = string.Empty;
            desplegarErrorVentanaEmergente = false;
            listaErroresValidaciones = new SortedDictionary<int, string>();
            listaDatosModificadosGarantias = new Dictionary<string, string>();
            listaDatosModificadosGarXOper = new Dictionary<string, string>();
            listaDatosModificadosGarValuacionesReales = new Dictionary<string, string>();
            listaMensajesValidaciones = new SortedDictionary<int, string>();
            tramaInicial = string.Empty;
            errorDatosRequeridos = false;
            listaDatosModificadosGarPoliza = new Dictionary<string, string>();
            listaDatosInsertadosGarPoliza = new Dictionary<string, string>();
            listaDatosEliminadosGarPoliza = new Dictionary<string, string>();

            string[] listaCamposGar = { _codGarantiaReal, _codTipoGarantia, _codTipoGarantiaReal, _codClaseGarantia, _codPartido, _numeroFinca, 
                                                        _codGrado, _cedulaHipotecaria, _codClaseBien, _numPlacaBien, _codTipoBien,
                                                        _fechaModifico, _usuarioModifico, _indicadorViviendaHabitadaDeudor };
            listaCamposGarantias = new List<string>(listaCamposGar);

            string[] listaCamposGarXOper = { _codOperacion, _codGarantiaReal, _codTipoMitigador, _codTipoDocumentoLegal,  _montoMitigador, 
                                                        _codInscripcion, _fechaPresentacion, _porcentajeResponsabilidad, _codGradoGravamen, 
                                                        _codOperacionEspecial, _fechaConstitucion, _fechaVencimiento, _codTipoAcreedor, _cedAcreedor, 
                                                        _codLiquidez, _codTenencia, _codMoneda, _fechaPrescripcion, 
                                                        _codEstado,_fechaModifico, _usuarioModifico,_porcentajeAceptacionCalculado, _porcentajeAceptacion};
            listaCamposGarantiaOperacion = new List<string>(listaCamposGarXOper);

            string[] listaCamposValuacion = { _codGarantiaReal, _fechaValuacion, _cedulaEmpresa, _cedulaPerito, _montoUltimaTasacionTerreno, 
                                              _montoUltimaTasacionNoTerreno, _montoTasacionActualizadaTerreno, _montoTasacionActualizadaNoTerreno, 
                                              _fechaUltimoSeguimiento, _montoTotalAvaluo, _fechaConstruccion ,
                                              //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
                                              _porcentajeAceptacionTerreno, _porcentajeAceptacionNoTerreno, _porcentajeAceptacionNoTerrenoCalculado, _porcentajeAceptacionTerrenoCalculado,
                                              _fechaModifico, _usuarioModifico};

            listaCamposAvaluoGarantia = new List<string>(listaCamposValuacion);

            string[] listaCamposPoliza = { _codigoSap, _montoAcreencia, _fechaModifico, _usuarioModifico };
            listaCamposPolizaGarantia = new List<string>(listaCamposPoliza);

            listaDescripcionValoresActualesCombos = new Dictionary<string, string>();
            listaDescripcionValoresAnterioresCombos = new Dictionary<string, string>();

            #endregion Generales

            #region Parámetros del cálculo

            porcentajeLimiteInferior = 0;
            porcentajeLimiteIntermedio = 0;
            porcentajeLimiteSuperior = 0;
            annosLimiteInferior = 0;
            annosLimiteIntermedio = 0;

            #endregion Parámetros del cálculo

            #region Operaciones Relacionadas

            OperacionesRelacionadas = new clsOperacionesCrediticias<clsOperacionCrediticia>();

            #endregion Operaciones Relacionadas

            #region Manipulación de Controles Web

            listaControlesWeb = new Dictionary<int, bool>();

            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.FechaPresentacion), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.IndicadorInscripcion), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.MontoMitigador), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.PorcentajeAceptacion), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.TipoBien), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.TipoMitigador), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.MontoUltimaTasacionTerreno), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.MontoUltimaTasacionNoTerreno), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.FechaUltimoSeguimiento), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.FechaConstruccion), true);

            #endregion Manipulación de Controles Web

            #region Pólizas SAP

            polizasSap = new clsPolizasSap<clsPolizaSap>();
            polizaSapAsociada = null;
            mostrarErrorRelacionTipoBienTipoPolizaSap = false;

            #endregion Pólizas SAP
        }

        /// <summary>
        /// Constructor de la clase que carga los datos que posee la trama recibida
        /// </summary>
        /// <param name="tramaGarantiaReal">Trama que posee los datos de la garantía real</param>
        /// <param name="numeroOperacionCred">Número de operación, bajo el formato Contabilidad - Oficina - Moneda - Producto - Núm. Operación / Núm. Contrato</param>
        public clsGarantiaReal(string tramaGarantiaReal, string numeroOperacionCred)
        {
            #region Muestra de la trama trabajada
            /*
               <DATOS>
                  <GARANTIA>
                    <cod_operacion>19834</cod_operacion>
                    <cod_garantia_real>220265</cod_garantia_real>
                    <cod_tipo_garantia>2</cod_tipo_garantia>
                    <cod_clase_garantia>10</cod_clase_garantia>
                    <cod_tipo_garantia_real>1</cod_tipo_garantia_real>
                    <des_tipo_garantia_real>Hipoteca</des_tipo_garantia_real>
                    <garantia_real>Partido: 1 - Finca: 185101</garantia_real>
                    <cod_partido>1</cod_partido>
                    <numero_finca>185101</numero_finca>
                    <cod_grado></cod_grado>
                    <cedula_hipotecaria></cedula_hipotecaria>
                    <cod_clase_bien></cod_clase_bien>
                    <num_placa_bien></num_placa_bien>
                    <cod_tipo_bien>-1</cod_tipo_bien>
                    <cod_tipo_mitigador>-1</cod_tipo_mitigador>
                    <cod_tipo_documento_legal>-1</cod_tipo_documento_legal>
                    <monto_mitigador>46191.01</monto_mitigador>
                    <cod_inscripcion>-1</cod_inscripcion>
                    <fecha_presentacion>01/01/1900</fecha_presentacion>
                    <porcentaje_responsabilidad>100.00</porcentaje_responsabilidad>
                    <cod_grado_gravamen>1</cod_grado_gravamen>
                    <cod_operacion_especial>0</cod_operacion_especial>
                    <fecha_constitucion>26/11/2001</fecha_constitucion>
                    <fecha_vencimiento>26/11/2016</fecha_vencimiento>
                    <cod_tipo_acreedor>2</cod_tipo_acreedor>
                    <ced_acreedor>4000000019</ced_acreedor>
                    <cod_liquidez>3</cod_liquidez>
                    <cod_tenencia>4</cod_tenencia>
                    <cod_moneda>1</cod_moneda>
                    <fecha_prescripcion>26/11/2016</fecha_prescripcion>
                    <cod_estado>1</cod_estado>
                    <fecha_valuacion>26/08/2005</fecha_valuacion>
                    <monto_total_avaluo>0.0000</monto_total_avaluo>
                    <des_tipo_grado_gravamen>1-1 grado</des_tipo_grado_gravamen>
                    <des_tipo_operacion_especial>0-Normal</des_tipo_operacion_especial>
                    <des_tipo_persona>2-Persona jurdica nacional</des_tipo_persona>
                    <des_tipo_liquidez>3-Mediana liquidez</des_tipo_liquidez>
                    <des_tipo_tenencia>4-Consentidor</des_tipo_tenencia>
                    <des_tipo_moneda>1-Colones</des_tipo_moneda>
                  </GARANTIA>
                  <AVALUO_MAS_RECIENTE>
                    <fecha_valuacion>26/08/2005</fecha_valuacion>
                    <cedula_empresa></cedula_empresa>
                    <cedula_perito></cedula_perito>
                    <monto_tasacion_actualizada_no_terreno>0.0000</monto_tasacion_actualizada_no_terreno>
                    <fecha_ultimo_seguimiento>01/01/1900</fecha_ultimo_seguimiento>
                    <monto_total_avaluo>0.0000</monto_total_avaluo>
                    <fecha_construccion>01/01/1900</fecha_construccion>
                    <penultima_fecha_valuacion>26/08/2005</penultima_fecha_valuacion>
                    <fecha_actual>19/06/2013</fecha_actual>
                    <avaluo_actualizado>0</avaluo_actualizado>
                    <fecha_semestre_actualizado>01/01/1900</fecha_semestre_actualizado>
                 </AVALUO_MAS_RECIENTE>
                  <AVALUO_SICC>
                    <prmgt_pfeavaing></prmgt_pfeavaing>
                    <prmgt_pmoavaing>0.00</prmgt_pmoavaing>
                  </AVALUO_SICC>
                  <PARAM_CALCULO>
                    <porcentaje_limite_inferior>0.009</porcentaje_limite_inferior>
                    <porcentaje_limite_intermedio>0.015</porcentaje_limite_intermedio>
                    <porcentaje_limite_superior>0.030</porcentaje_limite_superior>
                    <annos_limite_inferior>10</annos_limite_inferior>
                    <annos_limite_intermedio>40</annos_limite_intermedio>
                  </PARAM_CALCULO>
                  <OPERACIONES_ASOCIADAS>
                    <OPERACION>
                      <contabilidad>1</contabilidad>
                      <oficina>500</oficina>
                      <moneda>2</moneda>
                      <producto>2</producto>
                      <numeroOperacion>900035</numeroOperacion>
                      <tipoOperacion>1</tipoOperacion>
                    </OPERACION>
                  </OPERACIONES_ASOCIADAS>
                  <SEMESTRES_A_CALCULAR>
                    <SEMESTRE>
                        <Numero_Semestre>1</Numero_Semestre>
                        <Fecha_Semestre>2013-01-11T00:00:00</Fecha_Semestre>
                        <Tipo_Cambio>492.78</Tipo_Cambio>
                        <IPC>158.74</IPC>
                        <Tipo_Cambio_Anterior>497.15</Tipo_Cambio_Anterior>
                        <IPC_Anterior>153.39</IPC_Anterior>
                        <Total_Registros>2</Total_Registros>
                    </SEMESTRE>
                    <SEMESTRE>
                        <Numero_Semestre>2</Numero_Semestre>
                        <Fecha_Semestre>2013-07-11T00:00:00</Fecha_Semestre>
                        <Tipo_Cambio>493.03</Tipo_Cambio>
                        <IPC>162.31</IPC>
                        <Tipo_Cambio_Anterior>492.78</Tipo_Cambio_Anterior>
                        <IPC_Anterior>158.74</IPC_Anterior>
                        <Total_Registros>2</Total_Registros>
                    </SEMESTRE>
                  </SEMESTRES_A_CALCULAR>
                </DATOS>

            */

            #endregion Muestra de la trama trabajada

            #region Operación

            codContabilidad = -1;
            codOficina = -1;
            codMonedaOper = -1;
            codProducto = -1;
            numOperacion = -1;
            tipoOperacionCred = -1;

            #endregion Operación

            #region Garantía

            codOperacion = -1;
            codGarantiaReal = -1;
            codTipoGarantia = -1;
            codClaseGarantia = -1;
            codTipoGarantiaReal = -1;
            desTipoGarantiaReal = string.Empty;
            garantiaReal = string.Empty;
            codPartido = -1;
            numeroFinca = string.Empty;
            codGrado = string.Empty;
            cedulaHipotecaria = string.Empty;
            codClaseBien = string.Empty;
            numPlacaBien = string.Empty;
            codTipoBien = -1;
            codTipoMitigador = -1;
            codTipoDocumentoLegal = -1;
            montoMitigador = 0;
            codInscripcion = -1;
            fechaPresentacion = DateTime.MinValue;
            porcentajeResponsabilidad = -1;
            codGradoGravamen = -1;
            codOperacionEspecial = -1;
            fechaConstitucion = DateTime.MinValue;
            fechaVencimiento = DateTime.MinValue;
            codTipoAcreedor = -1;
            cedAcreedor = "4000000019";
            codLiquidez = -1;
            codTenencia = -1;
            codMoneda = -1;
            fechaPrescripcion = DateTime.MinValue;
            codEstado = -1;
            fechaValuacion = DateTime.MinValue;
            montoTotalAvaluo = 0;
            desTipoBien = string.Empty;
            desTipoMitigador = string.Empty;
            desTipoDocumentoLegal = string.Empty;
            desIndicadorInscripcion = string.Empty;
            desTipoGradoGravamen = string.Empty;
            desTipoOperacionEspecial = string.Empty;
            desTipoPersonaAcreedor = string.Empty;
            desTipoLiquidez = string.Empty;
            desTipoTenencia = string.Empty;
            desTipoMoneda = string.Empty;
            desTipoBienAnterior = string.Empty;
            desTipoMitigadorAnterior = string.Empty;
            desTipoDocumentoLegalAnterior = string.Empty;
            desIndicadorInscripcionAnterior = string.Empty;
            desTipoGradoGravamenAnterior = string.Empty;
            desTipoOperacionEspecialAnterior = string.Empty;
            desTipoPersonaAcreedorAnterior = string.Empty;
            desTipoLiquidezAnterior = string.Empty;
            desTipoTenenciaAnterior = string.Empty;
            desTipoMonedaAnterior = string.Empty;

            usuarioModifico = string.Empty;
            nombreUsuarioModifico = string.Empty;
            fechaModifico = DateTime.MinValue;
            fechaInserto = DateTime.MinValue;
            fechaReplica = DateTime.MinValue;

            porcentajeAceptacionCalculado = 0;
            porcentajeAceptacionCalculadoOriginal = 0;

            indicadorViviendaHabitadaDeudor = false;

            porcentajeAceptacion = 0;

            IndicadorPorcentajeResponsabilidadMaximo = false;
            IndicadorCuentaContableEspecial = false;
            IdentificacionGarantia = -1;
            IdentificacionAlfanumericaGarantia = string.Empty;

            #endregion Garantía

            #region Avalúos

            fechaValuacion = new DateTime(1900, 01, 01);
            cedulaEmpresa = string.Empty;
            cedulaPerito = string.Empty;
            montoUltimaTasacionTerreno = 0;
            montoUltimaTasacionNoTerreno = 0;
            montoTasacionActualizadaTerreno = 0;
            montoTasacionActualizadaNoTerreno = 0;
            fechaUltimoSeguimiento = new DateTime(1900, 01, 01);
            montoTotalAvaluo = 0;
            fechaConstruccion = new DateTime(1900, 01, 01);
            fechaValuacionSICC = new DateTime(1900, 01, 01);
            fechaAvaluoSICC = new DateTime(1900, 01, 01);
            montoTotalAvaluoSICC = 0;
            fechaPenultimoAvaluo = new DateTime(1900, 01, 01);
            fechaActualBD = new DateTime(1900, 01, 01);
            avaluoActualizado = false;
            fechaSemestreCalculado = new DateTime(1900, 01, 01);
            montoTasacionActualizadaTerrenoCalculado = null;
            montoTasacionActualizadaNoTerrenoCalculado = null;

            #region RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno

            porcentajeAceptacionTerreno = 0;
            porcentajeAceptacionNoTerreno = 0;
            porcentajeAceptacionTerrenoCalculado = 0;
            porcentajeAceptacionNoTerrenoCalculado = 0;

            #endregion

            #endregion Avalúos

            #region Inconsistencias

            inconsistenciaFechaPresentacion = false;
            inconsistenciaIndicadorInscripcion = false;
            inconsistenciaMontoMitigador = -1;
            inconsistenciaPorcentajeAceptacion = false;
            inconsistenciaPartido = false;
            inconsistenciaFinca = false;
            inconsistenciaClaseGarantia = false;
            inconsistenciaTipoBien = false;
            inconsistenciaTipoMitigador = false;
            inconsistenciaTipoDocumentoLegal = false;
            inconsistenciaGradoGravamen = false;
            inconsistenciaValuacionesTerreno = false;
            inconsistenciaValuacionesNoTerreno = -1;
            inconsistenciaFechaUltimoSeguimiento = 0;
            inconsistenciaFechaConstruccion = 0;
            inconsistenciaAvaluoDiferenteSicc = 0;
            inconsistenciaFechaVencimiento = 0;
            inconsistenciaFechaPrescripcion = false;
            inconsistenciaValidezMontoAvaluoActualizadoTerreno = 0;
            inconsistenciaValidezMontoAvaluoActualizadoNoTerreno = 0;
            calculoMontoActualizadoTerrenoNoTerreno = 0;
            errorTecnicoCalculoMontoActualizadoTerrenoNoTerreno = string.Empty;
            inconsistenciaFechaConstitucion = false;
            inconsistenciaPolizaNoCubreBien = false;
            inconsistenciaGarantiaSinPoliza = false;
            inconsistenciaPolizaInvalida = false;
            inconsistenciaPolizaVencida = false;
            inconsistenciaCambioPoliza = false;
            inconsistenciaCambioMontoPoliza = false;
            inconsistenciaCambioFechaVencimiento = false;
            inconsistenciaMontoAcreenciaDiferente = false;
            inconsistenciaGarantiaInfraSeguro = false;
            inconsistenciaCambioAcreedor = false;
            inconsistenciaCambioIdAcreedor = false;
            inconsistenciaCambioDatosAcreedor = false;

            inconsistenciaPorceAcepFechaSeguimientoMayorSeisMeses = false;
            inconsistenciaPorceAcepFechaSeguimientoMayorUnAnno = false;
            inconsistenciaPorceAcepFechaSeguimientoMayorUnAnnoBienTres = false;
            inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienUno = false;
            inconsistenciaPorceAcepNoPolizaAsociada = false;
            inconsistenciaPorceAcepPolizaFechaVencimientoMenor = false;
            inconsistenciaPorceAcepTipoBienUnoPolizaAsociada = false;
            inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienTres = false;
            inconsistenciaPorceAcepFechaValuacionMayorDieciochoMeses = false;
            inconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno = false;
            inconsistenciaPorceAcepTipoMitigadorNoRelacionado = false;
            inconsistenciaPorceAcepMayorPorceAcepCalculado = false;

            inconsistenciaPorceAcepFechaSeguimientoMenorUnAnnoBienCuatro = false;
            inconsistenciaPorcentajeAceptacionCalculado = false;

            inconsistenciaCoberturasObligatoriasInvalidas = false;

            //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
            inconsistenciaPorcAceptTerrenoCalcNoAnotadaNoInscrita = false;
            inconsistenciaPorcAceptTerrenoCalcAnotada = false;
            inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento = false;
            inconsistenciaPorcAceptTerrenoCalcFechaValuacion = false;

            inconsistenciaPorcAceptNoTerrenoCalcNoAnotadaNoInscrita = false;
            inconsistenciaPorcAceptNoTerrenoCalcAnotada = false;
            inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento = false;
            inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo = false;
            inconsistenciaPorcAceptNoTerrenoCalcFechaValuacion = false;

            //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
            inconsistenciaPorcAceptTerrenoCalcNoAnotadaNoInscrita = false;
            inconsistenciaPorcAceptTerrenoCalcAnotada = false;
            inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento = false;
            inconsistenciaPorcAceptTerrenoCalcFechaValuacion = false;
            inconsistenciaPorceAcepTerrenoMayorPorceAcepCalculado = false;

            inconsistenciaPorcAceptNoTerrenoCalcNoAnotadaNoInscrita = false;
            inconsistenciaPorcAceptNoTerrenoCalcAnotada = false;
            inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento = false;
            inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo = false;
            inconsistenciaPorcAceptNoTerrenoCalcFechaValuacion = false;
            inconsistenciaPorceAcepNoTerrenoMayorPorceAcepCalculado = false;


            #endregion Inconsistencias

            #region Generales

            garantia = string.Empty;
            errorDatos = false;
            errorValidaciones = false;
            descripcionError = string.Empty;
            desplegarErrorVentanaEmergente = false;
            listaErroresValidaciones = new SortedDictionary<int, string>();
            listaDatosModificadosGarantias = new Dictionary<string, string>();
            listaDatosModificadosGarXOper = new Dictionary<string, string>();
            listaDatosModificadosGarValuacionesReales = new Dictionary<string, string>();
            listaMensajesValidaciones = new SortedDictionary<int, string>();
            tramaInicial = string.Empty;
            errorDatosRequeridos = false;
            listaDatosModificadosGarPoliza = new Dictionary<string, string>();
            listaDatosInsertadosGarPoliza = new Dictionary<string, string>();
            listaDatosEliminadosGarPoliza = new Dictionary<string, string>();

            string[] listaCamposGar = { _codGarantiaReal, _codTipoGarantia, _codTipoGarantiaReal, _codClaseGarantia, _codPartido, _numeroFinca, 
                                                        _codGrado, _cedulaHipotecaria, _codClaseBien, _numPlacaBien, _codTipoBien, _fechaModifico, _usuarioModifico, _indicadorViviendaHabitadaDeudor };
            listaCamposGarantias = new List<string>(listaCamposGar);

            string[] listaCamposGarXOper = { _codOperacion, _codGarantiaReal, _codTipoMitigador, _codTipoDocumentoLegal,  _montoMitigador, 
                                                        _codInscripcion, _fechaPresentacion, _porcentajeResponsabilidad, _codGradoGravamen, 
                                                        _codOperacionEspecial, _fechaConstitucion, _fechaVencimiento, _codTipoAcreedor, _cedAcreedor, 
                                                        _codLiquidez, _codTenencia, _codMoneda, _fechaPrescripcion, _codEstado,_fechaModifico, _usuarioModifico,_porcentajeAceptacionCalculado, _porcentajeAceptacion };
            listaCamposGarantiaOperacion = new List<string>(listaCamposGarXOper);

            string[] listaCamposValuacion = { _codGarantiaReal, _fechaValuacion, _cedulaEmpresa, _cedulaPerito, _montoUltimaTasacionTerreno, 
                                              _montoUltimaTasacionNoTerreno, _montoTasacionActualizadaTerreno, _montoTasacionActualizadaNoTerreno, 
                                              _fechaUltimoSeguimiento, _montoTotalAvaluo, _fechaConstruccion, _avaluoActualizado, 
                                               //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
                                              _porcentajeAceptacionTerreno, _porcentajeAceptacionNoTerreno, _porcentajeAceptacionNoTerrenoCalculado, _porcentajeAceptacionTerrenoCalculado,
                                              _fechaSemestreActualizado,_fechaModifico, _usuarioModifico  };
            listaCamposAvaluoGarantia = new List<string>(listaCamposValuacion);

            string[] listaCamposPoliza = { _codigoSap, _montoAcreencia, _fechaModifico, _usuarioModifico };
            listaCamposPolizaGarantia = new List<string>(listaCamposPoliza);

            listaDescripcionValoresActualesCombos = new Dictionary<string, string>();
            listaDescripcionValoresAnterioresCombos = new Dictionary<string, string>();

            #endregion Generales

            #region Parámetros del cálculo

            porcentajeLimiteInferior = 0;
            porcentajeLimiteIntermedio = 0;
            porcentajeLimiteSuperior = 0;
            annosLimiteInferior = 0;
            annosLimiteIntermedio = 0;

            #endregion Parámetros del cálculo

            #region Operaciones Relacionadas

            OperacionesRelacionadas = new clsOperacionesCrediticias<clsOperacionCrediticia>();

            #endregion Operaciones Relacionadas

            #region Manipulación de Controles Web

            listaControlesWeb = new Dictionary<int, bool>();

            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.FechaPresentacion), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.IndicadorInscripcion), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.MontoMitigador), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.PorcentajeAceptacion), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.TipoBien), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.TipoMitigador), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.MontoUltimaTasacionTerreno), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.MontoUltimaTasacionNoTerreno), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.FechaUltimoSeguimiento), true);
            listaControlesWeb.Add(((int)Enumeradores.ControlesWebGarantiasReales.FechaConstruccion), true);

            #endregion Manipulación de Controles Web

            #region Cálculo del MTAT y MTANT

            listaSemestresCalcular = new clsSemestres<clsSemestre>();

            #endregion Cálculo del MTAT y MTANT

            #region Pólizas SAP

            polizasSap = new clsPolizasSap<clsPolizaSap>();
            polizaSapAsociada = null;
            mostrarErrorRelacionTipoBienTipoPolizaSap = false;

            #endregion Pólizas SAP

            if (tramaGarantiaReal.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();
                string[] formatosFecha = { "yyyyMMdd", "dd/MM/yyyy" };

                try
                {
                    xmlTrama.LoadXml(tramaGarantiaReal);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Garantia, Operacion, Mensajes.ASSEMBLY);

                    StringCollection parametros = new StringCollection();
                    parametros.Add(Garantia);
                    parametros.Add(Operacion);
                    parametros.Add(("El error se da al cargar la trama: " + ex.Message));

                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                #region Operación

                if (xmlTrama.SelectSingleNode("//" + _tagOperacion) != null)
                {
                    XmlDocument xmlOperacion = new XmlDocument();

                    try
                    {
                        xmlOperacion.LoadXml(xmlTrama.SelectSingleNode("//" + _tagOperacion).OuterXml);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_OPERACION, Mensajes.ASSEMBLY);

                        StringCollection parametros = new StringCollection();
                        parametros.Add(Operacion);
                        parametros.Add(("El error se da al cargar la trama de la operación: " + ex.Message));

                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_OPERACION_DETALLE, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }

                    if (xmlOperacion != null)
                    {
                        short tipoOper;
                        short contabilidad;
                        short oficina;
                        short moneda;
                        short producto;
                        long numeroOperacion;


                        try
                        {
                            numOperacion = ((xmlOperacion.SelectSingleNode("//" + _numOperacion) != null) ? ((long.TryParse((xmlOperacion.SelectSingleNode("//" + _numOperacion).InnerText), out numeroOperacion)) ? numeroOperacion : -1) : -1);

                            codContabilidad = ((xmlOperacion.SelectSingleNode("//" + _codContabilidad) != null) ? ((short.TryParse((xmlOperacion.SelectSingleNode("//" + _codContabilidad).InnerText), out contabilidad)) ? contabilidad : (short)-1) : (short)-1);
                            codOficina = ((xmlOperacion.SelectSingleNode("//" + _codOficinaOper) != null) ? ((short.TryParse((xmlOperacion.SelectSingleNode("//" + _codOficinaOper).InnerText), out oficina)) ? oficina : (short)-1) : (short)-1);
                            codMonedaOper = ((xmlOperacion.SelectSingleNode("//" + _codMonedaOper) != null) ? ((short.TryParse((xmlOperacion.SelectSingleNode("//" + _codMonedaOper).InnerText), out moneda)) ? moneda : (short)-1) : (short)-1);
                            codProducto = ((xmlOperacion.SelectSingleNode("//" + _codProducto) != null) ? ((short.TryParse((xmlOperacion.SelectSingleNode("//" + _codProducto).InnerText), out producto)) ? producto : (short)-1) : (short)-1);
                            tipoOperacionCred = ((xmlOperacion.SelectSingleNode("//" + _tipoOperacion) != null) ? ((short.TryParse((xmlOperacion.SelectSingleNode("//" + _tipoOperacion).InnerText), out tipoOper)) ? tipoOper : (short)-1) : (short)-1);
                        }
                        catch (Exception ex)
                        {
                            errorDatos = true;
                            descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_OPERACION, Mensajes.ASSEMBLY);

                            StringCollection parametros = new StringCollection();
                            parametros.Add(Operacion);
                            parametros.Add(("El error se da al cargar la trama de la operación: " + ex.Message));

                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_OPERACION_DETALLE, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                            return;
                        }

                    }
                }

                #endregion Operación

                #region Garantía

                if (xmlTrama.SelectSingleNode("//" + _tagGarantia) != null)
                {
                    XmlDocument xmlGarantia = new XmlDocument();

                    try
                    {
                        xmlGarantia.LoadXml(xmlTrama.SelectSingleNode("//" + _tagGarantia).OuterXml);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Garantia, Operacion, Mensajes.ASSEMBLY);

                        StringCollection parametros = new StringCollection();
                        parametros.Add(Garantia);
                        parametros.Add(Operacion);
                        parametros.Add(("El error se da al cargar la trama de la garantía: " + ex.Message));

                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }

                    if (xmlGarantia != null)
                    {
                        long idOperacion;
                        long idGarantiaReal;
                        short tipoGarantia;
                        short claseGarantia;
                        short tipoGarantiaReal;
                        short partido;
                        short tipoBien;
                        short tipoMitigador;
                        short tipoDocumentoLegal;
                        short indicadorInscripcion;
                        short gradoGravamen;
                        short operacionEspecial;
                        short tipoAcreedor;
                        short liquidez;
                        short tenencia;
                        short moneda;
                        short estado;
                        decimal monMitigador;
                        decimal porResponsabilidad;
                        decimal monTotalAvaluo;
                        DateTime fecPresentacion;
                        DateTime fecConstitucion;
                        DateTime fecVencimiento;
                        DateTime fecPrescripcion;
                        DateTime fecValuacion;

                        DateTime fecModifico;
                        DateTime fecInserto;
                        DateTime fecReplica;

                        decimal porcAcepCalculado;
                        decimal porcAcepCalculadoOriginal;
                        decimal porcAceptacion;

                        try
                        {
                            codOperacion = ((xmlGarantia.SelectSingleNode("//" + _codOperacion) != null) ? ((long.TryParse((xmlGarantia.SelectSingleNode("//" + _codOperacion).InnerText), out idOperacion)) ? idOperacion : -1) : -1);
                            codGarantiaReal = ((xmlGarantia.SelectSingleNode("//" + _codGarantiaReal) != null) ? ((long.TryParse((xmlGarantia.SelectSingleNode("//" + _codGarantiaReal).InnerText), out idGarantiaReal)) ? idGarantiaReal : -1) : -1);

                            codTipoGarantia = ((xmlGarantia.SelectSingleNode("//" + _codTipoGarantia) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codTipoGarantia).InnerText), out tipoGarantia)) ? tipoGarantia : (short)-1) : (short)-1);
                            codClaseGarantia = ((xmlGarantia.SelectSingleNode("//" + _codClaseGarantia) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codClaseGarantia).InnerText), out claseGarantia)) ? claseGarantia : (short)-1) : (short)-1);
                            codTipoGarantiaReal = ((xmlGarantia.SelectSingleNode("//" + _codTipoGarantiaReal) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codTipoGarantiaReal).InnerText), out tipoGarantiaReal)) ? tipoGarantiaReal : (short)-1) : (short)-1);
                            codPartido = ((xmlGarantia.SelectSingleNode("//" + _codPartido) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codPartido).InnerText), out partido)) ? partido : (short)-1) : (short)-1);
                            codTipoBien = ((xmlGarantia.SelectSingleNode("//" + _codTipoBien) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codTipoBien).InnerText), out tipoBien)) ? tipoBien : (short)-1) : (short)-1);
                            codTipoMitigador = ((xmlGarantia.SelectSingleNode("//" + _codTipoMitigador) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codTipoMitigador).InnerText), out tipoMitigador)) ? tipoMitigador : (short)-1) : (short)-1);
                            codTipoDocumentoLegal = ((xmlGarantia.SelectSingleNode("//" + _codTipoDocumentoLegal) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codTipoDocumentoLegal).InnerText), out tipoDocumentoLegal)) ? tipoDocumentoLegal : (short)-1) : (short)-1);
                            codInscripcion = ((xmlGarantia.SelectSingleNode("//" + _codInscripcion) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codInscripcion).InnerText), out indicadorInscripcion)) ? indicadorInscripcion : (short)-1) : (short)-1);
                            codGradoGravamen = ((xmlGarantia.SelectSingleNode("//" + _codGradoGravamen) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codGradoGravamen).InnerText), out gradoGravamen)) ? gradoGravamen : (short)-1) : (short)-1);
                            codOperacionEspecial = ((xmlGarantia.SelectSingleNode("//" + _codOperacionEspecial) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codOperacionEspecial).InnerText), out operacionEspecial)) ? operacionEspecial : (short)-1) : (short)-1);
                            codTipoAcreedor = ((xmlGarantia.SelectSingleNode("//" + _codTipoAcreedor) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codTipoAcreedor).InnerText), out tipoAcreedor)) ? tipoAcreedor : (short)-1) : (short)-1);
                            codLiquidez = ((xmlGarantia.SelectSingleNode("//" + _codLiquidez) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codLiquidez).InnerText), out liquidez)) ? liquidez : (short)-1) : (short)-1);
                            codTenencia = ((xmlGarantia.SelectSingleNode("//" + _codTenencia) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codTenencia).InnerText), out tenencia)) ? tenencia : (short)-1) : (short)-1);
                            codMoneda = ((xmlGarantia.SelectSingleNode("//" + _codMoneda) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codMoneda).InnerText), out moneda)) ? moneda : (short)-1) : (short)-1);
                            codEstado = ((xmlGarantia.SelectSingleNode("//" + _codEstado) != null) ? ((short.TryParse((xmlGarantia.SelectSingleNode("//" + _codEstado).InnerText), out estado)) ? estado : (short)-1) : (short)-1);

                            montoMitigador = ((xmlGarantia.SelectSingleNode("//" + _montoMitigador) != null) ? ((decimal.TryParse((xmlGarantia.SelectSingleNode("//" + _montoMitigador).InnerText), out monMitigador)) ? monMitigador : 0) : 0);
                            porcentajeResponsabilidad = ((xmlGarantia.SelectSingleNode("//" + _porcentajeResponsabilidad) != null) ? ((decimal.TryParse((xmlGarantia.SelectSingleNode("//" + _porcentajeResponsabilidad).InnerText), out porResponsabilidad)) ? porResponsabilidad : -1) : -1);
                            montoTotalAvaluo = ((xmlGarantia.SelectSingleNode("//" + _montoTotalAvaluo) != null) ? ((decimal.TryParse((xmlGarantia.SelectSingleNode("//" + _montoTotalAvaluo).InnerText), out monTotalAvaluo)) ? monTotalAvaluo : 0) : 0);

                            fechaPresentacion = ((xmlGarantia.SelectSingleNode("//" + _fechaPresentacion) != null) ? ((DateTime.TryParseExact((xmlGarantia.SelectSingleNode("//" + _fechaPresentacion).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecPresentacion)) ? ((fecPresentacion != (new DateTime(1900, 01, 01))) ? fecPresentacion : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);
                            fechaConstitucion = ((xmlGarantia.SelectSingleNode("//" + _fechaConstitucion) != null) ? ((DateTime.TryParseExact((xmlGarantia.SelectSingleNode("//" + _fechaConstitucion).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecConstitucion)) ? ((fecConstitucion != (new DateTime(1900, 01, 01))) ? fecConstitucion : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);
                            fechaVencimiento = ((xmlGarantia.SelectSingleNode("//" + _fechaVencimiento) != null) ? ((DateTime.TryParseExact((xmlGarantia.SelectSingleNode("//" + _fechaVencimiento).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecVencimiento)) ? ((fecVencimiento != (new DateTime(1900, 01, 01))) ? fecVencimiento : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);
                            fechaPrescripcion = ((xmlGarantia.SelectSingleNode("//" + _fechaPrescripcion) != null) ? ((DateTime.TryParseExact((xmlGarantia.SelectSingleNode("//" + _fechaPrescripcion).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecPrescripcion)) ? ((fecPrescripcion != (new DateTime(1900, 01, 01))) ? fecPrescripcion : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);
                            fechaValuacion = ((xmlGarantia.SelectSingleNode("//" + _fechaValuacion) != null) ? ((DateTime.TryParseExact((xmlGarantia.SelectSingleNode("//" + _fechaValuacion).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecValuacion)) ? ((fecValuacion != (new DateTime(1900, 01, 01))) ? fecValuacion : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);

                            desTipoGarantiaReal = ((xmlGarantia.SelectSingleNode("//" + _desTipoGarantiaReal) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoGarantiaReal).InnerText : string.Empty);
                            garantiaReal = ((xmlGarantia.SelectSingleNode("//" + _garantiaReal) != null) ? xmlGarantia.SelectSingleNode("//" + _garantiaReal).InnerText : string.Empty);
                            numeroFinca = ((xmlGarantia.SelectSingleNode("//" + _numeroFinca) != null) ? xmlGarantia.SelectSingleNode("//" + _numeroFinca).InnerText : string.Empty);
                            codGrado = ((xmlGarantia.SelectSingleNode("//" + _codGrado) != null) ? xmlGarantia.SelectSingleNode("//" + _codGrado).InnerText : string.Empty);
                            cedulaHipotecaria = ((xmlGarantia.SelectSingleNode("//" + _cedulaHipotecaria) != null) ? xmlGarantia.SelectSingleNode("//" + _cedulaHipotecaria).InnerText : string.Empty);
                            codClaseBien = ((xmlGarantia.SelectSingleNode("//" + _codClaseBien) != null) ? xmlGarantia.SelectSingleNode("//" + _codClaseBien).InnerText : string.Empty);
                            numPlacaBien = ((xmlGarantia.SelectSingleNode("//" + _numPlacaBien) != null) ? xmlGarantia.SelectSingleNode("//" + _numPlacaBien).InnerText : string.Empty);
                            //cedAcreedor = ((xmlGarantia.SelectSingleNode("//" + _cedAcreedor) != null) ? xmlGarantia.SelectSingleNode("//" + _cedAcreedor).InnerText : string.Empty);

                            desTipoBien = ((xmlGarantia.SelectSingleNode("//" + _desTipoBien) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoBien).InnerText : string.Empty);
                            desTipoMitigador = ((xmlGarantia.SelectSingleNode("//" + _desTipoMitigador) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoMitigador).InnerText : string.Empty);
                            desTipoDocumentoLegal = ((xmlGarantia.SelectSingleNode("//" + _desTipoDocumento) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoDocumento).InnerText : string.Empty);
                            desIndicadorInscripcion = ((xmlGarantia.SelectSingleNode("//" + _desTipoInscripcion) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoInscripcion).InnerText : string.Empty);
                            desTipoGradoGravamen = ((xmlGarantia.SelectSingleNode("//" + _desTipoGradoGravamen) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoGradoGravamen).InnerText : string.Empty);
                            desTipoOperacionEspecial = ((xmlGarantia.SelectSingleNode("//" + _desTipoOperacionEspecial) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoOperacionEspecial).InnerText : string.Empty);
                            desTipoPersonaAcreedor = ((xmlGarantia.SelectSingleNode("//" + _desTipoPersona) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoPersona).InnerText : string.Empty);
                            desTipoLiquidez = ((xmlGarantia.SelectSingleNode("//" + _desTipoLiquidez) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoLiquidez).InnerText : string.Empty);
                            desTipoTenencia = ((xmlGarantia.SelectSingleNode("//" + _desTipoTenencia) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoTenencia).InnerText : string.Empty);
                            desTipoMoneda = ((xmlGarantia.SelectSingleNode("//" + _desTipoMoneda) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoMoneda).InnerText : string.Empty);

                            desTipoBienAnterior = ((xmlGarantia.SelectSingleNode("//" + _desTipoBienAnterior) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoBienAnterior).InnerText : string.Empty);
                            desTipoMitigadorAnterior = ((xmlGarantia.SelectSingleNode("//" + _desTipoMitigadorAnterior) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoMitigadorAnterior).InnerText : string.Empty);
                            desTipoDocumentoLegalAnterior = ((xmlGarantia.SelectSingleNode("//" + _desTipoDocumentoAnterior) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoDocumentoAnterior).InnerText : string.Empty);
                            desIndicadorInscripcionAnterior = ((xmlGarantia.SelectSingleNode("//" + _desTipoInscripcionAnterior) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoInscripcionAnterior).InnerText : string.Empty);
                            desTipoGradoGravamenAnterior = ((xmlGarantia.SelectSingleNode("//" + _desTipoGradoGravamenAnterior) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoGradoGravamenAnterior).InnerText : string.Empty);
                            desTipoOperacionEspecialAnterior = ((xmlGarantia.SelectSingleNode("//" + _desTipoOperacionEspecialAnterior) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoOperacionEspecialAnterior).InnerText : string.Empty);
                            desTipoPersonaAcreedorAnterior = ((xmlGarantia.SelectSingleNode("//" + _desTipoPersonaAnterior) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoPersonaAnterior).InnerText : string.Empty);
                            desTipoLiquidezAnterior = ((xmlGarantia.SelectSingleNode("//" + _desTipoLiquidezAnterior) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoLiquidezAnterior).InnerText : string.Empty);
                            desTipoTenenciaAnterior = ((xmlGarantia.SelectSingleNode("//" + _desTipoTenenciaAnterior) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoTenenciaAnterior).InnerText : string.Empty);
                            desTipoMonedaAnterior = ((xmlGarantia.SelectSingleNode("//" + _desTipoMonedaAnterior) != null) ? xmlGarantia.SelectSingleNode("//" + _desTipoMonedaAnterior).InnerText : string.Empty);

                            ///////////////////
                            usuarioModifico = ((xmlGarantia.SelectSingleNode("//" + _usuarioModifico) != null) ? xmlGarantia.SelectSingleNode("//" + _usuarioModifico).InnerText : string.Empty);
                            nombreUsuarioModifico = ((xmlGarantia.SelectSingleNode("//" + _nombreUsuarioModifico) != null) ? xmlGarantia.SelectSingleNode("//" + _nombreUsuarioModifico).InnerText : string.Empty);
                            fechaModifico = ((xmlGarantia.SelectSingleNode("//" + _fechaModifico) != null) ? ((DateTime.TryParse((xmlGarantia.SelectSingleNode("//" + _fechaModifico).InnerText), out fecModifico)) ? ((fecModifico != (new DateTime(1900, 01, 01))) ? fecModifico : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);
                            fechaInserto = ((xmlGarantia.SelectSingleNode("//" + _fechaInserto) != null) ? ((DateTime.TryParse((xmlGarantia.SelectSingleNode("//" + _fechaInserto).InnerText), out fecInserto)) ? ((fecInserto != (new DateTime(1900, 01, 01))) ? fecInserto : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);
                            fechaReplica = ((xmlGarantia.SelectSingleNode("//" + _fechaReplica) != null) ? ((DateTime.TryParse((xmlGarantia.SelectSingleNode("//" + _fechaReplica).InnerText), out fecReplica)) ? ((fecReplica != (new DateTime(1900, 01, 01))) ? fecReplica : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);

                            ///////////////////

                            porcentajeAceptacionCalculado = ((xmlGarantia.SelectSingleNode("//" + _porcentajeAceptacionCalculado) != null) ? ((decimal.TryParse((xmlGarantia.SelectSingleNode("//" + _porcentajeAceptacionCalculado).InnerText), out porcAcepCalculado)) ? porcAcepCalculado : 0) : 0);

                            //este campo en la consulta de la bd no existe, solo cre 
                            porcentajeAceptacionCalculadoOriginal = ((xmlGarantia.SelectSingleNode("//" + _porcentajeAceptacionCalculadoOriginal) != null) ? ((decimal.TryParse((xmlGarantia.SelectSingleNode("//" + _porcentajeAceptacionCalculadoOriginal).InnerText), out porcAcepCalculadoOriginal)) ? porcAcepCalculadoOriginal : 0) : porcentajeAceptacionCalculado);

                            indicadorViviendaHabitadaDeudor = ((xmlTrama.SelectSingleNode("//" + _indicadorViviendaHabitadaDeudor) != null) ? ((xmlTrama.SelectSingleNode("//" + _indicadorViviendaHabitadaDeudor).InnerText.CompareTo("0") == 0) ? false : true) : false);
                            ///////////////////

                            porcentajeAceptacion = ((xmlGarantia.SelectSingleNode("//" + _porcentajeAceptacion) != null) ? ((decimal.TryParse((xmlGarantia.SelectSingleNode("//" + _porcentajeAceptacion).InnerText), out porcAceptacion)) ? porcAceptacion : 0) : 0);


                            //////////////////

                            IndicadorPorcentajeResponsabilidadMaximo = ((xmlTrama.SelectSingleNode("//" + _indicadorPorcentajeResponsabilidadMaximo) != null) ? ((xmlTrama.SelectSingleNode("//" + _indicadorPorcentajeResponsabilidadMaximo).InnerText.CompareTo("0") == 0) ? false : true) : false);
                            IndicadorCuentaContableEspecial =  ((xmlTrama.SelectSingleNode("//" + _indicadorCuentaContableEspecial) != null) ? ((xmlTrama.SelectSingleNode("//" + _indicadorCuentaContableEspecial).InnerText.CompareTo("0") == 0) ? false : true) : false);


                            /////////////////

                            listaDescripcionValoresAnterioresCombos.Add(_codTipoBien, ((desTipoBienAnterior.Length > 0) ? desTipoBienAnterior : desTipoBien));
                            listaDescripcionValoresAnterioresCombos.Add(_codTipoMitigador, ((desTipoMitigadorAnterior.Length > 0) ? desTipoMitigadorAnterior : desTipoMitigador));
                            listaDescripcionValoresAnterioresCombos.Add(_codTipoDocumentoLegal, ((desTipoMitigadorAnterior.Length > 0) ? desTipoMitigadorAnterior : desTipoMitigador));
                            listaDescripcionValoresAnterioresCombos.Add(_codInscripcion, ((desIndicadorInscripcionAnterior.Length > 0) ? desIndicadorInscripcionAnterior : desIndicadorInscripcion));
                            listaDescripcionValoresAnterioresCombos.Add(_codGradoGravamen, ((desTipoGradoGravamenAnterior.Length > 0) ? desTipoGradoGravamenAnterior : desTipoGradoGravamen));
                            listaDescripcionValoresAnterioresCombos.Add(_codOperacionEspecial, ((desTipoOperacionEspecialAnterior.Length > 0) ? desTipoOperacionEspecialAnterior : desTipoOperacionEspecial));
                            listaDescripcionValoresAnterioresCombos.Add(_codTipoAcreedor, ((desTipoPersonaAcreedorAnterior.Length > 0) ? desTipoPersonaAcreedorAnterior : desTipoPersonaAcreedor));
                            listaDescripcionValoresAnterioresCombos.Add(_codLiquidez, ((desTipoLiquidezAnterior.Length > 0) ? desTipoLiquidezAnterior : desTipoLiquidez));
                            listaDescripcionValoresAnterioresCombos.Add(_codTenencia, ((desTipoTenenciaAnterior.Length > 0) ? desTipoTenenciaAnterior : desTipoTenencia));
                            listaDescripcionValoresAnterioresCombos.Add(_codMoneda, ((desTipoMonedaAnterior.Length > 0) ? desTipoMonedaAnterior : desTipoMoneda));

                            listaDescripcionValoresActualesCombos.Add(_codTipoBien, desTipoBien);
                            listaDescripcionValoresActualesCombos.Add(_codTipoMitigador, desTipoMitigador);
                            listaDescripcionValoresActualesCombos.Add(_codTipoDocumentoLegal, desTipoDocumentoLegal);
                            listaDescripcionValoresActualesCombos.Add(_codInscripcion, desIndicadorInscripcion);
                            listaDescripcionValoresActualesCombos.Add(_codGradoGravamen, desTipoGradoGravamen);
                            listaDescripcionValoresActualesCombos.Add(_codOperacionEspecial, desTipoOperacionEspecial);
                            listaDescripcionValoresActualesCombos.Add(_codTipoAcreedor, desTipoPersonaAcreedor);
                            listaDescripcionValoresActualesCombos.Add(_codLiquidez, desTipoLiquidez);
                            listaDescripcionValoresActualesCombos.Add(_codTenencia, desTipoTenencia);
                            listaDescripcionValoresActualesCombos.Add(_codMoneda, desTipoMoneda);

                            garantia = ((garantia.Length > 0) ? garantia : garantiaReal);

                            //En caso de que el código de gravamen obtenido de la base de datos sea mayor a 3 se debe asignar 4 como máximo
                            if (codGradoGravamen > 3)
                            {
                                codGradoGravamen = 4;
                            }
                        }
                        catch (Exception ex)
                        {
                            errorDatos = true;
                            descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Garantia, Operacion, Mensajes.ASSEMBLY);

                            StringCollection parametros = new StringCollection();
                            parametros.Add(Garantia);
                            parametros.Add(Operacion);
                            parametros.Add(("El error se da al cargar los datos de la garantía: " + ex.Message));

                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                            return;
                        }

                    }
                }

                #endregion Garantía

                #region Operaciones Relacionadas

                if (xmlTrama.SelectSingleNode("//" + _tagOperacionesAsociadas) != null)
                {
                    XmlDocument xmlOperacionesRelacionadas = new XmlDocument();

                    try
                    {
                        xmlOperacionesRelacionadas.LoadXml(xmlTrama.SelectSingleNode("//" + _tagOperacionesAsociadas).OuterXml);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_OPERACIONES_ASOCIADAS, Mensajes.ASSEMBLY);

                        StringCollection parametros = new StringCollection();
                        parametros.Add(Operacion);
                        parametros.Add(("El error se da al cargar la trama de la lista de operaciones: " + ex.Message));

                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_OPERACIONES_ASOCIADAS_DETALLE, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }

                    if (xmlOperacionesRelacionadas != null)
                    {
                        clsOperacionCrediticia operacionRelacionada;
                        try
                        {
                            foreach (XmlNode nodoOperacion in xmlOperacionesRelacionadas.SelectNodes("//" + _tagOperacion))
                            {
                                if (nodoOperacion.SelectSingleNode("//" + _tagOperacion) != null)
                                {
                                    operacionRelacionada = new clsOperacionCrediticia((nodoOperacion.OuterXml));

                                    if (operacionRelacionada != null)
                                    {
                                        OperacionesRelacionadas.Agregar(operacionRelacionada);
                                    }
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            errorDatos = true;
                            descripcionError = Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_OPERACIONES_ASOCIADAS, Mensajes.ASSEMBLY);

                            StringCollection parametros = new StringCollection();
                            parametros.Add(Operacion);
                            parametros.Add(("El error se da al cargar la trama de la operación en la que participa la garantía consultada: " + ex.Message));

                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_OPERACIONES_ASOCIADAS_DETALLE, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                            return;
                        }
                    }
                }

                #endregion Operaciones Relacionadas

                #region Avalúo más reciente

                if (xmlTrama.SelectSingleNode("//" + _tagAvaluoReciente) != null)
                {
                    XmlDocument xmlAvaluo = new XmlDocument();

                    try
                    {
                        xmlAvaluo.LoadXml(xmlTrama.SelectSingleNode("//" + _tagAvaluoReciente).OuterXml);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Mensajes.ASSEMBLY);

                        StringCollection parametros = new StringCollection();
                        parametros.Add(Garantia);
                        parametros.Add(Operacion);
                        parametros.Add(("El error se da al cargar la trama del avalúo más reciente: " + ex.Message));

                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargandoAvaluoDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }

                    if (xmlAvaluo != null)
                    {
                        DateTime fecValuacion;
                        DateTime fecUS;
                        DateTime fecCons;
                        DateTime fecPenultimoAvaluo;
                        DateTime fecActualBD;
                        DateTime fecSemestreCalc;
                        DateTime fecValuacionSicc;
                        decimal montoUTT;
                        decimal montoUTNT;
                        decimal montoTAT;
                        decimal montoTANT;
                        decimal montoTA;
                        decimal porcAceptTerreno;
                        decimal porcAceptNoTerreno;
                        decimal porcAceptTerrenoCalc;
                        decimal porcAceptNoTerrenoCalc;

                        try
                        {
                            fechaValuacion = ((xmlAvaluo.SelectSingleNode("//" + _fechaValuacion) != null) ? ((DateTime.TryParseExact((xmlAvaluo.SelectSingleNode("//" + _fechaValuacion).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecValuacion)) ? fecValuacion : new DateTime(1900, 01, 01)) : new DateTime(1900, 01, 01));
                            fechaConstruccion = ((xmlAvaluo.SelectSingleNode("//" + _fechaConstruccion) != null) ? ((DateTime.TryParseExact((xmlAvaluo.SelectSingleNode("//" + _fechaConstruccion).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecCons)) ? fecCons : new DateTime(1900, 01, 01)) : new DateTime(1900, 01, 01));
                            fechaUltimoSeguimiento = ((xmlAvaluo.SelectSingleNode("//" + _fechaUltimoSeguimiento) != null) ? ((DateTime.TryParseExact((xmlAvaluo.SelectSingleNode("//" + _fechaUltimoSeguimiento).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecUS)) ? fecUS : fechaValuacion) : fechaValuacion);
                            fechaPenultimoAvaluo = ((xmlAvaluo.SelectSingleNode("//" + _fechaPenultimoAvaluo) != null) ? ((DateTime.TryParseExact((xmlAvaluo.SelectSingleNode("//" + _fechaPenultimoAvaluo).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecPenultimoAvaluo)) ? fecPenultimoAvaluo : new DateTime(1900, 01, 01)) : new DateTime(1900, 01, 01));
                            fechaActualBD = ((xmlAvaluo.SelectSingleNode("//" + _fechaActualBD) != null) ? ((DateTime.TryParseExact((xmlAvaluo.SelectSingleNode("//" + _fechaActualBD).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecActualBD)) ? fecActualBD : DateTime.Now) : DateTime.Now);
                            fechaSemestreCalculado = ((xmlAvaluo.SelectSingleNode("//" + _fechaSemestreActualizado) != null) ? ((DateTime.TryParseExact((xmlAvaluo.SelectSingleNode("//" + _fechaSemestreActualizado).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecSemestreCalc)) ? fecSemestreCalc : new DateTime(1900, 01, 01)) : new DateTime(1900, 01, 01));
                            fechaValuacionSICC = ((xmlAvaluo.SelectSingleNode("//" + _fechaValuacionSICC) != null) ? ((DateTime.TryParseExact((xmlAvaluo.SelectSingleNode("//" + _fechaValuacionSICC).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecValuacionSicc)) ? fecValuacionSicc : new DateTime(1900, 01, 01)) : new DateTime(1900, 01, 01));

                            montoUltimaTasacionTerreno = ((xmlAvaluo.SelectSingleNode("//" + _montoUltimaTasacionTerreno) != null) ? ((decimal.TryParse((xmlAvaluo.SelectSingleNode("//" + _montoUltimaTasacionTerreno).InnerText), out montoUTT)) ? montoUTT : 0) : 0);
                            montoUltimaTasacionNoTerreno = ((xmlAvaluo.SelectSingleNode("//" + _montoUltimaTasacionNoTerreno) != null) ? ((decimal.TryParse((xmlAvaluo.SelectSingleNode("//" + _montoUltimaTasacionNoTerreno).InnerText), out montoUTNT)) ? montoUTNT : 0) : 0);
                            montoTasacionActualizadaTerreno = ((xmlAvaluo.SelectSingleNode("//" + _montoTasacionActualizadaTerreno) != null) ? ((decimal.TryParse((xmlAvaluo.SelectSingleNode("//" + _montoTasacionActualizadaTerreno).InnerText), out montoTAT)) ? montoTAT : 0) : 0);
                            montoTasacionActualizadaNoTerreno = ((xmlAvaluo.SelectSingleNode("//" + _montoTasacionActualizadaNoTerreno) != null) ? ((decimal.TryParse((xmlAvaluo.SelectSingleNode("//" + _montoTasacionActualizadaNoTerreno).InnerText), out montoTANT)) ? montoTANT : 0) : 0);
                            montoTotalAvaluo = ((xmlAvaluo.SelectSingleNode("//" + _montoTotalAvaluo) != null) ? ((decimal.TryParse((xmlAvaluo.SelectSingleNode("//" + _montoTotalAvaluo).InnerText), out montoTA)) ? montoTA : 0) : 0);

                            cedulaEmpresa = ((xmlAvaluo.SelectSingleNode("//" + _cedulaEmpresa) != null) ? xmlAvaluo.SelectSingleNode("//" + _cedulaEmpresa).InnerText : string.Empty);
                            cedulaPerito = ((xmlAvaluo.SelectSingleNode("//" + _cedulaPerito) != null) ? xmlAvaluo.SelectSingleNode("//" + _cedulaPerito).InnerText : string.Empty);

                            avaluoActualizado = ((xmlAvaluo.SelectSingleNode("//" + _avaluoActualizado) != null) ? ((xmlAvaluo.SelectSingleNode("//" + _avaluoActualizado).InnerText == "1") ? true : false) : false);

                            //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno

                            porcentajeAceptacionNoTerreno = ((xmlAvaluo.SelectSingleNode("//" + _porcentajeAceptacionNoTerreno) != null) ? ((decimal.TryParse((xmlAvaluo.SelectSingleNode("//" + _porcentajeAceptacionNoTerreno).InnerText), out porcAceptNoTerreno)) ? porcAceptNoTerreno : -1) : -1);
                            porcentajeAceptacionTerreno = ((xmlAvaluo.SelectSingleNode("//" + _porcentajeAceptacionTerreno) != null) ? ((decimal.TryParse((xmlAvaluo.SelectSingleNode("//" + _porcentajeAceptacionTerreno).InnerText), out porcAceptTerreno)) ? porcAceptTerreno : -1) : -1);
                            porcentajeAceptacionNoTerrenoCalculado = ((xmlAvaluo.SelectSingleNode("//" + _porcentajeAceptacionNoTerrenoCalculado) != null) ? ((decimal.TryParse((xmlAvaluo.SelectSingleNode("//" + _porcentajeAceptacionNoTerrenoCalculado).InnerText), out porcAceptNoTerrenoCalc)) ? porcAceptNoTerrenoCalc : -1) : -1);
                            porcentajeAceptacionTerrenoCalculado = ((xmlAvaluo.SelectSingleNode("//" + _porcentajeAceptacionTerrenoCalculado) != null) ? ((decimal.TryParse((xmlAvaluo.SelectSingleNode("//" + _porcentajeAceptacionTerrenoCalculado).InnerText), out porcAceptTerrenoCalc)) ? porcAceptTerrenoCalc : -1) : -1);

                            if (HabilitarPorcentajesAceptacionAvaluo())
                            {
                                porcentajeAceptacionNoTerrenoCalculado = ((porcentajeAceptacionNoTerrenoCalculado >= 0) ? porcentajeAceptacionNoTerrenoCalculado : porcentajeAceptacionCalculado);
                                porcentajeAceptacionTerrenoCalculado = ((porcentajeAceptacionTerrenoCalculado >= 0) ? porcentajeAceptacionTerrenoCalculado : porcentajeAceptacionCalculado);
                            }
                        }
                        catch (Exception ex)
                        {
                            errorDatos = true;
                            descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Mensajes.ASSEMBLY);

                            StringCollection parametros = new StringCollection();
                            parametros.Add(Garantia);
                            parametros.Add(Operacion);
                            parametros.Add(("El error se da al cargar los datos del avalúo más reciente: " + ex.Message));

                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargandoAvaluoDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                            return;
                        }

                    }
                }


                #endregion Avalúo más reciente

                #region Avalúo del SICC

                if (xmlTrama.SelectSingleNode("//" + _tagAvaluoSICC) != null)
                {
                    XmlDocument xmlAvaluoSICC = new XmlDocument();

                    try
                    {
                        xmlAvaluoSICC.LoadXml(xmlTrama.SelectSingleNode("//" + _tagAvaluoSICC).OuterXml);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Mensajes.ASSEMBLY);

                        StringCollection parametros = new StringCollection();
                        parametros.Add(Garantia);
                        parametros.Add(Operacion);
                        parametros.Add(("El error se da al cargar la trama del avalúo registrado en el SICC: " + ex.Message));

                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargandoAvaluoDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }

                    if (xmlAvaluoSICC != null)
                    {
                        DateTime fecValuacionSICC;
                        decimal montoTASICC;


                        try
                        {
                            fechaAvaluoSICC = ((xmlAvaluoSICC.SelectSingleNode("//" + _prmgtFechaValuacion) != null) ? ((DateTime.TryParseExact((xmlAvaluoSICC.SelectSingleNode("//" + _prmgtFechaValuacion).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecValuacionSICC)) ? fecValuacionSICC : new DateTime(1900, 01, 01)) : new DateTime(1900, 01, 01));

                            montoTotalAvaluoSICC = ((xmlAvaluoSICC.SelectSingleNode("//" + _prmgtMontoTotalAvaluo) != null) ? ((decimal.TryParse((xmlAvaluoSICC.SelectSingleNode("//" + _prmgtMontoTotalAvaluo).InnerText), out montoTASICC)) ? montoTASICC : 0) : 0);
                        }
                        catch (Exception ex)
                        {
                            errorDatos = true;
                            descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Mensajes.ASSEMBLY);

                            StringCollection parametros = new StringCollection();
                            parametros.Add(Garantia);
                            parametros.Add(Operacion);
                            parametros.Add(("El error se da al cargar los datos del avalúo registrado en el SICC: " + ex.Message));

                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargandoAvaluoDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                            return;
                        }

                    }
                }

                #endregion Avalúo del SICC

                #region Parámetros del cálculo

                if (xmlTrama.SelectSingleNode("//" + _tagParametrosCalculo) != null)
                {
                    XmlDocument xmlParametrosCalculo = new XmlDocument();

                    try
                    {
                        xmlParametrosCalculo.LoadXml(xmlTrama.SelectSingleNode("//" + _tagParametrosCalculo).OuterXml);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Mensajes.ASSEMBLY);

                        StringCollection parametros = new StringCollection();
                        parametros.Add(Garantia);
                        parametros.Add(Operacion);
                        parametros.Add(("El error se da al cargar la trama de los parámetros usados para el cálculo: " + ex.Message));

                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargandoParametrosCalculoDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }

                    if (xmlParametrosCalculo != null)
                    {
                        decimal porcLimiteInferior;
                        decimal porcLimiteIntermedio;
                        decimal porcLimiteSuperior;
                        short cantidadAnnosLimiteInferior;
                        short cantidadAnnosLimiteIntermedio;

                        try
                        {
                            porcentajeLimiteInferior = ((xmlParametrosCalculo.SelectSingleNode("//" + _porcentajeLimiteInferior) != null) ? ((decimal.TryParse((xmlParametrosCalculo.SelectSingleNode("//" + _porcentajeLimiteInferior).InnerText), out porcLimiteInferior)) ? porcLimiteInferior : (short)0) : (short)0);
                            porcentajeLimiteIntermedio = ((xmlParametrosCalculo.SelectSingleNode("//" + _porcentajeLimiteIntermedio) != null) ? ((decimal.TryParse((xmlParametrosCalculo.SelectSingleNode("//" + _porcentajeLimiteIntermedio).InnerText), out porcLimiteIntermedio)) ? porcLimiteIntermedio : (short)0) : (short)0);
                            porcentajeLimiteSuperior = ((xmlParametrosCalculo.SelectSingleNode("//" + _porcentajeLimiteSuperior) != null) ? ((decimal.TryParse((xmlParametrosCalculo.SelectSingleNode("//" + _porcentajeLimiteSuperior).InnerText), out porcLimiteSuperior)) ? porcLimiteSuperior : (short)0) : (short)0);

                            annosLimiteInferior = ((xmlParametrosCalculo.SelectSingleNode("//" + _annosLimiteInferior) != null) ? ((short.TryParse((xmlParametrosCalculo.SelectSingleNode("//" + _annosLimiteInferior).InnerText), out cantidadAnnosLimiteInferior)) ? cantidadAnnosLimiteInferior : (short)0) : (short)0);
                            annosLimiteIntermedio = ((xmlParametrosCalculo.SelectSingleNode("//" + _annosLimiteIntermedio) != null) ? ((short.TryParse((xmlParametrosCalculo.SelectSingleNode("//" + _annosLimiteIntermedio).InnerText), out cantidadAnnosLimiteIntermedio)) ? cantidadAnnosLimiteIntermedio : (short)0) : (short)0);

                        }
                        catch (Exception ex)
                        {
                            errorDatos = true;
                            descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Mensajes.ASSEMBLY);

                            StringCollection parametros = new StringCollection();
                            parametros.Add(Garantia);
                            parametros.Add(Operacion);
                            parametros.Add(("El error se da al cargar la trama de los parámetros usados para el cálculo: " + ex.Message));

                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargandoParametrosCalculoDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                            return;
                        }

                    }
                }

                #endregion Parámetros del cálculo

                #region Cálculo del MTAT y MTANT

                if (xmlTrama.SelectSingleNode("//" + _tagSemestresACalcular) != null)
                {
                    XmlDocument xmlSemestresCalcular = new XmlDocument();

                    try
                    {
                        xmlSemestresCalcular.LoadXml(xmlTrama.SelectSingleNode("//" + _tagSemestresACalcular).OuterXml);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorObteniendoSemestreACalcular, Mensajes.ASSEMBLY);

                        StringCollection parametros = new StringCollection();
                        parametros.Add(Garantia);
                        parametros.Add(("El error se da al cargar la trama de la lista de semestres a calcular: " + ex.Message));

                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoSemestreACalcularDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }

                    if (xmlSemestresCalcular != null)
                    {
                        clsSemestre semestreCalcular;

                        DateTime fechaLimiteInferior;
                        DateTime fechaLimiteSuperior;

                        try
                        {
                            foreach (XmlNode nodoSemestre in xmlSemestresCalcular.SelectNodes("//" + _tagSemestre))
                            {
                                if (nodoSemestre.SelectSingleNode("//" + _tagSemestre) != null)
                                {
                                    semestreCalcular = new clsSemestre((nodoSemestre.OuterXml), false);

                                    if (semestreCalcular != null)
                                    {
                                        listaSemestresCalcular.Agregar(semestreCalcular);
                                    }
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            errorDatos = true;
                            descripcionError = Mensajes.Obtener(Mensajes._errorObteniendoSemestreACalcular, Mensajes.ASSEMBLY);

                            StringCollection parametros = new StringCollection();
                            parametros.Add(Garantia);
                            parametros.Add(("El error se da al cargar la trama de la lista de semestres a calcular: " + ex.Message));

                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoSemestreACalcularDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                            return;
                        }

                        if (((inconsistenciaAvaluoDiferenteSicc == 0) || (inconsistenciaAvaluoDiferenteSicc == 2))
                            && ((codTipoBien == 1) || (codTipoBien == 2) || (codTipoBien == -1)))
                        {
                            fechaLimiteInferior = fechaValuacionSICC.AddYears(annosLimiteInferior);
                            fechaLimiteSuperior = fechaValuacionSICC.AddYears(annosLimiteIntermedio);

                            if ((annosLimiteInferior > 0) && (annosLimiteIntermedio > 0) && (porcentajeLimiteInferior > 0)
                                && (porcentajeLimiteIntermedio > 0) && (porcentajeLimiteSuperior > 0))
                            {
                                foreach (clsSemestre semestreAjustar in listaSemestresCalcular)
                                {
                                    semestreAjustar.OperacionCrediticia = numeroOperacionCred;
                                    semestreAjustar.IdentificacionGarantia = GarantiaRealBitacora;

                                    if (semestreAjustar.FechaSemestre <= fechaLimiteInferior)
                                    {
                                        semestreAjustar.PorcentajeDepreciacion = porcentajeLimiteInferior;
                                    }
                                    else if ((semestreAjustar.FechaSemestre > fechaLimiteInferior) && (semestreAjustar.FechaSemestre <= fechaLimiteSuperior))
                                    {
                                        semestreAjustar.PorcentajeDepreciacion = porcentajeLimiteIntermedio;
                                    }
                                    else if (semestreAjustar.FechaSemestre > fechaLimiteSuperior)
                                    {
                                        semestreAjustar.PorcentajeDepreciacion = porcentajeLimiteSuperior;
                                    }
                                }
                            }
                            else
                            {
                                errorDatos = true;
                                descripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Garantia, Operacion, Mensajes.ASSEMBLY);

                                StringCollection parametros = new StringCollection();
                                parametros.Add(Garantia);
                                parametros.Add(Operacion);
                                parametros.Add("Alguno de los parámetros usados por el cálculo del monto de la tasación actualizada del terreno y no terreno calculado no fue obtenido o está mal parametrizado");

                                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, parametros,
                                                                  Mensajes.ASSEMBLY), EventLogEntryType.Error);
                            }
                        }
                    }
                }

                #endregion Cálculo del MTAT y MTANT

                #region Pólizas SAP

                if (xmlTrama.SelectSingleNode("//" + _tagPolizas) != null)
                {
                    XmlDocument xmlPolizasSap = new XmlDocument();

                    try
                    {
                        xmlPolizasSap.LoadXml(xmlTrama.SelectSingleNode("//" + _tagPolizas).OuterXml);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorObteniendoPolizasSap, Mensajes.ASSEMBLY);

                        StringCollection parametros = new StringCollection();
                        parametros.Add(Operacion);
                        parametros.Add(("El error se da al cargar la trama de las pólizas asociadas a la operación en la que participa la garantía consultada: " + ex.Message));

                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoPolizasSapDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }

                    if (xmlPolizasSap != null)
                    {
                        clsPolizaSap polizaSap;

                        try
                        {
                            foreach (XmlNode nodoPolizaSap in xmlPolizasSap.SelectNodes("//" + _tagPoliza))
                            {
                                if (nodoPolizaSap.SelectSingleNode("//" + _tagPoliza) != null)
                                {
                                    polizaSap = new clsPolizaSap((nodoPolizaSap.OuterXml));

                                    if (polizaSap != null)
                                    {
                                        polizasSap.Agregar(polizaSap);

                                        if (polizaSap.PolizaSapSeleccionada)
                                        {
                                            polizaSapAsociada = polizaSap;
                                        }
                                    }
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            errorDatos = true;
                            descripcionError = Mensajes.Obtener(Mensajes._errorObteniendoPolizasSap, Mensajes.ASSEMBLY);

                            StringCollection parametros = new StringCollection();
                            parametros.Add(Operacion);
                            parametros.Add(("El error se da al cargar la trama de las pólizas asociadas a la operación en la que participa la garantía consultada: " + ex.Message));

                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoPolizasSapDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                            return;
                        }
                    }
                }

                #endregion Pólizas SAP

                #region Inconsistencias

                if (tramaInicial.Length == 0)
                {
                    mostrarErrorRelacionTipoBienTipoPolizaSap = true;
                }

                EntidadValida(false);

                #endregion Inconsistencias

                if (tramaInicial.Length == 0)
                {
                    tramaInicial = ConvertirAXML(0);
                }
            }
        }

        #endregion Constructores - Finalizador

        #region Propiedades

        #region Operación

        /// <summary>
        /// Propiedad que obtiene y establece el código de la contabilidad
        /// </summary>
        public short Contabilidad
        {
            get { return codContabilidad; }
            set { codContabilidad = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el código de la oficina
        /// </summary>
        public short Oficina
        {
            get { return codOficina; }
            set { codOficina = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el código de la moneda de la operación
        /// </summary>
        public short MonedaOper
        {
            get { return codMonedaOper; }
            set { codMonedaOper = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el código del producto
        /// </summary>
        public short Producto
        {
            get { return codProducto; }
            set { codProducto = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el número de la operación o del contrato
        /// </summary>
        public long NumeroOperacion
        {
            get { return numOperacion; }
            set { numOperacion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el tipo de operación crediticia de la que se trata
        /// </summary>
        public short TipoOperacion
        {
            get { return tipoOperacionCred; }
            set { tipoOperacionCred = value; }
        }

        #endregion Operación

        #region Garantía

        /// <summary>
        /// Propiedad que obtiene y establece el consecutivo de la operación
        /// </summary>
        public long CodOperacion
        {
            get { return codOperacion; }
            set { codOperacion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el consecutivo de la garantía real
        /// </summary>
        public long CodGarantiaReal
        {
            get { return codGarantiaReal; }
            set { codGarantiaReal = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el tipo de garantía
        /// </summary>
        public short CodTipoGarantia
        {
            get { return codTipoGarantia; }
            set { codTipoGarantia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la clase de garantía
        /// </summary>
        public short CodClaseGarantia
        {
            get { return codClaseGarantia; }
            set { codClaseGarantia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el tipo de garantía real
        /// </summary>
        public short CodTipoGarantiaReal
        {
            get { return codTipoGarantiaReal; }
            set { codTipoGarantiaReal = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de garantía real
        /// </summary>
        public string DesTipoGarantiaReal
        {
            get { return desTipoGarantiaReal; }
            set { desTipoGarantiaReal = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el bien, en el formato Partido - Finca (o Clase de bien - Identificación del bien, según el tipo de garantía real)
        /// </summary>
        public string GarantiaReal
        {
            get { return garantiaReal; }
            set { garantiaReal = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el partido
        /// </summary>
        public short CodPartido
        {
            get { return codPartido; }
            set { codPartido = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el número de finca
        /// </summary>
        public string NumeroFinca
        {
            get { return numeroFinca; }
            set { numeroFinca = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el código del grado de la cédula hipotecaria
        /// </summary>
        public string CodGrado
        {
            get { return codGrado; }
            set { codGrado = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la cédula hipotecaria
        /// </summary>
        public string CedulaHipotecaria
        {
            get { return cedulaHipotecaria; }
            set { cedulaHipotecaria = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la clase del bien
        /// </summary>
        public string CodClaseBien
        {
            get { return codClaseBien; }
            set { codClaseBien = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el número de identificación del bien
        /// </summary>
        public string NumPlacaBien
        {
            get { return numPlacaBien; }
            set { numPlacaBien = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el tipo de bien
        /// </summary>
        public short CodTipoBien
        {
            get { return codTipoBien; }
            set { codTipoBien = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el tipo de mitigador
        /// </summary>
        public short CodTipoMitigador
        {
            get { return codTipoMitigador; }
            set { codTipoMitigador = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el tipo de documento legal
        /// </summary>
        public short CodTipoDocumentoLegal
        {
            get { return codTipoDocumentoLegal; }
            set { codTipoDocumentoLegal = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el monto mitigador
        /// </summary>
        public decimal MontoMitigador
        {
            get { return montoMitigador; }
            set { montoMitigador = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el indicador de inscripción
        /// </summary>
        public short CodInscripcion
        {
            get { return codInscripcion; }
            set { codInscripcion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la fecha de presentación
        /// </summary>
        public DateTime FechaPresentacion
        {
            get { return fechaPresentacion; }
            set { fechaPresentacion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el porcentaje de responsabilidad
        /// </summary>
        public decimal PorcentajeResponsabilidad
        {
            get { return porcentajeResponsabilidad; }
            set { porcentajeResponsabilidad = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el grado del gravamen
        /// </summary>
        public short CodGradoGravamen
        {
            get { return codGradoGravamen; }
            set { codGradoGravamen = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el código de operación especial
        /// </summary>
        public short CodOperacionEspecial
        {
            get { return codOperacionEspecial; }
            set { codOperacionEspecial = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la fecha de constitución de la garantía
        /// </summary>
        public DateTime FechaConstitucion
        {
            get { return fechaConstitucion; }
            set { fechaConstitucion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la fecha de vencimiento de la garantía
        /// </summary>
        public DateTime FechaVencimiento
        {
            get { return fechaVencimiento; }
            set { fechaVencimiento = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el tipo de persona del acreedor
        /// </summary>
        public short CodTipoAcreedor
        {
            get { return codTipoAcreedor; }
            set { codTipoAcreedor = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la identificación del acreedor
        /// </summary>
        public string CedulaAcreedor
        {
            get { return ((cedAcreedor.Length > 0) ? cedAcreedor : "4000000019"); }
            set { cedAcreedor = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el código de liquidez
        /// </summary>
        public short CodLiquidez
        {
            get { return codLiquidez; }
            set { codLiquidez = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el código de tenencia
        /// </summary>
        public short CodTenencia
        {
            get { return codTenencia; }
            set { codTenencia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el código de moneda de la garantía
        /// </summary>
        public short CodMoneda
        {
            get { return codMoneda; }
            set { codMoneda = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la fecha de prescripción de la garantía
        /// </summary>
        public DateTime FechaPrescripcion
        {
            get { return fechaPrescripcion; }
            set { fechaPrescripcion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el código de estado del registro de la garantía
        /// </summary>
        public short CodEstado
        {
            get { return codEstado; }
            set { codEstado = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de bien
        /// </summary>
        public string DescripcionTipoBien
        {
            get { return desTipoBien; }
            set { desTipoBien = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de mitigador
        /// </summary>
        public string DescripcionTipoMitigador
        {
            get { return desTipoMitigador; }
            set { desTipoMitigador = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de documento legal
        /// </summary>
        public string DescripcionTipoDocumentoLegal
        {
            get { return desTipoDocumentoLegal; }
            set { desTipoDocumentoLegal = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del indicador de inscripción
        /// </summary>
        public string DescripcionIndicadorInscripcion
        {
            get { return desIndicadorInscripcion; }
            set { desIndicadorInscripcion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de grado de gravamen
        /// </summary>
        public string DescripcionTipoGradoGravamen
        {
            get { return desTipoGradoGravamen; }
            set { desTipoGradoGravamen = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de operación especial
        /// </summary>
        public string DescripcionTipoOperacionEspecial
        {
            get { return desTipoOperacionEspecial; }
            set { desTipoOperacionEspecial = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de persona del acreedor
        /// </summary>
        public string DescripcionTipoPersonaAcreedor
        {
            get { return desTipoPersonaAcreedor; }
            set { desTipoPersonaAcreedor = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de liquidez
        /// </summary>
        public string DescripcionTipoLiquidez
        {
            get { return desTipoLiquidez; }
            set { desTipoLiquidez = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de tenencia
        /// </summary>
        public string DescripcionTipoTenencia
        {
            get { return desTipoTenencia; }
            set { desTipoTenencia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de moneda
        /// </summary>
        public string DescripcionTipoMoneda
        {
            get { return desTipoMoneda; }
            set { desTipoMoneda = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de bien anterior
        /// </summary>
        public string DescripcionTipoBienAnterior
        {
            get { return desTipoBienAnterior; }
            set { desTipoBienAnterior = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de mitigador anterior
        /// </summary>
        public string DescripcionTipoMitigadorAnterior
        {
            get { return desTipoMitigadorAnterior; }
            set { desTipoMitigadorAnterior = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de documento legal anterior
        /// </summary>
        public string DescripcionTipoDocumentoLegalAnterior
        {
            get { return desTipoDocumentoLegalAnterior; }
            set { desTipoDocumentoLegalAnterior = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del indicador de inscripción anterior
        /// </summary>
        public string DescripcionIndicadorInscripcionAnterior
        {
            get { return desIndicadorInscripcionAnterior; }
            set { desIndicadorInscripcionAnterior = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de grado de gravamen anterior
        /// </summary>
        public string DescripcionTipoGradoGravamenAnterior
        {
            get { return desTipoGradoGravamenAnterior; }
            set { desTipoGradoGravamenAnterior = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de operación especial anterior
        /// </summary>
        public string DescripcionTipoOperacionEspecialAnterior
        {
            get { return desTipoOperacionEspecialAnterior; }
            set { desTipoOperacionEspecialAnterior = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de persona del acreedor anterior
        /// </summary>
        public string DescripcionTipoPersonaAcreedorAnterior
        {
            get { return desTipoPersonaAcreedorAnterior; }
            set { desTipoPersonaAcreedorAnterior = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de liquidez anterior
        /// </summary>
        public string DescripcionTipoLiquidezAnterior
        {
            get { return desTipoLiquidezAnterior; }
            set { desTipoLiquidezAnterior = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de tenencia anterior
        /// </summary>
        public string DescripcionTipoTenenciaAnterior
        {
            get { return desTipoTenenciaAnterior; }
            set { desTipoTenenciaAnterior = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del tipo de moneda anterior
        /// </summary>
        public string DescripcionTipoMonedaAnterior
        {
            get { return desTipoMonedaAnterior; }
            set { desTipoMonedaAnterior = value; }
        }

        #region Campos Bitacora


        /// <summary>
        /// Propiedad que obtiene y establece la cedula del usuario que modifico
        /// </summary>
        public string UsuarioModifico
        {
            get { return usuarioModifico; }
            set { usuarioModifico = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el nombre del usuario que modifico
        /// </summary>
        public string NombreUsuarioModifico
        {
            get { return nombreUsuarioModifico; }
            set { nombreUsuarioModifico = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la fecha de modificación de la garantía real
        /// </summary>   
        public DateTime FechaModifico
        {
            get { return fechaModifico; }
            set { fechaModifico = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la fecha de inserción de la garantía real
        /// </summary>   
        public DateTime FechaInserto
        {
            get { return fechaInserto; }
            set { fechaInserto = value; }
        }
        /// <summary>
        /// Propiedad que obtiene y establece la fecha de replica de la garantía real
        /// </summary>   
        public DateTime FechaReplica
        {
            get { return fechaReplica; }
            set { fechaReplica = value; }
        }

        #endregion

        /// <summary>
        /// Propiedad que obtiene y establece el porcentaje aceptacion calculado
        /// </summary>
        public decimal PorcentajeAceptacionCalculado
        {
            get { return porcentajeAceptacionCalculado; }
            set { porcentajeAceptacionCalculado = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el porcentaje aceptacion calculado orignal
        /// </summary>
        public decimal PorcentajeAceptacionCalculadoOriginal
        {
            get { return porcentajeAceptacionCalculadoOriginal; }
            set { porcentajeAceptacionCalculadoOriginal = value; }
        }

        /// <summary>
        /// Propiedad que obtiene código de la garantía real que ser almacenada en la bitácora
        /// </summary>
        public string GarantiaRealBitacora
        {
            get
            {
                switch (codTipoGarantiaReal)
                {
                    case 1: garantiaRealBitacora = "[H] " + codPartido.ToString() + "-" + numeroFinca.Trim();
                        break;
                    case 2: garantiaRealBitacora = "[CH] " + codPartido.ToString() + "-" + numeroFinca.Trim();
                        break;
                    case 3: garantiaRealBitacora = "[P] " + codClaseBien + "-" + numPlacaBien.Trim();
                        break;
                    default: garantiaRealBitacora = garantiaReal;
                        break;
                }

                return garantiaRealBitacora;
            }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el indicador de que el deudor habita la vivienda
        /// </summary>
        public bool IndicadorViviendaHabitadaDeudor
        {
            get { return indicadorViviendaHabitadaDeudor; }
            set { indicadorViviendaHabitadaDeudor = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el porcentaje de aceptación
        /// </summary>
        public decimal PorcentajeAceptacion
        {
            get { return porcentajeAceptacion; }
            set { porcentajeAceptacion = value; }
        }

        public bool IndicadorPorcentajeResponsabilidadMaximo { get; set; }
        public bool IndicadorCuentaContableEspecial { get; set; }
        public long IdentificacionGarantia { get; set; }
        public string IdentificacionAlfanumericaGarantia { get; set; }

        #endregion Garantía

        #region Avalúo

        /// <summary>
        /// Propiedad que obtiene y establece la fecha de la valuación
        /// </summary>
        public DateTime FechaValuacion
        {
            get { return fechaValuacion; }
            set { fechaValuacion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la identificación de la empresa que realiza el avalúo
        /// </summary>
        public string CedulaEmpresa
        {
            get { return cedulaEmpresa; }
            set { cedulaEmpresa = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la identificación del perito que realiza el avalúo
        /// </summary>
        public string CedulaPerito
        {
            get { return cedulaPerito; }
            set { cedulaPerito = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el monto de la última tasación del terreno
        /// </summary>
        public decimal MontoUltimaTasacionTerreno
        {
            get { return montoUltimaTasacionTerreno; }
            set { montoUltimaTasacionTerreno = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el monto de la última tasación del no terreno
        /// </summary>
        public decimal MontoUltimaTasacionNoTerreno
        {
            get { return montoUltimaTasacionNoTerreno; }
            set { montoUltimaTasacionNoTerreno = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el monto de la tasación actualizada del terreno
        /// </summary>
        public decimal MontoTasacionActualizadaTerreno
        {
            get { return montoTasacionActualizadaTerreno; }
            set { montoTasacionActualizadaTerreno = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el monto de la tasación actualizada del no terreno
        /// </summary>
        public decimal MontoTasacionActualizadaNoTerreno
        {
            get { return montoTasacionActualizadaNoTerreno; }
            set { montoTasacionActualizadaNoTerreno = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la fecha de último seguimiento
        /// </summary>
        public DateTime FechaUltimoSeguimiento
        {
            get { return fechaUltimoSeguimiento; }
            set { fechaUltimoSeguimiento = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el monto total del avalúo
        /// </summary>
        public decimal MontoTotalAvaluo
        {
            get { return montoTotalAvaluo; }
            set { montoTotalAvaluo = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la fecha de construcción del bien
        /// </summary>
        public DateTime FechaConstruccion
        {
            get { return fechaConstruccion; }
            set { fechaConstruccion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene la fecha de valuación registrada en el SICC
        /// </summary>
        public DateTime FechaAvaluoSICC
        {
            get { return fechaAvaluoSICC; }
        }

        /// <summary>
        /// Propiedad que obtiene el monto total de la valuación registrada en el SICC
        /// </summary>
        public decimal MontoTotalAvaluoSICC
        {
            get { return montoTotalAvaluoSICC; }
        }

        /// <summary>
        /// Propiedad que obtiene la fecha del penúltimo avalúo asociado a la garantía
        /// </summary>
        public DateTime FechaPenultimoAvaluo
        {
            get { return fechaPenultimoAvaluo; }
        }

        /// <summary>
        /// Propiedad que obtiene la fecha actual de la base de datos
        /// </summary>
        public DateTime FechaActualBD
        {
            get { return fechaActualBD; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de si el avalúo ha sido actualizado o no
        /// </summary>
        public bool AvaluoActualizado
        {
            get { return avaluoActualizado; }
            set { avaluoActualizado = value; }
        }

        /// <summary>
        /// Obtiene o establece la fecha del último semestre calculado
        /// </summary>
        public DateTime FechaSemestreCalculado
        {
            get { return fechaSemestreCalculado; }
            set { fechaSemestreCalculado = value; }
        }

        /// <summary>
        /// Obtiene o establece el monto de la tasación actualizada del terreno calculado
        /// </summary>
        public decimal? MontoTasacionActualizadaTerrenoCalculado
        {
            get { return montoTasacionActualizadaTerrenoCalculado; }
            set { montoTasacionActualizadaTerrenoCalculado = value; }
        }

        /// <summary>
        /// Obtiene o establece el monto de la tasación actualizada del no terreno calculado
        /// </summary>
        public decimal? MontoTasacionActualizadaNoTerrenoCalculado
        {
            get { return montoTasacionActualizadaNoTerrenoCalculado; }
            set { montoTasacionActualizadaNoTerrenoCalculado = value; }
        }

        /// <summary>
        /// Propiedad que obtiene la fecha de valuación registrada en el SICC para una misma finca o prenda
        /// </summary>
        public DateTime FechaValuacionSICC
        {
            get { return fechaValuacionSICC; }
        }

        #region RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno

        /// <summary>
        /// Obtiene o establece el Porcentaje de Aceptacion Terreno
        /// </summary>
        public decimal PorcentajeAceptacionTerreno
        {
            get { return porcentajeAceptacionTerreno; }
            set { porcentajeAceptacionTerreno = value; }
        }

        /// <summary>
        /// Obtiene o establece el Porcentaje de Aceptacion No Terreno
        /// </summary>
        public decimal PorcentajeAceptacionNoTerreno
        {
            get { return porcentajeAceptacionNoTerreno; }
            set { porcentajeAceptacionNoTerreno = value; }
        }

        /// <summary>
        /// Obtiene o establece el Porcentaje de Aceptacion Terreno Calculado
        /// </summary>
        public decimal PorcentajeAceptacionTerrenoCalculado
        {
            get { return porcentajeAceptacionTerrenoCalculado; }
            set { porcentajeAceptacionTerrenoCalculado = value; }
        }

        /// <summary>
        /// Obtiene o establece el Porcentaje de Aceptacion No Terreno Calculado
        /// </summary>
        public decimal PorcentajeAceptacionNoTerrenoCalculado
        {
            get { return porcentajeAceptacionNoTerrenoCalculado; }
            set { porcentajeAceptacionNoTerrenoCalculado = value; }
        }

        #endregion

        #endregion Avalúo

        #region Inconsistencias

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con la fecha de presentación de la garantía
        /// </summary>
        public bool InconsistenciaFechaPresentacion
        {
            get { return inconsistenciaFechaPresentacion; }
            set { inconsistenciaFechaPresentacion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con el indicador de inscripción de la garantía
        /// </summary>
        public bool InconsistenciaIndicadorInscripcion
        {
            get { return inconsistenciaIndicadorInscripcion; }
            set { inconsistenciaIndicadorInscripcion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con el monto mitigador de la garantía
        /// </summary>
        public short InconsistenciaMontoMitigador
        {
            get { return inconsistenciaMontoMitigador; }
            set { inconsistenciaMontoMitigador = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con el porcentaje de aceptación de la garantía
        /// </summary>
        public bool InconsistenciaPorcentajeAceptacion
        {
            get { return inconsistenciaPorcentajeAceptacion; }
            set { inconsistenciaPorcentajeAceptacion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con el partido
        /// </summary>
        public bool InconsistenciaPartido
        {
            get { return inconsistenciaPartido; }
            set { inconsistenciaPartido = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con el número de finca
        /// </summary>
        public bool InconsistenciaFinca
        {
            get { return inconsistenciaFinca; }
            set { inconsistenciaFinca = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con la clase de garantía
        /// </summary>
        public bool InconsistenciaClaseGarantia
        {
            get { return inconsistenciaClaseGarantia; }
            set { inconsistenciaClaseGarantia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con el tipo de bien de la garantía
        /// </summary>
        public bool InconsistenciaTipoBien
        {
            get { return inconsistenciaTipoBien; }
            set { inconsistenciaTipoBien = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con el tipo de mitigador de la garantía
        /// </summary>
        public bool InconsistenciaTipoMitigador
        {
            get { return inconsistenciaTipoMitigador; }
            set { inconsistenciaTipoMitigador = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con el tipo de documento legal de la garantía
        /// </summary>
        public bool InconsistenciaTipoDocumentoLegal
        {
            get { return inconsistenciaTipoDocumentoLegal; }
            set { inconsistenciaTipoDocumentoLegal = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con el grado de gravemen de la garantía
        /// </summary>
        public bool InconsistenciaGradoGravamen
        {
            get { return inconsistenciaGradoGravamen; }
            set { inconsistenciaGradoGravamen = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con los datos del terreno, según el tipo de bien
        /// </summary>
        public bool InconsistenciaValuacionesTerreno
        {
            get { return inconsistenciaValuacionesTerreno; }
            set { inconsistenciaValuacionesTerreno = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con los datos del no terreno, según el tipo de bien
        /// </summary>
        public short InconsistenciaValuacionesNoTerreno
        {
            get { return inconsistenciaValuacionesNoTerreno; }
            set { inconsistenciaValuacionesNoTerreno = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con la fecha del último seguimiento del avalúo
        /// </summary>
        public short InconsistenciaFechaUltimoSeguimiento
        {
            get { return inconsistenciaFechaUltimoSeguimiento; }
            set { inconsistenciaFechaUltimoSeguimiento = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con la fecha de construcción del avalúo
        /// </summary>
        public short InconsistenciaFechaConstruccion
        {
            get { return inconsistenciaFechaConstruccion; }
            set { inconsistenciaFechaConstruccion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia en la que la fecha de valuación y el monto total del avalúo es diferente
        /// al registrado en el SICC
        /// </summary>
        public short AvaluoDiferenteSicc
        {
            get { return inconsistenciaAvaluoDiferenteSicc; }
            set { inconsistenciaAvaluoDiferenteSicc = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con la fecha de vencimiento de la garantía
        /// </summary>
        public short InconsistenciaFechaVencimiento
        {
            get { return inconsistenciaFechaVencimiento; }
            set { inconsistenciaFechaVencimiento = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con la fecha de prescripción de la garantía
        /// </summary>
        public bool InconsistenciaFechaPrescripcion
        {
            get { return inconsistenciaFechaPrescripcion; }
            set { inconsistenciaFechaPrescripcion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia referente a la validez del monto de la tasación actualizada del terreno calculado
        /// </summary>
        public short InconsistenciaValidezMontoAvaluoActualizadoTerreno
        {
            get { return inconsistenciaValidezMontoAvaluoActualizadoTerreno; }
            set { inconsistenciaValidezMontoAvaluoActualizadoTerreno = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia referente a la validez del monto de la tasación actualizada del no terreno calculado
        /// </summary>
        public short InconsistenciaValidezMontoAvaluoActualizadoNoTerreno
        {
            get { return inconsistenciaValidezMontoAvaluoActualizadoNoTerreno; }
            set { inconsistenciaValidezMontoAvaluoActualizadoNoTerreno = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia referente a la aplicación del cálculo del monto de la tasación actualizada del no terreno calculado
        /// </summary>
        public short CalculoMontoActualizadoNoTerreno
        {
            get { return calculoMontoActualizadoTerrenoNoTerreno; }
            set { calculoMontoActualizadoTerrenoNoTerreno = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del error técnico que se de por la aplicación del cálculo del monto de la tasación actualizada del no terreno calculado
        /// </summary>
        public string ErrorTecnicoCalculoMontoActualizadoNoTerreno
        {
            get { return errorTecnicoCalculoMontoActualizadoTerrenoNoTerreno; }
            set { errorTecnicoCalculoMontoActualizadoTerrenoNoTerreno = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la inconsistencia con la fecha de constitución de la garantía
        /// </summary>
        public bool InconsistenciaFechaConstitucion
        {
            get { return inconsistenciaFechaConstitucion; }
            set { inconsistenciaFechaConstitucion = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que el monto de la póliza no cubre el bien
        /// </summary>
        public bool InconsistenciaPolizaNoCubreBien
        {
            get { return inconsistenciaPolizaNoCubreBien; }
            set { inconsistenciaPolizaNoCubreBien = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que la garantía no posee una póliza asociada
        /// </summary>
        public bool InconsistenciaGarantiaSinPoliza
        {
            get { return inconsistenciaGarantiaSinPoliza; }
            set { inconsistenciaGarantiaSinPoliza = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que la póliza es inválida
        /// </summary>
        public bool InconsistenciaPolizaInvalida
        {
            get { return inconsistenciaPolizaInvalida; }
            set { inconsistenciaPolizaInvalida = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que la póliza está vencida
        /// </summary>
        public bool InconsistenciaPolizaVencida
        {
            get { return inconsistenciaPolizaVencida; }
            set { inconsistenciaPolizaVencida = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que la póliza fua cambiada en el SAP
        /// </summary>
        public bool InconsistenciaCambioPoliza
        {
            get { return inconsistenciaCambioPoliza; }
            set { inconsistenciaCambioPoliza = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que el monto de la póliza fue modificado en el SAP
        /// </summary>
        public bool InconsistenciaCambioMontoPoliza
        {
            get { return inconsistenciaCambioMontoPoliza; }
            set { inconsistenciaCambioMontoPoliza = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que la fecha de vencimiento de la póliza fue modificada en el SAP
        /// </summary>
        public bool InconsistenciaCambioFechaVencimiento
        {
            get { return inconsistenciaCambioFechaVencimiento; }
            set { inconsistenciaCambioFechaVencimiento = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que el monto de la acreencia, de una misma póliza y garantía, es diferente entre las difernetes operacioens que respalda la garantía
        /// </summary>
        public bool InconsistenciaMontoAcreenciaDiferente
        {
            get { return inconsistenciaMontoAcreenciaDiferente; }
            set { inconsistenciaMontoAcreenciaDiferente = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que el monto de la póliza es menor al de la última tasación del no terreno
        /// </summary>
        public bool InconsistenciaGarantiaInfraSeguro
        {
            get { return inconsistenciaGarantiaInfraSeguro; }
            set { inconsistenciaGarantiaInfraSeguro = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que el nombre del acreedor de la póliza fue modificado en el SAP
        /// </summary>
        public bool InconsistenciaCambioAcreedor
        {
            get { return inconsistenciaCambioAcreedor; }
            set { inconsistenciaCambioAcreedor = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que la identificación del acreedor de la póliza fue modificada en el SAP
        /// </summary>
        public bool InconsistenciaCambioIdAcreedor
        {
            get { return inconsistenciaCambioIdAcreedor; }
            set { inconsistenciaCambioIdAcreedor = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que los datos del acreedor de la póliza fueron modificados en el SAP
        /// </summary>
        public bool InconsistenciaCambioDatosAcreedor
        {
            get { return inconsistenciaCambioDatosAcreedor; }
            set { inconsistenciaCambioDatosAcreedor = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que el monto de la acreencia es mayor al monto de la póliza
        /// </summary>
        public bool InconsistenciaMontoAcreenciaInvalido
        {
            get { return inconsistenciaMontoAcreenciaInvalido; }
            set { inconsistenciaMontoAcreenciaInvalido = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca que la  fecha de valuacion sea mayor a 5 años en relacion a la fecha del sistema
        /// </summary>

        public bool InconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienUno
        {
            get { return inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienUno; }
            set { inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienUno = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca que la fecha de ultimo seguimiento es mayor 1 año en realacion a la fecha del sistema
        /// </summary>
        public bool InconsistenciaPorceAcepFechaSeguimientoMayorUnAnno
        {
            get { return inconsistenciaPorceAcepFechaSeguimientoMayorUnAnno; }
            set { inconsistenciaPorceAcepFechaSeguimientoMayorUnAnno = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca que la fecha de ultimo seguimiento es mayor 6 meses en realacion a la fecha del sistema    
        /// </summary>
        public bool InconsistenciaPorceAcepFechaSeguimientoMayorSeisMeses
        {
            get { return inconsistenciaPorceAcepFechaSeguimientoMayorSeisMeses; }
            set { inconsistenciaPorceAcepFechaSeguimientoMayorSeisMeses = value; }
        }


        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca que si tiene una poliza asociada
        /// </summary>

        public bool InconsistenciaPorceAcepTipoBienUnoPolizaAsociada
        {
            get { return inconsistenciaPorceAcepTipoBienUnoPolizaAsociada; }
            set { inconsistenciaPorceAcepTipoBienUnoPolizaAsociada = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca que no tiene una poliza asociada
        /// </summary>        
        public bool InconsistenciaPorceAcepNoPolizaAsociada
        {
            get { return inconsistenciaPorceAcepNoPolizaAsociada; }
            set { inconsistenciaPorceAcepNoPolizaAsociada = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca que tiene una poliza asociada y la fecha de vencimiento de la poliza es menor a la fecha del sistema
        /// </summary>
        public bool InconsistenciaPorceAcepPolizaFechaVencimientoMenor
        {
            get { return inconsistenciaPorceAcepPolizaFechaVencimientoMenor; }
            set { inconsistenciaPorceAcepPolizaFechaVencimientoMenor = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca que la fecha de valuacion sea mayor a 5 años en relacion a la fecha del sistema
        /// </summary>
        public bool InconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienTres
        {
            get { return inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienTres; }
            set { inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienTres = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca que la fecha de ultimo seguimiento es mayor 1 año en realacion a la fecha del sistema
        /// </summary>
        public bool InconsistenciaPorceAcepFechaSeguimientoMayorUnAnnoBienTres
        {
            get { return inconsistenciaPorceAcepFechaSeguimientoMayorUnAnnoBienTres; }
            set { inconsistenciaPorceAcepFechaSeguimientoMayorUnAnnoBienTres = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca que la MAYOR A 18 MESES FECHA SISTEMA, MIENTAS NO EXISTA DIFERENCIA MAYOR A 3 MESES ENTRE FECHA SEGUIMIENTO Y FECHA DEL SISTEMA
        /// </summary>
        public bool InconsistenciaPorceAcepFechaValuacionMayorDieciochoMeses
        {
            get { return inconsistenciaPorceAcepFechaValuacionMayorDieciochoMeses; }
            set { inconsistenciaPorceAcepFechaValuacionMayorDieciochoMeses = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca que la fecha de vencimiento de la poliza es mayor a la de proceso y el monto de la poliza no cubre el monto ultima tasacion no terreno 
        /// </summary>
        public bool InconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno
        {
            get { return inconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno; }
            set { inconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca que no tiene relacionado el tipo de mitigador en el catalogo de porcentaje de aceptacion
        /// </summary>
        public bool InconsistenciaPorceAcepTipoMitigadorNoRelacionado
        {
            get { return inconsistenciaPorceAcepTipoMitigadorNoRelacionado; }
            set { inconsistenciaPorceAcepTipoMitigadorNoRelacionado = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en que el porcentaje de aceptacion es mayor al porcentaje de aceptacion calculado
        /// </summary>
        public bool InconsistenciaPorceAcepMayorPorceAcepCalculado
        {
            get { return inconsistenciaPorceAcepMayorPorceAcepCalculado; }
            set { inconsistenciaPorceAcepMayorPorceAcepCalculado = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en que las coberturas obligatorias no fueron asignadas en su totalidad
        /// </summary>
        public bool InconsistenciaCoberturasObligatoriasInvalidas
        {
            get { return inconsistenciaCoberturasObligatoriasInvalidas; }
            set { inconsistenciaCoberturasObligatoriasInvalidas = value; }
        }


        //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en el Indicador Inscripción cuando sea No anotada/No Inscrita
        /// </summary>
        public bool InconsistenciaPorcAceptTerrenoCalcNoAnotadaNoInscrita
        {
            get { return inconsistenciaPorcAceptTerrenoCalcNoAnotadaNoInscrita; }
            set { inconsistenciaPorcAceptTerrenoCalcNoAnotadaNoInscrita = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en el Indicador Inscripción cuando sea Anotada
        /// </summary>
        public bool InconsistenciaPorcAceptTerrenoCalcAnotada
        {
            get { return inconsistenciaPorcAceptTerrenoCalcAnotada; }
            set { inconsistenciaPorcAceptTerrenoCalcAnotada = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la Fecha Último Seguimiento (la fecha actual supera en un año la fecha último seguimiento)
        /// </summary>
        public bool InconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento
        {
            get { return inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento; }
            set { inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la Fecha de Valuación (la fecha actual supera en 5 años la fecha valuación)
        /// </summary>
        public bool InconsistenciaPorcAceptTerrenoCalcFechaValuacion
        {
            get { return inconsistenciaPorcAceptTerrenoCalcFechaValuacion; }
            set { inconsistenciaPorcAceptTerrenoCalcFechaValuacion = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en el Indicador Inscripción cuando sea No anotada/No Inscrita
        /// </summary>
        public bool InconsistenciaPorcAceptNoTerrenoCalcNoAnotadaNoInscrita
        {
            get { return inconsistenciaPorcAceptNoTerrenoCalcNoAnotadaNoInscrita; }
            set { inconsistenciaPorcAceptNoTerrenoCalcNoAnotadaNoInscrita = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en el Indicador Inscripción cuando sea Anotada
        /// </summary>
        public bool InconsistenciaPorcAceptNoTerrenoCalcAnotada
        {
            get { return inconsistenciaPorcAceptNoTerrenoCalcAnotada; }
            set { inconsistenciaPorcAceptNoTerrenoCalcAnotada = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la Fecha Último Seguimiento (la fecha actual supera en un año la fecha último seguimiento)
        /// </summary>
        public bool InconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento
        {
            get { return inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento; }
            set { inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de que se presentó la inconsistenca en la Fecha Último Seguimiento (la fecha actual supera en 6 meses la fecha último seguimiento)
        /// </summary>
        public bool InconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo
        {
            get { return inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo; }
            set { inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo = value; }
        }

        /// <summary>
        /// /// Obtiene o establece el indicador de que se presentó la inconsistenca en la Fecha de Valuación (la fecha actual supera en 5 años la fecha valuación)
        /// </summary>
        public bool InconsistenciaPorcAceptNoTerrenoCalcFechaValuacion
        {
            get { return inconsistenciaPorcAceptNoTerrenoCalcFechaValuacion; }
            set { inconsistenciaPorcAceptNoTerrenoCalcFechaValuacion = value; }
        }

        /// <summary>
        /// /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que el porcentaje de aceptación del terreno es mayor al calculado
        /// </summary>
        public bool InconsistenciaPorceAcepTerrenoMayorPorceAcepCalculado
        {
            get { return inconsistenciaPorceAcepTerrenoMayorPorceAcepCalculado; }
            set { inconsistenciaPorceAcepTerrenoMayorPorceAcepCalculado = value; }
        }

        /// <summary>
        /// /// Obtiene o establece el indicador de que se presentó la inconsistenca en la que el porcentaje de aceptación del no terreno es mayor al calculado
        /// </summary>
        public bool InconsistenciaPorceAcepNoTerrenoMayorPorceAcepCalculado
        {
            get { return inconsistenciaPorceAcepNoTerrenoMayorPorceAcepCalculado; }
            set { inconsistenciaPorceAcepNoTerrenoMayorPorceAcepCalculado = value; }
        }


        #endregion Inconsistencias

        #region Generales

        /// <summary>
        /// Propiedad que obtiene y establece la indicación de que se presentó un error por problema de datos
        /// </summary>
        public bool ErrorDatos
        {
            get { return errorDatos; }
            set { errorDatos = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la indicación de que se presentó un error debido a la aplicación de las validaciones
        /// </summary>
        public bool ErrorValidaciones
        {
            get { return errorValidaciones; }
            set { errorValidaciones = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del error
        /// </summary>
        public string DescripcionError
        {
            get { return descripcionError; }
            set { descripcionError = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la indicación de presentar el error mediante la ventana emergente
        /// </summary>
        public bool DesplegarErrorVentanaEmergente
        {
            get { return desplegarErrorVentanaEmergente; }
            set { desplegarErrorVentanaEmergente = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la lista de errores que deben ser desplegados en la ventana emergente
        /// </summary>
        public SortedDictionary<int, string> ListaErroresValidaciones
        {
            get { return listaErroresValidaciones; }
            set { listaErroresValidaciones = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el número de operación, bajo el formato Contabilidad - Oficina - Moneda - Producto - Num Operación / Num. Contrato
        /// </summary>
        public string Operacion
        {
            get { return (((operacion != null) && (operacion.Length > 0)) ? operacion : (((codContabilidad != -1) && (codOficina != -1) && (codMonedaOper != -1) && (numOperacion != -1)) ? (codContabilidad.ToString() + "-" + codOficina.ToString() + "-" + codMonedaOper.ToString() + "-" + ((codProducto != -1) ? (codProducto.ToString() + "-" + numOperacion.ToString()) : numOperacion.ToString())) : "--")); }
            set { operacion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el número de garantía, bajo el formato Partido - Finca / Clase - Placa
        /// </summary>
        public string Garantia
        {
            get { return ((garantia.Length > 0) ? garantia : "--"); }
            set { garantia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la lista de campos, de la garantía, que fueron modificados
        /// </summary>
        public Dictionary<string, string> DatosModificadosGarantias
        {
            get { return listaDatosModificadosGarantias; }
            set { listaDatosModificadosGarantias = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la lista de campos, de la relación garantía - operación, que fueron modificados
        /// </summary>
        public Dictionary<string, string> DatosModificadosGarantiasXOperacion
        {
            get { return listaDatosModificadosGarXOper; }
            set { listaDatosModificadosGarXOper = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la trama de la consulta inicial
        /// </summary>
        public string TramaInicial
        {
            get { return tramaInicial; }
            set { tramaInicial = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la lista de descripciones de los valores iniciales de los combos
        /// </summary>
        public Dictionary<string, string> ListaDescripcionValoresAnteriores
        {
            get { return listaDescripcionValoresAnterioresCombos; }
            set { listaDescripcionValoresAnterioresCombos = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la lista de descripciones de los valores actuales de los combos
        /// </summary>
        public Dictionary<string, string> ListaDescripcionValoresActualesCombos
        {
            get { return listaDescripcionValoresActualesCombos; }
            set { listaDescripcionValoresActualesCombos = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la lista de mensajes informativos que deben ser desplegados en la ventana emergente
        /// </summary>
        public SortedDictionary<int, string> ListaMensajesValidaciones
        {
            get { return listaMensajesValidaciones; }
            set { listaMensajesValidaciones = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la indicación de que se presentó un error por problema de datos requeridos
        /// </summary>
        public bool ErrorDatosRequeridos
        {
            get { return errorDatosRequeridos; }
            set { errorDatosRequeridos = value; }
        }

        #endregion Generales

        #region Operaciones relacionadas

        /// <summary>
        /// Propiedad que posee la lista de operaciones en las que participa la garantía consultada
        /// </summary>
        public clsOperacionesCrediticias<clsOperacionCrediticia> OperacionesRelacionadas
        {
            get { return operacionesCrediticias; }
            set { operacionesCrediticias = value; }
        }

        #endregion Operaciones relacionadas

        #region Parámetros del cálculo

        /// <summary>
        /// Propiedad que obtiene el porcentaje usado para el cálculo del monto de la tasación actualizada del no terreno dentro de la 
        /// cota inferior
        /// </summary>
        public decimal PorcentajeLimiteInferior
        {
            get { return porcentajeLimiteInferior; }
        }

        /// <summary>
        /// Propiedad que obtiene el porcentaje usado para el cálculo del monto de la tasación actualizada del no terreno dentro de la 
        /// cota intermedia
        /// </summary>
        public decimal PorcentajeLimiteIntermedio
        {
            get { return porcentajeLimiteIntermedio; }
        }

        /// <summary>
        /// Propiedad que obtiene el porcentaje porcentaje usado para el cálculo del monto de la tasación actualizada del no terreno dentro de la 
        /// cota superior
        /// </summary>
        public decimal PorcentajeLimiteSuperior
        {
            get { return porcentajeLimiteSuperior; }
        }

        /// <summary>
        /// Propiedad que obtiene el límite de los años que comprende la cota inferior del cálculo del monto de la tasación actualizada del no terreno 
        /// </summary>
        public short AnnosLimiteInferior
        {
            get { return annosLimiteInferior; }
        }

        /// <summary>
        /// Propiedad que obtiene el límite de los años que comprende la cota intermedia del cálculo del monto de la tasación actualizada del no terreno 
        /// </summary>
        public short AnnosLimiteIntermedio
        {
            get { return annosLimiteIntermedio; }
        }

        #endregion Parámetros del cálculo

        #region Cálculo del MTAT y MTANT

        /// <summary>
        /// Obtiene y establece la lista de semestres que deben ser calculados para traer al presente los montos de las tasaciones actualizadas del terreno y no terreno
        /// </summary>
        public clsSemestres<clsSemestre> ListaSemestresCalcular
        {
            get { return listaSemestresCalcular; }
            set { listaSemestresCalcular = value; }
        }

        #endregion Cálculo del MTAT y MTANT

        #region Pólizas SAP

        /// <summary>
        /// Propiedad que posee la lista de pólizas asociadas a la operación en la que participa la garantía consultada
        /// </summary>
        public clsPolizasSap<clsPolizaSap> PolizasSap
        {
            get { return polizasSap; }
            set { polizasSap = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la póliza asignada a la garantía
        /// </summary>
        public clsPolizaSap PolizaSapAsociada
        {
            get { return polizaSapAsociada; }
            set { polizaSapAsociada = value; }
        }

        /// <summary>
        /// Indica si se debe mostrar o no el mensaje correspondiente al problema de la realción entre el tipo de bien y el tipo de póliza SAP
        /// </summary>
        public bool MostrarErrorRelacionTipoBienTipoPolizaSap
        {
            get
            {
                return mostrarErrorRelacionTipoBienTipoPolizaSap;
            }

            set
            {
                mostrarErrorRelacionTipoBienTipoPolizaSap = value;
            }
        }

        #endregion Pólizas SAP

        #endregion Propiedades

        #region Métodos

        #region Métodos Públicos

        /// <summary>
        /// Evalúa que los campos requeridos posean datos
        /// </summary>
        /// <returns>True: Todos los campos requeridos estn completos, False: Existe al menos un campo requerido que no fue suministrado</returns>
        public bool CamposRequeridosValidos()
        {
            bool camposRequeridos = true;

            desplegarErrorVentanaEmergente = false;

            if (camposRequeridos && codContabilidad == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al código de contabilidad", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && codOficina == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al código de oficina", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && codMonedaOper == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al código de moneda", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && tipoOperacionCred == ((int)Enumeradores.Tipos_Operaciones.Directa))
            {
                if (codProducto == -1)
                {
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al código del producto", Mensajes.ASSEMBLY);
                    camposRequeridos = false;
                }
            }
            if (camposRequeridos && numOperacion == -1)
            {
                if (tipoOperacionCred == ((int)Enumeradores.Tipos_Operaciones.Directa))
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al número de operación", Mensajes.ASSEMBLY);
                else
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al número de contrato", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && codTipoGarantiaReal == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al tipo de garantía real", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && codClaseGarantia == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "a la clase de garantía", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }

            if (camposRequeridos && codTipoGarantiaReal == ((int)Enumeradores.Tipos_Garantia_Real.Hipoteca))
            {
                if (camposRequeridos && codPartido == -1)
                {
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al partido", Mensajes.ASSEMBLY);
                    camposRequeridos = false;
                }
                if (camposRequeridos && numeroFinca.Trim().Length == 0)
                {
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al número de finca", Mensajes.ASSEMBLY);
                    camposRequeridos = false;
                }
            }
            else if (camposRequeridos && codTipoGarantiaReal == ((int)Enumeradores.Tipos_Garantia_Real.Cedula_Hipotecaria))
            {
                if (camposRequeridos && codPartido == -1)
                {
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al partido", Mensajes.ASSEMBLY);
                    camposRequeridos = false;
                }
                if (camposRequeridos && numeroFinca.Trim().Length == 0)
                {
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al número de finca", Mensajes.ASSEMBLY);
                    camposRequeridos = false;
                }
                if (camposRequeridos && codGrado.Trim().Length == 0)
                {
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al grado", Mensajes.ASSEMBLY);
                    camposRequeridos = false;
                }
                if (camposRequeridos && cedulaHipotecaria.Trim().Length == 0)
                {
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "a la cédula hipotecaria", Mensajes.ASSEMBLY);
                    camposRequeridos = false;
                }
            }
            else if (camposRequeridos && codTipoGarantiaReal == ((int)Enumeradores.Tipos_Garantia_Real.Prenda))
            {
                if (camposRequeridos && numPlacaBien.Trim().Length == 0)
                {
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al número de placa del bien", Mensajes.ASSEMBLY);
                    camposRequeridos = false;
                }
            }
            if (camposRequeridos && codTipoBien == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al tipo de bien", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && codTipoMitigador == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al tipo mitigador de riesgo", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && codTipoDocumentoLegal == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al tipo de documento legal", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && montoMitigador == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al monto mitigador", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && fechaConstitucion == DateTime.MinValue)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "a la fecha de constitución de la garantía", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && codGradoGravamen == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al grado de gravamen", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && fechaPrescripcion == DateTime.MinValue)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "a la fecha de prescripción", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && codInscripcion == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al código del indicador de inscripción", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && fechaValuacion == (new DateTime(1900, 01, 01)))
            {
                descripcionError = Mensajes.Obtener(Mensajes._errorDatosAvaluoRequeridos, Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && (cedulaPerito.Length == 0) && (cedulaEmpresa.Length == 0))
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "el perito o la empresa", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }
            if (camposRequeridos && fechaUltimoSeguimiento == (new DateTime(1900, 01, 01)))
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "la fecha de último seguimiento", Mensajes.ASSEMBLY);
                camposRequeridos = false;
            }

            return camposRequeridos;

        }

        /// <summary>
        /// Aplica las validaciones a diferentes campos
        /// </summary>
        /// <returns>True: Todas las validaciones fueron exitosas, False: Existe al menos una validación que no se cumplió</returns>
        public bool EntidadValida(bool validarCamposRequeridos)
        {
            bool esValida = true;
            bool tieneErrorMontoMitigador = false;
            DateTime fechaLimite;
            DateTime fechaNula = new DateTime(1900, 01, 01);
            DateTime fechaPrescripcionCalculada;


            bool aplicarValidacionCamposRequeridos = (validarCamposRequeridos) ? CamposRequeridosValidos() : true;
            List<clsPolizaSap> listaPolizas = PolizasSap.ObtenerPolizasPorTipoBien(CodTipoBien);
            bool errorRelacionGarantiaPoliza = PolizasSap.ErrorRelacionTipoBienPolizaSap;


            if (aplicarValidacionCamposRequeridos)
            {
                listaErroresValidaciones.Clear();
                inconsistenciaClaseGarantia = false;
                inconsistenciaFechaPresentacion = false;
                inconsistenciaGradoGravamen = false;
                inconsistenciaIndicadorInscripcion = false;
                inconsistenciaMontoMitigador = 0;
                inconsistenciaPartido = false;
                inconsistenciaFinca = false;
                inconsistenciaPorcentajeAceptacion = false;
                inconsistenciaTipoBien = false;
                inconsistenciaTipoDocumentoLegal = false;
                inconsistenciaTipoMitigador = false;
                inconsistenciaValuacionesNoTerreno = 0;
                inconsistenciaValuacionesTerreno = false;
                inconsistenciaFechaVencimiento = 0;
                inconsistenciaFechaPrescripcion = false;
                inconsistenciaAvaluoDiferenteSicc = 0;
                inconsistenciaFechaConstruccion = 0;
                inconsistenciaFechaUltimoSeguimiento = 0;
                inconsistenciaValidezMontoAvaluoActualizadoTerreno = 0;
                inconsistenciaValidezMontoAvaluoActualizadoNoTerreno = 0;
                inconsistenciaFechaConstitucion = false;
                inconsistenciaPolizaNoCubreBien = false;
                inconsistenciaGarantiaSinPoliza = false;
                inconsistenciaPolizaInvalida = false;
                inconsistenciaPolizaVencida = false;
                inconsistenciaCambioPoliza = false;
                inconsistenciaCambioMontoPoliza = false;
                inconsistenciaCambioFechaVencimiento = false;
                inconsistenciaMontoAcreenciaDiferente = false;
                inconsistenciaGarantiaInfraSeguro = false;
                inconsistenciaCambioAcreedor = false;
                inconsistenciaCambioIdAcreedor = false;
                inconsistenciaCambioDatosAcreedor = false;

                inconsistenciaPorceAcepFechaSeguimientoMayorSeisMeses = false;
                inconsistenciaPorceAcepFechaSeguimientoMayorUnAnno = false;
                inconsistenciaPorceAcepFechaSeguimientoMayorUnAnnoBienTres = false;
                inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienUno = false;
                inconsistenciaPorceAcepNoPolizaAsociada = false;
                inconsistenciaPorceAcepPolizaFechaVencimientoMenor = false;
                inconsistenciaPorceAcepTipoBienUnoPolizaAsociada = false;
                inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienTres = false;
                inconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno = false;
                inconsistenciaPorceAcepTipoBienUnoPolizaAsociada = false;
                inconsistenciaPorceAcepTipoMitigadorNoRelacionado = false;
                inconsistenciaPorceAcepMayorPorceAcepCalculado = false;

                inconsistenciaPorceAcepFechaSeguimientoMenorUnAnnoBienCuatro = false;
                inconsistenciaPorcentajeAceptacionCalculado = false;

                inconsistenciaCoberturasObligatoriasInvalidas = false;

                //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
                inconsistenciaPorcAceptTerrenoCalcNoAnotadaNoInscrita = false;
                inconsistenciaPorcAceptTerrenoCalcAnotada = false;
                inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento = false;
                inconsistenciaPorcAceptTerrenoCalcFechaValuacion = false;

                inconsistenciaPorcAceptNoTerrenoCalcNoAnotadaNoInscrita = false;
                inconsistenciaPorcAceptNoTerrenoCalcAnotada = false;
                inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento = false;
                inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo = false;
                inconsistenciaPorcAceptNoTerrenoCalcFechaValuacion = false;


                //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
                inconsistenciaPorcAceptTerrenoCalcNoAnotadaNoInscrita = false;
                inconsistenciaPorcAceptTerrenoCalcAnotada = false;
                inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento = false;
                inconsistenciaPorcAceptTerrenoCalcFechaValuacion = false;
                inconsistenciaPorceAcepTerrenoMayorPorceAcepCalculado = false;

                inconsistenciaPorcAceptNoTerrenoCalcNoAnotadaNoInscrita = false;
                inconsistenciaPorcAceptNoTerrenoCalcAnotada = false;
                inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento = false;
                inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo = false;
                inconsistenciaPorcAceptNoTerrenoCalcFechaValuacion = false;
                inconsistenciaPorceAcepNoTerrenoMayorPorceAcepCalculado = false;


                #region Cargar listas de datos

                List<int> listaProvincias = new List<int>(new int[] { 1, 2, 3, 4, 5, 6, 7 });

                List<int> listaClasesGarantias = new List<int>(new int[] { 10, 11, 12, 13, 14, 15, 16, 17 });

                List<int> listaTiposBien = new List<int>(new int[] { 1, 2 });

                List<int> listaTiposMitigador_TipoBien2 = new List<int>(new int[] { 2, 3 });

                List<int> listaTiposDocumentoLegalH = new List<int>(new int[] { 1, 2, 3, 4 });

                List<int> listaTiposDocumentoLegalCH = new List<int>(new int[] { 5, 6, 7, 8 });

                List<int> listaTiposDocumentoLegalP = new List<int>(new int[] { 9, 10, 11, 12 });

                List<int> listaClasesGarantiasPrendaInvalidas = new List<int>(new int[] { 56, 57, 58 });

                #endregion Cargar listas de datos

                #region Se aplica la validación correspondiente a la fecha de presentación

                //Se valida si la fecha de presentación es nula o vacía
                if (fechaPresentacion == DateTime.MinValue)
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = false;
                    inconsistenciaFechaPresentacion = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaPresentacion), _mensajeFechaPresentacion);
                }
                //Se verifica si la fecha de constitución es nula o vacía y la fecha de presentación es válida
                else if ((fechaConstitucion == DateTime.MinValue) && (fechaPresentacion != DateTime.MinValue))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaFechaPresentacion = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaPresentacion), _mensajeFechaPresentacion);
                }
                //Se valida si la fecha de constitución es mayor a la fecha de presentación
                else if (fechaConstitucion > fechaPresentacion)
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaFechaPresentacion = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaPresentacion), _mensajeFechaPresentacion);
                }

                #endregion Se aplica la validación correspondiente a la fecha de presentación

                #region Se aplica la validación correspondiente al indicador de inscripción

                //Se valida si el indicador de inscripción no ha sido asignado
                if ((validarCamposRequeridos) && (codInscripcion == -1))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = ((desplegarErrorVentanaEmergente) ? desplegarErrorVentanaEmergente : false);
                    inconsistenciaIndicadorInscripcion = true;
                    inconsistenciaPorcentajeAceptacionCalculado = true;
                }
                //Se verifica si se ha suministrado la fecha de presentación y el indicador de inscripción no
                else if ((FechaPresentacion != DateTime.MinValue) && (codInscripcion == -1))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = ((desplegarErrorVentanaEmergente) ? desplegarErrorVentanaEmergente : false);
                    inconsistenciaIndicadorInscripcion = true;
                    inconsistenciaPorcentajeAceptacionCalculado = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.IndicadorInscripcion), _mensajeIndicadorInscripcionInvalido);
                }
                //Se valida si el indicador de inscripción es uno inválido
                else if (codInscripcion == 0)
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaIndicadorInscripcion = true;
                    inconsistenciaPorcentajeAceptacionCalculado = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.IndicadorInscripcion), _mensajeIndicadorInscripcionInvalido);
                }
                //Se valida que si el indicador de inscripción es "No anotada/No inscrita" y la fecha actual supera en 30 días la fecha de constitución
                else if (codInscripcion == 1)
                {
                    fechaLimite = fechaConstitucion.AddDays(30);

                    if (DateTime.Today >= fechaLimite)
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaIndicadorInscripcion = true;
                        inconsistenciaPorcentajeAceptacionCalculado = true;
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.IndicadorInscripcion), _mensajeIndicadorInscripcionFPFA);
                    }
                }
                //Se valida que si el indicador de inscripción es "Anotada" y la fecha actual supera en 60 días la fecha de constitución
                else if (codInscripcion == 2)
                {
                    fechaLimite = fechaConstitucion.AddDays(60);

                    if (DateTime.Today >= fechaLimite)
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaIndicadorInscripcion = true;
                        inconsistenciaPorcentajeAceptacionCalculado = true;
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.IndicadorInscripcion), _mensajeIndicadorInscripcionFPFA);
                    }
                }

                #endregion Se aplica la validación correspondiente al indicador de inscripción

                #region Se aplica la validación correspondiente al monto mitigador

                //Se valida si la garantía posee registrado un avalúo
                if ((montoUltimaTasacionTerreno + montoUltimaTasacionNoTerreno) == 0)
                {
                    inconsistenciaMontoMitigador = 1;
                    tieneErrorMontoMitigador = true;
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.MontoMitigador), _mensajeMontoMitigadorSinAvaluo);
                }

                if ((!tieneErrorMontoMitigador) && (codInscripcion == 3) && (montoMitigador < 0))
                {
                    inconsistenciaMontoMitigador = 5;
                    tieneErrorMontoMitigador = true;
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;

                    if (listaErroresValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.MontoMitigador)))
                    {
                        listaErroresValidaciones[((int)Enumeradores.Inconsistencias.MontoMitigador)] = _mensajeMontoMitigadorInvalido;
                    }
                    else
                    {
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.MontoMitigador), _mensajeMontoMitigadorInvalido);
                    }
                }
                //Se verifica la validez del porcentaje de aceptación y del monto mitigador
                else if ((!tieneErrorMontoMitigador) && (montoMitigador >= 0) && (porcentajeAceptacion >= 0) && (montoTotalAvaluo >= 0))
                {
                    tieneErrorMontoMitigador = true;
                    //decimal porResp = (this.porcentajeAceptacion / 100);

                    //decimal montoMitigadorCalculado = Math.Round(this.montoTotalAvaluo * (porResp), 2, MidpointRounding.ToEven);
                    decimal montoMitigadorCalculado = Math.Round(CalcularMontoMitigador(), 2, MidpointRounding.ToEven);

                    listaMensajesValidaciones.Remove(((int)Enumeradores.Inconsistencias.MontoMitigador));

                    //Se valida si el monto mitigador es mayor al porcentaje de aceptación permitido
                    if (montoMitigador > montoMitigadorCalculado)
                    {
                        inconsistenciaMontoMitigador = 3;
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        //listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.MontoMitigador), _mensajeCalculoMontoMitigadorMayor);
                        listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.MontoMitigador), _mensajeCalculoMontoMitigadorMayor);

                    }
                    //Se valida si existe un déficit en el monto mitigador de la relación entre la garantía y la operación/contrato 
                    else if (montoMitigador < montoMitigadorCalculado)
                    {
                        inconsistenciaMontoMitigador = 4;
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        //listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.MontoMitigador), _mensajeCalculoMontoMitigadorMenor);
                        listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.MontoMitigador), _mensajeCalculoMontoMitigadorMenor);
                    }
                }

                #endregion Se aplica la validación correspondiente al monto mitigador

                #region Se aplica la validación correspondiente al porcentaje de aceptación
                //Se verifica que el campo esté habilitado, para así aplicar las validaciones
                if (!HabilitarPorcentajesAceptacionAvaluo())
                {
                    //Se valida que para el indicador de inscripción "No anotada/No inscrita" el porcentaje de aceptación sea válido
                    if (codInscripcion == 1)
                    {
                        fechaLimite = fechaConstitucion.AddDays(30);

                        //Se verifica si el porcentaje de aceptación es diferente de 0 (cero) si la fecha actual supera los 30 días posteriores a la 
                        //fecha de constitución
                        if ((DateTime.Today >= fechaLimite) && (porcentajeAceptacion != 0))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcentajeAceptacion = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcentajeAceptacion), _mensajePorcentajeAceptacionInvalido);
                        }
                        //Se valida si el porcetaje de aceptación se encuentra enttre 0 y 80 cuando la fecha actual se encuentra entre los 30 días 
                        //hábiles
                        else if ((DateTime.Today < fechaLimite) && ((porcentajeAceptacion < 0) || (porcentajeAceptacion > 80)))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcentajeAceptacion = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcentajeAceptacion), _mensajePorcentajeAceptacionInvalido);
                        }
                    }
                    //Se valida que para el indicador de inscripción "Anotada" el porcentaje de aceptación sea válido
                    if (codInscripcion == 2)
                    {
                        fechaLimite = fechaConstitucion.AddDays(60);

                        //Se verifica si el porcentaje de aceptación es diferente de 0 (cero) si la fecha actual supera los 60 días posteriores a la 
                        //fecha de constitución
                        if ((DateTime.Today >= fechaLimite) && (porcentajeAceptacion != 0))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcentajeAceptacion = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcentajeAceptacion), _mensajePorcentajeAceptacionInvalido);
                        }
                        //Se valida si el porcetaje de aceptación se encuentra enttre 0 y 80 cuando la fecha actual se encuentra entre los 60 días 
                        //hábiles
                        else if ((DateTime.Today < fechaLimite) && ((porcentajeAceptacion < 0) || (porcentajeAceptacion > 80)))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcentajeAceptacion = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcentajeAceptacion), _mensajePorcentajeAceptacionInvalido);
                        }
                    }
                    //Se valida que para el indicador de inscripción "No anotada/No inscrita" el porcentaje de aceptación sea válido
                    if (codInscripcion == 3)
                    {
                        /*REQ: Siebel 1 - 23969281. Se elimina la validación en la que se evaluaba que para las garantías inscritas se cumpliera el plazo
                        normado por SUGEF.*/

                        /*if (this.porcentajeAceptacion == 0)
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcentajeAceptacion = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcentajeAceptacion), _mensajePorcentajeAceptacionInvalidoIndIns);
                        }
                        else*/
                        if ((porcentajeAceptacion < 0) || (porcentajeAceptacion > 80))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcentajeAceptacion = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcentajeAceptacion), _mensajePorcentajeAceptacionInvalido);
                        }
                    }
                }
                #endregion Se aplica la validación correspondiente al porcentaje de aceptación

                #region Se aplica la validación correspondiente al partido

                //Se verifica que el código de partido sea válido, esto para las hipotecas comunes y cédulas hipotecarias
                if ((codTipoGarantiaReal != ((short)Enumeradores.Tipos_Garantia_Real.Prenda)) && (!listaProvincias.Contains(codPartido)))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaPartido = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.Partido), _mensajePartidoInvalido);
                }

                #endregion Se aplica la validación correspondiente al partido

                #region Se aplica la validación correspondiente al número de finca

                //Se verifica que el número de la finca sea válido, esto en cuanto a la cantidad de dígitos que la componen. Se aplica sólo 
                //a las hipotecas comunes y cédulas hipotecarias, con clase de garantía distinta a 11 (este código es el destinado para datos alfanuméricos)
                if ((codTipoGarantiaReal != ((short)Enumeradores.Tipos_Garantia_Real.Prenda)) && (codClaseGarantia != 11) && (numeroFinca.Trim().Length > 6))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaFinca = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.Finca), _mensajeFincaInvalida);
                }

                #endregion Se aplica la validación correspondiente al número de finca

                #region Se aplica la validación correspondiente a la clase de garantía

                //Se valida que el código de la clase de garantía sea válido, esto para las hipotecas comunes
                if ((codTipoGarantiaReal == 1) && (!listaClasesGarantias.Contains(codClaseGarantia)))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaClaseGarantia = true;

                    switch (codClaseGarantia)
                    {
                        case 18: listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ClaseGarantia), _mensajeClaseGarantiaInvalida18);
                            break;
                        case 19: listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ClaseGarantia), _mensajeClaseGarantiaInvalida19);
                            break;
                        default: listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ClaseGarantia), _mensajeClaseGarantiaInvalida);
                            break;
                    }
                }

                //Se valida que el código de la clase de garantía sea válido, esto para las prendas
                if ((codTipoGarantiaReal == 3) && (listaClasesGarantiasPrendaInvalidas.Contains(codClaseGarantia)))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaClaseGarantia = true;

                    switch (codClaseGarantia)
                    {
                        case 56: listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ClaseGarantia), _mensajeClaseGarantiaInvalida56);
                            break;
                        case 57: listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ClaseGarantia), _mensajeClaseGarantiaInvalida57);
                            break;
                        case 58: listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ClaseGarantia), _mensajeClaseGarantiaInvalida58);
                            break;
                        default: break;
                    }
                }

                #endregion Se aplica la validación correspondiente a la clase de garantía

                #region Se aplica la validación correspondiente al tipo de bien

                //Se valida que el tipo de bien sea el correcto para las hipotecas comunes
                if ((codTipoGarantiaReal == 1) && (!listaTiposBien.Contains(codTipoBien)))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaTipoBien = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.TipoBien), _mensajeTipoBienInvalido);
                }

                #endregion Se aplica la validación correspondiente al tipo de bien

                #region Se aplica la validación correspondiente al tipo de mitigador

                //Se verifica que la hipoteca común posea asignado el tipo de bien
                if ((validarCamposRequeridos) && (codTipoGarantiaReal == 1) && (codTipoBien == -1))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = ((desplegarErrorVentanaEmergente) ? desplegarErrorVentanaEmergente : false);
                    inconsistenciaTipoMitigador = true;
                }
                //Se verifica que el tipo de mitigador sea consistente para el tipo de bien correspondiente a Terrenos, esto para la hipoteca común
                else if ((codTipoGarantiaReal == 1) && (codTipoBien == 1) && (codTipoMitigador != 1))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaTipoMitigador = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.TipoMitigador), _mensajeTipoMitigadorInvalido);
                }
                //Se verifica que el tipo de mitigador sea consistente para el tipo de bien correspondiente a Edificaciones, esto para la hipoteca común
                else if ((codTipoGarantiaReal == 1) && (codTipoBien == 2) && (!listaTiposMitigador_TipoBien2.Contains(codTipoMitigador)))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaTipoMitigador = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.TipoMitigador), _mensajeTipoMitigadorInvalido);
                }

                #endregion Se aplica la validación correspondiente al tipo de mitigador

                #region Se aplica la validación correspondiente al tipo de documento legal

                //Se verifica si el tipo de documento legal almacenado es diferente al mapeado para el tipo de garantía real y el grado de gravamen
                if ((codTipoGarantiaReal == 1) && (!listaTiposDocumentoLegalH.Contains(codTipoDocumentoLegal)))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaTipoDocumentoLegal = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.TipoDocumentoLegal), _mensajeTipoDocumentoLegalInvalidoSegunGG);
                }
                //Se verifica si el tipo de documento legal almacenado es diferente al mapeado para el tipo de garantía real y el grado de gravamen
                else if ((codTipoGarantiaReal == 2) && (!listaTiposDocumentoLegalCH.Contains(codTipoDocumentoLegal)))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaTipoDocumentoLegal = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.TipoDocumentoLegal), _mensajeTipoDocumentoLegalInvalidoSegunGG);
                }
                //Se verifica si el tipo de documento legal almacenado es diferente al mapeado para el tipo de garantía real y el grado de gravamen
                else if ((codTipoGarantiaReal == 3) && (!listaTiposDocumentoLegalP.Contains(codTipoDocumentoLegal)))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaTipoDocumentoLegal = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.TipoDocumentoLegal), _mensajeTipoDocumentoLegalInvalidoSegunGG);
                }

                #endregion Se aplica la validación correspondiente al tipo de documento legal

                #region Se aplica la validación correspondiente al tipo de grado de gravamen

                //Se evalúa que el grado de gravamen sea válido.
                if ((codGradoGravamen < 1) || (codGradoGravamen > 4))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = ((desplegarErrorVentanaEmergente) ? desplegarErrorVentanaEmergente : false);
                    inconsistenciaGradoGravamen = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.GradoGravamen), _mensajeGradoGravamenInvalido);
                }

                #endregion Se aplica la validación correspondiente al tipo de grado de gravamen

                #region Se aplica la validación correspondiente a los datos del terreno

                //Se valida que los campos del no terreno no posean valores cuando se trata de terrenos (tipo de bien igual a 1)
                if ((codTipoGarantiaReal != ((short)Enumeradores.Tipos_Garantia_Real.Prenda)) && (codTipoBien == 1)
                && ((montoUltimaTasacionNoTerreno > 0) || (montoTasacionActualizadaNoTerreno > 0)))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaValuacionesTerreno = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValuacionesTerreno), _mensajeValuacionTerreno);
                }
                //Se verifica si el campo del monto de la última tasación del terreno posee un valor igual a 0 (cero)
                else if ((codTipoGarantiaReal != ((short)Enumeradores.Tipos_Garantia_Real.Prenda)) && ((codTipoBien == 1) || (codTipoBien == 2))
                && (montoUltimaTasacionTerreno <= 0))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaValuacionesTerreno = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValuacionesTerreno), _mensajeMontoUltimaTasacionTerrenoCero);
                }

                #endregion Se aplica la validación correspondiente a los datos del terreno

                #region Se aplica la validación correspondiente a los datos del no terreno

                //Se valida que los campos del no terreno posean valores cuando se trata de edificaciones (tipo de bien igual a 2) o vehículos (tipo de bien igual a 3)
                if ((codTipoGarantiaReal != ((short)Enumeradores.Tipos_Garantia_Real.Prenda)) && ((codTipoBien == 2) || (codTipoBien == 3)))
                {
                    //Se verifica que se haya valuado la parte del no terreno
                    if ((montoUltimaTasacionNoTerreno < 0) || ((codTipoBien == 3) && ((montoUltimaTasacionNoTerreno == 0))) || (montoTasacionActualizadaNoTerreno <= 0))
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaValuacionesNoTerreno = 1;
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValuacionesNoTerreno), _mensajeValuacionNoTerreno);
                    }
                    //Se verifica que se haya ingresado el monto de la última tasación del no terreno
                    else if ((codTipoBien == 2) && (montoUltimaTasacionNoTerreno == 0))
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaValuacionesNoTerreno = 1;
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValuacionesNoTerreno), _mensajeMontoUltimaTasacionNoTerrenoCero);
                    }
                    //Se valida que la fecha de construcción está asignada
                    else if ((fechaConstruccion == fechaNula) || (fechaConstruccion == DateTime.MinValue))
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaValuacionesNoTerreno = 1;
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValuacionesNoTerreno), _mensajeValuacionNoTerreno);
                    }
                    //Se verifica si la fecha de construcción está asignada, no la de constitución y la de presentación
                    else if ((codTipoBien == 2)
                            && (fechaConstruccion != fechaNula)
                            && ((fechaValuacion == DateTime.MinValue) || (fechaPresentacion == DateTime.MinValue)))
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaValuacionesNoTerreno = 2;
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValuacionesNoTerreno), _mensajeValuacionNoTerreno);
                    }
                    //Se valida que la fecha de construcción sea menor a la de constitución
                    else if ((codTipoBien == 2)
                            && (fechaConstruccion != fechaNula)
                            && ((fechaValuacion != DateTime.MinValue) && (fechaConstruccion > fechaValuacion)))
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaValuacionesNoTerreno = 3;
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValuacionesNoTerreno), _mensajeValuacionNoTerrenoFecha);
                    }
                    //Se valida que la fecha de construcción sea menor a la de presentación
                    //else if ((this.codTipoBien == 2)
                    //    && (this.fechaConstruccion != fechaNula)
                    //    && ((this.fechaPresentacion != DateTime.MinValue) && (this.fechaConstruccion > this.fechaPresentacion)))
                    //{
                    //    esValida = false;
                    //    errorValidaciones = true;
                    //    desplegarErrorVentanaEmergente = true;
                    //    inconsistenciaValuacionesNoTerreno = 3;
                    //    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValuacionesNoTerreno), _mensajeValuacionNoTerrenoFecha);
                    //}
                }
                #endregion Se aplica la validación correspondiente a los datos del no terreno

                #region Se aplica la validación correspondiente a la fecha de vencimiento

                //Se valida si la fecha es nula o vacía
                if (fechaVencimiento == DateTime.MinValue)
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaFechaVencimiento = 1;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaVencimiento), _mensajeFechaVencimientoInvalida);
                }
                //Se valida que la fecha de vencimiento no sea menor o igual a la fecha de constitución, presentación o de valuación
                else if ((fechaConstitucion != DateTime.MinValue) && (fechaPresentacion != DateTime.MinValue)
                        && (fechaValuacion != fechaNula)
                        && (fechaVencimiento <= fechaConstitucion) || (fechaVencimiento <= fechaPresentacion)
                        || (fechaVencimiento <= fechaValuacion))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaFechaVencimiento = 2;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaVencimiento), _mensajeFechaVencimientoInvalida);
                }

                #endregion Se aplica la validación correspondiente a la fecha de vencimiento

                #region Se aplica la validación correspondiente a la fecha de prescripción

                //Se verifica que la fecha de vencimiento no sea nula o vacía
                if (fechaVencimiento == DateTime.MinValue)
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaFechaPrescripcion = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaPrescripcion), _mensajeFechaPrescripcionSinCalcular);
                }
                //Se verifica que la fecha de prescripción no sea nula o vacía
                else if (fechaPrescripcion == DateTime.MinValue)
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaFechaPrescripcion = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaPrescripcion), _mensajeFechaPrescripcionInvalida);
                }
                //Si las fechas son válidas, se procede a relizar el cálculo de la fecha de prescripción
                else
                {
                    int annosCalculoPrescripcion = ObtenerCantidadAnnosPrescripcion(codTipoGarantiaReal);

                    fechaPrescripcionCalculada = fechaVencimiento.AddYears(annosCalculoPrescripcion);

                    //Primero se verifica si la fecha calcula es diferente a la del SICC
                    if (fechaPrescripcion != fechaPrescripcionCalculada)
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaFechaPrescripcion = true;
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaPrescripcion), _mensajeFechaPrescripcionInvalida);
                    }
                    else //Si las fechas son iguales, entonces se verifica que no se menor a la fecha de constitución, presentación, valuación o vencimiento
                    {
                        StringBuilder sbCamposMayores = new StringBuilder(); //" Fecha de Constitución, Fecha de Presentación, Fecha de Valuación o Fecha de Vencimiento. Favor verificar y ajustar.");

                        if (fechaPrescripcion < fechaConstitucion)
                        {
                            sbCamposMayores.Append(" Fecha de Constitución");
                        }

                        if (fechaPrescripcion < fechaPresentacion)
                        {
                            sbCamposMayores.Append(((sbCamposMayores.Length > 0) ? ", Fecha de Presentación" : " Fecha de Presentación"));
                        }

                        if (fechaPrescripcion < fechaValuacion)
                        {
                            sbCamposMayores.Append(((sbCamposMayores.Length > 0) ? ", Fecha de Valuación" : " Fecha de Valuación"));
                        }

                        if (fechaPrescripcion < fechaVencimiento)
                        {
                            sbCamposMayores.Append(((sbCamposMayores.Length > 0) ? ", Fecha de Vencimiento" : " Fecha de Vencimiento"));
                        }

                        if (sbCamposMayores.Length > 0)
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaFechaPrescripcion = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaPrescripcion), (_mensajeFechaPrescripcionMenor.Replace("@1", sbCamposMayores.ToString())));
                        }
                    }
                }

                #endregion Se aplica la validación correspondiente a la fecha de prescripción

                #region Se aplica la validación correspondiente a los datos del avalúo diferentes al SICC

                //Se valida si tanto la fecha como el monto total del avalúo son diferentes a los registrados en el SICC
                if (fechaValuacionSICC == fechaNula)
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaAvaluoDiferenteSicc = 4;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.DatosAvaluosIncorrectos), _mensajeFechaAvaluoNoExisteSICC);
                }
                else if ((fechaValuacionSICC != fechaValuacion) && (montoTotalAvaluoSICC != montoTotalAvaluo))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaAvaluoDiferenteSicc = 3;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.DatosAvaluosIncorrectos), _mensajeDatosAvaluoDiferenteSICC);
                }
                //Se verifica si sólo la fecha de valuación es distinta
                else if (fechaValuacionSICC != fechaValuacion)
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaAvaluoDiferenteSicc = 1;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.DatosAvaluosIncorrectos), _mensajeFechaAvaluoDiferenteSICC);
                }
                //Se valida que sólo el monto total del avalúo sea diferente
                else if (montoTotalAvaluoSICC != montoTotalAvaluo)
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaAvaluoDiferenteSicc = 2;

                    //Aquí se determina el mensaje a mostrar, en este caso ser el que corresponde al monto en que se quiere guardar los cambios
                    if (validarCamposRequeridos)
                    {
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.DatosAvaluosIncorrectos), _mensajeMontoTotalAvaluoDiferenteSICC);
                    }
                    else
                    {
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.DatosAvaluosIncorrectos), _mensajeMontoTotalAvaluoDiferenteSICC);
                    }
                }

                #endregion Se aplica la validación correspondiente a los datos del avalúo diferentes al SICC

                #region Se aplica la validación correspondiente a la fecha de construcción

                //Se valida si para el tipo de bien 1 (Terrenos) se ha registrado una fecha de construcción
                if ((codTipoBien == 1) && (fechaConstruccion != fechaNula) && (fechaConstruccion != DateTime.MinValue))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaFechaConstruccion = 1;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaConstruccion), _mensajeFechaConstruccionInvalida);
                }
                //Se valida si el tipo de bien es igual a 2 (Edificaciones)
                else if (codTipoBien == 2)
                {
                    //Se verifica si no se ha registrado una fecha de construcción
                    if ((fechaConstruccion == fechaNula) || (fechaConstruccion == DateTime.MinValue))
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaFechaConstruccion = 2;
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaConstruccion), _mensajeFechaConstruccionInvalida);
                    }
                }

                #endregion Se aplica la validación correspondiente a la fecha de construcción

                #region Se aplica la validación correspondiente a la fecha del último seguimiento

                //Se verifica si la fecha del último seguimiento no fue proporcionada
                if ((fechaUltimoSeguimiento == fechaNula) || (fechaUltimoSeguimiento == DateTime.MinValue))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = ((desplegarErrorVentanaEmergente) ? true : false);
                    inconsistenciaFechaUltimoSeguimiento = 1;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaUltimoSeguimiento), _mensajeFechaUltimoSeguimientoFaltante);
                }

                #endregion Se aplica la validación correspondiente a la fecha del último seguimiento

                #region Se aplica la validación correspondiente a la validez del monto del avalúo actualizado del terreno

                //Se verifica si todos los elementos requeridos para la validación fueron proporcionados
                if ((codTipoBien == 1) && (fechaValuacion != fechaNula) && (fechaValuacion != DateTime.MinValue))
                {
                    double diferenciaAnnos = UtilitariosComun.DateDiff("Y", fechaValuacion, DateTime.Now);

                    //Se valida si el porcentaje de aceptación es correcto para la vigencia del avalúo
                    if ((diferenciaAnnos >= 5) && (porcentajeAceptacion > 40))
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaValidezMontoAvaluoActualizadoTerreno = 1;
                        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValidezMontoTasActTerreno), _mensajeValidezMtoAvalActTerrenoPorcMay);
                    }
                    //else if ((diferenciaAnnos < 5) && (this.porcentajeAceptacion <= 40))
                    //{
                    //    esValida = false;
                    //    errorValidaciones = true;
                    //    desplegarErrorVentanaEmergente = true;
                    //    inconsistenciaValidezMontoAvaluoActualizadoTerreno = 2;
                    //    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValidezMontoTasActTerreno), _mensajeValidezMtoAvalActTerrenoPorcMen);
                    //}
                    ////Se valida que si los montos de la última tasación del terreno y el monto de la tasación actualizada del terreno calculado son diferentes 
                    //else if (this.montoUltimaTasacionTerreno > this.montoTasacionActualizadaTerreno)
                    //{
                    //    esValida = false;
                    //    errorValidaciones = true;
                    //    desplegarErrorVentanaEmergente = true;
                    //    inconsistenciaValidezMontoAvaluoActualizadoTerreno = 3;
                    //    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValidezMontoTasActTerreno), _mensajeValidezMtoAvalActTerrenoMontosDiff);
                    //}
                }

                #endregion Se aplica la validación correspondiente a la validez del monto del avalúo actualizado del terreno

                #region Se aplica la validación correspondiente a la validez del monto del avalúo actualizado del no terreno

                //Se valida si no se cuenta con alguno de los elementos requeridos para la aplicación de la validación
                if ((codTipoBien == 2) && ((fechaValuacion == fechaNula) || (fechaValuacion == DateTime.MinValue)))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaValidezMontoAvaluoActualizadoNoTerreno = 1;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValidezMontoTasActNoTerreno), _mensajeValidezMtoAvalActNoTerrenoSinDatos);
                }
                ////Se valida que las validaciones se apliquen sólo cuando el tipo de bien es igual a 2 (Edificaciones)
                //else if (this.codTipoBien == 2)
                //{
                //    //Se verifica si el monto de la última tasación del no terreno es mayor a la tasación actualizada del no terreno calculado
                //    if (this.montoUltimaTasacionNoTerreno > this.montoTasacionActualizadaNoTerreno)
                //    {
                //        esValida = false;
                //        errorValidaciones = true;
                //        desplegarErrorVentanaEmergente = true;
                //        inconsistenciaValidezMontoAvaluoActualizadoNoTerreno = 3;
                //        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ValidezMontoTasActNoTerreno), _mensajeValidezMtoAvalActNoTerrenoMontosDif);
                //    }
                //}

                #endregion Se aplica la validación correspondiente a la validez del monto del avalúo actualizado del no terreno

                #region Se aplica la validación correspondiente a la fecha de constitución

                //Se valida si la fecha es nula o vacía
                if (fechaConstitucion == DateTime.MinValue)
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;
                    inconsistenciaFechaConstitucion = true;
                    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaConstitucion), _mensajeFechaConstitucionInvalida);
                }

                #endregion Se aplica la validación correspondiente a la fecha de constitución

                #region Se aplican las validaciones correspondientes a la póliza

                //Se valida si la garantía no posee una póliza asociada
                if ((polizaSapAsociada == null)
                    && (polizasSap != null)
                    && (polizasSap.Count > 0)
                    && (polizasSap.ObtenerCantidadPolizasAsociadas() > 0))
                {
                    esValida = false;
                    errorValidaciones = true;
                    desplegarErrorVentanaEmergente = true;

                    if (!errorRelacionGarantiaPoliza)
                    {
                        inconsistenciaPolizaInvalida = true;

                        if (!listaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaInvalida)))
                        {
                            listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaInvalida), _mensajePolizaInvalida);
                        }
                    }

                    if ((MostrarErrorRelacionTipoBienTipoPolizaSap) && (errorRelacionGarantiaPoliza))
                    {
                        if (!listaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaInvalidaTipoBienPoliza)))
                        {
                            listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaInvalidaTipoBienPoliza), _mensajePolizaInvalidaRelacionTipoBienPoliza);
                        }
                    }
                }
                else //La garantía posee una póliza asociada
                    if (polizaSapAsociada != null)
                    {
                        if ((MostrarErrorRelacionTipoBienTipoPolizaSap) && (errorRelacionGarantiaPoliza))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;

                            if (!listaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaInvalidaTipoBienPoliza)))
                            {
                                listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaInvalidaTipoBienPoliza), _mensajePolizaInvalidaRelacionTipoBienPoliza);
                            }
                        }

                        //Se valida si la póliza ha sido cambiada
                        if (!polizaSapAsociada.CodigoSapValido)
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPolizaInvalida = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaInvalida), _mensajePolizaInvalida);
                        }

                        //Se verifica la existencia de un infraseguro
                        if (polizaSapAsociada.MontoPolizaSapColonizado < montoUltimaTasacionNoTerreno)
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            InconsistenciaGarantiaInfraSeguro = true;
                            //listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.InfraSeguro), _mensajeMontoPolizaMenorMontoUltimaTasacionTerreno);

                            if (!listaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.MontoPolizaNoCubreBien)))
                            {
                                listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.MontoPolizaNoCubreBien), _mensajeMontoPolizaMenorMontoUltimaTasacionTerreno);
                            }

                            listaMensajesValidaciones.Remove(((int)Enumeradores.Inconsistencias.InfraSeguro));
                            string[] listaOperaciones = OperacionesRelacionadas.ObtenerDatosOperaciones(Enumeradores.Tipos_Operaciones.Todos);
                            string listaOperacionesDirecta = (((listaOperaciones.Length > 1) && (listaOperaciones[0].Length > 0)) ? listaOperaciones[0] : string.Empty);
                            string listaOperacionesContrato = (((listaOperaciones.Length > 1) && (listaOperaciones[1].Length > 0)) ? listaOperaciones[1] : string.Empty);

                            if ((listaOperacionesDirecta.Length > 0) || (listaOperacionesContrato.Length > 0))
                            {
                                listaMensajesValidaciones.Remove(((int)Enumeradores.Inconsistencias.InfraSeguro));

                                string mensajeMostrar = mensajeGarantiaInfraSeguro.Replace("@1", listaOperacionesDirecta).Replace("@2", listaOperacionesContrato);

                                listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.InfraSeguro), mensajeMostrar);
                            }
                        }

                        //Se verifica si existen montos de acrencia diferente de una misma garantía y póliza
                        //if ((this.OperacionesRelacionadas != null) && (this.OperacionesRelacionadas.Count > 0) && (this.OperacionesRelacionadas.TieneGarantiasDiferentes()))
                        //{
                        //    esValida = false;
                        //    errorValidaciones = true;
                        //    desplegarErrorVentanaEmergente = true;
                        //    inconsistenciaMontoAcreenciaDiferente = true;

                        //    string[] listaOperaciones = OperacionesRelacionadas.ObtenerDatosOperaciones(Enumeradores.Tipos_Operaciones.Todos);
                        //    string listaOperacionesDirecta = (((listaOperaciones.Length > 1) && (listaOperaciones[0].Length > 0)) ? listaOperaciones[0] : string.Empty);
                        //    string listaOperacionesContrato = (((listaOperaciones.Length > 1) && (listaOperaciones[1].Length > 0)) ? listaOperaciones[1] : string.Empty);

                        //    if ((listaOperacionesDirecta.Length > 0) || (listaOperacionesContrato.Length > 0))
                        //    {
                        //        string mensajeMostrar = mensajeMontoAcreenciaDiferente.Replace("@1", listaOperacionesDirecta).Replace("@2", listaOperacionesContrato);

                        //        listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.AcreenciasDiferentes), mensajeMostrar);
                        //    }
                        // }

                        //Se revisa si se dió algún cambio en el monto de la póliza, esto en el SAP, y el mismo es menor al anterior
                        if (polizaSapAsociada.MontoPolizaMenor)
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaCambioMontoPoliza = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.MontoPolizaMenor), _mensajeCambioMontoPoliza);
                        }

                        //Se verifica si la fecha de vencimiento fue modificada en el SAP y la misma es menor a la anterior
                        if (polizaSapAsociada.FechaVencimientoMenor)
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaCambioFechaVencimiento = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.VencimientoPolizaMenor), _mensajeCambioFechaVencimientoPoliza);
                        }

                        //Se revisa si el monto de la acreencia es mayor al monto de la póliza
                        if (polizaSapAsociada.MontoAcreenciaPolizaSap > polizaSapAsociada.MontoPolizaSapColonizado)
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaMontoAcreenciaInvalido = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.MontoAcreenciaInvalido), _mensajeMontoAcreenciaInvalido);
                        }

                        //Se verifica si se ha dado algún cambio en los datos del acreedor
                        if ((polizaSapAsociada.CambioIdAcreedor) && (polizaSapAsociada.CambioNombreAcreedor))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaCambioDatosAcreedor = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.DatosAcreedorDiferentes), _mensajeCambioDatosAcreedorPoliza);
                        }
                        //Se revisa si el cambio se dio sólo en la cédula del acreedor
                        else if ((polizaSapAsociada.CambioIdAcreedor) && (!polizaSapAsociada.CambioNombreAcreedor))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaCambioIdAcreedor = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.IdAcreedorDiferente), _mensajeCambioCedulaAcreedorPoliza);
                        }
                        //Se verifica si el cambio se dio sólo en el nombre del acreedor
                        else if ((polizaSapAsociada.CambioNombreAcreedor) && (!polizaSapAsociada.CambioIdAcreedor))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaCambioAcreedor = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.NombreAcreedorDiferente), _mensajeCambioAcreedorPoliza);
                        }

                        //Se verifica las coberturas obligatorias fueron asignadas
                        if (polizaSapAsociada.DiferenciaCoberturasObligatorias != 0)
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            InconsistenciaCoberturasObligatoriasInvalidas = true;

                            if (!listaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.CoberturasObligatoriasInvalidas)))
                            {
                                listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.CoberturasObligatoriasInvalidas), _mensajeCoberturasObligatoriasInvalidas);
                            }
                        }
                    }

                #endregion Se aplican las validaciones correspondientes a la póliza

                #region Se carga el mensaje con las operaciones respaldadas por la garantía

                //Se carga el mensaje en el que se muestran las operaciones afectadas por el avalúo.
                if ((OperacionesRelacionadas != null) && (OperacionesRelacionadas.Count > 0))
                {
                    listaMensajesValidaciones.Remove(((int)Enumeradores.Inconsistencias.ListaOperaciones));
                    string[] listaOperaciones = OperacionesRelacionadas.ObtenerDatosOperaciones(Enumeradores.Tipos_Operaciones.Todos);
                    string listaOperacionesDirecta = (((listaOperaciones.Length > 1) && (listaOperaciones[0].Length > 0)) ? listaOperaciones[0] : string.Empty);
                    string listaOperacionesContrato = (((listaOperaciones.Length > 1) && (listaOperaciones[1].Length > 0)) ? listaOperaciones[1] : string.Empty);

                    if ((listaOperacionesDirecta.Length > 0) || (listaOperacionesContrato.Length > 0))
                    {
                        string mensajeMostrar = mensajeDatosAvaluosInvalidos.Replace("@1", listaOperacionesDirecta).Replace("@2", listaOperacionesContrato);

                        //listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.ListaOperaciones), mensajeMostrar);
                        listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.ListaOperaciones), mensajeMostrar);
                    }
                }

                #endregion Se carga el mensaje con las operaciones respaldadas por la garantía

                #region Manipulación de Controles Web

                //Se bloquean estos controles cuando existe un problema con la fecha de presentación
                if (inconsistenciaFechaPresentacion)
                {
                    listaControlesWeb[((int)Enumeradores.ControlesWebGarantiasReales.IndicadorInscripcion)] = false;
                    listaControlesWeb[((int)Enumeradores.ControlesWebGarantiasReales.MontoMitigador)] = false;
                    listaControlesWeb[((int)Enumeradores.ControlesWebGarantiasReales.PorcentajeAceptacion)] = false;
                }

                //Se bloquean los controles cuando existe un problema con el indicador de inscripción
                if (inconsistenciaIndicadorInscripcion)
                {
                    listaControlesWeb[((int)Enumeradores.ControlesWebGarantiasReales.MontoMitigador)] = false;
                    listaControlesWeb[((int)Enumeradores.ControlesWebGarantiasReales.PorcentajeAceptacion)] = false;
                }

                ////Se bloquean los controles cuando existe un problema con el porcentaje de aceptación
                //if ((this.inconsistenciaPorcentajeAceptacion) || (this.porcentajeAceptacion == 0))
                //{
                //    listaControlesWeb[((int)Enumeradores.ControlesWebGarantiasReales.MontoMitigador)] = false;
                //}

                ////Se bloquean los controles cuando la garantía no posee avalúo asociado
                //if (montoTotalAvaluo == 0)
                //{
                //    listaControlesWeb[((int)Enumeradores.ControlesWebGarantiasReales.MontoMitigador)] = false;
                //}

                //Se bloquean los controles cuando existe un problema con el tipo de bien
                if (inconsistenciaTipoBien)
                {
                    listaControlesWeb[((int)Enumeradores.ControlesWebGarantiasReales.TipoMitigador)] = false;
                }

                //Se bloquean los controles cuando existe un problema con los datos del terreno del avalúo
                if ((codTipoGarantiaReal == 1) && (codTipoBien == 1) && (!inconsistenciaValuacionesTerreno))
                {
                    listaControlesWeb[((int)Enumeradores.ControlesWebGarantiasReales.MontoUltimaTasacionNoTerreno)] = false;
                    listaControlesWeb[((int)Enumeradores.ControlesWebGarantiasReales.FechaConstruccion)] = false;
                }

                #endregion Manipulación de Controles Web

                #region Se aplican las validaciones correspondientes al porcentaje de aceptacion calculado

                DateTime fechaActualSistema = DateTime.Now.Date;

                if (!HabilitarPorcentajesAceptacionAvaluo())
                {

                    if (porcentajeAceptacionCalculadoOriginal > 0)
                    {
                        //aplica validciones

                        #region Tipo Bien 1

                        if ((codTipoBien == 1) && ((codTipoGarantiaReal == 1) || (codTipoGarantiaReal == 2)))
                        {
                            //Se verifica que el fecha de valuacion sea mayor a 5 años en relacion a la fecha del sistema
                            if (UtilitariosComun.DateDiff("Y", fechaValuacion, fechaActualSistema) > 5)
                            {
                                esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienUno = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;

                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.FechaValuacionMayor)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaValuacionMayor), _mensajePorceAcepFechaValuacionMayorCincoAnnosBienUno);
                                }
                            }

                            //Se verifica que la fecha de ultimo seguimiento es mayor 1 año en realacion a la fecha del sistema
                            if (UtilitariosComun.DateDiff("Y", fechaUltimoSeguimiento, fechaActualSistema) > 1)
                            {
                                esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepFechaSeguimientoMayorUnAnno = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;

                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor), _mensajePorceAcepFechaSeguimientoMayorUnAnno);
                                }
                            }

                            //Se verifica si tiene una poliza asociada
                            if ((polizaSapAsociada != null) && (!errorRelacionGarantiaPoliza))
                            {
                                esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepTipoBienUnoPolizaAsociada = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;

                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaAsociada)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaAsociada), _mensajePorceAcepTipoBienUnoPolizaAsociada);
                                }
                            }

                        }
                        #endregion Tipo Bien 1

                        #region Tipo Bien 2

                        if ((codTipoBien == 2) && ((codTipoGarantiaReal == 1) || (codTipoGarantiaReal == 2)))
                        {

                            //if ((this.fechaValuacion != fechaNula) && (this.fechaUltimoSeguimiento != fechaNula) 
                            //    && (this.fechaValuacion !=  DateTime.MinValue) && (this.fechaUltimoSeguimiento !=  DateTime.MinValue))
                            //{
                            //    double diferenciaMesesFechaValuacion = UtilitariosComun.DateDiff("M", this.fechaValuacion, fechaActualSistema); // (this.fechaValuacion.Month - fechaActualSistema.Month) + 12 * (this.fechaValuacion.Year - fechaActualSistema.Year);
                            //    double diferenciaMesesFechaUltSegui = UtilitariosComun.DateDiff("M", this.fechaUltimoSeguimiento, fechaActualSistema); //(this.fechaUltimoSeguimiento.Month - fechaActualSistema.Month) + 12 * (this.fechaUltimoSeguimiento.Year - fechaActualSistema.Year);

                            //Se verifica que la fecha de valuacion MAYOR A 18 MESES FECHA SISTEMA, MIENTRAS EXISTA DIFERENCIA MAYOR A 3 MESES ENTRE FECHA SEGUIMIENTO Y FECHA DEL SISTEMA Y EL DEUDOR NO HABITE LA VIVIENDA

                            //Se solicita eliminar esta validación, mediante el IRQA:
                            //if ((diferenciaMesesFechaValuacion > 18) && (diferenciaMesesFechaUltSegui > 3) && (!this.indicadorViviendaHabitadaDeudor))
                            //{
                            //    esValida = false;
                            //    errorValidaciones = true;
                            //    desplegarErrorVentanaEmergente = true;
                            //    inconsistenciaPorceAcepFechaValuacionMayorDieciochoMeses = true;
                            //    inconsistenciaPorcentajeAceptacionCalculado = true;
                            //    //listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaValuacionMayor), _mensajePorceAcepFechaValuacionMayorDieciochoMeses);
                            //}

                            //if ((diferenciaMesesFechaValuacion > 18) && (diferenciaMesesFechaUltSegui <= 3) && (this.indicadorViviendaHabitadaDeudor))
                            //{
                            //    esValida = false;
                            //    errorValidaciones = true;
                            //    desplegarErrorVentanaEmergente = true;
                            //    inconsistenciaPorceAcepFechaValuacionMayorDieciochoMeses = true;
                            //    inconsistenciaPorcentajeAceptacionCalculado = true;
                            // }   

                            //}                     

                            //Se verifica que la fecha de ultimo seguimiento es mayor 1 año en realacion a la fecha del sistema             
                            if ((fechaValuacion != fechaNula) && (fechaValuacion != DateTime.MinValue) &&
                                (UtilitariosComun.DateDiff("Y", fechaValuacion, fechaActualSistema) > 5))
                            {
                                //esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepFechaValuacionMayorDieciochoMeses = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;

                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.FechaValuacionMayor)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaValuacionMayor), _mensajePorceAcepFechaValuacionMayorCincoAnnosBienTres);
                                }

                            }

                            //Se verifica que la fecha de ultimo seguimiento es mayor 1 año en realacion a la fecha del sistema             
                            if ((fechaUltimoSeguimiento != fechaNula) && (fechaUltimoSeguimiento != DateTime.MinValue) &&
                                (UtilitariosComun.DateDiff("Y", fechaUltimoSeguimiento, fechaActualSistema) > 1) && (!indicadorViviendaHabitadaDeudor))
                            {
                                //esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepFechaSeguimientoMayorUnAnno = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;

                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor), _mensajePorceAcepFechaSeguimientoMayorUnAnno);
                                }

                            }


                            //Se verifica si tiene no una poliza asociada
                            if ((polizaSapAsociada == null)
                                || ((polizaSapAsociada != null) && (errorRelacionGarantiaPoliza)))
                            {
                                //esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepNoPolizaAsociada = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;

                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaNoAsociada)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaNoAsociada), _mensajePorceAcepNoPolizaAsociada);
                                }
                            }
                            else
                            { //tiene poliza

                                //Se verifica si al guardar existe el mensaje de que no tiene póliza asociada, esto para eliminarla
                                if ((aplicarValidacionCamposRequeridos)
                                   && (ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaNoAsociada))))
                                {
                                    listaMensajesValidaciones.Remove((int)Enumeradores.Inconsistencias.PolizaNoAsociada);
                                }

                                if ((polizaSapAsociada.FechaVencimientoPolizaSap != fechaNula) && (polizaSapAsociada.FechaVencimientoPolizaSap != DateTime.MinValue))
                                {
                                    //Se verifica si tiene una poliza asociada y la fecha de vencimiento de la poliza es menor a la fecha del sistema
                                    if (polizaSapAsociada.FechaVencimientoPolizaSap < fechaActualSistema)
                                    {
                                        esValida = false;
                                        errorValidaciones = true;
                                        desplegarErrorVentanaEmergente = true;
                                        inconsistenciaPorceAcepPolizaFechaVencimientoMenor = true;
                                        inconsistenciaPorcentajeAceptacionCalculado = true;

                                        if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaAsociadaVencimientoMenor)))
                                        {
                                            listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaAsociadaVencimientoMenor), _mensajePorceAcepPolizaFechaVencimientoMenor);
                                        }
                                    }

                                    //Se verifica si tiene una poliza asociada, fecha de vencimiento es mayor a la fecha del sistema y monto poliza no cubre monto ultima tasacion no terreno
                                    if ((polizaSapAsociada.FechaVencimientoPolizaSap > fechaActualSistema) && (polizaSapAsociada.MontoPolizaSapColonizado < montoUltimaTasacionNoTerreno))
                                    {
                                        esValida = false;
                                        errorValidaciones = true;
                                        desplegarErrorVentanaEmergente = true;
                                        inconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno = true;
                                        inconsistenciaPorcentajeAceptacionCalculado = true;
                                        //listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaAsociadaMontoMenor), _mensajePorceAcepPolizaFechaVencimientoMontoNoTerreno);

                                    }
                                }
                            }


                        }
                        #endregion Tipo Bien 2

                        #region Tipo Bien 3


                        if ((codTipoBien == 3) && (codTipoGarantiaReal == 3))
                        {
                            //Se verifica que el fecha de valuacion sea mayor a 5 años en relacion a la fecha del sistema
                            if (UtilitariosComun.DateDiff("Y", fechaValuacion, fechaActualSistema) > 5)
                            {
                                //esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienTres = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;

                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.FechaValuacionMayor)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaValuacionMayor), _mensajePorceAcepFechaValuacionMayorCincoAnnosBienTres);
                                }
                            }

                            //Se verifica que la fecha de ultimo seguimiento es mayor 1 año en realacion a la fecha del sistema
                            //if (UtilitariosComun.DateDiff("Y", this.fechaUltimoSeguimiento, fechaActualSistema) > 1)
                            //{
                            //    esValida = false;
                            //    errorValidaciones = true;
                            //    desplegarErrorVentanaEmergente = true;                            
                            //    inconsistenciaPorceAcepFechaSeguimientoMayorUnAnnoBienTres = true;
                            //    inconsistenciaPorcentajeAceptacionCalculado = true;
                            //    listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor), _mensajePorceAcepFechaSeguimientoMayorUnAnnoBienTres);

                            //}

                            //Se verifica si no tiene una poliza asociada
                            if ((polizaSapAsociada == null) || ((polizaSapAsociada != null) && (errorRelacionGarantiaPoliza)))
                            {
                                //esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepNoPolizaAsociada = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;
                                //  listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaNoAsociada), _mensajePorceAcepNoPolizaAsociada);
                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaNoAsociada)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaNoAsociada), _mensajePorceAcepNoPolizaAsociada);
                                }
                            }
                            else
                            { //tiene poliza

                                if ((polizaSapAsociada.FechaVencimientoPolizaSap != fechaNula) && (polizaSapAsociada.FechaVencimientoPolizaSap != DateTime.MinValue))
                                {
                                    //Se verifica si tiene una poliza asociada y la fecha de vencimiento de la poliza es menor a la fecha del sistema
                                    if (polizaSapAsociada.FechaVencimientoPolizaSap < fechaActualSistema)
                                    {
                                        esValida = false;
                                        errorValidaciones = true;
                                        desplegarErrorVentanaEmergente = true;
                                        inconsistenciaPorceAcepPolizaFechaVencimientoMenor = true;
                                        inconsistenciaPorcentajeAceptacionCalculado = true;

                                        if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaAsociadaVencimientoMenor)))
                                        {
                                            listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaAsociadaVencimientoMenor), _mensajePorceAcepPolizaFechaVencimientoMenor);
                                        }
                                    }


                                    //Se verifica si tiene una poliza asociada, fecha de vencimiento es mayor a la fecha del sistema y monto poliza no cubre monto ultima tasacion no terreno
                                    if ((polizaSapAsociada.FechaVencimientoPolizaSap > fechaActualSistema) && (polizaSapAsociada.MontoPolizaSapColonizado < montoUltimaTasacionNoTerreno))
                                    {
                                        esValida = false;
                                        errorValidaciones = true;
                                        desplegarErrorVentanaEmergente = true;
                                        inconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno = true;
                                        inconsistenciaPorcentajeAceptacionCalculado = true;

                                        //if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaAsociadaMontoMenor)))
                                        //{
                                        //    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaAsociadaMontoMenor), _mensajePorceAcepPolizaFechaVencimientoMontoNoTerreno);
                                        //}
                                    }
                                }

                            }

                        }

                        #endregion Tipo Bien 3

                        #region  Tipo Bien 4

                        if ((codTipoBien == 4) && (codTipoGarantiaReal == 3))
                        {
                            //Se verifica que el fecha de valuacion sea mayor a 5 años en relacion a la fecha del sistema
                            if (UtilitariosComun.DateDiff("Y", fechaValuacion, fechaActualSistema) > 5)
                            {
                                //esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienTres = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;

                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.FechaValuacionMayor)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaValuacionMayor), _mensajePorceAcepFechaValuacionMayorCincoAnnosBienTres);
                                }
                            }

                            if (fechaUltimoSeguimiento != fechaNula)
                            {
                                double diferenciaMesesFechaSeguimiento = UtilitariosComun.DateDiff("M", fechaUltimoSeguimiento, fechaActualSistema); // (this.fechaUltimoSeguimiento.Month - fechaActualSistema.Month) + 12 * (this.fechaUltimoSeguimiento.Year - fechaActualSistema.Year);

                                //Se verifica que la fecha de ultimo seguimiento es mayor 6 meses en realacion a la fecha del sistema                  
                                if (diferenciaMesesFechaSeguimiento > 6)
                                {
                                    //esValida = false;
                                    errorValidaciones = true;
                                    desplegarErrorVentanaEmergente = true;
                                    inconsistenciaPorceAcepFechaSeguimientoMayorSeisMeses = true;
                                    inconsistenciaPorcentajeAceptacionCalculado = true;

                                    if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)))
                                    {
                                        listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor), _mensajePorceAcepFechaSeguimientoMayorSeisMeses);
                                    }
                                }
                            }

                            //Se verifica si tiene no una poliza asociada
                            if ((polizaSapAsociada == null) || ((polizaSapAsociada != null) && (errorRelacionGarantiaPoliza)))
                            {
                                //esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepNoPolizaAsociada = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;
                                //listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaNoAsociada), _mensajePorceAcepNoPolizaAsociada);
                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaNoAsociada)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaNoAsociada), _mensajePorceAcepNoPolizaAsociada);
                                }
                            }

                            else
                            {//tiene poliza

                                if ((polizaSapAsociada.FechaVencimientoPolizaSap != fechaNula) && (polizaSapAsociada.FechaVencimientoPolizaSap != DateTime.MinValue))
                                {
                                    //Se verifica si tiene una poliza asociada y la fecha de vencimiento de la poliza es menor a la fecha del sistema
                                    if (polizaSapAsociada.FechaVencimientoPolizaSap < fechaActualSistema)
                                    {
                                        esValida = false;
                                        errorValidaciones = true;
                                        desplegarErrorVentanaEmergente = true;
                                        inconsistenciaPorceAcepPolizaFechaVencimientoMenor = true;
                                        inconsistenciaPorcentajeAceptacionCalculado = true;

                                        if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaAsociadaVencimientoMenor)))
                                        {
                                            listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaAsociadaVencimientoMenor), _mensajePorceAcepPolizaFechaVencimientoMenor);
                                        }
                                    }

                                    //Se verifica si tiene una poliza asociada, fecha de vencimiento es mayor a la fecha del sistema y monto poliza no cubre monto ultima tasacion no terreno
                                    if ((polizaSapAsociada.FechaVencimientoPolizaSap > fechaActualSistema) && (polizaSapAsociada.MontoPolizaSapColonizado < montoUltimaTasacionNoTerreno))
                                    {
                                        esValida = false;
                                        errorValidaciones = true;
                                        desplegarErrorVentanaEmergente = true;
                                        inconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno = true;
                                        inconsistenciaPorcentajeAceptacionCalculado = true;

                                        //if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaAsociadaMontoMenor)))
                                        //{
                                        //    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaAsociadaMontoMenor), _mensajePorceAcepPolizaFechaVencimientoMontoNoTerreno);
                                        //}
                                    }
                                }

                            }

                        }
                        #endregion Tipo Bien 4


                    }

                    if ((codTipoBien >= 1) && (codTipoBien <= 4))
                    {
                        //si el PorcentajeAceptacionCalculado da 0 se debe corregir la inconsitencia antes de continuar 
                        if (porcentajeAceptacion > PorcentajeAceptacionCalculado) //PorcentajeAceptacionCalculado se inicializa en 0, 
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorceAcepMayorPorceAcepCalculado = true;
                            listaErroresValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcentajeAceptacionMayorCalculado), _mensajePorceAcepMayorPorceAcepCalculado);

                        }
                    }
                }

                #endregion Se aplican las validaciones correspondientes al porcentaje de aceptacion calculado
 
                if (HabilitarPorcentajesAceptacionAvaluo())
                {
                    //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
                    #region Se aplican la validaciones correspondientes al Porcentaje de Aceptación Terreno Calculado


                    //BANDERA EXCLUYENTE PARA LOS CASTIGOS
                    bool castigoAplicado = false;

                    //SE INICIALIZA EL PORCENTAJE DE ACEPTACION DEL TERRENO CALCULADO, ESTO POR AQUELLO DE QUE NO HAYAN INCONSISTENCIAS
                    porcentajeAceptacionTerrenoCalculado = porcentajeAceptacionCalculadoOriginal;

                    //SI NO EXISTE SELECCION PARA TIPO MITIGADOR RIESGO
                    if (codTipoMitigador.Equals(-1))
                    {
                        porcentajeAceptacionTerrenoCalculado = 0;
                        castigoAplicado = true;
                    }

                    //EXISTE INCONSISTENCIA EN INDICADOR INSCRIPCION                
                    if (inconsistenciaIndicadorInscripcion)
                    {
                        //NO ANOTADA - NO INSCRITA
                        if (codInscripcion.Equals(1))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcAceptTerrenoCalcNoAnotadaNoInscrita = true;
                            listaErroresValidaciones.Add((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcNoAnotadaNoInscrita, _mensajePorcAceptTerrenoCalcNoAnotadaNoInscrita);
                        }
                        else
                        {
                            //ANOTADA
                            if (codInscripcion.Equals(2))
                            {
                                esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorcAceptTerrenoCalcAnotada = true;
                                listaErroresValidaciones.Add((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcAnotada, _mensajePorcAceptTerrenoCalcAnotada);
                            }
                        }

                        if (!castigoAplicado)
                        {
                            porcentajeAceptacionTerrenoCalculado = 0;
                            castigoAplicado = true;
                        }
                    }

                    //SE VERIFICA QUE LA FECHA ULTIMO SEGUIMIENTO SEA SEA MAYOR A 1 AÑO EN RELACION A LA FECHA DEL SISTEMA
                    if (fechaUltimoSeguimiento != fechaNula)
                    {
                        if ((!codTipoBien.Equals(2)) && (UtilitariosComun.DateDiff("Y", fechaUltimoSeguimiento, fechaActualSistema) > 1))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento = true;
                            
                            if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcFechaUltimoSeguimiento)))
                            {
                                listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcFechaUltimoSeguimiento), _mensajePorcAceptTerrenoCalcFechaUltimoSeguimiento);
                            }

                            if (!castigoAplicado)
                            {
                                porcentajeAceptacionTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                castigoAplicado = true;
                            }
                        }
                        else if ((codTipoBien.Equals(2)) && (UtilitariosComun.DateDiff("Y", fechaUltimoSeguimiento, fechaActualSistema) > 1) && (indicadorViviendaHabitadaDeudor == false))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento = true;

                            if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcFechaUltimoSeguimiento)))
                            {
                                listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcFechaUltimoSeguimiento), _mensajePorcAceptTerrenoCalcFechaUltimoSeguimiento);
                            }

                            if (!castigoAplicado)
                            {
                                porcentajeAceptacionTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                castigoAplicado = true;
                            }
                        }
                    }
                    else
                    {
                        //Si la fecha de último seguimiento es nula, entonces se compara la fecha de valuación, esto porque la fecha dé último seguimiento será igual a la de valuación
                        if ((!codTipoBien.Equals(2)) && (UtilitariosComun.DateDiff("Y", fechaValuacion, fechaActualSistema) > 1))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento = true;

                            if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcFechaUltimoSeguimiento)))
                            {
                                listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcFechaUltimoSeguimiento), _mensajePorcAceptTerrenoCalcFechaUltimoSeguimiento);
                            }

                            if (!castigoAplicado)
                            {
                                porcentajeAceptacionTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                castigoAplicado = true;
                            }
                        }
                        else if ((codTipoBien.Equals(2)) && (UtilitariosComun.DateDiff("Y", fechaValuacion, fechaActualSistema) > 1) && (indicadorViviendaHabitadaDeudor == false))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcAceptTerrenoCalcFechaUltimoSeguimiento = true;

                            if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcFechaUltimoSeguimiento)))
                            {
                                listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcFechaUltimoSeguimiento), _mensajePorcAceptTerrenoCalcFechaUltimoSeguimiento);
                            }

                            if (!castigoAplicado)
                            {
                                porcentajeAceptacionTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                castigoAplicado = true;
                            }
                        }
                    }

                    //SE VERIFICA QUE EL FECHA DE VALUACION SEA MAYOR A 5 AÑOS EN RELACION A LA FECHA DEL SISTEMA
                    if (UtilitariosComun.DateDiff("Y", fechaValuacion, fechaActualSistema) > 5)
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaPorcAceptTerrenoCalcFechaValuacion = true;
 
                        if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcFechaValuacion)))
                        {
                            listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptTerrenoCalcFechaValuacion), _mensajePorcAceptTerrenoCalcFechaValuacion);
                        }

                        if (!castigoAplicado)
                        {
                            porcentajeAceptacionTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                            castigoAplicado = true;
                        }
                    }

                    if(porcentajeAceptacionTerreno > porcentajeAceptacionTerrenoCalculado)
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaPorceAcepTerrenoMayorPorceAcepCalculado = true;
                        listaErroresValidaciones.Add((int)Enumeradores.Inconsistencias.PorcAceptTerrenoMayorCalculado, _mensajePorceAcepTerrenoMayorPorceAcepTerrenoCalculado);

                    }

                    #endregion

                    //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
                    #region Se aplican la validaciones correspondientes al Porcentaje de Aceptación No Terreno Calculado

                    //SE REESTABLECE LA BANDERA PARA SER UTILIZADA EN EL CAMPO PORC ACEPT NO TERRENO CALC
                    castigoAplicado = false;

                    //SE INICIALIZA EL PORCENTAJE DE ACEPTACION DEL TERRENO CALCULADO, ESTO POR AQUELLO DE QUE NO HAYAN INCONSISTENCIAS
                    porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal;

                    //SI NO EXISTE SELECCION PARA TIPO MITIGADOR RIESGO
                    if (codTipoMitigador.Equals(-1))
                    {
                        porcentajeAceptacionNoTerrenoCalculado = 0;
                        castigoAplicado = true;
                    }

                    //EXISTE INCONSISTENCIA EN INDICADOR INSCRIPCION
                    if (inconsistenciaIndicadorInscripcion)
                    {
                        //NO ANOTADA - NO INSCRITA
                        if (codInscripcion.Equals(1))
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcAceptNoTerrenoCalcNoAnotadaNoInscrita = true;
                            listaErroresValidaciones.Add((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcNoAnotadaNoInscrita, _mensajePorcAceptNoTerrenoCalcNoAnotadaNoInscrita);
                        }
                        else
                        {
                            //ANOTADA
                            if (codInscripcion.Equals(2))
                            {
                                esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorcAceptNoTerrenoCalcAnotada = true;
                                listaErroresValidaciones.Add((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcAnotada, _mensajePorcAceptNoTerrenoCalcAnotada);
                            }
                        }

                        if (!castigoAplicado)
                        {
                            porcentajeAceptacionNoTerrenoCalculado = 0;
                            castigoAplicado = true;
                        }
                    }

                    //SI TIPO BIEN IGUAL A EDIFICACIONES Y ( TIPO GARANTIA REAL IGUAL A HIPOTECA COMÚN O CEDULA HIPOTECARIA )
                    if (codTipoBien.Equals(2) && (codTipoGarantiaReal.Equals(1) || codTipoGarantiaReal.Equals(2)))
                    {
                        if (fechaUltimoSeguimiento != fechaNula)
                        {
                            //SE VERIFICA QUE LA FECHA ULTIMO SEGUIMIENTO SEA SEA MAYOR A 1 AÑO EN RELACION A LA FECHA DEL SISTEMA E INIDICADOR DEUDOR HABITA NO ESTÁ ACTIVADO
                            if (UtilitariosComun.DateDiff("Y", fechaUltimoSeguimiento, fechaActualSistema) > 1 && indicadorViviendaHabitadaDeudor == false)
                            {
                                esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento = true;
                                
                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimiento)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimiento), _mensajePorcAceptNoTerrenoCalcFechaUltimoSeguimiento);
                                }

                                if (!castigoAplicado)
                                {
                                    porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                    castigoAplicado = true;
                                }
                            }
                        }
                        else
                        {
                            //Si la fecha de último seguimiento es nula, entonces se compara la fecha de valuación, esto porque la fecha dé último seguimiento será igual a la de valuación
                            if (UtilitariosComun.DateDiff("Y", fechaValuacion, fechaActualSistema) > 1)
                            {
                                esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento = true;

                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimiento)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimiento), _mensajePorcAceptNoTerrenoCalcFechaUltimoSeguimiento);
                                }

                                if (!castigoAplicado)
                                {
                                    porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                    castigoAplicado = true;
                                }
                            }
                        }
                    }

                    ////SI TIPO BIEN DIFERENTE DE TRERENOS O VEHICULOS Y TIPO GARANTIA REAL DIFERENTE DE PRENDAS
                    //if ((codTipoBien > 3) && (!codTipoGarantiaReal.Equals(3)))
                    //{
                    //    if (this.fechaUltimoSeguimiento != fechaNula)
                    //    {
                    //        //SE VERIFICA QUE LA FECHA ULTIMO SEGUIMIENTO SEA SEA MAYOR A 1 AÑO EN RELACION A LA FECHA DEL SISTEMA 
                    //        if (UtilitariosComun.DateDiff("Y", this.fechaUltimoSeguimiento, fechaActualSistema) > 1)
                    //        {
                    //            esValida = false;
                    //            errorValidaciones = true;
                    //            desplegarErrorVentanaEmergente = true;
                    //            inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento = true;
                                
                    //            if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimientoNoVehiculos)))
                    //            {
                    //                listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimientoNoVehiculos), _mensajePorcAceptNoTerrenoCalcFechaUltimoSeguimiento);
                    //            }

                    //            if (!castigoAplicado)
                    //            {
                    //                porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                    //                castigoAplicado = true;
                    //            }
                    //        }
                    //    }
                    //    else
                    //    {
                    //        //Si la fecha de último seguimiento es nula, entonces se compara la fecha de valuación, esto porque la fecha dé último seguimiento será igual a la de valuación
                    //        if (UtilitariosComun.DateDiff("Y", this.fechaValuacion, fechaActualSistema) > 1)
                    //        {
                    //            esValida = false;
                    //            errorValidaciones = true;
                    //            desplegarErrorVentanaEmergente = true;
                    //            inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimiento = true;

                    //            if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimientoNoVehiculos)))
                    //            {
                    //                listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimientoNoVehiculos), _mensajePorcAceptNoTerrenoCalcFechaUltimoSeguimiento);
                    //            }

                    //            if (!castigoAplicado)
                    //            {
                    //                porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                    //                castigoAplicado = true;
                    //            }
                    //        }
                    //    }
                    //}

                    //SI TIPO BIEN IGUAL MAQUINARIA Y EQUIPO, Y TIPO GARANTIA REAL IGUAL A PRENDAS
                    if (codTipoBien.Equals(4) && codTipoGarantiaReal.Equals(3))
                    {
                        if (fechaUltimoSeguimiento != fechaNula)
                        {
                            //SE VERIFICA QUE LA FECHA ULTIMO SEGUIMIENTO SEA SEA MAYOR A 6 MESES EN RELACION A LA FECHA DEL SISTEMA 
                            if (UtilitariosComun.DateDiff("M", fechaUltimoSeguimiento, fechaActualSistema) > 6)
                            {
                                esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo = true;
                                
                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo), _mensajePorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo);
                                }

                                if (!castigoAplicado)
                                {
                                    porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                    castigoAplicado = true;
                                }
                            }
                        }
                        else
                        {
                            //Si la fecha de último seguimiento es nula, entonces se compara la fecha de valuación, esto porque la fecha dé último seguimiento será igual a la de valuación
                            if (UtilitariosComun.DateDiff("M", fechaValuacion, fechaActualSistema) > 6)
                            {
                                esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo = true;

                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo), _mensajePorcAceptNoTerrenoCalcFechaUltimoSeguimientoMaquinariaEquipo);
                                }

                                if (!castigoAplicado)
                                {
                                    porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                    castigoAplicado = true;
                                }
                            }
                        }
                    }

                    //SI TIPO BIEN DIFERENTE A VEHICULOS Y TIPO GARANTIA REAL DISTINTO A PRENDAS
                    if (!codTipoBien.Equals(3))
                    {
                        //SE VERIFICA QUE LA FECHA ULTIMO VALUACION SEA SEA MAYOR A 5 AÑOS EN RELACION A LA FECHA DEL SISTEMA 
                        if (UtilitariosComun.DateDiff("Y", fechaValuacion, fechaActualSistema) > 5)
                        {
                            esValida = false;
                            errorValidaciones = true;
                            desplegarErrorVentanaEmergente = true;
                            inconsistenciaPorcAceptNoTerrenoCalcFechaValuacion = true;
  
                            if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaValuacion)))
                            {
                                listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoCalcFechaValuacion), _mensajePorcAceptNoTerrenoCalcFechaValuacion);
                            }

                            if (!castigoAplicado)
                            {
                                porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                castigoAplicado = true;
                            }
                        }
                    }

                    //SI TIENE POLIZA ASOCIADA
                    if (polizaSapAsociada != null)
                    {
                        //Se verifica si al guardar existe el mensaje de que no tiene póliza asociada, esto para eliminarla
                        if ((aplicarValidacionCamposRequeridos)
                           && (ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaNoAsociada))))
                        {
                            listaMensajesValidaciones.Remove((int)Enumeradores.Inconsistencias.PolizaNoAsociada);
                        }

                        if ((polizaSapAsociada.FechaVencimientoPolizaSap != fechaNula) && (polizaSapAsociada.FechaVencimientoPolizaSap != DateTime.MinValue))
                        {
                            //Se verifica si tiene una poliza asociada y la fecha de vencimiento de la poliza es menor a la fecha del sistema
                            if (polizaSapAsociada.FechaVencimientoPolizaSap < fechaActualSistema)
                            {
                                esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepPolizaFechaVencimientoMenor = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;

                                if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaAsociadaVencimientoMenor)))
                                {
                                    listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaAsociadaVencimientoMenor), _mensajePorceAcepPolizaFechaVencimientoMenor);
                                }

                                if (!castigoAplicado)
                                {
                                    porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                    castigoAplicado = true;
                                }
                            }

                            //Se verifica si tiene una poliza asociada, fecha de vencimiento es mayor a la fecha del sistema y monto poliza no cubre monto ultima tasacion no terreno
                            if ((polizaSapAsociada.FechaVencimientoPolizaSap > fechaActualSistema) && (polizaSapAsociada.MontoAcreenciaPolizaSap < montoUltimaTasacionNoTerreno))
                            {
                                esValida = false;
                                errorValidaciones = true;
                                desplegarErrorVentanaEmergente = true;
                                inconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno = true;
                                inconsistenciaPorcentajeAceptacionCalculado = true;

                                if (!castigoAplicado)
                                {
                                    porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                    castigoAplicado = true;
                                }
                            }
                        }

                        //SI NO POSEE TODAS LAS COBERTURAS OBLIGATORIAS
                        if (polizaSapAsociada != null)
                        {
                            if (!polizaSapAsociada.DiferenciaCoberturasObligatorias.Equals(0))
                            {
                                if (!castigoAplicado)
                                {
                                    porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                    castigoAplicado = true;
                                }
                            }
                        }

                        //SI EL ACREEDOR ES DISTINTO DE 4000000019
                        if (!cedAcreedor.Trim().Equals("4000000019"))
                        {
                            if (!castigoAplicado)
                            {
                                porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                                castigoAplicado = true;
                            }
                        }
                    }
                    else if ((codTipoBien != 1) && (polizaSapAsociada == null)
                         || ((polizaSapAsociada != null) && (errorRelacionGarantiaPoliza)))
                    {

                        //esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaPorceAcepNoPolizaAsociada = true;
                        inconsistenciaPorcentajeAceptacionCalculado = true;

                        //SI NO TIENE POLIZA ASOCIADA SE CASTIGA
                        if (!castigoAplicado)
                        {
                            porcentajeAceptacionNoTerrenoCalculado = porcentajeAceptacionCalculadoOriginal / 2;
                            castigoAplicado = true;
                        }

                        if (!ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaNoAsociada)))
                        {
                            listaMensajesValidaciones.Add(((int)Enumeradores.Inconsistencias.PolizaNoAsociada), _mensajePorceAcepNoPolizaAsociada);
                        }
                    }

                    if (porcentajeAceptacionNoTerreno > porcentajeAceptacionNoTerrenoCalculado)
                    {
                        esValida = false;
                        errorValidaciones = true;
                        desplegarErrorVentanaEmergente = true;
                        inconsistenciaPorceAcepNoTerrenoMayorPorceAcepCalculado = true;
                        listaErroresValidaciones.Add((int)Enumeradores.Inconsistencias.PorcAceptNoTerrenoMayorCalculado, _mensajePorceAcepNoTerrenoMayorPorceAcepNoTerrenoCalculado);

                    }

                    #endregion

                    //agregar validaciones
                }
            }
            else
            {
                esValida = false;
                errorDatosRequeridos = true;
            }

            return esValida;
        }

        /// <summary>
        /// Genera una trama con los datos que fueron modificados, separados según la tabla donde sern insertados, además, agrega los datos 
        /// que sern insertados en la bitácora
        /// </summary>
        /// <param name="idUsuario">Identificación del usuario que realiza el ajuste de datos</param>
        /// <param name="dirIP">Dirección IP de la máquina desde donde se hace el ajuste</param>
        /// <returns>Trama con los datos que sern ajustados</returns>
        public string ObtenerTramaDatosModificados(string idUsuario, string dirIP)
        {
            string tramaDatosAModificar = string.Empty;
            string tramaDatosActuales = ConvertirAXML(1);
            string[] formatosFecha = { "yyyyMMdd", "dd/MM/yyyy" };
            bool existenCamposModificados = false;
            bool existePolizaEliminada = false;
            bool polizaModificada = false;
            bool polizaInsertada = false;
            bool porcentajeAcepCalculadoReg = false;
            StringBuilder sentenciaActualizacionGarantia = new StringBuilder("UPDATE dbo.GAR_GARANTIA_REAL SET ");
            StringBuilder sentenciaActualizacionGarOper = new StringBuilder("UPDATE dbo.GAR_GARANTIAS_REALES_X_OPERACION SET ");
            StringBuilder sentenciaActualizacionAvaluos = new StringBuilder("UPDATE dbo.GAR_VALUACIONES_REALES SET ");
            StringBuilder sentenciaActualizacionPoliza = new StringBuilder("UPDATE dbo.GAR_POLIZAS_RELACIONADAS SET ");
            string sentenciaInsercionPoliza = "INSERT INTO dbo.GAR_POLIZAS_RELACIONADAS(Codigo_SAP, cod_operacion, cod_garantia_real, Monto_Acreencia, Fecha_Inserto, Usuario_Modifico, Fecha_Modifico, Usuario_Inserto) VALUES({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7})";
            string sentenciaEliminacionPoliza = "DELETE FROM dbo.GAR_POLIZAS_RELACIONADAS WHERE Codigo_SAP = {0} AND cod_operacion = {1} AND cod_garantia_real = {2}";
            listaDatosModificadosGarantias = new Dictionary<string, string>();
            listaDatosEliminadosGarPoliza = new Dictionary<string, string>();
            listaDatosInsertadosGarPoliza = new Dictionary<string, string>();
            listaDatosModificadosGarPoliza = new Dictionary<string, string>();
            listaDatosModificadosGarValuacionesReales = new Dictionary<string, string>();
            listaDatosModificadosGarXOper = new Dictionary<string, string>();

            bool aplicanPorcentajesAceptAvaluo = HabilitarPorcentajesAceptacionAvaluo();

            int tipoBienInicial = -1;
            int tipoBienActual = -1;

            string porcentajeAceptCalculadoOriginal = string.Empty;
            DateTime fechaBase = new DateTime(1900,01,01);
            DateTime fecModifico;            

            if ((tramaInicial.Length > 0) && (tramaDatosActuales.Length > 0))
            {
                XmlDocument xmlTramaInicial = new XmlDocument();
                XmlDocument xmlTramaDatosActuales = new XmlDocument();

                xmlTramaInicial.LoadXml(tramaInicial);
                xmlTramaDatosActuales.LoadXml(tramaDatosActuales);

                XmlDocument xmlTramaGarantiaInicial = new XmlDocument();
                XmlDocument xmlTramaGarantiaActual = new XmlDocument();

                XmlDocument xmlTramaAvaluoInicial = new XmlDocument();
                XmlDocument xmlTramaAvaluoActual = new XmlDocument();

                xmlTramaGarantiaInicial.LoadXml(xmlTramaInicial.SelectSingleNode("//" + _tagGarantia).OuterXml);
                xmlTramaGarantiaActual.LoadXml(xmlTramaDatosActuales.SelectSingleNode("//" + _tagGarantia).OuterXml);

                xmlTramaAvaluoInicial.LoadXml(xmlTramaInicial.SelectSingleNode("//" + _tagAvaluoReciente).OuterXml);
                xmlTramaAvaluoActual.LoadXml(xmlTramaDatosActuales.SelectSingleNode("//" + _tagAvaluoReciente).OuterXml);

                clsPolizasSap<clsPolizaSap> listaPolizasInicial = new clsPolizasSap<clsPolizaSap>(xmlTramaInicial.SelectSingleNode("//" + _tagPolizas).OuterXml);
                clsPolizaSap polizaSeleccionadaInicial = listaPolizasInicial.ObtenerPolizaSapSeleccionada();
                clsPolizaSap polizaRelacionada = ObtenerPolizaRelacionada(codOperacion, codGarantiaReal);

                if ((xmlTramaGarantiaInicial != null) && (xmlTramaGarantiaActual != null))
                {
                    MemoryStream stream = new MemoryStream(200000);

                    //Crea un escritor de XML con el path y el foemato
                    XmlTextWriter objEscritor = new XmlTextWriter(stream, Encoding.Unicode);

                    //Se inicializa para que idente el archivo
                    objEscritor.Formatting = Formatting.None;

                    //Inicializa el Documento XML
                    objEscritor.WriteStartDocument();

                    //Inicializa el nodo raiz
                    objEscritor.WriteStartElement("DATOS");

                    #region Datos Insertados

                    if (((polizaSeleccionadaInicial != null) && (polizaSapAsociada == null))
                        || ((polizaSeleccionadaInicial != null) && (polizaSapAsociada != null)
                        && (polizaSeleccionadaInicial.CodigoPolizaSap != polizaSapAsociada.CodigoPolizaSap)))
                    {
                        existePolizaEliminada = true;
                    }
                    else if ((polizaRelacionada != null) && (polizaRelacionada.CodigoPolizaSap != -1))
                    {
                        existePolizaEliminada = true;
                    }

                    if(polizaSapAsociada != null)
                    //if (((polizaSeleccionadaInicial == null) && (polizaSapAsociada != null)) ||
                    //    ((polizaSeleccionadaInicial != null) && (polizaSapAsociada != null)
                    //    && ((polizaSeleccionadaInicial.CodigoPolizaSap != polizaSapAsociada.CodigoPolizaSap))))
                    {
                        existenCamposModificados = true;
                        polizaInsertada = true;

                        existePolizaEliminada = ((polizaRelacionada != null) ? true : false);

                        DateTime fechaInsercion = DateTime.Now;

                        //Inicializa el nodo que poseer los datos de la garantía que serán insertados
                        objEscritor.WriteStartElement("INSERTAR");

                        //Inicializa el nodo que poseer los datos de la póliza de la garantía que fueron modificados
                        objEscritor.WriteStartElement("POLIZAS");

                        //Crea el nodo del campo del código SAP
                        objEscritor.WriteStartElement(_codigoSap);
                        objEscritor.WriteString(polizaSapAsociada.CodigoPolizaSap.ToString());
                        objEscritor.WriteEndElement();

                        //Crea el nodo del campo del consecutivo de la operación
                        objEscritor.WriteStartElement(_codOperacion);
                        objEscritor.WriteString(codOperacion.ToString());
                        objEscritor.WriteEndElement();

                        //Crea el nodo del campo del consecutivo de la garantía
                        objEscritor.WriteStartElement(_codGarantiaReal);
                        objEscritor.WriteString(codGarantiaReal.ToString());
                        objEscritor.WriteEndElement();

                        //Crea el nodo del campo del monto de la acreencia
                        objEscritor.WriteStartElement(_montoAcreencia);
                        objEscritor.WriteString(polizaSapAsociada.MontoAcreenciaPolizaSap.ToString());
                        objEscritor.WriteEndElement();

                        //Crea el nodo del campo del usuario que inserta
                        objEscritor.WriteStartElement(_usuarioInserto);
                        objEscritor.WriteString(idUsuario);
                        objEscritor.WriteEndElement();

                        //Crea el nodo del campo del usuario que inserta
                        objEscritor.WriteStartElement(_fechaInserto);
                        objEscritor.WriteString(fechaInsercion.ToString("yyyyMMdd HH:mm:ss"));
                        objEscritor.WriteEndElement();

                        //Final del tag POLIZAS
                        objEscritor.WriteEndElement();

                        //Final del tag INSERTAR
                        objEscritor.WriteEndElement();

                        sentenciaInsercionPoliza = string.Format(sentenciaInsercionPoliza, (new object[] { polizaSapAsociada.CodigoPolizaSap.ToString(), codOperacion.ToString(), codGarantiaReal.ToString(), polizaSapAsociada.MontoAcreenciaPolizaSap.ToString("N2"), DateTime.Now.ToString("dd/MM/yyyy"), idUsuario, DateTime.Now.ToString("dd/MM/yyyy"), idUsuario }));
                        listaDatosInsertadosGarPoliza.Add(_codigoSap, (string.Format("-|{0}", polizaSapAsociada.CodigoPolizaSap.ToString())));
                        //listaDatosInsertadosGarPoliza.Add(_codOperacion, ("-|" + codOperacion.ToString()));
                        //listaDatosInsertadosGarPoliza.Add(_codGarantiaReal, ("-|" + codGarantiaReal.ToString()));
                        listaDatosInsertadosGarPoliza.Add(_montoAcreencia, string.Format("-|{0}", polizaSapAsociada.MontoAcreenciaPolizaSap.ToString()));
                        listaDatosInsertadosGarPoliza.Add(_fechaInserto, (string.Format("-|{0}", fechaInsercion.ToString("yyyyMMdd HH:mm:ss"))));
                        listaDatosInsertadosGarPoliza.Add(_usuarioInserto, (string.Format("-|{0}", idUsuario)));
                    }
                    //else if ((polizaSeleccionadaInicial != null) && (polizaSapAsociada != null)
                    //        && ((polizaSeleccionadaInicial.CodigoPolizaSap == polizaSapAsociada.CodigoPolizaSap))
                    //        && (polizaSeleccionadaInicial.MontoAcreenciaPolizaSap != polizaSapAsociada.MontoAcreenciaPolizaSap))
                    //{
                    //    existenCamposModificados = true;
                    //}

                    #endregion Datos Insertados

                    #region Datos Modificados

                    //Inicializa el nodo que poseer los datos de la garantía que fueron modificados
                    objEscritor.WriteStartElement("MODIFICADOS");

                    //Se obtienen los datos modificados de la garantía
                    foreach (XmlNode nodoInicial in xmlTramaGarantiaInicial.ChildNodes.Item(0).ChildNodes)
                    {
                        XmlNode nodoActual = xmlTramaGarantiaActual.SelectSingleNode("//" + nodoInicial.Name);

                        if ((nodoInicial != null) && (nodoActual != null)
                            && (nodoInicial.InnerText.CompareTo(((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : string.Empty)) != 0))
                        {
                            existenCamposModificados = true;

                            if (listaCamposGarantias.Contains(nodoInicial.Name))
                            {
                                if (!listaDatosModificadosGarantias.ContainsKey(nodoInicial.Name))
                                {
                                    switch (nodoInicial.Name)
                                    {
                                        case _codPartido:
                                            if ((codClaseGarantia < 30) && (nodoActual.InnerText.CompareTo("-1") != 0))
                                            {
                                                sentenciaActualizacionGarantia.Append((string.Format("{0} = {1},", nodoActual.Name, (((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "NULL") : "NULL")))));
                                                listaDatosModificadosGarantias.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((nodoInicial.InnerText.Length > 0) ? ((nodoInicial.InnerText.CompareTo("-1") != 0) ? nodoInicial.InnerText : "-") : "-"), ((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "-") : "-"))));
                                            }

                                            break;
                                        case _usuarioInserto:
                                        //case _usuarioModifico:
                                        case _fechaInserto:
                                        case _fechaModifico:
                                            sentenciaActualizacionGarantia.Append((string.Format("{0} = {1},", nodoActual.Name, (((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "NULL") : "NULL")))));
                                            break;
                                        case _codTipoBien:

                                            tipoBienInicial = ((int.TryParse(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : "-1"), out tipoBienInicial)) ? tipoBienInicial : -1);
                                            tipoBienActual = ((int.TryParse(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : "-1"), out tipoBienActual)) ? tipoBienActual : -1);

                                            sentenciaActualizacionGarantia.Append((string.Format("{0} = {1},", nodoActual.Name, (((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "NULL") : "NULL")))));
                                            listaDatosModificadosGarantias.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((nodoInicial.InnerText.Length > 0) ? ((nodoInicial.InnerText.CompareTo("-1") != 0) ? nodoInicial.InnerText : "-") : "-"), ((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "-") : "-"))));
                                            break;
                                        default:
                                            sentenciaActualizacionGarantia.Append((string.Format("{0} = {1},", nodoActual.Name, (((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "NULL") : "NULL")))));
                                            listaDatosModificadosGarantias.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((nodoInicial.InnerText.Length > 0) ? ((nodoInicial.InnerText.CompareTo("-1") != 0) ? nodoInicial.InnerText : "-") : "-"), ((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "-") : "-"))));

                                            break;
                                    }
                                }
                            }
                            // else 
                            if (listaCamposGarantiaOperacion.Contains(nodoInicial.Name))
                            {
                                if (!listaDatosModificadosGarXOper.ContainsKey(nodoInicial.Name))
                                {
                                    switch (nodoInicial.Name)
                                    {
                                        case _porcentajeAceptacionCalculado:

                                            if (!aplicanPorcentajesAceptAvaluo)
                                            {
                                                porcentajeAceptCalculadoOriginal = porcentajeAceptacionCalculadoOriginal.ToString();

                                                decimal porcentajeAceptacionCalculadoInicial = (decimal.TryParse(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionCalculadoInicial) ? porcentajeAceptacionCalculadoInicial : porcentajeAceptacionCalculadoOriginal);
                                                decimal porcentajeAceptacionCalculadoActual = (decimal.TryParse(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionCalculadoActual) ? porcentajeAceptacionCalculadoActual : porcentajeAceptacionCalculadoOriginal);

                                                string valorInicial = xmlTramaGarantiaInicial.SelectSingleNode("//" + _porcentajeAceptacion).InnerText;
                                                string valorActual = xmlTramaGarantiaActual.SelectSingleNode("//" + _porcentajeAceptacion).InnerText;

                                                decimal porcentajeAceptacionInicial = (decimal.TryParse(((valorInicial.Length > 0) ? valorInicial : "-1"), out porcentajeAceptacionInicial) ? porcentajeAceptacionInicial : -1);
                                                decimal porcentajeAceptacionActual = (decimal.TryParse(((valorActual.Length > 0) ? valorActual : "-1"), out porcentajeAceptacionActual) ? porcentajeAceptacionActual : -1);

                                                porcentajeAceptacionCalculadoInicial = ((codTipoBien > 4) ? ((tipoBienInicial != tipoBienActual) ? 0 : porcentajeAceptacionInicial) : porcentajeAceptacionCalculadoInicial);
                                                porcentajeAceptacionCalculadoActual = ((codTipoBien > 4) ? ((tipoBienInicial != tipoBienActual) ? 0 : porcentajeAceptacionActual) : porcentajeAceptacionCalculadoActual);

                                                if (porcentajeAceptacionCalculadoInicial != porcentajeAceptacionCalculadoActual)
                                                {
                                                    sentenciaActualizacionGarOper.Append((string.Format("{0} = {1},", nodoActual.Name, ((porcentajeAceptacionCalculadoActual != -1) ? ((codTipoBien <= 4) ? nodoActual.InnerText : valorActual) : "NULL"))));
                                                    listaDatosModificadosGarXOper.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((porcentajeAceptacionCalculadoInicial != -1) ? ((codTipoBien <= 4) ? nodoInicial.InnerText : valorInicial) : "-"), ((porcentajeAceptacionCalculadoActual != -1) ? ((codTipoBien <= 4) ? nodoActual.InnerText : valorActual) : "-"))));
                                                    porcentajeAcepCalculadoReg = true;
                                                }
                                            }

                                            break;
                                        case _porcentajeAceptacion:
                                            if (!aplicanPorcentajesAceptAvaluo)
                                            {
                                                decimal porcentajeAceptacionInicial = (decimal.TryParse(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : "-1"), out porcentajeAceptacionInicial) ? porcentajeAceptacionInicial : -1);
                                                decimal porcentajeAceptacionActual = (decimal.TryParse(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : "-1"), out porcentajeAceptacionActual) ? porcentajeAceptacionActual : -1);
                                                string valorInicial = nodoInicial.InnerText;
                                                
                                                if ((tipoBienInicial != tipoBienActual) && (tipoBienActual > 4))
                                                {
                                                    porcentajeAceptacionInicial = 0;
                                                    valorInicial = "0.00";
                                                }

                                                if (porcentajeAceptacionInicial != porcentajeAceptacionActual)
                                                {
                                                    sentenciaActualizacionGarOper.Append((string.Format("{0} = {1},", nodoActual.Name, ((porcentajeAceptacionActual != -1) ? nodoActual.InnerText : "NULL"))));
                                                    listaDatosModificadosGarXOper.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((porcentajeAceptacionInicial != -1) ? valorInicial : "-"), ((porcentajeAceptacionActual != -1) ? nodoActual.InnerText : "-"))));
                                                }
                                            }

                                            break;
                                        case _fechaPresentacion:

                                            DateTime fechaInicial = ((DateTime.TryParseExact(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : "19000101"), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fechaInicial)) ? fechaInicial : fechaBase);
                                            DateTime fechaActual = ((DateTime.TryParseExact(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : "19000101"), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fechaActual)) ? fechaActual : fechaBase);

                                            fechaInicial = ((fechaInicial == DateTime.MinValue) ? fechaBase : fechaInicial);
                                            fechaActual = ((fechaActual == DateTime.MinValue) ? fechaBase : fechaActual);


                                            if (fechaInicial != fechaActual)
                                            {
                                                sentenciaActualizacionGarOper.Append((string.Format("{0} = {1},", nodoActual.Name, ((fechaActual != fechaBase) ? nodoActual.InnerText : "NULL"))));
                                                listaDatosModificadosGarXOper.Add(nodoInicial.Name, (((fechaInicial != fechaBase) ? nodoInicial.InnerText : "-") + "|" + ((fechaActual != fechaBase) ? nodoActual.InnerText : "-")));
                                            }

                                            break;
                                        case _usuarioInserto:
                                        //case _usuarioModifico:
                                        case _fechaInserto:
                                        //case _fechaModifico:
                                        //    sentenciaActualizacionGarOper.Append((string.Format("{0} = {1},", nodoActual.Name, (((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "NULL") : "NULL")))));
                                        //    break;
                                        default:
                                            sentenciaActualizacionGarOper.Append((string.Format("{0} = {1},", nodoActual.Name, (((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "NULL") : "NULL")))));
                                            listaDatosModificadosGarXOper.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((nodoInicial.InnerText.Length > 0) ? ((nodoInicial.InnerText.CompareTo("-1") != 0) ? nodoInicial.InnerText : "-") : "-"), ((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "-") : "-"))));

                                            break;
                                    }
                                }
                            }

                            if (listaCamposAvaluoGarantia.Contains(nodoInicial.Name))
                            {
                                if (!listaDatosModificadosGarValuacionesReales.ContainsKey(nodoInicial.Name))
                                {
                                    switch (nodoInicial.Name)
                                    {
                                        case _porcentajeAceptacionTerrenoCalculado:
                                            if (aplicanPorcentajesAceptAvaluo)
                                            {
                                                existenCamposModificados = true;

                                                porcentajeAceptCalculadoOriginal = porcentajeAceptacionCalculadoOriginal.ToString();

                                                decimal porcentajeAceptacionTerrenoCalculadoInicial = (decimal.TryParse(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionTerrenoCalculadoInicial) ? porcentajeAceptacionTerrenoCalculadoInicial : porcentajeAceptacionCalculadoOriginal);
                                                decimal porcentajeAceptacionTerrenoCalculadoActual = (decimal.TryParse(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionTerrenoCalculadoActual) ? porcentajeAceptacionTerrenoCalculadoActual : porcentajeAceptacionCalculadoOriginal);

                                                if (porcentajeAceptacionTerrenoCalculadoInicial != porcentajeAceptacionTerrenoCalculadoActual)
                                                {
                                                    sentenciaActualizacionAvaluos.Append((string.Format("{0} = {1},", nodoActual.Name, ((porcentajeAceptacionTerrenoCalculadoActual != -1) ? nodoActual.InnerText : "NULL"))));
                                                    listaDatosModificadosGarValuacionesReales.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((porcentajeAceptacionTerrenoCalculadoInicial != -1) ? nodoInicial.InnerText : "-"), ((porcentajeAceptacionTerrenoCalculadoActual != -1) ? nodoActual.InnerText : "-"))));
                                                }
                                            }

                                            break;
                                        case _porcentajeAceptacionNoTerrenoCalculado:
                                            if ((aplicanPorcentajesAceptAvaluo) && (codTipoBien != 1))
                                            {
                                                existenCamposModificados = true;

                                                porcentajeAceptCalculadoOriginal = porcentajeAceptacionCalculadoOriginal.ToString();

                                                decimal porcentajeAceptacionNoTerrenoCalculadoInicial = (decimal.TryParse(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionNoTerrenoCalculadoInicial) ? porcentajeAceptacionNoTerrenoCalculadoInicial : porcentajeAceptacionCalculadoOriginal);
                                                decimal porcentajeAceptacionNoTerrenoCalculadoActual = (decimal.TryParse(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionNoTerrenoCalculadoActual) ? porcentajeAceptacionNoTerrenoCalculadoActual : porcentajeAceptacionCalculadoOriginal);

                                                if (porcentajeAceptacionNoTerrenoCalculadoInicial != porcentajeAceptacionNoTerrenoCalculadoActual)
                                                {
                                                    sentenciaActualizacionAvaluos.Append((string.Format("{0} = {1},", nodoActual.Name, ((porcentajeAceptacionNoTerrenoCalculadoActual != -1) ? nodoActual.InnerText : "NULL"))));
                                                    listaDatosModificadosGarValuacionesReales.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((porcentajeAceptacionNoTerrenoCalculadoInicial != -1) ? nodoInicial.InnerText : "-"), ((porcentajeAceptacionNoTerrenoCalculadoActual != -1) ? nodoActual.InnerText : "-"))));
                                                }
                                            }

                                            break;
                                        case _usuarioInserto:
                                        //case _usuarioModifico:
                                        case _fechaInserto:
                                        //case _fechaModifico:
                                        //    sentenciaActualizacionAvaluos.Append((string.Format("{0} = {1},", nodoActual.Name, (((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "NULL") : "NULL")))));
                                        //    break;
                                        default:
                                            sentenciaActualizacionAvaluos.Append((string.Format("{0} = {1},", nodoActual.Name, (((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "NULL") : "NULL")))));
                                            listaDatosModificadosGarValuacionesReales.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((nodoInicial.InnerText.Length > 0) ? ((nodoInicial.InnerText.CompareTo("-1") != 0) ? nodoInicial.InnerText : "-") : "-"), ((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "-") : "-"))));

                                            break;
                                    }
                                }
                            }
                        }
                    }

                    //Se verifica si hace falta incluir el cambio del campo porcentaje de aceptación calculado, esto porque no es un campo físico, por lo que en la trama inicial es posible que no exista
                    if ((!porcentajeAcepCalculadoReg) && (!aplicanPorcentajesAceptAvaluo))
                    {
                        //Se verifica si hubo un cambio de tipo de bien
                        if ((tipoBienInicial != tipoBienActual) && (tipoBienActual > 4))
                        {
                            //Se ingresa el valor correspondiente al porcentaje de aceptación calculado
                            if (listaCamposGarantiaOperacion.Contains(_porcentajeAceptacionCalculado))
                            {
                                if (!listaDatosModificadosGarXOper.ContainsKey(_porcentajeAceptacionCalculado))
                                {
                                    string valorInicial = "0.00";
                                    string valorActual = xmlTramaGarantiaActual.SelectSingleNode("//" + _porcentajeAceptacion).InnerText;

                                    decimal porcentajeAceptacionCalculadoInicial = 0;
                                    decimal porcentajeAceptacionCalculadoActual = (decimal.TryParse(((valorActual.Length > 0) ? valorActual : "-1"), out porcentajeAceptacionCalculadoActual) ? porcentajeAceptacionCalculadoActual : -1);

                                    if (porcentajeAceptacionCalculadoInicial != porcentajeAceptacionCalculadoActual)
                                    {
                                        sentenciaActualizacionGarOper.Append((string.Format("{0} = {1},", _porcentajeAceptacionCalculado, ((porcentajeAceptacionCalculadoActual != -1) ? valorActual : "NULL"))));
                                        listaDatosModificadosGarXOper.Add(_porcentajeAceptacionCalculado, (string.Format("{0}|{1}", ((porcentajeAceptacionCalculadoInicial != -1) ? valorInicial : "-"), ((porcentajeAceptacionCalculadoActual != -1) ? valorActual : "-"))));
                                    }
                                }
                            }
                        }
                        else if ((tipoBienInicial != tipoBienActual) && (tipoBienActual <= 4))
                        {
                            //Se ingresa el valor correspondiente al porcentaje de aceptación calculado
                            if (listaCamposGarantiaOperacion.Contains(_porcentajeAceptacionCalculado))
                            {
                                if (!listaDatosModificadosGarXOper.ContainsKey(_porcentajeAceptacionCalculado))
                                {
                                    string valorInicial = xmlTramaGarantiaInicial.SelectSingleNode("//" + _porcentajeAceptacion).InnerText;
                                    string valorActual = "0.00";

                                    decimal porcentajeAceptacionCalculadoInicial = (decimal.TryParse(((valorInicial.Length > 0) ? valorInicial : "-1"), out porcentajeAceptacionCalculadoInicial) ? porcentajeAceptacionCalculadoInicial : -1);
                                    decimal porcentajeAceptacionCalculadoActual = 0;

                                    if (porcentajeAceptacionCalculadoInicial != porcentajeAceptacionCalculadoActual)
                                    {
                                        sentenciaActualizacionGarOper.Append((string.Format("{0} = {1},", _porcentajeAceptacionCalculado, ((porcentajeAceptacionCalculadoActual != -1) ? valorActual : "NULL"))));
                                        listaDatosModificadosGarXOper.Add(_porcentajeAceptacionCalculado, (string.Format("{0}|{1}", ((porcentajeAceptacionCalculadoInicial != -1) ? valorInicial : "-"), ((porcentajeAceptacionCalculadoActual != -1) ? valorActual : "-"))));
                                    }
                                }
                            }
                        }
                        else
                        {
                            if (listaCamposGarantiaOperacion.Contains(_porcentajeAceptacionCalculado))
                            {
                                if (!listaDatosModificadosGarXOper.ContainsKey(_porcentajeAceptacionCalculado))
                                {
                                    porcentajeAceptCalculadoOriginal = porcentajeAceptacionCalculadoOriginal.ToString();

                                    string valorInicialPC = xmlTramaGarantiaInicial.SelectSingleNode("//" + _porcentajeAceptacionCalculado).InnerText;
                                    string valorActualPC = xmlTramaGarantiaActual.SelectSingleNode("//" + _porcentajeAceptacionCalculado).InnerText;

                                    decimal porcentajeAceptacionCalculadoInicial = (decimal.TryParse(((valorInicialPC.Length > 0) ? valorInicialPC : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionCalculadoInicial) ? porcentajeAceptacionCalculadoInicial : porcentajeAceptacionCalculadoOriginal);
                                    decimal porcentajeAceptacionCalculadoActual = (decimal.TryParse(((valorActualPC.Length > 0) ? valorActualPC : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionCalculadoActual) ? porcentajeAceptacionCalculadoActual : porcentajeAceptacionCalculadoOriginal);

                                    string valorInicial = xmlTramaGarantiaInicial.SelectSingleNode("//" + _porcentajeAceptacion).InnerText;
                                    string valorActual = xmlTramaGarantiaActual.SelectSingleNode("//" + _porcentajeAceptacion).InnerText;

                                    decimal porcentajeAceptacionInicial = (decimal.TryParse(((valorInicial.Length > 0) ? valorInicial : "-1"), out porcentajeAceptacionInicial) ? porcentajeAceptacionInicial : -1);
                                    decimal porcentajeAceptacionActual = (decimal.TryParse(((valorActual.Length > 0) ? valorActual : "-1"), out porcentajeAceptacionActual) ? porcentajeAceptacionActual : -1);

                                    porcentajeAceptacionCalculadoInicial = ((codTipoBien > 4) ? ((tipoBienInicial != tipoBienActual) ? 0 : porcentajeAceptacionInicial) : porcentajeAceptacionCalculadoInicial);
                                    porcentajeAceptacionCalculadoActual = ((codTipoBien > 4) ? ((tipoBienInicial != tipoBienActual) ? 0 : porcentajeAceptacionActual) : porcentajeAceptacionCalculadoActual);

                                    if (porcentajeAceptacionCalculadoInicial != porcentajeAceptacionCalculadoActual)
                                    {
                                        sentenciaActualizacionGarOper.Append((string.Format("{0} = {1},", _porcentajeAceptacionCalculado, ((porcentajeAceptacionCalculadoActual != -1) ? ((codTipoBien <= 4) ? valorActualPC : valorActual) : "NULL"))));
                                        listaDatosModificadosGarXOper.Add(_porcentajeAceptacionCalculado, (string.Format("{0}|{1}", ((porcentajeAceptacionCalculadoInicial != -1) ? ((codTipoBien <= 4) ? valorInicialPC : valorInicial) : "-"), ((porcentajeAceptacionCalculadoActual != -1) ? ((codTipoBien <= 4) ? valorActualPC : valorActual) : "-"))));
                                    }
                                }
                            }
                        }
                    }

                    //Se obtienen los datos modificados del avalúo
                    foreach (XmlNode nodoInicial in xmlTramaAvaluoInicial.ChildNodes.Item(0).ChildNodes)
                    {
                        XmlNode nodoActual = xmlTramaAvaluoActual.SelectSingleNode("//" + nodoInicial.Name);

                        if (listaCamposAvaluoGarantia.Contains(nodoInicial.Name))
                        {
                            if (!listaDatosModificadosGarValuacionesReales.ContainsKey(nodoInicial.Name))
                            {
                                switch (nodoInicial.Name)
                                {
                                    case _porcentajeAceptacionTerrenoCalculado:
                                        if (aplicanPorcentajesAceptAvaluo)
                                        {
                                            existenCamposModificados = true;

                                            porcentajeAceptCalculadoOriginal = porcentajeAceptacionCalculadoOriginal.ToString();

                                            decimal porcentajeAceptacionTerrenoCalculadoInicial = (decimal.TryParse(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionTerrenoCalculadoInicial) ? porcentajeAceptacionTerrenoCalculadoInicial : porcentajeAceptacionCalculadoOriginal);
                                            decimal porcentajeAceptacionTerrenoCalculadoActual = (decimal.TryParse(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionTerrenoCalculadoActual) ? porcentajeAceptacionTerrenoCalculadoActual : porcentajeAceptacionCalculadoOriginal);

                                            if (porcentajeAceptacionTerrenoCalculadoInicial != porcentajeAceptacionTerrenoCalculadoActual)
                                            {
                                                sentenciaActualizacionAvaluos.Append((string.Format("{0} = {1},", nodoActual.Name, ((porcentajeAceptacionTerrenoCalculadoActual != -1) ? nodoActual.InnerText : "NULL"))));
                                                listaDatosModificadosGarValuacionesReales.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((porcentajeAceptacionTerrenoCalculadoInicial != -1) ? nodoInicial.InnerText : "-"), ((porcentajeAceptacionTerrenoCalculadoActual != -1) ? nodoActual.InnerText : "-"))));
                                            }
                                        }

                                        break;
                                    case _porcentajeAceptacionNoTerrenoCalculado:
                                        if ((aplicanPorcentajesAceptAvaluo) && (codTipoBien != 1))
                                        {
                                            existenCamposModificados = true;

                                            porcentajeAceptCalculadoOriginal = porcentajeAceptacionCalculadoOriginal.ToString();

                                            decimal porcentajeAceptacionNoTerrenoCalculadoInicial = (decimal.TryParse(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionNoTerrenoCalculadoInicial) ? porcentajeAceptacionNoTerrenoCalculadoInicial : porcentajeAceptacionCalculadoOriginal);
                                            decimal porcentajeAceptacionNoTerrenoCalculadoActual = (decimal.TryParse(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : porcentajeAceptCalculadoOriginal), out porcentajeAceptacionNoTerrenoCalculadoActual) ? porcentajeAceptacionNoTerrenoCalculadoActual : porcentajeAceptacionCalculadoOriginal);

                                            if (porcentajeAceptacionNoTerrenoCalculadoInicial != porcentajeAceptacionNoTerrenoCalculadoActual)
                                            {
                                                sentenciaActualizacionAvaluos.Append((string.Format("{0} = {1},", nodoActual.Name, ((porcentajeAceptacionNoTerrenoCalculadoActual != -1) ? nodoActual.InnerText : "NULL"))));
                                                listaDatosModificadosGarValuacionesReales.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((porcentajeAceptacionNoTerrenoCalculadoInicial != -1) ? nodoInicial.InnerText : "-"), ((porcentajeAceptacionNoTerrenoCalculadoActual != -1) ? nodoActual.InnerText : "-"))));
                                            }
                                        }

                                        break;
                                    case _porcentajeAceptacionTerreno:
                                        if (aplicanPorcentajesAceptAvaluo)
                                        {
                                            existenCamposModificados = true;

                                            decimal porcentajeAceptacionTerrenoInicial = (decimal.TryParse(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : "-1"), out porcentajeAceptacionTerrenoInicial) ? porcentajeAceptacionTerrenoInicial : -1);
                                            decimal porcentajeAceptacionTerrenoActual = (decimal.TryParse(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : "-1"), out porcentajeAceptacionTerrenoActual) ? porcentajeAceptacionTerrenoActual : -1);

                                            if (porcentajeAceptacionTerrenoInicial != porcentajeAceptacionTerrenoActual)
                                            {
                                                sentenciaActualizacionAvaluos.Append((string.Format("{0} = {1},", nodoActual.Name, ((porcentajeAceptacionTerrenoActual != -1) ? nodoActual.InnerText : "NULL"))));
                                                listaDatosModificadosGarValuacionesReales.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((porcentajeAceptacionTerrenoInicial != -1) ? nodoInicial.InnerText : "-"), ((porcentajeAceptacionTerrenoActual != -1) ? nodoActual.InnerText : "-"))));
                                            }
                                        }

                                        break;
                                    case _porcentajeAceptacionNoTerreno:
                                        if ((aplicanPorcentajesAceptAvaluo) && (codTipoBien != 1))
                                        {
                                            existenCamposModificados = true;

                                            decimal porcentajeAceptacionNoTerrenoInicial = (decimal.TryParse(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : "-1"), out porcentajeAceptacionNoTerrenoInicial) ? porcentajeAceptacionNoTerrenoInicial : -1);
                                            decimal porcentajeAceptacionNoTerrenoActual = (decimal.TryParse(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : "-1"), out porcentajeAceptacionNoTerrenoActual) ? porcentajeAceptacionNoTerrenoActual : -1);

                                            if (porcentajeAceptacionNoTerrenoInicial != porcentajeAceptacionNoTerrenoActual)
                                            {
                                                sentenciaActualizacionAvaluos.Append((string.Format("{0} = {1},", nodoActual.Name, ((porcentajeAceptacionNoTerrenoActual != -1) ? nodoActual.InnerText : "NULL"))));
                                                listaDatosModificadosGarValuacionesReales.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((porcentajeAceptacionNoTerrenoInicial != -1) ? nodoInicial.InnerText : "-"), ((porcentajeAceptacionNoTerrenoActual != -1) ? nodoActual.InnerText : "-"))));
                                            }
                                        }

                                        break;
                                    case _fechaConstruccion:
                                        if (aplicanPorcentajesAceptAvaluo)
                                        {
                                            existenCamposModificados = true;

                                            DateTime fechaInicial = ((DateTime.TryParseExact(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : "19000101"), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fechaInicial)) ? fechaInicial : fechaBase);
                                            DateTime fechaActual = ((DateTime.TryParseExact(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : "19000101"), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fechaActual)) ? fechaActual : fechaBase);

                                            fechaInicial = ((fechaInicial == DateTime.MinValue) ? fechaBase : fechaInicial);
                                            fechaActual = ((fechaActual == DateTime.MinValue) ? fechaBase : fechaActual);

                                            if (fechaInicial != fechaActual)
                                            {
                                                sentenciaActualizacionAvaluos.Append((nodoActual.Name + "=" + (((fechaActual != fechaBase) ? nodoActual.InnerText : "NULL") + ",")));
                                                listaDatosModificadosGarValuacionesReales.Add(nodoInicial.Name, (((fechaInicial != fechaBase) ? nodoInicial.InnerText : "-") + "|" + ((fechaActual != fechaBase) ? nodoActual.InnerText : "-")));
                                            }
                                        }

                                        break;
                                    case _fechaUltimoSeguimiento:
                                        if (aplicanPorcentajesAceptAvaluo)
                                        {
                                            existenCamposModificados = true;

                                            DateTime fechaInicial = ((DateTime.TryParseExact(((nodoInicial.InnerText.Length > 0) ? nodoInicial.InnerText : "19000101"), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fechaInicial)) ? fechaInicial : fechaBase);
                                            DateTime fechaActual = ((DateTime.TryParseExact(((nodoActual.InnerText.Length > 0) ? nodoActual.InnerText : "19000101"), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fechaActual)) ? fechaActual : fechaBase);

                                            fechaInicial = ((fechaInicial == DateTime.MinValue) ? fechaBase : fechaInicial);
                                            fechaActual = ((fechaActual == DateTime.MinValue) ? fechaBase : fechaActual);

                                            if (fechaInicial != fechaActual)
                                            {
                                                sentenciaActualizacionAvaluos.Append((nodoActual.Name + "=" + (((fechaActual != fechaBase) ? nodoActual.InnerText : "NULL") + ",")));
                                                listaDatosModificadosGarValuacionesReales.Add(nodoInicial.Name, (((fechaInicial != fechaBase) ? nodoInicial.InnerText : "-") + "|" + ((fechaActual != fechaBase) ? nodoActual.InnerText : "-")));
                                            }
                                        }

                                        break;
                                    case _usuarioInserto:
                                   // case _usuarioModifico:
                                    case _fechaInserto:
                                    //case _fechaModifico:
                                    //    sentenciaActualizacionAvaluos.Append((string.Format("{0} = {1},", nodoActual.Name, (((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "NULL") : "NULL")))));
                                    //    break;
                                    default:
                                        if ((nodoInicial != null) && (nodoActual != null) && (nodoInicial.InnerText.CompareTo(((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : string.Empty)) != 0))
                                        {
                                            existenCamposModificados = true;

                                            if (!listaDatosModificadosGarValuacionesReales.ContainsKey(nodoInicial.Name))
                                            {
                                                sentenciaActualizacionAvaluos.Append((string.Format("{0} = {1},", nodoActual.Name, (((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "NULL") : "NULL")))));
                                                listaDatosModificadosGarValuacionesReales.Add(nodoInicial.Name, (string.Format("{0}|{1}", ((nodoInicial.InnerText.Length > 0) ? ((nodoInicial.InnerText.CompareTo("-1") != 0) ? nodoInicial.InnerText : "-") : "-"), ((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "-") : "-"))));
                                            }

                                        }

                                        break;
                                }
                            }
                        }
                    }
                                        


                    if (existenCamposModificados)
                    {
                        #region Nodo de Garantías

                        if ((listaDatosModificadosGarantias != null) && (listaDatosModificadosGarantias.Count > 0))
                        {
                            //Inicializa el nodo que poseer los datos de la garantía que fueron modificados
                            objEscritor.WriteStartElement("GARANTIAS");

                            //Crea el nodo del campo del consecutivo de la garantía
                            objEscritor.WriteStartElement(_codGarantiaReal);
                            objEscritor.WriteString(codGarantiaReal.ToString());
                            objEscritor.WriteEndElement();

                            foreach (KeyValuePair<string, string> datosGarantia in listaDatosModificadosGarantias)
                            {
                                string valorActual = datosGarantia.Value.Split("|".ToCharArray())[1];

                                if (valorActual.CompareTo("-") != 0)
                                {
                                    string valorAct = valorActual;
                                    switch (datosGarantia.Key)
                                    {
                                        case _fechaModifico: valorAct = DateTime.TryParse(valorActual, out fecModifico) ? fecModifico.ToString("yyyyMMdd HH:mm:ss") : valorActual;
                                            break;
                                        default: valorAct = valorActual;
                                            break;
                                    }
                                    //Crea el nodo del campo que se ha modificado
                                    objEscritor.WriteStartElement(datosGarantia.Key);
                                    objEscritor.WriteString(valorAct);
                                    objEscritor.WriteEndElement();
                                }
                            }

                            //Se registran los campos correspondientes a la pista de seguimiento del registro
                            //Se crea el nodo del usuario que realiza el ajuste
                            objEscritor.WriteStartElement(_usuarioModifico);
                            objEscritor.WriteString(idUsuario);
                            objEscritor.WriteEndElement();

                            //Final del tag GARANTIAS
                            objEscritor.WriteEndElement();
                        }

                        #endregion Nodo de Garantías

                        #region Nodo de Relaciones Garantías por Operación

                        if ((listaDatosModificadosGarXOper != null) && (listaDatosModificadosGarXOper.Count > 0))
                        {
                            DateTime fecPresentacion;
                            DateTime fecConstitucion;
                            DateTime fecVencimiento;
                            DateTime fecPrescripcion;

                            //Inicializa el nodo que poseer los datos de la relación garantía - operación que fueron modificados
                            objEscritor.WriteStartElement("GAROPER");

                            //Crea el nodo del campo del consecutivo de la operación
                            objEscritor.WriteStartElement(_codOperacion);
                            objEscritor.WriteString(codOperacion.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del campo del consecutivo de la garantía
                            objEscritor.WriteStartElement(_codGarantiaReal);
                            objEscritor.WriteString(codGarantiaReal.ToString());
                            objEscritor.WriteEndElement();

                            foreach (KeyValuePair<string, string> datosRelacion in listaDatosModificadosGarXOper)
                            {
                                string valorActual = datosRelacion.Value.Split("|".ToCharArray())[1];

                                if (valorActual.CompareTo("-") != 0)
                                {
                                    string valorAct = valorActual;
                                    switch (datosRelacion.Key)
                                    {
                                        case _montoMitigador: valorAct = (Convert.ToDecimal(valorActual)).ToString();
                                            break;
                                        case _fechaPresentacion: valorAct = DateTime.TryParseExact(valorActual, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecPresentacion) ? fecPresentacion.ToString("yyyyMMdd") : valorActual;
                                            break;
                                        case _porcentajeResponsabilidad: valorAct = (Convert.ToDecimal(valorActual)).ToString();
                                            break;
                                        case _fechaConstitucion: valorAct = DateTime.TryParseExact(valorActual, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecConstitucion) ? fecConstitucion.ToString("yyyyMMdd") : valorActual;
                                            break;
                                        case _fechaVencimiento: valorAct = DateTime.TryParseExact(valorActual, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecVencimiento) ? fecVencimiento.ToString("yyyyMMdd") : valorActual;
                                            break;
                                        case _fechaPrescripcion: valorAct = DateTime.TryParseExact(valorActual, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecPrescripcion) ? fecPrescripcion.ToString("yyyyMMdd") : valorActual;
                                            break;
                                        case _fechaModifico: valorAct = DateTime.TryParse(valorActual, out fecModifico) ? fecModifico.ToString("yyyyMMdd HH:mm:ss") : valorActual;
                                            break;
                                        case _porcentajeAceptacionCalculado: valorAct = (Convert.ToDecimal(valorActual)).ToString();
                                            break;

                                        default: valorAct = valorActual;
                                            break;
                                    }

                                    //Crea el nodo del campo que se ha modificado
                                    objEscritor.WriteStartElement(datosRelacion.Key);
                                    objEscritor.WriteString(valorAct);
                                    objEscritor.WriteEndElement();
                                }
                            }

                            //Se registran los campos correspondientes a la pista de seguimiento del registro
                            //Se crea el nodo del usuario que realiza el ajuste
                            objEscritor.WriteStartElement(_usuarioModifico);
                            objEscritor.WriteString(idUsuario);
                            objEscritor.WriteEndElement();

                            //Final del tag GAROPER
                            objEscritor.WriteEndElement();
                        }

                        #endregion Nodo de Relaciones Garantías por Operación

                        #region Nodo de Avalúo

                        if ((listaDatosModificadosGarValuacionesReales != null) && (listaDatosModificadosGarValuacionesReales.Count > 0))
                        {
                            DateTime fecValuacion;
                            DateTime fecUS;
                            DateTime fecCons;

                            //Inicializa el nodo que poseer los datos del avalúo de la garantía que fueron modificados
                            objEscritor.WriteStartElement("AVALUO");

                            //Crea el nodo del campo del consecutivo de la garantía
                            objEscritor.WriteStartElement(_codGarantiaReal);
                            objEscritor.WriteString(codGarantiaReal.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del campo de la fecha del avalúo de la garantía
                            objEscritor.WriteStartElement(_fechaValuacion);
                            objEscritor.WriteString(fechaValuacion.ToString("yyyyMMdd"));
                            objEscritor.WriteEndElement();

                            foreach (KeyValuePair<string, string> datosAvaluo in listaDatosModificadosGarValuacionesReales)
                            {
                                string valorActual = datosAvaluo.Value.Split("|".ToCharArray())[1];

                                if (valorActual.CompareTo("-") != 0)
                                {
                                    string valorAct = valorActual;

                                    switch (datosAvaluo.Key)
                                    {
                                        case _fechaValuacion: valorAct = DateTime.TryParseExact(valorActual, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecValuacion) ? fecValuacion.ToString("yyyyMMdd") : valorActual;
                                            break;
                                        case _montoUltimaTasacionTerreno: valorAct = (Convert.ToDecimal(valorActual)).ToString();
                                            break;
                                        case _montoUltimaTasacionNoTerreno: valorAct = (Convert.ToDecimal(valorActual)).ToString();
                                            break;
                                        case _montoTasacionActualizadaTerreno: valorAct = (Convert.ToDecimal(valorActual)).ToString();
                                            break;
                                        case _montoTasacionActualizadaNoTerreno: valorAct = (Convert.ToDecimal(valorActual)).ToString();
                                            break;
                                        case _montoTotalAvaluo: valorAct = (Convert.ToDecimal(valorActual)).ToString();
                                            break;
                                        case _fechaUltimoSeguimiento: valorAct = DateTime.TryParseExact(valorActual, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecUS) ? fecUS.ToString("yyyyMMdd") : valorActual;
                                            break;
                                        case _fechaConstruccion: valorAct = DateTime.TryParseExact(valorActual, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecCons) ? fecCons.ToString("yyyyMMdd") : valorActual;
                                            break;
                                        case _fechaModifico: valorAct = DateTime.TryParse(valorActual, out fecModifico) ? fecModifico.ToString("yyyyMMdd HH:mm:ss") : valorActual;
                                            break;
                                        //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
                                        case _porcentajeAceptacionTerreno: valorAct = (valorActual.Length.Equals(0)) ? "0" : Convert.ToDecimal(valorActual).ToString();
                                            break;
                                        case _porcentajeAceptacionNoTerreno: valorAct = (valorActual.Length.Equals(0)) ? "0" : Convert.ToDecimal(valorActual).ToString();
                                            break;
                                        case _porcentajeAceptacionTerrenoCalculado: valorAct = (valorActual.Length.Equals(0)) ? "0" : Convert.ToDecimal(valorActual).ToString();
                                            break;
                                        case _porcentajeAceptacionNoTerrenoCalculado: valorAct = (valorActual.Length.Equals(0)) ? "0" : Convert.ToDecimal(valorActual).ToString();
                                            break;
                                        default: valorAct = valorActual;
                                            break;
                                    }
                                    //Crea el nodo del campo que se ha modificado
                                    objEscritor.WriteStartElement(datosAvaluo.Key);
                                    objEscritor.WriteString(valorAct);
                                    objEscritor.WriteEndElement();
                                }
                                else if ((valorActual.CompareTo("-") == 0) &&
                                    ((datosAvaluo.Key.CompareTo(clsGarantiaReal._cedulaPerito) == 0)
                                    || (datosAvaluo.Key.CompareTo(clsGarantiaReal._cedulaEmpresa) == 0)))
                                {
                                    objEscritor.WriteStartElement(datosAvaluo.Key);
                                    objEscritor.WriteString(DBNull.Value.ToString());
                                    objEscritor.WriteEndElement();
                                }
                            }

                            //Se registran los campos correspondientes a la pista de seguimiento del registro
                            //Se crea el nodo del usuario que realiza el ajuste
                            objEscritor.WriteStartElement(_usuarioModifico);
                            objEscritor.WriteString(idUsuario);
                            objEscritor.WriteEndElement();

                            //Final del tag AVALUO
                            objEscritor.WriteEndElement();
                        }

                        #endregion Nodo de Avalúo

                        #region Nodo de Póliza

                        //  if ((listaDatosModificadosGarPoliza != null) && (listaDatosModificadosGarPoliza.Count > 0)
                        //    && (polizaSeleccionadaInicial != null) && (this.polizaSapAsociada != null)
                        //    && (polizaSeleccionadaInicial.MontoAcreenciaPolizaSap != this.polizaSapAsociada.MontoAcreenciaPolizaSap))
                        //{

                        //Inicializa el nodo que poseer los datos de la póliza de la garantía que fueron modificados
                        objEscritor.WriteStartElement("POLIZAS");

                        if ((polizaSeleccionadaInicial != null) && (polizaSapAsociada != null)
                            && (polizaSeleccionadaInicial.MontoAcreenciaPolizaSap != polizaSapAsociada.MontoAcreenciaPolizaSap))
                        {
                            polizaModificada = true;

                            //Crea el nodo del campo del código SAP
                            objEscritor.WriteStartElement(_codigoSap);
                            objEscritor.WriteString(polizaSapAsociada.CodigoPolizaSap.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del campo del consecutivo de la operación
                            objEscritor.WriteStartElement(_codOperacion);
                            objEscritor.WriteString(codOperacion.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del campo del consecutivo de la garantía
                            objEscritor.WriteStartElement(_codGarantiaReal);
                            objEscritor.WriteString(codGarantiaReal.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del monto de acreencia si este ha sido modificado
                            objEscritor.WriteStartElement(_montoAcreencia);
                            objEscritor.WriteString(polizaSapAsociada.MontoAcreenciaPolizaSap.ToString());
                            objEscritor.WriteEndElement();

                            //FALTA AGREGAR LA FECHA DE MODIFICACION Y USUARIO QUE MODIFICÓ GAR_POLIZA_RELACIONADA
                            sentenciaActualizacionPoliza.Append(_montoAcreencia + "=" + polizaSapAsociada.MontoAcreenciaPolizaSap.ToString());

                        }

                        //Se registran los campos correspondientes a la pista de seguimiento del registro
                        //Se crea el nodo del usuario que realiza el ajuste
                        objEscritor.WriteStartElement(_usuarioModifico);
                        objEscritor.WriteString(idUsuario);
                        objEscritor.WriteEndElement();

                        objEscritor.WriteStartElement(_fechaModifico);
                        objEscritor.WriteString(fechaModifico.ToString("yyyyMMdd HH:mm:ss"));
                        objEscritor.WriteEndElement();


                        //Final del tag POLIZAS
                        objEscritor.WriteEndElement();

                        #endregion Nodo de Póliza

                        #region Datos de Control 

                        //Inicializa el nodo que poseer los datos de control
                        objEscritor.WriteStartElement("CONTROL");

                        //Crea el nodo del campo del consecutivo de la operación
                        objEscritor.WriteStartElement(_codOperacion);
                        objEscritor.WriteString(codOperacion.ToString());
                        objEscritor.WriteEndElement();

                        //Crea el nodo del campo del consecutivo de la garantía
                        objEscritor.WriteStartElement(_codGarantiaReal);
                        objEscritor.WriteString(codGarantiaReal.ToString());
                        objEscritor.WriteEndElement();

                        //Crea el nodo del campo de la fecha de valuación
                        objEscritor.WriteStartElement(_fechaValuacion);
                        objEscritor.WriteString(fechaValuacion.ToString("yyyyMMdd"));
                        objEscritor.WriteEndElement();


                        //Crea el nodo del campo del código SAP
                        objEscritor.WriteStartElement(_codigoSap);
                        objEscritor.WriteString(((polizaSapAsociada != null) ? polizaSapAsociada.CodigoPolizaSap.ToString() : "-1"));
                        objEscritor.WriteEndElement();

                        //Se registran los campos correspondientes a la pista de seguimiento del registro
                        //Se crea el nodo del usuario que realiza el ajuste
                        objEscritor.WriteStartElement(_usuarioModifico);
                        objEscritor.WriteString(idUsuario);
                        objEscritor.WriteEndElement();

                        objEscritor.WriteStartElement(_fechaModifico);
                        objEscritor.WriteString(fechaModifico.ToString("yyyyMMdd HH:mm:ss"));
                        objEscritor.WriteEndElement();


                        //Final del tag CONTROL
                        objEscritor.WriteEndElement();

                        #endregion Datos de Control
                    }

                    //Final del tag MODIFICADOS
                    objEscritor.WriteEndElement();
                    
                    #endregion  Datos Modificados

                    #region Datos Eliminados
                    if (existePolizaEliminada)
                    {
                        clsPolizaSap polizaSap = listaPolizasInicial.ObtenerPolizaSapSeleccionada();

                        polizaSap = ((polizaSap != null) ? polizaSap : polizaRelacionada);
                        polizaSeleccionadaInicial = ((polizaSeleccionadaInicial != null) ? polizaSeleccionadaInicial : polizaRelacionada);


                        if (polizaSap != null)
                        {
                            //Inicializa el nodo que poseer los datos de la garantía que serán insertados
                            objEscritor.WriteStartElement("ELIMINADOS");

                            //Inicializa el nodo que poseer los datos de la póliza de la garantía que fueron modificados
                            objEscritor.WriteStartElement("POLIZAS");

                            //Crea el nodo del campo del código SAP
                            objEscritor.WriteStartElement(_codigoSap);
                            objEscritor.WriteString(polizaSap.CodigoPolizaSap.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del campo del consecutivo de la operación
                            objEscritor.WriteStartElement(_codOperacion);
                            objEscritor.WriteString(codOperacion.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del campo del consecutivo de la garantía
                            objEscritor.WriteStartElement(_codGarantiaReal);
                            objEscritor.WriteString(codGarantiaReal.ToString());
                            objEscritor.WriteEndElement();

                            sentenciaEliminacionPoliza = String.Format(sentenciaEliminacionPoliza, (new object[] { polizaSap.CodigoPolizaSap.ToString(), codOperacion.ToString(), codGarantiaReal.ToString() }));
                            listaDatosEliminadosGarPoliza.Add(_codigoSap, (string.Format("{0}|-", polizaSeleccionadaInicial.CodigoPolizaSap.ToString())));
                            //listaDatosEliminadosGarPoliza.Add(_codOperacion, (codOperacion.ToString() + "|-"));
                            //listaDatosEliminadosGarPoliza.Add(_codGarantiaReal, (codGarantiaReal.ToString() + "|-"));
                            listaDatosEliminadosGarPoliza.Add(_montoAcreencia, (string.Format("{0}|-", polizaSeleccionadaInicial.MontoAcreenciaPolizaSap.ToString())));

                            //Final del tag POLIZAS
                            objEscritor.WriteEndElement();

                            //Final del tag ELIMINADOS
                            objEscritor.WriteEndElement();
                         }
                    }

                    #endregion Datos Eliminados

                    #region Nodo de Pistas de Auditoría

                    if (existenCamposModificados)
                    {
                        //Inicializa el nodo que poseer los datos que serán almacenados en la bitácora
                        objEscritor.WriteStartElement("PISTA_AUDITORIA");

                        #region Cambios en Datos de la Garantía

                        if (listaDatosModificadosGarantias.Count > 0)
                        {
                            clsBitacora entidadBitacoraGR = new clsBitacora(_entidadGarantiaReal, idUsuario, dirIP);
                            entidadBitacoraGR.TipoOperacion = Enumeradores.Tipos_Accion.Modificar;
                            entidadBitacoraGR.TipoGarantia = 2;
                            entidadBitacoraGR.NumeroGarantia = GarantiaRealBitacora;
                            entidadBitacoraGR.NumeroOperacion = Operacion;
                            entidadBitacoraGR.Consulta = string.Format(sentenciaActualizacionGarantia.ToString().TrimEnd(",".ToCharArray()) + " WHERE {0} = {1}", _codGarantiaReal,  codGarantiaReal.ToString());

                            foreach (KeyValuePair<string, string> datosGarantia in listaDatosModificadosGarantias)
                            {
                                string datoInicial = datosGarantia.Value.Split("|".ToCharArray())[0];
                                string datoActual = datosGarantia.Value.Split("|".ToCharArray())[1];

                                //este if es para que no inserte este campo en bitacora
                                if (!datosGarantia.Key.Equals("Fecha_Modifico"))
                                {
                                    entidadBitacoraGR.NombreCampoAfectado = datosGarantia.Key;

                                    if (listaDescripcionValoresAnterioresCombos.ContainsKey(datosGarantia.Key))
                                    {
                                        entidadBitacoraGR.ValorAnterior = ((listaDescripcionValoresAnterioresCombos[datosGarantia.Key].Length > 0) ? listaDescripcionValoresAnterioresCombos[datosGarantia.Key] : "-");
                                    }
                                    else
                                    {
                                        entidadBitacoraGR.ValorAnterior = datoInicial;
                                    }

                                    if (listaDescripcionValoresActualesCombos.ContainsKey(datosGarantia.Key))
                                    {
                                        entidadBitacoraGR.ValorActual = ((listaDescripcionValoresActualesCombos[datosGarantia.Key].Length > 0) ? listaDescripcionValoresActualesCombos[datosGarantia.Key] : "-");
                                    }
                                    else
                                    {
                                        entidadBitacoraGR.ValorActual = datoActual;
                                    }

                                    //Crea el nodo del campo que se ha modificado
                                    objEscritor.WriteString(entidadBitacoraGR.ToString(true));

                                } // FIN if (!datosGarantia.Key.Equals("Fecha_Modifico"))                                                      
                            }
                        }

                        #endregion Cambios en Datos de la Garantía

                        #region Cambios en Datos de la Relación de la Garantía

                        if (listaDatosModificadosGarXOper.Count > 0)
                        {
                            DateTime fecPresentacion;
                            DateTime fecConstitucion;
                            DateTime fecVencimiento;
                            DateTime fecPrescripcion;
                            DateTime fecPresentacionAct;
                            DateTime fecConstitucionAct;
                            DateTime fecVencimientoAct;
                            DateTime fecPrescripcionAct;

                            clsBitacora entidadBitacoraRelacion = new clsBitacora(_entidadGarantiaRealXOperacion, idUsuario, dirIP);
                            entidadBitacoraRelacion.TipoOperacion = Enumeradores.Tipos_Accion.Modificar;
                            entidadBitacoraRelacion.TipoGarantia = 2;
                            entidadBitacoraRelacion.NumeroGarantia = GarantiaRealBitacora;
                            entidadBitacoraRelacion.NumeroOperacion = Operacion;
                            entidadBitacoraRelacion.Consulta = string.Format(sentenciaActualizacionGarOper.ToString().TrimEnd(",".ToCharArray()) + " WHERE {0} = {1} AND {2} = {3}", _codOperacion, codOperacion.ToString(), _codGarantiaReal, codGarantiaReal.ToString()); ;

                            foreach (KeyValuePair<string, string> datosRelacion in listaDatosModificadosGarXOper)
                            {
                                string datoInicialR = datosRelacion.Value.Split("|".ToCharArray())[0];
                                string datoActualR = datosRelacion.Value.Split("|".ToCharArray())[1];


                                //este if es para que no inserte este campo en bitacora
                                if (!datosRelacion.Key.Equals("Fecha_Modifico"))
                                {

                                    entidadBitacoraRelacion.NombreCampoAfectado = datosRelacion.Key;

                                    if (listaDescripcionValoresAnterioresCombos.ContainsKey(datosRelacion.Key))
                                    {
                                        entidadBitacoraRelacion.ValorAnterior = ((listaDescripcionValoresAnterioresCombos[datosRelacion.Key].Length > 0) ? listaDescripcionValoresAnterioresCombos[datosRelacion.Key] : "-");
                                    }
                                    else
                                    {
                                        if ((datoInicialR.Length > 0) && (datoInicialR.CompareTo("NULL") != 0) && (datoInicialR.CompareTo("-") != 0))
                                        {
                                            switch (datosRelacion.Key)
                                            {
                                                case _montoMitigador: entidadBitacoraRelacion.ValorAnterior = (Convert.ToDecimal(datoInicialR)).ToString("N2");
                                                    break;
                                                case _fechaPresentacion: entidadBitacoraRelacion.ValorAnterior = DateTime.TryParseExact(datoInicialR, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecPresentacion) ? fecPresentacion.ToString("dd/MM/yyyy") : datoInicialR;
                                                    break;
                                                case _porcentajeResponsabilidad: entidadBitacoraRelacion.ValorAnterior = (Convert.ToDecimal(datoInicialR)).ToString("N2");
                                                    break;
                                                case _fechaConstitucion: entidadBitacoraRelacion.ValorAnterior = DateTime.TryParseExact(datoInicialR, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecConstitucion) ? fecConstitucion.ToString("dd/MM/yyyy") : datoInicialR;
                                                    break;
                                                case _fechaVencimiento: entidadBitacoraRelacion.ValorAnterior = DateTime.TryParseExact(datoInicialR, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecVencimiento) ? fecVencimiento.ToString("dd/MM/yyyy") : datoInicialR;
                                                    break;
                                                case _fechaPrescripcion: entidadBitacoraRelacion.ValorAnterior = DateTime.TryParseExact(datoInicialR, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecPrescripcion) ? fecPrescripcion.ToString("dd/MM/yyyy") : datoInicialR;
                                                    break;
                                                case _porcentajeAceptacion:
                                                    entidadBitacoraRelacion.ValorAnterior = (Convert.ToDecimal(datoInicialR)).ToString("N2");
                                                    break;
                                                //case _fechaModifico: entidadBitacoraRelacion.ValorAnterior = DateTime.TryParse(datoInicialR, out fecModifico) ? fecModifico.ToString("dd/MM/yyyy hh:mm:ss tt") : datoInicialR;
                                                //    break;
                                                default: entidadBitacoraRelacion.ValorAnterior = datoInicialR;
                                                    break;
                                            }
                                        }
                                        else
                                        {
                                            entidadBitacoraRelacion.ValorAnterior = datoInicialR;
                                        }
                                    }

                                    if (listaDescripcionValoresActualesCombos.ContainsKey(datosRelacion.Key))
                                    {
                                        entidadBitacoraRelacion.ValorActual = ((listaDescripcionValoresActualesCombos[datosRelacion.Key].Length > 0) ? listaDescripcionValoresActualesCombos[datosRelacion.Key] : "-");
                                    }
                                    else
                                    {
                                        if ((datoActualR.Length > 0) && (datoActualR.CompareTo("NULL") != 0) && (datoActualR.CompareTo("-") != 0))
                                        {
                                            switch (datosRelacion.Key)
                                            {
                                                case _montoMitigador: entidadBitacoraRelacion.ValorActual = (Convert.ToDecimal(datoActualR)).ToString("N2");
                                                    break;
                                                case _fechaPresentacion: entidadBitacoraRelacion.ValorActual = DateTime.TryParseExact(datoActualR, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecPresentacionAct) ? fecPresentacionAct.ToString("dd/MM/yyyy") : datoActualR;
                                                    break;
                                                case _porcentajeResponsabilidad: entidadBitacoraRelacion.ValorActual = (Convert.ToDecimal(datoActualR)).ToString("N2");
                                                    break;
                                                case _fechaConstitucion: entidadBitacoraRelacion.ValorActual = DateTime.TryParseExact(datoActualR, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecConstitucionAct) ? fecConstitucionAct.ToString("dd/MM/yyyy") : datoActualR;
                                                    break;
                                                case _fechaVencimiento: entidadBitacoraRelacion.ValorActual = DateTime.TryParseExact(datoActualR, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecVencimientoAct) ? fecVencimientoAct.ToString("dd/MM/yyyy") : datoActualR;
                                                    break;
                                                case _fechaPrescripcion: entidadBitacoraRelacion.ValorActual = DateTime.TryParseExact(datoActualR, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecPrescripcionAct) ? fecPrescripcionAct.ToString("dd/MM/yyyy") : datoActualR;
                                                    break;
                                                case _porcentajeAceptacion:
                                                    entidadBitacoraRelacion.ValorActual = (Convert.ToDecimal(datoActualR)).ToString("N2");
                                                    break;
                                                //case _fechaModifico: entidadBitacoraRelacion.ValorActual = DateTime.TryParse(datoActualR, out fecModifico) ? fecModifico.ToString("dd/MM/yyyy hh:mm:ss tt") : datoActualR;
                                                //    break;
                                                default: entidadBitacoraRelacion.ValorActual = datoActualR;
                                                    break;
                                            }
                                        }
                                        else
                                        {
                                            entidadBitacoraRelacion.ValorActual = datoActualR;
                                        }
                                    }

                                    //Crea el nodo del campo que se ha modificado
                                    objEscritor.WriteString(entidadBitacoraRelacion.ToString(true));

                                } //FIN if (!datosGarantia.Key.Equals("Fecha_Modifico"))

                            }
                        }

                        #endregion Cambios en Datos de la Relación de la Garantía

                        #region Cambios en Datos del Avalúo de la Garantía

                        if (listaDatosModificadosGarValuacionesReales.Count > 0)
                        {
                            DateTime fecValuacion;
                            DateTime fecUS;
                            DateTime fecCons;
                            DateTime fecValuacionAct;
                            DateTime fecUSAct;
                            DateTime fecConsAct;

                            clsBitacora entidadBitacoraAvaluo = new clsBitacora(_entidadValuacionesReales, idUsuario, dirIP);
                            entidadBitacoraAvaluo.TipoOperacion = Enumeradores.Tipos_Accion.Modificar;
                            entidadBitacoraAvaluo.TipoGarantia = 2;
                            entidadBitacoraAvaluo.NumeroGarantia = GarantiaRealBitacora;
                            entidadBitacoraAvaluo.NumeroOperacion = Operacion;
                            entidadBitacoraAvaluo.Consulta = string.Format(sentenciaActualizacionAvaluos.ToString().TrimEnd(",".ToCharArray()) + " WHERE {0} = {1}", _codGarantiaReal, codGarantiaReal.ToString());

                            foreach (KeyValuePair<string, string> datosAvaluo in listaDatosModificadosGarValuacionesReales)
                            {
                                string datoInicialAval = datosAvaluo.Value.Split("|".ToCharArray())[0];
                                string datoActualAval = datosAvaluo.Value.Split("|".ToCharArray())[1];

                                if (!datosAvaluo.Key.Equals("Fecha_Modifico"))
                                {

                                    entidadBitacoraAvaluo.NombreCampoAfectado = datosAvaluo.Key;

                                    if (listaDescripcionValoresAnterioresCombos.ContainsKey(datosAvaluo.Key))
                                    {
                                        entidadBitacoraAvaluo.ValorAnterior = ((listaDescripcionValoresAnterioresCombos[datosAvaluo.Key].Length > 0) ? listaDescripcionValoresAnterioresCombos[datosAvaluo.Key] : "-");
                                    }
                                    else
                                    {
                                        if ((datoInicialAval.Length > 0) && (datoInicialAval.CompareTo("NULL") != 0) && (datoInicialAval.CompareTo("-") != 0))
                                        {
                                            switch (datosAvaluo.Key)
                                            {
                                                case _fechaValuacion: entidadBitacoraAvaluo.ValorAnterior = DateTime.TryParseExact(datoInicialAval, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecValuacion) ? fecValuacion.ToString("dd/MM/yyyy") : datoInicialAval;
                                                    break;
                                                case _montoUltimaTasacionTerreno: entidadBitacoraAvaluo.ValorAnterior = (Convert.ToDecimal(datoInicialAval)).ToString("N2");
                                                    break;
                                                case _montoUltimaTasacionNoTerreno: entidadBitacoraAvaluo.ValorAnterior = (Convert.ToDecimal(datoInicialAval)).ToString("N2");
                                                    break;
                                                case _montoTasacionActualizadaTerreno: entidadBitacoraAvaluo.ValorAnterior = (Convert.ToDecimal(datoInicialAval)).ToString("N2");
                                                    break;
                                                case _montoTasacionActualizadaNoTerreno: entidadBitacoraAvaluo.ValorAnterior = (Convert.ToDecimal(datoInicialAval)).ToString("N2");
                                                    break;
                                                case _montoTotalAvaluo: entidadBitacoraAvaluo.ValorAnterior = (Convert.ToDecimal(datoInicialAval)).ToString("N2");
                                                    break;
                                                case _fechaUltimoSeguimiento: entidadBitacoraAvaluo.ValorAnterior = DateTime.TryParseExact(datoInicialAval, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecUS) ? fecUS.ToString("dd/MM/yyyy") : datoInicialAval;
                                                    break;
                                                case _fechaConstruccion: entidadBitacoraAvaluo.ValorAnterior = DateTime.TryParseExact(datoInicialAval, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecCons) ? fecCons.ToString("dd/MM/yyyy") : datoInicialAval;
                                                    break;
                                                //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
                                                case _porcentajeAceptacionTerreno: datoInicialAval = ((datoInicialAval.CompareTo("-1") == 0) ? "0" : datoInicialAval); entidadBitacoraAvaluo.ValorAnterior = Convert.ToDecimal(datoInicialAval).ToString("N2");
                                                    break;
                                                case _porcentajeAceptacionNoTerreno: datoInicialAval = ((datoInicialAval.CompareTo("-1") == 0) ? "0" : datoInicialAval); entidadBitacoraAvaluo.ValorAnterior = Convert.ToDecimal(datoInicialAval).ToString("N2");
                                                    break;
                                                case _porcentajeAceptacionTerrenoCalculado: datoInicialAval = ((datoInicialAval.CompareTo("-1") == 0) ? "0" : datoInicialAval); entidadBitacoraAvaluo.ValorAnterior = Convert.ToDecimal(datoInicialAval).ToString("N2");
                                                    break;
                                                case _porcentajeAceptacionNoTerrenoCalculado: datoInicialAval = ((datoInicialAval.CompareTo("-1") == 0) ? "0" : datoInicialAval); entidadBitacoraAvaluo.ValorAnterior = Convert.ToDecimal(datoInicialAval).ToString("N2");
                                                    break;
                                                //case _fechaModifico: entidadBitacoraAvaluo.ValorAnterior = DateTime.TryParse(datoInicialAval, out fecModifico) ? fecModifico.ToString("dd/MM/yyyy hh:mm:ss tt") : datoInicialAval;
                                                //  break;
                                                case _avaluoActualizado:
                                                    break;
                                                case _semestreCalculadoCalculo:
                                                    break;
                                                default: entidadBitacoraAvaluo.ValorAnterior = datoInicialAval;
                                                    break;
                                            }
                                        }
                                        else
                                        {
                                            entidadBitacoraAvaluo.ValorAnterior = datoInicialAval;
                                        }
                                    }

                                    if (listaDescripcionValoresActualesCombos.ContainsKey(datosAvaluo.Key))
                                    {
                                        entidadBitacoraAvaluo.ValorActual = ((listaDescripcionValoresActualesCombos[datosAvaluo.Key].Length > 0) ? listaDescripcionValoresActualesCombos[datosAvaluo.Key] : "-");
                                    }
                                    else
                                    {
                                        if ((datoActualAval.Length > 0) && (datoActualAval.CompareTo("NULL") != 0) && (datoActualAval.CompareTo("-") != 0))
                                        {
                                            switch (datosAvaluo.Key)
                                            {
                                                case _fechaValuacion: entidadBitacoraAvaluo.ValorActual = DateTime.TryParseExact(datoActualAval, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecValuacionAct) ? fecValuacionAct.ToString("dd/MM/yyyy") : datoActualAval;
                                                    break;
                                                case _montoUltimaTasacionTerreno: entidadBitacoraAvaluo.ValorActual = (Convert.ToDecimal(datoActualAval)).ToString("N2");
                                                    break;
                                                case _montoUltimaTasacionNoTerreno: entidadBitacoraAvaluo.ValorActual = (Convert.ToDecimal(datoActualAval)).ToString("N2");
                                                    break;
                                                case _montoTasacionActualizadaTerreno: entidadBitacoraAvaluo.ValorActual = (Convert.ToDecimal(datoActualAval)).ToString("N2");
                                                    break;
                                                case _montoTasacionActualizadaNoTerreno: entidadBitacoraAvaluo.ValorActual = (Convert.ToDecimal(datoActualAval)).ToString("N2");
                                                    break;
                                                case _montoTotalAvaluo: entidadBitacoraAvaluo.ValorActual = (Convert.ToDecimal(datoActualAval)).ToString("N2");
                                                    break;
                                                case _fechaUltimoSeguimiento: entidadBitacoraAvaluo.ValorActual = DateTime.TryParseExact(datoActualAval, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecUSAct) ? fecUSAct.ToString("dd/MM/yyyy") : datoActualAval;
                                                    break;
                                                case _fechaConstruccion: entidadBitacoraAvaluo.ValorActual = DateTime.TryParseExact(datoActualAval, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecConsAct) ? fecConsAct.ToString("dd/MM/yyyy") : datoActualAval;
                                                    break;
                                                //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
                                                case _porcentajeAceptacionTerreno: entidadBitacoraAvaluo.ValorActual = Convert.ToDecimal(datoActualAval).ToString("N2");
                                                    break;
                                                case _porcentajeAceptacionNoTerreno: entidadBitacoraAvaluo.ValorActual = Convert.ToDecimal(datoActualAval).ToString("N2");
                                                    break;
                                                case _porcentajeAceptacionTerrenoCalculado: entidadBitacoraAvaluo.ValorActual = Convert.ToDecimal(datoActualAval).ToString("N2");
                                                    break;
                                                case _porcentajeAceptacionNoTerrenoCalculado: entidadBitacoraAvaluo.ValorActual = Convert.ToDecimal(datoActualAval).ToString("N2");
                                                    break;
                                                //case _fechaModifico: entidadBitacoraAvaluo.ValorActual = DateTime.TryParse(datoActualAval, out fecModifico) ? fecModifico.ToString("dd/MM/yyyy hh:mm:ss tt") : datoActualAval;
                                                //    break;
                                                case _avaluoActualizado:
                                                    break;
                                                case _semestreCalculadoCalculo:
                                                    break;
                                                default: entidadBitacoraAvaluo.ValorActual = datoActualAval;
                                                    break;
                                            }
                                        }
                                        else
                                        {
                                            entidadBitacoraAvaluo.ValorActual = datoActualAval;
                                        }
                                    }

                                    //Crea el nodo del campo que se ha modificado
                                    objEscritor.WriteString(entidadBitacoraAvaluo.ToString(true));

                                } //FIN      if (!datosGarantia.Key.Equals("Fecha_Modifico"))

                            }
                        }

                        #endregion Cambios en Datos del Avalúo de la Garantía

                        #region Cambios en la Póliza de la Garantía

                        if (polizaInsertada)
                        {
                            clsBitacora entidadBitacoraPoliza = new clsBitacora(_entidadPolizasRelaciondas, idUsuario, dirIP);
                            entidadBitacoraPoliza.TipoOperacion = Enumeradores.Tipos_Accion.Insertar;
                            entidadBitacoraPoliza.TipoGarantia = 2;
                            entidadBitacoraPoliza.NumeroGarantia = GarantiaRealBitacora;
                            entidadBitacoraPoliza.NumeroOperacion = Operacion;
                            entidadBitacoraPoliza.Consulta = sentenciaInsercionPoliza.ToString().TrimEnd(",".ToCharArray());

                            foreach (KeyValuePair<string, string> datosPoliza in listaDatosInsertadosGarPoliza)
                            {
                                string datoInicialPoliza = datosPoliza.Value.Split("|".ToCharArray())[0];
                                string datoActualPoliza = datosPoliza.Value.Split("|".ToCharArray())[1];

                                //este if es para que no inserte este campo en bitacora
                                if (!datosPoliza.Key.Equals("Fecha_Modifico"))
                                {
                                    entidadBitacoraPoliza.NombreCampoAfectado = datosPoliza.Key;

                                    if ((datoInicialPoliza.Length > 0) && (datoInicialPoliza.CompareTo("NULL") != 0) && (datoInicialPoliza.CompareTo("-") != 0))
                                    {
                                        switch (datosPoliza.Key)
                                        {
                                            case _montoAcreencia: entidadBitacoraPoliza.ValorAnterior = (Convert.ToDecimal(datoInicialPoliza)).ToString("N2");
                                                break;
                                            //case _fechaModifico: entidadBitacoraPoliza.ValorAnterior = DateTime.TryParse(datoInicialPoliza, out fecModifico) ? fecModifico.ToString("dd/MM/yyyy hh:mm:ss tt") : datoInicialPoliza;
                                            //    break;
                                            default: entidadBitacoraPoliza.ValorAnterior = datoInicialPoliza;
                                                break;
                                        }
                                    }
                                    else
                                    {
                                        entidadBitacoraPoliza.ValorAnterior = datoInicialPoliza;
                                    }

                                    if ((datoActualPoliza.Length > 0) && (datoActualPoliza.CompareTo("NULL") != 0) && (datoActualPoliza.CompareTo("-") != 0))
                                    {
                                        switch (datosPoliza.Key)
                                        {
                                            case _montoAcreencia: entidadBitacoraPoliza.ValorActual = (Convert.ToDecimal(datoActualPoliza)).ToString("N2");
                                                break;
                                            //case _fechaModifico: entidadBitacoraPoliza.ValorActual = DateTime.TryParse(datoActualPoliza, out fecModifico) ? fecModifico.ToString("dd/MM/yyyy hh:mm:ss tt") : datoActualPoliza;
                                            //    break;
                                            default: entidadBitacoraPoliza.ValorActual = datoActualPoliza;
                                                break;
                                        }
                                    }
                                    else
                                    {
                                        entidadBitacoraPoliza.ValorActual = datoActualPoliza;
                                    }

                                    //Crea el nodo del campo que se ha modificado
                                    objEscritor.WriteString(entidadBitacoraPoliza.ToString(true));

                                } //FIN      if (!datosGarantia.Key.Equals("Fecha_Modifico"))

                            }
                        }


                        if (polizaModificada)
                        {
                            //no se agrega el campo fecha_modificacion porque no se tiene el dato anterior 

                            clsBitacora entidadBitacoraPoliza = new clsBitacora(_entidadPolizasRelaciondas, idUsuario, dirIP);
                            entidadBitacoraPoliza.TipoOperacion = Enumeradores.Tipos_Accion.Modificar;
                            entidadBitacoraPoliza.TipoGarantia = 2;
                            entidadBitacoraPoliza.NumeroGarantia = GarantiaRealBitacora;
                            entidadBitacoraPoliza.NumeroOperacion = Operacion;
                            entidadBitacoraPoliza.Consulta = string.Format(sentenciaActualizacionPoliza.ToString().TrimEnd(",".ToCharArray()) + " WHERE Codigo_SAP = {0} AND cod_operacion = {1} AND cod_garantia_real = {2}", polizaSapAsociada.CodigoPolizaSap.ToString(), codOperacion.ToString(), codGarantiaReal.ToString());
                            entidadBitacoraPoliza.NombreCampoAfectado = _montoAcreencia;
                            entidadBitacoraPoliza.ValorAnterior = polizaSeleccionadaInicial.MontoAcreenciaPolizaSap.ToString("N2");
                            entidadBitacoraPoliza.ValorActual = polizaSapAsociada.MontoAcreenciaPolizaSap.ToString("N2");

                            //Crea el nodo del campo que se ha modificado
                            objEscritor.WriteString(entidadBitacoraPoliza.ToString(true));

                        }

                        if (existePolizaEliminada)
                        {
                            clsBitacora entidadBitacoraPoliza = new clsBitacora(_entidadPolizasRelaciondas, idUsuario, dirIP);
                            entidadBitacoraPoliza.TipoOperacion = Enumeradores.Tipos_Accion.Borrar;
                            entidadBitacoraPoliza.TipoGarantia = 2;
                            entidadBitacoraPoliza.NumeroGarantia = GarantiaRealBitacora;
                            entidadBitacoraPoliza.NumeroOperacion = Operacion;
                            entidadBitacoraPoliza.Consulta = sentenciaEliminacionPoliza.ToString().TrimEnd(",".ToCharArray());

                            foreach (KeyValuePair<string, string> datosPoliza in listaDatosEliminadosGarPoliza)
                            {
                                string datoInicialPoliza = datosPoliza.Value.Split("|".ToCharArray())[0];
                                string datoActualPoliza = datosPoliza.Value.Split("|".ToCharArray())[1];

                                //este if es para que no inserte este campo en bitacora
                                if (!datosPoliza.Key.Equals("Fecha_Modifico"))
                                {

                                    entidadBitacoraPoliza.NombreCampoAfectado = datosPoliza.Key;

                                    if ((datoInicialPoliza.Length > 0) && (datoInicialPoliza.CompareTo("NULL") != 0) && (datoInicialPoliza.CompareTo("-") != 0))
                                    {
                                        switch (datosPoliza.Key)
                                        {
                                            case _montoAcreencia: entidadBitacoraPoliza.ValorAnterior = (Convert.ToDecimal(datoInicialPoliza)).ToString("N2");
                                                break;
                                            //case _fechaModifico: entidadBitacoraPoliza.ValorActual = DateTime.TryParse(datoInicialPoliza, out fecModifico) ? fecModifico.ToString("dd/MM/yyyy hh:mm:ss tt") : datoActualPoliza;
                                            //    break;
                                            default: entidadBitacoraPoliza.ValorAnterior = datoInicialPoliza;
                                                break;
                                        }
                                    }
                                    else
                                    {
                                        entidadBitacoraPoliza.ValorAnterior = datoInicialPoliza;
                                    }

                                    if ((datoActualPoliza.Length > 0) && (datoActualPoliza.CompareTo("NULL") != 0) && (datoActualPoliza.CompareTo("-") != 0))
                                    {
                                        switch (datosPoliza.Key)
                                        {
                                            case _montoAcreencia: entidadBitacoraPoliza.ValorActual = (Convert.ToDecimal(datoActualPoliza)).ToString("N2");
                                                break;
                                            //case _fechaModifico: entidadBitacoraPoliza.ValorActual = DateTime.TryParse(datoActualPoliza, out fecModifico) ? fecModifico.ToString("dd/MM/yyyy hh:mm:ss tt") : datoActualPoliza;
                                            //    break;
                                            default: entidadBitacoraPoliza.ValorActual = datoActualPoliza;
                                                break;
                                        }
                                    }
                                    else
                                    {
                                        entidadBitacoraPoliza.ValorActual = datoActualPoliza;
                                    }

                                    //Crea el nodo del campo que se ha modificado
                                    objEscritor.WriteString(entidadBitacoraPoliza.ToString(true));

                                } //FIN      if (!datosGarantia.Key.Equals("Fecha_Modifico"))

                            }
                        }


                        #endregion Cambios en la Póliza de la Garantía

                        //Final del tag PISTA_AUDITORIA
                        objEscritor.WriteEndElement();
                    }

                    #endregion Nodo de Pistas de Auditoría

                    //Final del tag DATOS
                    objEscritor.WriteEndElement();

                    //Final del documento
                    objEscritor.WriteEndDocument();

                    //Flush
                    objEscritor.Flush();

                    tramaDatosAModificar = UtilitariosComun.GetStringFromStream(stream).Replace("&lt;", "<").Replace("&gt;", ">");

                    //Cierre del xml document
                    objEscritor.Close();
                }
            }

            return ((existenCamposModificados) ? tramaDatosAModificar : string.Empty);
        }

        /// <summary>
        /// Genera una trama con los avalúos que fueron modificados, además, agrega los datos 
        /// que sern insertados en la bitácora
        /// </summary>
        /// <param name="idUsuario">Identificación del usuario que realiza el ajuste de datos</param>
        /// <param name="dirIP">Dirección IP de la máquina desde donde se hace el ajuste</param>
        /// <returns>Trama con los datos que sern ajustados</returns>
        public string ObtenerTramaAvaluosModificados(string idUsuario, string dirIP)
        {
            string tramaDatosAModificar = string.Empty;
            string tramaDatosActuales = ConvertirAXML(1);
            bool existenCamposModificados = false;
            StringBuilder sentenciaActualizacionAvaluos = new StringBuilder("UPDATE GAR_VALUACIONES_REALES SET ");

            if ((tramaInicial.Length > 0) && (tramaDatosActuales.Length > 0))
            {
                XmlDocument xmlTramaInicial = new XmlDocument();
                XmlDocument xmlTramaDatosActuales = new XmlDocument();

                xmlTramaInicial.LoadXml(tramaInicial);
                xmlTramaDatosActuales.LoadXml(tramaDatosActuales);

                XmlDocument xmlTramaAvaluoInicial = new XmlDocument();
                XmlDocument xmlTramaAvaluoActual = new XmlDocument();

                xmlTramaAvaluoInicial.LoadXml(xmlTramaInicial.SelectSingleNode("//" + _tagAvaluoReciente).OuterXml);
                xmlTramaAvaluoActual.LoadXml(xmlTramaDatosActuales.SelectSingleNode("//" + _tagAvaluoReciente).OuterXml);

                if ((xmlTramaAvaluoInicial != null) && (xmlTramaAvaluoActual != null))
                {
                    MemoryStream stream = new MemoryStream(200000);

                    //Crea un escritor de XML con el path y el foemato
                    XmlTextWriter objEscritor = new XmlTextWriter(stream, Encoding.Unicode);

                    //Se inicializa para que idente el archivo
                    objEscritor.Formatting = Formatting.None;

                    //Inicializa el Documento XML
                    objEscritor.WriteStartDocument();

                    //Inicializa el nodo raiz
                    objEscritor.WriteStartElement("DATOS");

                    //Inicializa el nodo que poseer los datos de la garantía que fueron modificados
                    objEscritor.WriteStartElement("MODIFICADOS");

                    foreach (XmlNode nodoInicial in xmlTramaAvaluoInicial.ChildNodes.Item(0).ChildNodes)
                    {
                        XmlNode nodoActual = xmlTramaAvaluoActual.SelectSingleNode("//" + nodoInicial.Name);

                        if ((nodoInicial != null) && (nodoActual != null)
                            && (nodoInicial.InnerText.CompareTo(((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : string.Empty)) != 0))
                        {
                            existenCamposModificados = true;

                            if (listaCamposAvaluoGarantia.Contains(nodoInicial.Name))
                            {
                                sentenciaActualizacionAvaluos.Append((nodoActual.Name + "=" + (((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "NULL") : "NULL")) + ","));
                                listaDatosModificadosGarValuacionesReales.Add(nodoInicial.Name, (((nodoInicial.InnerText.Length > 0) ? ((nodoInicial.InnerText.CompareTo("-1") != 0) ? nodoInicial.InnerText : "-") : "-") + "|" + ((nodoActual.InnerText.Length > 0) ? ((nodoActual.InnerText.CompareTo("-1") != 0) ? nodoActual.InnerText : "-") : "-")));
                            }
                        }
                    }

                    if (existenCamposModificados)
                    {
                        if ((listaDatosModificadosGarValuacionesReales != null) && (listaDatosModificadosGarValuacionesReales.Count > 0))
                        {
                            //Inicializa el nodo que poseer los datos del avalúo de la garantía que fueron modificados
                            objEscritor.WriteStartElement("AVALUO");

                            //Crea el nodo del campo del consecutivo de la garantía
                            objEscritor.WriteStartElement(_codGarantiaReal);
                            objEscritor.WriteString(codGarantiaReal.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del campo de la fecha del avalúo de la garantía
                            objEscritor.WriteStartElement(_fechaValuacion);
                            objEscritor.WriteString(fechaValuacion.ToString("yyyyMMMdd"));
                            objEscritor.WriteEndElement();

                            foreach (KeyValuePair<string, string> datosAvaluo in listaDatosModificadosGarValuacionesReales)
                            {
                                string valorActual = datosAvaluo.Value.Split("|".ToCharArray())[1];

                                if (valorActual.CompareTo("-") != 0)
                                {
                                    //Crea el nodo del campo que se ha modificado
                                    objEscritor.WriteStartElement(datosAvaluo.Key);
                                    objEscritor.WriteString(valorActual);
                                    objEscritor.WriteEndElement();
                                }
                            }

                            //Final del tag AVALUO
                            objEscritor.WriteEndElement();
                        }
                    }

                    //Final del tag MODIFICADOS
                    objEscritor.WriteEndElement();

                    if (existenCamposModificados)
                    {
                        //Inicializa el nodo que poseer los datos que sern almacenados en la bitácora
                        objEscritor.WriteStartElement("PISTA_AUDITORIA");

                        if (listaDatosModificadosGarValuacionesReales.Count > 0)
                        {
                            clsBitacora entidadBitacoraAvaluo = new clsBitacora(_entidadValuacionesReales, idUsuario, dirIP);
                            entidadBitacoraAvaluo.TipoOperacion = Enumeradores.Tipos_Accion.Modificar;
                            entidadBitacoraAvaluo.TipoGarantia = 2;
                            entidadBitacoraAvaluo.NumeroGarantia = GarantiaRealBitacora;
                            entidadBitacoraAvaluo.NumeroOperacion = Operacion;
                            entidadBitacoraAvaluo.Consulta = sentenciaActualizacionAvaluos.ToString().TrimEnd(",".ToCharArray());

                            foreach (KeyValuePair<string, string> datosAvaluo in listaDatosModificadosGarValuacionesReales)
                            {
                                string datoInicialAval = datosAvaluo.Value.Split("|".ToCharArray())[0];
                                string datoActualAval = datosAvaluo.Value.Split("|".ToCharArray())[1];

                                entidadBitacoraAvaluo.NombreCampoAfectado = datosAvaluo.Key;

                                if (listaDescripcionValoresAnterioresCombos.ContainsKey(datosAvaluo.Key))
                                {
                                    entidadBitacoraAvaluo.ValorAnterior = ((listaDescripcionValoresAnterioresCombos[datosAvaluo.Key].Length > 0) ? listaDescripcionValoresAnterioresCombos[datosAvaluo.Key] : "-");
                                }
                                else
                                {
                                    entidadBitacoraAvaluo.ValorAnterior = datoInicialAval;
                                }

                                if (listaDescripcionValoresActualesCombos.ContainsKey(datosAvaluo.Key))
                                {
                                    entidadBitacoraAvaluo.ValorActual = ((listaDescripcionValoresActualesCombos[datosAvaluo.Key].Length > 0) ? listaDescripcionValoresActualesCombos[datosAvaluo.Key] : "-");
                                }
                                else
                                {
                                    entidadBitacoraAvaluo.ValorActual = datoActualAval;
                                }

                                //Crea el nodo del campo que se ha modificado
                                objEscritor.WriteString(entidadBitacoraAvaluo.ToString(true));
                            }
                        }

                        //Final del tag PISTA_AUDITORIA
                        objEscritor.WriteEndElement();
                    }

                    //Final del tag DATOS
                    objEscritor.WriteEndElement();

                    //Final del documento
                    objEscritor.WriteEndDocument();

                    //Flush
                    objEscritor.Flush();

                    tramaDatosAModificar = UtilitariosComun.GetStringFromStream(stream).Replace("&lt;", "<").Replace("&gt;", ">");

                    //Cierre del xml document
                    objEscritor.Close();
                }
            }

            return ((existenCamposModificados) ? tramaDatosAModificar : string.Empty);
        }

        /// <summary>
        /// Genera una trama, en formato xml, con el contenido de la clase
        /// </summary>
        /// <returns>Trama XML con el contenido de la clase</returns>
        public override string ToString()
        {
            return ConvertirAXML(1);
        }

        /// <summary>
        /// Genera una trama, en formato xml, con el contenido de la clase
        /// </summary>
        /// <returns>Trama XML con el contenido de la clase</returns>
        public string ToString(short tipoGeneracion)
        {
            return ConvertirAXML(tipoGeneracion);
        }

        /// <summary>
        /// Aplica el cálculo que permite obtener el monto que se le asignar la campo de la tasación actualizada del terreno y no terreno calculado
        /// </summary>
        /// <param name="esServicioWindows">Indica si es el servicio windows el que consume el método.</param>
        public void AplicarCalculoMTATyMTANT(bool esServicioWindows)
        {
            calculoMontoActualizadoTerrenoNoTerreno = 0;
            errorTecnicoCalculoMontoActualizadoTerrenoNoTerreno = string.Empty;

            bool aplicarCalculoMTAT = (((codTipoBien == 1) || (codTipoBien == 2)) ? true : false);
            bool aplicarCalculoMTANT = ((codTipoBien == 2) ? true : false);


            //Se valida que si no se cumplen las condiciones para aplicar el cálculo
            if (((aplicarCalculoMTANT) && (montoUltimaTasacionNoTerreno == 0))
               || ((aplicarCalculoMTAT) && (montoUltimaTasacionTerreno == 0))
               || (fechaValuacion != fechaValuacionSICC)
               || (montoTotalAvaluo != montoTotalAvaluoSICC))
            {
                calculoMontoActualizadoTerrenoNoTerreno = 1;
                montoTasacionActualizadaTerrenoCalculado = null;
                montoTasacionActualizadaNoTerrenoCalculado = null;
            }
            //Se cumplen las condiciones para aplicar el cálculo
            else
            {
                try
                {
                    //Se verifica si alguno de los parámetros usados por el cálculo no fue obtenido o está mal parametrizado
                    if ((annosLimiteInferior == 0) || (annosLimiteIntermedio == 0)
                        || (porcentajeLimiteInferior == 0) || (porcentajeLimiteIntermedio == 0) || (porcentajeLimiteSuperior == 0))
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Garantia, Operacion, Mensajes.ASSEMBLY);

                        StringCollection parametros = new StringCollection();
                        parametros.Add(Garantia);
                        parametros.Add(Operacion);
                        parametros.Add("Alguno de los parámetros usados por el cálculo del monto de la tasación actualizada del terreno y no terreno calculado no fue obtenido o está mal parametrizado");

                        if (esServicioWindows)
                        {
                            descripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, parametros, Mensajes.ASSEMBLY);
                        }
                        else
                        {
                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, parametros,
                                                              Mensajes.ASSEMBLY), EventLogEntryType.Error);
                        }

                        return;
                    }
                    //Si todo está en orden, se procede a aplicar el cálculo
                    else
                    {
                        //Se crean las variables en las que se almacenarán los montos anteriores
                        decimal montoTATAnterior = 0;
                        decimal montoTANTAnterior = 0;

                        //Se recorre la lista de semestres generada, con el fin de actualizar los montos
                        foreach (clsSemestre entidadSemestre in ListaSemestresCalcular)
                        {
                            if (entidadSemestre.NumeroSemestre == 1)
                            {
                                entidadSemestre.MontoUltimaTasacionTerreno = montoUltimaTasacionTerreno;
                                entidadSemestre.MontoUltimaTasacionNoTerreno = montoUltimaTasacionNoTerreno;
                            }

                            entidadSemestre.Aplicar_Calculo_Semestre(montoTATAnterior, montoTANTAnterior, aplicarCalculoMTAT, aplicarCalculoMTANT);

                            if (entidadSemestre.ErrorDatos)
                            {
                                errorDatos = true;
                                descripcionError = entidadSemestre.DescripcionError;

                                if ((!entidadSemestre.MontoTasacionActualizadaTerreno.HasValue) &&
                                    (!entidadSemestre.MontoTasacionActualizadaNoTerreno.HasValue))
                                {
                                    break;
                                }
                            }
                            else
                            {
                                if (entidadSemestre.MontoTasacionActualizadaTerreno.HasValue)
                                {
                                    montoTATAnterior = ((decimal)entidadSemestre.MontoTasacionActualizadaTerreno);
                                }

                                if (entidadSemestre.MontoTasacionActualizadaNoTerreno.HasValue)
                                {
                                    montoTANTAnterior = ((decimal)entidadSemestre.MontoTasacionActualizadaNoTerreno);
                                }
                            }

                            if ((entidadSemestre.NumeroSemestre == entidadSemestre.TotalRegistros) && (!entidadSemestre.ErrorDatos))
                            {
                                montoTasacionActualizadaTerrenoCalculado = ((entidadSemestre.MontoTasacionActualizadaTerreno.HasValue) ? ((decimal)entidadSemestre.MontoTasacionActualizadaTerreno) : ((decimal?)null));
                                montoTasacionActualizadaNoTerrenoCalculado = ((entidadSemestre.MontoTasacionActualizadaNoTerreno.HasValue) ? ((decimal)entidadSemestre.MontoTasacionActualizadaNoTerreno) : ((decimal?)null));
                                avaluoActualizado = true;
                                fechaSemestreCalculado = entidadSemestre.FechaSemestre;

                            }
                        }
                    }
                }
                catch (ArithmeticException exArimetico)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Garantia, Operacion, Mensajes.ASSEMBLY);

                    StringCollection parametros = new StringCollection();
                    parametros.Add(Garantia);
                    parametros.Add(Operacion);
                    parametros.Add(exArimetico.Message);

                    if (esServicioWindows)
                    {
                        descripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, parametros, Mensajes.ASSEMBLY);
                    }
                    else
                    {
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    }

                    return;
                }
                catch (ArgumentException exArgumento)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Garantia, Operacion, Mensajes.ASSEMBLY);

                    StringCollection parametros = new StringCollection();
                    parametros.Add(Garantia);
                    parametros.Add(Operacion);
                    parametros.Add(exArgumento.Message);

                    if (esServicioWindows)
                    {
                        descripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, parametros, Mensajes.ASSEMBLY);
                    }
                    else
                    {
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    }


                    return;
                }
                catch (Exception exGeneral)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Garantia, Operacion, Mensajes.ASSEMBLY);

                    StringCollection parametros = new StringCollection();
                    parametros.Add(Garantia);
                    parametros.Add(Operacion);
                    parametros.Add(exGeneral.Message);

                    if (esServicioWindows)
                    {
                        descripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, parametros, Mensajes.ASSEMBLY);
                    }
                    else
                    {
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    }

                    return;
                }
            }
        }

        /// <summary>
        /// Extrae la lista de operaciones relacionadas, esto de la trama inicial de datos
        /// </summary>
        /// <param name="tramaDatos">Trama XML que posee la lista de operaciones asociadas</param>
        /// <returns></returns>
        public clsOperacionesCrediticias<clsOperacionCrediticia> ObtenerListaOperaciones(string tramaDatos)
        {
            OperacionesRelacionadas = new clsOperacionesCrediticias<clsOperacionCrediticia>();

            if (tramaDatos.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();

                try
                {
                    xmlTrama.LoadXml(tramaDatos);
                }
                catch
                {
                    return OperacionesRelacionadas;
                }

                #region Operaciones Relacionadas

                if (xmlTrama.SelectSingleNode("//" + _tagOperacionesAsociadas) != null)
                {
                    XmlDocument xmlOperacionesRelacionadas = new XmlDocument();

                    try
                    {
                        xmlOperacionesRelacionadas.LoadXml(xmlTrama.SelectSingleNode("//" + _tagOperacionesAsociadas).OuterXml);
                    }
                    catch
                    {
                        return OperacionesRelacionadas;
                    }

                    if (xmlOperacionesRelacionadas != null)
                    {
                        clsOperacionCrediticia operacionRelacionada;
                        try
                        {
                            foreach (XmlNode nodoOperacion in xmlOperacionesRelacionadas.SelectNodes("//" + _tagOperacion))
                            {
                                if (nodoOperacion.SelectSingleNode("//" + _tagOperacion) != null)
                                {
                                    operacionRelacionada = new clsOperacionCrediticia((nodoOperacion.OuterXml));

                                    if (operacionRelacionada != null)
                                    {
                                        OperacionesRelacionadas.Agregar(operacionRelacionada);
                                    }
                                }
                            }
                        }
                        catch
                        {
                            return OperacionesRelacionadas;
                        }
                    }
                }

                #endregion Operaciones Relacionadas
            }

            return OperacionesRelacionadas;
        }

        public clsPolizasSap<clsPolizaSap> ObtenerListaPolizas(string tramaDatos)
        {
            PolizasSap = new clsPolizasSap<clsPolizaSap>();

            if (tramaDatos.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();

                try
                {
                    xmlTrama.LoadXml(tramaDatos);
                }
                catch
                {
                    return PolizasSap;
                }

                #region Polizas

                if (xmlTrama.SelectSingleNode("//" + _tagPolizas) != null)
                {
                    XmlDocument xmlPolizasSap = new XmlDocument();

                    try
                    {
                        xmlPolizasSap.LoadXml(xmlTrama.SelectSingleNode("//" + _tagPolizas).OuterXml);
                    }
                    catch
                    {
                        return PolizasSap;
                    }

                    if (xmlPolizasSap != null)
                    {
                        clsPolizaSap polizaSAP;
                        try
                        {
                            foreach (XmlNode nodoPoliza in xmlPolizasSap.SelectNodes("//" + _tagPoliza))
                            {
                                if (nodoPoliza.SelectSingleNode("//" + _tagPoliza) != null)
                                {
                                    polizaSAP = new clsPolizaSap((nodoPoliza.OuterXml));

                                    if (polizaSAP != null)
                                    {
                                        PolizasSap.Agregar(polizaSAP);
                                    }
                                }
                            }
                        }
                        catch
                        {
                            return PolizasSap;
                        }
                    }
                }

                #endregion Polizas
            }

            return PolizasSap;
        }

        /// <summary>
        /// Determina si los campos de los porcentajes de aceptación del terreno y no terreno deben de ser habilitados
        /// </summary>
        /// <returns>True: Los campos deben de ser habilitados. False: Los campos deben de ser bloqueados</returns>
        public bool HabilitarPorcentajesAceptacionAvaluo()
        {
            bool debenHabilitarse = false;

            //SI LA CLASE DE GARANTIA REAL ES HIPOTECA COMUN
            if (codTipoGarantiaReal.Equals(1))
            {
                if (codTipoBien.Equals(1) && codTipoMitigador.Equals(1))
                    debenHabilitarse = true;

                //SI TIPO BIEN ES IGUAL A EDIFICACIONES Y TIPO MITIGADOR RIESGO IGUAL A 2 (HIPOTECAS SOBRE EDIFICACIONES), 
                //3 (HIPOTECAS SOBRE RESIDENCIAS HABITADAS POR EL DEUDOR (PONDERACIÓN DEL 50%)), 5 (CÉDULAS HIPOTECARIAS SOBRE TERRENOS) 
                //Y 6 (CÉDULAS HIPOTECARIAS SOBRE EDIFICACIONES)
                if (codTipoBien.Equals(2) && ((codTipoMitigador.Equals(2) || codTipoMitigador.Equals(3)
                                            || codTipoMitigador.Equals(5) || codTipoMitigador.Equals(6))))
                {
                    debenHabilitarse = true;
                }
            }

            //SI LA CLASE DE GARANTIA REAL ES CEDULA HIPOTECARIA O IGUAL A PRENDA
            if (codTipoGarantiaReal.Equals(2) || codTipoGarantiaReal.Equals(3))
            {
                //SI TIPO BIEN ES IGUAL TERRENOS Y, TIPO MITIGADOR RIESGO IGUAL A HIPOTECA SOBRE TERRENOS Y CED HIPOT SOBRE TERRENOS
                if (codTipoBien.Equals(1) && ((codTipoMitigador.Equals(1) || codTipoMitigador.Equals(4))))
                    debenHabilitarse = true;

                //SI TIPO BIEN ES IGUAL A EDIFICACIONES Y TIPO MITIGADOR RIESGO IGUAL A 2 (HIPOTECAS SOBRE EDIFICACIONES), 
                //3 (HIPOTECAS SOBRE RESIDENCIAS HABITADAS POR EL DEUDOR (PONDERACIÓN DEL 50%)), 5 (CÉDULAS HIPOTECARIAS SOBRE TERRENOS) 
                //Y 6 (CÉDULAS HIPOTECARIAS SOBRE EDIFICACIONES)
                if (codTipoBien.Equals(2) && ((codTipoMitigador.Equals(2) || codTipoMitigador.Equals(3)
                                            || codTipoMitigador.Equals(5) || codTipoMitigador.Equals(6))))
                {
                    debenHabilitarse = true;
                }

                //SI TIPO BIEN IGUAL A VEHICULOS O IGUAL A MAQUINARIA Y EQUIPO
                //Y TIPO MITIGADOR RIESDO IGUAL A 7 (PRENDA S/BIENES MUEBLES E HIPOTECAS S/MAQUINARIA FIJADA PERM. AL TERRENO)
                if ((codTipoBien.Equals(3) || codTipoBien.Equals(4)) && (codTipoMitigador.Equals(7)))
                    debenHabilitarse = true;
            }

            return debenHabilitarse;
        }

        /// <summary>
        /// Obtiene el monto mitigador calculado
        /// </summary>
        /// <returns>Monto mitigador calculado</returns>
        public decimal CalcularMontoMitigador()
        {
            decimal montoMitigadorCalculado = 0;

            if (HabilitarPorcentajesAceptacionAvaluo())
            {
                //Se establecen los porcentajes de aceptación en caso de que no existan
                decimal porcentaAceptTerreno = ((porcentajeAceptacionTerreno >= 0) ? porcentajeAceptacionTerreno : porcentajeAceptacionTerrenoCalculado);
                decimal porcentaAceptaNoTerreno = ((porcentajeAceptacionNoTerreno >= 0) ? porcentajeAceptacionNoTerreno : porcentajeAceptacionNoTerrenoCalculado);

                if (codTipoBien == 1)
                {
                    //Se obtiene el menor de cada porcentaje
                    decimal porcentajeAceptTerrenoMenor = ((porcentaAceptTerreno <= porcentajeAceptacionTerrenoCalculado) ? porcentaAceptTerreno : porcentajeAceptacionTerrenoCalculado);

                    //Se calcula el monto mitigador
                    montoMitigadorCalculado = Convert.ToDecimal((montoTasacionActualizadaTerreno * (Convert.ToDecimal((porcentajeAceptTerrenoMenor / 100)))));
                }
                else
                {
                    //Se obtiene el menor de cada porcentaje
                    decimal porcentajeAceptTerrenoMenor = ((porcentaAceptTerreno <= porcentajeAceptacionTerrenoCalculado) ? porcentaAceptTerreno : porcentajeAceptacionTerrenoCalculado);
                    decimal porcentajeAceptNoTerrenoMenor = ((porcentaAceptaNoTerreno <= porcentajeAceptacionNoTerrenoCalculado) ? porcentaAceptaNoTerreno : porcentajeAceptacionNoTerrenoCalculado);

                    //Se obtiene la proporcionalidad del terreno
                    decimal montoProporcionalTerreno = Convert.ToDecimal((montoTasacionActualizadaTerreno * (Convert.ToDecimal((porcentajeAceptTerrenoMenor / 100)))));

                    //Se obtiene la proporcionalidad del no terreno
                    decimal montoProporcionalNoTerreno = Convert.ToDecimal((montoTasacionActualizadaNoTerreno * (Convert.ToDecimal((porcentajeAceptNoTerrenoMenor / 100)))));

                    //Se calcula el monto mitigador
                    montoMitigadorCalculado = Convert.ToDecimal(montoProporcionalTerreno + montoProporcionalNoTerreno);
                }
            }
            else
            {
                decimal porcentajeAceptMenor = ((porcentajeAceptacion <= porcentajeAceptacionCalculado) ? porcentajeAceptacion : porcentajeAceptacionCalculado);

                decimal montoTotalAvaluo = montoTasacionActualizadaTerreno + montoTasacionActualizadaNoTerreno;

                //Se calcula el monto mitigador
                montoMitigadorCalculado = Convert.ToDecimal((montoTotalAvaluo * (Convert.ToDecimal((porcentajeAceptMenor / 100)))));
            }

            return montoMitigadorCalculado;
        }

        /// <summary>
        /// Obtiene la diferencia entre el monto mitigador digitado por el usuario y el calculado por el sistema
        /// </summary>
        /// <returns>Diferencia obtenida entre los dos montos</returns>
        public decimal ObtenerDiferenciaMontosMitigadores()
        {
            decimal diferenciaMontos = 0;

            decimal montoMitigadorDigitado = montoMitigador;
            decimal montoMitigadorCalculado = CalcularMontoMitigador();

            diferenciaMontos = (((montoMitigadorCalculado >= montoMitigadorDigitado)) ? (Convert.ToDecimal(montoMitigadorCalculado - montoMitigadorDigitado)) : (Convert.ToDecimal(montoMitigadorDigitado - montoMitigadorCalculado)));

            return diferenciaMontos;
        }

        #endregion Métodos Públicos

        #region Métodos Privados

        /// <summary>
        /// Convierte los datos relevantes dela entidad en formato xml
        /// </summary>
        /// <param name="tipoGeneracion">Indica el tipo de generación que se desea, a saber: 
        ///     0 = Todo, 
        ///     1 = Todo, menos las operaciones asociadas y la información del avalúo del SICC. 
        /// </param>
        /// <returns>Trama xml con los datos que posee la entidad</returns>
        private string ConvertirAXML(short tipoGeneracion)
        {
            bool generarOperacion = false;
            bool generarGarantias = false;
            bool generarAvaluo = false;
            bool generarOperacionesAsociadas = false;
            bool generarAvaluoSICC = false;
            bool generarSemestresACalcular = false;
            bool generarDocumento = true;
            bool generarListaSemestresCalculados = false;
            bool generarListaPolizasSap = false;

            switch (tipoGeneracion)
            {
                case 0: generarOperacion = true;
                    generarGarantias = true;
                    generarAvaluo = true;
                    generarOperacionesAsociadas = true;
                    generarAvaluoSICC = true;
                    generarSemestresACalcular = true;
                    generarListaPolizasSap = true;
                    break;

                case 1: generarOperacion = true;
                    generarGarantias = true;
                    generarAvaluo = true;
                    generarOperacionesAsociadas = false;
                    generarAvaluoSICC = false;
                    generarListaPolizasSap = true;
                    break;

                case 2: generarListaSemestresCalculados = true;
                    break;

                default: generarDocumento = false;
                    break;
            }

            string tramaGenerada = string.Empty;

            if (generarDocumento)
            {
                MemoryStream stream = new MemoryStream(200000);

                //Crea un escritor de XML con el path y el formato
                XmlTextWriter objEscritor = new XmlTextWriter(stream, Encoding.Unicode);

                //Se inicializa para que idente el archivo
                objEscritor.Formatting = Formatting.None;

                //Inicializa el Documento XML
                objEscritor.WriteStartDocument();

                //Inicializa el nodo raiz
                objEscritor.WriteStartElement(_tagDatos);

                #region OPERACION

                if (generarOperacion)
                {
                    //Inicializa el nodo que poseer los datos de la garantía
                    objEscritor.WriteStartElement(_tagOperacion);

                    //Crea el nodo de la contabilidad
                    objEscritor.WriteStartElement(_codContabilidad);
                    objEscritor.WriteString(codContabilidad.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la oficina
                    objEscritor.WriteStartElement(_codOficinaOper);
                    objEscritor.WriteString(codOficina.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la moneda
                    objEscritor.WriteStartElement(_codMonedaOper);
                    objEscritor.WriteString(codMonedaOper.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del producto
                    objEscritor.WriteStartElement(_codProducto);
                    objEscritor.WriteString(codProducto.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del número de operación/contrato
                    objEscritor.WriteStartElement(_numOperacion);
                    objEscritor.WriteString(numOperacion.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del número de operación/contrato
                    objEscritor.WriteStartElement(_tipoOperacion);
                    objEscritor.WriteString(tipoOperacionCred.ToString());
                    objEscritor.WriteEndElement();

                    //Final del tag OPERACION
                    objEscritor.WriteEndElement();
                }

                #endregion OPERACION

                #region GARANTIAS

                /*
              <GARANTIA>
                <cod_operacion>91137</cod_operacion>
                <cod_garantia_real>14603</cod_garantia_real>
                <cod_tipo_garantia>2</cod_tipo_garantia>
                <cod_clase_garantia>10</cod_clase_garantia>
                <cod_tipo_garantia_real>1</cod_tipo_garantia_real>
                <des_tipo_garantia_real>Hipoteca</des_tipo_garantia_real>
                <garantia_real>Partido: 6 - Finca: 40942</garantia_real>
                <cod_partido>6</cod_partido>
                <numero_finca>40942</numero_finca>
                <cod_grado></cod_grado>
                <cedula_hipotecaria></cedula_hipotecaria>
                <cod_clase_bien></cod_clase_bien>
                <num_placa_bien></num_placa_bien>
                <cod_tipo_bien>2</cod_tipo_bien>
                <cod_tipo_mitigador>-1</cod_tipo_mitigador>
                <cod_tipo_documento_legal>-1</cod_tipo_documento_legal>
                <monto_mitigador>0.00</monto_mitigador>
                <cod_inscripcion>-1</cod_inscripcion>
                <fecha_presentacion>10/12/2009</fecha_presentacion>
                <porcentaje_responsabilidad>100.00</porcentaje_responsabilidad>
                <cod_grado_gravamen>1</cod_grado_gravamen>
                <cod_operacion_especial>0</cod_operacion_especial>
                <fecha_constitucion>10/12/2009</fecha_constitucion>
                <fecha_vencimiento>10/11/2019</fecha_vencimiento>
                <cod_tipo_acreedor>2</cod_tipo_acreedor>
                <ced_acreedor>4000000019</ced_acreedor>
                <cod_liquidez>-1</cod_liquidez>
                <cod_tenencia>4</cod_tenencia>
                <cod_moneda>1</cod_moneda>
                <fecha_prescripcion>09/12/2029</fecha_prescripcion>
                <cod_estado>1</cod_estado>
                <fecha_valuacion>30/11/2005</fecha_valuacion>
                <monto_total_avaluo>21517893.1500</monto_total_avaluo>
                <des_tipo_bien>Edificaciones</des_tipo_bien>
                <des_tipo_mitigador>--</des_tipo_mitigador>
                <des_tipo_documento>--</des_tipo_documento>
                <des_tipo_inscripcion>--</des_tipo_inscripcion>
                <des_tipo_grado_gravamen>1 grado</des_tipo_grado_gravamen>
                <des_tipo_operacion_especial>Normal</des_tipo_operacion_especial>
                <des_tipo_persona>Persona jurdica nacional</des_tipo_persona>
                <des_tipo_liquidez>--</des_tipo_liquidez>
                <des_tipo_tenencia>Consentidor</des_tipo_tenencia>
                <des_tipo_moneda>Colones</des_tipo_moneda>
              </GARANTIA>
            */

                if (generarGarantias)
                {
                    //Inicializa el nodo que poseer los datos de la garantía
                    objEscritor.WriteStartElement(_tagGarantia);

                    //Crea el nodo del consecutivo de la operación
                    objEscritor.WriteStartElement(_codOperacion);
                    objEscritor.WriteString(codOperacion.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del consecutivo de la garantía real
                    objEscritor.WriteStartElement(_codGarantiaReal);
                    objEscritor.WriteString(codGarantiaReal.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del tipo de garantía
                    objEscritor.WriteStartElement(_codTipoGarantia);
                    objEscritor.WriteString(codTipoGarantia.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la clase de garantía
                    objEscritor.WriteStartElement(_codClaseGarantia);
                    objEscritor.WriteString(codClaseGarantia.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del tipo de garantía real
                    objEscritor.WriteStartElement(_codTipoGarantiaReal);
                    objEscritor.WriteString(codTipoGarantiaReal.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del tipo de garantía real
                    objEscritor.WriteStartElement(_desTipoGarantiaReal);
                    objEscritor.WriteString(desTipoGarantiaReal);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción de la garantía, según el formato partido - finca o clase de bien - número placa del bien
                    objEscritor.WriteStartElement(_garantiaReal);
                    objEscritor.WriteString(garantiaReal);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código del partido
                    objEscritor.WriteStartElement(_codPartido);
                    objEscritor.WriteString(codPartido.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo número de finca
                    objEscritor.WriteStartElement(_numeroFinca);
                    objEscritor.WriteString(numeroFinca);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del grado de la cédula hipotecaria
                    objEscritor.WriteStartElement(_codGrado);
                    objEscritor.WriteString(codGrado);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la cédula hipotecaria
                    objEscritor.WriteStartElement(_cedulaHipotecaria);
                    objEscritor.WriteString(cedulaHipotecaria);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la clase de bien
                    objEscritor.WriteStartElement(_codClaseBien);
                    objEscritor.WriteString(codClaseBien);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la identificación del bien
                    objEscritor.WriteStartElement(_numPlacaBien);
                    objEscritor.WriteString(numPlacaBien);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código del tipo de bien
                    objEscritor.WriteStartElement(_codTipoBien);
                    objEscritor.WriteString(codTipoBien.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código del tipo de mitigador
                    objEscritor.WriteStartElement(_codTipoMitigador);
                    objEscritor.WriteString(codTipoMitigador.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código del tipo de documento legal
                    objEscritor.WriteStartElement(_codTipoDocumentoLegal);
                    objEscritor.WriteString(codTipoDocumentoLegal.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto mitigador
                    objEscritor.WriteStartElement(_montoMitigador);
                    objEscritor.WriteString(montoMitigador.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código del indicador de inscripción
                    objEscritor.WriteStartElement(_codInscripcion);
                    objEscritor.WriteString(codInscripcion.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha de presentación
                    objEscritor.WriteStartElement(_fechaPresentacion);
                    objEscritor.WriteString(fechaPresentacion.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del porcentaje de responsabilidad
                    objEscritor.WriteStartElement(_porcentajeResponsabilidad);
                    objEscritor.WriteString(porcentajeResponsabilidad.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del grado de gravamen
                    objEscritor.WriteStartElement(_codGradoGravamen);
                    objEscritor.WriteString(codGradoGravamen.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código del tipo de operación especial
                    objEscritor.WriteStartElement(_codOperacionEspecial);
                    objEscritor.WriteString(codOperacionEspecial.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha de constitución
                    objEscritor.WriteStartElement(_fechaConstitucion);
                    objEscritor.WriteString(fechaConstitucion.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha de vencimiento
                    objEscritor.WriteStartElement(_fechaVencimiento);
                    objEscritor.WriteString(fechaVencimiento.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código del tipo de persona del acreedor
                    objEscritor.WriteStartElement(_codTipoAcreedor);
                    objEscritor.WriteString(codTipoAcreedor.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la identificación del acreedor
                    objEscritor.WriteStartElement(_cedAcreedor);
                    objEscritor.WriteString(cedAcreedor);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código de liquidez
                    objEscritor.WriteStartElement(_codLiquidez);
                    objEscritor.WriteString(codLiquidez.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código de tenencia
                    objEscritor.WriteStartElement(_codTenencia);
                    objEscritor.WriteString(codTenencia.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código de la moneda de la garantía
                    objEscritor.WriteStartElement(_codMoneda);
                    objEscritor.WriteString(codMoneda.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha de prescripción
                    objEscritor.WriteStartElement(_fechaPrescripcion);
                    objEscritor.WriteString(fechaPrescripcion.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código de estado del registro
                    objEscritor.WriteStartElement(_codEstado);
                    objEscritor.WriteString(codEstado.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del código del tipo de persona del acreedor
                    objEscritor.WriteStartElement(_codTipoAcreedor);
                    objEscritor.WriteString(codTipoAcreedor.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha del avalúo
                    objEscritor.WriteStartElement(_fechaValuacion);
                    objEscritor.WriteString(fechaValuacion.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto total del avalúo
                    objEscritor.WriteStartElement(_montoTotalAvaluo);
                    objEscritor.WriteString(montoTotalAvaluo.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del tipo de bien
                    objEscritor.WriteStartElement(_desTipoBien);
                    objEscritor.WriteString(desTipoBien);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del tipo de mitigador
                    objEscritor.WriteStartElement(_desTipoMitigador);
                    objEscritor.WriteString(desTipoMitigador);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del tipo de documento legal
                    objEscritor.WriteStartElement(_desTipoDocumento);
                    objEscritor.WriteString(desTipoDocumentoLegal);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del indicador de inscripción
                    objEscritor.WriteStartElement(_desTipoInscripcion);
                    objEscritor.WriteString(desIndicadorInscripcion);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del grado de gravamen
                    objEscritor.WriteStartElement(_desTipoGradoGravamen);
                    objEscritor.WriteString(desTipoGradoGravamen);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del tipo de operación especial
                    objEscritor.WriteStartElement(_desTipoOperacionEspecial);
                    objEscritor.WriteString(desTipoOperacionEspecial);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción código del tipo de persona del acreedor
                    objEscritor.WriteStartElement(_desTipoPersona);
                    objEscritor.WriteString(desTipoPersonaAcreedor);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción código del tipo de liquidez
                    objEscritor.WriteStartElement(_desTipoLiquidez);
                    objEscritor.WriteString(desTipoLiquidez);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción código del tipo de tenencia
                    objEscritor.WriteStartElement(_desTipoTenencia);
                    objEscritor.WriteString(desTipoTenencia);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción código del tipo de moneda de la garantía
                    objEscritor.WriteStartElement(_desTipoMoneda);
                    objEscritor.WriteString(desTipoMoneda);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del tipo de bien anterior
                    objEscritor.WriteStartElement(_desTipoBienAnterior);
                    objEscritor.WriteString(desTipoBienAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del tipo de mitigador anterior
                    objEscritor.WriteStartElement(_desTipoMitigadorAnterior);
                    objEscritor.WriteString(desTipoMitigadorAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del tipo de documento legal anterior
                    objEscritor.WriteStartElement(_desTipoDocumentoAnterior);
                    objEscritor.WriteString(desTipoDocumentoLegalAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del indicador de inscripción anterior
                    objEscritor.WriteStartElement(_desTipoInscripcionAnterior);
                    objEscritor.WriteString(desIndicadorInscripcionAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del grado de gravamen anterior
                    objEscritor.WriteStartElement(_desTipoGradoGravamenAnterior);
                    objEscritor.WriteString(desTipoGradoGravamenAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción del tipo de operación especial anterior
                    objEscritor.WriteStartElement(_desTipoOperacionEspecialAnterior);
                    objEscritor.WriteString(desTipoOperacionEspecialAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción código del tipo de persona del acreedor anterior
                    objEscritor.WriteStartElement(_desTipoPersonaAnterior);
                    objEscritor.WriteString(desTipoPersonaAcreedorAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción código del tipo de liquidez anterior
                    objEscritor.WriteStartElement(_desTipoLiquidezAnterior);
                    objEscritor.WriteString(desTipoLiquidezAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción código del tipo de tenencia anterior
                    objEscritor.WriteStartElement(_desTipoTenenciaAnterior);
                    objEscritor.WriteString(desTipoTenenciaAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripción código del tipo de moneda de la garantía anterior
                    objEscritor.WriteStartElement(_desTipoMonedaAnterior);
                    objEscritor.WriteString(desTipoMonedaAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del porcentaje de aceptacion calculado
                    objEscritor.WriteStartElement(_porcentajeAceptacionCalculado);
                    objEscritor.WriteString(porcentajeAceptacionCalculado.ToString("N2"));
                    objEscritor.WriteEndElement();


                    //Crea el nodo del porcentaje de aceptacion calculado
                    objEscritor.WriteStartElement(_porcentajeAceptacionCalculadoOriginal);
                    objEscritor.WriteString(porcentajeAceptacionCalculadoOriginal.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del indicador de que el deudor habita la vivienda
                    objEscritor.WriteStartElement(_indicadorViviendaHabitadaDeudor);
                    objEscritor.WriteString(((indicadorViviendaHabitadaDeudor) ? "1" : "0"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del porcentaje de aceptación
                    objEscritor.WriteStartElement(_porcentajeAceptacion);
                    objEscritor.WriteString(porcentajeAceptacion.ToString("N2"));
                    objEscritor.WriteEndElement();

                    #region Campos Bitacora

                    //Crea el nodo de la cedula del usuario que modificó la garantía
                    objEscritor.WriteStartElement(_usuarioModifico);
                    objEscritor.WriteString(usuarioModifico);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del nombre del usuario que modificó la garantía
                    objEscritor.WriteStartElement(_nombreUsuarioModifico);
                    objEscritor.WriteString(nombreUsuarioModifico);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha en que se modificó
                    objEscritor.WriteStartElement(_fechaModifico);
                    objEscritor.WriteString(fechaModifico.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha en que se insertó
                    objEscritor.WriteStartElement(_fechaInserto);
                    objEscritor.WriteString(fechaInserto.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha de la réplica
                    objEscritor.WriteStartElement(_fechaReplica);
                    objEscritor.WriteString(fechaReplica.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    #endregion

                    //Final del tag GARANTIAS
                    objEscritor.WriteEndElement();
                }

                #endregion GARANTIAS

                #region AVALUO MAS RECIENTE

                if (generarAvaluo)
                {
                    /*
                    
                      <AVALUO_MAS_RECIENTE>
                         <fecha_valuacion>2011-06-02T00:00:00</fecha_valuacion>
                         <cedula_perito>203680707</cedula_perito>
                         <monto_ultima_tasacion_terreno>14137500.0000</monto_ultima_tasacion_terreno>
                         <monto_ultima_tasacion_no_terreno>34931905.0000</monto_ultima_tasacion_no_terreno>
                         <monto_tasacion_actualizada_terreno>14137500.0000</monto_tasacion_actualizada_terreno>
                         <monto_tasacion_actualizada_no_terreno>34931905.0000</monto_tasacion_actualizada_no_terreno>
                         <fecha_ultimo_seguimiento>2011-06-02T00:00:00</fecha_ultimo_seguimiento>
                         <monto_total_avaluo>49069405.0000</monto_total_avaluo>
                         <fecha_construccion>2011-01-01T00:00:00</fecha_construccion>
                         <avaluo_actualizado>0</avaluo_actualizado>
                         <fecha_semestre_actualizado>01/01/1900</fecha_semestre_actualizado>
                         <fecha_valuacion_sicc>01/01/1900</fecha_valuacion_sicc>
                      </AVALUO_MAS_RECIENTE>
                     
                    */

                    //Inicializa el nodo que poseer los datos del avalúo más reciente
                    objEscritor.WriteStartElement(_tagAvaluoReciente);

                    //Crea el nodo de la fecha de valuación
                    objEscritor.WriteStartElement(_fechaValuacion);
                    objEscritor.WriteString(fechaValuacion.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la cédula de la empresa valuadora
                    objEscritor.WriteStartElement(_cedulaEmpresa);
                    objEscritor.WriteString(cedulaEmpresa);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la cédula del perito
                    objEscritor.WriteStartElement(_cedulaPerito);
                    objEscritor.WriteString(cedulaPerito);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto de la última tasación del terreno
                    objEscritor.WriteStartElement(_montoUltimaTasacionTerreno);
                    objEscritor.WriteString(montoUltimaTasacionTerreno.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto de la última tasación del no terreno
                    objEscritor.WriteStartElement(_montoUltimaTasacionNoTerreno);
                    objEscritor.WriteString(montoUltimaTasacionNoTerreno.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto de la tasación actualizada del terreno
                    objEscritor.WriteStartElement(_montoTasacionActualizadaTerreno);
                    objEscritor.WriteString(montoTasacionActualizadaTerreno.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto de la tasación actualizada del no terreno
                    objEscritor.WriteStartElement(_montoTasacionActualizadaNoTerreno);
                    objEscritor.WriteString(montoTasacionActualizadaNoTerreno.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha del último seguimiento
                    objEscritor.WriteStartElement(_fechaUltimoSeguimiento);
                    objEscritor.WriteString(fechaUltimoSeguimiento.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto total del avalúo
                    objEscritor.WriteStartElement(_montoTotalAvaluo);
                    objEscritor.WriteString(montoTotalAvaluo.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha de la fecha de construcción
                    objEscritor.WriteStartElement(_fechaConstruccion);
                    objEscritor.WriteString(fechaConstruccion.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del indicador de si el avalúo ha sido actualizado
                    objEscritor.WriteStartElement(_avaluoActualizado);
                    objEscritor.WriteString((avaluoActualizado ? "1" : "0"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha del último semestre calculado
                    objEscritor.WriteStartElement(_fechaSemestreActualizado);
                    objEscritor.WriteString(fechaSemestreCalculado.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha de valuación registrada en el SICC
                    objEscritor.WriteStartElement(_fechaValuacionSICC);
                    objEscritor.WriteString(fechaValuacionSICC.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    #region RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno

                    //Crea el nodo del porcentaje de aceptación del terreno
                    objEscritor.WriteStartElement(_porcentajeAceptacionTerreno);
                    objEscritor.WriteString(string.Format("{0:N2}", porcentajeAceptacionTerreno));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del porcentaje de aceptación del no terreno
                    objEscritor.WriteStartElement(_porcentajeAceptacionNoTerreno);
                    objEscritor.WriteString(string.Format("{0:N2}", porcentajeAceptacionNoTerreno));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del porcentaje de aceptación del terreno calculado
                    objEscritor.WriteStartElement(_porcentajeAceptacionTerrenoCalculado);
                    objEscritor.WriteString(string.Format("{0:N2}", porcentajeAceptacionTerrenoCalculado));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del porcentaje de aceptación del no terreno calculado
                    objEscritor.WriteStartElement(_porcentajeAceptacionNoTerrenoCalculado);
                    objEscritor.WriteString(string.Format("{0:N2}", porcentajeAceptacionNoTerrenoCalculado));
                    objEscritor.WriteEndElement();

                    #endregion

                    //Final del tag AVALUO_MAS_RECIENTE
                    objEscritor.WriteEndElement();
                }

                #endregion AVALUO MAS RECIENTE

                #region AVALUO SICC

                if (generarAvaluoSICC)
                {
                    /*
                    
                      <AVALUO_SICC>
                        <prmgt_pfeavaing></prmgt_pfeavaing>
                        <prmgt_pmoavaing>0.00</prmgt_pmoavaing>
                      </AVALUO_SICC>
                     
                    */

                    //Inicializa el nodo que poseer los datos del avalúo registrado en el SICC
                    objEscritor.WriteStartElement(_tagAvaluoSICC);

                    //Crea el nodo de la fecha de valuación del SICC
                    objEscritor.WriteStartElement(_prmgtFechaValuacion);
                    objEscritor.WriteString(fechaValuacionSICC.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto total del avalúo del SICC
                    objEscritor.WriteStartElement(_prmgtMontoTotalAvaluo);
                    objEscritor.WriteString(montoTotalAvaluoSICC.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Final del tag AVALUO_SICC
                    objEscritor.WriteEndElement();
                }

                #endregion AVALUO SICC

                #region PARAMETROS DEL CALCULO

                if (generarAvaluoSICC)
                {
                    /*
                    
                      <PARAM_CALCULO>
                        <porcentaje_limite_inferior>0.009</porcentaje_limite_inferior>
                        <porcentaje_limite_intermedio>0.015</porcentaje_limite_intermedio>
                        <porcentaje_limite_superior>0.030</porcentaje_limite_superior>
                        <annos_limite_inferior>10</annos_limite_inferior>
                        <annos_limite_intermedio>40</annos_limite_intermedio>
                        <annos_limite_superior>41</annos_limite_superior>
                        <meses_por_anno>12</meses_por_anno>
                        <dias_por_mes>30</dias_por_mes>
                      </PARAM_CALCULO>
                     
                    */

                    //Inicializa el nodo que poseer los datos de los parámetros usados para el cálculo
                    objEscritor.WriteStartElement(_tagParametrosCalculo);

                    //Crea el nodo del porcentaje del límite inferior 
                    objEscritor.WriteStartElement(_porcentajeLimiteInferior);
                    objEscritor.WriteString(porcentajeLimiteInferior.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del porcentaje del límite intermedio 
                    objEscritor.WriteStartElement(_porcentajeLimiteIntermedio);
                    objEscritor.WriteString(porcentajeLimiteIntermedio.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del porcentaje del límite superior 
                    objEscritor.WriteStartElement(_porcentajeLimiteSuperior);
                    objEscritor.WriteString(porcentajeLimiteSuperior.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de los años del límite inferior
                    objEscritor.WriteStartElement(_annosLimiteInferior);
                    objEscritor.WriteString(annosLimiteInferior.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de los años del límite intermedio
                    objEscritor.WriteStartElement(_annosLimiteIntermedio);
                    objEscritor.WriteString(annosLimiteIntermedio.ToString());
                    objEscritor.WriteEndElement();

                    //Final del tag PARAM_CALCULO
                    objEscritor.WriteEndElement();
                }

                #endregion PARAMETROS DEL CALCULO

                #region OPERACIONES RELACIONADAS

                if (generarOperacionesAsociadas)
                {
                    /*
                    
                      <OPERACIONES_ASOCIADAS>
                        <OPERACION>
                          <contabilidad>1</contabilidad>
                          <oficina>270</oficina>
                          <moneda>1</moneda>
                          <producto>2</producto>
                          <numeroOperacion>5759497</numeroOperacion>
                          <tipoOperacion>1</tipoOperacion>
                        </OPERACION>
                      </OPERACIONES_ASOCIADAS>
                     
                    */

                    //Inicializa el nodo que poseer los datos de las operaciones asociadas
                    objEscritor.WriteString(operacionesCrediticias.ObtenerTrama());
                }

                #endregion OPERACIONES RELACIONADAS

                #region INCONSISTENCIAS

                /*
             
             <INCONSISTENCIAS>
                <fecha_presentacion>0</fecha_presentacion>
                <indicador_inscripcion>0</indicador_inscripcion>
                <monto_mitigador>0</monto_mitigador>
                <porcentaje_aceptacion>0</porcentaje_aceptacion>
                <partido>0</partido>
                <clase_garantia>0</clase_garantia>
                <tipo_bien>0</tipo_bien>
                <tipo_mitigador>1</tipo_mitigador>
                <tipo_documento_legal>0</tipo_documento_legal>
                <grado_gravamen>0</grado_gravamen>
                <valuaciones_terreno>0</valuaciones_terreno>
                <valuaciones_no_terreno>0</valuaciones_no_terreno>
              </INCONSISTENCIAS>
             
             */

                //if (generarInconsistencias)
                //{
                ////Inicializa el nodo que poseer los datos de las inconsistencias
                //objEscritor.WriteStartElement(_tagInconsistencias);

                ////Crea el nodo de la inconsistencia de la fecha de presentación
                //objEscritor.WriteStartElement(_inconsistenciaFechaPresentacion);
                //objEscritor.WriteString(((this.inconsistenciaFechaPresentacion) ? "1" : "0"));
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia del indicador de incripcin
                //objEscritor.WriteStartElement(_inconsistenciaIndicadorInscripcion);
                //objEscritor.WriteString(((this.inconsistenciaIndicadorInscripcion) ? "1" : "0"));
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia del monto mitigador
                //objEscritor.WriteStartElement(_inconsistenciaMontoMitigador);
                //objEscritor.WriteString(this.inconsistenciaMontoMitigador.ToString());
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia del porcentaje de aceptación
                //objEscritor.WriteStartElement(_inconsistenciaPorcentajeAceptacion);
                //objEscritor.WriteString(((this.inconsistenciaPorcentajeAceptacion) ? "1" : "0"));
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia del partido
                //objEscritor.WriteStartElement(_inconsistenciaPartido);
                //objEscritor.WriteString(((this.inconsistenciaPartido) ? "1" : "0"));
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia del número de finca
                //objEscritor.WriteStartElement(_inconsistenciaFinca);
                //objEscritor.WriteString(((this.inconsistenciaFinca) ? "1" : "0"));
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia de la clase de garantía
                //objEscritor.WriteStartElement(_inconsistenciaClaseGarantia);
                //objEscritor.WriteString(((this.inconsistenciaClaseGarantia) ? "1" : "0"));
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia del tipo de bien
                //objEscritor.WriteStartElement(_inconsistenciaTipoBien);
                //objEscritor.WriteString(((this.inconsistenciaTipoBien) ? "1" : "0"));
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia del tipo de mitigador
                //objEscritor.WriteStartElement(_inconsistenciaTipoMitigador);
                //objEscritor.WriteString(((this.inconsistenciaTipoMitigador) ? "1" : "0"));
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia del tipo de documento legal
                //objEscritor.WriteStartElement(_inconsistenciaTipoDocumentoLegal);
                //objEscritor.WriteString(((this.inconsistenciaTipoDocumentoLegal) ? "1" : "0"));
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia del grado de gravamen
                //objEscritor.WriteStartElement(_inconsistenciaGradoGravamen);
                //objEscritor.WriteString(((this.inconsistenciaGradoGravamen) ? "1" : "0"));
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia de la valuación del terreno
                //objEscritor.WriteStartElement(_inconsistenciaValuacionesTerreno);
                //objEscritor.WriteString(((this.inconsistenciaValuacionesTerreno) ? "1" : "0"));
                //objEscritor.WriteEndElement();

                ////Crea el nodo de la inconsistencia de la valuación del no terreno
                //objEscritor.WriteStartElement(_inconsistenciaValuacionesNoTerreno);
                //objEscritor.WriteString(this.inconsistenciaValuacionesNoTerreno.ToString());
                //objEscritor.WriteEndElement();

                ////Final del tag INCONSISTENCIAS
                //objEscritor.WriteEndElement();
                //}

                #endregion INCONSISTENCIAS

                #region Cálculo del MTAT y MTANT

                if (generarSemestresACalcular)
                {
                    /*
                    
                      <SEMESTRES_A_CALCULAR>
                        <SEMESTRE>
                            <Numero_Semestre>1</Numero_Semestre>
                            <Fecha_Semestre>2013-01-11T00:00:00</Fecha_Semestre>
                            <Tipo_Cambio>492.78</Tipo_Cambio>
                            <IPC>158.74</IPC>
                            <Tipo_Cambio_Anterior>497.15</Tipo_Cambio_Anterior>
                            <IPC_Anterior>153.39</IPC_Anterior>
                            <Total_Registros>2</Total_Registros>
                        </SEMESTRE>
                        <SEMESTRE>
                            <Numero_Semestre>2</Numero_Semestre>
                            <Fecha_Semestre>2013-07-11T00:00:00</Fecha_Semestre>
                            <Tipo_Cambio>493.03</Tipo_Cambio>
                            <IPC>162.31</IPC>
                            <Tipo_Cambio_Anterior>492.78</Tipo_Cambio_Anterior>
                            <IPC_Anterior>158.74</IPC_Anterior>
                            <Total_Registros>2</Total_Registros>
                        </SEMESTRE>
                      </SEMESTRES_A_CALCULAR>
                     
                    */

                    //Inicializa el nodo que poseer los datos de los semestres a calcular
                    objEscritor.WriteString(ListaSemestresCalcular.ObtenerTrama());
                }

                #endregion Cálculo del MTAT y MTANT

                #region Lista de Semestres Calculados

                if (generarListaSemestresCalculados)
                {
                    //Inicializa el nodo que poseer los datos de los semestres calculados
                    objEscritor.WriteStartElement(_tagSemestresACalcular);

                    if (listaSemestresCalcular.Count > 0)
                    {
                        string montoUltimaTasacionTerreno = "0.00";
                        string montoUltimaTasacionNoTerreno = "0.00";

                        foreach (clsSemestre semestre in listaSemestresCalcular)
                        {
                            if (semestre.NumeroSemestre == 1)
                            {
                                montoUltimaTasacionTerreno = semestre.MontoUltimaTasacionTerreno.ToString();
                                montoUltimaTasacionNoTerreno = semestre.MontoUltimaTasacionNoTerreno.ToString();
                            }

                            objEscritor.WriteStartElement(_tagSemestre);

                            //Crea el nodo de la fecha en que se aplicó el cálculo del semestre
                            objEscritor.WriteStartElement(_fechaHoraCalculo);
                            objEscritor.WriteString(semestre.FechaHoraCalculo.ToString("yyyyMMdd HH:mm:ss"));
                            objEscritor.WriteEndElement();

                            //Crea el nodo del código de la garantía
                            objEscritor.WriteStartElement(_idGarantiaCalculo);
                            objEscritor.WriteString(garantia);
                            objEscritor.WriteEndElement();

                            //Crea el nodo del tipo de garantía real
                            objEscritor.WriteStartElement(_tipoGarantiaRealCalculo);
                            objEscritor.WriteString(codTipoGarantiaReal.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo de la clase de garantía real
                            objEscritor.WriteStartElement(_claseGarantiaCalculo);
                            objEscritor.WriteString(codClaseGarantia.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo de la fecha del semestre evaluado
                            objEscritor.WriteStartElement(_semestreCalculadoCalculo);
                            objEscritor.WriteString(semestre.FechaSemestre.ToString("yyyyMMdd HH:mm:ss"));
                            objEscritor.WriteEndElement();

                            //Crea el nodo de la fecha del avalúo
                            objEscritor.WriteStartElement(_fechaValuacionCalculo);
                            objEscritor.WriteString(fechaValuacion.ToString("yyyyMMdd"));
                            objEscritor.WriteEndElement();

                            //Crea el nodo del monto de la última tasación del terreno
                            objEscritor.WriteStartElement(_montoUltimaTasacionTerrenoCalculo);
                            objEscritor.WriteString(montoUltimaTasacionTerreno);
                            objEscritor.WriteEndElement();

                            //Crea el nodo del monto de la última tasación del no terreno
                            objEscritor.WriteStartElement(_montoUltimaTasacionNoTerrenoCalculo);
                            objEscritor.WriteString(montoUltimaTasacionNoTerreno);
                            objEscritor.WriteEndElement();

                            //Crea el nodo del tipo de cambio
                            objEscritor.WriteStartElement(_tipoCambioCalculo);
                            objEscritor.WriteString(((semestre.TipoCambio.HasValue) ? semestre.TipoCambio.ToString() : string.Empty));
                            objEscritor.WriteEndElement();

                            //Crea el nodo del índice de precios al consumidor
                            objEscritor.WriteStartElement(_ipcCalculo);
                            objEscritor.WriteString(((semestre.IPC.HasValue) ? semestre.IPC.ToString() : string.Empty));
                            objEscritor.WriteEndElement();

                            //Crea el nodo del tipo de cambio anterior
                            objEscritor.WriteStartElement(_tipoCambioAnteriorCalculo);
                            objEscritor.WriteString(((semestre.TipoCambioAnterior.HasValue) ? semestre.TipoCambioAnterior.ToString() : string.Empty));
                            objEscritor.WriteEndElement();

                            //Crea el nodo del índice de precios al consumidor anterior
                            objEscritor.WriteStartElement(_ipcAnteriorCalculo);
                            objEscritor.WriteString(((semestre.IPCAnterior.HasValue) ? semestre.IPCAnterior.ToString() : string.Empty));
                            objEscritor.WriteEndElement();

                            //Crea el nodo del factor del tipo de cambio 
                            objEscritor.WriteStartElement(_factorTipoCambioCalculo);
                            objEscritor.WriteString(((semestre.FactorTipoCambio.HasValue) ? semestre.FactorTipoCambio.ToString() : string.Empty));
                            objEscritor.WriteEndElement();

                            //Crea el nodo del factor del índice de precios al consumidor 
                            objEscritor.WriteStartElement(_factorIpcCalculo);
                            objEscritor.WriteString(((semestre.FactorIPC.HasValue) ? semestre.FactorIPC.ToString() : string.Empty));
                            objEscritor.WriteEndElement();

                            //Crea el nodo del porcentaje de depreciación semestral
                            objEscritor.WriteStartElement(_porcentajeDepreciacionSemestralCalculo);
                            objEscritor.WriteString(semestre.PorcentajeDepreciacion.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del monto de la tasación actualizada del terreno
                            objEscritor.WriteStartElement(_montoTasacionActualizadaTerrenoCalculo);
                            objEscritor.WriteString(semestre.MontoTasacionActualizadaTerreno.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del monto de la tasación actualizada del no terreno
                            objEscritor.WriteStartElement(_montoTasacionActualizadaNoTerrenoCalculo);
                            objEscritor.WriteString(semestre.MontoTasacionActualizadaNoTerreno.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del consecutivo del registro
                            objEscritor.WriteStartElement(_numeroRegistroCalculo);
                            objEscritor.WriteString(semestre.NumeroSemestre.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del consecutivo de la operación
                            objEscritor.WriteStartElement(_codigoOperacionCalculo);
                            objEscritor.WriteString(codOperacion.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del consecutivo de la garantía
                            objEscritor.WriteStartElement(_codigoGarantiaCalculo);
                            objEscritor.WriteString(codGarantiaReal.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del código del tipo de bien
                            objEscritor.WriteStartElement(_tipoBienCalculo);
                            objEscritor.WriteString(codTipoBien.ToString());
                            objEscritor.WriteEndElement();

                            //Crea el nodo del total de semestres trabajados
                            objEscritor.WriteStartElement(_totalSemestresCalculo);
                            objEscritor.WriteString(semestre.TotalRegistros.ToString());
                            objEscritor.WriteEndElement();

                            #region RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno

                            if (tipoGeneracion == 2)
                            {
                                //Crea el nodo del porcentaje de aceptación parametrizado
                                objEscritor.WriteStartElement(_porcentajeAceptacionBase);
                                objEscritor.WriteString(string.Format("{0:N2}", porcentajeAceptacionCalculadoOriginal));
                                objEscritor.WriteEndElement();

                                //Crea el nodo del porcentaje de aceptación del terreno
                                objEscritor.WriteStartElement(_porcentajeAceptacionTerreno);
                                objEscritor.WriteString(string.Format("{0:N2}", porcentajeAceptacionTerreno));
                                objEscritor.WriteEndElement();

                                //Crea el nodo del porcentaje de aceptación del no terreno
                                objEscritor.WriteStartElement(_porcentajeAceptacionNoTerreno);
                                objEscritor.WriteString(string.Format("{0:N2}", porcentajeAceptacionNoTerreno));
                                objEscritor.WriteEndElement();

                                //Crea el nodo del porcentaje de aceptación del terreno calculado
                                objEscritor.WriteStartElement(_porcentajeAceptacionTerrenoCalculado);
                                objEscritor.WriteString(string.Format("{0:N2}", porcentajeAceptacionTerrenoCalculado));
                                objEscritor.WriteEndElement();

                                //Crea el nodo del porcentaje de aceptación del no terreno calculado
                                objEscritor.WriteStartElement(_porcentajeAceptacionNoTerrenoCalculado);
                                objEscritor.WriteString(string.Format("{0:N2}", porcentajeAceptacionNoTerrenoCalculado));
                                objEscritor.WriteEndElement();
                            }

                            #endregion

                            //Final del tag SEMESTRE
                            objEscritor.WriteEndElement();
                        }
                    }
                    else
                    {
                        objEscritor.WriteStartElement(_tagSemestre);

                        //Final del tag SEMESTRE
                        objEscritor.WriteEndElement();
                    }

                    //Final del tag SEMESTRES_A_CALCULAR
                    objEscritor.WriteEndElement();
                }

                #endregion  Lista de Semestres Calculados

                #region POLIZAS SAP

                if (generarListaPolizasSap)
                {
                    /*
                    
                      <POLIZAS>
                        <POLIZA>
                          <Codigo_SAP>117133</Codigo_SAP>
                          <Tipo_Poliza>14</Tipo_Poliza>
                          <Monto_Poliza>31762882.00</Monto_Poliza>
                          <Moneda_Monto_Poliza>1</Moneda_Monto_Poliza>
                          <Fecha_Vencimiento>2012-10-01T00:00:00</Fecha_Vencimiento>
                          <Cedula_Acreedor>4000000019</Cedula_Acreedor>
                          <Nombre_Acreedor>Banco de Costa Rica</Nombre_Acreedor>
                          <Detalle_Poliza></Detalle_Poliza>
                          <Poliza_Seleccionada>0</Poliza_Seleccionada>
                          <Descripcion_Tipo_Poliza_Sap>INS - Incendio Colectivo BCR (HS2000) Colones</Descripcion_Tipo_Poliza_Sap>
                          <Monto_Poliza_Colonizado>31762882.00</Monto_Poliza_Colonizado>
                        </POLIZA>
                      </POLIZAS>
                     
                    */

                    //Inicializa el nodo que poseer los datos de las pólizas asociadas a la operación que respalda la garantía consultada
                    objEscritor.WriteString(polizasSap.ObtenerTrama());
                }

                #endregion POLIZAS SAP

                //Final del tag DATOS
                objEscritor.WriteEndElement();

                //Final del documento
                objEscritor.WriteEndDocument();

                //Flush
                objEscritor.Flush();

                tramaGenerada = UtilitariosComun.GetStringFromStream(stream).Replace("&lt;", "<").Replace("&gt;", ">"); ;

                //Cierre del xml document
                objEscritor.Close();
            }

            return tramaGenerada;
        }

        /// <summary>
        /// Obtiene la cantidad de años requeridos para calcular la fecha de prescripción, según el tipo de garantía real
        /// </summary>
        /// <param name="tipoGarantiaReal">Código del tipo de garantia real</param>
        /// <returns>Cantidad de años usados para el cálculo de la fecha de prescripción</returns>
        private int ObtenerCantidadAnnosPrescripcion(int tipoGarantiaReal)
        {
            int cantidadAnnos;

            try
            {
                switch (tipoGarantiaReal)
                {
                    case 1: cantidadAnnos = (int.TryParse(ConfigurationManager.AppSettings.Get("ANNOS_FECHA_PRESCRIPCION_HIPOTECA"), out cantidadAnnos) ? cantidadAnnos : 0);
                        break;
                    case 2: cantidadAnnos = (int.TryParse(ConfigurationManager.AppSettings.Get("ANNOS_FECHA_PRESCRIPCION_CEDULA_HIPOTECARIA"), out cantidadAnnos) ? cantidadAnnos : 0);
                        break;
                    case 3: cantidadAnnos = (int.TryParse(ConfigurationManager.AppSettings.Get("ANNOS_FECHA_PRESCRIPCION_PRENDA"), out cantidadAnnos) ? cantidadAnnos : 0);
                        break;
                    default: cantidadAnnos = 0;
                        break;
                }
            }
            catch (Exception ex)
            {
                cantidadAnnos = 0;

                descripcionError = Mensajes.Obtener(Mensajes._errorDatosArchivoConfiguracion, Mensajes.ASSEMBLY);

                UtilitariosComun.RegistraEventLog((Mensajes.Obtener(Mensajes._errorDatosArchivoConfiguracionDetalle,
                    "los años configurados para el cálculo de la fecha de prescripción",
                    ex.Message, Mensajes.ASSEMBLY)), EventLogEntryType.Error);
            }


            return cantidadAnnos;
        }
        
        /// <summary>
        /// Obtiene el código SAP relacionado a la operación y a la garantía
        /// </summary>
        /// <param name="consecutivoOperacion">Consecutivo de la operación</param>
        /// <param name="consecutivoGarantia">Consecutivo de la garantía</param>
        /// <returns>Información de la póliza</returns>
        private clsPolizaSap ObtenerPolizaRelacionada(long consecutivoOperacion, long consecutivoGarantia)
        {
            string[] listaCampos = new string[] { string.Empty };
            string sentenciaSql = string.Empty;
            clsPolizaSap valorRetornado = new clsPolizaSap();
            int codigoSap;
            decimal montoAcreencia;

            try
            {
                listaCampos = new string[] {clsPolizaSap._codigoSap, clsPolizaSap._montoAcreencia,
                                            clsPolizaSap._tagPolizasRelacionadas,
                                            _codOperacion, consecutivoOperacion.ToString(),
                                            _codGarantiaReal, consecutivoGarantia.ToString()};

                sentenciaSql = string.Format("SELECT {0}, {1} FROM dbo.{2} WHERE {3} = {4} AND {5} = {6}", listaCampos);

                SqlParameter[] parameters = new SqlParameter[] { };

               DataSet datosPolizaRelacionada = AccesoBD.ExecuteDataSet(CommandType.Text, sentenciaSql, parameters);

                if ((datosPolizaRelacionada != null) && (datosPolizaRelacionada.Tables.Count > 0) && (datosPolizaRelacionada.Tables[0].Rows.Count > 0))
                {
                    valorRetornado.CodigoPolizaSap = (((!datosPolizaRelacionada.Tables[0].Rows[0].IsNull(clsPolizaSap._codigoSap)) && (int.TryParse(datosPolizaRelacionada.Tables[0].Rows[0][clsPolizaSap._codigoSap].ToString(), out codigoSap))) ? codigoSap : -1);
                    valorRetornado.MontoAcreenciaPolizaSap = (((!datosPolizaRelacionada.Tables[0].Rows[0].IsNull(clsPolizaSap._montoAcreencia)) && (decimal.TryParse(datosPolizaRelacionada.Tables[0].Rows[0][clsPolizaSap._montoAcreencia].ToString(), out montoAcreencia))) ? montoAcreencia : 0);
                }
            }
            catch
            {
                throw;
            }


            return valorRetornado;
        }


        #endregion  Métodos Privados
        
        #endregion Métodos
    }
}
