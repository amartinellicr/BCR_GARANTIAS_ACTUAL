using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorTarjeta_sistar : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "TAR_TARJETA_SISTAR";
        public const string CEDULA = "cedula";
        public const string TARJETA = "tarjeta";
        public const string BIN = "bin";
        public const string CODIGO_INTERNO = "codigo_interno";

		#endregion

        public ContenedorTarjeta_sistar()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = CEDULA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TARJETA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BIN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CODIGO_INTERNO;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

