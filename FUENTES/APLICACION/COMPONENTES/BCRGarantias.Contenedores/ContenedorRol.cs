using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorRol : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "SEG_ROL";
        public const string COD_ROL = "cod_rol";
        public const string DES_ROL = "des_rol";
        public const string NOMBRE = "nombre";

		#endregion

        public ContenedorRol()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_ROL;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_ROL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NOMBRE;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

