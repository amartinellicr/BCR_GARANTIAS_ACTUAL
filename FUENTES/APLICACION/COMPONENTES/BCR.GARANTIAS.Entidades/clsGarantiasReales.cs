using System;
using System.Collections;
using System.Xml;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsGarantiasReales<T> : CollectionBase
        where T : clsGarantiaReal
    {
        #region Trama Esperada
           /*
            <DATOS>
              <PARA_CALCULAR>
                <OPERACION>
                  <Cod_Operacion>151290</Cod_Operacion>
                  <Contabilidad>1</Contabilidad>
                  <Oficina>245</Oficina>
                  <Moneda>1</Moneda>
                  <Producto>2</Producto>
                  <Operacion>5910713</Operacion>
                </OPERACION>
                <GARANTIA>
                  <Cod_Garantia_Real>203972</Cod_Garantia_Real>
                  <Tipo_Garantia_Real>1</Tipo_Garantia_Real>
                  <Codigo_Bien>1-278434</Codigo_Bien>
                  <Codigo_Partido>1</Codigo_Partido>
                  <Numero_Finca>278434</Numero_Finca>
                  <Numero_Placa_Bien></Numero_Placa_Bien>
                  <AVALUO_MAS_RECIENTE>
                    <fecha_valuacion>2011-11-28T00:00:00</fecha_valuacion>
                    <monto_ultima_tasacion_terreno>762639600.0000</monto_ultima_tasacion_terreno>
                    <monto_ultima_tasacion_no_terreno>563068054.3500</monto_ultima_tasacion_no_terreno>
                    <monto_tasacion_actualizada_terreno>766199145.0700</monto_tasacion_actualizada_terreno>
                    <monto_tasacion_actualizada_no_terreno>548852516.9900</monto_tasacion_actualizada_no_terreno>
                    <monto_total_avaluo>1325707654.3500</monto_total_avaluo>
                    <penultima_fecha_valuacion>2007-11-15T00:00:00</penultima_fecha_valuacion>
                    <fecha_actual>2013-06-18T14:57:52.240</fecha_actual>
                  </AVALUO_MAS_RECIENTE>
                  <AVALUO_SICC>
                    <prmgt_pfeavaing>2011-11-28T00:00:00</prmgt_pfeavaing>
                    <prmgt_pmoavaing>1325707654.35</prmgt_pmoavaing>
                  </AVALUO_SICC>
                </GARANTIA>
              </PARA_CALCULAR>
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
            </DATOS>
            */
        #endregion Trama Esperada

        #region Constantes

        //Tags importantes de la trama
        private const string _tagDatos = "DATOS";
        private const string _tagOperacion = "OPERACION";
        private const string _tagGarantia = "GARANTIA";
        private const string _tagParaCalcular = "PARA_CALCULAR";
        private const string _tagAvaluoReciente = "AVALUO_MAS_RECIENTE";
        private const string _tagAvaluoSICC = "AVALUO_SICC";
        private const string _tagParametrosCalculo = "PARAM_CALCULO";
        private const string _tagAvaluo = "AVALUO";
        private const string _tagBitacora = "BITACORA";

        //Tags de la parte correspondiente a la operación
        private const string _codOperacion = "Cod_Operacion";
        private const string _codContabilidad = "Contabilidad";
        private const string _codOficinaOper = "Oficina";
        private const string _codMonedaOper = "Moneda";
        private const string _codProducto = "Producto";
        public const string _numOperacion = "Operacion";

        //Tags de la parte correspondiente a la garantía
        private const string _codGarantiaReal = "Cod_Garantia_Real";
        public const string _codTipoGarantiaReal = "Tipo_Garantia_Real";
        private const string _garantiaReal = "Codigo_Bien";
        public const string _codPartido = "Codigo_Partido";
        public const string _numeroFinca = "Numero_Finca";
        public const string _numPlacaBien = "Numero_Placa_Bien";

        //Tags referentes a la parte del avalúo más reciente
        private const string _fechaValuacion = "fecha_valuacion";
        private const string _montoUltimaTasacionTerreno = "monto_ultima_tasacion_terreno";
        private const string _montoUltimaTasacionNoTerreno = "monto_ultima_tasacion_no_terreno";
        private const string _montoTasacionActualizadaTerreno = "monto_tasacion_actualizada_terreno";
        private const string _montoTasacionActualizadaNoTerreno = "monto_tasacion_actualizada_no_terreno";
        private const string _montoTotalAvaluo = "monto_total_avaluo";
        private const string _fechaPenultimoAvaluo = "penultima_fecha_valuacion";
        private const string _fechaActualBD = "fecha_actual";

        //Tags referentes a la parte del avalúo del SICC
        private const string _prmgtFechaValuacion = "prmgt_pfeavaing";
        private const string _prmgtMontoTotalAvaluo = "prmgt_pmoavaing";

        //Nombre de las tablas de BD
        private const string _tablaGrarantiasReales = "GAR_GARANTIA_REAL";
        private const string _tablaGarOper = "GAR_GARANTIAS_REALES_X_OPERACION";
        private const string _tablaValuacionesReales = "GAR_VALUACIONES_REALES";

        //Tags referentes a los parámetros usados para el cálculo del monto de la tasación actualizada del no terreno
        private const string _porcentajeLimiteInferior = "porcentaje_limite_inferior";
        private const string _porcentajeLimiteIntermedio = "porcentaje_limite_intermedio";
        private const string _porcentajeLimiteSuperior = "porcentaje_limite_superior";
        private const string _annosLimiteInferior = "annos_limite_inferior";
        private const string _annosLimiteIntermedio = "annos_limite_intermedio";
        private const string _annosLimiteSuperior = "annos_limite_superior";
        private const string _mesesPorAnno = "meses_por_anno";
        private const string _diasPorMes = "dias_por_mes";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaGarantias;

        /// <summary>
        /// Indicador de que se presentó un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripción del error detectado
        /// </summary>
        private string descripcionError;

        #endregion Variables

        #region Propiedades

        /// <summary>
        /// Obtiene o establece la trama de respuesta obtenida de la consulta realizada a la Base de Datos
        /// </summary>
        public string TramaGarantias
        {
            get { return tramaGarantias; }
            set { tramaGarantias = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la indicación de que se presentó un error por problema de datos
        /// </summary>
        public bool ErrorDatos
        {
            get { return errorDatos; }
            set { errorDatos = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del error
        /// </summary>
        public string DescripcionError
        {
            get { return descripcionError; }
            set { descripcionError = value; }
        }

        #endregion Propiedades

        #region Construtores

        /// <summary>
        /// Constructor base del a clase
        /// </summary>
        public clsGarantiasReales()
        {
            tramaGarantias = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaGarantias">Trama que posee los datos de las garantías obtenidas de la Base de Datos</param>
        public clsGarantiasReales(string tramaListaGarantias, bool esServicioWindows)
        {
            tramaGarantias = string.Empty;

            if (tramaListaGarantias.Length > 0)
            {
                XmlDocument xmlGarantias = new XmlDocument();

                try
                {
                    xmlGarantias.LoadXml(tramaListaGarantias);
                }
                catch (Exception ex)
                {
                    errorDatos = true;

                    if (esServicioWindows)
                    {
                        string desError = "Error al cargar la trama de la lista de garantías: " + ex.Message;
                        descripcionError = Mensajes.Obtener(Mensajes._errorCargaGarantiasDetalle, desError, Mensajes.ASSEMBLY);
                    }
                    else
                    {
                        descripcionError = Mensajes.Obtener(Mensajes._errorCargaGarantias, Mensajes.ASSEMBLY);

                        string desError = "Error al cargar la trama: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaGarantiasDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    }

                    return;
                }

                if (xmlGarantias != null)
                {
                    tramaGarantias = tramaListaGarantias;

                    if (xmlGarantias.HasChildNodes)
                    {
                        clsGarantiaReal entidadGarantiaReal;

                        if (xmlGarantias.SelectSingleNode("//" + _tagParametrosCalculo) != null)
                        {
                            XmlNode xmlParametrosCalculo = xmlGarantias.SelectSingleNode("//" + _tagParametrosCalculo);

                            foreach (XmlNode nodoGarantia in xmlGarantias.SelectNodes("//" + _tagParaCalcular).Item(0).ChildNodes)
                            {
                                nodoGarantia.AppendChild(xmlParametrosCalculo);

                                entidadGarantiaReal = new clsGarantiaReal(nodoGarantia.OuterXml,"--");

                                if (entidadGarantiaReal.ErrorDatos)
                                {
                                    errorDatos = entidadGarantiaReal.ErrorDatos;
                                    descripcionError = entidadGarantiaReal.DescripcionError;
                                    break;
                                }
                                else
                                {
                                    Agregar(entidadGarantiaReal);
                                }
                            }
                        }
                    }
                }
            }
        }
        #endregion Constructores

        #region Métodos Públicos

        /// <summary>
        /// Agrega una entidad del tipo garantía real a la colección
        /// </summary>
        /// <param name="garantiaReal">Entidad del tipo Garantía Real que se agregará a la colección</param>
        public void Agregar(clsGarantiaReal garantiaReal)
        {
            InnerList.Add(garantiaReal);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo garantía real de la colección
        /// </summary>
        /// <param name="indece">Posición de la entidad dentro de la colección</param>
        public void Remover(int indece)
        {
            InnerList.RemoveAt(indece);
        }

        /// <summary>
        /// Obtiene una entidad del tipo garantía real específica
        /// </summary>
        /// <param name="indece">Posición, dentro de la colección, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo garantía real</returns>
        public clsGarantiaReal Item(int indece)
        {
            return (clsGarantiaReal)InnerList[indece];
        }

        /// <summary>
        /// Método que obtiene la trama que será enviada a la base de datos para actualizar el monto de la tasación 
        /// actualizada del no terreno calculado
        /// </summary>
        /// <returns>Trama con la información a ser actualizada</returns>
        public string ObtenerXml(string idUsuario, string dirIP)
        {
            XmlDocument xmlTramaAvaluos = null;
            XmlDocument docAvaluo = null;

            if (InnerList.Count > 0)
            {
                foreach (clsGarantiaReal avaluoGarantiaReal in InnerList)
                {
                    if (xmlTramaAvaluos == null)
                    {
                        xmlTramaAvaluos.LoadXml(avaluoGarantiaReal.ObtenerTramaAvaluosModificados(idUsuario, dirIP));
                    }
                    else
                    {
                        docAvaluo.LoadXml(avaluoGarantiaReal.ObtenerTramaAvaluosModificados(idUsuario, dirIP));

                        if((docAvaluo != null) && (docAvaluo.OuterXml.Length > 0))
                        {
                            XmlNode xmlAvaluo = null;
                            XmlNode xmlBitacora = null;

                            if ((docAvaluo.SelectSingleNode("//" + _tagAvaluo) != null) 
                               && (docAvaluo.SelectSingleNode("//" + _tagBitacora) != null))
                            {
                                xmlAvaluo = docAvaluo.SelectSingleNode("//" + _tagAvaluo);
                                xmlBitacora = docAvaluo.SelectSingleNode("//" + _tagBitacora);

                                if ((xmlAvaluo != null) && (xmlBitacora != null))
                                {
                                    xmlTramaAvaluos.AppendChild(xmlAvaluo);
                                    xmlTramaAvaluos.AppendChild(xmlBitacora);
                                }
                            }
                           
                        }
                    }
                }
            }

            return (((xmlTramaAvaluos != null) && (xmlTramaAvaluos.OuterXml.Length > 0)) ? xmlTramaAvaluos.OuterXml : string.Empty);
        }

        /// <summary>
        /// Permite convertir la entidad en un dataset
        /// </summary>
        /// <returns>DataSet que posee la información de la entidad</returns>
        //public DataSet toDataSet()
        //{
        //    //Se inicializan la variables locales
        //    DataSet dsValuacionesReales = new DataSet();
        //    DataTable dtValuacionesReales = new DataTable("Avaluos");


        //    #region Agregar columnas a la tabla

        //    DataColumn dcColumna = new DataColumn(_codGarantiaReal, typeof(long));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_fechaValuacion, typeof(DateTime));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_cedulaEmpresa, typeof(string));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_cedulaPerito, typeof(string));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_montoUltimaTasacionTerreno, typeof(decimal));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_montoUltimaTasacionNoTerreno, typeof(decimal));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_montoTasacionActualizadaTerreno, typeof(decimal));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_montoTasacionActualizadaNoTerreno, typeof(decimal));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_fechaUltimoSeguimiento, typeof(DateTime));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_montoTotalAvaluo, typeof(decimal));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_codRecomendacionPerito, typeof(Int16));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_codInspeccionMenorTresMeses, typeof(Int16));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_fechaConstruccion, typeof(DateTime));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_nombreClientePerito, typeof(string));
        //    dtValuacionesReales.Columns.Add(dcColumna);

        //    dcColumna = new DataColumn(_nombreClienteEmpresa, typeof(string));
        //    dtValuacionesReales.Columns.Add(dcColumna);


        //    dtValuacionesReales.AcceptChanges();

        //    #endregion Agregar columnas a la tabla

        //    //Se verifica que existan registros
        //    if (InnerList.Count > 0)
        //    {
        //        #region Agregar filas y datos a la tabla

        //        DataRow drFila = dtValuacionesReales.NewRow();

        //        foreach (clsValuacionReal avaluoReal in this.InnerList)
        //        {
        //            drFila[_codGarantiaReal] = avaluoReal.CodGarantiaReal;
        //            drFila[_fechaValuacion] = avaluoReal.FechaValuacion;
        //            drFila[_cedulaEmpresa] = avaluoReal.CedulaEmpresa;
        //            drFila[_cedulaPerito] = avaluoReal.CedulaPerito;
        //            drFila[_montoUltimaTasacionTerreno] = avaluoReal.MontoUltimaTasacionTerreno;
        //            drFila[_montoUltimaTasacionNoTerreno] = avaluoReal.MontoUltimaTasacionNoTerreno;
        //            drFila[_montoTasacionActualizadaTerreno] = avaluoReal.MontoTasacionActualizadaTerreno;
        //            drFila[_montoTasacionActualizadaNoTerreno] = avaluoReal.MontoTasacionActualizadaNoTerreno;
        //            drFila[_fechaUltimoSeguimiento] = avaluoReal.FechaUltimoSeguimiento;
        //            drFila[_montoTotalAvaluo] = avaluoReal.MontoTotalAvaluo;
        //            drFila[_codRecomendacionPerito] = avaluoReal.CodigoRecomendacionPerito;
        //            drFila[_codInspeccionMenorTresMeses] = avaluoReal.CodigoInspeccionMenorTresMeses;
        //            drFila[_fechaConstruccion] = avaluoReal.FechaConstruccion;
        //            drFila[_nombreClientePerito] = avaluoReal.DescripcionNombreClientePerito;
        //            drFila[_nombreClienteEmpresa] = avaluoReal.DescripcionNombreClienteEmpresa;

        //            dtValuacionesReales.Rows.Add(drFila);
        //            drFila = dtValuacionesReales.NewRow();
        //        }

        //        #endregion Agregar filas y datos a la tabla

        //        dtValuacionesReales.AcceptChanges();

        //        dtValuacionesReales.DefaultView.Sort = _fechaValuacion + " desc";
        //    }

        //    dsValuacionesReales.Tables.Add(dtValuacionesReales);
        //    dsValuacionesReales.AcceptChanges();

        //    return dsValuacionesReales;
        //}

        ///// <summary>
        ///// Obtiene una entidad del tipo garantía real específica de acuerdo a la fecha de evaluación
        ///// </summary>
        ///// <param name="indece">Fecha de valuación de la entidad que se requiere</param>
        ///// <returns>Una entidad</returns>
        //public clsValuacionReal obtenerItem(DateTime fecha_evaluacion)
        //{
        //    clsValuacionReal item = new clsValuacionReal();

        //    if (InnerList.Count > 0)
        //    {
        //        foreach (clsValuacionReal avaluoReal in this.InnerList)
        //        {
        //            if (avaluoReal.FechaValuacion == fecha_evaluacion)
        //            {
        //                item.CodGarantiaReal = avaluoReal.CodGarantiaReal;
        //                item.FechaValuacion = avaluoReal.FechaValuacion;
        //                item.CedulaEmpresa = avaluoReal.CedulaEmpresa;
        //                item.CedulaPerito = avaluoReal.CedulaPerito;
        //                item.MontoUltimaTasacionTerreno = avaluoReal.MontoUltimaTasacionTerreno;
        //                item.MontoUltimaTasacionNoTerreno = avaluoReal.MontoUltimaTasacionNoTerreno;
        //                item.MontoTasacionActualizadaTerreno = avaluoReal.MontoTasacionActualizadaTerreno;
        //                item.MontoTasacionActualizadaNoTerreno = avaluoReal.MontoTasacionActualizadaNoTerreno;
        //                item.FechaUltimoSeguimiento = avaluoReal.FechaUltimoSeguimiento;
        //                item.MontoTotalAvaluo = avaluoReal.MontoTotalAvaluo;
        //                item.CodigoRecomendacionPerito = avaluoReal.CodigoRecomendacionPerito;
        //                item.CodigoInspeccionMenorTresMeses = avaluoReal.CodigoInspeccionMenorTresMeses;
        //                item.FechaConstruccion = avaluoReal.FechaConstruccion;
        //                item.DescripcionNombreClientePerito = avaluoReal.DescripcionNombreClientePerito;
        //                item.DescripcionNombreClienteEmpresa = avaluoReal.DescripcionNombreClienteEmpresa;
        //            }

        //        }
        //    }

        //    return item;
        //}

        #endregion Métodos Públicos

    }
}
