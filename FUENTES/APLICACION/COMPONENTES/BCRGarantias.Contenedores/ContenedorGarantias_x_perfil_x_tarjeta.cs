using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    [Serializable]
    public class ContenedorGarantias_x_perfil_x_tarjeta : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "TAR_GARANTIAS_X_PERFIL_X_TARJETA";
        public const string COD_TARJETA = "cod_tarjeta";
        public const int COD_TARJETA_INDEX = 1;
        public const string OBSERVACIONES = "observaciones";
        public const int OBSERVACIONES_INDEX = 2;

		#endregion

        public ContenedorGarantias_x_perfil_x_tarjeta()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_TARJETA;
			campo.EsLlave = true;
			campo.Tipo = System.Data.DbType.Int32;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = OBSERVACIONES;
			campo.Tipo = System.Data.DbType.String;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

