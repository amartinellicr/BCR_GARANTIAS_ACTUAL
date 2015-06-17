using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorUsuario : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "SEG_USUARIO";
        public const string COD_USUARIO = "cod_usuario";
        public const string DES_USUARIO = "des_usuario";
        public const string COD_PERFIL = "cod_perfil";

		#endregion

        public ContenedorUsuario()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_USUARIO;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_USUARIO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_PERFIL;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

