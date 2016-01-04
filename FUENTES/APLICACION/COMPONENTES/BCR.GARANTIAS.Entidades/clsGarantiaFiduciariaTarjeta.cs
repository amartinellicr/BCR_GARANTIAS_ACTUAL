using System;
using System.Collections.Generic;
using System.Text;

namespace BCR.GARANTIAS.Entidades
{
    public class clsGarantiaFiduciariaTarjeta
    {
        #region Constantes
        public const string _entidadGarantiaFiduciariaTarjeta = "TAR_GARANTIA_FIDUCIARIA";
        public const string _entidadGarantiaFiduciariaXTarjeta = "TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA";


        //Campos de la tabla de garantías fiduciarias 
        public const string _codigoTipoGarantia = "cod_tipo_garantia";
        public const string _codigoClaseGarantia = "cod_clase_garantia";
        public const string _cedulaFiador = "cedula_fiador";
        public const string _nombreFiador = "nombre_fiador";
        public const string _codigoTipoPersonaFiador = "cod_tipo_fiador";
        public const string _cedulaFiadorRuc = "ruc_cedula_fiador";

        //Campos de la tabla de la relación 
        public const string _consecutivoTarjeta = "cod_tarjeta";
        public const string _codigoTipoMitigador = "cod_tipo_mitigador";
        public const string _codigoTipoDocumentoLegal = "cod_tipo_documento_legal";
        public const string _montoMitigador = "monto_mitigador";
        public const string _porcentajeResponsabilidad = "porcentaje_responsabilidad";
        public const string _codigoOperacionEspecial = "cod_operacion_especial";
        public const string _codigoTipoPersonaAcreedor = "cod_tipo_acreedor";
        public const string _cedulaAcreedor = "cedula_acreedor";
        public const string _fechaExpiracion = "fecha_expiracion";
        public const string _montoCobertura = "monto_cobertura";
        public const string _observacion = "des_observacion";
        public const string _porcentajeAceptacion = "Porcentaje_Aceptacion";
 
        //Campos comunes entre las tablas
        public const string _consecutivoGarantiaFiduciaria = "cod_garantia_fiduciaria";

        #endregion Constantes
    }
}
