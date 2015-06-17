using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorIsin : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "CAT_ISIN";
        public const string COD_ISIN = "cod_isin";

		#endregion

        public ContenedorIsin()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_ISIN;
			campo.EsLlave = true;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

