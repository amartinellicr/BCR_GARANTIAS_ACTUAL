using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace BCR.GARANTIAS.Entidades
{
    public class clsEjecucionProceso
    {
        #region Constantes

        private const string _proceso       = "cocProceso";
        private const string _fecha         = "fecIngreso";
        private const string _resultado     = "Resultado";
        private const string _observacion   = "desObservacion";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Descripci�n del proceso
        /// </summary>
        private string nombreProceso;

        /// <summary>
        /// Fecha en que se realiza la ejecuci�n
        /// </summary>
        private DateTime fechaEjecucion;
    
        /// <summary>
        /// Resultado de la ejecuci�n
        /// </summary>
        private string resultadoEjecucion;

        /// <summary>
        /// Detalle de la ejecuci�n
        /// </summary>
        private string detalleEjecucion;

        #endregion Variables

        #region Propiedades P�blicas
    
        /// <summary>
        /// Propiedad que obtiene el nombre del proceso ejecutado
        /// </summary>
	    public string NombreProceso
	    {
		    get { return nombreProceso;}
		    set { nombreProceso = value;}
	    }

        /// <summary>
        /// Propiedad que obtiene la fecha en que se realiza la ejecuci�n del proceso
        /// </summary>
	    public DateTime FechaEjecucion
	    {
		    get { return fechaEjecucion;}
		    set { fechaEjecucion = value;}
	    }

        /// <summary>
        /// Propiedad que obtiene el resultado de la ejecuci�n del subproceso
        /// </summary>
	    public string ResultadoEjecucion
	    {
		    get { return resultadoEjecucion;}
		    set { resultadoEjecucion = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene el detalle de la ejecuci�n
        /// </summary>
	    public string DetalleEjecucion
	    {
		    get { return detalleEjecucion;}
		    set { detalleEjecucion = value;}
	    }
	
        #endregion Propiedades P�blicas

        #region Constructores

        /// <summary>
        /// Constructor b�sico de la clase
        /// </summary>
        public clsEjecucionProceso()
        {
            this.nombreProceso = string.Empty;
            this.fechaEjecucion = DateTime.MinValue;
            this.resultadoEjecucion = string.Empty;
            this.detalleEjecucion = string.Empty;
        }

        /// <summary>
        /// Constructor de la clase que carga los datos que posee la trama recibida
        /// </summary>
        /// <param name="tramaEjecucionProceso">Trama que posee los datos de la ejecuci�n</param>
        public clsEjecucionProceso(string tramaEjecucionProceso)
        {
            /*
             <RESPUESTA>
              <CODIGO>0</CODIGO>
              <PROCEDIMIENTO>pa_Obtener_Valuaciones_Reales</PROCEDIMIENTO>
              <MENSAJE>La obtenci�n de datos fue satisfactoria</MENSAJE>
              <RESULTADOS>
                <RESULTADO>
                  <cocProceso>MIGRAR GARANTIAS</cocProceso>
                  <fecIngreso>2014-02-11T19:04:17.860</fecIngreso>
                  <Resultado>Exitoso</Resultado>
                  <desObservacion>Inicia el proceso de migraci�n</desObservacion>
                </RESULTADO>
              </RESULTADOS>
            </RESPUESTA>
             */

            this.nombreProceso      = string.Empty;
            this.fechaEjecucion     = DateTime.MinValue;
            this.resultadoEjecucion = string.Empty;
            this.detalleEjecucion   = string.Empty;

            if (tramaEjecucionProceso.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();
                DateTime fecEjecucion;

                xmlTrama.LoadXml(tramaEjecucionProceso);

                fechaEjecucion = ((xmlTrama.SelectSingleNode("//" + _fecha) != null) ? ((DateTime.TryParse((xmlTrama.SelectSingleNode("//" + _fecha).InnerText), out fecEjecucion)) ? fecEjecucion : DateTime.MinValue) : DateTime.MinValue);

                nombreProceso = ((xmlTrama.SelectSingleNode("//" + _proceso) != null) ? xmlTrama.SelectSingleNode("//" + _proceso).InnerText : string.Empty);
                resultadoEjecucion = ((xmlTrama.SelectSingleNode("//" + _resultado) != null) ? xmlTrama.SelectSingleNode("//" + _resultado).InnerText : string.Empty);
                detalleEjecucion = ((xmlTrama.SelectSingleNode("//" + _observacion) != null) ? xmlTrama.SelectSingleNode("//" + _observacion).InnerText : string.Empty);
            }
        }

        #endregion Constructores

        #region M�todos P�blicos

        #endregion M�todos P�blicos
    }
}
