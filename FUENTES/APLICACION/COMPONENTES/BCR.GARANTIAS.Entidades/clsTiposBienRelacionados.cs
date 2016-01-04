using System;
using System.Collections.Generic;
using System.Collections;
using System.Xml;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsTiposBienRelacionados<T> : CollectionBase
        where T : clsTipoBienRelacionado
    {
        #region Constantes

        private const string _tagRelaciones = "RELACIONES";
        private const string _tagRelacion   = "RELACION";

        //Mensajes que se presentarn según la inconsistencia encontrada
       // private const string _mensajeRegistroDuplicado = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeDuplicadoTipoPolizaBienRelacionado) !== 'undefined'){$MensajeDuplicadoTipoPolizaBienRelacionado.dialog('open');} </script>";
        private const string _mensajeRegistroDuplicado = "<script type=\"text/javascript\" language=\"javascript\">MensajeTipoBienRelacionadoDuplicado();</script>";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaRelaciones;

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
        public string TramaRelaciones
        {
            get { return tramaRelaciones; }
            set { tramaRelaciones = value; }
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
        public clsTiposBienRelacionados()
        {
            tramaRelaciones = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaRelacionesBD">Trama que posee los datos de las relaciones entre el tipo de bien y los tipos de pólizas obtenidas de la Base de Datos</param>
        public clsTiposBienRelacionados(string tramaRelacionesBD)
        {
            tramaRelaciones = string.Empty;

            if (tramaRelacionesBD.Length > 0)
            {
                XmlDocument xmlRelaciones = new XmlDocument();

                try
                {
                    xmlRelaciones.LoadXml(tramaRelacionesBD);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaTipoBienRelacionado, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaTipoBienRelacionadDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlRelaciones != null)
                {
                    tramaRelaciones = tramaRelacionesBD;

                    if (xmlRelaciones.HasChildNodes)
                    {
                        clsTipoBienRelacionado entidadTipoBienRelacionado;

                        foreach (XmlNode nodoRelacion in xmlRelaciones.SelectNodes("//" + _tagRelaciones).Item(0).ChildNodes)
                        {
                            entidadTipoBienRelacionado = new clsTipoBienRelacionado(nodoRelacion.OuterXml);

                            if (entidadTipoBienRelacionado.ErrorDatos)
                            {
                                errorDatos = entidadTipoBienRelacionado.ErrorDatos;
                                descripcionError = entidadTipoBienRelacionado.DescripcionError;
                                break;
                            }
                            else
                            {
                                Agregar(entidadTipoBienRelacionado);
                            }
                        }
                    }
                }
            }
        }
        #endregion Constructores

        #region Métodos Públicos

        /// <summary>
        /// Agrega una entidad del tipo de bien relacionado a la colección
        /// </summary>
        /// <param name="TipoBienRelacionado">Entidad de TipoBienRelacionado que se agregará a la colección</param>
        public void Agregar(clsTipoBienRelacionado TipoBienRelacionado)
        {
            InnerList.Add(TipoBienRelacionado);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo de bien relacionado del a colección
        /// </summary>
        /// <param name="indice">Posición de la entidad dentro de la colección</param>
        public void Remover(int indice)
        {
            InnerList.RemoveAt(indice);
        }

        /// <summary>
        /// Obtiene una entidad del tipo de bien relacionado específica
        /// </summary>
        /// <param name="indice">Posición, dentro de la colección, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo de bien relacionado</returns>
        public clsTipoBienRelacionado Item(int indice)
        {
            return (clsTipoBienRelacionado)InnerList[indice];
        }

        /// <summary>
        /// Obtiene la lista de elementos del tipo de bien relacionado especificado. 
        /// </summary>
        /// <param name="tipoBien">Fecha del registro requerido</param>
        /// <returns>Lista de entidades del tipo de bien relacionado</returns>
        public List<clsTipoBienRelacionado> Items(int tipoBien)
        {
            List<clsTipoBienRelacionado> listaItems = new List<clsTipoBienRelacionado>();

            foreach (clsTipoBienRelacionado entidadTipoBienRelacionado in InnerList)
            {
                if (entidadTipoBienRelacionado.TipoBien.ToString().CompareTo(tipoBien.ToString()) == 0)
                {
                    listaItems.Add(entidadTipoBienRelacionado);
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsTipoBienRelacionado>("ConsecutivoRelacion", clsComparadorGenerico<clsTipoBienRelacionado>.SortOrder.Ascending));

            return listaItems;
        }

        /// <summary>
        /// Obtiene la lista de tipos de póliza SAP. 
        /// </summary>
        /// <returns>Lista de códigos del tipo de póliza SAP</returns>
        public List<int> ListaTipoPolizaSap()
        {
            List<int> listaItems = new List<int>();

            foreach (clsTipoBienRelacionado entidadTipoBienRelacionado in InnerList)
            {
                    listaItems.Add(entidadTipoBienRelacionado.TipoPolizaSap);
            }

            return listaItems;
        }
        #endregion Métodos Públicos

    }
}
