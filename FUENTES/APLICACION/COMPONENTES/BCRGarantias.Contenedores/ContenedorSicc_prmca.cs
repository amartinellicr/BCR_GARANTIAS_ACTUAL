using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorSicc_prmca : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_SICC_PRMCA";
        public const string PRMCA_ESTADO = "prmca_estado";
        public const string PRMCA_PCO_APROB = "prmca_pco_aprob";
        public const string PRMCA_PNU_CONTR = "prmca_pnu_contr";
        public const string PRMCA_PNUCTACTE = "prmca_pnuctacte";
        public const string PRMCA_PNUDIGVER = "prmca_pnudigver";
        public const string PRMCA_PSA_CONTA = "prmca_psa_conta";
        public const string PRMCA_PSA_DISCON = "prmca_psa_discon";
        public const string PRMCA_PSE_CONTAB = "prmca_pse_contab";
        public const string PRMCA_PSE_VAL01 = "prmca_pse_val01";
        public const string PRMCA_PSE_VAL02 = "prmca_pse_val02";
        public const string PRMCA_PSE_VAL03 = "prmca_pse_val03";
        public const string PRMCA_PTATASPIS = "prmca_ptataspis";
        public const string PRMCA_PCO_APRO2 = "prmca_pco_apro2";
        public const string PRMCA_PCO_CONTA = "prmca_pco_conta";
        public const string PRMCA_PCO_IDENT = "prmca_pco_ident";
        public const string PRMCA_PCO_MONED = "prmca_pco_moned";
        public const string PRMCA_PCO_NUM01 = "prmca_pco_num01";
        public const string PRMCA_PCO_NUM02 = "prmca_pco_num02";
        public const string PRMCA_PCO_NUM03 = "prmca_pco_num03";
        public const string PRMCA_PCO_OFICI = "prmca_pco_ofici";
        public const string PRMCA_PCO_PRODUC = "prmca_pco_produc";
        public const string PRMCA_PCO_TIPCRE = "prmca_pco_tipcre";
        public const string PRMCA_PCOCLACON = "prmca_pcoclacon";
        public const string PRMCA_PCOESTCRE = "prmca_pcoestcre";
        public const string PRMCA_PCOINTFLU = "prmca_pcointflu";
        public const string PRMCA_PCOOFICTA = "prmca_pcooficta";
        public const string PRMCA_PCOTIPCON = "prmca_pcotipcon";
        public const string PRMCA_PFE_CONST = "prmca_pfe_const";
        public const string PRMCA_PFE_DEFIN = "prmca_pfe_defin";
        public const string PRMCA_PFE_REGIS = "prmca_pfe_regis";
        public const string PRMCA_PMO_MAXIM = "prmca_pmo_maxim";
        public const string PRMCA_PMO_MON01 = "prmca_pmo_mon01";
        public const string PRMCA_PMO_MON02 = "prmca_pmo_mon02";
        public const string PRMCA_PMO_MON03 = "prmca_pmo_mon03";
        public const string PRMCA_PMO_RESERV = "prmca_pmo_reserv";
        public const string PRMCA_PMO_UTILIZ = "prmca_pmo_utiliz";

		#endregion

        public ContenedorSicc_prmca()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = PRMCA_ESTADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCO_APROB;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PNU_CONTR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PNUCTACTE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PNUDIGVER;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PSA_CONTA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PSA_DISCON;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PSE_CONTAB;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PSE_VAL01;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PSE_VAL02;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PSE_VAL03;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PTATASPIS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCO_APRO2;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCO_CONTA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCO_IDENT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCO_MONED;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCO_NUM01;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCO_NUM02;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCO_NUM03;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCO_OFICI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCO_PRODUC;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCO_TIPCRE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCOCLACON;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCOESTCRE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCOINTFLU;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCOOFICTA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PCOTIPCON;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PFE_CONST;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PFE_DEFIN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PFE_REGIS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PMO_MAXIM;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PMO_MON01;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PMO_MON02;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PMO_MON03;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PMO_RESERV;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMCA_PMO_UTILIZ;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

