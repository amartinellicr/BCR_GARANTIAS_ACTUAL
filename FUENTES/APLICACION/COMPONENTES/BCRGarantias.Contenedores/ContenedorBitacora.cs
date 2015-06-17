using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorBitacora : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_BITACORA";
        public const string DES_TABLA = "des_tabla";
        public const string COD_USUARIO = "cod_usuario";
        public const string COD_IP = "cod_ip";
        public const string COD_OFICINA = "cod_oficina";
        public const string COD_OPERACION = "cod_operacion";
        public const string FECHA_HORA = "fecha_hora";
        public const string COD_CONSULTA = "cod_consulta";
        public const string COD_TIPO_GARANTIA = "cod_tipo_garantia";
        public const string COD_GARANTIA = "cod_garantia";
        public const string COD_OPERACION_CREDITICIA = "cod_operacion_crediticia";
        public const string COD_CONSULTA2 = "cod_consulta2";
        public const string DES_CAMPO_AFECTADO = "des_campo_afectado";
        public const string EST_ANTERIOR_CAMPO_AFECTADO = "est_anterior_campo_afectado";
        public const string EST_ACTUAL_CAMPO_AFECTADO = "est_actual_campo_afectado";

		#endregion

        public ContenedorBitacora()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = DES_TABLA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_USUARIO;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_IP;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OFICINA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OPERACION;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_HORA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_CONSULTA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIPO_GARANTIA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_GARANTIA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_OPERACION_CREDITICIA;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_CONSULTA2;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = DES_CAMPO_AFECTADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = EST_ANTERIOR_CAMPO_AFECTADO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = EST_ACTUAL_CAMPO_AFECTADO;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

