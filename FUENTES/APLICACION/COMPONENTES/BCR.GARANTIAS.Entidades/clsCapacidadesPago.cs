using System;
using System.Collections;
using System.Data;

namespace BCR.GARANTIAS.Entidades
{
    public class clsCapacidadesPago<T> : CollectionBase
        where T : clsCapacidadPago
    {

        #region Constantes

        private const string _fechaCapacidadPago        = "fecha_capacidad_pago";
        private const string _codCapacidadPago          = "cod_capacidad_pago";
        private const string _porSensibilidadTipoCambio = "sensibilidad_tipo_cambio";
        private const string _desCapacidadPago          = "des_capacidad_pago";

        #endregion Constantes

        #region Métodos Públicos

        /// <summary>
        /// Agrega una entidad del tipo capacidad de pago a la colección
        /// </summary>
        /// <param name="CapacidadPago">Entidad de Capacidad Pago que se agregará a la colección</param>
        public void Agregar(clsCapacidadPago CapacidadPago)
        {
            InnerList.Add(CapacidadPago);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo capacidad de pago del a colección
        /// </summary>
        /// <param name="indece">Posición de la entidad dentro de la colección</param>
        public void Remover(int indece)
        {
            InnerList.RemoveAt(indece);
        }

        /// <summary>
        /// Obtiene una entidad de capacidad de pago específica
        /// </summary>
        /// <param name="indece">Posición, dentro de la colección, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo capacidad de pago</returns>
        public clsCapacidadPago Item(int indece)
        {
            return (clsCapacidadPago)InnerList[indece];
        }

        public DataSet toDataSet()
        {
            //Se inicializan la variables locales
            DataSet dsCapacidadesPago = new DataSet();
            DataTable dtCapacidadesPago = new DataTable("Deudor");


            #region Agregar columnas a la tabla

            DataColumn dcColumna = new DataColumn(_fechaCapacidadPago, typeof(DateTime));
            dtCapacidadesPago.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_codCapacidadPago, typeof(int));
            dtCapacidadesPago.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_porSensibilidadTipoCambio, typeof(decimal));
            dtCapacidadesPago.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_desCapacidadPago, typeof(string));
            dtCapacidadesPago.Columns.Add(dcColumna);

            dtCapacidadesPago.AcceptChanges();

            #endregion Agregar columnas a la tabla

            //Se verifica que existan registros
            if (InnerList.Count > 0)
            {
                #region Agregar filas y datos a la tabla

                DataRow drFila = dtCapacidadesPago.NewRow();

                foreach (clsCapacidadPago capacidadPago in InnerList)
                {
                    drFila[_fechaCapacidadPago] = capacidadPago.FechaCapacidadPago;
                    drFila[_codCapacidadPago] = capacidadPago.CapacidadPago;
                    drFila[_porSensibilidadTipoCambio] = capacidadPago.SensibilidadTipoCambio;
                    drFila[_desCapacidadPago] = capacidadPago.DescripcionCapacidadPago;

                    dtCapacidadesPago.Rows.Add(drFila);
                    drFila = dtCapacidadesPago.NewRow();
                }


                #endregion Agregar filas y datos a la tabla
  
                dtCapacidadesPago.AcceptChanges();

                dtCapacidadesPago.DefaultView.Sort = _fechaCapacidadPago + " desc";
            }

            dsCapacidadesPago.Tables.Add(dtCapacidadesPago);
            dsCapacidadesPago.AcceptChanges();
            
            return dsCapacidadesPago;
        }
        #endregion Métodos Públicos
    }
}
