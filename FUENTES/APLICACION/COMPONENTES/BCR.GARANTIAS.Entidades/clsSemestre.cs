using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Collections.Specialized;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsSemestre
    {
        #region Variables
        /// <summary>
        /// Consecutivo del semestre generado
        /// </summary>
        private int numeroSemestre;

        /// <summary>
        /// Fecha del semestre a ser calculado
        /// </summary>
        private DateTime fechaSemestre;

        /// <summary>
        /// Tipo de cambio de compra del dólar, según BCCR, que aplica para el día del semestre
        /// </summary>
        private decimal? tipoCambio;

        /// <summary>
        /// Indice de Precios al Consumidor, según BCCR, que aplica para el mes del semestre
        /// </summary>
        private decimal? indicePreciosConsumidor;

        /// <summary>
        /// Tipo de cambio de compra del dólar del semestre anterior, según BCCR
        /// </summary>
        private decimal? tipoCambioAnterior;

        /// <summary>
        /// Indice de Precios al Consumidor del semestre anterior, según BCCR
        /// </summary>
        private decimal? ipcAnterior;

        /// <summary>
        /// Total de semestres generados
        /// </summary>
        private int totalRegistros;

        /// <summary>
        /// Porcentaje de depreciación que aplica para el semestre
        /// </summary>
        private decimal porcentajeDepreciacion;

        /// <summary>
        /// Monto de la última tasación del terreno del avalúo más reciente
        /// </summary>
        private decimal montoUltimaTasacionTerreno;

        /// <summary>
        /// Monto de la última tasación del no terreno del avalúo más reciente
        /// </summary>
        private decimal montoUltimaTasacionNoTerreno;

        /// <summary>
        /// Monto de la tasación actualizada del terreno que será calculado
        /// </summary>
        private decimal? montoTasacionActualizadaTerreno;

        /// <summary>
        /// Monto de la tasación actualizada del no terreno que será calculado
        /// </summary>
        private decimal? montoTasacionActualizadaNoTerreno;

        /// <summary>
        /// Factor del tipo de cambio que aplicaría para el cálculo
        /// </summary>
        private decimal? factorTipoCambio;

        /// <summary>
        /// Factor del IPC que aplicaría para el cálculo
        /// </summary>
        private decimal? factorIPC;

        /// <summary>
        /// Indicador de que se presentó un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripción del error detectado
        /// </summary>
        private string descripcionError;

        /// <summary>
        /// Operación crediticia a la que está ligada la garantía cuyo avalúo será actualizado. 
        /// Esto bajo el formato Oficina-Moneda-Producto-Número_Operacion/Contrato
        /// </summary>
        private string operacionCrediticia;

        /// <summary>
        /// Identificación de la garantía a la que se le actualizará el avalúo.
        /// Esto bajo el formato: Partido/Clase_Bien-Numero_Finca/Numero_Placa
        /// </summary>
        private string identificacionGarantia;

        /// <summary>
        /// Fecha y hora en que se aplicó el cálculo al semestre
        /// </summary>
        private DateTime fechaHoraCalculo;

        #endregion Variables

        #region Constantes

        private const string _tagSemestresACalcular = "SEMESTRES_A_CALCULAR";
        private const string _tagSemestre = "SEMESTRE";

        //Tags refernetes a los semestres a evaluar
        private const string _numeroSemestre = "Numero_Semestre";
        private const string _fechaSemestre = "Fecha_Semestre";
        private const string _tipoCambio = "Tipo_Cambio";
        private const string _ipc = "IPC";
        private const string _tipoCambioAnterior = "Tipo_Cambio_Anterior";
        private const string _ipcAnterior = "IPC_Anterior";
        private const string _totalRegistros = "Total_Registros";

        //Constantes para la conversión o lectura del formato JSON, se adiciona a las anteriores
        private const string _porcentajeDepreciacion = "Porcentaje_Depreciacion";
        private const string _montoUltimaTasacionTerreno = "Monto_Ultima_Tasacion_Terreno";
        private const string _montoUltimaTasacionNoTerreno = "Monto_Ultima_Tasacion_No_Terreno";
        private const string _montoTasacionActualizadaTerreno = "Monto_Tasacion_Actualizada_Terreno";
        private const string _montoTasacionActualizadaNoTerreno = "Monto_Tasacion_Actualizada_No_Terreno";
        private const string _operacionCrediticia = "Operacion_Crediticia";
        private const string _identificacionGarantia = "Identificacion_Garantia";
        private const string _fechaHoraCalculoSemestre = "Fecha_Hora_Calculo_Semestre";

        
        #endregion Constantes

        #region Propiedades

        /// <summary>
        /// Obtiene el consecutivo generado para el semestre
        /// </summary>
        public int NumeroSemestre
        {
            get { return numeroSemestre; }
        }

        /// <summary>
        /// Obtiene la fecha del semestre calculado
        /// </summary>
        public DateTime FechaSemestre
        {
            get { return fechaSemestre; }
        }

        /// <summary>
        /// Obtiene el tipo de cambio usado para el cálculo
        /// </summary>
        public decimal? TipoCambio
        {
            get { return tipoCambio; }
        }

        /// <summary>
        /// Obtiene el IPC usado para el cálculo
        /// </summary>
        public decimal? IPC
        {
            get { return indicePreciosConsumidor; }
        }

        /// <summary>
        /// Obtiene el tipo de cambio anterior usado para el cálculo
        /// </summary>
        public decimal? TipoCambioAnterior
        {
            get { return tipoCambioAnterior; }
            set { tipoCambioAnterior = value; }
        }

        /// <summary>
        /// Obtiene el IPC anterior usado para el cálculo
        /// </summary>
        public decimal? IPCAnterior
        {
            get { return ipcAnterior; }
        }

        /// <summary>
        /// Obtiene la cantidad total de semestres generados
        /// </summary>
        public int TotalRegistros
        {
            get { return totalRegistros; }
        }

        /// <summary>
        /// Obtiene y establece el porcentaje de depreciación usado para el cálculo
        /// </summary>
        public decimal PorcentajeDepreciacion
        {
            get { return porcentajeDepreciacion; }
            set { porcentajeDepreciacion = value; }
        }

        /// <summary>
        /// Obtiene y establece el monto de la última tasación del terereno, correpondiente al avalúo más reciente
        /// </summary>
        public decimal MontoUltimaTasacionTerreno
        {
            get { return montoUltimaTasacionTerreno; }
            set { montoUltimaTasacionTerreno = value; }
        }

        /// <summary>
        /// Obtiene y establece el monto de la última tasación del no terereno, correpondiente al avalúo más reciente
        /// </summary>
        public decimal MontoUltimaTasacionNoTerreno
        {
            get { return montoUltimaTasacionNoTerreno; }
            set { montoUltimaTasacionNoTerreno = value; }
        }

        /// <summary>
        /// Obtiene y establece el monto de la tasación actualizada del terereno, que será calculado para el semestre
        /// </summary>
        public decimal? MontoTasacionActualizadaTerreno
        {
            get { return montoTasacionActualizadaTerreno; }
            set { montoTasacionActualizadaTerreno = value; }
        }

        /// <summary>
        /// Obtiene y establece el monto de la tasación actualizada del no terereno, que será calculado para el semestre
        /// </summary>
        public decimal? MontoTasacionActualizadaNoTerreno
        {
            get { return montoTasacionActualizadaNoTerreno; }
            set { montoTasacionActualizadaNoTerreno = value; }
        }

        /// <summary>
        /// Obtiene el factor del tipo de cambio que se podría usar para el cálculo
        /// </summary>
        public decimal? FactorTipoCambio
        {
            get
            {
                if ((tipoCambio.HasValue) && (tipoCambioAnterior.HasValue))
                {
                    decimal tipCambio = Convert.ToDecimal(tipoCambio);
                    decimal tipCambioAnt = Convert.ToDecimal(tipoCambioAnterior);

                    if ((tipCambio > 0) && (tipCambioAnt > 0))
                    {
                        factorTipoCambio = Convert.ToDecimal((tipCambio / tipCambioAnt) - 1);
                    }
                    else
                    {
                        factorTipoCambio = null;
                    }
                }
                else
                {
                    factorTipoCambio = null;
                }

                return factorTipoCambio;
            }
        }

        /// <summary>
        /// Obtiene el factor del IPC que se podría usar para el cálculo
        /// </summary>
        public decimal? FactorIPC
        {
            get
            {
                if ((indicePreciosConsumidor.HasValue) && (ipcAnterior.HasValue))
                {
                    decimal indPC = Convert.ToDecimal(indicePreciosConsumidor);
                    decimal indPCAnt = Convert.ToDecimal(ipcAnterior);

                    if ((indPC > 0) && (indPCAnt > 0))
                    {
                        factorIPC = Convert.ToDecimal((indPC / indPCAnt) - 1);
                    }
                    else
                    {
                        factorIPC = null;
                    }
                }
                else
                {
                    factorIPC = null;
                }

                return factorIPC;
            }
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

        /// <summary>
        /// Obtiene o establece la operación crediticia a la que está ligada la garantía cuyo avalúo será actualizado. 
        /// Esto bajo el formato Oficina-Moneda-Producto-Número_Operacion/Contrato
        /// </summary>
        public string OperacionCrediticia
        {
            get { return operacionCrediticia; }
            set { operacionCrediticia = value; }
        }

        /// <summary>
        /// Obtiene o establece la identificación de la garantía a la que se le actualizará el avalúo.
        /// Esto bajo el formato: Partido/Clase_Bien-Numero_Finca/Numero_Placa
        /// </summary>
        public string IdentificacionGarantia
        {
            get { return identificacionGarantia; }
            set { identificacionGarantia = value; }
        }

        /// <summary>
        /// Obtiene la fecha y hora en que fue calculado el semestre
        /// </summary>
       public DateTime FechaHoraCalculo
        {
            get { return fechaHoraCalculo; }
        }
	

        #endregion Propiedades

        #region Constructores

        public clsSemestre()
        {
            numeroSemestre = 0;
            fechaSemestre = new DateTime(1900, 01, 01);
            tipoCambio = null;
            indicePreciosConsumidor = null;
            tipoCambioAnterior = null;
            ipcAnterior = null;
            totalRegistros = 0;
            porcentajeDepreciacion = 0;
            montoUltimaTasacionTerreno = 0;
            montoUltimaTasacionNoTerreno = 0;
            montoTasacionActualizadaTerreno = null;
            montoTasacionActualizadaNoTerreno = null;
            factorTipoCambio = null;
            factorIPC = null;
            errorDatos = false;
            descripcionError = string.Empty;
            operacionCrediticia = string.Empty;
            identificacionGarantia = string.Empty;
            fechaHoraCalculo = DateTime.Now;
        }

        public clsSemestre(string tramaSemestre, bool formatoJSON)
        {
            numeroSemestre = 0;
            fechaSemestre = new DateTime(1900, 01, 01);
            tipoCambio = null;
            indicePreciosConsumidor = null;
            tipoCambioAnterior = null;
            ipcAnterior = null;
            totalRegistros = 0;
            porcentajeDepreciacion = 0;
            montoUltimaTasacionTerreno = 0;
            montoUltimaTasacionNoTerreno = 0;
            montoTasacionActualizadaTerreno = null;
            montoTasacionActualizadaNoTerreno = null;
            factorTipoCambio = null;
            factorIPC = null;
            errorDatos = false;
            descripcionError = string.Empty;
            operacionCrediticia = string.Empty;
            identificacionGarantia = string.Empty;
            fechaHoraCalculo = DateTime.Now;

            int numSemestre;
            int registrosTotales;
            DateTime fechora;
            DateTime fecHoraCalc;
            decimal tipoCambioCompra;
            decimal ipc;
            decimal tipoCambioCompraAnterior;
            decimal ipcAnt;
            decimal porDepreciacion;
            decimal montoUTT;
            decimal montoUTNT;
            decimal montoTAT;
            decimal montoTANT;
            
            if (tramaSemestre.Length > 0)
            {
                //Se verifica si la cadena viene en formato XML o JSON
                if (!formatoJSON)
                {
                    XmlDocument xmlTrama = new XmlDocument();

                    try
                    {
                        xmlTrama.LoadXml(tramaSemestre);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorCargaSemestreActAvaluos, Mensajes.ASSEMBLY);

                        string desError = "Error al cargar la trama: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaSemestreActAvaluosDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }

                    if (xmlTrama != null)
                    {
                        try
                        {
                            numeroSemestre = ((xmlTrama.SelectSingleNode("//" + _numeroSemestre) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _numeroSemestre).InnerText), out numSemestre)) ? numSemestre : 0) : 0);
                            totalRegistros = ((xmlTrama.SelectSingleNode("//" + _totalRegistros) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _totalRegistros).InnerText), out registrosTotales)) ? registrosTotales : 0) : 0);

                            fechaSemestre = ((xmlTrama.SelectSingleNode("//" + _fechaSemestre) != null) ? ((DateTime.TryParse((xmlTrama.SelectSingleNode("//" + _fechaSemestre).InnerText), out fechora)) ? fechora : new DateTime(1900, 01, 01)) : new DateTime(1900, 01, 01));

                            tipoCambio = ((xmlTrama.SelectSingleNode("//" + _tipoCambio) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _tipoCambio).InnerText), out tipoCambioCompra)) ? tipoCambioCompra : (decimal?)null) : null);
                            indicePreciosConsumidor = ((xmlTrama.SelectSingleNode("//" + _ipc) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _ipc).InnerText), out ipc)) ? ipc : (decimal?)null) : null);
                            tipoCambioAnterior = ((xmlTrama.SelectSingleNode("//" + _tipoCambioAnterior) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _tipoCambioAnterior).InnerText), out tipoCambioCompraAnterior)) ? tipoCambioCompraAnterior : (decimal?)null) : null);
                            ipcAnterior = ((xmlTrama.SelectSingleNode("//" + _ipcAnterior) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _ipcAnterior).InnerText), out ipcAnt)) ? ipcAnt : (decimal?)null) : null);
                        }
                        catch (Exception ex)
                        {
                            errorDatos = true;
                            descripcionError = Mensajes.Obtener(Mensajes._errorCargaSemestreActAvaluos, Mensajes.ASSEMBLY);

                            string desError = "El error se da al cargar los datos del semestre: " + ex.Message;
                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaSemestreActAvaluosDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                            return;
                        }
                    }
                }
                else
                {
                    //Se elimina el caracter inicial y final de la cadena
                    string cadenaJSON = tramaSemestre.Replace("{", string.Empty).Replace("}", string.Empty);

                    //Se revisa que tras la eliminación anterior la cadena aún posea caracteres
                    if (cadenaJSON.Length > 0)
                    {
                        //Se genera el arereglo con cada uno de los pares llave-valor
                        string[] datosFormatoJSON = cadenaJSON.Split(",".ToCharArray());

                        //Se revisa que el arreglo tenga pares
                        if (datosFormatoJSON.Length > 0)
                        {
                            //Se recorre el arrelo generado
                            foreach (string datoJSON in datosFormatoJSON)
                            {
                                //Se genera un nuevo arreglo, esta vez con el valor de la llave y del valor del par evaluado
                                string[] llaveValor = datoJSON.Split(":".ToCharArray());

                                //Se verifica que se haya obtenido el arereglo deseado
                                if (llaveValor.Length == 2)
                                {
                                    //En base al valor de la llave, se convierte y se asigna el dato del valor
                                    switch ((llaveValor[0].Replace('"', ' ').Trim()))
                                    {
                                        case _numeroSemestre: this.numeroSemestre = ((int.TryParse(llaveValor[1], out numSemestre)) ? numSemestre : 0);
                                            break;
                                        case _fechaSemestre: this.fechaSemestre = ((DateTime.TryParse(llaveValor[1], out fechora)) ? fechora : new DateTime(1900, 01, 01));
                                            break;
                                        case _tipoCambio: this.tipoCambio = (((llaveValor[1].CompareTo("null") != 0) && (decimal.TryParse(llaveValor[1], out tipoCambioCompra)) ? tipoCambioCompra : (decimal?)null));
                                            break;
                                        case _ipc: this.indicePreciosConsumidor = (((llaveValor[1].CompareTo("null") != 0) && (decimal.TryParse(llaveValor[1], out ipc)) ? ipc : (decimal?)null));
                                            break;
                                        case _tipoCambioAnterior: this.tipoCambioAnterior = (((llaveValor[1].CompareTo("null") != 0) && (decimal.TryParse(llaveValor[1], out tipoCambioCompraAnterior)) ? tipoCambioCompraAnterior : (decimal?)null));
                                            break;
                                        case _ipcAnterior: this.ipcAnterior = (((llaveValor[1].CompareTo("null") != 0) && (decimal.TryParse(llaveValor[1], out ipcAnt)) ? ipcAnt : (decimal?)null));
                                            break;
                                        case _totalRegistros: this.totalRegistros = ((int.TryParse(llaveValor[1], out registrosTotales)) ? registrosTotales : 0);
                                            break;
                                        case _porcentajeDepreciacion: this.porcentajeDepreciacion = ((decimal.TryParse(llaveValor[1], out porDepreciacion)) ? porDepreciacion : 0);
                                            break;
                                        case _montoUltimaTasacionTerreno: this.montoUltimaTasacionTerreno = ((decimal.TryParse(llaveValor[1], out montoUTT)) ? montoUTT : 0);
                                            break;
                                        case _montoUltimaTasacionNoTerreno: this.montoUltimaTasacionNoTerreno = ((decimal.TryParse(llaveValor[1], out montoUTNT)) ? montoUTNT : 0);
                                            break;
                                        case _montoTasacionActualizadaTerreno: this.montoTasacionActualizadaTerreno = (((llaveValor[1].CompareTo("null") != 0) && (decimal.TryParse(llaveValor[1], out montoTAT)) ? montoTAT : (decimal?)null));
                                            break;
                                        case _montoTasacionActualizadaNoTerreno: this.montoTasacionActualizadaNoTerreno = (((llaveValor[1].CompareTo("null") != 0) && (decimal.TryParse(llaveValor[1], out montoTANT)) ? montoTANT : (decimal?)null));
                                            break;
                                        case _operacionCrediticia: this.operacionCrediticia = llaveValor[1];
                                            break;
                                        case _identificacionGarantia: this.identificacionGarantia = llaveValor[1];
                                            break;
                                        case _fechaHoraCalculoSemestre: this.fechaHoraCalculo = ((DateTime.TryParse(llaveValor[1], out fecHoraCalc)) ? fecHoraCalc : DateTime.Now);
                                            break;
                                        default:
                                            break;
                                    }
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
        /// Permite calcular el monto de la tasación actualizada del terreno y no terreno, para el semestre 
        /// </summary>
        /// <param name="montoTasacionActTerrenoAnterior">Monto de la última tasación del terreno.</param>
        /// <param name="montoTasacionActNoTerrenoAnterior">Monto de la última tasación del no terreno.</param>
        /// <param name="calcularMTAT">Indica si se debe aplicar el cálculo del monto de la tasación actualizada del terreno (true) o no (false).</param>
        /// <param name="calcularMTANT">Indica si se debe aplicar el cálculo del monto de la tasación actualizada del no terreno (true) o no (false).</param>
        public void Aplicar_Calculo_Semestre(decimal montoTasacionActTerrenoAnterior, decimal montoTasacionActNoTerrenoAnterior, bool calcularMTAT, bool calcularMTANT)
        {
            #region Cálculo del Monto de la Tasación Actualizada del Terreno

            //Se asigna el valor por defecto
            montoTasacionActualizadaTerreno = null;

            fechaHoraCalculo = DateTime.Now;

            if (calcularMTAT)
            {
                //Se asigna nulo si es el único semestre a calcular y aún no se ha ingresado el monto de la última tasación del terreno
                if ((numeroSemestre == 1) && (totalRegistros == 1) && (montoUltimaTasacionTerreno == 0))
                {
                    montoTasacionActualizadaTerreno = null;
                }
                //Se asigna el mismo monto de la última tasación del terreno, esto para el primer semestre
                else if ((numeroSemestre == 1) && (totalRegistros >= 1) && (montoUltimaTasacionTerreno > 0))
                {
                    montoTasacionActualizadaTerreno = montoUltimaTasacionTerreno;
                }
                //Se calcula el semestre en caso de que sea más de uno y los parámetros sean válidos
                else if ((numeroSemestre > 1) && (totalRegistros > 1))
                {
                    //Se verifica si los datos básicos para la realización del cálculo han sido suministrados u obtenidos
                    if ((montoTasacionActTerrenoAnterior > 0) && (tipoCambio != null) && (indicePreciosConsumidor != null)
                        && (tipoCambioAnterior != null) && (ipcAnterior != null) && (FactorTipoCambio != null) && (FactorIPC != null)
                        && (FactorTipoCambio.HasValue) && (FactorIPC.HasValue))
                    {
                        decimal facTC = Convert.ToDecimal(FactorTipoCambio);
                        decimal factIPC = Convert.ToDecimal(FactorIPC);
                        decimal minimoFactor = ((facTC <= factIPC) ? facTC : factIPC);

                        montoTasacionActualizadaTerreno = Convert.ToDecimal((montoTasacionActTerrenoAnterior * (1 + minimoFactor)));
                    }
                    else //en caso de que alguno de los parámetros usados para el cálculo no sea válido
                    {
                        errorDatos = true;

                        StringBuilder sbDetalleError = new StringBuilder("Alguno de los parámetros usados para el cálculo, del monto de la tasación actualziada del terreno, no es válido. Valores de los parámetros:");
                        sbDetalleError.AppendLine("Monto Utima Tasación Terreno: ");
                        sbDetalleError.Append(montoUltimaTasacionTerreno.ToString("N2"));
                        sbDetalleError.AppendLine("Monto Tasación Actualizada Terreno Anterior: ");
                        sbDetalleError.Append(montoTasacionActTerrenoAnterior.ToString("N2"));
                        sbDetalleError.AppendLine("Tipo de Cambio: ");
                        sbDetalleError.Append((tipoCambio.HasValue ? tipoCambio.ToString() : "-"));
                        sbDetalleError.AppendLine("IPC: ");
                        sbDetalleError.Append((indicePreciosConsumidor.HasValue ? indicePreciosConsumidor.ToString() : "-"));
                        sbDetalleError.AppendLine("Tipo de Cambio Anterior: ");
                        sbDetalleError.Append((tipoCambioAnterior.HasValue ? tipoCambioAnterior.ToString() : "-"));
                        sbDetalleError.AppendLine("IPC Anterior: ");
                        sbDetalleError.Append((ipcAnterior.HasValue ? ipcAnterior.ToString() : "-"));

                        StringCollection datosError = new StringCollection();
                        datosError.Add(identificacionGarantia);
                        datosError.Add(operacionCrediticia);
                        datosError.Add(sbDetalleError.ToString());

                        descripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Mensajes.ASSEMBLY);
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, datosError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    }
                }
            }

            #endregion Cálculo del Monto de la Tasación Actualizada del Terreno

            #region Cálculo del Monto de la Tasación Actualizada del No Terreno

            //Se asigna el valor por defecto
            montoTasacionActualizadaNoTerreno = null;

            if (calcularMTANT)
            {
                //Se asigna nulo si es el único semestre a calcular y aún no se ha ingresado el monto de la última tasación del no terreno
                if ((numeroSemestre == 1) && (totalRegistros == 1) && (montoUltimaTasacionNoTerreno == 0))
                {
                    montoTasacionActualizadaNoTerreno = null;
                }
                //Se asigna el mismo monto de la última tasación del no terreno, esto para el primer semestre
                else if ((numeroSemestre == 1) && (totalRegistros >= 1) && (montoUltimaTasacionNoTerreno > 0))
                {
                    montoTasacionActualizadaNoTerreno = montoUltimaTasacionNoTerreno;
                }
                //Se calcula el semestre en caso de que sea más de uno y los parámetros sean válidos
                else if ((numeroSemestre > 1) && (totalRegistros > 1))
                {
                    //Se verifica si los datos básicos para la realización del cálculo han sido suministrados u obtenidos
                    if ((montoTasacionActNoTerrenoAnterior > 0) && (tipoCambio != null) && (indicePreciosConsumidor != null)
                        && (tipoCambioAnterior != null) && (ipcAnterior != null) && (FactorTipoCambio != null) && (FactorIPC != null)
                        && (FactorTipoCambio.HasValue) && (FactorIPC.HasValue) && (porcentajeDepreciacion > 0))
                    {
                        decimal facTC = Convert.ToDecimal(FactorTipoCambio);
                        decimal factIPC = Convert.ToDecimal(FactorIPC);
                        decimal minimoFactor = ((facTC <= factIPC) ? facTC : factIPC);

                        montoTasacionActualizadaNoTerreno = Convert.ToDecimal((montoTasacionActNoTerrenoAnterior * (1 - porcentajeDepreciacion) * (1 + minimoFactor)));
                    }
                    else //en caso de que alguno de los parámetros usados para el cálculo no sea válido
                    {
                        errorDatos = true;

                        StringBuilder sbDetalleError = new StringBuilder("Alguno de los parámetros usados para el cálculo, del monto de la tasación actualziada del no terreno, no es válido. Valores de los parámetros:");
                        sbDetalleError.AppendLine("Monto Utima Tasación No Terreno: ");
                        sbDetalleError.Append(montoUltimaTasacionNoTerreno.ToString("N2"));
                        sbDetalleError.AppendLine("Monto Tasación Actualizada No Terreno Anterior: ");
                        sbDetalleError.Append(montoTasacionActNoTerrenoAnterior.ToString("N2"));
                        sbDetalleError.AppendLine("Tipo de Cambio: ");
                        sbDetalleError.Append((tipoCambio.HasValue ? tipoCambio.ToString() : "-"));
                        sbDetalleError.AppendLine("IPC: ");
                        sbDetalleError.Append((indicePreciosConsumidor.HasValue ? indicePreciosConsumidor.ToString() : "-"));
                        sbDetalleError.AppendLine("Tipo de Cambio Anterior: ");
                        sbDetalleError.Append((tipoCambioAnterior.HasValue ? tipoCambioAnterior.ToString() : "-"));
                        sbDetalleError.AppendLine("IPC Anterior: ");
                        sbDetalleError.Append((ipcAnterior.HasValue ? ipcAnterior.ToString() : "-"));
                        sbDetalleError.AppendLine("Porcentaje Depreciacion: ");
                        sbDetalleError.Append(porcentajeDepreciacion.ToString("N2"));

                        StringCollection datosError = new StringCollection();
                        datosError.Add(identificacionGarantia);
                        datosError.Add(operacionCrediticia);
                        datosError.Add(sbDetalleError.ToString());

                        descripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Mensajes.ASSEMBLY);
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, datosError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    }
                }
            }

            #endregion Cálculo del Monto de la Tasación Actualizada del No Terreno
        }

        /// <summary>
        /// Sobreescritura del método toString, para que se retorne el contenido del semestre en formato texto
        /// </summary>
        /// <returns>Cadena en formato texto con el contenido de la clase</returns>
        public override string ToString()
        {
            StringBuilder cadenaRetornada = new StringBuilder("Los datos almacenado son: ");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_numeroSemestre);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(numeroSemestre.ToString());
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_fechaSemestre);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(fechaSemestre.ToShortDateString());
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_tipoCambio);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(((tipoCambio.HasValue) ? tipoCambio.ToString() : "null"));
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_ipc);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(((indicePreciosConsumidor.HasValue) ? indicePreciosConsumidor.ToString() : "null"));
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_tipoCambioAnterior);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(((tipoCambioAnterior.HasValue) ? tipoCambioAnterior.ToString() : "null"));
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_ipcAnterior);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(((ipcAnterior.HasValue) ? ipcAnterior.ToString() : "null"));
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_totalRegistros);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(totalRegistros.ToString());
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_porcentajeDepreciacion);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(porcentajeDepreciacion.ToString());
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_montoUltimaTasacionTerreno);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(montoUltimaTasacionTerreno.ToString());
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_montoUltimaTasacionNoTerreno);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(montoUltimaTasacionNoTerreno.ToString());
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_montoTasacionActualizadaTerreno);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(((montoTasacionActualizadaTerreno.HasValue) ? montoTasacionActualizadaTerreno.ToString() : "null"));
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_montoTasacionActualizadaNoTerreno);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(((montoTasacionActualizadaNoTerreno.HasValue) ? montoTasacionActualizadaNoTerreno.ToString() : "null"));
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_operacionCrediticia);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(operacionCrediticia);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(',');

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_identificacionGarantia);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(identificacionGarantia);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(",");

            cadenaRetornada.Append('"');
            cadenaRetornada.Append(_fechaHoraCalculoSemestre);
            cadenaRetornada.Append('"');
            cadenaRetornada.Append(':');
            cadenaRetornada.Append(fechaHoraCalculo.ToString());

            cadenaRetornada.Append('}');

            return cadenaRetornada.ToString();
        }

        /// <summary>
        /// Método que permite generar el contenido de la clase en formato JSON
        /// </summary>
        /// <returns>Cadena de texto en formato JSON</returns>
        public string ConvertirJSON()
        {
            StringBuilder formatoJSON = new StringBuilder("{");

            formatoJSON.Append('"');
            formatoJSON.Append(_numeroSemestre);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(numeroSemestre.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_fechaSemestre);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(fechaSemestre.ToShortDateString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_tipoCambio);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(((tipoCambio.HasValue) ? tipoCambio.ToString() : "null"));
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_ipc);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(((indicePreciosConsumidor.HasValue) ? indicePreciosConsumidor.ToString() : "null"));
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_tipoCambioAnterior);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(((tipoCambioAnterior.HasValue) ? tipoCambioAnterior.ToString() : "null"));
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_ipcAnterior);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(((ipcAnterior.HasValue) ? ipcAnterior.ToString() : "null"));
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_totalRegistros);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(totalRegistros.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_porcentajeDepreciacion);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(porcentajeDepreciacion.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_montoUltimaTasacionTerreno);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(montoUltimaTasacionTerreno.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_montoUltimaTasacionNoTerreno);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(montoUltimaTasacionNoTerreno.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_montoTasacionActualizadaTerreno);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(((montoTasacionActualizadaTerreno.HasValue) ? ((decimal) montoTasacionActualizadaTerreno).ToString() : "null"));
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_montoTasacionActualizadaNoTerreno);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(((montoTasacionActualizadaNoTerreno.HasValue) ? ((decimal) montoTasacionActualizadaNoTerreno).ToString() : "null"));
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_operacionCrediticia);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(operacionCrediticia);
            formatoJSON.Append('"');
            formatoJSON.Append(',');

            formatoJSON.Append('"');
            formatoJSON.Append(_identificacionGarantia);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(identificacionGarantia);
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_fechaHoraCalculoSemestre);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(fechaHoraCalculo.ToString());

            formatoJSON.Append('}');

            return formatoJSON.ToString();
        }

        #endregion Métodos Públicos

        #region Métodos Privados

        #endregion Métodos Privados
    }
}
