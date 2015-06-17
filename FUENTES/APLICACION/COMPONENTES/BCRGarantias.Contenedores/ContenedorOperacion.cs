using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorOperacion : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_OPERACION";
        public const string COD_OPERACION = "cod_operacion";
        public const string COD_CONTABILIDAD = "cod_contabilidad";
        public const string COD_OFICINA = "cod_oficina";
        public const string COD_MONEDA = "cod_moneda";
        public const string COD_PRODUCTO = "cod_producto";
        public const string NUM_OPERACION = "num_operacion";
        public const string NUM_CONTRATO = "num_contrato";
        public const string FECHA_CONSTITUCION = "fecha_constitucion";
        public const string CEDULA_DEUDOR = "cedula_deudor";
        public const string FECHA_VENCIMIENTO = "fecha_vencimiento";
        public const string MONTO_ORIGINAL = "monto_original";
        public const string SALDO_ACTUAL = "saldo_actual";
        public const string COD_ESTADO = "cod_estado";

		#endregion

        public ContenedorOperacion()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_OPERACION;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_CONTABILIDAD;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OFICINA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_MONEDA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_PRODUCTO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NUM_OPERACION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NUM_CONTRATO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_CONSTITUCION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_DEUDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_VENCIMIENTO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_ORIGINAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = SALDO_ACTUAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_ESTADO;
			campo.EsLlave = true;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

