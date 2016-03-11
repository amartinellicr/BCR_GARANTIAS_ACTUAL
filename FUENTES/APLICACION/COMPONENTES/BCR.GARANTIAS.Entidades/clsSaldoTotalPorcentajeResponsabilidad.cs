using System;
using System.Data;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Collections.Specialized;
using System.Diagnostics;
using System.IO;
using System.Configuration;
using System.Globalization;
using System.Data.SqlClient;

using BCR.GARANTIAS.Comun;
using BCRGARANTIAS.Datos;


namespace BCR.GARANTIAS.Entidades
{
    public class clsSaldoTotalPorcentajeResponsabilidad
    {
        #region Constantes

        //Nombre tablas
        public const string _entidadSaldoTotalPorcentajeResp = "GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD";

        //Campos
        public const string _consecutivoOperacion               = "Consecutivo_Operacion";
        public const string _consecutivoGarantia                = "Consecutivo_Garantia";
        public const string _codigoTipoGarantia                 = "Codigo_Tipo_Garantia";
        public const string _saldoActual                        = "Saldo_Actual";
        public const string _cuentaContable                     = "Cuenta_Contable";
        public const string _tipoOperacion                      = "Tipo_Operacion";
        public const string _codigoTipoOperacion                = "Codigo_Tipo_Operacion";
        public const string _operacionLarga = "Operacion_Larga";
        public const string _saldoActualAjustado = "Saldo_Actual_Ajustado";
        public const string _porcentajeResponsabilidadAjustado = "Porcentaje_Responsabilidad_Ajustado";
        public const string _indicadorAjusteSaldoActual = "Indicador_Ajuste_Saldo_Actual";
        public const string _indicadorAjustePorcentaje = "Indicador_Ajuste_Porcentaje";
        public const string _indicadorExcluido = "Indicador_Excluido";


        #endregion Constantes

        #region Propiedades
        #endregion Propiedades

        #region Constructores
        #endregion Constructores

        #region Métodos
        #endregion Métodos

    }
}
