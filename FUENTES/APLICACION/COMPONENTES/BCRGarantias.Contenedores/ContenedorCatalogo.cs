using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorCatalogo : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "CAT_CATALOGO";
        public const string CAT_CATALOGO = "cat_catalogo";
        public const string CAT_DESCRIPCION = "cat_descripcion";

		#endregion

        public ContenedorCatalogo()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = CAT_CATALOGO;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CAT_DESCRIPCION;
			campo.EsLlave = true;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

