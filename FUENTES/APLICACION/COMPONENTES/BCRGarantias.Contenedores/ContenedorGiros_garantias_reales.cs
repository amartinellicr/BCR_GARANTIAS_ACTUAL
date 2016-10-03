using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorGiros_garantias_reales : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_GIROS_GARANTIAS_REALES";
        public const string COD_CONTABILIDAD = "cod_contabilidad";
        public const string COD_OFICINA = "cod_oficina";
        public const string MONTO_TASACION_ACTUALIZADA_TERRENO = "monto_tasacion_actualizada_terreno";
        public const string MONTO_TASACION_ACTUALIZADA_NO_TERRENO = "monto_tasacion_actualizada_no_terreno";
        public const string FECHA_ULTIMO_SEGUIMIENTO = "fecha_ultimo_seguimiento";
        public const string MONTO_TOTAL_AVALUO = "monto_total_avaluo";
        public const string FECHA_CONSTRUCCION = "fecha_construccion";
        public const string COD_GRADO = "cod_grado";
        public const string CEDULA_HIPOTECARIA = "cedula_hipotecaria";
        public const string CEDULA_DEUDOR = "cedula_deudor";
        public const string COD_MONEDA = "cod_moneda";
        public const string COD_PRODUCTO = "cod_producto";
        public const string NUM_OPERACION = "num_operacion";
        public const string COD_TIPO_BIEN = "cod_tipo_bien";
        public const string COD_BIEN = "cod_bien";
        public const string COD_TIPO_MITIGADOR = "cod_tipo_mitigador";
        public const string COD_TIPO_DOCUMENTO_LEGAL = "cod_tipo_documento_legal";
        public const string MONTO_MITIGADOR = "monto_mitigador";
        public const string FECHA_PRESENTACION = "fecha_presentacion";
        public const string COD_INSCRIPCION = "cod_inscripcion";
        public const string PORCENTAJE_RESPONSABILIDAD = "porcentaje_responsabilidad";
        public const string FECHA_CONSTITUCION = "fecha_constitucion";
        public const string COD_GRADO_GRAVAMEN = "cod_grado_gravamen";
        public const string COD_TIPO_ACREEDOR = "cod_tipo_acreedor";
        public const string CEDULA_ACREEDOR = "cedula_acreedor";
        public const string FECHA_VENCIMIENTO = "fecha_vencimiento";
        public const string COD_OPERACION_ESPECIAL = "cod_operacion_especial";
        public const string FECHA_VALUACION = "fecha_valuacion";
        public const string CEDULA_EMPRESA = "cedula_empresa";
        public const string COD_TIPO_EMPRESA = "cod_tipo_empresa";
        public const string CEDULA_PERITO = "cedula_perito";
        public const string COD_TIPO_PERITO = "cod_tipo_perito";
        public const string MONTO_ULTIMA_TASACION_TERRENO = "monto_ultima_tasacion_terreno";
        public const string MONTO_ULTIMA_TASACION_NO_TERRENO = "monto_ultima_tasacion_no_terreno";
        public const string PORCENTAJE_ACEPTACION = "Porcentaje_Aceptacion";

        #endregion

        public ContenedorGiros_garantias_reales()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_CONTABILIDAD;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OFICINA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_TASACION_ACTUALIZADA_TERRENO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_TASACION_ACTUALIZADA_NO_TERRENO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_ULTIMO_SEGUIMIENTO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_TOTAL_AVALUO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_CONSTRUCCION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_GRADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_HIPOTECARIA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_DEUDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_MONEDA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_PRODUCTO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NUM_OPERACION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_BIEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_BIEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_MITIGADOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_DOCUMENTO_LEGAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_MITIGADOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_PRESENTACION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_INSCRIPCION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_RESPONSABILIDAD;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_CONSTITUCION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_GRADO_GRAVAMEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_ACREEDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_ACREEDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_VENCIMIENTO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OPERACION_ESPECIAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_VALUACION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_EMPRESA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_EMPRESA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_PERITO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_PERITO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_ULTIMA_TASACION_TERRENO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_ULTIMA_TASACION_NO_TERRENO;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

