using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorSicc_prhcs : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_SICC_PRHCS";
        public const string PRHCS_ESTADO = "prhcs_estado";
        public const string PRHCS_PCO_CALIF = "prhcs_pco_calif";
        public const string PRHCS_PCOIDESUG = "prhcs_pcoidesug";
        public const string PRHCS_PCO_CLIEN = "prhcs_pco_clien";
        public const string PRHCS_PCOTIPCAL = "prhcs_pcotipcal";
        public const string PRHCS_PCOUSUREG = "prhcs_pcousureg";
        public const string PRHCS_PFE_REGIS = "prhcs_pfe_regis";

		#endregion

        public ContenedorSicc_prhcs()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = PRHCS_ESTADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRHCS_PCO_CALIF;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRHCS_PCOIDESUG;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRHCS_PCO_CLIEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRHCS_PCOTIPCAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRHCS_PCOUSUREG;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRHCS_PFE_REGIS;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

