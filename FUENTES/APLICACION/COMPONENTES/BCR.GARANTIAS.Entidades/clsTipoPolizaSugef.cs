using System;
using System.Xml;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    [Serializable]
    public class clsTipoPolizaSugef
    {
        #region Constantes

        public const string _tipoPolizaSugef                = "CAT_TIPOS_POLIZAS_SUGEF";
        public const string _codigoTipoPolizaSugef          = "Codigo_Tipo_Poliza_Sugef";
        public const string _nombreTipoPolizaSugef          = "Nombre_Tipo_Poliza";
        public const string _descripcionTipoPolizaSugef     = "Descripcion_Tipo_Poliza";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Almacena el código del tipo de póliza SUGEF
        /// </summary>
        private int tipoPolizaSugef;

        /// <summary>
        /// Nombre del tipo de póliza SUGEF
        /// </summary>
        private string nombreTipoPolizaSugef;

        /// <summary>
        /// Descripción del tipo de póliza SUGEF
        /// </summary>
        private string descripcionTipoPolizaSugef;
              
        /// <summary>
        /// Indicador de que se presentó un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripción del error detectado
        /// </summary>
        private string descripcionError;

        #endregion Variables

        #region Propiedades Públicas

        /// <summary>
        /// Obtiene y establece el código del tipo de póliza SUGEF.
        /// </summary>
	    public int TipoPolizaSugef
	    {
		    get { return tipoPolizaSugef;}
		    set { tipoPolizaSugef = value;}
	    }
    	
        /// <summary>
        /// Propiedad que obtiene y establece el nombre del tipo de póliza SUGEF.
        /// </summary>
        public string NombreTipoPolizaSugef
        {
            get { return nombreTipoPolizaSugef; }
            set { nombreTipoPolizaSugef = value;}
        }

        /// <summary>
        /// Propiedad que obtiene la descripción del tipo de póliza SUGEF
        /// </summary>
        public string DescripcionTipoPolizaSugef
        {
            get { return descripcionTipoPolizaSugef; }
            set { descripcionTipoPolizaSugef = value;}
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
        /// Porpiedad que obtiene el código del tipo de póliza SUGEF y el nombre concatenados 
        /// </summary>
        public string NombreCodigoTipoPolizaSugef
        {
            get { return ((TipoPolizaSugef != -1) ? (string.Format("{0} - {1}", tipoPolizaSugef, nombreTipoPolizaSugef)) : string.Empty); }
        }
        
        #endregion Propiedades Públicas

        #region Constructores

        /// <summary>
        /// Constructor básico de la clase
        /// </summary>
        public clsTipoPolizaSugef()
        {
            tipoPolizaSugef = -1;
            nombreTipoPolizaSugef = string.Empty;
            descripcionTipoPolizaSugef = string.Empty;
            errorDatos = false;
            descripcionError = string.Empty;
        }

        /// <summary>
        /// Constructor de la clase que carga los datos que posee la trama recibida
        /// </summary>
        /// <param name="tramaTipoPolizaSugef">Trama que posee los datos sobre los tipos de pólizas SUGEF</param>
        public clsTipoPolizaSugef(string tramaTipoPolizaSugef)
        {
            tipoPolizaSugef = -1;
            nombreTipoPolizaSugef = string.Empty;
            descripcionTipoPolizaSugef = string.Empty;
            errorDatos = false;
            descripcionError = string.Empty;

            if (tramaTipoPolizaSugef.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();

                try
                {
                    xmlTrama.LoadXml(tramaTipoPolizaSugef);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaTipoPolizaSugef, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaTipoPolizaSugefDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlTrama != null)
                {
                    int tipoPolSugef;

                    try
                    {
                        tipoPolizaSugef = ((xmlTrama.SelectSingleNode("//" + _codigoTipoPolizaSugef) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codigoTipoPolizaSugef).InnerText), out tipoPolSugef)) ? tipoPolSugef : -1) : -1);
                        nombreTipoPolizaSugef = ((xmlTrama.SelectSingleNode("//" + _nombreTipoPolizaSugef) != null) ? xmlTrama.SelectSingleNode("//" + _nombreTipoPolizaSugef).InnerText : string.Empty);
                        descripcionTipoPolizaSugef = ((xmlTrama.SelectSingleNode("//" + _descripcionTipoPolizaSugef) != null) ? xmlTrama.SelectSingleNode("//" + _descripcionTipoPolizaSugef).InnerText : string.Empty);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorCargaTipoPolizaSugef, Mensajes.ASSEMBLY);

                        string desError = "El error se da al cargar los datos del catálogo de tipos de pólizas SUGEF: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaTipoPolizaSugefDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

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

            if (camposRequeridos && tipoPolizaSugef == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al tipo de póliza SUGEF", Mensajes.ASSEMBLY);
                errorDatos = true;
                camposRequeridos = false;
            }
            if (camposRequeridos && nombreTipoPolizaSugef.Length == 0)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "a la descripción del tipo de póliza SUGEF", Mensajes.ASSEMBLY);
                errorDatos = true;
                camposRequeridos = false;
            }
            if (camposRequeridos && descripcionTipoPolizaSugef.Length == 0)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al detalle del tipo de póliza SUGEF", Mensajes.ASSEMBLY);
                errorDatos = true;
                camposRequeridos = false;
            }

            return camposRequeridos;

        }

        #endregion Métodos Privados
    }
}