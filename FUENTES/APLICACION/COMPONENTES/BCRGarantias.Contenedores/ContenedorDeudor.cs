using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorDeudor : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_DEUDOR";
        public const string CEDULA_DEUDOR = "cedula_deudor";
        public const string NOMBRE_DEUDOR = "nombre_deudor";
        public const string COD_TIPO_DEUDOR = "cod_tipo_deudor";
        public const string COD_CONDICION_ESPECIAL = "cod_condicion_especial";
        public const string COD_TIPO_ASIGNACION = "cod_tipo_asignacion";
        public const string COD_GENERADOR_DIVISAS = "cod_generador_divisas";
        public const string COD_VINCULADO_ENTIDAD = "cod_vinculado_entidad";
        public const string COD_ESTADO = "cod_estado";

		#endregion

        public ContenedorDeudor()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = CEDULA_DEUDOR;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NOMBRE_DEUDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_DEUDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_CONDICION_ESPECIAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_ASIGNACION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_GENERADOR_DIVISAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_VINCULADO_ENTIDAD;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_ESTADO;
			campo.EsLlave = true;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

