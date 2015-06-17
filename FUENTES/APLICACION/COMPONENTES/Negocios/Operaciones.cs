using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Operaciones.
	/// </summary>
	public class Operaciones
	{
		#region Metodos Publicos
		public long ObtenerConsecutivoOperacion(int nContabilidad, int nOficina, int nMoneda, 
												int nProducto, long nOperacion, string strDeudor)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_ObtenerConsecutivoOperacion", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();
					SqlDataAdapter oDataAdapter = new SqlDataAdapter();
					long nConsecutivo = 0;

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//Agrega los parametros
					oComando.Parameters.AddWithValue("@nContabilidad", nContabilidad);
					oComando.Parameters.AddWithValue("@nOficina", nOficina);
					oComando.Parameters.AddWithValue("@nMoneda", nMoneda);
					oComando.Parameters.AddWithValue("@nProducto", nProducto);
					oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
					oComando.Parameters.AddWithValue("@strDeudor", strDeudor);

					//Abre la conexion
					oConexion.Open();

					//Ejecuta el comando
					oDataAdapter.SelectCommand = oComando;
					oDataAdapter.SelectCommand.Connection = oConexion;
					oDataAdapter.Fill(dsData, "Datos");
					if (dsData.Tables["Datos"].Rows.Count > 0)
						nConsecutivo = long.Parse(dsData.Tables["Datos"].Rows[0][0].ToString());

					return nConsecutivo;
				}
			}
			catch
			{
				throw;
			}
		}

		#endregion
	}
}
