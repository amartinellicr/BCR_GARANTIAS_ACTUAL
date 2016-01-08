using System;
using System.Collections.Generic;
using System.Text;

namespace BCR.GARANTIAS.Entidades
{
    [Serializable]
    public class clsTarjeta
    {
        #region Constantes
        public const string _entidadBinSistar = "TAR_BIN_SISTAR";
        public const string _entidadTarjeta = "TAR_TARJETA";
        public const string _entidadTarjetaSicc = "TAR_TARJETA_SICC";
        public const string _entidadTarjetaSistar = "TAR_TARJETA_SISTAR";
        
        //Campos de la tabla de bines        
        public const string _fechaIngreso = "fecingreso";

        //Campos de la tabla de tarjetas
        public const string _consecutivoTarjeta = "cod_tarjeta";
        public const string _codigoTipoGarantia = "cod_tipo_garantia";
        public const string _indicadorEstadoTarjeta = "cod_estado_tarjeta";

        //Campos de la tabla de tarjetas SICC
        public const string _fechaExpiracion = "fecha_expiracion";
        public const string _montoCobertura = "monto_cobertura";
        public const string _cedulaFiador = "cedula_fiador";

        //Campos de la tabla de tarjetas SISTAR
        public const string _cedulaTarjetaHabiente = "cedula";
        
        //Campos comunes entre las tablas
        public const string _numeroBin = "bin";
        public const string _codigoBin = "cod_bin";
        public const string _numeroTarjeta = "num_tarjeta";
        public const string _numeroTarjetaSistar = "tarjeta";
        public const string _cedulaDeudor = "cedula_deudor";
        public const string _codigoMoneda = "cod_moneda";
        public const string _codigoOficinaRegistra = "cod_oficina_registra";
        public const string _codigoInternoSistar = "cod_interno_sistar";
        public const string _codigoInterno = "codigo_interno";

        #endregion Constantes

        #region Propiedades

        public bool TarjetaValida { get; set; }
        public bool EsMasterCard { get; set; }
        public string CedulaDeudor { get; set; }
        public string NombreDeudor { get; set; }
        public int NumeroBin { get; set; }
        public int CodigoInternoSistar { get; set; }
        public int CodigoMoneda { get; set; }
        public int CodigoOficinaRegistra { get; set; }
        public int CodigoTipoGarantia { get; set; }
        public string EstadoTarjeta { get; set; }
        public decimal MontoOperacion { get; set; }

        public string CodigoError { get; set; }
        public string DescripcionError { get; set; }

        #endregion Propiedades
    }
}
