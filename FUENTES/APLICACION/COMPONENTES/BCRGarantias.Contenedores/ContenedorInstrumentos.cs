using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorInstrumentos : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "CAT_INSTRUMENTOS";
        public const string COD_INSTRUMENTO = "cod_instrumento";
        public const string DES_INSTRUMENTO = "des_instrumento";

		#endregion

        public ContenedorInstrumentos()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_INSTRUMENTO;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_INSTRUMENTO;
			campo.EsLlave = true;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

