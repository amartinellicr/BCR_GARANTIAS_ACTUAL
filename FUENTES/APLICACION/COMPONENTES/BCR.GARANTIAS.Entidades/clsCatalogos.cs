using System;
using System.Collections.Generic;
using System.Collections;
using System.Xml;
using System.Diagnostics;
using System.Text;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsCatalogos<T> : CollectionBase
        where T : clsCatalogo
    {

        #region Constantes

        private const string _tagCatalogos = "CATALOGOS";
        private const string _tagCatalogo = "CATALAGO";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaCatalogo;

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
        public string TramaCatalogo
        {
            get { return tramaCatalogo; }
            set { tramaCatalogo = value; }
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
        public clsCatalogos()
        {
            tramaCatalogo = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaCatalogos">Trama que posee los datos del os cat�logos obtenidos de la Base de Datos</param>
        public clsCatalogos(string tramaCatalogos)
        {
            tramaCatalogo = string.Empty;

            if (tramaCatalogos.Length > 0)
            {
                XmlDocument xmlCatalogos = new XmlDocument();

                try
                {
                    xmlCatalogos.LoadXml(tramaCatalogos);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS_DETALLE, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlCatalogos != null)
                {
                    tramaCatalogo = tramaCatalogos;

                    if (xmlCatalogos.HasChildNodes)
                    {
                        clsCatalogo entidadCatalogo;

                        foreach (XmlNode nodoCatalogo in xmlCatalogos.SelectNodes("//" + _tagCatalogos).Item(0).ChildNodes)
                        {
                            entidadCatalogo = new clsCatalogo(nodoCatalogo.OuterXml);

                            if (entidadCatalogo.ErrorDatos)
                            {
                                errorDatos = entidadCatalogo.ErrorDatos;
                                descripcionError = entidadCatalogo.DescripcionError;
                                break;
                            }
                            else
                            {
                                Agregar(entidadCatalogo);
                            }
                        }
                    }
                }
            }
        }
        #endregion Constructores

        #region M�todos P�blicos

        /// <summary>
        /// Agrega una entidad del tipo cat�logo a la colecci�n
        /// </summary>
        /// <param name="CapacidadPago">Entidad de Cat�logo que se agregar� a la colecci�n</param>
        public void Agregar(clsCatalogo Catalogo)
        {
            InnerList.Add(Catalogo);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo cat�logo del a colecci�n
        /// </summary>
        /// <param name="indece">Posici�n de la entidad dentro de la colecci�n</param>
        public void Remover(int indece)
        {
            InnerList.RemoveAt(indece);
        }

        /// <summary>
        /// Obtiene una entidad del tipo cat�logo espec�fica
        /// </summary>
        /// <param name="indece">Posici�n, dentro de la colecci�n, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo cat�logo</returns>
        public clsCatalogo Item(int indece)
        {
            return (clsCatalogo)InnerList[indece];
        }

        /// <summary>
        /// Obtiene la lista de elementos del cat�logo especificado. 
        /// </summary>
        /// <param name="codCatalogo">C�digo del cat�logo requerido</param>
        /// <returns>Lista de entidades del tipo Cat�logo</returns>
        public List<clsCatalogo> Items(int codCatalogo)
        {
            List<clsCatalogo> listaItems = new List<clsCatalogo>();

            foreach (clsCatalogo entidadCatalogo in InnerList)
            {
                if (entidadCatalogo.CodigoCatalogo == codCatalogo)
                {
                    listaItems.Add(entidadCatalogo);
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsCatalogo>("IDElemento", clsComparadorGenerico<clsCatalogo>.SortOrder.Ascending));

            return listaItems;
        }

        /// <summary>
        /// Convierte la lista de elementos en una cadena JSON
        /// </summary>
        public string ObtenerJSON()
        {
            StringBuilder listaRegistrosJSON = new StringBuilder();

            List<clsCatalogo> listaItems = new List<clsCatalogo>();

            foreach (clsCatalogo entidadCatalogo in InnerList)
            {
                listaItems.Add(entidadCatalogo);
            }

            listaItems.Sort(new clsComparadorGenerico<clsCatalogo>("IDElemento", clsComparadorGenerico<clsCatalogo>.SortOrder.Ascending));

           

            //Se revisa que la lista posea elementos
            if (listaItems.Count > 0)
            {
                //Se agrega la llave de inicio
                listaRegistrosJSON.Append("[");

                //Se recorren los elementos y se genera la cedena JSON de cada uno
                foreach (clsCatalogo convertirRegistro in listaItems)
                {
                       listaRegistrosJSON.Append(convertirRegistro.ConvertirJSON());
                       listaRegistrosJSON.Append(",");
                }

                //Se agrega la llave final
                listaRegistrosJSON.Append("]");

                //Se elimina la coma (,) final
                listaRegistrosJSON.Replace(",]", "]");
            }

            //Se retorna la cadena generada
            return listaRegistrosJSON.ToString();
        }

        #endregion M�todos P�blicos
    }
}
