using System;
using System.Xml;

namespace BCR.GARANTIAS.Entidades
{
    public class clsCapacidadPago
    {
        #region Constantes
        public const string _entidadCapacidadPagoDeudor = "GAR_CAPACIDAD_PAGO";

        private const string _capacidad                = "CAPACIDAD";
        public const string _cedulaDeudor              = "cedula_deudor";
        public const string _fechaCapacidadPago        = "fecha_capacidad_pago";
        public const string _codCapacidadPago          = "cod_capacidad_pago";
        public const string _porSensibilidadTipoCambio = "sensibilidad_tipo_cambio";
        private const string _desCapacidadPago         = "des_capacidad_pago";

 
        #endregion Constantes

        #region Variables

        /// <summary>
        /// Identificación del deudor/codeudor
        /// </summary>
        private string cedulaDeudor;

        /// <summary>
        /// Fecha en la que se registra la capacidad de pago
        /// </summary>
        private DateTime fecCapacidadPago;

        /// <summary>
        /// Código de capacidad de pago
        /// </summary>
        private int codCapacidadPago;

        /// <summary>
        /// Porcentaje de sensibilidad al tipo de cambio
        /// </summary>
        private decimal porSensibilidadTipoCambio;

        /// <summary>
        /// Descripción del código de la capacidad de pago
        /// </summary>
        private string desCapacidadPago;

        #endregion Variables

        #region Propiedades Públicas

        /// <summary>
        /// Obtiene o establece la identificación del deudor/codeudor
        /// </summary>
        public string CedulaDeudor
        {
            get { return cedulaDeudor; }
            set { cedulaDeudor = value; }
        }

        /// <summary>
        /// Obtiene la fecha en la que se registra la capacidad de pago
        /// </summary>
        public DateTime FechaCapacidadPago
        {
            get { return fecCapacidadPago; }
        }

        /// <summary>
        /// Obtiene o establece la capacidad de pago
        /// </summary>
        public int CapacidadPago
        {
            get { return codCapacidadPago; }
        }

        /// <summary>
        /// Obtiene o establece el porcentaje de sensibilidad al tipo de cambio
        /// </summary>
        public decimal SensibilidadTipoCambio
        {
            get { return porSensibilidadTipoCambio; }
        }

        /// <summary>
        /// Obtiene la descripción del código de la capacidad de pago
        /// </summary>
        public string DescripcionCapacidadPago
        {
            get { return desCapacidadPago; }
        }
	
        #endregion Propiedades Públicas

        #region Constructores

        /// <summary>
        /// Constructor básico de la clase
        /// </summary>
        public clsCapacidadPago()
        {
            cedulaDeudor = string.Empty;
            fecCapacidadPago = new DateTime(1900, 01, 01);
            codCapacidadPago = -1;
            porSensibilidadTipoCambio = 0;
            desCapacidadPago = string.Empty;
        }

        /// <summary>
        /// Constructor de la clase que carga los datos que posee la trama recibida
        /// </summary>
        /// <param name="tramaCapacidadPago">Trama que posee los datos de la capacidad de pago</param>
        public clsCapacidadPago(string tramaCapacidadPago)
        {
            cedulaDeudor = string.Empty;
            fecCapacidadPago = new DateTime(1900, 01, 01);
            codCapacidadPago = -1;
            porSensibilidadTipoCambio = 0;
            desCapacidadPago = string.Empty;


            if (tramaCapacidadPago.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();
                DateTime fecCapacidad;
                int dato;
                decimal porValor;


                xmlTrama.LoadXml(tramaCapacidadPago);

                fecCapacidadPago = ((xmlTrama.SelectSingleNode("//" + _fechaCapacidadPago) != null) ? ((DateTime.TryParse((xmlTrama.SelectSingleNode("//" + _fechaCapacidadPago).InnerText), out fecCapacidad)) ? fecCapacidad : new DateTime(1900, 01, 01)) : new DateTime(1900, 01, 01));
                codCapacidadPago = ((xmlTrama.SelectSingleNode("//" + _codCapacidadPago) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codCapacidadPago).InnerText), out dato)) ? dato : -1) : -1);
                porSensibilidadTipoCambio = ((xmlTrama.SelectSingleNode("//" + _porSensibilidadTipoCambio) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _porSensibilidadTipoCambio).InnerText), out porValor)) ? porValor : 0) : 0);
                desCapacidadPago = ((xmlTrama.SelectSingleNode("//" + _desCapacidadPago) != null) ? xmlTrama.SelectSingleNode("//" + _desCapacidadPago).InnerText : string.Empty);
            }

        }
        #endregion Constructores

        #region Métodos Públicos

        #endregion Métodos Públicos
    }
}
