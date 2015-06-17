using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorGiros_garantias_fiduciarias : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_GIROS_GARANTIAS_FIDUCIARIAS";
        public const string COD_CONTABILIDAD = "cod_contabilidad";
        public const string COD_OFICINA = "cod_oficina";
        public const string COD_MONEDA = "cod_moneda";
        public const string COD_PRODUCTO = "cod_producto";
        public const string NUM_OPERACION = "num_operacion";
        public const string CEDULA_FIADOR = "cedula_fiador";
        public const string COD_TIPO_FIADOR = "cod_tipo_fiador";
        public const string FECHA_VALUACION = "fecha_valuacion";
        public const string INGRESO_NETO = "ingreso_neto";
        public const string COD_TIPO_MITIGADOR = "cod_tipo_mitigador";
        public const string COD_TIPO_DOCUMENTO_LEGAL = "cod_tipo_documento_legal";
        public const string MONTO_MITIGADOR = "monto_mitigador";
        public const string PORCENTAJE_RESPONSABILIDAD = "porcentaje_responsabilidad";
        public const string COD_TIPO_ACREEDOR = "cod_tipo_acreedor";
        public const string CEDULA_ACREEDOR = "cedula_acreedor";
        public const string COD_OPERACION_ESPECIAL = "cod_operacion_especial";
        public const string NOMBRE_FIADOR = "nombre_fiador";
        public const string CEDULA_DEUDOR = "cedula_deudor";
        public const string NOMBRE_DEUDOR = "nombre_deudor";
        public const string OFICINA_DEUDOR = "oficina_deudor";
        public const string COD_BIN = "cod_bin";
        public const string COD_INTERNO_SISTAR = "cod_interno_sistar";

		#endregion

        public ContenedorGiros_garantias_fiduciarias()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_CONTABILIDAD;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OFICINA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_MONEDA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_PRODUCTO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NUM_OPERACION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_FIADOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_FIADOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_VALUACION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = INGRESO_NETO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_MITIGADOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_DOCUMENTO_LEGAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_MITIGADOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_RESPONSABILIDAD;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_ACREEDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_ACREEDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OPERACION_ESPECIAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NOMBRE_FIADOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_DEUDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NOMBRE_DEUDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = OFICINA_DEUDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_BIN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_INTERNO_SISTAR;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

