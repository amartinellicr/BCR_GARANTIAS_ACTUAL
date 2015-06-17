using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorCapacidad_pago : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_CAPACIDAD_PAGO";
        public const string CEDULA_DEUDOR = "cedula_deudor";
        public const string FECHA_CAPACIDAD_PAGO = "fecha_capacidad_pago";
        public const string COD_CAPACIDAD_PAGO = "cod_capacidad_pago";
        public const string SENSIBILIDAD_TIPO_CAMBIO = "sensibilidad_tipo_cambio";

		#endregion

        public ContenedorCapacidad_pago()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = CEDULA_DEUDOR;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_CAPACIDAD_PAGO;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_CAPACIDAD_PAGO;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = SENSIBILIDAD_TIPO_CAMBIO;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

