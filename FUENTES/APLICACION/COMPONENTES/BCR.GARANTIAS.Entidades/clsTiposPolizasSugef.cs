using System;
using System.Collections.Generic;
using System.Collections;
using System.Xml;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsTiposPolizasSugef<T> : CollectionBase
        where T : clsTipoPolizaSugef
    {
        #region Constantes

        private const string _tagDetalle    = "DETALLE";
        private const string _tagDato       = "DATO";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaDatos;

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
        public string TramaDatos
        {
            get { return tramaDatos; }
            set { tramaDatos = value; }
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
        public clsTiposPolizasSugef()
        {
            tramaDatos = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaDatosBD">Trama que posee los datos de las relaciones entre el tipo de bien y los tipos de p�lizas obtenidas de la Base de Datos</param>
        public clsTiposPolizasSugef(string tramaDatosBD)
        {
            tramaDatos = string.Empty;

            if (tramaDatosBD.Length > 0)
            {
                XmlDocument xmlDatos = new XmlDocument();

                try
                {
                    xmlDatos.LoadXml(tramaDatosBD);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaTipoPolizaSugef, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaTipoPolizaSugefDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlDatos != null)
                {
                    tramaDatos = tramaDatosBD;

                    if (xmlDatos.HasChildNodes)
                    {
                        clsTipoPolizaSugef entidadTipoPolizaSugef;

                        foreach (XmlNode nodoTipoPolizaSugef in xmlDatos.SelectNodes("//" + _tagDetalle).Item(0).ChildNodes)
                        {
                            entidadTipoPolizaSugef = new clsTipoPolizaSugef(nodoTipoPolizaSugef.OuterXml);

                            if (entidadTipoPolizaSugef.ErrorDatos)
                            {
                                errorDatos = entidadTipoPolizaSugef.ErrorDatos;
                                descripcionError = entidadTipoPolizaSugef.DescripcionError;
                                break;
                            }
                            else
                            {
                                Agregar(entidadTipoPolizaSugef);
                            }
                        }
                    }
                }
            }
        }
        #endregion Constructores

        #region M�todos P�blicos

        /// <summary>
        /// Agrega una entidad del tipo de bien relacionado a la colecci�n
        /// </summary>
        /// <param name="TipoPolizaSugef">Entidad de TipoPolizaSugef que se agregar� a la colecci�n</param>
        public void Agregar(clsTipoPolizaSugef TipoPolizaSugef)
        {
            InnerList.Add(TipoPolizaSugef);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo de bien relacionado del a colecci�n
        /// </summary>
        /// <param name="indice">Posici�n de la entidad dentro de la colecci�n</param>
        public void Remover(int indice)
        {
            InnerList.RemoveAt(indice);
        }

        /// <summary>
        /// Obtiene una entidad del tipo de p�liza SUGEF espec�fica
        /// </summary>
        /// <param name="indice">Posici�n, dentro de la colecci�n, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo de p�liza SUGEF</returns>
        public clsTipoPolizaSugef Item(int indice)
        {
            return (clsTipoPolizaSugef)InnerList[indice];
        }

        /// <summary>
        /// Obtiene la lista de elementos del tipo de p�liza SUGEF especificado. 
        /// </summary>
        /// <param name="tipoPolizaSugef">Fecha del registro requerido</param>
        /// <returns>Lista de entidades del tipo de p�liza SUGEF</returns>
        public List<clsTipoPolizaSugef> Items(int tipoPolizaSugef)
        {
            List<clsTipoPolizaSugef> listaItems = new List<clsTipoPolizaSugef>();

            foreach (clsTipoPolizaSugef entidadTipoPolizaSugef in InnerList)
            {
                if (entidadTipoPolizaSugef.TipoPolizaSugef.ToString().CompareTo(tipoPolizaSugef.ToString()) == 0)
                {
                    listaItems.Add(entidadTipoPolizaSugef);
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsTipoPolizaSugef>("TipoPolizaSugef", clsComparadorGenerico<clsTipoPolizaSugef>.SortOrder.Ascending));

            return listaItems;
        }

        /// <summary>
        /// Obtiene la lista de elementos del tipo de p�liza SUGEF ordenados. 
        /// </summary>
        /// <returns>Lista de entidades del tipo de p�liza SUGEF ordenados</returns>
        public List<clsTipoPolizaSugef> ListaOrdenada()
        {
            List<clsTipoPolizaSugef> listaItems = new List<clsTipoPolizaSugef>();

            foreach (clsTipoPolizaSugef entidadTipoPolizaSugef in InnerList)
            {
                    listaItems.Add(entidadTipoPolizaSugef);
            }

            listaItems.Sort(new clsComparadorGenerico<clsTipoPolizaSugef>("TipoPolizaSugef", clsComparadorGenerico<clsTipoPolizaSugef>.SortOrder.Ascending));

            return listaItems;
        }
        #endregion M�todos P�blicos

    }
}

