using System;
using System.Collections.Generic;
using System.Text;
using LiderSoft.FrameWork.Contenedores;

namespace BCRGarantias.Contenedores
{
    public class ContenedorValuaciones_fiador : ContenedorBase
    {
        #region Constantes
        public const string NOMBRE_ENTIDAD = "GAR_VALUACIONES_FIADOR";
        public const string COD_GARANTIA_FIDUCIARIA = "cod_garantia_fiduciaria";
        public const string FECHA_VALUACION = "fecha_valuacion";
        public const string INGRESO_NETO = "ingreso_neto";
        public const string COD_TIENE_CAPACIDAD_PAGO = "cod_tiene_capacidad_pago";

		#endregion

        public ContenedorValuaciones_fiador()
		{
			CampoBase campo = new CampoBase();

			campo = new CampoBase();
            campo.Llave = COD_GARANTIA_FIDUCIARIA;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = FECHA_VALUACION;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = INGRESO_NETO;
			campo.EsLlave = true;
			Campos.Agregar(campo);

			campo = new CampoBase();
            campo.Llave = COD_TIENE_CAPACIDAD_PAGO;
			Campos.Agregar(campo);



			NombreEntidad = NOMBRE_ENTIDAD;

		}
    }
}

