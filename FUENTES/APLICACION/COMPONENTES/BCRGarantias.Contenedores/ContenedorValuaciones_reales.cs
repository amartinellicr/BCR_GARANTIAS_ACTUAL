using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorValuaciones_reales : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_VALUACIONES_REALES";
        public const string COD_GARANTIA_REAL = "cod_garantia_real";
        public const string FECHA_VALUACION = "fecha_valuacion";
        public const string CEDULA_EMPRESA = "cedula_empresa";
        public const string CEDULA_PERITO = "cedula_perito";
        public const string MONTO_ULTIMA_TASACION_TERRENO = "monto_ultima_tasacion_terreno";
        public const string MONTO_ULTIMA_TASACION_NO_TERRENO = "monto_ultima_tasacion_no_terreno";
        public const string MONTO_TASACION_ACTUALIZADA_TERRENO = "monto_tasacion_actualizada_terreno";
        public const string MONTO_TASACION_ACTUALIZADA_NO_TERRENO = "monto_tasacion_actualizada_no_terreno";
        public const string FECHA_ULTIMO_SEGUIMIENTO = "fecha_ultimo_seguimiento";
        public const string MONTO_TOTAL_AVALUO = "monto_total_avaluo";
        public const string COD_RECOMENDACION_PERITO = "cod_recomendacion_perito";
        public const string COD_INSPECCION_MENOR_TRES_MESES = "cod_inspeccion_menor_tres_meses";
        public const string FECHA_CONSTRUCCION = "fecha_construccion";
        public const string INDICADOR_TIPO_REGISTRO = "Indicador_Tipo_Registro";
        public const string INDICADOR_ACTUALIZADO_CALCULO = "Indicador_Actualizado_Calculo";
        public const string FECHA_SEMESTRE_CALCULADO = "Fecha_Semestre_Calculado";
        public const string USUARIO_MODIFICO = "Usuario_Modifico";
        public const string FECHA_MODIFICO = "Fecha_Modifico";
        public const string FECHA_INSERTO = "Fecha_Inserto";
        public const string FECHA_REPLICA = "Fecha_Replica";
        public const string PORCENTAJE_ACEPTACION_TERRENO = "Porcentaje_Aceptacion_Terreno";
        public const string PORCENTAJE_ACEPTACION_NO_TERRENO = "Porcentaje_Aceptacion_No_Terreno";
        public const string PORCENTAJE_ACEPTACION_TERRENO_CALCULADO = "Porcentaje_Aceptacion_Terreno_Calculado";
        public const string PORCENTAJE_ACEPTACION_NO_TERRENO_CALCULADO = "Porcentaje_Aceptacion_No_Terreno_Calculado";
 

        #endregion

        public ContenedorValuaciones_reales()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_GARANTIA_REAL;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_VALUACION;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_EMPRESA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = CEDULA_PERITO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_ULTIMA_TASACION_TERRENO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = MONTO_ULTIMA_TASACION_NO_TERRENO;
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
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_RECOMENDACION_PERITO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_INSPECCION_MENOR_TRES_MESES;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_CONSTRUCCION;
			Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = INDICADOR_TIPO_REGISTRO;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = INDICADOR_ACTUALIZADO_CALCULO;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = FECHA_SEMESTRE_CALCULADO;
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
            campo.Llave = PORCENTAJE_ACEPTACION_TERRENO;
            campo.EsLlave = true;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = PORCENTAJE_ACEPTACION_NO_TERRENO;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = PORCENTAJE_ACEPTACION_TERRENO_CALCULADO;
            Campos.Agregar(campo);

            campo = new CampoBase();
            campo.Llave = PORCENTAJE_ACEPTACION_NO_TERRENO_CALCULADO;
            Campos.Agregar(campo);


            NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

