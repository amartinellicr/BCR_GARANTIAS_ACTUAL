using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using System.Diagnostics;
using System.Xml;
using System.Data;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsHistoricosPorcentajesAceptacion<T> : CollectionBase
        where T : clsHistoricoPorcentajeAceptacion
    {

        #region Constantes

        private const string _codigoUsuario                     = "Codigo_Usuario";
        private const string _codigoAccion                      = "Codigo_Accion";
        private const string _codigoConsulta                    = "Codigo_Consulta";
        private const string _codigoTipoGarantia                = "Codigo_Tipo_Garantia";
        private const string _codigoTipoMitigador               = "Codigo_Tipo_Mitigador";
        private const string _descripcionCampoAfectado          = "Descripcion_Campo_Afectado";
        private const string _estadoAnteriorCampoAfectado       = "Estado_Anterior_Campo_Afectado";
        private const string _estadoActualCampoAfectado         = "Estado_Actual_Campo_Afectado";
        private const string _fechaHora                         = "Fecha_Hora";
        private const string _nombreUsuario                     = "NOMBRE_USUARIO";
        private const string _desTipoGarantia                   = "TIPO_GARANTIA";
        private const string _desTipoMitigador                  = "TIPO_MITIGADOR";
        private const string _desAccionRealizada                = "ACCION_REALIZADA";

        //Tags especiales
        private const string _tagHistorial = "HISTORIAL";
        private const string _tagDatos = "DATOS";

        #endregion

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaDatos;

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
        public string TramaDatos
        {
            get { return tramaDatos; }
            set { tramaDatos = value; }
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
        public clsHistoricosPorcentajesAceptacion()
        {
            this.tramaDatos = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaListaCambios">Trama que posee los datos de los porcentajes obtenidas de la Base de Datos</param>
        public clsHistoricosPorcentajesAceptacion(string tramaListaCambios)
        {
            this.tramaDatos = string.Empty;

            if (tramaListaCambios.Length > 0)
            {
                XmlDocument xmlCambioHistorico = new XmlDocument();

                try
                {
                    xmlCambioHistorico.LoadXml(tramaListaCambios);
                }
                catch (Exception ex)
                {
                    errorDatos = true;                   
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaGarantias, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaGarantiasDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
             

                    return;
                }

                if (xmlCambioHistorico != null)
                {
                    this.tramaDatos = tramaListaCambios;

                    if (xmlCambioHistorico.HasChildNodes)
                    {
                        clsHistoricoPorcentajeAceptacion entidadHistorico;

                        if (xmlCambioHistorico.SelectSingleNode("//" + _tagHistorial) != null)
                        {
                            foreach (XmlNode nodoHistorico in xmlCambioHistorico.SelectNodes("//" + _tagHistorial))
                            {
                                entidadHistorico = new clsHistoricoPorcentajeAceptacion(nodoHistorico.OuterXml);

                                if (entidadHistorico.ErrorDatos)
                                {
                                    this.errorDatos = entidadHistorico.ErrorDatos;
                                    this.descripcionError = entidadHistorico.DesError;
                                    break;
                                }
                                else
                                {
                                    this.Agregar(entidadHistorico);
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
        /// Agrega una entidad del tipo historicoPorcentajeAceptacion a la colección
        /// </summary>
        /// <param name="garantiaReal">Entidad del tipo bitacora que se agregará a la colección</param>
        public void Agregar(clsHistoricoPorcentajeAceptacion historicoPorcentaje)
        {
            InnerList.Add(historicoPorcentaje);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo historicoPorcentajeAceptacion  de la colección
        /// </summary>
        /// <param name="indece">Posición de la entidad dentro de la colección</param>
        public void Remover(int indece)
        {
            InnerList.RemoveAt(indece);
        }

        /// <summary>
        /// Obtiene una entidad del tipo bitacora específica
        /// </summary>
        /// <param name="indece">Posición, dentro de la colección, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo historicoPorcentajeAceptacion</returns>
        public clsHistoricoPorcentajeAceptacion Item(int indece)
        {
            return (clsHistoricoPorcentajeAceptacion)InnerList[indece];
        }


        /// <summary>
        /// Obtiene la lista completa de todos los los datos
        /// </summary>
        /// <returns>La lista de todos los valuadores</returns>
        public List<clsHistoricoPorcentajeAceptacion> Items()
        {
            List<clsHistoricoPorcentajeAceptacion> listaDatosHistorico = new List<clsHistoricoPorcentajeAceptacion>();

            foreach (clsHistoricoPorcentajeAceptacion historico in InnerList)
            {
                listaDatosHistorico.Add(historico);
            }       

            return listaDatosHistorico;
        }


        /// <summary>
        /// Permite convertir la entidad en un dataset
        /// </summary>
        /// <returns>DataSet que posee la información de la entidad</returns>
        public DataSet toDataSet()
        {
            //Se inicializan la variables locales
            DataSet dsHistorico = new DataSet();
            DataTable dtHistorico = new DataTable("Historico");

            #region Agregar columnas a la tabla

            DataColumn dcColumna = new DataColumn(_descripcionCampoAfectado, typeof(string));
            dtHistorico.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_estadoAnteriorCampoAfectado, typeof(string));
            dtHistorico.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_estadoAnteriorCampoAfectado, typeof(string));
            dtHistorico.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_fechaHora, typeof(DateTime));
            dtHistorico.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_codigoUsuario, typeof(string));
            dtHistorico.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_nombreUsuario, typeof(string));
            dtHistorico.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_desTipoGarantia, typeof(string));
            dtHistorico.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_desTipoMitigador, typeof(string));
            dtHistorico.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_desAccionRealizada, typeof(string));
            dtHistorico.Columns.Add(dcColumna);

            dtHistorico.AcceptChanges();

            #endregion Agregar columnas a la tabla

            //Se verifica que existan registros
            if (InnerList.Count > 0)
            {
                #region Agregar filas y datos a la tabla

                DataRow drFila = dtHistorico.NewRow();

                foreach (clsHistoricoPorcentajeAceptacion historico in this.InnerList)
                {
                    drFila[_descripcionCampoAfectado] = historico.DescripcionCampoAfectado;
                    drFila[_estadoAnteriorCampoAfectado] = historico.EstadoAnteriorCampoAfectado;
                    drFila[_estadoActualCampoAfectado] = historico.EstadoActualCampoAfectado;
                    drFila[_fechaHora] = historico.FechaHora;
                    drFila[_codigoUsuario] = historico.CodigoUsuario;
                    drFila[_nombreUsuario] = historico.NombreUsuario;
                    drFila[_desTipoGarantia] = historico.DesTipoGarantia;
                    drFila[_desTipoMitigador] = historico.DesTipoMitigador;
                    drFila[_desAccionRealizada] = historico.DesAccionRealizada;

                    dtHistorico.Rows.Add(drFila);
                    drFila = dtHistorico.NewRow();
                }

                #endregion Agregar filas y datos a la tabla

                dtHistorico.AcceptChanges();

                dtHistorico.DefaultView.Sort = _fechaHora + " desc";
            }

            dsHistorico.Tables.Add(dtHistorico);
            dsHistorico.AcceptChanges();

            return dsHistorico;
        }


        #endregion Métodos Públicos



    }//FIN
}//FIN
