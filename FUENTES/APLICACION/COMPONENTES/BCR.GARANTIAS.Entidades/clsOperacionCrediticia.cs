using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;


namespace BCR.GARANTIAS.Entidades
{
    public class clsOperacionCrediticia
    {
        #region Variables

        /// <summary>
        /// Estas variables son usadas para tratar los datos de la operación
        /// </summary>
        private short codigoContabilidad = 1;
        private short codigoOficina = -1;
        private short codigoMoneda = -1;
        private short codigoProducto = -1;
        private long numeroOperacion = -1;
        private short tipoOperacion = -1;
        private Int64 codigoOperacion = -1;
        private Int64 codigoGarantia = -1;
        private decimal montoAcreenciaPoliza = 0;

        #endregion Variables

        #region Constantes

        /// <summary>
        /// Estas constantes representan los tag de la trama obtenida
        /// </summary>
        private const string _contabilidad = "contabilidad";
        private const string _oficina = "oficina";
        private const string _moneda = "moneda";
        private const string _producto = "producto";
        private const string _numeroOperacion = "numeroOperacion";
        private const string _tipoOperacion = "tipoOperacion";
        private const string _codigoOperacion = "codigoOperacion";
        private const string _codigoGarantia = "codigoGarantia";
        private const string _montoAcreenciaPoliza = "Monto_Acreencia_Poliza";

        #endregion Constantes

        #region Constructor - Finalizador

        /// <summary>
        /// Constructor base.
        /// </summary>
        public clsOperacionCrediticia()
        {
            codigoContabilidad = 1;
            codigoOficina = -1;
            codigoMoneda = -1;
            codigoProducto = -1;
            numeroOperacion = -1;
            tipoOperacion = -1;
            codigoOperacion = -1;
            codigoGarantia = -1;
            montoAcreenciaPoliza = 0;
        }

        /// <summary>
        /// Constructor que recibe la trama de la cual debe obtener los datos.
        /// </summary>
        /// <param name="tramaXML"></param>
        public clsOperacionCrediticia(string tramaXML)
        {
            codigoContabilidad = 1;
            codigoOficina = -1;
            codigoMoneda = -1;
            codigoProducto = -1;
            numeroOperacion = -1;
            tipoOperacion = -1;
            codigoOperacion = -1;
            codigoGarantia = -1;
            montoAcreenciaPoliza = 0;

            if (tramaXML.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();
                short contabilidad;
                short oficina;
                short moneda;
                short producto;
                long operacion;
                short tipoOperacionCrediticia;
                Int64 consecutivoOperacion;
                Int64 consecutivoGarantia;
                decimal mtoAcreenciaPoliza;

                xmlTrama.LoadXml(tramaXML);

                numeroOperacion = ((xmlTrama.SelectSingleNode("//" + _numeroOperacion) != null) ? ((long.TryParse((xmlTrama.SelectSingleNode("//" + _numeroOperacion).InnerText), out operacion)) ? operacion : -1) : -1);

                codigoContabilidad = ((xmlTrama.SelectSingleNode("//" + _contabilidad) != null) ? ((short.TryParse((xmlTrama.SelectSingleNode("//" + _contabilidad).InnerText), out contabilidad)) ? contabilidad : ((short)-1)) : ((short)-1));
                codigoOficina = ((xmlTrama.SelectSingleNode("//" + _oficina) != null) ? ((short.TryParse((xmlTrama.SelectSingleNode("//" + _oficina).InnerText), out oficina)) ? oficina : ((short)-1)) : ((short)-1));
                codigoMoneda = ((xmlTrama.SelectSingleNode("//" + _moneda) != null) ? ((short.TryParse((xmlTrama.SelectSingleNode("//" + _moneda).InnerText), out moneda)) ? moneda : ((short)-1)) : ((short)-1));
                codigoProducto = ((xmlTrama.SelectSingleNode("//" + _producto) != null) ? ((short.TryParse((xmlTrama.SelectSingleNode("//" + _producto).InnerText), out producto)) ? producto : ((short)-1)) : ((short)-1));
                tipoOperacion = ((xmlTrama.SelectSingleNode("//" + _tipoOperacion) != null) ? ((short.TryParse((xmlTrama.SelectSingleNode("//" + _tipoOperacion).InnerText), out tipoOperacionCrediticia)) ? tipoOperacionCrediticia : ((short)-1)) : ((short)-1));
                codigoOperacion = ((xmlTrama.SelectSingleNode("//" + _codigoOperacion) != null) ? ((Int64.TryParse((xmlTrama.SelectSingleNode("//" + _codigoOperacion).InnerText), out consecutivoOperacion)) ? consecutivoOperacion : -1) : -1);
                codigoGarantia = ((xmlTrama.SelectSingleNode("//" + _codigoGarantia) != null) ? ((Int64.TryParse((xmlTrama.SelectSingleNode("//" + _codigoGarantia).InnerText), out consecutivoGarantia)) ? consecutivoGarantia : -1) : -1);

                montoAcreenciaPoliza = ((xmlTrama.SelectSingleNode("//" + _montoAcreenciaPoliza) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _montoAcreenciaPoliza).InnerText), out mtoAcreenciaPoliza)) ? mtoAcreenciaPoliza : 0) : 0);

            }
        }

        #endregion Constructor - Finalizador

        #region Propiedades


        /// <summary>
        /// Contabilidad de la operación.
        /// </summary>
        public short Contabilidad
        {
            get { return codigoContabilidad; }
            set { codigoContabilidad = value; }
        }

        /// <summary>
        /// Oficina de la operación.
        /// </summary>
        public short Oficina
        {
            get { return codigoOficina; }
            set { codigoOficina = value; }
        }

        /// <summary>
        /// Moneda de la operación.
        /// </summary>
        public short Moneda
        {
            get { return codigoMoneda; }
            set { codigoMoneda = value; }
        }

        /// <summary>
        /// Producto de la operación.
        /// </summary>
        public short Producto
        {
            get { return codigoProducto; }
            set { codigoProducto = value; }
        }

        /// <summary>
        /// Número de la operación.
        /// </summary>
        public long Operacion
        {
            get { return numeroOperacion; }
            set { numeroOperacion = value; }
        }

        /// <summary>
        /// Tipo de operación, siendo 1 = Directa, 2 = Contrato y 3 = Giro de contrato.
        /// </summary>
        public short TipoOperacion
        {
            get { return tipoOperacion; }
            set { tipoOperacion = value; }
        }

        /// <summary>
        /// Obtiene o establece el consecutivo del registro de la operación/contrato a nivel de la base de datos.
        /// </summary>
        public Int64 CodigoOperacion
        {
            get { return codigoOperacion; }
            set { codigoOperacion = value; }
        }

        /// <summary>
        /// Obtiene o establece el consecutivo del registro de la garantía a nivel de la base de datos.
        /// </summary>
        public Int64 CodigoGarantia
        {
            get { return codigoGarantia; }
            set { codigoGarantia = value; }
        }

        /// <summary>
        /// Obtiene o establece el consecutivo del registro de la garantía a nivel de la base de datos.
        /// </summary>
        public decimal MontoAcreenciaPoliza
        {
            get { return montoAcreenciaPoliza; }
        }


        #endregion Propiedades

        #region Métodos

        /// <summary>
        /// Obtiene el dato de la operación/contrato en formato Contabilidad - Oficina - Moneda - Producto (sólo si es directa) - Operación/Contrato
        /// </summary>
        /// <param name="paraMensaje">Indica si la operación será para mostrarla al usuario o no</param>
        /// <returns>La operación en formato Contabilidad - Oficina - Moneda - Producto (sólo si es directa) - Operación/Contrato</returns>
        public string ToString(bool paraMensaje)
        {
            StringBuilder cadenaRetornada = new StringBuilder();

            if (this.TipoOperacion == 1)
            {
                if (paraMensaje)
                {
                    cadenaRetornada.Append("<br />");
                }

                cadenaRetornada.Append(this.Contabilidad.ToString());
                cadenaRetornada.Append(" - ");
                cadenaRetornada.Append(this.Oficina.ToString());
                cadenaRetornada.Append(" - ");
                cadenaRetornada.Append(this.Moneda.ToString());
                cadenaRetornada.Append(" - ");
                cadenaRetornada.Append(this.Producto.ToString());
                cadenaRetornada.Append(" - ");
                cadenaRetornada.Append(this.Operacion.ToString());

                if (paraMensaje)
                {
                    cadenaRetornada.Append(".");
                }
            }
            else if (this.TipoOperacion == 2)
            {
                if (paraMensaje)
                {
                    cadenaRetornada.Append("<br />");
                }
                
                cadenaRetornada.Append(this.Contabilidad.ToString());
                cadenaRetornada.Append(" - ");
                cadenaRetornada.Append(this.Oficina.ToString());
                cadenaRetornada.Append(" - ");
                cadenaRetornada.Append(this.Moneda.ToString());
                cadenaRetornada.Append(" - ");
                cadenaRetornada.Append(this.Operacion.ToString());

                if (paraMensaje)
                {
                    cadenaRetornada.Append(".");
                }
            }

            return cadenaRetornada.ToString();
        }


        #endregion Métodos
    }
}
