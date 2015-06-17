using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorElemento : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "CAT_ELEMENTO";
        public const string CAT_ELEMENTO = "cat_elemento";
        public const string CAT_CATALOGO = "cat_catalogo";
        public const string CAT_CAMPO = "cat_campo";
        public const string CAT_DESCRIPCION = "cat_descripcion";

		#endregion

        public ContenedorElemento()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = CAT_ELEMENTO;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CAT_CATALOGO;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CAT_CAMPO;
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

