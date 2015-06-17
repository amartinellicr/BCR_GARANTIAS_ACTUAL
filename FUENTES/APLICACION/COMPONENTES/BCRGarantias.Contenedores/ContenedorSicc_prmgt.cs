using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorSicc_prmgt : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_SICC_PRMGT";
        public const string PRMGT_ESTADO = "prmgt_estado";
        public const string PRMGT_PCO_ADIC1 = "prmgt_pco_adic1";
        public const string PRMGT_PCO_ADIC2 = "prmgt_pco_adic2";
        public const string PRMGT_PCO_CONTA = "prmgt_pco_conta";
        public const string PRMGT_PCO_GRADO = "prmgt_pco_grado";
        public const string PRMGT_PCO_MONED = "prmgt_pco_moned";
        public const string PRMGT_PCO_MONGAR = "prmgt_pco_mongar";
        public const string PRMGT_PCO_OFICI = "prmgt_pco_ofici";
        public const string PRMGT_PCO_PRODU = "prmgt_pco_produ";
        public const string PRMGT_PCOCLAGAR = "prmgt_pcoclagar";
        public const string PRMGT_PCOLIQGAR = "prmgt_pcoliqgar";
        public const string PRMGT_PCOTENGAR = "prmgt_pcotengar";
        public const string PRMGT_PFE_ADIC1 = "prmgt_pfe_adic1";
        public const string PRMGT_PFE_PRESCR = "prmgt_pfe_prescr";
        public const string PRMGT_PFEAVAING = "prmgt_pfeavaing";
        public const string PRMGT_PFEULTINS = "prmgt_pfeultins";
        public const string PRMGT_PMOAVAING = "prmgt_pmoavaing";
        public const string PRMGT_PMORESGAR = "prmgt_pmoresgar";
        public const string PRMGT_PNU_ASIEN = "prmgt_pnu_asien";
        public const string PRMGT_PNU_FOLIO = "prmgt_pnu_folio";
        public const string PRMGT_PNU_OPER = "prmgt_pnu_oper";
        public const string PRMGT_PNU_PART = "prmgt_pnu_part";
        public const string PRMGT_PNU_TOMO = "prmgt_pnu_tomo";
        public const string PRMGT_PNUIDEGAR = "prmgt_pnuidegar";
        public const string PRMGT_PSE_ADIC1 = "prmgt_pse_adic1";

		#endregion

        public ContenedorSicc_prmgt()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = PRMGT_ESTADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PCO_ADIC1;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PCO_ADIC2;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PCO_CONTA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PCO_GRADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PCO_MONED;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PCO_MONGAR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PCO_OFICI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PCO_PRODU;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PCOCLAGAR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PCOLIQGAR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PCOTENGAR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PFE_ADIC1;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PFE_PRESCR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PFEAVAING;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PFEULTINS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PMOAVAING;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PMORESGAR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PNU_ASIEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PNU_FOLIO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PNU_OPER;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PNU_PART;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PNU_TOMO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PNUIDEGAR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMGT_PSE_ADIC1;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

