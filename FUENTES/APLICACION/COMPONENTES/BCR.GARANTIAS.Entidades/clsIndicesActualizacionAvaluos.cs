using System;
using System.Collections.Generic;
using System.Collections;
using System.Xml;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsIndicesActualizacionAvaluos<T> : CollectionBase
        where T : clsIndiceActualizacionAvaluo
    {
        #region Constantes

        private const string _tagIndices = "INDICES";
        private const string _tagIndice = "INDICE";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaIndices;

        /// <summary>
        /// Indicador de que se present� un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripci�n del error detectado
        /// </summary>
        private string descripcionError;

        #endregion Variables

        #region Propiedades

        /// <summary>
        /// Obtiene o establece la trama de respuesta obtenida de la consulta realizada a la Base de Datos
        /// </summary>
        public string TramaIndices
        {
            get { return tramaIndices; }
            set { tramaIndices = value; }
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
	
        #endregion Propiedades

        #region Construtores

        /// <summary>
        /// Constructor base del a clase
        /// </summary>
        public clsIndicesActualizacionAvaluos()
        {
            tramaIndices = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaIndicesBD">Trama que posee los datos del os cat�logos obtenidos de la Base de Datos</param>
        public clsIndicesActualizacionAvaluos(string tramaIndicesBD)
        {
            tramaIndices = string.Empty;

            if (tramaIndicesBD.Length > 0)
            {
                XmlDocument xmlIndices = new XmlDocument();

                try
                {
                    xmlIndices.LoadXml(tramaIndicesBD);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluos, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluosDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlIndices != null)
                {
                    tramaIndices = tramaIndicesBD;

                    if (xmlIndices.HasChildNodes)
                    {
                        clsIndiceActualizacionAvaluo entidadIndiceActAvaluos;

                        foreach (XmlNode nodoIndice in xmlIndices.SelectNodes("//" + _tagIndices).Item(0).ChildNodes)
                        {
                            entidadIndiceActAvaluos = new clsIndiceActualizacionAvaluo(nodoIndice.OuterXml);

                            if (entidadIndiceActAvaluos.ErrorDatos)
                            {
                                errorDatos = entidadIndiceActAvaluos.ErrorDatos;
                                descripcionError = entidadIndiceActAvaluos.DescripcionError;
                                break;
                            }
                            else
                            {
                                Agregar(entidadIndiceActAvaluos);
                            }
                        }
                    }
                }
            }
        }
        #endregion Constructores

        #region M�todos P�blicos

        /// <summary>
        /// Agrega una entidad del tipo �ndice de actualizaci�n de aval�os a la colecci�n
        /// </summary>
        /// <param name="IndiceActAvaluo">Entidad de IndiceActualizacionAvaluo que se agregar� a la colecci�n</param>
        public void Agregar(clsIndiceActualizacionAvaluo IndiceActAvaluo)
        {
            InnerList.Add(IndiceActAvaluo);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo �ndice de actualizaci�n de aval�os del a colecci�n
        /// </summary>
        /// <param name="indice">Posici�n de la entidad dentro de la colecci�n</param>
        public void Remover(int indice)
        {
            InnerList.RemoveAt(indice);
        }

        /// <summary>
        /// Obtiene una entidad del tipo �ndice de actualizaci�n de aval�os espec�fica
        /// </summary>
        /// <param name="indice">Posici�n, dentro de la colecci�n, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo �ndice de actualizaci�n de aval�os</returns>
        public clsIndiceActualizacionAvaluo Item(int indice)
        {
            return (clsIndiceActualizacionAvaluo)InnerList[indice];
        }

        /// <summary>
        /// Obtiene la lista de elementos del �ndice de actualizaci�n de aval�os especificado. 
        /// </summary>
        /// <param name="fechaRegistro">Fecha del registro requerido</param>
        /// <returns>Lista de entidades del tipo �ndice de actualizaci�n de aval�os</returns>
        public List<clsIndiceActualizacionAvaluo> Items(DateTime fechaRegistro)
        {
            List<clsIndiceActualizacionAvaluo> listaItems = new List<clsIndiceActualizacionAvaluo>();

            foreach (clsIndiceActualizacionAvaluo entidadIndiceActuAvaluo in InnerList)
            {
                if (entidadIndiceActuAvaluo.FechaHora.ToShortDateString().CompareTo(fechaRegistro.ToShortDateString()) == 0)
                {
                    listaItems.Add(entidadIndiceActuAvaluo);
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsIndiceActualizacionAvaluo>("IDElemento", clsComparadorGenerico<clsIndiceActualizacionAvaluo>.SortOrder.Ascending));

            return listaItems;
        }

        #endregion M�todos P�blicos

    }
}
