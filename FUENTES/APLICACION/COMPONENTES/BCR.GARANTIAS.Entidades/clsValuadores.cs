using System;
using System.Collections.Generic;
using System.Collections;
using System.Xml;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsValuadores<T> : CollectionBase
        where T : clsValuador
    {
        #region Constantes

        private const string _tagValuadores = "VALUADORES";
        private const string _tagValuador = "VALUADOR";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaValuador;

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
        public string TramaValuador
        {
            get { return tramaValuador; }
            set { tramaValuador = value; }
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
        public clsValuadores()
        {
            tramaValuador = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaValuadores">Trama que posee los datos de los valuadores obtenidos de la Base de Datos</param>
        /// <param name="listaTipoValuador">Tipo de valuador sobre el que se desea extraer la información</param>
        public clsValuadores(string tramaValuadores, Enumeradores.TiposValuadores listaTipoValuador)
        {
            tramaValuador = string.Empty;

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

            if (tramaValuadores.Length > 0)
            {
                XmlDocument xmlValuadores = new XmlDocument();

                try
                {
                    xmlValuadores.LoadXml(tramaValuadores);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaListaValuadores, tipoValuador, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaListaValuadoresDetalle, tipoValuador, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    return;
                }

                if (xmlValuadores != null)
                {
                    tramaValuador = tramaValuadores;

                    if (xmlValuadores.HasChildNodes)
                    {
                        clsValuador entidadValuador;

                        foreach (XmlNode nodoValuador in xmlValuadores.SelectNodes("//" + _tagValuadores).Item(0).ChildNodes)
                        {
                            entidadValuador = new clsValuador(nodoValuador.OuterXml, listaTipoValuador);

                            if (entidadValuador.ErrorDatos)
                            {
                                errorDatos = entidadValuador.ErrorDatos;
                                descripcionError = entidadValuador.DescripcionError;
                                break;
                            }
                            else
                            {
                                Agregar(entidadValuador);
                            }
                        }
                    }
                }
            }
        }
        #endregion Constructores

        #region Métodos Públicos

        /// <summary>
        /// Agrega una entidad del tipo valuador a la colección
        /// </summary>
        /// <param name="CapacidadPago">Entidad de Valuador que se agregará a la colección</param>
        public void Agregar(clsValuador Valuador)
        {
            InnerList.Add(Valuador);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo valaudor del a colección
        /// </summary>
        /// <param name="indece">Posición de la entidad dentro de la colección</param>
        public void Remover(int indece)
        {
            InnerList.RemoveAt(indece);
        }

        /// <summary>
        /// Obtiene una entidad del tipo valuador específica
        /// </summary>
        /// <param name="indice">Posición, dentro de la colección, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo valuador</returns>
        public clsValuador Item(int indice)
        {
            return (clsValuador)InnerList[indice];
        }

        /// <summary>
        /// Obtiene la lista completa de todos los valuadores
        /// </summary>
        /// <returns>La lista de todos los valuadores</returns>
        public List<clsValuador> Items()
        {
            List<clsValuador> listaValuadores = new List<clsValuador>();

            foreach (clsValuador valuador in InnerList)
            {
                listaValuadores.Add(valuador);
            }

            listaValuadores.Sort(delegate(clsValuador valuador1, clsValuador valuador2)
              {
                  return valuador1.CedulaValuador.CompareTo(valuador2.CedulaValuador);
              });

            return listaValuadores;
        }


        /// <summary>
        /// Obtiene la lista de elementos del valaudor especificado. 
        /// </summary>
        /// <param name="codValuador">Identificación del valuador requerido</param>
        /// <returns>Datos del valuador solicitado, de no encontrase el valuador se retorna nulo</returns>
        public clsValuador ItemValuador(string codValuador)
        {
            clsValuador valuador = new clsValuador();

            InnerList.Sort();

            int indiceValuador = InnerList.BinarySearch(codValuador);

            if (indiceValuador < 0)
            {
                valuador = null;
            }
            else
            {
                valuador = (clsValuador)InnerList[indiceValuador];
            }

            return valuador;
        }

        #endregion Métodos Públicos
   }
}
