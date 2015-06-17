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
    [Serializable]
    public class clsPorcentajeAceptacion
    {

        #region Constantes

        public const string _catTipoPorcentajeAceptacion = "CAT_PORCENTAJE_ACEPTACION";
        public const string _codigoPorcentajeAceptacion = "Codigo_Porcentaje_Aceptacion";
        public const string _codigoTipoGarantia = "Codigo_Tipo_Garantia";
        public const string _codigoTipoMitigador = "Codigo_Tipo_Mitigador";
        public const string _indicadorSinCalificacion = "Indicador_Sin_Calificacion";
        public const string _porcentajeAceptacion = "Porcentaje_Aceptacion";
        public const string _porcentajeCeroTres = "Porcentaje_Cero_Tres";
        public const string _porcentajeCuatro= "Porcentaje_Cuatro";
        public const string _porcentajeCinco = "Porcentaje_Cinco";
        public const string _porcentajeSeis = "Porcentaje_Seis";
        public const string _usuarioInserto = "Usuario_Inserto";
        public const string _fechaInserto = "Fecha_Inserto";
        public const string _usuarioModifico= "Usuario_Modifico";
        public const string _fechaModifico = "Fecha_Modifico";        

        #endregion

        #region Variables

        /// <summary>
        /// Almacena el código (consecutivo) del porcentaje de aceptación
        /// </summary>
        private int codigoPorcentajeAceptacion;

        /// <summary>
        /// Almacena el código (consecutivo) del tipo de garantia
        /// </summary>
        private int codigoTipoGarantia;

        /// <summary>
        /// Almacena el código (consecutivo) del tipo de mitigador de riesgo
        /// </summary>
        private int codigoTipoMitigador;

        /// <summary>
        /// Indicador de 0: No Aplica Calificacion 1:Sin Calificacion
        /// </summary>
        private Boolean indicadorSinCalificacion;

        /// <summary>
        /// Almacena el monto del porcentaje de aceptación
        /// </summary>
        private decimal porcentajeAceptacion;

        /// <summary>
        /// Almacena el monto del porcentaje de aceptación de 0-3
        /// </summary>
        private decimal porcentajeCeroTres;

        /// <summary>
        /// Almacena el monto del porcentaje de aceptación 4
        /// </summary>
        private decimal porcentajeCuatro;

        /// <summary>
        /// Almacena el monto del porcentaje de aceptación 5
        /// </summary>
        private decimal porcentajeCinco;

        /// <summary>
        /// Almacena el monto del porcentaje de aceptación 6
        /// </summary>
        private decimal porcentajeSeis;

        /// <summary>
        /// Almacena el usuario que insertó el registro 
        /// </summary>
        private string usuarioInserto;

        /// <summary>
        /// Almacena la fecha en que se insertó el registro 
        /// </summary>
        private DateTime fechaInserto;

        /// <summary>
        /// Almacena el usuario que modificó el registro 
        /// </summary>
        private string usuarioModifico;

        /// <summary>
        /// Almacena la fecha en que se modificó el registro 
        /// </summary>
        private DateTime fechaModifico;
    
        /// <summary>
        /// Indicador de que se presentó un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripción del error detectado
        /// </summary>
        private string descripcionError;
       
        #endregion

        #region Propiedades Públicas

        /// <summary>
        /// Propiedad que obtiene y establece el consecutivo del porcentaje de aceptacion
        /// </summary>

        public int CodigoPorcentajeAceptacion
        {
            get { return codigoPorcentajeAceptacion; }
            set { codigoPorcentajeAceptacion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el consecutivo del tipo de garantia del catalago de tipos de garantia
        /// </summary>

        public int CodigoTipoGarantia
        {
            get { return codigoTipoGarantia; }
            set { codigoTipoGarantia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el consecutivo del tipo de mitigador del catalogo de tipo de mitigador de riesgo
        /// </summary>
        /// 
        public int CodigoTipoMitigador
        {
            get { return codigoTipoMitigador; }
            set { codigoTipoMitigador = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el indicador  0: No Aplica Calificacion 1:Sin Calificacion
        /// </summary>
        public Boolean IndicadorSinCalificacion
        {
            get { return indicadorSinCalificacion; }
            set { indicadorSinCalificacion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el porcentaje de aceptacion  
        /// </summary>
        public decimal PorcentajeAceptacion
        {
            get { return porcentajeAceptacion; }
            set { porcentajeAceptacion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el porcentaje de aceptacion de 0-3, cuando el IndicadorSinCalificacion es 1
        /// </summary>
        public decimal PorcentajeCeroTres
        {
            get { return porcentajeCeroTres; }
            set { porcentajeCeroTres = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el porcentaje de aceptacion 4, cuando el IndicadorSinCalificacion es 1
        /// </summary>
        public decimal PorcentajeCuatro
        {
            get { return porcentajeCuatro; }
            set { porcentajeCuatro = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el porcentaje de aceptacion 5, cuando el IndicadorSinCalificacion es 1
        /// </summary>
        public decimal PorcentajeCinco
        {
            get { return porcentajeCinco; }
            set { porcentajeCinco = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el porcentaje de aceptacion de 6, cuando el IndicadorSinCalificacion es 1
        /// </summary>
        public decimal PorcentajeSeis
        {
            get { return porcentajeSeis; }
            set { porcentajeSeis = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el usuario que insertó el registro
        /// </summary>
        public string UsuarioInserto
        {
            get { return usuarioInserto; }
            set { usuarioInserto = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la hora en que se insertó el registro
        /// </summary>
        public DateTime FechaInserto
        {
            get { return fechaInserto; }
            set { fechaInserto = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el usuario que modificó el registro
        /// </summary>
        public string UsuarioModifico
        {
            get { return usuarioModifico; }
            set { usuarioModifico = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la hora en que se modificó el registro
        /// </summary>
        public DateTime FechaModifico
        {
            get { return fechaModifico; }
            set { fechaModifico = value; }
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

        #endregion

        #region Constructores

        /// <summary>
        /// Constructor básico de la clase
        /// </summary>
        public clsPorcentajeAceptacion() 
        {
            codigoPorcentajeAceptacion = -1;
            codigoTipoGarantia = -1;
            codigoTipoMitigador = -1;
            indicadorSinCalificacion = false;
            porcentajeAceptacion = 0;
            porcentajeCeroTres = 0;
            porcentajeCuatro = 0;
            porcentajeCinco = 0;
            porcentajeSeis = 0;
            usuarioInserto = string.Empty;
            fechaInserto = DateTime.MinValue;
            usuarioModifico = string.Empty;
            fechaModifico = DateTime.MinValue;
            errorDatos = false;
            descripcionError = string.Empty;
        
        }

        /// <summary>
        /// Constructor de la clase que carga los datos que posee la trama recibida
        /// </summary>
        /// <param name="tramaPorcentajeAceptacion">Trama que posee los datos sobre los porcentajes de aceptacion</param>
        public clsPorcentajeAceptacion(string tramaPorcentajeAceptacion)
        {
            codigoPorcentajeAceptacion = -1;
            codigoTipoGarantia = -1;
            codigoTipoMitigador = -1;
            indicadorSinCalificacion = false;
            porcentajeAceptacion = 0;
            porcentajeCeroTres = 0;
            porcentajeCuatro = 0;
            porcentajeCinco = 0;
            porcentajeSeis = 0;
            usuarioInserto = string.Empty;
            fechaInserto = DateTime.MinValue;
            usuarioModifico = string.Empty;
            fechaModifico = DateTime.MinValue;
            errorDatos = false;
            descripcionError = string.Empty;

            if (tramaPorcentajeAceptacion.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();
                string[] formatosFecha = { "yyyyMMdd", "dd/MM/yyyy" };

                try
                {
                    xmlTrama.LoadXml(tramaPorcentajeAceptacion);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaPorcentajeAceptacion, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaPorcentajeAceptacionDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlTrama != null)
                {
                    int codPorcenAceptacion;
                    int codTipoGarantia;
                    int codTipoMitigador;
                    decimal porcenAceptacion;
                    decimal porcenCeroTres;
                    decimal porcenCuatro;
                    decimal porcenCinco;
                    decimal porcenSeis;                 
                    DateTime fecInserto;
                    DateTime fecModifico;

                    try
                    {
                        codigoPorcentajeAceptacion = ((xmlTrama.SelectSingleNode("//" + _codigoPorcentajeAceptacion) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codigoPorcentajeAceptacion).InnerText), out codPorcenAceptacion)) ? codPorcenAceptacion : -1) : -1);
                        codigoTipoGarantia = ((xmlTrama.SelectSingleNode("//" + _codigoTipoGarantia) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codigoTipoGarantia).InnerText), out codTipoGarantia)) ? codTipoGarantia : -1) : -1);
                        codigoTipoMitigador = ((xmlTrama.SelectSingleNode("//" + _codigoTipoMitigador) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codigoTipoMitigador).InnerText), out codTipoMitigador)) ? codTipoMitigador : -1) : -1);

                        indicadorSinCalificacion = ((xmlTrama.SelectSingleNode("//" + _indicadorSinCalificacion) != null) ? ((xmlTrama.SelectSingleNode("//" + _indicadorSinCalificacion).InnerText.CompareTo("0") == 0) ? false : true) : false);

                        porcentajeAceptacion = ((xmlTrama.SelectSingleNode("//" + _porcentajeAceptacion) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _porcentajeAceptacion).InnerText), out porcenAceptacion)) ? porcenAceptacion : 0) : 0);
                        porcentajeCeroTres = ((xmlTrama.SelectSingleNode("//" + _porcentajeCeroTres) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _porcentajeCeroTres).InnerText), out porcenCeroTres)) ? porcenCeroTres : 0) : 0);
                        porcentajeCuatro = ((xmlTrama.SelectSingleNode("//" + _porcentajeCuatro) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _porcentajeCuatro).InnerText), out porcenCuatro)) ? porcenCuatro : 0) : 0);
                        porcentajeCinco = ((xmlTrama.SelectSingleNode("//" + _porcentajeCinco) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _porcentajeCinco).InnerText), out porcenCinco)) ? porcenCinco : 0) : 0);
                        porcentajeSeis = ((xmlTrama.SelectSingleNode("//" + _porcentajeSeis) != null) ? ((decimal.TryParse((xmlTrama.SelectSingleNode("//" + _porcentajeSeis).InnerText), out porcenSeis)) ? porcenSeis : 0) : 0);

                        usuarioInserto = ((xmlTrama.SelectSingleNode("//" + _usuarioInserto) != null) ? xmlTrama.SelectSingleNode("//" + _usuarioInserto).InnerText : string.Empty);
                        fechaInserto = ((xmlTrama.SelectSingleNode("//" + _fechaInserto) != null) ? ((DateTime.TryParseExact((xmlTrama.SelectSingleNode("//" + _fechaInserto).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecInserto)) ? ((fecInserto != (new DateTime(1900, 01, 01))) ? fecInserto : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);
                        usuarioModifico = ((xmlTrama.SelectSingleNode("//" + _usuarioModifico) != null) ? xmlTrama.SelectSingleNode("//" + _usuarioModifico).InnerText : string.Empty);
                        fechaModifico = ((xmlTrama.SelectSingleNode("//" + _fechaModifico) != null) ? ((DateTime.TryParseExact((xmlTrama.SelectSingleNode("//" + _fechaModifico).InnerText), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecModifico)) ? ((fecModifico != (new DateTime(1900, 01, 01))) ? fecModifico : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);
                                               
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorCargaPorcentajeAceptacion, Mensajes.ASSEMBLY);

                        string desError = "El error se da al cargar los datos del Porcentaje de Aceptación: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaPorcentajeAceptacionDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }
                }
            }                        
        }
        #endregion

        #region Métodos Públicos

        /// <summary>
        /// Método que permite generar el contenido de la clase en formato JSON
        /// </summary>
        /// <returns>Cadena de texto en formato JSON</returns>
        public string ConvertirJSON()
        {
            StringBuilder formatoJSON = new StringBuilder("{");

            formatoJSON.Append('"');
            formatoJSON.Append(_codigoPorcentajeAceptacion);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(codigoPorcentajeAceptacion.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_codigoTipoGarantia);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(codigoTipoGarantia.ToString());
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_codigoTipoMitigador);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(codigoTipoMitigador.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_indicadorSinCalificacion);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((indicadorSinCalificacion) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_porcentajeAceptacion);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(porcentajeAceptacion.ToString());
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_porcentajeCeroTres);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(porcentajeCeroTres.ToString());
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_porcentajeCuatro);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(porcentajeCuatro.ToString());
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_porcentajeCinco);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(porcentajeCinco.ToString());
            formatoJSON.Append('"');
            formatoJSON.Append(",");
           

            formatoJSON.Append('"');
            formatoJSON.Append(_porcentajeSeis);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(porcentajeSeis.ToString());
            formatoJSON.Append('"');
            formatoJSON.Append(",");         

            formatoJSON.Append('"');
            formatoJSON.Append(_usuarioInserto);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(usuarioInserto.ToString());
            formatoJSON.Append('"');
            formatoJSON.Append(",");
            

            formatoJSON.Append('"');
            formatoJSON.Append(_fechaInserto);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(fechaInserto.ToShortDateString());
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_usuarioModifico);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(usuarioModifico.ToString());
            formatoJSON.Append('"');
            formatoJSON.Append(",");       

            formatoJSON.Append('"');
            formatoJSON.Append(_fechaModifico);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(fechaModifico.ToShortDateString());
            formatoJSON.Append('"');
            formatoJSON.Append(",");


            formatoJSON.Append('}');

            return formatoJSON.ToString();
        }

        #endregion

        #region Métodos Privados

        /// <summary>
        /// Evalúa que los campos requeridos posean datos
        /// </summary>
        /// <returns>True: Todos los campos requeridos están completos, False: Existe al menos un campo requerido que no fue suministrado</returns>
        public bool CamposRequeridosValidos()
        {
            bool camposRequeridos = true;

            if (camposRequeridos && this.codigoTipoGarantia == -1)
            {
                this.descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al tipo de garantia", Mensajes.ASSEMBLY);
                this.errorDatos = true;
                camposRequeridos = false;
            }
            if (camposRequeridos && this.codigoTipoMitigador == -1)
            {
                this.descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al tipo de mitigador de riesgo", Mensajes.ASSEMBLY);
                this.errorDatos = true;
                camposRequeridos = false;
            }
            //if (camposRequeridos && this.porcentajeAceptacion == 0)
            //{
            //    this.descripcionError = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al porcentaje de aceptación", Mensajes.ASSEMBLY);
            //    this.errorDatos = true;
            //    camposRequeridos = false;
            //}

            return camposRequeridos;

        }

        #endregion Métodos Privados

    }//FIN
}//FIN
