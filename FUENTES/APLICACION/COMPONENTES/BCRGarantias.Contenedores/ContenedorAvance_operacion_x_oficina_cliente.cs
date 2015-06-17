using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorAvance_operacion_x_oficina_cliente : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "RPT_AVANCE_OPERACION_X_OFICINA_CLIENTE";
        public const string FECHA_CORTE = "fecha_corte";
        public const string COD_OFICINA = "cod_oficina";
        public const string DES_OFICINA = "des_oficina";
        public const string TOTAL_OPERACIONES = "total_operaciones";
        public const string TOTAL_OPERACIONES_COMPLETAS = "total_operaciones_completas";
        public const string TOTAL_OPERACIONES_PENDIENTES = "total_operaciones_pendientes";
        public const string PORCENTAJE_TOTAL_OPERACIONES_COMPLETAS = "porcentaje_total_operaciones_completas";
        public const string PORCENTAJE_TOTAL_OPERACIONES_PENDIENTES = "porcentaje_total_operaciones_pendientes";

		#endregion

        public ContenedorAvance_operacion_x_oficina_cliente()
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
            campo.Llave = TOTAL_OPERACIONES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_OPERACIONES_COMPLETAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = TOTAL_OPERACIONES_PENDIENTES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_OPERACIONES_COMPLETAS;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_TOTAL_OPERACIONES_PENDIENTES;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

