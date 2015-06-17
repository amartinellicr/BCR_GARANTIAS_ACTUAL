using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorRoles_x_perfil : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "SEG_ROLES_X_PERFIL";
        public const string COD_PERFIL = "cod_perfil";
        public const string COD_ROL = "cod_rol";

		#endregion

        public ContenedorRoles_x_perfil()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_PERFIL;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_ROL;
			campo.EsLlave = true;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

