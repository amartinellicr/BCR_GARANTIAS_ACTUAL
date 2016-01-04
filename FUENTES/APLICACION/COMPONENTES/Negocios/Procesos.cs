using System;
using BCRGARANTIAS.Datos;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Gestor.
    /// </summary>
    public class Procesos
	{
        #region [ Control de procesos desatendidos ]
        public static bool SeEjecutoProceso(string tcocProceso, DateTime tfecEjecucion)
        {
            ProcesosDatos procesoDatos = new ProcesosDatos();

            return procesoDatos.SeEjecutoProceso(tcocProceso, tfecEjecucion);
        }
        #endregion
    }
}
