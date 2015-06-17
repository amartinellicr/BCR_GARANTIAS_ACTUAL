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
        /// Indicador de que se present� un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripci�n del error detectado
        /// </summary>
        private string descripcionError;

        /// <summary>
        /// Se obtiene el a�o del registro
        /// </summary>
        private int anno;

        #endregion Variables

        #region Propiedades P�blicas

        /// <summary>
        /// Obtiene y establece la fecha y hora del registro.
        /// </summary>
	    public DateTime  FechaHora
	    {
		    get { return fechaHora;}
		    set { fechaHora = value;}
	    }
    	
        /// <summary>
        /// Obtiene y establece el tipo de cambio de compra, seg�n el BCCR.
        /// </summary>
	    public decimal TipoCambio
	    {
		    get { return tipoCambio;}
		    set { tipoCambio = value;}
	    }
    	
        /// <summary>
        /// Obtiene y establece el �ndice de precios al consumidor, seg�n el BCCR.
        /// </summary>
	    public decimal IndicePreciosConsumidor
	    {
		    get { return indicePreciosConsumidor;}
		    set { indicePreciosConsumidor = value;}
	    }

        /// <summary>
        /// Obtiene el a�o del registro extra�do.
        /// </summary>
        public int Anno
        {
            get { return anno; }
        }
	
        /// <summary>
        /// Propiedad que obtiene y establece la indicaci�n de que se present� un error por problema de datos
        /// </summary>
        public bool ErrorDatos
        {
            get { return errorDatos; }
            set { errorDatos = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripci�n del error
        /// </summary>
        public string DescripcionError
        {
            get { return descripcionError; }
            set { descripcionError = value; }
        }


        #endregion Propiedades P�blicas

        #region Constructores

        /// <summary>
        /// Constructor b�sico de la clase
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
        /// <param name="tramaIndicesActualizacionAvaluo">Trama que posee los datos sobre los �ndices usados para la actualizaci�n de aval�os</param>
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

                        string desError = "El error se da al cargar los datos del cat�logo de �ndices de actualizaci�n de aval�os: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluosDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }
                }

            }

        }
        #endregion Constructores

        #region M�todos P�blicos

        #endregion M�todos P�blicos

        #region M�todos Privados

        /// <summary>
        /// Eval�a que los campos requeridos posean datos
        /// </summary>
        /// <returns>True: Todos los campos requeridos est�n completos, False: Existe al menos un campo requerido que no fue suministrado</returns>
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
                this.descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al �ndice de precios al consumidor", Mensajes.ASSEMBLY);
                this.errorDatos = true;
                camposRequeridos = false;
            }

            return camposRequeridos;

        }

        #endregion M�todos Privados
    }
}
