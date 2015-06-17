using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorDetalle_x_garantia : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "RPT_DETALLE_X_GARANTIA";
        public const string COD_OFICINA_CLIENTE = "cod_oficina_cliente";
        public const string DES_OFICINA_CLIENTE = "des_oficina_cliente";
        public const string OFICINA = "oficina";
        public const string OPERACION = "operacion";
        public const string TIPO_GARANTIA = "tipo_garantia";
        public const string GARANTIA = "garantia";
        public const string PENDIENTE = "pendiente";

		#endregion

        public ContenedorDetalle_x_garantia()
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
            campo.Llave = OPERACION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TIPO_GARANTIA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = GARANTIA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PENDIENTE;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

