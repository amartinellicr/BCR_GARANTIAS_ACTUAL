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
    public class clsCobertura
    {
        #region Variables

        /// <summary>
        /// Código de la cobertura
        /// </summary>
        private decimal codigoCobertura;

        /// <summary>
        /// Descripción de la cobertura
        /// </summary>
        private string descripcionCobertura;
        
        /// <summary>
        /// Descripción corta de la cobertura
        /// </summary>
        private string descripcionCortaCobertura;

        /// <summary>
        /// Indica si la cobertura es obligatoria o no
        /// </summary>
        private bool indicadorObligatoria;

        /// <summary>
        /// Indicador de que se presentó un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripción del error detectado
        /// </summary>
        private string descripcionError;

        /// <summary>
        /// Tipo de lista a la que pertenece la cobertura
        /// </summary>
        private Enumeradores.Tipos_Trama_Cobertura tipoListaCobertura;

        #endregion Variables

        #region Constantes

        //Tags importantes de la trama
        private const string _tagCoberturas = "COBERTURAS";
        private const string _tagCoberturasPorAsignar = "POR_ASIGNAR";
        private const string _tagCoberturasAsignadas = "ASIGNADAS";
        private const string _tagCobertura = "COBERTURA";


        //Tags de la parte correspondiente a la cobertura
        private const string _codCobertura = "Codigo_Cobertura";
        private const string _descripcionCobertura = "Descripcion_Cobertura";
        private const string _descripcionCortaCobertura = "Descripcion_Corta_Cobertura";
        private const string _indicadorObligatoria = "Indicador_Obligatoria";

        //Tags de control
        private const string _tipoLista = "Tipo_Lista_Cobertura";


        #endregion Constantes

        #region Constructor - Finalizador

        /// <summary>
        /// Constructor básico de la clase
        /// </summary>
        public clsCobertura()
        {
            codigoCobertura = -1;
            descripcionCobertura = string.Empty;
            descripcionCortaCobertura = string.Empty;
            indicadorObligatoria = false;
            tipoListaCobertura = Enumeradores.Tipos_Trama_Cobertura.Ninguna;
        }

        /// <summary>
        /// Constructor de la clase que carga los datos que posee la trama recibida
        /// </summary>
        /// <param name="tramaCobertura">Trama que posee los datos de la cobertura</param>
        /// <param name="tipoTramaCobertura">Código del tipo de trama de la cobertura a ser cargada, siendo: 1: Coberturas por asignar y 2: Coberturas asignadas</param>
        public clsCobertura(string tramaCobertura, Enumeradores.Tipos_Trama_Cobertura tipoTramaCobertura)
        {
            codigoCobertura = -1;
            descripcionCobertura = string.Empty;
            descripcionCortaCobertura = string.Empty;
            indicadorObligatoria = false;
            tipoListaCobertura = tipoTramaCobertura;

            if (tramaCobertura.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();
                string[] formatosFecha = { "yyyyMMdd", "dd/MM/yyyy" };

                string descripcionTipoListaCobertura = "-";


                switch (tipoTramaCobertura)
                {
                    case Enumeradores.Tipos_Trama_Cobertura.Ninguna: descripcionTipoListaCobertura = "-";
                        break;
                    case Enumeradores.Tipos_Trama_Cobertura.PorAsignar: descripcionTipoListaCobertura = "Indicadas por el Asegurador";
                        break;
                    case Enumeradores.Tipos_Trama_Cobertura.Asignada: descripcionTipoListaCobertura = "Respaldada por el Bien";
                        break;
                    default: descripcionTipoListaCobertura = "-";
                        break;
                }

                try
                {
                    xmlTrama.LoadXml(tramaCobertura);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaCoberturaPolizaSap, descripcionTipoListaCobertura, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaCoberturaPolizaSapDetalle, descripcionTipoListaCobertura, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlTrama != null)
                {
                    decimal codCobert;
                    
                    try
                    {

                        codigoCobertura = ((xmlTrama.SelectSingleNode("//" + _codCobertura) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _codCobertura).InnerText), out codCobert)) ? codCobert : -1) : -1);

                        descripcionCobertura = ((xmlTrama.SelectSingleNode("//" + _descripcionCobertura) != null) ? xmlTrama.SelectSingleNode("//" + _descripcionCobertura).InnerText : string.Empty);
                        descripcionCortaCobertura = ((xmlTrama.SelectSingleNode("//" + _descripcionCortaCobertura) != null) ? xmlTrama.SelectSingleNode("//" + _descripcionCortaCobertura).InnerText : string.Empty);

                        indicadorObligatoria = ((xmlTrama.SelectSingleNode("//" + _indicadorObligatoria) != null) ? ((xmlTrama.SelectSingleNode("//" + _indicadorObligatoria).InnerText.CompareTo("0") == 0) ? false : true) : false);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorCargaCoberturaPolizaSap, descripcionTipoListaCobertura, Mensajes.ASSEMBLY);

                        string desError = "El error se da al cargar las coberturas de las pólizas SAP: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaCoberturaPolizaSapDetalle, descripcionTipoListaCobertura, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }
                }

            }

        }

        #endregion  Constructor - Finalizador

        #region Propiedades

        /// <summary>
        /// Expone el código de la cobertura
        /// </summary>
        public decimal CodigoCobertura 
        { 
            get { return codigoCobertura; }
            set { codigoCobertura = value; }
        }

        /// <summary>
        /// Expone la descripción de la cobertura
        /// </summary>
        public string DescripcionCobertura 
        {
            get { return descripcionCobertura; }            
            set { descripcionCobertura = value; }
        }

        /// <summary>
        /// Expone la descripción corta de la cobertura
        /// </summary>
        public string DescripcionCortaCobertura
        {
            get { return descripcionCortaCobertura; }
            set { descripcionCortaCobertura = value; }
        }

        /// <summary>
        /// Expone el indicador de si la cobertura es obligatoria o no
        /// </summary>
        public bool IndicadorObligatoria 
        {
            get { return indicadorObligatoria; }
            set { indicadorObligatoria = value; }
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
        /// Expone el tipo de lista al que pertenece la cobertura
        /// </summary>
        public Enumeradores.Tipos_Trama_Cobertura TipoListaCobertura
        {
            get { return tipoListaCobertura; }
            set { tipoListaCobertura = value; }
        }

        public string DescripcionCompuesta
        {
            get
            {
                return string.Format("{0} - {2}", this.descripcionCortaCobertura, this.descripcionCobertura);
            }
        }


        #endregion Propiedades

        #region Métodos

        #region Métodos Públicos

        /// <summary>
        /// Método que permite generar el contenido de la clase en formato JSON
        /// </summary>
        /// <returns>Cadena de texto en formato JSON</returns>
        public string ConvertirJSON()
        {
            StringBuilder formatoJSON = new StringBuilder("{");

            string tipoLista = "0";

            switch (this.tipoListaCobertura)
            {
                case Enumeradores.Tipos_Trama_Cobertura.PorAsignar: tipoLista = "1";
                    break;
                case Enumeradores.Tipos_Trama_Cobertura.Asignada: tipoLista = "2";
                    break;
                default: tipoLista = "0";
                    break;
            }


            formatoJSON.Append('"');
            formatoJSON.Append(_codCobertura);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(codigoCobertura.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_descripcionCobertura);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(UtilitariosComun.EnquoteJSON(descripcionCobertura));
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_descripcionCortaCobertura);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(UtilitariosComun.EnquoteJSON(descripcionCortaCobertura));
            formatoJSON.Append(",");
            
            formatoJSON.Append('"');
            formatoJSON.Append(_indicadorObligatoria);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((indicadorObligatoria) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_tipoLista);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(tipoLista);
            formatoJSON.Append('"');

            formatoJSON.Append('}');

            return formatoJSON.ToString();
        }

        #endregion Métodos Públicos

        #region  Métodos Privados

        #endregion  Métodos Privados

        #endregion Métodos
    }
}
