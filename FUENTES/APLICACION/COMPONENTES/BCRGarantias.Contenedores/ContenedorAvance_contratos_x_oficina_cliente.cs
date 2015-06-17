using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorAvance_contratos_x_oficina_cliente : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "RPT_AVANCE_CONTRATOS_X_OFICINA_CLIENTE";
        public const string FECHA_CORTE = "fecha_corte";
        public const string COD_OFICINA = "cod_oficina";
        public const string DES_OFICINA = "des_oficina";
        public const string TOTAL_CONTRATOS = "total_contratos";
        public const string TOTAL_CONTRATOS_COMPLETOS = "total_contratos_completos";
        public const string TOTAL_CONTRATOS_PENDIENTES = "total_contratos_pendientes";
        public const string PORCENTAJE_TOTAL_CONTRATOS_COMPLETOS = "porcentaje_total_contratos_completos";
        public const string PORCENTAJE_TOTAL_CONTRATOS_PENDIENTES = "porcentaje_total_contratos_pendientes";

		#endregion

        public ContenedorAvance_contratos_x_oficina_cliente()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = FECHA_CORTE;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OFICINA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_OFICINA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_CONTRATOS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_CONTRATOS_COMPLETOS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_CONTRATOS_PENDIENTES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_CONTRATOS_COMPLETOS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_CONTRATOS_PENDIENTES;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

