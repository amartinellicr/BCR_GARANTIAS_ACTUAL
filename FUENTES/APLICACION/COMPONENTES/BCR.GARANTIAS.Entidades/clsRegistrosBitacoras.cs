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
    public class clsRegistrosBitacoras<T> : CollectionBase
        where T : clsBitacora
    {


        #region Constantes
         
        private const string _desTabla = "des_tabla";
        private const string _codUsuario = "cod_usuario";
        private const string _codIP = "cod_ip";
        private const string _codOficina = "cod_oficina";
        private const string _codOperacion = "cod_operacion";
        private const string _fechaHora = "fecha_hora";
        private const string _codConsulta = "cod_consulta";
        private const string _codTipoGarantia = "cod_tipo_garantia";
        private const string _codGarantia = "cod_garantia";
        private const string _codOperacionCrediticia = "cod_operacion_crediticia";
        private const string _codConsulta2 = "cod_consulta2";
        private const string _desCampoAfectado = "des_campo_afectado";
        private const string _estAnteriorCampoAfectado = "est_anterior_campo_afectado";
        private const string _estActualCampoAfectado = "est_actual_campo_afectado";
        private const string _nombreUsuarioModifico = "Nombre_Usuario_Modifico";

        private const string _desTipoGarantia = "Tipo_Garantia";
        private const string _accionRealizada = "Accion_Realizada";


        //Tags especiales
        private const string _tagBitacora = "BITACORA";
        private const string _tagDatos = "DATOS";

        #endregion

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaDatosCambioGarantia;

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
        public string TramaDatosCambioGarantia
        {
            get { return tramaDatosCambioGarantia; }
            set { tramaDatosCambioGarantia = value; }
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
        public clsRegistrosBitacoras()
        {
            this.tramaDatosCambioGarantia = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaListaCambiosGarantias">Trama que posee los datos de las garantías obtenidas de la Base de Datos</param>
        public clsRegistrosBitacoras(string tramaListaCambiosGarantias)
        {
            this.tramaDatosCambioGarantia = string.Empty;

            if (tramaListaCambiosGarantias.Length > 0)
            {
                XmlDocument xmlCambioGarantias = new XmlDocument();

                try
                {
                    xmlCambioGarantias.LoadXml(tramaListaCambiosGarantias);
                }
                catch (Exception ex)
                {
                    errorDatos = true;                   
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaGarantias, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaGarantiasDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
             

                    return;
                }

                if (xmlCambioGarantias != null)
                {
                    this.tramaDatosCambioGarantia = tramaListaCambiosGarantias;

                    if (xmlCambioGarantias.HasChildNodes)
                    {
                        clsBitacora entidadBitacora;

                        if (xmlCambioGarantias.SelectSingleNode("//" + _tagBitacora) != null)
                        {
                            foreach (XmlNode nodoGarantia in xmlCambioGarantias.SelectNodes("//" + _tagBitacora))
                            {                           
                               entidadBitacora = new clsBitacora(nodoGarantia.OuterXml);                                   

                                if (entidadBitacora.ErrorDatos)
                                {
                                    this.errorDatos = entidadBitacora.ErrorDatos;
                                    this.descripcionError = entidadBitacora.DescripcionError;
                                    break;
                                }
                                else
                                {
                                    this.Agregar(entidadBitacora);
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
        /// Agrega una entidad del tipo bitacora a la colección
        /// </summary>
        /// <param name="garantiaReal">Entidad del tipo bitacora que se agregará a la colección</param>
        public void Agregar(clsBitacora bitacora)
        {
            InnerList.Add(bitacora);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo bitacora de la colección
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
        /// <returns>Una entidad del tipo bitacora</returns>
        public clsBitacora Item(int indece)
        {
            return (clsBitacora)InnerList[indece];
        }


        /// <summary>
        /// Obtiene la lista completa de todos los los datos
        /// </summary>
        /// <returns>La lista de todos los valuadores</returns>
        public List<clsBitacora> Items()
        {
            List<clsBitacora> listaDatosCambioGarantia = new List<clsBitacora>();

            foreach (clsBitacora bitacora in InnerList)
            {
                listaDatosCambioGarantia.Add(bitacora);
            }
            //listaDatosCambioGarantia.Sort(delegate(clsBitacora valuador1, clsBitacora valuador2)
            //  {
            //      return valuador1.CedulaValuador.CompareTo(valuador2.CedulaValuador);
            //  });

            return listaDatosCambioGarantia;
        }


        /// <summary>
        /// Permite convertir la entidad en un dataset
        /// </summary>
        /// <returns>DataSet que posee la información de la entidad</returns>
        public DataSet toDataSet()
        {
            //Se inicializan la variables locales
            DataSet dsBitacora = new DataSet();
            DataTable dtBitacora = new DataTable("Bitacora");

            #region Agregar columnas a la tabla

            DataColumn dcColumna = new DataColumn(_desCampoAfectado, typeof(string));
            dtBitacora.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_estAnteriorCampoAfectado, typeof(string));
            dtBitacora.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_estActualCampoAfectado, typeof(string));
            dtBitacora.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_fechaHora, typeof(DateTime));
            dtBitacora.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_codUsuario, typeof(string));
            dtBitacora.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_nombreUsuarioModifico, typeof(string));
            dtBitacora.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_desTipoGarantia, typeof(string));
            dtBitacora.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_accionRealizada, typeof(string));
            dtBitacora.Columns.Add(dcColumna);

            dtBitacora.AcceptChanges();

            #endregion Agregar columnas a la tabla

            //Se verifica que existan registros
            if (InnerList.Count > 0)
            {
                #region Agregar filas y datos a la tabla

                DataRow drFila = dtBitacora.NewRow();

                foreach (clsBitacora bitacora in this.InnerList)
                {
                    drFila[_desCampoAfectado] = bitacora.NombreCampoAfectado;
                    drFila[_estAnteriorCampoAfectado] = bitacora.ValorAnterior;
                    drFila[_estActualCampoAfectado] = bitacora.ValorActual;
                    drFila[_fechaHora] = bitacora.FechaHora;
                    drFila[_codUsuario] = bitacora.IdUsuario;
                    drFila[_nombreUsuarioModifico] = bitacora.NombreUsuarioModifico;
                    drFila[_desTipoGarantia] = bitacora.DesTipoGarantia;
                    drFila[_accionRealizada] = bitacora.AccionRealizada;

                    dtBitacora.Rows.Add(drFila);
                    drFila = dtBitacora.NewRow();
                }

                #endregion Agregar filas y datos a la tabla

                dtBitacora.AcceptChanges();

                dtBitacora.DefaultView.Sort = _fechaHora + " desc";
            }

            dsBitacora.Tables.Add(dtBitacora);
            dsBitacora.AcceptChanges();

            return dsBitacora;
        }


        #endregion Métodos Públicos
    }//
}//
