using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Xml;
using System.Diagnostics;
using System.IO;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsSemestres<T> : CollectionBase
        where T : clsSemestre
    {
        #region Constantes

        private const string _tagSemestresACalcular = "SEMESTRES_A_CALCULAR";
        private const string _tagSemestre = "SEMESTRE";

        //Tags refernetes a los semestres a evaluar
        private const string _numeroSemestre = "Numero_Semestre";
        private const string _fechaSemestre = "Fecha_Semestre";
        private const string _tipoCambio = "Tipo_Cambio";
        private const string _ipc = "IPC";
        private const string _tipoCambioAnterior = "Tipo_Cambio_Anterior";
        private const string _ipcAnterior = "IPC_Anterior";
        private const string _totalRegistros = "Total_Registros";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaSemestres;

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
        public string TramaSemestres
        {
            get { return tramaSemestres; }
            set { tramaSemestres = value; }
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
        public clsSemestres()
        {
            tramaSemestres = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaSemestres">Trama que posee los datos de los semestres obtenidos de la Base de Datos</param>
        public clsSemestres(string tramaSemestres, bool esFormatoJSON)
        {
            this.tramaSemestres = string.Empty;

            if (tramaSemestres.Length > 0)
            {
                if (!esFormatoJSON)
                {
                    XmlDocument xmlIndices = new XmlDocument();

                    try
                    {
                        xmlIndices.LoadXml(tramaSemestres);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes._errorCargaSemestreActAvaluos, Mensajes.ASSEMBLY);

                        string desError = "Error al cargar la trama: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaSemestreActAvaluosDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }

                    if (xmlIndices != null)
                    {
                        this.tramaSemestres = tramaSemestres;

                        if (xmlIndices.HasChildNodes)
                        {
                            clsSemestre entidadSemestre;

                            foreach (XmlNode nodoSemestre in xmlIndices.SelectNodes("//" + _tagSemestresACalcular).Item(0).ChildNodes)
                            {
                                entidadSemestre = new clsSemestre(nodoSemestre.OuterXml, false);

                                if (entidadSemestre.ErrorDatos)
                                {
                                    errorDatos = entidadSemestre.ErrorDatos;
                                    descripcionError = entidadSemestre.DescripcionError;
                                    break;
                                }
                                else
                                {
                                    Agregar(entidadSemestre);
                                }
                            }
                        }
                    }
                }
                else
                {
                    CargarJSON(tramaSemestres);
                }
            }
        }
        #endregion Constructores

        #region Métodos Públicos

        /// <summary>
        /// Agrega una entidad del tipo semestre a la colección
        /// </summary>
        /// <param name="SemestreActAvaluo">Entidad de Semestre que se agregará a la colección</param>
        public void Agregar(clsSemestre SemestreActAvaluo)
        {
            InnerList.Add(SemestreActAvaluo);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo semestre de la colección
        /// </summary>
        /// <param name="indice">Posición de la entidad dentro de la colección</param>
        public void Remover(int indice)
        {
            InnerList.RemoveAt(indice);
        }

        /// <summary>
        /// Obtiene una entidad del tipo semestre específica
        /// </summary>
        /// <param name="indice">Posición, dentro de la colección, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo Semestre</returns>
        public clsSemestre Item(int indice)
        {
            return (clsSemestre)InnerList[indice];
        }

        /// <summary>
        /// Obtiene la lista de elementos del Semestre especificado. 
        /// </summary>
        /// <param name="fechaRegistro">Fecha del registro requerido</param>
        /// <returns>Lista de entidades del tipo Semestre</returns>
        public List<clsSemestre> Items(DateTime fechaRegistro)
        {
            List<clsSemestre> listaItems = new List<clsSemestre>();

            foreach (clsSemestre entidadSemestreAct in InnerList)
            {
                if (entidadSemestreAct.FechaSemestre.ToShortDateString().CompareTo(fechaRegistro.ToShortDateString()) == 0)
                {
                    listaItems.Add(entidadSemestreAct);
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsSemestre>("IDElemento", clsComparadorGenerico<clsSemestre>.SortOrder.Ascending));

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

            //Inicializa el nodo que poseerá los datos de lo semestres a calcular
            objEscritor.WriteStartElement(_tagSemestresACalcular);

            if (InnerList.Count > 0)
            {
                foreach (clsSemestre semestre in InnerList)
                {
                    objEscritor.WriteStartElement(_tagSemestre);

                    //Crea el nodo del consecutivo del registro
                    objEscritor.WriteStartElement(_numeroSemestre);
                    objEscritor.WriteString(semestre.NumeroSemestre.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha del semestre evaluado
                    objEscritor.WriteStartElement(_fechaSemestre);
                    objEscritor.WriteString(semestre.FechaSemestre.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del tipo de cambio
                    objEscritor.WriteStartElement(_tipoCambio);
                    objEscritor.WriteString(((semestre.TipoCambio.HasValue) ? semestre.TipoCambio.ToString() : string.Empty));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del índice de precios al consumidor
                    objEscritor.WriteStartElement(_ipc);
                    objEscritor.WriteString(((semestre.IPC.HasValue) ? semestre.IPC.ToString() : string.Empty));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del tipo de cambio anterior
                    objEscritor.WriteStartElement(_tipoCambioAnterior);
                    objEscritor.WriteString(((semestre.TipoCambioAnterior.HasValue) ? semestre.TipoCambioAnterior.ToString() : string.Empty));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del índice de precios al consumidor anterior
                    objEscritor.WriteStartElement(_ipcAnterior);
                    objEscritor.WriteString(((semestre.IPCAnterior.HasValue) ? semestre.IPCAnterior.ToString() : string.Empty));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del total de semestres trabajados
                    objEscritor.WriteStartElement(_totalRegistros);
                    objEscritor.WriteString(semestre.TotalRegistros.ToString());
                    objEscritor.WriteEndElement();

                    //Final del tag SEMESTRE
                    objEscritor.WriteEndElement();
                }
            }

            //Final del tag SEMESTRES_A_CALCULAR
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
        /// <returns>Cadena con los semetres de la lista, en formato JSON</returns>
        public string ObtenerJSON()
        {
            StringBuilder listaSemetresJSON = new StringBuilder();

            //Se revisa que la lista posea semestres
            if (InnerList.Count > 0)
            {
                //Se agrega la llave de inicio
                listaSemetresJSON.Append("{");

                //Se recorren los semestres y se genera la cedena JSON de cada uno
                foreach (clsSemestre convertirSemestre in InnerList)
                {
                    listaSemetresJSON.Append(convertirSemestre.ConvertirJSON());
                    listaSemetresJSON.Append(",");
                }
                
                //Se agrega la llave final
                listaSemetresJSON.Append("}");

                //Se elimina la coma (,) final
                listaSemetresJSON.Replace(",}", "}");
            }

            //Se retorna la cadena generada
            return listaSemetresJSON.ToString();
        }

        

        #endregion Métodos Públicos

        #region Métodos Privados

        /// <summary>
        /// Método que permite cargar una cadena en formato JSON a la lista de semestres
        /// </summary>
        /// <param name="cadenaJSON">Cadena JSON con los semestres a cargar</param>
        private void CargarJSON(string cadenaJSON)
        {
            clsSemestre semestreAgregar = null;

            //Se revisa que la cadena posea caracteres
            if (cadenaJSON.Length > 0)
            {
                //Se eliminan la llave inicial y final de la cadena
                cadenaJSON = cadenaJSON.Replace("{{", "{").Replace("}}", "}");

                StringBuilder cadenaSemestre = new StringBuilder();

                //Se recorre la cadena caracter por caracter
                for (int indiceCaracter = 0; indiceCaracter < cadenaJSON.Length; indiceCaracter++)
                {
                    cadenaSemestre.Append(cadenaJSON[indiceCaracter]);

                    //Se verifica que si la llave es de cierre indica que ya se obtuvo el equivalente a un semestre
                    if (cadenaJSON[indiceCaracter] == '}')
                    {
                        //Se carga el semestre obtenido
                        semestreAgregar = new clsSemestre(cadenaSemestre.ToString(), true);

                        if (semestreAgregar != null)
                        {
                            //Se agrega a la lista el semestre generado
                            Agregar(semestreAgregar);
                        }

                        //Se reincia la cadena de texto que permite obtener cada semestre
                        cadenaSemestre = new StringBuilder();
                    }
                }
            }
        }

        #endregion Métodos Privados

    }
}
