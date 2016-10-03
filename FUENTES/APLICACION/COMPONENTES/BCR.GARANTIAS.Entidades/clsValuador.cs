using System;
using System.Xml;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsValuador
    {
        #region Ejemplo de parte de la trama

        //PARA PERITO
        //<VALUADOR>
        //    <cedula_valuador>103550419</cedula_valuador>
        //    <nombre_valuador>Roberto Loría González</nombre_valuador>
        //    <tipo_persona_valuador>1</tipo_persona_valuador>
        //    <direccion_valuador>Apado 83630 San José</direccion_valuador>
        //    <telefono_valuador></telefono_valuador>
        //    <email_valuador></email_valuador>
        //</VALUADOR>


        //PARA EMPRESA
        //<VALUADOR>
        //    <cedula_valuador>3101004126</cedula_valuador>
        //    <nombre_valuador>Franz Amrhein y Compañía S.A.</nombre_valuador>
        //    <direccion_valuador>Apdo 1766 cp 1000 San José</direccion_valuador>
        //    <telefono_valuador>2576911</telefono_valuador>
        //    <email_valuador></email_valuador>
        //</VALUADOR>

        #endregion Ejemplo de parte de la trama

        #region Constantes

        private const string _tagValuador           = "VALUADOR";

        private const string _cedulaValuador        = "cedula_valuador";
        private const string _nombreValuador        = "nombre_valuador";
        private const string _tipoPersonaValuador   = "tipo_persona_valuador";
        private const string _direccionValuador     = "direccion_valuador";
        private const string _telefonoValuador      = "telefono_valuador";
        private const string _emailValuador         = "email_valuador";
        private const string _datosValuador         = "datos_valuador";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Identificación del valuador
        /// </summary>
        private string cedulaValuador;

        /// <summary>
        /// Nombre completo del valuador
        /// </summary>
        private string nombreValuador;

        /// <summary>
        /// Tipo de persona del valuador
        /// </summary>
        private int  tipoPersonaValuador;

        /// <summary>
        /// Dirección del valuador
        /// </summary>
        private string direccionValuador;

        /// <summary>
        /// Número de teléfono del valuador
        /// </summary>
        private string telefonoValuador;

        /// <summary>
        /// Correo electrónico del valuador
        /// </summary>
        private string correoValuador;

        /// <summary>
        /// Indicador de que se presentó un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripción del error detectado
        /// </summary>
        private string descripcionError;

        /// <summary>
        /// Datos del valuador utilizado cuando se enlistas los valuadores
        /// </summary>
        private string datosValuador;

        #endregion Variables

        #region Propiedades

        /// <summary>
        /// Propiedad que obtiene y establece la identificación del valuador
        /// </summary>
        public string CedulaValuador
	    {
		    get { return cedulaValuador;}
		    set { cedulaValuador = value;}
	    }

        /// <summary>
        /// Propiedad que obtiene y establece el nombre completo del valuador
        /// </summary>
	    public string NombreValuador
	    {
		    get { return nombreValuador;}
		    set { nombreValuador = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece el tipo de persona del valuador. 
        /// </summary>
	    public int  TipoPersonaValuador
	    {
		    get { return tipoPersonaValuador;}
		    set { tipoPersonaValuador = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece la dirección del valuador
        /// </summary>
	    public string DireccionValuador
	    {
		    get { return direccionValuador;}
		    set { direccionValuador = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece el número telefónico del valuador
        /// </summary>
	    public string TelefonoValuador
	    {
		    get { return telefonoValuador;}
		    set { telefonoValuador = value;}
	    }
	
        /// <summary>
        /// Propiedad que obtiene y establece el correo electrónico del valuador
        /// </summary>
        public string CorreoValuador
	    {
		    get { return correoValuador;}
		    set { correoValuador = value;}
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
        /// Propiedad que obtiene y establece los datos del valuador
        /// </summary>
        public string DatosValuador
        {
            get { return datosValuador; }
            set { datosValuador = value; }
        }
	
        #endregion Propiedades

        #region Constructores

        public clsValuador()
        {
            cedulaValuador = string.Empty;
            nombreValuador = string.Empty;
            tipoPersonaValuador = -1;
            direccionValuador = string.Empty;
            telefonoValuador = string.Empty;
            correoValuador = string.Empty;
        }

        public clsValuador(string tramaValuador, Enumeradores.TiposValuadores listaTipoValuador)
        {
            #region Trama Ejemplo
            /*
             PARA PERITOS
             
                <VALUADORES>
                    <VALUADOR>
                      <cedula_valuador>103550419</cedula_valuador>
                      <nombre_valuador>Roberto Loría González</nombre_valuador>
                      <tipo_persona_valuador>1</tipo_persona_valuador>
                      <direccion_valuador>Apado 83630 San José</direccion_valuador>
                      <telefono_valuador></telefono_valuador>
                      <email_valuador></email_valuador>
                    </VALUADOR>
                    <VALUADOR>
                      <cedula_valuador>103560599</cedula_valuador>
                      <nombre_valuador>Hugo Zeledón Grau</nombre_valuador>
                      <tipo_persona_valuador>1</tipo_persona_valuador>
                      <direccion_valuador>200 Norte 25 Sur de la Coca, Golfito, Puntarenas</direccion_valuador>
                      <telefono_valuador>7899080</telefono_valuador>
                      <email_valuador></email_valuador>
                    </VALUADOR>
                </VALUADORES>

             PARA EMPRESAS
             
                <VALUADORES>
                    <VALUADOR>
                      <cedula_valuador>3101004126</cedula_valuador>
                      <nombre_valuador>Franz Amrhein y Compañía S.A.</nombre_valuador>
                      <direccion_valuador>Apdo 1766 cp 1000 San José</direccion_valuador>
                      <telefono_valuador>2576911</telefono_valuador>
                      <email_valuador></email_valuador>
                    </VALUADOR>
                    <VALUADOR>
                      <cedula_valuador>3101005113</cedula_valuador>
                      <nombre_valuador>Capris S A</nombre_valuador>
                      <direccion_valuador>La Uruca</direccion_valuador>
                      <telefono_valuador>290-01-02</telefono_valuador>
                      <email_valuador></email_valuador>
                    </VALUADOR>
                </VALUADORES>
                */

            #endregion Trama Ejemplo

            cedulaValuador = string.Empty;
            nombreValuador = string.Empty;
            tipoPersonaValuador = -1;
            direccionValuador = string.Empty;
            telefonoValuador = string.Empty;
            correoValuador = string.Empty;

            string tipoValuador = "los valuadores";

            switch (listaTipoValuador)
            {
                case Enumeradores.TiposValuadores.Perito: tipoValuador = "los peritos";
                    break;
                case Enumeradores.TiposValuadores.Empresa: tipoValuador = "las empresas valuadoras";
                    break;
                default:
                    break;
            }

            if (tramaValuador.Length > 0)
            {
                XmlDocument xmlValuador = new XmlDocument();

                try
                {
                    xmlValuador.LoadXml(tramaValuador);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaListaValuadores, tipoValuador, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaListaValuadoresDetalle, tipoValuador, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlValuador != null)
                {
                    int codTipoPersona;

                    try
                    {
                        if (xmlValuador.SelectSingleNode("//" + _datosValuador) != null)
                        {
                            cedulaValuador = ((xmlValuador.SelectSingleNode("//" + _cedulaValuador) != null) ? xmlValuador.SelectSingleNode("//" + _cedulaValuador).InnerText : string.Empty);
                            datosValuador = ((xmlValuador.SelectSingleNode("//" + _datosValuador) != null) ? xmlValuador.SelectSingleNode("//" + _datosValuador).InnerText : string.Empty);
                        }
                        else
                        {
                            cedulaValuador = ((xmlValuador.SelectSingleNode("//" + _cedulaValuador) != null) ? xmlValuador.SelectSingleNode("//" + _cedulaValuador).InnerText : string.Empty);
                            nombreValuador = ((xmlValuador.SelectSingleNode("//" + _nombreValuador) != null) ? xmlValuador.SelectSingleNode("//" + _nombreValuador).InnerText : string.Empty);
                            direccionValuador = ((xmlValuador.SelectSingleNode("//" + _direccionValuador) != null) ? xmlValuador.SelectSingleNode("//" + _direccionValuador).InnerText : string.Empty);
                            telefonoValuador = ((xmlValuador.SelectSingleNode("//" + _telefonoValuador) != null) ? xmlValuador.SelectSingleNode("//" + _telefonoValuador).InnerText : string.Empty);
                            correoValuador = ((xmlValuador.SelectSingleNode("//" + _emailValuador) != null) ? xmlValuador.SelectSingleNode("//" + _emailValuador).InnerText : string.Empty);

                            tipoPersonaValuador = ((xmlValuador.SelectSingleNode("//" + _tipoPersonaValuador) != null) ? ((int.TryParse((xmlValuador.SelectSingleNode("//" + _tipoPersonaValuador).InnerText), out codTipoPersona)) ? codTipoPersona : -1) : -1);
                        }
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorCargaListaValuadores, tipoValuador, Mensajes.ASSEMBLY);

                        string desError = "El error se da al cargar los datos del valuador: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaListaValuadoresDetalle, tipoValuador, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }
                }
            }
        }

        #endregion Constructores

        #region Métodos Públicos

        #endregion Métodos Públicos

        #region Métodos Privados

        #endregion Métodos Privados
   }
}
