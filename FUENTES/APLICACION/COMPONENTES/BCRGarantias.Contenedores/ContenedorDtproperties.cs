using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorDtproperties : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "dtproperties";
        public const string ID = "id";
        public const string OBJECTID = "objectid";
        public const string PROPERTY = "property";
        public const string VALUE = "value";
        public const string UVALUE = "uvalue";
        public const string LVALUE = "lvalue";
        public const string VERSION = "version";

		#endregion

        public ContenedorDtproperties()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = ID;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = OBJECTID;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PROPERTY;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = VALUE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = UVALUE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = LVALUE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = VERSION;
			campo.EsLlave = true;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

