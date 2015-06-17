using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorDetalle_x_operacion : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "RPT_DETALLE_X_OPERACION";
        public const string COD_OFICINA_CLIENTE = "cod_oficina_cliente";
        public const string DES_OFICINA_CLIENTE = "des_oficina_cliente";
        public const string OFICINA = "oficina";
        public const string COD_CONTABILIDAD = "cod_contabilidad";
        public const string COD_OFICINA = "cod_oficina";
        public const string COD_MONEDA = "cod_moneda";
        public const string COD_PRODUCTO = "cod_producto";
        public const string NUM_OPERACION = "num_operacion";
        public const string NUM_CONTRATO = "num_contrato";
        public const string PRMOC_PSA_ACTUAL = "prmoc_psa_actual";
        public const string PRMOC_PFE_CONST = "prmoc_pfe_const";
        public const string PRMOC_PFE_CONTA = "prmoc_pfe_conta";
        public const string PENDIENTE = "pendiente";

		#endregion

        public ContenedorDetalle_x_operacion()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_OFICINA_CLIENTE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_OFICINA_CLIENTE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = OFICINA;
			Campos.Agregar(campo);

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
            campo.Llave = NUM_CONTRATO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSA_ACTUAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFE_CONST;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFE_CONTA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PENDIENTE;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

