using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorGarantias_valor_x_operacion : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_GARANTIAS_VALOR_X_OPERACION";
        public const string COD_OPERACION = "cod_operacion";
        public const string COD_GARANTIA_VALOR = "cod_garantia_valor";
        public const string COD_TIPO_MITIGADOR = "cod_tipo_mitigador";
        public const string COD_TIPO_DOCUMENTO_LEGAL = "cod_tipo_documento_legal";
        public const string MONTO_MITIGADOR = "monto_mitigador";
        public const string COD_INSCRIPCION = "cod_inscripcion";
        public const string FECHA_PRESENTACION_REGISTRO = "fecha_presentacion_registro";
        public const string PORCENTAJE_RESPONSABILIDAD = "porcentaje_responsabilidad";
        public const string COD_GRADO_GRAVAMEN = "cod_grado_gravamen";
        public const string COD_GRADO_PRIORIDADES = "cod_grado_prioridades";
        public const string MONTO_PRIORIDADES = "monto_prioridades";
        public const string COD_OPERACION_ESPECIAL = "cod_operacion_especial";
        public const string COD_TIPO_ACREEDOR = "cod_tipo_acreedor";
        public const string CEDULA_ACREEDOR = "cedula_acreedor";
        public const string COD_ESTADO = "cod_estado";

		#endregion

        public ContenedorGarantias_valor_x_operacion()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_OPERACION;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_GARANTIA_VALOR;
			campo.EsLlave = true;
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
            campo.Llave = COD_INSCRIPCION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_PRESENTACION_REGISTRO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_RESPONSABILIDAD;
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
            campo.Llave = COD_OPERACION_ESPECIAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_ACREEDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_ACREEDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_ESTADO;
			campo.EsLlave = true;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}
