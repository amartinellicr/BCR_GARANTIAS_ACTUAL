using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorTar_bin_sistar : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "TAR_BIN_SISTAR";
        public const string BIN = "bin";
        public const int BIN_INDEX = 1;
        public const string FECINGRESO = "fecingreso";
        public const int FECINGRESO_INDEX = 2;

		#endregion

        public ContenedorTar_bin_sistar()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = BIN;
			campo.EsLlave = true;
			campo.Tipo = System.Data.DbType.Int32;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECINGRESO;
			campo.Tipo = System.Data.DbType.String;
			Campos.Agregar(campo);

			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}
