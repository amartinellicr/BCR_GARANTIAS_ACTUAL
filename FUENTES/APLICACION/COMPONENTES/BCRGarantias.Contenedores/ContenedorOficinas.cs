using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorOficinas : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "BCR_OFICINAS";
        public const string COD_OFICINA = "cod_oficina";
        public const string DES_OFICINA = "des_oficina";
        public const string COD_OFICINA_ASIGNADA = "cod_oficina_asignada";
        public const string COD_INDICADOR = "cod_indicador";

		#endregion

        public ContenedorOficinas()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_OFICINA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_OFICINA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OFICINA_ASIGNADA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_INDICADOR;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

