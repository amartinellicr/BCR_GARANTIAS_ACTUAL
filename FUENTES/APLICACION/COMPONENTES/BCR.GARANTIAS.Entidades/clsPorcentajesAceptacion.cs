using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Xml;
using System.Data;
using System.Diagnostics;
using System.IO;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsPorcentajesAceptacion<T> : CollectionBase 
        where T: clsPorcentajeAceptacion
    {
        
        #region Constantes

        private const string _tagPorcentaje = "PORCENTAJE";
        private const string _tagPorcentajes = "PORCENTAJES";

        public const string _codigoPorcentajeAceptacion = "Codigo_Porcentaje_Aceptacion";
        public const string _codigoTipoGarantia = "Codigo_Tipo_Garantia";
        public const string _codigoTipoMitigador = "Codigo_Tipo_Mitigador";
        public const string _indicadorSinCalificacion = "Indicador_Sin_Calificacion";
        public const string _porcentajeAceptacion = "Porcentaje_Aceptacion";
        public const string _porcentajeCeroTres = "Porcentaje_Cero_Tres";
        public const string _porcentajeCuatro = "Porcentaje_Cuatro";
        public const string _porcentajeCinco = "Porcentaje_Cinco";
        public const string _porcentajeSeis = "Porcentaje_Seis";
        public const string _usuarioInserto = "Usuario_Inserto";
        public const string _fechaInserto = "Fecha_Inserto";
        public const string _usuarioModifico = "Usuario_Modifico";
        public const string _fechaModifico = "Fecha_Modifico";

        #endregion

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaPorcentajesAceptacion;

        /// <summary>
        /// Indicador de que se presentó un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripción del error detectado
        /// </summary>
        private string descripcionError;

        #endregion Variables

        #region Propiedades

        /// <summary>
        /// Obtiene o establece la trama de respuesta obtenida de la consulta realizada a la Base de Datos
        /// </summary>
        public string TramaPorcentajesAceptacion
        {
            get { return tramaPorcentajesAceptacion; }
            set { tramaPorcentajesAceptacion = value; }
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

        #endregion Propiedades

        #region Construtores

        /// <summary>
        /// Constructor base del a clase
        /// </summary>
        public clsPorcentajesAceptacion()
        {
            this.tramaPorcentajesAceptacion = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaPolizasBD">Trama que posee los datos de las pólizas obtenidas de la Base de Datos</param>
        public clsPorcentajesAceptacion(string tramaPorcentajesAceptacionBD)
        {
            this.tramaPorcentajesAceptacion = string.Empty;

            if (tramaPorcentajesAceptacionBD.Length > 0)
            {
                XmlDocument xmlPorcentajes = new XmlDocument();

                try
                {
                    xmlPorcentajes.LoadXml(tramaPorcentajesAceptacionBD);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaPorcentajeAceptacion, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaPorcentajeAceptacionDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlPorcentajes != null)
                {
                    this.tramaPorcentajesAceptacion = tramaPorcentajesAceptacionBD;

                    if (xmlPorcentajes.HasChildNodes)
                    {
                        clsPorcentajeAceptacion entidadPorcentajeAceptacion;

                        foreach (XmlNode nodoPoliza in xmlPorcentajes.SelectNodes("//" + _tagPorcentajes).Item(0).ChildNodes)
                        {
                            entidadPorcentajeAceptacion = new clsPorcentajeAceptacion(nodoPoliza.OuterXml);

                            if (entidadPorcentajeAceptacion.ErrorDatos)
                            {
                                this.errorDatos = entidadPorcentajeAceptacion.ErrorDatos;
                                this.descripcionError = entidadPorcentajeAceptacion.DescripcionError;
                                break;
                            }
                            else
                            {
                                this.Agregar(entidadPorcentajeAceptacion);
                            }
                        }
                    }
                }
            }
        }
        #endregion Constructores


        #region Métodos Públicos

        /// <summary>
        /// Agrega una entidad del tipo porcentaje de aceptacion a la colección
        /// </summary>
        /// <param name="porcentajeAceptacion">Entidad de Poliza SAP que se agregará a la colección</param>
        public void Agregar(clsPorcentajeAceptacion porcentajeAceptacion)
        {
            InnerList.Add(porcentajeAceptacion);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo porcentaje de aceptacion  de la colección
        /// </summary>
        /// <param name="indice">Posición de la entidad dentro de la colección</param>
        public void Remover(int indice)
        {
            InnerList.RemoveAt(indice);
        }

        /// <summary>
        /// Obtiene una entidad del tipo porcentaje de aceptacion  específica
        /// </summary>
        /// <param name="indice">Posición, dentro de la colección, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo porcentaje aceptacion</returns>
        public clsPorcentajeAceptacion Item(int indice)
        {
            return (clsPorcentajeAceptacion)InnerList[indice];
        }

        /// <summary>
        /// Obtiene la lista de elementos del código de porcentaje de aceptacion especificado. 
        /// </summary>
        /// <param name="codigoPorcentajeAceptacion">Código de porcentaje aceptacion del registro requerido</param>
        /// <returns>Lista de entidades del porcentaje de aceptacion</returns>
        public List<clsPorcentajeAceptacion> Items(int codigoPorcentajeAceptacion)
        {
            List<clsPorcentajeAceptacion> listaItems = new List<clsPorcentajeAceptacion>();

            foreach (clsPorcentajeAceptacion entidadPorcentajeAceptacion in InnerList)
            {
                if (entidadPorcentajeAceptacion.CodigoPorcentajeAceptacion == codigoPorcentajeAceptacion)
                {
                    listaItems.Add(entidadPorcentajeAceptacion);
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsPorcentajeAceptacion>("CodigoPorcentajeAceptacion", clsComparadorGenerico<clsPorcentajeAceptacion>.SortOrder.Ascending));

            return listaItems;
        }
        
   
        /// <summary>
        /// Obtiene toda la lista de porcentajes de aceptacion según el tipo de garantia. 
        /// </summary>
        /// <param name="tipoGarantia">Tipo de Garantia</param>
        /// <returns>Lista de entidades del tipo porcentajes de aceptacion</returns>
        public List<clsPorcentajeAceptacion> ObtenerPorcentajeAceptacionPorTipoGarantia(int tipoGarantia)
        {
            List<clsPorcentajeAceptacion> listaItems = new List<clsPorcentajeAceptacion>();

            foreach (clsPorcentajeAceptacion entidadPorcentajeAceptacion in InnerList)
            {
                if (entidadPorcentajeAceptacion.CodigoTipoGarantia == tipoGarantia)
                {
                    listaItems.Add(entidadPorcentajeAceptacion);
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsPorcentajeAceptacion>("CodigoTipoGarantia", clsComparadorGenerico<clsPorcentajeAceptacion>.SortOrder.Ascending));

            return listaItems;
        }


        /// <summary>
        /// Obtiene toda la lista de porcentajes de aceptacion según el tipo de mitigador. 
        /// </summary>
        /// <param name="tipoGarantia">Tipo de Mitigador de Riesgo</param>
        /// <returns>Lista de entidades del tipo porcentajes de aceptacion</returns>
        public List<clsPorcentajeAceptacion> ObtenerPorcentajeAceptacionPorTipoMitigador(int tipoMitigador)
        {
            List<clsPorcentajeAceptacion> listaItems = new List<clsPorcentajeAceptacion>();

            foreach (clsPorcentajeAceptacion entidadPorcentajeAceptacion in InnerList)
            {
                if (entidadPorcentajeAceptacion.CodigoTipoGarantia == tipoMitigador)
                {
                    listaItems.Add(entidadPorcentajeAceptacion);
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsPorcentajeAceptacion>("CodigoTipoMitigador", clsComparadorGenerico<clsPorcentajeAceptacion>.SortOrder.Ascending));

            return listaItems;
        }


        /// <summary>
        /// Se genera la trama con los datos contenidos en la lista
        /// </summary>
        /// <returns>Trama con los datos que posee la lista</returns>
        public string ObtenerTrama()
        {
            string tramaGenerada = string.Empty;

            MemoryStream stream = new MemoryStream(200000);

            //Crea un escritor de XML con el path y el formato
            XmlTextWriter objEscritor = new XmlTextWriter(stream, Encoding.UTF8);

            //Se inicializa para que idente el archivo
            objEscritor.Formatting = Formatting.None;

            //Inicializa el Documento XML
            objEscritor.WriteStartDocument();

            //Inicializa el nodo que poseerá los datos de las operaciones asociadas
            objEscritor.WriteStartElement(_tagPorcentajes);

            if (InnerList.Count > 0)
            {
                foreach (clsPorcentajeAceptacion porcentajeAceptacion in this.InnerList)
                {
                    objEscritor.WriteStartElement(_tagPorcentaje);

                    //Crea el nodo del código Porcentaje Aceptacion
                    objEscritor.WriteStartElement(_codigoPorcentajeAceptacion);
                    objEscritor.WriteString(porcentajeAceptacion.CodigoPorcentajeAceptacion.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del tipo de garantia
                    objEscritor.WriteStartElement(_codigoTipoGarantia);
                    objEscritor.WriteString(porcentajeAceptacion.CodigoTipoGarantia.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del tipo de mitigador
                    objEscritor.WriteStartElement(_codigoTipoMitigador);
                    objEscritor.WriteString(porcentajeAceptacion.CodigoTipoMitigador.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del indicador de 0: No Aplica Calificacion 1:Sin Calificacion
                    objEscritor.WriteStartElement(_indicadorSinCalificacion);
                    objEscritor.WriteString(((porcentajeAceptacion.IndicadorSinCalificacion) ? "1" : "0"));
                    objEscritor.WriteEndElement();
                    

                    //Crea el nodo del porcentaje de aceptacion 
                    objEscritor.WriteStartElement(_porcentajeAceptacion);
                    objEscritor.WriteString(porcentajeAceptacion.PorcentajeAceptacion.ToString());
                    objEscritor.WriteEndElement();


                    //Crea el nodo del porcentaje de aceptacion 0-3
                    objEscritor.WriteStartElement(_porcentajeCeroTres);
                    objEscritor.WriteString(porcentajeAceptacion.PorcentajeCeroTres.ToString());
                    objEscritor.WriteEndElement();

                     //Crea el nodo del porcentaje de aceptacion 4
                    objEscritor.WriteStartElement(_porcentajeCuatro);
                    objEscritor.WriteString(porcentajeAceptacion.PorcentajeCuatro.ToString());
                    objEscritor.WriteEndElement();

                     //Crea el nodo del porcentaje de aceptacion 5
                    objEscritor.WriteStartElement(_porcentajeCinco);
                    objEscritor.WriteString(porcentajeAceptacion.PorcentajeCinco.ToString());
                    objEscritor.WriteEndElement();

                     //Crea el nodo del porcentaje de aceptacion 6
                    objEscritor.WriteStartElement(_porcentajeSeis);
                    objEscritor.WriteString(porcentajeAceptacion.PorcentajeSeis.ToString());
                    objEscritor.WriteEndElement();


                    //Crea el nodo de la fecha de inserción
                    objEscritor.WriteStartElement(_fechaInserto);
                    objEscritor.WriteString(porcentajeAceptacion.FechaInserto.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del usuario que insertó
                    objEscritor.WriteStartElement(_usuarioInserto);
                    objEscritor.WriteString(porcentajeAceptacion.UsuarioInserto);
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha de modificacion
                    objEscritor.WriteStartElement(_fechaModifico);
                    objEscritor.WriteString(porcentajeAceptacion.FechaModifico.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();


                    //Crea el nodo del usuario que modificó
                    objEscritor.WriteStartElement(_usuarioModifico);
                    objEscritor.WriteString(porcentajeAceptacion.UsuarioModifico);
                    objEscritor.WriteEndElement();


                    objEscritor.WriteEndElement();

                    //Final del tag PORCENTAJE
                    objEscritor.WriteEndElement();
                }
            }

            //Final del tag POLIZAS
            objEscritor.WriteEndElement();

            //Final del documento
            objEscritor.WriteEndDocument();

            //Flush
            objEscritor.Flush();

            tramaGenerada = UtilitariosComun.GetStringFromStream(stream).Replace("<?xml version=\"1.0\" encoding=\"utf-8\"?>", string.Empty);

            //Cierre del xml document
            objEscritor.Close();

            return tramaGenerada;
        }
              

        /// <summary>
        /// Método que permite convertir la lista de elementos en formato JSON
        /// </summary>
        /// <returns>Cadena con las pólizas de la lista, en formato JSON</returns>
        public string ObtenerJSON()
        {
            StringBuilder listaPorcentajesAceptacionJSON = new StringBuilder();

            //Se revisa que la lista posea semestres
            if (this.InnerList.Count > 0)
            {
                //Se agrega la llave de inicio
                listaPorcentajesAceptacionJSON.Append("[");

                //Se recorren los semestres y se genera la cedena JSON de cada uno
                foreach (clsPorcentajeAceptacion convertirPorcentajeAceptacion in this.InnerList)
                {
                    listaPorcentajesAceptacionJSON.Append(convertirPorcentajeAceptacion.ConvertirJSON());
                    listaPorcentajesAceptacionJSON.Append(",");
                }

                //Se agrega la llave final
                listaPorcentajesAceptacionJSON.Append("]");

                //Se elimina la coma (,) final
                listaPorcentajesAceptacionJSON.Replace(",]", "]");
            }

            //Se retorna la cadena generada
            return listaPorcentajesAceptacionJSON.ToString();
        }
        #endregion Métodos Públicos

    }//FIN
}//FIN
