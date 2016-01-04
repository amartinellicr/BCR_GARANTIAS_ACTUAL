using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorGarantia_real : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_GARANTIA_REAL";
        public const string COD_GARANTIA_REAL = "cod_garantia_real";
        public const string COD_TIPO_GARANTIA = "cod_tipo_garantia";
        public const string COD_CLASE_GARANTIA = "cod_clase_garantia";
        public const string COD_TIPO_GARANTIA_REAL = "cod_tipo_garantia_real";
        public const string COD_PARTIDO = "cod_partido";
        public const string NUMERO_FINCA = "numero_finca";
        public const string COD_GRADO = "cod_grado";
        public const string CEDULA_HIPOTECARIA = "cedula_hipotecaria";
        public const string COD_CLASE_BIEN = "cod_clase_bien";
        public const string NUM_PLACA_BIEN = "num_placa_bien";
        public const string COD_TIPO_BIEN = "cod_tipo_bien";
        public const string IDENTIFICACION_SICC = "Identificacion_Sicc";
        public const string IDENTIFICACION_ALFANUMERICA_SICC = "Identificacion_Alfanumerica_Sicc";
        public const string INDICADOR_VIVIENDA_HABITADA_DEUDOR = "Indicador_Vivienda_Habitada_Deudor";
        public const string USUARIO_MODIFICO = "Usuario_Modifico";
        public const string FECHA_MODIFICO = "Fecha_Modifico";
        public const string FECHA_INSERTO = "Fecha_Inserto";
        public const string FECHA_REPLICA = "Fecha_Replica";

   
        #endregion

        public ContenedorGarantia_real()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_GARANTIA_REAL;
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
            campo.Llave = COD_TIPO_GARANTIA_REAL;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_PARTIDO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NUMERO_FINCA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_GRADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_HIPOTECARIA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_CLASE_BIEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = NUM_PLACA_BIEN;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_BIEN;
			Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = IDENTIFICACION_SICC;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = IDENTIFICACION_ALFANUMERICA_SICC;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = INDICADOR_VIVIENDA_HABITADA_DEUDOR;
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


            NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

