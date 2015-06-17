using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorContratos_avance_x_oficina_cliente : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE";
        public const string FECHA_CORTE = "fecha_corte";
        public const string COD_OFICINA = "cod_oficina";
        public const string DES_OFICINA = "des_oficina";
        public const string TOTAL_GARANTIAS = "total_garantias";
        public const string TOTAL_GARANTIAS_COMPLETAS = "total_garantias_completas";
        public const string TOTAL_GARANTIAS_PENDIENTES = "total_garantias_pendientes";
        public const string PORCENTAJE_TOTAL_GARANTIAS_COMPLETAS = "porcentaje_total_garantias_completas";
        public const string PORCENTAJE_TOTAL_GARANTIAS_PENDIENTES = "porcentaje_total_garantias_pendientes";
        public const string TOTAL_GARANTIAS_FIDUCIARIAS = "total_garantias_fiduciarias";
        public const string TOTAL_GARANTIAS_FIDUCIARIAS_COMPLETAS = "total_garantias_fiduciarias_completas";
        public const string TOTAL_GARANTIAS_FIDUCIARIAS_PENDIENTES = "total_garantias_fiduciarias_pendientes";
        public const string PORCENTAJE_TOTAL_GARANTIAS_FIDUCIARIAS_COMPLETAS = "porcentaje_total_garantias_fiduciarias_completas";
        public const string PORCENTAJE_TOTAL_GARANTIAS_FIDUCIARIAS_PENDIENTES = "porcentaje_total_garantias_fiduciarias_pendientes";
        public const string TOTAL_GARANTIAS_REALES = "total_garantias_reales";
        public const string TOTAL_GARANTIAS_REALES_COMPLETAS = "total_garantias_reales_completas";
        public const string TOTAL_GARANTIAS_REALES_PENDIENTES = "total_garantias_reales_pendientes";
        public const string PORCENTAJE_TOTAL_GARANTIAS_REALES_COMPLETAS = "porcentaje_total_garantias_reales_completas";
        public const string PORCENTAJE_TOTAL_GARANTIAS_REALES_PENDIENTES = "porcentaje_total_garantias_reales_pendientes";
        public const string TOTAL_GARANTIAS_VALOR = "total_garantias_valor";
        public const string TOTAL_GARANTIAS_VALOR_COMPLETAS = "total_garantias_valor_completas";
        public const string TOTAL_GARANTIAS_VALOR_PENDIENTES = "total_garantias_valor_pendientes";
        public const string PORCENTAJE_TOTAL_GARANTIAS_VALOR_COMPLETAS = "porcentaje_total_garantias_valor_completas";
        public const string PORCENTAJE_TOTAL_GARANTIAS_VALOR_PENDIENTES = "porcentaje_total_garantias_valor_pendientes";

		#endregion

        public ContenedorContratos_avance_x_oficina_cliente()
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
            campo.Llave = TOTAL_GARANTIAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_GARANTIAS_COMPLETAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_GARANTIAS_PENDIENTES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_GARANTIAS_COMPLETAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_GARANTIAS_PENDIENTES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_GARANTIAS_FIDUCIARIAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_GARANTIAS_FIDUCIARIAS_COMPLETAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_GARANTIAS_FIDUCIARIAS_PENDIENTES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_GARANTIAS_FIDUCIARIAS_COMPLETAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_GARANTIAS_FIDUCIARIAS_PENDIENTES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_GARANTIAS_REALES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_GARANTIAS_REALES_COMPLETAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_GARANTIAS_REALES_PENDIENTES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_GARANTIAS_REALES_COMPLETAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_GARANTIAS_REALES_PENDIENTES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_GARANTIAS_VALOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_GARANTIAS_VALOR_COMPLETAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_GARANTIAS_VALOR_PENDIENTES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_GARANTIAS_VALOR_COMPLETAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_GARANTIAS_VALOR_PENDIENTES;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

