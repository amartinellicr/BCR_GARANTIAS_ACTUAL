using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Xml;
using System.Data;
using System.Diagnostics;

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
        public string TramaCatalogo
        {
            get { return tramaCatalogo; }
            set { tramaCatalogo = value; }
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
        public clsCatalogos()
        {
            this.tramaCatalogo = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaCatalogos">Trama que posee los datos del os catálogos obtenidos de la Base de Datos</param>
        public clsCatalogos(string tramaCatalogos)
        {
            this.tramaCatalogo = string.Empty;

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
                    this.tramaCatalogo = tramaCatalogos;

                    if (xmlCatalogos.HasChildNodes)
                    {
                        clsCatalogo entidadCatalogo;

                        foreach (XmlNode nodoCatalogo in xmlCatalogos.SelectNodes("//" + _tagCatalogos).Item(0).ChildNodes)
                        {
                            entidadCatalogo = new clsCatalogo(nodoCatalogo.OuterXml);

                            if (entidadCatalogo.ErrorDatos)
                            {
                                this.errorDatos = entidadCatalogo.ErrorDatos;
                                this.descripcionError = entidadCatalogo.DescripcionError;
                                break;
                            }
                            else
                            {
                                this.Agregar(entidadCatalogo);
                            }
                        }
                    }
                }
            }
        }
        #endregion Constructores

        #region Métodos Públicos

        /// <summary>
        /// Agrega una entidad del tipo catálogo a la colección
        /// </summary>
        /// <param name="CapacidadPago">Entidad de Catálogo que se agregará a la colección</param>
        public void Agregar(clsCatalogo Catalogo)
        {
            InnerList.Add(Catalogo);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo catálogo del a colección
        /// </summary>
        /// <param name="indece">Posición de la entidad dentro de la colección</param>
        public void Remover(int indece)
        {
            InnerList.RemoveAt(indece);
        }

        /// <summary>
        /// Obtiene una entidad del tipo catálogo específica
        /// </summary>
        /// <param name="indece">Posición, dentro de la colección, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo catálogo</returns>
        public clsCatalogo Item(int indece)
        {
            return (clsCatalogo)InnerList[indece];
        }

        /// <summary>
        /// Obtiene la lista de elementos del catálogo especificado. 
        /// </summary>
        /// <param name="codCatalogo">Código del catálogo requerido</param>
        /// <returns>Lista de entidades del tipo Catálogo</returns>
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

        #endregion Métodos Públicos

    }
}
