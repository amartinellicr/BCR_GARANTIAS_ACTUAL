using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Data;

namespace BCR.GARANTIAS.Entidades
{
    public class clsEjecucionProcesos<T> : CollectionBase
        where T : clsEjecucionProceso
    {
        #region Constantes

        private const string _proceso       = "cocProceso";
        private const string _fecha         = "fecIngreso";
        private const string _resultado     = "Resultado";
        private const string _observacion   = "desObservacion";

        #endregion Constantes

        #region M�todos P�blicos

        /// <summary>
        /// Agrega una entidad del tipo ejecuci�n proceso a la colecci�n
        /// </summary>
        /// <param name="CapacidadPago">Entidad de Ejecuci�n Proceso que se agregar� a la colecci�n</param>
        public void Agregar(clsEjecucionProceso procesoEjecutado)
        {
            InnerList.Add(procesoEjecutado);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo ejecuci�n proceso de la colecci�n
        /// </summary>
        /// <param name="indece">Posici�n de la entidad dentro de la colecci�n</param>
        public void Remover(int indece)
        {
            InnerList.RemoveAt(indece);
        }

        /// <summary>
        /// Obtiene una entidad de ejecuci�n de proceso espec�fica
        /// </summary>
        /// <param name="indece">Posici�n, dentro de la colecci�n, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo ejecuci�n proceso</returns>
        public clsEjecucionProceso Item(int indece)
        {
            return (clsEjecucionProceso)InnerList[indece];
        }

        /// <summary>
        /// Permite convertir la entidad en un dataset
        /// </summary>
        /// <returns>DataSet que posee la informaci�n de la entidad</returns>
        public DataSet toDataSet()
        {
            //Se inicializan la variables locales
            DataSet dsProcesosEjecutados = new DataSet();
            DataTable dtProcesosEjecutados = new DataTable("Procesos");


            #region Agregar columnas a la tabla

            DataColumn dcColumna = new DataColumn(_proceso, typeof(string));
            dtProcesosEjecutados.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_fecha, typeof(DateTime));
            dtProcesosEjecutados.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_resultado, typeof(string));
            dtProcesosEjecutados.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_observacion, typeof(string));
            dtProcesosEjecutados.Columns.Add(dcColumna);

            dtProcesosEjecutados.AcceptChanges();

            #endregion Agregar columnas a la tabla

            //Se verifica que existan registros
            if (InnerList.Count > 0)
            {
                #region Agregar filas y datos a la tabla

                DataRow drFila = dtProcesosEjecutados.NewRow();

                foreach (clsEjecucionProceso procesoEjecutado in this.InnerList)
                {
                    drFila[_proceso] = procesoEjecutado.NombreProceso;
                    drFila[_fecha] = procesoEjecutado.FechaEjecucion;
                    drFila[_resultado] = procesoEjecutado.ResultadoEjecucion;
                    drFila[_observacion] = procesoEjecutado.DetalleEjecucion;

                    dtProcesosEjecutados.Rows.Add(drFila);
                    drFila = dtProcesosEjecutados.NewRow();
                }

                #endregion Agregar filas y datos a la tabla

                dtProcesosEjecutados.AcceptChanges();

                dtProcesosEjecutados.DefaultView.Sort = _fecha + " desc";
            }

            dsProcesosEjecutados.Tables.Add(dtProcesosEjecutados);
            dsProcesosEjecutados.AcceptChanges();

            return dsProcesosEjecutados;
        }

        #endregion M�todos P�blicos
    }
}
