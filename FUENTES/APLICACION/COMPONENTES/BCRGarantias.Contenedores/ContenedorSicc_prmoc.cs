using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorSicc_prmoc : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_SICC_PRMOC";
        public const string PRMOC_ESTADO = "prmoc_estado";
        public const string PRMOC_PCOCALADI = "prmoc_pcocaladi";
        public const string PRMOC_PCOMONINT = "prmoc_pcomonint";
        public const string PRMOC_PDITRAPRO = "prmoc_pditrapro";
        public const string PRMOC_PFE_APROB = "prmoc_pfe_aprob";
        public const string PRMOC_PFE_CONST = "prmoc_pfe_const";
        public const string PRMOC_PFE_CONTA = "prmoc_pfe_conta";
        public const string PRMOC_PFE_DEFIN = "prmoc_pfe_defin";
        public const string PRMOC_PFECONANT = "prmoc_pfeconant";
        public const string PRMOC_PFEGENTAB = "prmoc_pfegentab";
        public const string PRMOC_PFEINTPAG = "prmoc_pfeintpag";
        public const string PRMOC_PFELIMIDE = "prmoc_pfelimide";
        public const string PRMOC_PFEPROFLU = "prmoc_pfeproflu";
        public const string PRMOC_PFEPROPAG = "prmoc_pfepropag";
        public const string PRMOC_PFERELINT = "prmoc_pferelint";
        public const string PRMOC_PFEULTACT = "prmoc_pfeultact";
        public const string PRMOC_PFEULTCAL = "prmoc_pfeultcal";
        public const string PRMOC_PFEULTPAG = "prmoc_pfeultpag";
        public const string PRMOC_PFEVENABO = "prmoc_pfevenabo";
        public const string PRMOC_PFEVENINT = "prmoc_pfevenint";
        public const string PRMOC_PFEVIGTAS = "prmoc_pfevigtas";
        public const string PRMOC_PMO_GIRAD = "prmoc_pmo_girad";
        public const string PRMOC_PMO_ORIGI = "prmoc_pmo_origi";
        public const string PRMOC_PMOCREPEN = "prmoc_pmocrepen";
        public const string PRMOC_PMODEBPEN = "prmoc_pmodebpen";
        public const string PRMOC_PMOINTDIA = "prmoc_pmointdia";
        public const string PRMOC_PMOINTGAN = "prmoc_pmointgan";
        public const string PRMOC_PNU_CONTR = "prmoc_pnu_contr";
        public const string PRMOC_PNU_DIREC = "prmoc_pnu_direc";
        public const string PRMOC_PNU_OPER = "prmoc_pnu_oper";
        public const string PRMOC_PNU_SOLIC = "prmoc_pnu_solic";
        public const string PRMOC_PSA_ACTUAL = "prmoc_psa_actual";
        public const string PRMOC_PSA_AYER = "prmoc_psa_ayer";
        public const string PRMOC_PSA_IDEAL = "prmoc_psa_ideal";
        public const string PRMOC_PSAACTMEA = "prmoc_psaactmea";
        public const string PRMOC_PSE_BASE = "prmoc_pse_base";
        public const string PRMOC_PSE_CEI = "prmoc_pse_cei";
        public const string PRMOC_PSE_CERRAR = "prmoc_pse_cerrar";
        public const string PRMOC_PSE_EMPLE = "prmoc_pse_emple";
        public const string PRMOC_PSE_INTERV = "prmoc_pse_interv";
        public const string PRMOC_PSE_PROCES = "prmoc_pse_proces";
        public const string PRMOC_PSE_PRORR = "prmoc_pse_prorr";
        public const string PRMOC_PSE_SCACS = "prmoc_pse_scacs";
        public const string PRMOC_PSEARRPAG = "prmoc_psearrpag";
        public const string PRMOC_PSECOBAUT = "prmoc_psecobaut";
        public const string PRMOC_PSECOMADM = "prmoc_psecomadm";
        public const string PRMOC_PSEINTADE = "prmoc_pseintade";
        public const string PRMOC_PSEPAGPEN = "prmoc_psepagpen";
        public const string PRMOC_PSEPROCJ = "prmoc_pseprocj";
        public const string PRMOC_PSERECTAB = "prmoc_pserectab";
        public const string PRMOC_PSESOLARR = "prmoc_psesolarr";
        public const string PRMOC_PTA_INTER = "prmoc_pta_inter";
        public const string PRMOC_PTA_PLUS = "prmoc_pta_plus";
        public const string PRMOC_PTACOMADM = "prmoc_ptacomadm";
        public const string PRMOC_PVACOMADM = "prmoc_pvacomadm";
        public const string PRMOC_SCO_IDENT = "prmoc_sco_ident";
        public const string PRMOC_SCOANALIS = "prmoc_scoanalis";
        public const string PRMOC_SCOEJECUE = "prmoc_scoejecue";
        public const string PRMOC_PCOCALOPE = "prmoc_pcocalope";
        public const string PRMOC_PNO_CLIEN = "prmoc_pno_clien";
        public const string PRMOC_PNU_ATRAS = "prmoc_pnu_atras";
        public const string PRMOC_DCO_OFICI = "prmoc_dco_ofici";
        public const string PRMOC_PCO_APROB = "prmoc_pco_aprob";
        public const string PRMOC_PCO_CONTA = "prmoc_pco_conta";
        public const string PRMOC_PCO_DESTI = "prmoc_pco_desti";
        public const string PRMOC_PCO_DIVIS = "prmoc_pco_divis";
        public const string PRMOC_PCO_MONED = "prmoc_pco_moned";
        public const string PRMOC_PCO_OFICI = "prmoc_pco_ofici";
        public const string PRMOC_PCO_OFICON = "prmoc_pco_oficon";
        public const string PRMOC_PCO_PLAZO = "prmoc_pco_plazo";
        public const string PRMOC_PCO_POLIZ = "prmoc_pco_poliz";
        public const string PRMOC_PCO_PRODU = "prmoc_pco_produ";
        public const string PRMOC_PCOALTRIE = "prmoc_pcoaltrie";
        public const string PRMOC_PCOCALINT = "prmoc_pcocalint";
        public const string PRMOC_PCOCTAMAY = "prmoc_pcoctamay";
        public const string PRMOC_PCOESTLOG = "prmoc_pcoestlog";
        public const string PRMOC_PCOESTPRES = "prmoc_pcoestpres";
        public const string PRMOC_PCOFREFLU = "prmoc_pcofreflu";
        public const string PRMOC_PCOGRACON = "prmoc_pcogracon";
        public const string PRMOC_PCOINSAGR = "prmoc_pcoinsagr";
        public const string PRMOC_PCOINTFLU = "prmoc_pcointflu";
        public const string PRMOC_PCOLINCRE = "prmoc_pcolincre";

		#endregion

        public ContenedorSicc_prmoc()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = PRMOC_ESTADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOCALADI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOMONINT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PDITRAPRO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFE_APROB;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFE_CONST;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFE_CONTA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFE_DEFIN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFECONANT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFEGENTAB;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFEINTPAG;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFELIMIDE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFEPROFLU;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFEPROPAG;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFERELINT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFEULTACT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFEULTCAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFEULTPAG;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFEVENABO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFEVENINT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PFEVIGTAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PMO_GIRAD;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PMO_ORIGI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PMOCREPEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PMODEBPEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PMOINTDIA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PMOINTGAN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PNU_CONTR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PNU_DIREC;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PNU_OPER;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PNU_SOLIC;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSA_ACTUAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSA_AYER;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSA_IDEAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSAACTMEA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSE_BASE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSE_CEI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSE_CERRAR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSE_EMPLE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSE_INTERV;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSE_PROCES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSE_PRORR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSE_SCACS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSEARRPAG;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSECOBAUT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSECOMADM;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSEINTADE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSEPAGPEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSEPROCJ;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSERECTAB;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PSESOLARR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PTA_INTER;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PTA_PLUS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PTACOMADM;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PVACOMADM;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_SCO_IDENT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_SCOANALIS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_SCOEJECUE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOCALOPE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PNO_CLIEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PNU_ATRAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_DCO_OFICI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCO_APROB;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCO_CONTA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCO_DESTI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCO_DIVIS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCO_MONED;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCO_OFICI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCO_OFICON;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCO_PLAZO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCO_POLIZ;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCO_PRODU;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOALTRIE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOCALINT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOCTAMAY;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOESTLOG;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOESTPRES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOFREFLU;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOGRACON;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOINSAGR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOINTFLU;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMOC_PCOLINCRE;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

