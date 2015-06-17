using System;
using System.Data;
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
            ProcesosDatos p = new ProcesosDatos();

            return p.SeEjecutoProceso(tcocProceso, tfecEjecucion);
        }
        #endregion
    }
}
