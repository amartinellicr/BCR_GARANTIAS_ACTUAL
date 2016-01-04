using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorGarantias_reales_x_operacion : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_GARANTIAS_REALES_X_OPERACION";
        public const string COD_OPERACION = "cod_operacion";
        public const string COD_GARANTIA_REAL = "cod_garantia_real";
        public const string COD_TIPO_MITIGADOR = "cod_tipo_mitigador";
        public const string COD_TIPO_DOCUMENTO_LEGAL = "cod_tipo_documento_legal";
        public const string MONTO_MITIGADOR = "monto_mitigador";
        public const string COD_INSCRIPCION = "cod_inscripcion";
        public const string FECHA_PRESENTACION = "fecha_presentacion";
        public const string PORCENTAJE_RESPONSABILIDAD = "porcentaje_responsabilidad";
        public const string COD_GRADO_GRAVAMEN = "cod_grado_gravamen";
        public const string COD_OPERACION_ESPECIAL = "cod_operacion_especial";
        public const string FECHA_CONSTITUCION = "fecha_constitucion";
        public const string FECHA_VENCIMIENTO = "fecha_vencimiento";
        public const string COD_TIPO_ACREEDOR = "cod_tipo_acreedor";
        public const string CEDULA_ACREEDOR = "cedula_acreedor";
        public const string COD_LIQUIDEZ = "cod_liquidez";
        public const string COD_TENENCIA = "cod_tenencia";
        public const string COD_MONEDA = "cod_moneda";
        public const string FECHA_PRESCRIPCION = "fecha_prescripcion";
        public const string COD_ESTADO = "cod_estado";
        public const string FECHA_VALUACION_SICC = "Fecha_Valuacion_SICC";
        public const string USUARIO_MODIFICO = "Usuario_Modifico";
        public const string FECHA_MODIFICO = "Fecha_Modifico";
        public const string FECHA_INSERTO = "Fecha_Inserto";
        public const string FECHA_REPLICA = "Fecha_Replica";
        public const string PORCENTAJE_ACEPTACION = "Porcentaje_Aceptacion";

        
        
        #endregion

        public ContenedorGarantias_reales_x_operacion()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_OPERACION;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_GARANTIA_REAL;
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
            campo.Llave = FECHA_PRESENTACION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = PORCENTAJE_RESPONSABILIDAD;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_GRADO_GRAVAMEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OPERACION_ESPECIAL;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_CONSTITUCION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_VENCIMIENTO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_ACREEDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_ACREEDOR;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_LIQUIDEZ;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TENENCIA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_MONEDA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_PRESCRIPCION;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_ESTADO;
			campo.EsLlave = true;
			Campos.Agregar(campo);
            
            campo = new CampoBase();
            campo.Llave = FECHA_VALUACION_SICC;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = USUARIO_MODIFICO;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = FECHA_MODIFICO;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = FECHA_INSERTO;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = FECHA_REPLICA;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = PORCENTAJE_ACEPTACION;
            Campos.Agregar(campo);

            NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

