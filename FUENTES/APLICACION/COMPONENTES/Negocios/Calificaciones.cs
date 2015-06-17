using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Calificaciones.
	/// </summary>
	public class Calificaciones
	{

        // Muy importante, esta clase no realiza coonversión de códigos, ni tampoco sea podido probar si se realiza la inserción
        // de los datos en bitácora.

		#region Metodos Publicos
		public void Crear(string strCedula, DateTime dFecha, int nTipoAsignacion, string strCategoria, string strCalificacion, string strUsuario, string strIP)
		{
			try
			{
				string strInsertarCalificacion = "INSERT INTO GAR_CALIFICACIONES " +
						 "(CEDULA_DEUDOR, FECHA_CALIFICACION, ";

				if (nTipoAsignacion != -1)
					strInsertarCalificacion += "COD_TIPO_ASIGNACION, ";


				string strFecha = dFecha.ToString("yyyyMMdd");

				strInsertarCalificacion += "COD_CATEGORIA_CALIFICACION, COD_CALIFICACION_RIESGO) " +
								  "VALUES ('" + strCedula + "', '" + strFecha + "', ";

				if (nTipoAsignacion != -1)
					strInsertarCalificacion += nTipoAsignacion + ", ";

				strInsertarCalificacion += "'" + strCategoria + "', '" + strCalificacion + "');";

				//AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strInsertarCalificacion, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						Bitacora oBitacora = new Bitacora();

						oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
						   1, null, null, null, strInsertarCalificacion, string.Empty, "cedula_deudor",
						   string.Empty,
						   strCedula);

						oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCalificacion, string.Empty, "fecha_calificacion",
						   string.Empty,
						   dFecha.ToShortDateString());

						if (nTipoAsignacion != -1)
						{
							oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
							   1, null, string.Empty, string.Empty, strInsertarCalificacion, string.Empty, "cod_tipo_asignacion",
							   string.Empty,
							   nTipoAsignacion.ToString());
						}

						oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCalificacion, string.Empty, "cod_categoria_calificacion",
						   string.Empty,
						   strCategoria);

						oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCalificacion, string.Empty, "cod_calificacion_riesgo",
						   string.Empty,
						   strCalificacion);
					}
				}
			}
			catch
			{
				throw;
			}
		}

		public void Modificar(string strCedula, DateTime dFecha, int nTipoAsignacion, string strCategoria, string strCalificacion, string strUsuario, string strIP)
		{
			try
			{
                string strFecha = dFecha.ToString("yyyyMMdd");

				string strModificarCalificacion = "UPDATE GAR_CALIFICACIONES " +
                                "SET FECHA_CALIFICACION = convert(varchar(10),'" + strFecha + "',111), " +
								"COD_TIPO_ASIGNACION = " + nTipoAsignacion + ", " +
								"COD_CATEGORIA_CALIFICACION = '" + strCategoria + "', COD_CALIFICACION_RIESGO = '" + strCalificacion + "' " + 
								"WHERE CEDULA_DEUDOR = '" + strCedula + "' AND " +
                                "FECHA_CALIFICACION = '" + strFecha + "'";
                //AccesoBD.ejecutarConsulta(strQry);

                DataSet dsCalificacion = AccesoBD.ejecutarConsulta("select fecha_calificacion, cod_tipo_asignacion, cod_categoria_calificacion, cod_categoria_riesgo" +
                    " from GAR_CALIFICACIONES" + 
                    " where cedula_deudor = '" + strCedula + "'" +
                    " and fecha_calificacion = '" + strFecha + "'");


				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strModificarCalificacion, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						if ((dsCalificacion != null) && (dsCalificacion.Tables.Count > 0) && (dsCalificacion.Tables[0].Rows.Count > 0))
						{
							Bitacora oBitacora = new Bitacora();

							if (!dsCalificacion.Tables[0].Rows[0].IsNull("fecha_calificacion"))
							{
								DateTime dFechaCalificacionObt = Convert.ToDateTime(dsCalificacion.Tables[0].Rows[0]["fecha_calificacion"].ToString());

								if (dFechaCalificacionObt != dFecha)
								{
									oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCalificacion, string.Empty, "fecha_calificacion",
									   dFechaCalificacionObt.ToShortDateString(),
									   dFecha.ToShortDateString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCalificacion, string.Empty, "fecha_calificacion",
									   string.Empty,
									   dFecha.ToShortDateString());
							}

							if (!dsCalificacion.Tables[0].Rows[0].IsNull("cod_tipo_asignacion"))
							{
								int nCodigoTipoAsignacionObt = Convert.ToInt32(dsCalificacion.Tables[0].Rows[0]["cod_tipo_asignacion"].ToString());

								if (nCodigoTipoAsignacionObt != nTipoAsignacion)
								{
									oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCalificacion, string.Empty, "cod_tipo_asignacion",
									   nCodigoTipoAsignacionObt.ToString(),
									   nTipoAsignacion.ToString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCalificacion, string.Empty, "cod_tipo_asignacion",
									   string.Empty,
									   nTipoAsignacion.ToString());
							}

							if (!dsCalificacion.Tables[0].Rows[0].IsNull("cod_categoria_calificacion"))
							{
								int nCodigoCategoriaCalificacionObt = Convert.ToInt32(dsCalificacion.Tables[0].Rows[0]["cod_categoria_calificacion"].ToString());

								if (nCodigoCategoriaCalificacionObt != Convert.ToInt32(strCalificacion))
								{
									oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCalificacion, string.Empty, "cod_categoria_calificacion",
									   nCodigoCategoriaCalificacionObt.ToString(),
									   strCalificacion);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCalificacion, string.Empty, "cod_categoria_calificacion",
									   string.Empty,
									   strCalificacion);
							}

							if (!dsCalificacion.Tables[0].Rows[0].IsNull("cod_categoria_riesgo"))
							{
								int nCodigoCategoriaRiesgoObt = Convert.ToInt32(dsCalificacion.Tables[0].Rows[0]["cod_categoria_riesgo"].ToString());

								if (nCodigoCategoriaRiesgoObt != Convert.ToInt32(strCategoria))
								{
									oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCalificacion, string.Empty, "cod_categoria_riesgo",
									   nCodigoCategoriaRiesgoObt.ToString(),
									   strCategoria);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCalificacion, string.Empty, "cod_categoria_riesgo",
									   string.Empty,
									   strCategoria);
							}
						}
					}
				}
			}
			catch
			{
				throw;
			}
		}

		public void Eliminar(string strCedula, DateTime dFecha, string strUsuario, string strIP)
		{
			try
			{
                string strFecha = dFecha.ToString("yyyyMMdd");  

				string strEliminarCalificacion = "DELETE GAR_CALIFICACIONES WHERE CEDULA_DEUDOR = '" + strCedula + "' " +
                                "AND FECHA_CALIFICACION = '" + strFecha + "'";

                string strConsultaCalificacion = "select GAR_CALIFICACIONES where CEDULA_DEUDOR = '" + strCedula + "' " +
                                "and FECHA_CALIFICACION = '" + strFecha + "'";
                //AccesoBD.ejecutarConsulta(strQry);

                //DataSet dsCalificacion = AccesoBD.ejecutarConsulta(strConsultaCalificacion);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strEliminarCalificacion, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						Bitacora oBitacora = new Bitacora();

						//if ((dsCalificacion != null) && (dsCalificacion.Tables.Count > 0) && (dsCalificacion.Tables[0].Rows.Count > 0))
						//{

						oBitacora.InsertarBitacora("GAR_CALIFICACIONES", strUsuario, strIP, null,
						   3, null, string.Empty, string.Empty, strEliminarCalificacion, string.Empty, string.Empty,
						   string.Empty,
						   string.Empty);
						//}
					}
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
