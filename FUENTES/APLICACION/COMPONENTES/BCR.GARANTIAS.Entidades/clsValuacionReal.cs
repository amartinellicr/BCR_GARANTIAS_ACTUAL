using System;
using System.Xml;

namespace BCR.GARANTIAS.Entidades
{
    public class clsValuacionReal
    {
        #region Constantes
        public const string _entidadValuacionesReales          = "GAR_VALUACIONES_REALES";

        public const string _codGarantiaReal                   = "cod_garantia_real";
        public const string _fechaValuacion                    = "fecha_valuacion";
        public const string _cedulaEmpresa                     = "cedula_empresa";
        public const string _cedulaPerito                      = "cedula_perito";
        public const string _montoUltimaTasacionTerreno        = "monto_ultima_tasacion_terreno";
        public const string _montoUltimaTasacionNoTerreno      = "monto_ultima_tasacion_no_terreno";
        public const string _montoTasacionActualizadaTerreno   = "monto_tasacion_actualizada_terreno";
        public const string _montoTasacionActualizadaNoTerreno = "monto_tasacion_actualizada_no_terreno";
        public const string _fechaUltimoSeguimiento            = "fecha_ultimo_seguimiento";
        public const string _montoTotalAvaluo                  = "monto_total_avaluo";
        public const string _codRecomendacionPerito            = "cod_recomendacion_perito";
        public const string _codInspeccionMenorTresMeses       = "cod_inspeccion_menor_tres_meses";
        public const string _fechaConstruccion                 = "fecha_construccion";
        public const string _desRecomendacionPerito            = "des_recomendacion_perito";
        public const string _desInspeccionMenorTresMeses       = "des_inspeccion_menor_tres_meses";
        public const string _nombreClientePerito               = "nombre_cliente_perito";
        public const string _nombreClienteEmpresa              = "nombre_cliente_empresa";
        public const string _indicadorTipoRegistro             = "Indicador_Tipo_Registro";
        public const string _indicadorAvaluoActualizado        = "Indicador_Actualizado_Calculo";
        public const string _fechaSemestreActualizado          = "Fecha_Semestre_Calculado";
        public const string _usuarioModifico                   = "Usuario_Modifico";
        public const string _fechaModifico                     = "Fecha_Modifico";
        public const string _fechaInserto                      = "Fecha_Inserto";
        public const string _fechaReplica                      = "Fecha_Replica";
        public const string _porcentajeAceptacionTerreno       = "Porcentaje_Aceptacion_Terreno";
        public const string _porcentajeAceptacionNoTerreno     = "Porcentaje_Aceptacion_No_Terreno";
        public const string _porcentajeAceptacionTerrenoCalculado   = "Porcentaje_Aceptacion_Terreno_Calculado";
        public const string _porcentajeAceptacionNoTerrenoCalculado = "Porcentaje_Aceptacion_No_Terreno_Calculado";
        
        #endregion Constantes

        #region Variables

        /// <summary>
        /// Consecutivo de la garant�a real
        /// </summary>
        private long codGarantiaReal;

        /// <summary>
        /// Fecha en que se realiza el aval�o
        /// </summary>
        private DateTime fechaValuacion;
    
        /// <summary>
        /// Identificaci�n de la empresa que realiza el aval�o
        /// </summary>
        private string cedulaEmpresa;

        /// <summary>
        /// Identificaci�n del perito que realiza el aval�o
        /// </summary>
        private string cedulaPerito;

        /// <summary>
        /// Monto de la �ltima tasaci�n del terreno
        /// </summary>
        private decimal montoUltimaTasacionTerreno;

        /// <summary>
        /// Monto de la �ltima tasaci�n del no terreno
        /// </summary>
        private decimal montoUltimaTasacionNoTerreno;

        /// <summary>
        /// Monto de la tasaci�n actualizada del terreno
        /// </summary>
        private decimal montoTasacionActualizadaTerreno;

        /// <summary>
        /// Monto de la tasaci�n actualizada del no terreno
        /// </summary>
        private decimal montoTasacionActualizadaNoTerreno;

        /// <summary>
        /// Fecha en que se realiza el �ltimo seguimiento
        /// </summary>
	    private DateTime fechaUltimoSeguimiento;

        /// <summary>
        /// Monto total del aval�o, resultado de la suma de tasaci�n actualizada terreno y tasaci�n actualizada no terreno
        /// </summary>
        private decimal montoTotalAvaluo;

        /// <summary>
        /// Indicador de la recomendaci�n del perito
        /// </summary>
        private Int16 codRecomendacionPerito;

        /// <summary>
        /// Indicador de si la inspecci�n debe realizarse antes de los tres meses cumplidos
        /// </summary>
	    private Int16 codInspeccionMenorTresMeses;

        /// <summary>
        /// Fecha en que se contruy� el bien valuado
        /// </summary>
        private DateTime fechaConstruccion;

        /// <summary>
        /// Descripci�n del c�digo de la recomendaci�n del perito
        /// </summary>
        private string desRecomendacionPerito;

        /// <summary>
        /// Descripci�n del c�digo del indicador de la inspecci�n menor a tres meses
        /// </summary>
        private string desInspeccionMenorTresMeses;

        /// <summary>
        /// Descripci�n del nombre del cliente Perito
        /// </summary>
        private string nombreClientePerito;

        /// <summary>
        /// Descripci�n del nombre del cliente Empresa
        /// </summary>
        private string nombreClienteEmpresa;


        #endregion Variables

        #region Propiedades P�blicas
    
        /// <summary>
        /// Propiedad que obtiene y establece el consecutivo de la garant�a real
        /// </summary>
	    public long CodGarantiaReal
	    {
		    get { return codGarantiaReal;}
		    set { codGarantiaReal = value;}
	    }

        /// <summary>
        /// Propiedad que obtiene y establece la fecha en que se realiza el aval�o
        /// </summary>
	    public DateTime FechaValuacion
	    {
		    get { return fechaValuacion;}
		    set { fechaValuacion = value;}
	    }

        /// <summary>
        /// Propiedad que obtiene y establece la identificaci�n de la empresa que realiza el aval�o
        /// </summary>
	    public string CedulaEmpresa
	    {
		    get { return cedulaEmpresa;}
		    set { cedulaEmpresa = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece la identificaci�n del perito que realiza el aval�o
        /// </summary>
	    public string CedulaPerito
	    {
		    get { return cedulaPerito;}
		    set { cedulaPerito = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece el monto de la �ltima tasaci�n del terreno
        /// </summary>
	    public decimal MontoUltimaTasacionTerreno
	    {
		    get { return montoUltimaTasacionTerreno;}
		    set { montoUltimaTasacionTerreno = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece el monto de la �ltima tasaci�n del no terreno
        /// </summary>
	    public decimal MontoUltimaTasacionNoTerreno
	    {
		    get { return montoUltimaTasacionNoTerreno;}
		    set { montoUltimaTasacionNoTerreno = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece el monto de la tasaci�n actualizada del terreno
        /// </summary>
	    public decimal MontoTasacionActualizadaTerreno
	    {
		    get { return montoTasacionActualizadaTerreno;}
		    set { montoTasacionActualizadaTerreno = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece el monto de la tasaci�n actualizada del no terreno
        /// </summary>
	    public decimal MontoTasacionActualizadaNoTerreno
	    {
		    get { return montoTasacionActualizadaNoTerreno;}
		    set { montoTasacionActualizadaNoTerreno = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece la fecha de �ltimo seguimiento
        /// </summary>
	    public DateTime FechaUltimoSeguimiento
	    {
		    get { return fechaUltimoSeguimiento;}
		    set { fechaUltimoSeguimiento = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece el monto total del aval�o
        /// </summary>
	    public decimal MontoTotalAvaluo
	    {
		    get { return montoTotalAvaluo;}
		    set { montoTotalAvaluo = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece el indicador de la recomendaci�n del perito
        /// </summary>
	    public Int16 CodigoRecomendacionPerito
	    {
		    get { return codRecomendacionPerito;}
		    set { codRecomendacionPerito = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece el indicador que determina si la ispecci�n debe realizarse en menos de tres meses
        /// </summary>
	    public Int16 CodigoInspeccionMenorTresMeses
	    {
		    get { return codInspeccionMenorTresMeses;}
		    set { codInspeccionMenorTresMeses = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece la fecha de construcci�n del bien
        /// </summary>
	    public DateTime FechaConstruccion
	    {
		    get { return fechaConstruccion;}
		    set { fechaConstruccion = value;}
	    }

        /// <summary>
        /// Propiedad que obtiene y establece la descripci�n del c�digo de la recomendaci�n del perito
        /// </summary>
        public string DescripcionRecomendacionPerito
        {
            get { return desRecomendacionPerito; }
            set { desRecomendacionPerito = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripci�n del c�digo del indicador de la inspecci�n menor a tres meses
        /// </summary>
        public string DescripcionInspeccionMenorTresMeses
        {
            get { return desInspeccionMenorTresMeses; }
            set { desInspeccionMenorTresMeses = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripci�n del c�digo del indicador de la inspecci�n menor a tres meses
        /// </summary>
        public string DescripcionNombreClientePerito
        {
            get { return nombreClientePerito; }
            set { nombreClientePerito = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripci�n del c�digo del indicador de la inspecci�n menor a tres meses
        /// </summary>
        public string DescripcionNombreClienteEmpresa
        {
            get { return nombreClienteEmpresa; }
            set { nombreClienteEmpresa = value; }
        }

        #endregion Propiedades P�blicas

        #region Constructores

        /// <summary>
        /// Constructor b�sico de la clase
        /// </summary>
        public clsValuacionReal()
        {
            codGarantiaReal = 0;
            fechaValuacion = new DateTime(1900, 01, 01);
            cedulaEmpresa = string.Empty;
            cedulaPerito = string.Empty;
            montoUltimaTasacionTerreno = 0;
            montoUltimaTasacionNoTerreno = 0;
            montoTasacionActualizadaTerreno = 0;
            montoTasacionActualizadaNoTerreno = 0;
            fechaUltimoSeguimiento = new DateTime(1900, 01, 01);
            montoTotalAvaluo = 0;
            codRecomendacionPerito = 1;
            codInspeccionMenorTresMeses = 1;
            fechaConstruccion = new DateTime(1900, 01, 01);
            desRecomendacionPerito = string.Empty;
            desInspeccionMenorTresMeses = string.Empty;
            nombreClientePerito = string.Empty;
            nombreClienteEmpresa = string.Empty;
        }

        /// <summary>
        /// Constructor de la clase que carga los datos que posee la trama recibida
        /// </summary>
        /// <param name="tramaValuacionReal">Trama que posee los datos del aval�o</param>
        public clsValuacionReal(string tramaValuacionReal)
        {
            /*
             <RESPUESTA>
              <CODIGO>0</CODIGO>
              <PROCEDIMIENTO>pa_Obtener_Valuaciones_Reales</PROCEDIMIENTO>
              <MENSAJE>La obtenci�n de datos fue satisfactoria</MENSAJE>
              <DETALLE>
                <AVALUOS>
                  <AVALUO>
                    <cod_garantia_real>4</cod_garantia_real>
                    <fecha_valuacion>07/05/2009</fecha_valuacion>
                    <cedula_empresa></cedula_empresa>
                    <cedula_perito>104440059</cedula_perito>
                    <monto_ultima_tasacion_terreno>4680000.0000</monto_ultima_tasacion_terreno>
                    <monto_ultima_tasacion_no_terreno>25214400.0000</monto_ultima_tasacion_no_terreno>
                    <monto_tasacion_actualizada_terreno>4680000.0000</monto_tasacion_actualizada_terreno>
                    <monto_tasacion_actualizada_no_terreno>25214400.0000</monto_tasacion_actualizada_no_terreno>
                    <fecha_ultimo_seguimiento>2009/05/07</fecha_ultimo_seguimiento>
                    <monto_total_avaluo>29894400.0000</monto_total_avaluo>
                    <cod_recomendacion_perito>1</cod_recomendacion_perito>
                    <cod_inspeccion_menor_tres_meses>1</cod_inspeccion_menor_tres_meses>
                    <fecha_construccion>1997/01/01</fecha_construccion>
                    <des_recomendacion_perito>Si</des_recomendacion_perito>
                    <des_inspeccion_menor_tres_meses>Si</des_inspeccion_menor_tres_meses>
                  </AVALUO>
                </AVALUOS>
              </DETALLE>
            </RESPUESTA>
             */

            codGarantiaReal = 0;
            fechaValuacion = new DateTime(1900, 01, 01);
            cedulaEmpresa = string.Empty;
            cedulaPerito = string.Empty;
            montoUltimaTasacionTerreno = 0;
            montoUltimaTasacionNoTerreno = 0;
            montoTasacionActualizadaTerreno = 0;
            montoTasacionActualizadaNoTerreno = 0;
            fechaUltimoSeguimiento = new DateTime(1900, 01, 01);
            montoTotalAvaluo = 0;
            codRecomendacionPerito = 1;
            codInspeccionMenorTresMeses = 1;
            fechaConstruccion = new DateTime(1900, 01, 01);
            desRecomendacionPerito = string.Empty;
            desInspeccionMenorTresMeses = string.Empty;
            nombreClientePerito = string.Empty;
            nombreClienteEmpresa = string.Empty;

            if (tramaValuacionReal.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();
                DateTime fecValuacion;
                DateTime fecUS;
                DateTime fecCons;
                long idGarantia;
                decimal montoUTT;
                decimal montoUTNT;
                decimal montoTAT;
                decimal montoTANT;
                decimal montoTA;
                Int16 codRP;
                Int16 codIMT;

                xmlTrama.LoadXml(tramaValuacionReal);

                codGarantiaReal = ((xmlTrama.SelectSingleNode("//" + _codGarantiaReal) != null) ? ((long.TryParse((xmlTrama.SelectSingleNode("//" + _codGarantiaReal).InnerText), out idGarantia)) ? idGarantia : 0) : 0);
                
                fechaValuacion = ((xmlTrama.SelectSingleNode("//" + _fechaValuacion)                    != null) ? ((DateTime.TryParse((xmlTrama.SelectSingleNode("//" + _fechaValuacion).InnerText),           out fecValuacion))  ? fecValuacion  : new DateTime(1900, 01, 01)) : new DateTime(1900, 01, 01));
                fechaConstruccion = ((xmlTrama.SelectSingleNode("//" + _fechaConstruccion)              != null) ? ((DateTime.TryParse((xmlTrama.SelectSingleNode("//" + _fechaConstruccion).InnerText),        out fecCons))       ? fecCons       : new DateTime(1900, 01, 01)) : new DateTime(1900, 01, 01));
                fechaUltimoSeguimiento = ((xmlTrama.SelectSingleNode("//" + _fechaUltimoSeguimiento)    != null) ? ((DateTime.TryParse((xmlTrama.SelectSingleNode("//" + _fechaUltimoSeguimiento).InnerText),   out fecUS))         ? fecUS         : new DateTime(1900, 01, 01)) : new DateTime(1900, 01, 01));
                
                montoUltimaTasacionTerreno = ((xmlTrama.SelectSingleNode("//" + _montoUltimaTasacionTerreno)                != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _montoUltimaTasacionTerreno).InnerText),        out montoUTT))  ? montoUTT  : 0) : 0);
                montoUltimaTasacionNoTerreno = ((xmlTrama.SelectSingleNode("//" + _montoUltimaTasacionNoTerreno)            != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _montoUltimaTasacionNoTerreno).InnerText),      out montoUTNT)) ? montoUTNT : 0) : 0);
                montoTasacionActualizadaTerreno = ((xmlTrama.SelectSingleNode("//" + _montoTasacionActualizadaTerreno)      != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _montoTasacionActualizadaTerreno).InnerText),   out montoTAT))  ? montoTAT  : 0) : 0);
                montoTasacionActualizadaNoTerreno = ((xmlTrama.SelectSingleNode("//" + _montoTasacionActualizadaNoTerreno)  != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _montoTasacionActualizadaNoTerreno).InnerText), out montoTANT)) ? montoTANT : 0) : 0);
                montoTotalAvaluo = ((xmlTrama.SelectSingleNode("//" + _montoTotalAvaluo)                                    != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _montoTotalAvaluo).InnerText),                  out montoTA))   ? montoTA   : 0) : 0);
                
                codRecomendacionPerito = ((xmlTrama.SelectSingleNode("//" + _codRecomendacionPerito)            != null) ? ((Int16.TryParse((xmlTrama.SelectSingleNode("//" + _codRecomendacionPerito).InnerText),      out codRP)) ? codRP     : Convert.ToInt16(-1)) : Convert.ToInt16(-1));
                codInspeccionMenorTresMeses = ((xmlTrama.SelectSingleNode("//" + _codInspeccionMenorTresMeses)  != null) ? ((Int16.TryParse((xmlTrama.SelectSingleNode("//" + _codInspeccionMenorTresMeses).InnerText), out codIMT)) ? codIMT   : Convert.ToInt16(-1)) : Convert.ToInt16(-1));
                
                cedulaEmpresa = ((xmlTrama.SelectSingleNode("//" + _cedulaEmpresa)                              != null) ? xmlTrama.SelectSingleNode("//" + _cedulaEmpresa).InnerText               : string.Empty);
                cedulaPerito = ((xmlTrama.SelectSingleNode("//" + _cedulaPerito)                                != null) ? xmlTrama.SelectSingleNode("//" + _cedulaPerito).InnerText                : string.Empty);
                desRecomendacionPerito = ((xmlTrama.SelectSingleNode("//" + _desRecomendacionPerito)            != null) ? xmlTrama.SelectSingleNode("//" + _desRecomendacionPerito).InnerText      : string.Empty);
                desInspeccionMenorTresMeses = ((xmlTrama.SelectSingleNode("//" + _desInspeccionMenorTresMeses)  != null) ? xmlTrama.SelectSingleNode("//" + _desInspeccionMenorTresMeses).InnerText : string.Empty);
                nombreClientePerito = ((xmlTrama.SelectSingleNode("//" + _nombreClientePerito) != null) ? xmlTrama.SelectSingleNode("//" + _nombreClientePerito).InnerText : string.Empty);
                nombreClienteEmpresa = ((xmlTrama.SelectSingleNode("//" + _nombreClienteEmpresa) != null) ? xmlTrama.SelectSingleNode("//" + _nombreClienteEmpresa).InnerText : string.Empty);
            }

        }

        #endregion Constructores

        #region M�todos P�blicos

        #endregion M�todos P�blicos
    }
}
