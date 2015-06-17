using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorGiros_garantias_valor : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_GIROS_GARANTIAS_VALOR";
        public const string COD_CONTABILIDAD = "cod_contabilidad";
        public const string COD_OFICINA = "cod_oficina";
        public const string COD_ISIN = "cod_isin";
        public const string VALOR_FACIAL = "valor_facial";
        public const string COD_MONEDA_VALOR_FACIAL = "cod_moneda_valor_facial";
        public const string VALOR_MERCADO = "valor_mercado";
        public const string COD_MONEDA_VALOR_MERCADO = "cod_moneda_valor_mercado";
        public const string MONTO_RESPONSABILIDAD = "monto_responsabilidad";
        public const string COD_MONEDA_GARANTIA = "cod_moneda_garantia";
        public const string CEDULA_DEUDOR = "cedula_deudor";
        public const string NOMBRE_DEUDOR = "nombre_deudor";
        public const string OFICINA_DEUDOR = "oficina_deudor";
        public const string COD_MONEDA = "cod_moneda";
        public const string COD_PRODUCTO = "cod_producto";
        public const string NUM_OPERACION = "num_operacion";
        public const string NUMERO_SEGURIDAD = "numero_seguridad";
        public const string COD_TIPO_MITIGADOR = "cod_tipo_mitigador";
        public const string COD_TIPO_DOCUMENTO_LEGAL = "cod_tipo_documento_legal";
        public const string MONTO_MITIGADOR = "monto_mitigador";
        public const string FECHA_PRESENTACION = "fecha_presentacion";
        public const string COD_INSCRIPCION = "cod_inscripcion";
        public const string PORCENTAJE_RESPONSABILIDAD = "porcentaje_responsabilidad";
        public const string FECHA_CONSTITUCION = "fecha_constitucion";
        public const string COD_GRADO_GRAVAMEN = "cod_grado_gravamen";
        public const string COD_GRADO_PRIORIDADES = "cod_grado_prioridades";
        public const string MONTO_PRIORIDADES = "monto_prioridades";
        public const string COD_TIPO_ACREEDOR = "cod_tipo_acreedor";
        public const string CEDULA_ACREEDOR = "cedula_acreedor";
        public const string FECHA_VENCIMIENTO = "fecha_vencimiento";
        public const string COD_OPERACION_ESPECIAL = "cod_operacion_especial";
        public const string COD_CLASIFICACION_INSTRUMENTO = "cod_clasificacion_instrumento";
        public const string DES_INSTRUMENTO = "des_instrumento";
        public const string DES_SERIE_INSTRUMENTO = "des_serie_instrumento";
        public const string COD_TIPO_EMISOR = "cod_tipo_emisor";
        public const string CEDULA_EMISOR = "cedula_emisor";
        public const string PREMIO = "premio";

		#endregion

        public ContenedorGiros_garantias_valor()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_CONTABILIDAD;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OFICINA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_ISIN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = VALOR_FACIAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_MONEDA_VALOR_FACIAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = VALOR_MERCADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_MONEDA_VALOR_MERCADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_RESPONSABILIDAD;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_MONEDA_GARANTIA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_DEUDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NOMBRE_DEUDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = OFICINA_DEUDOR;
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
            campo.Llave = NUMERO_SEGURIDAD;
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
            campo.Llave = COD_GRADO_PRIORIDADES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_PRIORIDADES;
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
            campo.Llave = COD_CLASIFICACION_INSTRUMENTO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_INSTRUMENTO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_SERIE_INSTRUMENTO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_EMISOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_EMISOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PREMIO;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

