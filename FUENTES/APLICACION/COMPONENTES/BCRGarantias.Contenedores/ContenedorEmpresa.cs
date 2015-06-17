using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorEmpresa : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_EMPRESA";
        public const string CEDULA_EMPRESA = "cedula_empresa";
        public const string DES_EMPRESA = "des_empresa";
        public const string DES_DIRECCION = "des_direccion";
        public const string DES_TELEFONO = "des_telefono";
        public const string DES_EMAIL = "des_email";

		#endregion

        public ContenedorEmpresa()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = CEDULA_EMPRESA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_EMPRESA;
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

