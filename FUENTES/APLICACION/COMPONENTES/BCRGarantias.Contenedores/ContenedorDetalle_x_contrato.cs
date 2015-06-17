using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorDetalle_x_contrato : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "RPT_DETALLE_X_CONTRATO";
        public const string COD_OFICINA_CLIENTE = "cod_oficina_cliente";
        public const string DES_OFICINA_CLIENTE = "des_oficina_cliente";
        public const string OFICINA = "oficina";
        public const string COD_CONTABILIDAD = "cod_contabilidad";
        public const string COD_OFICINA = "cod_oficina";
        public const string COD_MONEDA = "cod_moneda";
        public const string COD_PRODUCTO = "cod_producto";
        public const string NUM_OPERACION = "num_operacion";
        public const string NUM_CONTRATO = "num_contrato";
        public const string PRMCA_PFE_CONST = "prmca_pfe_const";
        public const string PENDIENTE = "pendiente";

		#endregion

        public ContenedorDetalle_x_contrato()
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
            campo.Llave = PRMCA_PFE_CONST;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PENDIENTE;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

