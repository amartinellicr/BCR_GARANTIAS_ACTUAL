using System;
using System.Collections;
using System.Data;

namespace BCR.GARANTIAS.Entidades
{
    public class clsValuacionesReales<T> : CollectionBase
        where T : clsValuacionReal
    {
        #region Constantes

        private const string _codGarantiaReal                   = "cod_garantia_real";
        private const string _fechaValuacion                    = "fecha_valuacion";
        private const string _cedulaEmpresa                     = "cedula_empresa";
        private const string _cedulaPerito                      = "cedula_perito";
        private const string _montoUltimaTasacionTerreno        = "monto_ultima_tasacion_terreno";
        private const string _montoUltimaTasacionNoTerreno      = "monto_ultima_tasacion_no_terreno";
        private const string _montoTasacionActualizadaTerreno   = "monto_tasacion_actualizada_terreno";
        private const string _montoTasacionActualizadaNoTerreno = "monto_tasacion_actualizada_no_terreno";
        private const string _fechaUltimoSeguimiento            = "fecha_ultimo_seguimiento";
        private const string _montoTotalAvaluo                  = "monto_total_avaluo";
        private const string _codRecomendacionPerito            = "cod_recomendacion_perito";
        private const string _codInspeccionMenorTresMeses       = "cod_inspeccion_menor_tres_meses";
        private const string _fechaConstruccion                 = "fecha_construccion";
        private const string _nombreClientePerito               = "nombre_cliente_perito";
        private const string _nombreClienteEmpresa              = "nombre_cliente_empresa";

        #endregion Constantes

        #region M�todos P�blicos

        /// <summary>
        /// Agrega una entidad del tipo valuaci�n a la colecci�n
        /// </summary>
        /// <param name="CapacidadPago">Entidad de Capacidad Pago que se agregar� a la colecci�n</param>
        public void Agregar(clsValuacionReal avaluoReal)
        {
            InnerList.Add(avaluoReal);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo valuaci�n del a colecci�n
        /// </summary>
        /// <param name="indece">Posici�n de la entidad dentro de la colecci�n</param>
        public void Remover(int indece)
        {
            InnerList.RemoveAt(indece);
        }

        /// <summary>
        /// Obtiene una entidad de valuaci�n espec�fica
        /// </summary>
        /// <param name="indece">Posici�n, dentro de la colecci�n, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo capacidad de pago</returns>
        public clsValuacionReal Item(int indece)
        {
            return (clsValuacionReal)InnerList[indece];
        }

        /// <summary>
        /// Permite convertir la entidad en un dataset
        /// </summary>
        /// <returns>DataSet que posee la informaci�n de la entidad</returns>
        public DataSet toDataSet()
        {
            //Se inicializan la variables locales
            DataSet dsValuacionesReales = new DataSet();
            DataTable dtValuacionesReales = new DataTable("Avaluos");


            #region Agregar columnas a la tabla

            DataColumn dcColumna = new DataColumn(_codGarantiaReal, typeof(long));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_fechaValuacion, typeof(DateTime));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_cedulaEmpresa, typeof(string));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_cedulaPerito, typeof(string));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_montoUltimaTasacionTerreno, typeof(decimal));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_montoUltimaTasacionNoTerreno, typeof(decimal));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_montoTasacionActualizadaTerreno, typeof(decimal));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_montoTasacionActualizadaNoTerreno, typeof(decimal));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_fechaUltimoSeguimiento, typeof(DateTime));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_montoTotalAvaluo, typeof(decimal));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_codRecomendacionPerito, typeof(Int16));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_codInspeccionMenorTresMeses, typeof(Int16));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_fechaConstruccion, typeof(DateTime));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_nombreClientePerito, typeof(string));
            dtValuacionesReales.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_nombreClienteEmpresa, typeof(string));
            dtValuacionesReales.Columns.Add(dcColumna);


            dtValuacionesReales.AcceptChanges();

            #endregion Agregar columnas a la tabla

            //Se verifica que existan registros
            if (InnerList.Count > 0)
            {
                #region Agregar filas y datos a la tabla

                DataRow drFila = dtValuacionesReales.NewRow();

                foreach (clsValuacionReal avaluoReal in InnerList)
                {
                    drFila[_codGarantiaReal] = avaluoReal.CodGarantiaReal;
                    drFila[_fechaValuacion] = avaluoReal.FechaValuacion;
                    drFila[_cedulaEmpresa] = avaluoReal.CedulaEmpresa;
                    drFila[_cedulaPerito] = avaluoReal.CedulaPerito;
                    drFila[_montoUltimaTasacionTerreno] = avaluoReal.MontoUltimaTasacionTerreno;
                    drFila[_montoUltimaTasacionNoTerreno] = avaluoReal.MontoUltimaTasacionNoTerreno;
                    drFila[_montoTasacionActualizadaTerreno] = avaluoReal.MontoTasacionActualizadaTerreno;
                    drFila[_montoTasacionActualizadaNoTerreno] = avaluoReal.MontoTasacionActualizadaNoTerreno;
                    drFila[_fechaUltimoSeguimiento] = avaluoReal.FechaUltimoSeguimiento;
                    drFila[_montoTotalAvaluo] = avaluoReal.MontoTotalAvaluo;
                    drFila[_codRecomendacionPerito] = avaluoReal.CodigoRecomendacionPerito;
                    drFila[_codInspeccionMenorTresMeses] = avaluoReal.CodigoInspeccionMenorTresMeses;
                    drFila[_fechaConstruccion] = avaluoReal.FechaConstruccion;
                    drFila[_nombreClientePerito] = avaluoReal.DescripcionNombreClientePerito;
                    drFila[_nombreClienteEmpresa] = avaluoReal.DescripcionNombreClienteEmpresa;

                    dtValuacionesReales.Rows.Add(drFila);
                    drFila = dtValuacionesReales.NewRow();
                }

                #endregion Agregar filas y datos a la tabla

                dtValuacionesReales.AcceptChanges();

                dtValuacionesReales.DefaultView.Sort = _fechaValuacion + " desc";
            }

            dsValuacionesReales.Tables.Add(dtValuacionesReales);
            dsValuacionesReales.AcceptChanges();

            return dsValuacionesReales;
        }

        /// <summary>
        /// Obtiene una entidad de valuaci�n espec�fica de acuerdo a la fecha de evaluaci�n
        /// </summary>
        /// <param name="indece">Fecha de valuaci�n de la entidad que se requiere</param>
        /// <returns>Una entidad</returns>
        public clsValuacionReal obtenerItem(DateTime fecha_evaluacion)
        {
            clsValuacionReal item = new clsValuacionReal();

            if (InnerList.Count > 0)
            {
                foreach (clsValuacionReal avaluoReal in InnerList)
                {
                    if (avaluoReal.FechaValuacion == fecha_evaluacion)
                    {
                        item.CodGarantiaReal = avaluoReal.CodGarantiaReal;
                        item.FechaValuacion = avaluoReal.FechaValuacion;
                        item.CedulaEmpresa = avaluoReal.CedulaEmpresa;
                        item.CedulaPerito = avaluoReal.CedulaPerito;
                        item.MontoUltimaTasacionTerreno = avaluoReal.MontoUltimaTasacionTerreno;
                        item.MontoUltimaTasacionNoTerreno = avaluoReal.MontoUltimaTasacionNoTerreno;
                        item.MontoTasacionActualizadaTerreno = avaluoReal.MontoTasacionActualizadaTerreno;
                        item.MontoTasacionActualizadaNoTerreno = avaluoReal.MontoTasacionActualizadaNoTerreno;
                        item.FechaUltimoSeguimiento = avaluoReal.FechaUltimoSeguimiento;
                        item.MontoTotalAvaluo = avaluoReal.MontoTotalAvaluo;
                        item.CodigoRecomendacionPerito = avaluoReal.CodigoRecomendacionPerito;
                        item.CodigoInspeccionMenorTresMeses = avaluoReal.CodigoInspeccionMenorTresMeses;
                        item.FechaConstruccion = avaluoReal.FechaConstruccion;
                        item.DescripcionNombreClientePerito = avaluoReal.DescripcionNombreClientePerito;
                        item.DescripcionNombreClienteEmpresa = avaluoReal.DescripcionNombreClienteEmpresa;
                    }
                    
                }
            }

            return item;
        }

     #endregion M�todos P�blicos
    }
}
