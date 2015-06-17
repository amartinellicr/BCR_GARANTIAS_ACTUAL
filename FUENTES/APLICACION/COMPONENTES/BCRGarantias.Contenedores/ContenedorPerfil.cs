using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorPerfil : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "SEG_PERFIL";
        public const string COD_PERFIL = "cod_perfil";
        public const string DES_PERFIL = "des_perfil";

		#endregion

        public ContenedorPerfil()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_PERFIL;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_PERFIL;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

