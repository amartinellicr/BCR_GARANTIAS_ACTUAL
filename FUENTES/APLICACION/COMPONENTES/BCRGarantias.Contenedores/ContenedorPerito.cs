using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorPerito : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_PERITO";
        public const string CEDULA_PERITO = "cedula_perito";
        public const string DES_PERITO = "des_perito";
        public const string COD_TIPO_PERSONA = "cod_tipo_persona";
        public const string DES_DIRECCION = "des_direccion";
        public const string DES_TELEFONO = "des_telefono";
        public const string DES_EMAIL = "des_email";

		#endregion

        public ContenedorPerito()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = CEDULA_PERITO;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_PERITO;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_PERSONA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_DIRECCION;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_TELEFONO;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_EMAIL;
			campo.EsLlave = true;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

