using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorGarantia_fiduciaria : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "TAR_GARANTIA_FIDUCIARIA";
        public const string COD_GARANTIA_FIDUCIARIA = "cod_garantia_fiduciaria";
        public const string COD_TIPO_GARANTIA = "cod_tipo_garantia";
        public const string COD_CLASE_GARANTIA = "cod_clase_garantia";
        public const string CEDULA_FIADOR = "cedula_fiador";
        public const string NOMBRE_FIADOR = "nombre_fiador";
        public const string COD_TIPO_FIADOR = "cod_tipo_fiador";
        public const string RUC_CEDULA_FIADOR = "ruc_cedula_fiador";

		#endregion

        public ContenedorGarantia_fiduciaria()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_GARANTIA_FIDUCIARIA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_GARANTIA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_CLASE_GARANTIA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_FIADOR;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NOMBRE_FIADOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_FIADOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = RUC_CEDULA_FIADOR;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

