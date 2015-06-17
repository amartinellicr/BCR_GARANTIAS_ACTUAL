using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorSicc_bsmcl : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_SICC_BSMCL";
        public const string BSMCL_ESTADO = "bsmcl_estado";
        public const string BSMCL_SNO_CLIEN = "bsmcl_sno_clien";
        public const string BSMCL_SCO_IDENT = "bsmcl_sco_ident";
        public const string BSMCL_SCO_SEXO = "bsmcl_sco_sexo";
        public const string BSMCL_SCOACTECO = "bsmcl_scoacteco";
        public const string BSMCL_SCOAUTBPE = "bsmcl_scoautbpe";
        public const string BSMCL_SCOESTCIV = "bsmcl_scoestciv";
        public const string BSMCL_SCOPERCLI = "bsmcl_scopercli";
        public const string BSMCL_SCOSECECO = "bsmcl_scosececo";
        public const string BSMCL_SCOTIPCLI = "bsmcl_scotipcli";
        public const string BSMCL_SCOTIPIDE = "bsmcl_scotipide";
        public const string BSMCL_SCOTIPPER = "bsmcl_scotipper";
        public const string BSMCL_SFE_NACIM = "bsmcl_sfe_nacim";
        public const string BSMCL_SSECLICT = "bsmcl_sseclict";

		#endregion

        public ContenedorSicc_bsmcl()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = BSMCL_ESTADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SNO_CLIEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SCO_IDENT;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SCO_SEXO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SCOACTECO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SCOAUTBPE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SCOESTCIV;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SCOPERCLI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SCOSECECO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SCOTIPCLI;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SCOTIPIDE;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SCOTIPPER;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SFE_NACIM;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = BSMCL_SSECLICT;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

