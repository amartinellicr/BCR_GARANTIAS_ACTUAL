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
    public class clsCoberturas<T> : CollectionBase
        where T : clsCobertura
    {
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

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaCoberturas;

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
        public string TramaCoberturas
        {
            get { return tramaCoberturas; }
            set { tramaCoberturas = value; }
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
        /// Constructor base de la clase
        /// </summary>
        public clsCoberturas()
        {
            this.tramaCoberturas = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaCoberturasBD">Trama que posee los datos de las pólizas obtenidas de la Base de Datos</param>
        public clsCoberturas(string tramaCoberturasBD)
        {
            this.tramaCoberturas = string.Empty;

            if (tramaCoberturasBD.Length > 0)
            {
                XmlDocument xmlCoberturas = new XmlDocument();
                XmlNodeList xmlCoberturasPorAsignar = null;
                XmlNodeList xmlCoberturasAsignadas = null;

                try
                {
                    xmlCoberturas.LoadXml(tramaCoberturasBD);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaCoberturaPolizaSap, "completas", Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaCoberturaPolizaSapDetalle, "completas", desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }


                try
                {
                    if (xmlCoberturas.SelectSingleNode("//" + _tagCoberturasPorAsignar) != null)
                    {
                        xmlCoberturasPorAsignar = xmlCoberturas.SelectSingleNode("//" + _tagCoberturasPorAsignar).ChildNodes;
                    }
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaCoberturaPolizaSap, "Indicadas por el Asegurador", Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaCoberturaPolizaSapDetalle, "Indicadas por el Asegurador", desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }


                try
                {
                    if (xmlCoberturas.SelectSingleNode("//" + _tagCoberturasAsignadas) != null)
                    {
                        xmlCoberturasAsignadas = xmlCoberturas.SelectSingleNode("//" + _tagCoberturasAsignadas).ChildNodes;
                    }
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaCoberturaPolizaSap, "Respaldada por el Bien", Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaCoberturaPolizaSapDetalle, "Respaldada por el Bien", desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }


                if (xmlCoberturas != null)
                {
                    this.tramaCoberturas = tramaCoberturasBD;

                    if (xmlCoberturas.HasChildNodes)
                    {
                        clsCobertura entidadCobertura;

                        if (xmlCoberturasPorAsignar != null)
                        {
                            foreach (XmlNode nodoCobertura in xmlCoberturasPorAsignar)
                            {
                                entidadCobertura = new clsCobertura(nodoCobertura.OuterXml, Enumeradores.Tipos_Trama_Cobertura.PorAsignar);

                                if (entidadCobertura.ErrorDatos)
                                {
                                    this.errorDatos = entidadCobertura.ErrorDatos;
                                    this.descripcionError = entidadCobertura.DescripcionError;
                                    break;
                                }
                                else
                                {
                                    this.Agregar(entidadCobertura);
                                }
                            }
                        }

                        if (xmlCoberturasAsignadas != null)
                        {
                            foreach (XmlNode nodoCobertura in xmlCoberturasAsignadas)
                            {
                                entidadCobertura = new clsCobertura(nodoCobertura.OuterXml, Enumeradores.Tipos_Trama_Cobertura.Asignada);

                                if (entidadCobertura.ErrorDatos)
                                {
                                    this.errorDatos = entidadCobertura.ErrorDatos;
                                    this.descripcionError = entidadCobertura.DescripcionError;
                                    break;
                                }
                                else
                                {
                                    this.Agregar(entidadCobertura);
                                }
                            }
                        }
                    }
                }
            }
        }
        #endregion Constructores

        #region Métodos Públicos

        /// <summary>
        /// Agrega una entidad del tipo cobertura a la colección
        /// </summary>
        /// <param name="poliza">Entidad Cobertura que se agregará a la colección</param>
        public void Agregar(clsCobertura cobertura)
        {
            InnerList.Add(cobertura);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo cobertura de la colección
        /// </summary>
        /// <param name="indice">Posición de la entidad dentro de la colección</param>
        public void Remover(int indice)
        {
            InnerList.RemoveAt(indice);
        }

        /// <summary>
        /// Obtiene una entidad del tipo cobertura específica
        /// </summary>
        /// <param name="indice">Posición, dentro de la colección, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo cobertura</returns>
        public clsCobertura Item(int indice)
        {
            return (clsCobertura)InnerList[indice];
        }

        /// <summary>
        /// Obtiene la lista de elementos del tipo de lista especificado. 
        /// </summary>
        /// <param name="tipoListaCobertura">Código del tipo de lista de las coberturas requeridas</param>
        /// <returns>Lista de entidades del tipo cobertura</returns>
        public List<clsCobertura> Items(Enumeradores.Tipos_Trama_Cobertura tipoListaCobertura)
        {
            List<clsCobertura> listaItems = new List<clsCobertura>();

            if (tipoListaCobertura == Enumeradores.Tipos_Trama_Cobertura.Ninguna)
            {
                foreach (clsCobertura entidadCobertura in InnerList)
                {
                    listaItems.Add(entidadCobertura);
                }
            }
            else
            {
                foreach (clsCobertura entidadCobertura in InnerList)
                {
                    if (entidadCobertura.TipoListaCobertura == tipoListaCobertura)
                    {
                        listaItems.Add(entidadCobertura);
                    }
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsCobertura>("CodigoCobertura", clsComparadorGenerico<clsCobertura>.SortOrder.Ascending));

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
            objEscritor.WriteStartElement(_tagCoberturas);

            if (InnerList.Count > 0)
            {

                List<clsCobertura> listaCoberturasPorAsignar = this.Items(Enumeradores.Tipos_Trama_Cobertura.PorAsignar);
                List<clsCobertura> listaCoberturasAsignadas = this.Items(Enumeradores.Tipos_Trama_Cobertura.Asignada);

                //Se genera el nodo de las coberturas por asignar
                if (listaCoberturasPorAsignar.Count > 0)
                {
                    objEscritor.WriteStartElement(_tagCoberturasPorAsignar);

                    foreach (clsCobertura cobertura in listaCoberturasPorAsignar)
                    {

                        objEscritor.WriteStartElement(_tagCobertura);

                        //Crea el nodo del código de la cobertura
                        objEscritor.WriteStartElement(_codCobertura);
                        objEscritor.WriteString(cobertura.CodigoCobertura.ToString());
                        objEscritor.WriteEndElement();

                        //Crea el nodo de la descripción de la cobertura
                        objEscritor.WriteStartElement(_descripcionCobertura);
                        objEscritor.WriteString(cobertura.DescripcionCobertura);
                        objEscritor.WriteEndElement();

                        //Crea el nodo de la descripción corta de la cobertura
                        objEscritor.WriteStartElement(_descripcionCortaCobertura);
                        objEscritor.WriteString(cobertura.DescripcionCortaCobertura);
                        objEscritor.WriteEndElement();
                                               
                        //Crea el nodo del indicador de que la cobertura es obligatoria o no
                        objEscritor.WriteStartElement(_indicadorObligatoria);
                        objEscritor.WriteString(((cobertura.IndicadorObligatoria) ? "1" : "0"));
                        objEscritor.WriteEndElement();                     

                        //Final del tag COBERTURA
                        objEscritor.WriteEndElement();
                    }

                    //Final del tag POR_ASIGNAR
                    objEscritor.WriteEndElement();
                }

                //Se genera el nodo de las coberturas asignadas
                if (listaCoberturasAsignadas.Count > 0)
                {
                    objEscritor.WriteStartElement(_tagCoberturasAsignadas);

                    foreach (clsCobertura cobertura in listaCoberturasAsignadas)
                    {

                        objEscritor.WriteStartElement(_tagCobertura);

                        //Crea el nodo del código de la cobertura
                        objEscritor.WriteStartElement(_codCobertura);
                        objEscritor.WriteString(cobertura.CodigoCobertura.ToString());
                        objEscritor.WriteEndElement();

                        //Crea el nodo de la descripción de la cobertura
                        objEscritor.WriteStartElement(_descripcionCobertura);
                        objEscritor.WriteString(cobertura.DescripcionCobertura);
                        objEscritor.WriteEndElement();

                        //Crea el nodo de la descripción corta de la cobertura
                        objEscritor.WriteStartElement(_descripcionCortaCobertura);
                        objEscritor.WriteString(cobertura.DescripcionCortaCobertura);
                        objEscritor.WriteEndElement();

                        //Crea el nodo del indicador de que la cobertura es obligatoria o no
                        objEscritor.WriteStartElement(_indicadorObligatoria);
                        objEscritor.WriteString(((cobertura.IndicadorObligatoria) ? "1" : "0"));
                        objEscritor.WriteEndElement();

                        //Final del tag COBERTURA
                        objEscritor.WriteEndElement();
                    }

                    //Final del tag ASIGNADAS
                    objEscritor.WriteEndElement();
                }
            }

            //Final del tag COBERTURAS
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
        /// <returns>Cadena con las coberturas de la lista, en formato JSON</returns>
        public string ObtenerJSON()
        {
            StringBuilder  listaCoberturasJSON = new StringBuilder();

            //Se revisa que la lista posea coberturas
            if (this.InnerList.Count > 0)
            {
                //Se agrega la llave de inicio
                 listaCoberturasJSON.Append("[");

                //Se recorren las coberturas y se genera la cedena JSON de cada uno
                 foreach (clsCobertura convertirCobertura in this.InnerList)
                 {
                     listaCoberturasJSON.Append(convertirCobertura.ConvertirJSON());
                     listaCoberturasJSON.Append(",");
                 }

                //Se agrega la llave final
                 listaCoberturasJSON.Append("]");

                //Se elimina la coma (,) final
                 listaCoberturasJSON.Replace(",]", "]");
            }

            //Se retorna la cadena generada
            return  listaCoberturasJSON.ToString();
        }

        /// <summary>
        /// Obtiene la diferencia entre las coberturas por asignar obligatorias y las coberturas obligatorias asignadas
        /// </summary>
        /// <returns>Diferencia encontrada, si es igual a cero es que no existe diferencia</returns>
        public int ObtenerDiferenciaCoberturasObligatorias()
        {
            int diferenciaCoberturasObligatorias = 0;
            int cantidadCPAObligatorias = 0;
            int cantidadCAObligatorias = 0;

            foreach (clsCobertura entidadCobertura in InnerList)
            {
                if ((entidadCobertura.TipoListaCobertura == Enumeradores.Tipos_Trama_Cobertura.PorAsignar) && (entidadCobertura.IndicadorObligatoria))
                {
                    cantidadCPAObligatorias += 1;
                }
                else if ((entidadCobertura.TipoListaCobertura == Enumeradores.Tipos_Trama_Cobertura.Asignada) && (entidadCobertura.IndicadorObligatoria))
                {
                    cantidadCAObligatorias += 1;
                }
            }

            diferenciaCoberturasObligatorias = cantidadCPAObligatorias - cantidadCAObligatorias;

            return diferenciaCoberturasObligatorias;
        }
        #endregion Métodos Públicos
    }
}
