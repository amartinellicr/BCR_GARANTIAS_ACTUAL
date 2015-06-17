using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorTarjeta_sicc : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "TAR_TARJETA_SICC";
        public const string NUM_TARJETA = "num_tarjeta";
        public const string CEDULA_DEUDOR = "cedula_deudor";
        public const string COD_BIN = "cod_bin";
        public const string MONTO_COBERTURA = "monto_cobertura";
        public const string FECHA_EXPIRACION = "fecha_expiracion";
        public const string CEDULA_FIADOR = "cedula_fiador";
        public const string COD_MONEDA = "cod_moneda";
        public const string COD_OFICINA_REGISTRA = "cod_oficina_registra";

		#endregion

        public ContenedorTarjeta_sicc()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = NUM_TARJETA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_DEUDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_BIN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_COBERTURA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_EXPIRACION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_FIADOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_MONEDA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OFICINA_REGISTRA;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

