using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorGarantia_valor : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_GARANTIA_VALOR";
        public const string COD_GARANTIA_VALOR = "cod_garantia_valor";
        public const string COD_TIPO_GARANTIA = "cod_tipo_garantia";
        public const string COD_CLASE_GARANTIA = "cod_clase_garantia";
        public const string NUMERO_SEGURIDAD = "numero_seguridad";
        public const string FECHA_CONSTITUCION = "fecha_constitucion";
        public const string FECHA_VENCIMIENTO_INSTRUMENTO = "fecha_vencimiento_instrumento";
        public const string COD_CLASIFICACION_INSTRUMENTO = "cod_clasificacion_instrumento";
        public const string DES_INSTRUMENTO = "des_instrumento";
        public const string DES_SERIE_INSTRUMENTO = "des_serie_instrumento";
        public const string COD_TIPO_EMISOR = "cod_tipo_emisor";
        public const string CEDULA_EMISOR = "cedula_emisor";
        public const string PREMIO = "premio";
        public const string COD_ISIN = "cod_isin";
        public const string VALOR_FACIAL = "valor_facial";
        public const string COD_MONEDA_VALOR_FACIAL = "cod_moneda_valor_facial";
        public const string VALOR_MERCADO = "valor_mercado";
        public const string COD_MONEDA_VALOR_MERCADO = "cod_moneda_valor_mercado";
        public const string COD_TENENCIA = "cod_tenencia";
        public const string FECHA_PRESCRIPCION = "fecha_prescripcion";

		#endregion

        public ContenedorGarantia_valor()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_GARANTIA_VALOR;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_GARANTIA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_CLASE_GARANTIA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NUMERO_SEGURIDAD;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_CONSTITUCION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_VENCIMIENTO_INSTRUMENTO;
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
            campo.Llave = COD_TENENCIA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_PRESCRIPCION;
			campo.EsLlave = true;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

