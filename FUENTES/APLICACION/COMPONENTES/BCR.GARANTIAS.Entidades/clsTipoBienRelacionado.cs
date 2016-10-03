using System;
using System.Xml;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    [Serializable]
    public class clsTipoBienRelacionado
    {
        #region Constantes

        public const string _tiposPolizasXTipoBien          = "CAT_TIPOS_POLIZAS_X_TIPO_BIEN";
        public const string _consecutivoRelacion            = "Consecutivo_Relacion";
        public const string _codigoTipoPolizaSap            = "Codigo_Tipo_Poliza_Sap";
        public const string _codigoTipoPolizaSugef          = "Codigo_Tipo_Poliza_Sugef";
        public const string _codigoTipoBien                 = "Codigo_Tipo_Bien";
        public const string _nombreTipoPolizaSugef          = "Nombre_Tipo_Poliza_Sugef";
        public const string _descripcionTipoPolizaSugef     = "Descripcion_Tipo_Poliza_Sugef";
        public const string _descripcionTipoPolizaSap       = "Descripcion_Tipo_Poliza_Sap";
        public const string _descripcionTipoBien            = "Descripcion_Tipo_Bien";

        //Mensajes que se presentarn seg�n la inconsistencia encontrada
       // public const string mensajeRegistroDuplicado = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeDuplicadoTipoPolizaBienRelacionado) !== 'undefined'){$MensajeDuplicadoTipoPolizaBienRelacionado.dialog('open');} </script>";
        public const string mensajeRegistroDuplicado = "<script type=\"text/javascript\" language=\"javascript\">MensajeTipoBienRelacionadoDuplicado();</script>";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Almacena consecutivo del registro
        /// </summary>
        private int consecutivoRelacion;

        /// <summary>
        /// Almacena el tipo de p�liza SAP
        /// </summary>
        private int tipoPolizaSap;

        /// <summary>
        /// Almacena el tipo de p�liza SUGEF
        /// </summary>
        private int tipoPolizaSugef;

        /// <summary>
        /// Almacena el tipo de bien
        /// </summary>
        private int tipoBien;

        /// <summary>
        /// Descripci�n del tipo de p�liza SUGEF
        /// </summary>
        private string descripcionTipoPolizaSugef;

        /// <summary>
        /// Detalle del tipo de p�liza SUGEF
        /// </summary>
        private string nombreTipoPolizaSugef;

        /// <summary>
        /// Descripci�n del tipo de p�liza SAP
        /// </summary>
        private string descripcionTipoPolizaSap;
      
        /// <summary>
        /// Descripci�n del tipo de bien
        /// </summary>
        private string descripcionTipoBien;
       
        /// <summary>
        /// Indicador de que se present� un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripci�n del error detectado
        /// </summary>
        private string descripcionError;


        private int rowIndex;

        #endregion Variables

        #region Propiedades P�blicas

        /// <summary>
        /// Obtiene y establece el consecutivo del registro.
        /// </summary>
	    public int ConsecutivoRelacion
	    {
		    get { return consecutivoRelacion;}
		    set { consecutivoRelacion = value;}
	    }
	    	
        /// <summary>
        /// Obtiene y establece el tipo de p�liza SAP.
        /// </summary>
	    public int TipoPolizaSap
	    {
		    get { return tipoPolizaSap;}
		    set { tipoPolizaSap = value;}
	    }
	
        /// <summary>
        /// Obtiene y establece el tipo de p�liza SUGEF.
        /// </summary>
	    public int TipoPolizaSugef
	    {
		    get { return tipoPolizaSugef;}
		    set { tipoPolizaSugef = value;}
	    }
    	
        /// <summary>
        /// Obtiene y establece el tipo de bien.
        /// </summary>
	    public int TipoBien
	    {
		    get { return tipoBien;}
		    set { tipoBien = value;}
	    }

        /// <summary>
        /// Propiedad que obtiene la descripci�n del tipo de p�liza SUGEF
        /// </summary>
        public string NombreTipoPolizaSugef
        {
            get { return nombreTipoPolizaSugef; }
        }

        /// <summary>
        /// Propiedad que obtiene el detalle del tipo de p�liza SUGEF
        /// </summary>
        public string DescripcionTipoPolizaSugef
        {
            get { return descripcionTipoPolizaSugef; }
        }

        /// <summary>
        /// Propiedad que obtiene la descripci�n del tipo de p�liza SAP
        /// </summary>
        public string DescripcionTipoPolizaSap
        {
            get { return descripcionTipoPolizaSap; }
        }

        /// <summary>
        /// Propiedad que obtiene la descripci�n del tipo de bien
        /// </summary>
        public string DescripcionTipoBien
        {
            get { return descripcionTipoBien; }
        }

        /// <summary>
        /// Porpiedad que obtiene el c�digo del tipo de bien y la descripci�n concatenados 
        /// </summary>
        public string DescripcionCodigoTipoBien
        {
            get { return ((TipoBien != -1) ? (string.Format("{0} - {1}", tipoBien, descripcionTipoBien)) : string.Empty); }
        }

        /// <summary>
        /// Porpiedad que obtiene el c�digo del tipo de p�liza SUGEF y la descripci�n concatenados 
        /// </summary>
        public string DescripcionCodigoTipoPolizaSugef
        {
            get { return ((TipoPolizaSugef != -1) ? (string.Format("{0} - {1}", tipoPolizaSugef, descripcionTipoPolizaSugef)) : string.Empty); }
        }

        /// <summary>
        /// Porpiedad que obtiene el c�digo del tipo de p�liza SAP y la descripci�n concatenados 
        /// </summary>
        public string DescripcionCodigoTipoPolizaSap
        {
            get { return ((TipoPolizaSap != -1) ? (string.Format("{0} - {1}", tipoPolizaSap, descripcionTipoPolizaSap)) : string.Empty); }
        }

        /// <summary>
        /// Porpiedad que obtiene el c�digo del tipo de p�liza SUGEF y el nombre concatenados 
        /// </summary>
        public string NombreCodigoTipoPolizaSugef
        {
            get { return ((TipoPolizaSugef != -1) ? (string.Format("{0} - {1}", tipoPolizaSugef, nombreTipoPolizaSugef)) : string.Empty); }
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


        public string MensajeRegistroDuplicado 
        {
            get { return mensajeRegistroDuplicado; }           
        }

        public int RowIndex
        {
            get { return rowIndex; }
            set { rowIndex = value; }
        }


        #endregion Propiedades P�blicas

        #region Constructores

        /// <summary>
        /// Constructor b�sico de la clase
        /// </summary>
        public clsTipoBienRelacionado()
        {
            consecutivoRelacion = -1;
            tipoPolizaSap = -1;
            tipoPolizaSugef = -1;
            tipoBien = -1;
            nombreTipoPolizaSugef = string.Empty;
            descripcionTipoPolizaSugef = string.Empty;
            descripcionTipoPolizaSap = string.Empty;
            descripcionTipoBien = string.Empty;
            errorDatos = false;
            descripcionError = string.Empty;
        }

        /// <summary>
        /// Constructor de la clase que carga los datos que posee la trama recibida
        /// </summary>
        /// <param name="tramaTipoBienRelacionado">Trama que posee los datos sobre los �ndices usados para la actualizaci�n de aval�os</param>
        public clsTipoBienRelacionado(string tramaTipoBienRelacionado)
        {
            consecutivoRelacion = -1;
            tipoPolizaSap = -1;
            tipoPolizaSugef = -1;
            tipoBien = -1;
            nombreTipoPolizaSugef = string.Empty;
            descripcionTipoPolizaSugef = string.Empty;
            descripcionTipoPolizaSap = string.Empty;
            descripcionTipoBien = string.Empty;
            errorDatos = false;
            descripcionError = string.Empty;


            if (tramaTipoBienRelacionado.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();

                try
                {
                    xmlTrama.LoadXml(tramaTipoBienRelacionado);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaTipoBienRelacionado, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaTipoBienRelacionadDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlTrama != null)
                {
                    int consecutivoRel;
                    int tipoPolSap;
                    int tipoPolSugef;
                    int tipoDeBien;

                    try
                    {
                        consecutivoRelacion = ((xmlTrama.SelectSingleNode("//" + _consecutivoRelacion) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _consecutivoRelacion).InnerText), out consecutivoRel)) ? consecutivoRel :-1) : -1);
                        tipoPolizaSap = ((xmlTrama.SelectSingleNode("//" + _codigoTipoPolizaSap) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codigoTipoPolizaSap).InnerText), out tipoPolSap)) ? tipoPolSap : -1) : -1);
                        tipoPolizaSugef = ((xmlTrama.SelectSingleNode("//" + _codigoTipoPolizaSugef) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codigoTipoPolizaSugef).InnerText), out tipoPolSugef)) ? tipoPolSugef : -1) : -1);
                        tipoBien = ((xmlTrama.SelectSingleNode("//" + _codigoTipoBien) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codigoTipoBien).InnerText), out tipoDeBien)) ? tipoDeBien : -1) : -1);
                        nombreTipoPolizaSugef = ((xmlTrama.SelectSingleNode("//" + _nombreTipoPolizaSugef) != null) ? xmlTrama.SelectSingleNode("//" + _nombreTipoPolizaSugef).InnerText : string.Empty);
                        descripcionTipoPolizaSugef = ((xmlTrama.SelectSingleNode("//" + _descripcionTipoPolizaSugef) != null) ? xmlTrama.SelectSingleNode("//" + _descripcionTipoPolizaSugef).InnerText : string.Empty);
                        descripcionTipoPolizaSap = ((xmlTrama.SelectSingleNode("//" + _descripcionTipoPolizaSap) != null) ? xmlTrama.SelectSingleNode("//" + _descripcionTipoPolizaSap).InnerText : string.Empty);
                        descripcionTipoBien = ((xmlTrama.SelectSingleNode("//" + _descripcionTipoBien) != null) ? xmlTrama.SelectSingleNode("//" + _descripcionTipoBien).InnerText : string.Empty);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorCargaTipoBienRelacionado, Mensajes.ASSEMBLY);

                        string desError = "El error se da al cargar los datos del cat�logo de tipos de bien relacionado a los tipos de p�lizas: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaTipoBienRelacionadDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

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

            if (camposRequeridos && tipoBien == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al tipo de bien", Mensajes.ASSEMBLY);
                errorDatos = true;
                camposRequeridos = false;
            }
            if (camposRequeridos && tipoPolizaSap == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al tipo de p�liza SAP", Mensajes.ASSEMBLY);
                errorDatos = true;
                camposRequeridos = false;
            }
            if (camposRequeridos && tipoPolizaSugef == -1)
            {
                descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al tipo de p�liza SUGEF", Mensajes.ASSEMBLY);
                errorDatos = true;
                camposRequeridos = false;
            }

            return camposRequeridos;

        }

        #endregion M�todos Privados
    }
}
