using System;
using System.Data;
using System.Data.SqlClient;

namespace BCRGARANTIAS.Datos
{
	/// <summary>
	/// Summary description for Gestor.
	/// </summary>
	public class ProcesosDatos
    {
        #region [ Control de procesos desatendidos ]

        public bool SeEjecutoProceso(string tcocProceso, DateTime tfecEjecucion)
        {
            bool fueEjecutado;

             SqlParameter[] parameters = new SqlParameter[] { 
                new SqlParameter("ReturnValue", SqlDbType.Bit),
                new SqlParameter("tcocProceso", SqlDbType.VarChar, 20), 
                new SqlParameter("tfecCorrida", SqlDbType.DateTime)
                 
                };

             parameters[0].Direction = ParameterDirection.ReturnValue;
             parameters[1].Value = tcocProceso;
             parameters[2].Value = tfecEjecucion;
             
             fueEjecutado = false;
             AccesoBD.ExecuteNonQuery("ufn_ObtenersiCorrioServicio", parameters);
             fueEjecutado = (bool) parameters[0].Value;

            return fueEjecutado;
        }
        #endregion
    }
}
