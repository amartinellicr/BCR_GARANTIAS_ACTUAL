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

using BCR.GARANTIAS.Comun;
using BCRGARANTIAS.Datos;

namespace BCR.GARANTIAS.Entidades
{
    public class clsIndiceActualizacionAvaluo
    {
        #region Constantes

        public const string _indicesActualizacionAvaluo     = "CAT_INDICES_ACTUALIZACION_AVALUO";
        public const string _fechaHora                      = "Fecha_Hora";
        public const string _tipoCambio                     = "Tipo_Cambio";
        public const string _indicePreciosConsumidor        = "Indice_Precios_Consumidor";
        public const string _Anno                           = "Anno";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Almacena la fecha y hora del registro
        /// </summary>
        private DateTime  fechaHora;

        /// <summary>
        /// Almacena el tipo de cambio
        /// </summary>
 	    private decimal tipoCambio;

        /// <summary>
        /// Almacena el indice de precios al consumidor
        /// </summary>
        private decimal indicePreciosConsumidor;

        /// <summary>
        /// Indicador de que se presentó un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripción del error detectado
        /// </summary>
        private string descripcionError;

        /// <summary>
        /// Se obtiene el año del registro
        /// </summary>
        private int anno;

        #endregion Variables

        #region Propiedades Públicas

        /// <summary>
        /// Obtiene y establece la fecha y hora del registro.
        /// </summary>
	    public DateTime  FechaHora
	    {
		    get { return fechaHora;}
		    set { fechaHora = value;}
	    }
    	
        /// <summary>
        /// Obtiene y establece el tipo de cambio de compra, según el BCCR.
        /// </summary>
	    public decimal TipoCambio
	    {
		    get { return tipoCambio;}
		    set { tipoCambio = value;}
	    }
    	
        /// <summary>
        /// Obtiene y establece el índice de precios al consumidor, según el BCCR.
        /// </summary>
	    public decimal IndicePreciosConsumidor
	    {
		    get { return indicePreciosConsumidor;}
		    set { indicePreciosConsumidor = value;}
	    }

        /// <summary>
        /// Obtiene el año del registro extraído.
        /// </summary>
        public int Anno
        {
            get { return anno; }
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


        #endregion Propiedades Públicas

        #region Constructores

        /// <summary>
        /// Constructor básico de la clase
        /// </summary>
        public clsIndiceActualizacionAvaluo()
        {
            fechaHora = DateTime.MinValue;
            tipoCambio = 0;
            indicePreciosConsumidor = 0;
            anno = 0;
        }

        /// <summary>
        /// Constructor de la clase que carga los datos que posee la trama recibida
        /// </summary>
        /// <param name="tramaIndicesActualizacionAvaluo">Trama que posee los datos sobre los índices usados para la actualización de avalúos</param>
        public clsIndiceActualizacionAvaluo(string tramaIndicesActualizacionAvaluo)
        {
            fechaHora = DateTime.MinValue;
            tipoCambio = 0;
            indicePreciosConsumidor = 0;
            anno = 0;

            if (tramaIndicesActualizacionAvaluo.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();

                try
                {
                    xmlTrama.LoadXml(tramaIndicesActualizacionAvaluo);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluos, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluosDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlTrama != null)
                {
                    DateTime fechora;
                    decimal tipoCambioCompra;
                    decimal ipc;
                    int annno;
                    
                    try
                    {
                        if (xmlTrama.SelectSingleNode("//" + _fechaHora) != null)
                        {
                            fechaHora = ((xmlTrama.SelectSingleNode("//" + _fechaHora) != null) ? ((DateTime.TryParse((xmlTrama.SelectSingleNode("//" + _fechaHora).InnerText), out fechora)) ? fechora : DateTime.Now) : DateTime.Now);
                            tipoCambio = ((xmlTrama.SelectSingleNode("//" + _tipoCambio) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _tipoCambio).InnerText), out tipoCambioCompra)) ? tipoCambioCompra : 0) : 0);
                            indicePreciosConsumidor = ((xmlTrama.SelectSingleNode("//" + _indicePreciosConsumidor) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _indicePreciosConsumidor).InnerText), out ipc)) ? ipc : 0) : 0);
                            anno = fechaHora.Year;
                        }
                        else
                        {
                            anno = ((xmlTrama.SelectSingleNode("//" + _Anno) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _Anno).InnerText), out annno)) ? annno : 0) : 0);
                        }
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluos, Mensajes.ASSEMBLY);

                        string desError = "El error se da al cargar los datos del catálogo de índices de actualización de avalúos: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluosDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }
                }

            }

        }
        #endregion Constructores

        #region Métodos Públicos

        #endregion Métodos Públicos

        #region Métodos Privados

        /// <summary>
        /// Evalúa que los campos requeridos posean datos
        /// </summary>
        /// <returns>True: Todos los campos requeridos están completos, False: Existe al menos un campo requerido que no fue suministrado</returns>
        public bool CamposRequeridosValidos()
        {
            bool camposRequeridos = true;

            if (camposRequeridos && this.FechaHora == DateTime.MinValue)
            {
                this.descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "a la fecha de vigencia", Mensajes.ASSEMBLY);
                this.errorDatos = true;
                camposRequeridos = false;
            }
            if (camposRequeridos && this.tipoCambio == 0)
            {
                this.descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al tipo de cambio", Mensajes.ASSEMBLY);
                this.errorDatos = true;
                camposRequeridos = false;
            }
            if (camposRequeridos && this.indicePreciosConsumidor == 0)
            {
                this.descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al índice de precios al consumidor", Mensajes.ASSEMBLY);
                this.errorDatos = true;
                camposRequeridos = false;
            }

            return camposRequeridos;

        }

        #endregion Métodos Privados
    }
}
