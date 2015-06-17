using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorSicc_bsmpc : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_SICC_BSMPC";
        public const string BSMPC_ESTADO = "bsmpc_estado";
        public const string BSMPC_ACOIDEREG = "bsmpc_acoidereg";
        public const string BSMPC_TMO2IND08 = "bsmpc_tmo2ind08";
        public const string BSMPC_TMO2IND09 = "bsmpc_tmo2ind09";
        public const string BSMPC_TMO3IND08 = "bsmpc_tmo3ind08";
        public const string BSMPC_TMO3IND09 = "bsmpc_tmo3ind09";
        public const string BSMPC_TMO4IND08 = "bsmpc_tmo4ind08";
        public const string BSMPC_TMO4IND09 = "bsmpc_tmo4ind09";
        public const string BSMPC_AFE_TRANS = "bsmpc_afe_trans";
        public const string BSMPC_AFERELTRA = "bsmpc_afereltra";
        public const string BSMPC_AFE1IND10 = "bsmpc_afe1ind10";
        public const string BSMPC_AHO_TRANS = "bsmpc_aho_trans";
        public const string BSMPC_ASEINDI01 = "bsmpc_aseindi01";
        public const string BSMPC_ASEINDI02 = "bsmpc_aseindi02";
        public const string BSMPC_ASEINDI03 = "bsmpc_aseindi03";
        public const string BSMPC_ASEINDI04 = "bsmpc_aseindi04";
        public const string BSMPC_ASEINDI05 = "bsmpc_aseindi05";
        public const string BSMPC_ASEINDI06 = "bsmpc_aseindi06";
        public const string BSMPC_ASEINDI07 = "bsmpc_aseindi07";
        public const string BSMPC_ASEINDI08 = "bsmpc_aseindi08";
        public const string BSMPC_ASEINDI09 = "bsmpc_aseindi09";
        public const string BSMPC_ASEINDI10 = "bsmpc_aseindi10";
        public const string BSMPC_DCO_OFICI = "bsmpc_dco_ofici";
        public const string BSMPC_SCO_IDENT = "bsmpc_sco_ident";
        public const string BSMPC_TMO_PONDE = "bsmpc_tmo_ponde";
        public const string BSMPC_TMO1IND01 = "bsmpc_tmo1ind01";
        public const string BSMPC_TMO1IND02 = "bsmpc_tmo1ind02";
        public const string BSMPC_TMO1IND03 = "bsmpc_tmo1ind03";
        public const string BSMPC_TMO1IND04 = "bsmpc_tmo1ind04";
        public const string BSMPC_TMO1IND06 = "bsmpc_tmo1ind06";
        public const string BSMPC_TMO1IND08 = "bsmpc_tmo1ind08";
        public const string BSMPC_TMO1IND09 = "bsmpc_tmo1ind09";

		#endregion

        public ContenedorSicc_bsmpc()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = BSMPC_ESTADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_ACOIDEREG;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO2IND08;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO2IND09;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO3IND08;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO3IND09;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO4IND08;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO4IND09;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_AFE_TRANS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_AFERELTRA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_AFE1IND10;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_AHO_TRANS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_ASEINDI01;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_ASEINDI02;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_ASEINDI03;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_ASEINDI04;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_ASEINDI05;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_ASEINDI06;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_ASEINDI07;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_ASEINDI08;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_ASEINDI09;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_ASEINDI10;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_DCO_OFICI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_SCO_IDENT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO_PONDE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO1IND01;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO1IND02;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO1IND03;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO1IND04;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO1IND06;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO1IND08;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMPC_TMO1IND09;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

