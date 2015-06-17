using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorSicc_prmsc : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_SICC_PRMSC";
        public const string PRMSC_ESTADO = "prmsc_estado";
        public const string PRMSC_PPASERCON = "prmsc_ppasercon";
        public const string PRMSC_PCO_CONTA = "prmsc_pco_conta";
        public const string PRMSC_PCO_IDENT = "prmsc_pco_ident";
        public const string PRMSC_PCO_MONED = "prmsc_pco_moned";
        public const string PRMSC_PCO_MSG1 = "prmsc_pco_msg1";
        public const string PRMSC_PCO_MSG2 = "prmsc_pco_msg2";
        public const string PRMSC_PCO_OFICI = "prmsc_pco_ofici";
        public const string PRMSC_PCO_PRODU = "prmsc_pco_produ";
        public const string PRMSC_PCO_USUAR = "prmsc_pco_usuar";
        public const string PRMSC_PCOESTREL = "prmsc_pcoestrel";
        public const string PRMSC_PCOSERCON = "prmsc_pcosercon";
        public const string PRMSC_PFE_INICI = "prmsc_pfe_inici";
        public const string PRMSC_PFE_MSG1 = "prmsc_pfe_msg1";
        public const string PRMSC_PFE_MSG2 = "prmsc_pfe_msg2";
        public const string PRMSC_PFE_REGIS = "prmsc_pfe_regis";
        public const string PRMSC_PFE_VENCI = "prmsc_pfe_venci";
        public const string PRMSC_PNU_OPER = "prmsc_pnu_oper";
        public const string PRMSC_PNUDOCREF = "prmsc_pnudocref";
        public const string PRMSC_PSESERCON = "prmsc_psesercon";

		#endregion

        public ContenedorSicc_prmsc()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = PRMSC_ESTADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PPASERCON;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PCO_CONTA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PCO_IDENT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PCO_MONED;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PCO_MSG1;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PCO_MSG2;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PCO_OFICI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PCO_PRODU;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PCO_USUAR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PCOESTREL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PCOSERCON;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PFE_INICI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PFE_MSG1;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PFE_MSG2;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PFE_REGIS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PFE_VENCI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PNU_OPER;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PNUDOCREF;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PRMSC_PSESERCON;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

