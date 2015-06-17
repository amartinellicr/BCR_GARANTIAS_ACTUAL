using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorTarjeta : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "TAR_TARJETA";
        public const string COD_TARJETA = "cod_tarjeta";
        public const string CEDULA_DEUDOR = "cedula_deudor";
        public const string NUM_TARJETA = "num_tarjeta";
        public const string COD_BIN = "cod_bin";
        public const string COD_INTERNO_SISTAR = "cod_interno_sistar";
        public const string COD_MONEDA = "cod_moneda";
        public const string COD_OFICINA_REGISTRA = "cod_oficina_registra";
        public const string COD_TIPO_GARANTIA = "cod_tipo_garantia";
        public const string COD_ESTADO_TARJETA = "cod_estado_tarjeta";
		#endregion

        public ContenedorTarjeta()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_TARJETA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_DEUDOR;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NUM_TARJETA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_BIN;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_INTERNO_SISTAR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_MONEDA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OFICINA_REGISTRA;
			Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = COD_ESTADO_TARJETA;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = COD_TIPO_GARANTIA;
            Campos.Agregar(campo);


			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

