using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Data.SqlClient;
using System.Data;
using System.IO;
using System.Reflection;
using System.Globalization;

using BCR.GARANTIAS.Comun;
using BCRGARANTIAS.Datos;

namespace BCR.GARANTIAS.Entidades
{
    public class clsPolizaSap
    {
        #region Constantes

        private const string _codigoSap = "Codigo_SAP";
        private const string _tipoPoliza = "Tipo_Poliza";
        private const string _montoPoliza = "Monto_Poliza";
        private const string _monedaMontoPoliza = "Moneda_Monto_Poliza";
        private const string _fechaVencimientoPoliza = "Fecha_Vencimiento";
        private const string _cedulaAcreedorPoliza = "Cedula_Acreedor";
        private const string _nombreAcreedorPoliza = "Nombre_Acreedor";
        private const string _montoAcreencia = "Monto_Acreencia";
        private const string _detallePoliza = "Detalle_Poliza";
        private const string _polizaSeleccionada = "Poliza_Seleccionada";
        private const string _montoPolizaColonizado = "Monto_Poliza_Colonizado";
        private const string _descripcionTipoPolizaSap = "Descripcion_Tipo_Poliza_Sap";
        private const string _codigoSapValido = "Codigo_Sap_Valido";
        private const string _montoPolizaAnterior = "Monto_Poliza_Anterior";
        private const string _fechaVencimientoPolizaAnterior = "Fecha_Vencimiento_Anterior";
        private const string _cedulaAcreedorAnterior = "Cedula_Acreedor_Anterior";
        private const string _nombreAcreedorAnterior = "Nombre_Acreedor_Anterior";
        private const string _tipoBienPoliza = "Tipo_Bien_Poliza";
        private const string _polizaAsociada = "Poliza_Asociada";

        private const string _cedulaBCR = "4000000019";
        private const string _descripcionBCR = "BANCODECOSTARICA";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Almacena el código de la póliza SAP
        /// </summary>
        private int codigoPolizaSap;

        /// <summary>
        /// Almacena el tipo de la póliza SAP
        /// </summary>
        private int tipoPolizaSap;

        /// <summary>
        /// Almacena el monto de la póliza SAP
        /// </summary>
        private decimal montoPolizaSap;

        /// <summary>
        /// Almacena el tipo de moneda del monto de la póliza SAP
        /// </summary>
        private int tipoMonedaPolizaSap;

        /// <summary>
        /// Almacena el la fecha de vencimiento de la póliza SAP
        /// </summary>
        private DateTime fechaVencimientoPolizaSap;
              
        /// <summary>
        /// Almacena la cédula del acreedor de la póliza SAP
        /// </summary>
        private string cedulaAcreedorPolizaSap;

        /// <summary>
        /// Almacena el nombre del acreedor de la póliza SAP
        /// </summary>
        private string nombreAcreedorPolizaSap;

        /// <summary>
        /// Almacena el monto de acreencia de la póliza SAP
        /// </summary>
        private decimal montoAcreenciaPolizaSap;

        /// <summary>
        /// Almacena el detalle de la póliza SAP
        /// </summary>
        private string detallePolizaSap;

        /// <summary>
        /// Almacena el indicador sobresi al póliza es la seleccionada
        /// </summary>
        private bool indicadorPolizaSapSeleccionada;

        /// <summary>
        /// Almacena el monto de la póliza SAP colonizado
        /// </summary>
        private decimal montoPolizaSapColonizado;

        /// <summary>
        /// Almacena el tipo de bien asociado al tipo de póliza SAP
        /// </summary>
        private int tipoBienPoliza;

        /// <summary>
        /// Indicador de que se presentó un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripción del error detectado
        /// </summary>
        private string descripcionError;

        /// <summary>
        /// Descripción del tipo de póliza SAP
        /// </summary>
        private string descripcionTipoPolizaSap;

        /// <summary>
        /// Indicador de si la póliza SAP es válida
        /// </summary>
        private bool codigoSapValido;

        /// <summary>
        /// Monto anterior de la póliza
        /// </summary>
        private decimal montoPolizaAnterior;

        /// <summary>
        /// Fecha de vencimiento anteriror de la póliza
        /// </summary>
        private DateTime fechaVencimientoAnterior;

        /// <summary>
        /// Almacena la identificación anterior del acreedor
        /// </summary>
        private string cedulaAcreedorAnterior;

        /// <summary>
        /// Almacena el nombre anterior del acreedor
        /// </summary>
        private string nombreAcreedorAnterior;

        /// <summary>
        /// Indicador de si la póliza SAP existe dentro de la estructura de las pólizas relacionadas
        /// </summary>
        private bool indicadorPolizaAsocida;

        #endregion Variables

        #region Propiedades Públicas

        /// <summary>
        /// Obtiene y establece el código de la póliza SAP.
        /// </summary>
	    public int CodigoPolizaSap
	    {
		    get { return codigoPolizaSap;}
		    set { codigoPolizaSap = value;}
	    }
    	
        /// <summary>
        /// Obtiene y establece el código del tipo póliza SAP.
        /// </summary>
	    public int TipoPolizaSap
	    {
		    get { return tipoPolizaSap;}
		    set { tipoPolizaSap = value;}
	    }
 
        /// <summary>
        /// Obtiene y establece el monto de la póliza SAP.
        /// </summary>
	    public decimal MontoPolizaSap
	    {
		    get { return montoPolizaSap;}
		    set { montoPolizaSap = value;}
	    }
 
        /// <summary>
        /// Obtiene y establece el código del tipo moneda del monto de la póliza SAP.
        /// </summary>
	    public int TipoMonedaPolizaSap
	    {
		    get { return tipoMonedaPolizaSap;}
		    set { tipoMonedaPolizaSap = value;}
	    }
        
        /// <summary>
        /// Obtiene y establece la fecha de vencimiento de la póliza SAP.
        /// </summary>
	    public DateTime FechaVencimientoPolizaSap
	    {
		    get { return fechaVencimientoPolizaSap;}
		    set { fechaVencimientoPolizaSap = value;}
	    }
        
        /// <summary>
        /// Obtiene y establece la cédula del acreedor de la póliza SAP.
        /// </summary>
	    public string CedulaAcreedorPolizaSap
	    {
		    get { return cedulaAcreedorPolizaSap;}
		    set { cedulaAcreedorPolizaSap = value;}
	    }

        /// <summary>
        /// Obtiene y establece el nombre del acreedor de la póliza SAP.
        /// </summary>
	    public string NombreAcreedorPolizaSap
	    {
		    get { return nombreAcreedorPolizaSap;}
		    set { nombreAcreedorPolizaSap = value;}
	    }

        /// <summary>
        /// Obtiene y establece el monto de la acreencia de la póliza SAP.
        /// </summary>
	    public decimal MontoAcreenciaPolizaSap
	    {
		    get { return montoAcreenciaPolizaSap;}
		    set { montoAcreenciaPolizaSap = value;}
	    }

        /// <summary>
        /// Obtiene y establece el detalle de la póliza SAP.
        /// </summary>
	    public string DetallePolizaSap
	    {
            get { return detallePolizaSap; }
            set { detallePolizaSap = value; }
	    }

        /// <summary>
        /// Obtiene y establece el indicador de la póliza SAP seleccionada.
        /// </summary>
	    public bool PolizaSapSeleccionada
	    {
		    get { return indicadorPolizaSapSeleccionada;}
		    set { indicadorPolizaSapSeleccionada = value;}
	    }

        /// <summary>
        /// Obtiene y establece el monto de la póliza SAP colonizado.
        /// </summary>
	    public decimal MontoPolizaSapColonizado
	    {
		    get { return montoPolizaSapColonizado;}
		    set { montoPolizaSapColonizado = value;}
	    }

        /// <summary>
        /// Obtiene el tipo de bien de la póliza.
        /// </summary>
        public int TipoBienPoliza
        {
            get { return tipoBienPoliza; }
        }
	

        /// <summary>
        /// Obtiene la descripción del tipo de la póliza SAP.
        /// </summary>
	    public string DecripcionTipoPolizaSap
	    {
		    get { return descripcionTipoPolizaSap;}
        }

        /// <summary>
        /// Obtiene el indicador de si la póliza SAP está vigente.
        /// </summary>
	    public bool IndicadorPolizaSapVigente
	    {
		    get 
            { 
                return ((fechaVencimientoPolizaSap.Ticks >= DateTime.Today.Ticks) ? true : false);
            }
	    }


        /// <summary>
        /// Obtiene el indicador de si la póliza SAP es válida, estos que la póliza no posea el estado "CAN" en el SAP.
        /// </summary>
        public bool CodigoSapValido
        {
            get { return codigoSapValido; }
        }

        /// <summary>
        /// Obtiene el monto de la póliza anterior
        /// </summary>
        public decimal MontoPolizaAnterior
        {
            get { return montoPolizaAnterior; }
        }

        /// <summary>
        /// Obtiene la fecha de vencimiento anterior de la póliza
        /// </summary>
        public DateTime FechaVencimientoAnterior
        {
            get { return fechaVencimientoAnterior; }
        }

        /// <summary>
        /// Obtiene la identificación anterior del acreedor
        /// </summary>
        public string CedulaAcreedorAnterior
        {
            get { return cedulaAcreedorAnterior; }
        }

        /// <summary>
        /// Obtiene el nombre anterior del acreedor
        /// </summary>
        public string NombreAcreedorAnterior
        {
            get { return nombreAcreedorAnterior; }
        }

        /// <summary>
        /// Obtiene la concatenación entre el código SAP y la descripción del tipo de póliza SAP
        /// </summary>
        public string CodigoDescripcionPolizaSap
        {            

           // get { return ((codigoPolizaSap != -1) ? ((descripcionTipoPolizaSap.Length > 0) ? (codigoPolizaSap.ToString() + " (" + descripcionTipoPolizaSap + ")") : string.Empty): string.Empty); }

            get {
                string  descripcionTipoPolizaSapCompleto =   ((tipoPolizaSap != -1) ? (string.Format("{0} - {1}", tipoPolizaSap, descripcionTipoPolizaSap)) : string.Empty);
           
                return ((codigoPolizaSap != -1) ? ((descripcionTipoPolizaSap.Length > 0) ? (codigoPolizaSap.ToString() + " (" + descripcionTipoPolizaSapCompleto + ")") : string.Empty): string.Empty);  
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
        /// Propiedad que obtiene el código del tipo de póliza SUGEF y el nombre concatenados 
        /// </summary>
        public string NombreCodigoTipoPolizaSap
        {
            get { return ((tipoPolizaSap != -1) ? (string.Format("{0} - {1}", tipoPolizaSap, descripcionTipoPolizaSap)) : string.Empty); }
            
        }

        /// <summary>
        /// Indica si se debe presnetar el mensaje de error correspondiente cuando se ha variado el monto de la póliza y el valor actual es menor al anteriror
        /// </summary>
        public bool MontoPolizaMenor
        {
            get
            {
                return (montoPolizaSap < montoPolizaAnterior);
            }
        }


        /// <summary>
        /// Indica si se debe presnetar el mensaje de error correspondiente cuando se ha variado la fecha de vencimiento de la póliza y el valor actual es menor al anteriror
        /// </summary>
        public bool FechaVencimientoMenor
        {
            get
            {
                return ((fechaVencimientoPolizaSap == DateTime.MinValue) || (fechaVencimientoPolizaSap.Ticks < fechaVencimientoAnterior.Ticks) ? true : false);
            }
        }

        /// <summary>
        /// Indica si la cédula del acreedor cambió
        /// </summary>
        public bool CambioIdAcreedor
        {
            get
            {
                //return (((cedulaAcreedorPolizaSap.Trim().ToLower().CompareTo(_cedulaBCR) == 0) && (cedulaAcreedorPolizaSap.Trim().ToLower().CompareTo(cedulaAcreedorAnterior.Trim().ToLower()) == 0)) ? false : ((cedulaAcreedorAnterior.Length > 0) ? true : false));
                return ((cedulaAcreedorPolizaSap.Trim().ToLower().CompareTo(_cedulaBCR) == 0) ? false : true);
            }
        }

        /// <summary>
        /// Indica si el nombre del acreedor cambió
        /// </summary>
        public bool CambioNombreAcreedor
        {
            get
            {
                //return ((nombreAcreedorPolizaSap.Trim().Replace(" ", "").ToUpper().CompareTo(_descripcionBCR) == 0) && (nombreAcreedorPolizaSap.Trim().ToLower().CompareTo(nombreAcreedorAnterior.Trim().ToLower()) == 0) ? false : ((nombreAcreedorAnterior.Length > 0) ? true : false));
                return ((nombreAcreedorPolizaSap.Trim().Replace(" ", "").ToUpper().CompareTo(_descripcionBCR) == 0)  ? false : true);
            }
        }

        /// <summary>
        /// Obtiene el indicador que determina si la póliza existe dentro de la estructura de pólizas relacionadas, para esta garantía.
        /// </summary>
        public bool PolizaAsociada
        {
            get { return indicadorPolizaAsocida; }
            set { indicadorPolizaAsocida = value; }
        }

        #endregion Propiedades Públicas

        #region Constructores

        /// <summary>
        /// Constructor básico de la clase
        /// </summary>
        public clsPolizaSap()
        {
            codigoPolizaSap = -1;
            tipoPolizaSap = -1;
            montoPolizaSap = 0;
            tipoMonedaPolizaSap = -1;
            fechaVencimientoPolizaSap = DateTime.MinValue;
            cedulaAcreedorPolizaSap = string.Empty;
            nombreAcreedorPolizaSap = string.Empty;
            montoAcreenciaPolizaSap = 0;
            DetallePolizaSap = string.Empty;
            indicadorPolizaSapSeleccionada = false;
            montoPolizaSapColonizado = 0;
            errorDatos = false;
            descripcionError = string.Empty;
            descripcionTipoPolizaSap = string.Empty;
            codigoSapValido = false;
            montoPolizaAnterior = 0;
            fechaVencimientoAnterior = DateTime.MinValue;
            tipoBienPoliza = -1;
            indicadorPolizaAsocida = false;
        }

        /// <summary>
        /// Constructor de la clase que carga los datos que posee la trama recibida
        /// </summary>
        /// <param name="tramaTipoPolizaSap">Trama que posee los datos sobre los tipos de pólizas SUGEF</param>
        public clsPolizaSap(string tramaTipoPolizaSap)
        {
            codigoPolizaSap = -1;
            tipoPolizaSap = -1;
            montoPolizaSap = 0;
            tipoMonedaPolizaSap = -1;
            fechaVencimientoPolizaSap = DateTime.MinValue;
            cedulaAcreedorPolizaSap = string.Empty;
            nombreAcreedorPolizaSap = string.Empty;
            montoAcreenciaPolizaSap = 0;
            DetallePolizaSap = string.Empty;
            indicadorPolizaSapSeleccionada = false;
            montoPolizaSapColonizado = 0;
            errorDatos = false;
            descripcionError = string.Empty;
            descripcionTipoPolizaSap = string.Empty;
            codigoSapValido = false;
            montoPolizaAnterior = 0;
            fechaVencimientoAnterior = DateTime.MinValue;
            tipoBienPoliza = -1;
            indicadorPolizaAsocida = false;

            if (tramaTipoPolizaSap.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();
                string[] formatosFecha = { "yyyyMMdd", "dd/MM/yyyy" };
                
                try
                {
                    xmlTrama.LoadXml(tramaTipoPolizaSap);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaPolizaSap, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaPolizaSapDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlTrama != null)
                {
                    int codPolSap;
                    int tipoPolSap;
                    int tipoMndPoliza;
                    int tipoBienPol;
                    decimal mntPolSap;
                    decimal mntPolSapAnt;
                    decimal mntAcreencia;
                    decimal mntPolSapColonizado;
                    DateTime fecVencimiento;
                    DateTime fecVencimientoAnt;

                    try
                    {
                        codigoPolizaSap = ((xmlTrama.SelectSingleNode("//" + _codigoSap) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codigoSap).InnerText), out codPolSap)) ? codPolSap : -1) : -1);
                        tipoPolizaSap = ((xmlTrama.SelectSingleNode("//" + _tipoPoliza) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _tipoPoliza).InnerText), out tipoPolSap)) ? tipoPolSap : -1) : -1);
                        tipoMonedaPolizaSap = ((xmlTrama.SelectSingleNode("//" + _monedaMontoPoliza) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _monedaMontoPoliza).InnerText), out tipoMndPoliza)) ? tipoMndPoliza : -1) : -1);
                        tipoBienPoliza = ((xmlTrama.SelectSingleNode("//" + _tipoBienPoliza) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _tipoBienPoliza).InnerText), out tipoBienPol)) ? tipoBienPol : -1) : -1);

                        fechaVencimientoPolizaSap = ((xmlTrama.SelectSingleNode("//" + _fechaVencimientoPoliza) != null) ? ((DateTime.TryParseExact((xmlTrama.SelectSingleNode("//" + _fechaVencimientoPoliza).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecVencimiento)) ? ((fecVencimiento != (new DateTime(1900, 01, 01))) ? fecVencimiento : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);
                        fechaVencimientoAnterior = ((xmlTrama.SelectSingleNode("//" + _fechaVencimientoPolizaAnterior) != null) ? ((DateTime.TryParseExact((xmlTrama.SelectSingleNode("//" + _fechaVencimientoPolizaAnterior).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecVencimientoAnt)) ? ((fecVencimientoAnt != (new DateTime(1900, 01, 01))) ? fecVencimientoAnt : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);

                        montoPolizaSap = ((xmlTrama.SelectSingleNode("//" + _montoPoliza) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _montoPoliza).InnerText), out mntPolSap)) ? mntPolSap : 0) : 0);
                        montoAcreenciaPolizaSap = ((xmlTrama.SelectSingleNode("//" + _montoAcreencia) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _montoAcreencia).InnerText), out mntAcreencia)) ? mntAcreencia : 0) : 0);
                        montoPolizaSapColonizado = ((xmlTrama.SelectSingleNode("//" + _montoPolizaColonizado) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _montoPolizaColonizado).InnerText), out mntPolSapColonizado)) ? mntPolSapColonizado : 0) : 0);
                        montoPolizaAnterior = ((xmlTrama.SelectSingleNode("//" + _montoPolizaAnterior) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _montoPolizaAnterior).InnerText), out mntPolSapAnt)) ? mntPolSapAnt : 0) : 0);

                        cedulaAcreedorPolizaSap = ((xmlTrama.SelectSingleNode("//" + _cedulaAcreedorPoliza) != null) ? xmlTrama.SelectSingleNode("//" + _cedulaAcreedorPoliza).InnerText : string.Empty);
                        nombreAcreedorPolizaSap = ((xmlTrama.SelectSingleNode("//" + _nombreAcreedorPoliza) != null) ? xmlTrama.SelectSingleNode("//" + _nombreAcreedorPoliza).InnerText : string.Empty);
                        detallePolizaSap = ((xmlTrama.SelectSingleNode("//" + _detallePoliza) != null) ? xmlTrama.SelectSingleNode("//" + _detallePoliza).InnerText.Trim() : string.Empty);
                        descripcionTipoPolizaSap = ((xmlTrama.SelectSingleNode("//" + _descripcionTipoPolizaSap) != null) ? xmlTrama.SelectSingleNode("//" + _descripcionTipoPolizaSap).InnerText : string.Empty);
                        cedulaAcreedorAnterior = ((xmlTrama.SelectSingleNode("//" + _cedulaAcreedorAnterior) != null) ? xmlTrama.SelectSingleNode("//" + _cedulaAcreedorAnterior).InnerText : string.Empty);
                        nombreAcreedorAnterior = ((xmlTrama.SelectSingleNode("//" + _nombreAcreedorAnterior) != null) ? xmlTrama.SelectSingleNode("//" + _nombreAcreedorAnterior).InnerText : string.Empty);

                        indicadorPolizaSapSeleccionada = ((xmlTrama.SelectSingleNode("//" + _polizaSeleccionada) != null) ? ((xmlTrama.SelectSingleNode("//" + _polizaSeleccionada).InnerText.CompareTo("0") == 0) ? false : true) : false);
                        codigoSapValido = ((xmlTrama.SelectSingleNode("//" + _codigoSapValido) != null) ? ((xmlTrama.SelectSingleNode("//" + _codigoSapValido).InnerText.CompareTo("0") == 0) ? false : true) : false);
                        indicadorPolizaAsocida = ((xmlTrama.SelectSingleNode("//" + _polizaAsociada) != null) ? ((xmlTrama.SelectSingleNode("//" + _polizaAsociada).InnerText.CompareTo("0") == 0) ? false : true) : false);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorCargaPolizaSap, Mensajes.ASSEMBLY);

                        string desError = "El error se da al cargar los datos de las pólizas SAP: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaPolizaSapDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }
                }

            }

        }

        #endregion Constructores

        #region Métodos Públicos

        /// <summary>
        /// Método que permite generar el contenido de la clase en formato JSON
        /// </summary>
        /// <returns>Cadena de texto en formato JSON</returns>
        public string ConvertirJSON()
        {
            StringBuilder formatoJSON = new StringBuilder("{");

            formatoJSON.Append('"');
            formatoJSON.Append(_codigoSap);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(codigoPolizaSap.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_montoPoliza);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(montoPolizaSap.ToString("N2"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_monedaMontoPoliza);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(tipoMonedaPolizaSap.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_fechaVencimientoPoliza);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((fechaVencimientoPolizaSap == DateTime.MinValue) ? string.Empty : fechaVencimientoPolizaSap.ToShortDateString()));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_cedulaAcreedorPoliza);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(cedulaAcreedorPolizaSap);
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_nombreAcreedorPoliza);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(nombreAcreedorPolizaSap);
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_montoAcreencia);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(montoAcreenciaPolizaSap.ToString("N2"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_detallePoliza);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            //formatoJSON.Append('"');
            formatoJSON.Append(UtilitariosComun.EnquoteJSON(detallePolizaSap));
            //formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_polizaSeleccionada);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((PolizaSapSeleccionada) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_montoPolizaColonizado);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(montoPolizaSapColonizado.ToString("N2"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append("Poliza_Vigente");
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(((IndicadorPolizaSapVigente) ? "1" : "0"));
            formatoJSON.Append(",");
            
            formatoJSON.Append('"');
            formatoJSON.Append(_descripcionTipoPolizaSap);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(descripcionTipoPolizaSap);
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_codigoSapValido);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((codigoSapValido) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append("Monto_Poliza_Menor");
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((MontoPolizaMenor) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append("Fecha_Vencimiento_Menor");
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((FechaVencimientoMenor) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append("Codigo_Descripcion_Poliza_Sap");
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(CodigoDescripcionPolizaSap);
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_tipoBienPoliza);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(tipoBienPoliza.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_polizaAsociada);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((indicadorPolizaAsocida) ? "1" : "0"));
            formatoJSON.Append('"');

            formatoJSON.Append('}');

            return formatoJSON.ToString();
        }

        #endregion Métodos Públicos

        #region Métodos Privados

        #endregion Métodos Privados
    }
}