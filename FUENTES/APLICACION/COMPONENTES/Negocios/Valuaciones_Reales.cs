using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Web;
using System.Configuration;
using System.Diagnostics;
using System.Xml;
using System.IO;
using System.Reflection;
using System.Text;

using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;


namespace BCRGARANTIAS.Negocios
{

    /// <summary>
	/// Summary description for Valuaciones_Reales.
	/// </summary>
	public class Valuaciones_Reales
    {

        #region Constantes

        private const string _codigo    = "CODIGO";
        private const string _mensaje   = "MENSAJE";
        private const string _avaluos   = "AVALUOS";
        private const string _avaluo    = "AVALUO";

        #endregion Constantes

        #region Variables Globales

        private string mstrGarantia             = "-";
        private string mstrOperacionCrediticia  = "-";

        #endregion

        #region Metodos Publicos

        public void Crear(long nGarantiaReal, string dFechaValuacion, string strCedulaEmpresa,
                          string strCedulaPerito, decimal nMontoUltTasacionTerreno, decimal nMontoUltTasacionNoTerreno,
                          decimal nMontoTasacionActTerreno, decimal nMontoTasacionActNoTerreno,
                          string dFechaUltSeguimiento, decimal nMontoTotalAvaluo, int nRecomendacion,
						  int nInspeccion, string dFechaConstruccion, string strUsuario, string strIP)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_InsertarValuacionReal", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();

					string strFechaValuacion = "";

					if (dFechaValuacion != "")
						strFechaValuacion = dFechaValuacion.Substring(6, 4).ToString() + "/" +
											dFechaValuacion.Substring(3, 2).ToString() + "/" +
											dFechaValuacion.Substring(0, 2).ToString();

					string strFechaUltSeguimiento = "";

					if (dFechaUltSeguimiento != "")
						strFechaUltSeguimiento = dFechaUltSeguimiento.Substring(6, 4).ToString() + "/" +
												 dFechaUltSeguimiento.Substring(3, 2).ToString() + "/" +
												 dFechaUltSeguimiento.Substring(0, 2).ToString();

					string strFechaConstruccion = "";

					if (dFechaConstruccion != "")
						strFechaConstruccion = dFechaConstruccion.Substring(6, 4).ToString() + "/" +
												dFechaConstruccion.Substring(3, 2).ToString() + "/" +
												dFechaConstruccion.Substring(0, 2).ToString();

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//Agrega los parametros
					oComando.Parameters.AddWithValue("@nGarantiaReal", nGarantiaReal);
					oComando.Parameters.AddWithValue("@dFechaValuacion", DateTime.Parse(strFechaValuacion));

					if (strCedulaEmpresa.Length > 0)
						oComando.Parameters.AddWithValue("@strCedulaEmpresa", strCedulaEmpresa);

					if (strCedulaPerito.Length > 0)
						oComando.Parameters.AddWithValue("@strCedulaPerito", strCedulaPerito);

					if (nMontoUltTasacionTerreno > 0)
						oComando.Parameters.AddWithValue("@nMontoUltimaTasacionTerreno", nMontoUltTasacionTerreno);

					if (nMontoUltTasacionNoTerreno > 0)
						oComando.Parameters.AddWithValue("@nMontoUltimaTasacionNoTerreno", nMontoUltTasacionNoTerreno);

					if (nMontoTasacionActTerreno > 0)
						oComando.Parameters.AddWithValue("@nMontoTasacionActualizadaTerreno", nMontoTasacionActTerreno);

					if (nMontoTasacionActNoTerreno > 0)
						oComando.Parameters.AddWithValue("@nMontoTasacionActualizadaNoTerreno", nMontoTasacionActNoTerreno);

					if (strFechaUltSeguimiento != "")
						oComando.Parameters.AddWithValue("@dFechaUltimoSeguimiento", DateTime.Parse(strFechaUltSeguimiento));

					//				if (dFechaUltSeguimiento != DateTime.Parse("1900-01-01"))
					//					oComando.Parameters.AddWithValue("@dFechaUltimoSeguimiento",strFechaUltSeguimiento);

					oComando.Parameters.AddWithValue("@nMontoTotalAvaluo", nMontoTotalAvaluo);
					oComando.Parameters.AddWithValue("@nRecomendacion", nRecomendacion);
					oComando.Parameters.AddWithValue("@nInspeccion", nInspeccion);

					if (dFechaConstruccion != "")
						oComando.Parameters.AddWithValue("@dFechaConstruccion", DateTime.Parse(strFechaConstruccion));

					//				if (dFechaConstruccion != DateTime.Parse("1900-01-01"))
					//					oComando.Parameters.AddWithValue("@dFechaConstruccion",strFechaConstruccion);

					oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
					oComando.Parameters.AddWithValue("@strIP", strIP);
					//oComando.Parameters.AddWithValue("@nOficina",nOficina);	

					//Abre la conexion
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						DataSet dsValuacionReal = AccesoBD.ejecutarConsulta("select 1" +
							" from " + ContenedorValuaciones_reales.NOMBRE_ENTIDAD +
							" where " + ContenedorValuaciones_reales.COD_GARANTIA_REAL + " = " + nGarantiaReal.ToString() +
							" and " + ContenedorValuaciones_reales.FECHA_VALUACION + " = " + dFechaValuacion);


						if ((dsValuacionReal == null) || (dsValuacionReal.Tables.Count == 0) || (dsValuacionReal.Tables[0].Rows.Count == 0))
						{

							Bitacora oBitacora = new Bitacora();

							TraductordeCodigos oTraductor = new TraductordeCodigos();

							#region Obtener Datos Relevantes

							CGarantiaReal oGarantia = CGarantiaReal.Current;

							if (oGarantia != null)
							{
								//Se genera el valor correspondiente a la operación crediticia
								if (oGarantia.Contabilidad != 0)
									mstrOperacionCrediticia = oGarantia.Contabilidad.ToString();

								if (oGarantia.Oficina != 0)
									mstrOperacionCrediticia += "-" + oGarantia.Oficina.ToString();

								if (oGarantia.Moneda != 0)
									mstrOperacionCrediticia += "-" + oGarantia.Moneda.ToString();

								if (oGarantia.TipoOperacion == int.Parse(ConfigurationManager.AppSettings["OPERACION_CREDITICIA"].ToString()))
								{
									if (oGarantia.Producto != 0)
										mstrOperacionCrediticia += "-" + oGarantia.Producto.ToString();
								}

								if (oGarantia.Numero != 0)
									mstrOperacionCrediticia += "-" + oGarantia.Numero.ToString();


								//Se genera el dato correspondiente a la garantía
								if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["HIPOTECAS"].ToString()))
								{
									mstrGarantia = "[H] ";

									if (oGarantia.Partido != -1)
										mstrGarantia += oGarantia.Partido.ToString();

									if (oGarantia.Finca != -1)
									{
										mstrGarantia += "-" + oGarantia.Finca.ToString();

										if (oGarantia.Partido == -1)
										{
											mstrGarantia += oGarantia.Finca.ToString();
										}
									}
								}
								else if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["CEDULAS_HIPOTECARIAS"].ToString()))
								{
									mstrGarantia = "[CH] ";

									if (oGarantia.Partido != -1)
										mstrGarantia += oGarantia.Partido.ToString();

									if (oGarantia.Finca != -1)
									{
										mstrGarantia += "-" + oGarantia.Finca.ToString();

										if (oGarantia.Partido == -1)
										{
											mstrGarantia += oGarantia.Finca.ToString();
										}
									}

								}
								else if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["PRENDAS"].ToString()))
								{
									mstrGarantia = "[P] ";

									if ((oGarantia.ClaseBien != null) && (oGarantia.ClaseBien != string.Empty))
										mstrGarantia += oGarantia.ClaseBien.ToString();

									if ((oGarantia.NumPlaca != null) && (oGarantia.NumPlaca != string.Empty))
									{
										mstrGarantia += "-" + oGarantia.NumPlaca.ToString();

										if ((oGarantia.ClaseBien == null) || (oGarantia.ClaseBien == string.Empty))
										{
											mstrGarantia += oGarantia.NumPlaca.ToString();
										}
									}
								}
							}

							#endregion

							string strInsertarValuacionReal = "INSERT INTO GAR_VALUACIONES_REALES (cod_garantia_real,fecha_valuacion,cedula_empresa,cedula_perito," +
								"monto_ultima_tasacion_terreno,monto_ultima_tasacion_no_terreno,monto_tasacion_actualizada_terreno," +
								"monto_tasacion_actualizada_no_terreno,fecha_ultimo_seguimiento,monto_total_avaluo," +
								"cod_recomendacion_perito,cod_inspeccion_menor_tres_meses,fecha_construccion) VALUES(" +
								nGarantiaReal.ToString() + "," + dFechaValuacion + "," +
								strCedulaEmpresa + "," + strCedulaPerito + "," +
								nMontoUltTasacionTerreno.ToString() + "," + nMontoUltTasacionNoTerreno.ToString() + "," +
								nMontoTasacionActTerreno.ToString() + "," + nMontoTasacionActNoTerreno.ToString() + "," +
								dFechaUltSeguimiento + "," + nMontoTotalAvaluo.ToString() + "," +
								nRecomendacion.ToString() + "," + nInspeccion.ToString() + "," +
								dFechaConstruccion + ")";

							oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
							   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
							   ContenedorValuaciones_reales.COD_GARANTIA_REAL,
							   string.Empty,
							   mstrGarantia);

							oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
							   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
							   ContenedorValuaciones_reales.FECHA_VALUACION,
							   string.Empty,
							   dFechaValuacion);

							if (strCedulaEmpresa.Length > 0)
							{
								oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
								   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
								   ContenedorValuaciones_reales.CEDULA_EMPRESA,
								   string.Empty,
								   strCedulaEmpresa);
							}

							if (strCedulaPerito.Length > 0)
							{
								oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
								   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
								   ContenedorValuaciones_reales.CEDULA_PERITO,
								   string.Empty,
								   strCedulaPerito);
							}

							if (nMontoUltTasacionTerreno > 0)
							{
								oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
								   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
								   ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_TERRENO,
								   string.Empty,
								   nMontoUltTasacionTerreno.ToString());
							}

							if (nMontoUltTasacionNoTerreno > 0)
							{
								oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
								   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
								   ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_NO_TERRENO,
								   string.Empty,
								   nMontoUltTasacionNoTerreno.ToString());
							}

							if (nMontoTasacionActTerreno > 0)
							{
								oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
								   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
								   ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_TERRENO,
								   string.Empty,
								   nMontoTasacionActTerreno.ToString());
							}

							if (nMontoTasacionActNoTerreno > 0)
							{
								oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
								   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
								   ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_NO_TERRENO,
								   string.Empty,
								   nMontoTasacionActNoTerreno.ToString());
							}

							if (dFechaUltSeguimiento != string.Empty)
							{
								oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
								   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
								   ContenedorValuaciones_reales.FECHA_ULTIMO_SEGUIMIENTO,
								   string.Empty,
								   dFechaUltSeguimiento);
							}

							oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
							   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
							   ContenedorValuaciones_reales.MONTO_TOTAL_AVALUO,
							   string.Empty,
							   nMontoTotalAvaluo.ToString());

							oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
							   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
							   ContenedorValuaciones_reales.COD_RECOMENDACION_PERITO,
							   string.Empty,
							   oTraductor.TraducirTipoRecomendacionPerito(nRecomendacion));

							oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
							   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
							   ContenedorValuaciones_reales.COD_INSPECCION_MENOR_TRES_MESES,
							   string.Empty,
							   oTraductor.TraducirTipoInspeccion3Meses(nInspeccion));

							if (dFechaConstruccion != string.Empty)
							{
								oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
								   1, 2, mstrGarantia, mstrOperacionCrediticia, strInsertarValuacionReal, string.Empty,
								   ContenedorValuaciones_reales.FECHA_CONSTRUCCION,
								   string.Empty,
								   dFechaConstruccion);
							}
						}

						#endregion
					}
				}
			}
			catch
			{
				throw;
			}
		}

		public void Modificar(long nGarantiaReal, string dFechaValuacion, string strCedulaEmpresa,
                            string strCedulaPerito, decimal nMontoUltTasacionTerreno, decimal nMontoUltTasacionNoTerreno,
                            decimal nMontoTasacionActTerreno, decimal nMontoTasacionActNoTerreno,
                            string dFechaUltSeguimiento, decimal nMontoTotalAvaluo, int nRecomendacion,
							int nInspeccion, string dFechaConstruccion, string strUsuario, string strIP)
		{
			try
			{
				string strMontoUltTasacionTerreno = nMontoUltTasacionTerreno.ToString();
				string strMontoUltTasacionNoTerreno = nMontoUltTasacionNoTerreno.ToString();
				string strMontoTasacionActTerreno = nMontoTasacionActTerreno.ToString();
				string strMontoTasacionActNoTerreno = nMontoTasacionActNoTerreno.ToString();
				string strMontoTotalAvaluo = nMontoTotalAvaluo.ToString();

//				strMontoUltTasacionTerreno = strMontoUltTasacionTerreno.Replace(",",".");
//				strMontoUltTasacionNoTerreno = strMontoUltTasacionNoTerreno.Replace(",",".");
//				strMontoTasacionActTerreno = strMontoTasacionActTerreno.Replace(",",".");
//				strMontoTasacionActNoTerreno = strMontoTasacionActNoTerreno.Replace(",",".");
                //				strMontoTotalAvaluo = strMontoTotalAvaluo.Replace(",",".");

                #region Armar String de modificación de una Valuación Real

                string strModificarValuacionReal = "UPDATE GAR_VALUACIONES_REALES " +
								"SET ";

				if (strCedulaEmpresa.Length > 0)
					strModificarValuacionReal = strModificarValuacionReal + "cedula_empresa = '" + strCedulaEmpresa + "', ";

				if (strCedulaPerito.Length > 0)
					strModificarValuacionReal = strModificarValuacionReal + "cedula_perito = '" + strCedulaPerito + "', ";

				if (nMontoUltTasacionTerreno >= 0)
					strModificarValuacionReal = strModificarValuacionReal + "monto_ultima_tasacion_terreno = convert(decimal(18,2), '" + strMontoUltTasacionTerreno + "'), ";

				if (nMontoUltTasacionNoTerreno >= 0)
					strModificarValuacionReal = strModificarValuacionReal + "monto_ultima_tasacion_no_terreno = convert(decimal(18,2), '" + strMontoUltTasacionNoTerreno + "'), ";

				if (nMontoTasacionActTerreno >= 0)
					strModificarValuacionReal = strModificarValuacionReal + "monto_tasacion_actualizada_terreno = convert(decimal(18,2), '" + strMontoTasacionActTerreno + "'), ";

				if (nMontoTasacionActNoTerreno >= 0)
					strModificarValuacionReal = strModificarValuacionReal + "monto_tasacion_actualizada_no_terreno = convert(decimal(18,2), '" + strMontoTasacionActNoTerreno + "'), ";

				if (dFechaUltSeguimiento != "")
				{
                    DateTime dtFUS = Convert.ToDateTime(dFechaUltSeguimiento);
                    dFechaUltSeguimiento = new System.Data.SqlTypes.SqlDateTime(dtFUS).ToString(); //dtFUS.Year.ToString() + "/" + dtFUS.Month.ToString() + "/" + dtFUS.Day.ToString();

                    strModificarValuacionReal = strModificarValuacionReal + "fecha_ultimo_seguimiento = '" + dtFUS.ToString("yyyyMMdd") + "',";
				}

				strModificarValuacionReal = strModificarValuacionReal + "monto_total_avaluo = convert(decimal(18,2), '" + strMontoTotalAvaluo + "'), " +
								  "cod_recomendacion_perito = " + nRecomendacion + ", " +
								  "cod_inspeccion_menor_tres_meses = " + nInspeccion + ",";

				if (dFechaConstruccion != "")
				{
                    DateTime dtFC = Convert.ToDateTime(dFechaConstruccion);
                    dFechaConstruccion = new System.Data.SqlTypes.SqlDateTime(dtFC).ToString(); 

                    strModificarValuacionReal = strModificarValuacionReal + "fecha_construccion = '" + dtFC.ToString("yyyyMMdd") + "'";
				}
				else
					strModificarValuacionReal = strModificarValuacionReal + " fecha_construccion = null";

                DateTime dtV = Convert.ToDateTime(dFechaValuacion);
                dFechaValuacion = new System.Data.SqlTypes.SqlDateTime(dtV).ToString(); 

                strModificarValuacionReal = strModificarValuacionReal + " WHERE cod_garantia_real = " + nGarantiaReal +
                        " AND fecha_valuacion = '" + dtV.ToString("yyyyMMdd") + "'";


                string strConsultaObtenerValuacionReal = "select " + ContenedorValuaciones_reales.CEDULA_EMPRESA + "," +
                    ContenedorValuaciones_reales.CEDULA_PERITO + "," + ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_TERRENO + "," +
                    ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_NO_TERRENO + "," + ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_TERRENO + "," +
                    ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_NO_TERRENO + "," + ContenedorValuaciones_reales.FECHA_ULTIMO_SEGUIMIENTO + "," +
                    ContenedorValuaciones_reales.MONTO_TOTAL_AVALUO + "," + ContenedorValuaciones_reales.COD_RECOMENDACION_PERITO + "," +
                    ContenedorValuaciones_reales.COD_INSPECCION_MENOR_TRES_MESES + "," + ContenedorValuaciones_reales.FECHA_CONSTRUCCION +
                    " from " + ContenedorValuaciones_reales.NOMBRE_ENTIDAD +
                    " where " + ContenedorValuaciones_reales.COD_GARANTIA_REAL + " = " + nGarantiaReal.ToString() + " and " +
                    ContenedorValuaciones_reales.FECHA_VALUACION + " = '" + dtV.ToString("yyyyMMdd") + "'"; 

                #endregion

                DataSet dsValuacionesReales = AccesoBD.ejecutarConsulta(strConsultaObtenerValuacionReal);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strModificarValuacionReal, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						if ((dsValuacionesReales != null) && (dsValuacionesReales.Tables.Count > 0) && (dsValuacionesReales.Tables[0].Rows.Count > 0))
						{
							Bitacora oBitacora = new Bitacora();

							TraductordeCodigos oTraductor = new TraductordeCodigos();

							#region Obtener Datos Relevantes

							CGarantiaReal oGarantia = CGarantiaReal.Current;

							if (oGarantia != null)
							{
								//Se genera el valor correspondiente a la operación crediticia
								if (oGarantia.Contabilidad != 0)
									mstrOperacionCrediticia = oGarantia.Contabilidad.ToString();

								if (oGarantia.Oficina != 0)
									mstrOperacionCrediticia += "-" + oGarantia.Oficina.ToString();

								if (oGarantia.Moneda != 0)
									mstrOperacionCrediticia += "-" + oGarantia.Moneda.ToString();

								if (oGarantia.TipoOperacion == int.Parse(ConfigurationManager.AppSettings["OPERACION_CREDITICIA"].ToString()))
								{
									if (oGarantia.Producto != 0)
										mstrOperacionCrediticia += "-" + oGarantia.Producto.ToString();
								}

								if (oGarantia.Numero != 0)
									mstrOperacionCrediticia += "-" + oGarantia.Numero.ToString();


								//Se genera el dato correspondiente a la garantía
								if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["HIPOTECAS"].ToString()))
								{
									mstrGarantia = "[H] ";

									if (oGarantia.Partido != -1)
										mstrGarantia += oGarantia.Partido.ToString();

									if (oGarantia.Finca != -1)
									{
										mstrGarantia += "-" + oGarantia.Finca.ToString();

										if (oGarantia.Partido == -1)
										{
											mstrGarantia += oGarantia.Finca.ToString();
										}
									}
								}
								else if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["CEDULAS_HIPOTECARIAS"].ToString()))
								{
									mstrGarantia = "[CH] ";

									if (oGarantia.Partido != -1)
										mstrGarantia += oGarantia.Partido.ToString();

									if (oGarantia.Finca != -1)
									{
										mstrGarantia += "-" + oGarantia.Finca.ToString();

										if (oGarantia.Partido == -1)
										{
											mstrGarantia += oGarantia.Finca.ToString();
										}
									}

								}
								else if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["PRENDAS"].ToString()))
								{
									mstrGarantia = "[P] ";

									if ((oGarantia.ClaseBien != null) && (oGarantia.ClaseBien != string.Empty))
										mstrGarantia += oGarantia.ClaseBien.ToString();

									if ((oGarantia.NumPlaca != null) && (oGarantia.NumPlaca != string.Empty))
									{
										mstrGarantia += "-" + oGarantia.NumPlaca.ToString();

										if ((oGarantia.ClaseBien == null) || (oGarantia.ClaseBien == string.Empty))
										{
											mstrGarantia += oGarantia.NumPlaca.ToString();
										}
									}
								}
							}

							#endregion

							if (!dsValuacionesReales.Tables[0].Rows[0].IsNull(ContenedorValuaciones_reales.CEDULA_EMPRESA))
							{
								string strCedulaEmpresaObt = dsValuacionesReales.Tables[0].Rows[0][ContenedorValuaciones_reales.CEDULA_EMPRESA].ToString().Trim();

								if ((strCedulaEmpresa.Length > 0) && (strCedulaEmpresaObt.CompareTo(strCedulaEmpresa.Trim()) != 0))
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
									   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
									   ContenedorValuaciones_reales.CEDULA_EMPRESA,
									   strCedulaEmpresaObt,
									   strCedulaEmpresa);
								}
							}
							else
							{
								if (strCedulaEmpresa.Length > 0)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										   ContenedorValuaciones_reales.CEDULA_EMPRESA,
										   string.Empty,
										   strCedulaEmpresa);
								}
							}

							if (!dsValuacionesReales.Tables[0].Rows[0].IsNull(ContenedorValuaciones_reales.CEDULA_PERITO))
							{
								string strCedulaPeritoObt = dsValuacionesReales.Tables[0].Rows[0][ContenedorValuaciones_reales.CEDULA_PERITO].ToString();

								if ((strCedulaPerito.Length > 0) && (strCedulaPeritoObt.CompareTo(strCedulaPerito) != 0))
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
									   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
									   ContenedorValuaciones_reales.CEDULA_PERITO,
									   strCedulaPeritoObt,
									   strCedulaPerito);
								}
							}
							else
							{
								if (strCedulaPerito.Length > 0)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										   ContenedorValuaciones_reales.CEDULA_PERITO,
										   string.Empty,
										   strCedulaPerito);
								}
							}

							if (!dsValuacionesReales.Tables[0].Rows[0].IsNull(ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_TERRENO))
							{
								decimal nMontoUltTasacionTerrenoObt = Convert.ToDecimal(dsValuacionesReales.Tables[0].Rows[0][ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_TERRENO].ToString());

								if (nMontoUltTasacionTerrenoObt != nMontoUltTasacionTerreno)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
									   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
									   ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_TERRENO,
									   nMontoUltTasacionTerrenoObt.ToString(),
									   nMontoUltTasacionTerreno.ToString());
								}
							}
							else
							{
								if (nMontoUltTasacionTerreno != 0)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										   ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_TERRENO,
										   string.Empty,
										   nMontoUltTasacionTerreno.ToString());
								}
							}

							if (!dsValuacionesReales.Tables[0].Rows[0].IsNull(ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_NO_TERRENO))
							{
								decimal nMontoUltTasacionNoTerrenoObt = Convert.ToDecimal(dsValuacionesReales.Tables[0].Rows[0][ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_NO_TERRENO].ToString());

								if (nMontoUltTasacionNoTerrenoObt != nMontoUltTasacionNoTerreno)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
									   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
									   ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_NO_TERRENO,
									   nMontoUltTasacionNoTerrenoObt.ToString(),
									   nMontoUltTasacionNoTerreno.ToString());
								}
							}
							else
							{
								if (nMontoUltTasacionNoTerreno != 0)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										   ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_NO_TERRENO,
										   string.Empty,
										   nMontoUltTasacionNoTerreno.ToString());
								}
							}

							if (!dsValuacionesReales.Tables[0].Rows[0].IsNull(ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_TERRENO))
							{
								decimal nMontoTasacionActTerrenoObt = Convert.ToDecimal(dsValuacionesReales.Tables[0].Rows[0][ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_TERRENO].ToString());

								if (nMontoTasacionActTerrenoObt != nMontoTasacionActTerreno)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
									   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
									   ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_TERRENO,
									   nMontoTasacionActTerrenoObt.ToString(),
									   nMontoTasacionActTerreno.ToString());
								}
							}
							else
							{
								if (nMontoTasacionActTerreno != 0)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										  2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										  ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_TERRENO,
										  string.Empty,
										  nMontoTasacionActTerreno.ToString());
								}
							}

							if (!dsValuacionesReales.Tables[0].Rows[0].IsNull(ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_NO_TERRENO))
							{
								decimal nMontoTasacionActNoTerrenoObt = Convert.ToDecimal(dsValuacionesReales.Tables[0].Rows[0][ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_NO_TERRENO].ToString());

								if (nMontoTasacionActNoTerrenoObt != nMontoTasacionActNoTerreno)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
									   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
									   ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_NO_TERRENO,
									   nMontoTasacionActNoTerrenoObt.ToString(),
									   nMontoTasacionActNoTerreno.ToString());
								}
							}
							else
							{
								if (nMontoTasacionActNoTerreno != 0)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										   ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_NO_TERRENO,
										   string.Empty,
										   nMontoTasacionActNoTerreno.ToString());
								}
							}

							if (!dsValuacionesReales.Tables[0].Rows[0].IsNull(ContenedorValuaciones_reales.FECHA_ULTIMO_SEGUIMIENTO))
							{
								DateTime dFechaUltimoSeguimientoObt = Convert.ToDateTime(dsValuacionesReales.Tables[0].Rows[0][ContenedorValuaciones_reales.FECHA_ULTIMO_SEGUIMIENTO].ToString());

								if (dFechaUltSeguimiento != string.Empty)
								{
									DateTime dFechaSeguimientoConvertida = new DateTime();

									dFechaSeguimientoConvertida = Convert.ToDateTime(dFechaUltSeguimiento);

									if (dFechaUltimoSeguimientoObt != dFechaSeguimientoConvertida)
									{
										oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										   ContenedorValuaciones_reales.FECHA_ULTIMO_SEGUIMIENTO,
										   dFechaUltimoSeguimientoObt.ToShortDateString(),
										   dFechaSeguimientoConvertida.ToShortDateString());
									}
								}
							}
							else
							{
								if (dFechaUltSeguimiento != string.Empty)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
											   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
											   ContenedorValuaciones_reales.FECHA_ULTIMO_SEGUIMIENTO,
											   string.Empty,
											   dFechaUltSeguimiento);
								}
							}

							if (!dsValuacionesReales.Tables[0].Rows[0].IsNull(ContenedorValuaciones_reales.MONTO_TOTAL_AVALUO))
							{
								decimal nMontoTotalAvaluoObt = Convert.ToDecimal(dsValuacionesReales.Tables[0].Rows[0][ContenedorValuaciones_reales.MONTO_TOTAL_AVALUO].ToString());

								if (nMontoTotalAvaluoObt != nMontoTotalAvaluo)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
									   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
									   ContenedorValuaciones_reales.MONTO_TOTAL_AVALUO,
									   nMontoTotalAvaluoObt.ToString(),
									   nMontoTotalAvaluo.ToString());
								}
							}
							else
							{
								if (nMontoTotalAvaluo != 0)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										   ContenedorValuaciones_reales.MONTO_TOTAL_AVALUO,
										   string.Empty,
										   nMontoTotalAvaluo.ToString());
								}
							}

							if (!dsValuacionesReales.Tables[0].Rows[0].IsNull(ContenedorValuaciones_reales.COD_RECOMENDACION_PERITO))
							{
								int nCodigoRecomendacionPeritoObt = Convert.ToInt32(dsValuacionesReales.Tables[0].Rows[0][ContenedorValuaciones_reales.COD_RECOMENDACION_PERITO].ToString());

								if ((nCodigoRecomendacionPeritoObt != nRecomendacion) && (nRecomendacion != -1))
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
									   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
									   ContenedorValuaciones_reales.COD_RECOMENDACION_PERITO,
									   oTraductor.TraducirTipoRecomendacionPerito(nCodigoRecomendacionPeritoObt),
									   oTraductor.TraducirTipoRecomendacionPerito(nRecomendacion));
								}
							}
							else
							{
								if (nRecomendacion != -1)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										   ContenedorValuaciones_reales.COD_RECOMENDACION_PERITO,
										   string.Empty,
										   oTraductor.TraducirTipoRecomendacionPerito(nRecomendacion));
								}
							}

							if (!dsValuacionesReales.Tables[0].Rows[0].IsNull(ContenedorValuaciones_reales.COD_INSPECCION_MENOR_TRES_MESES))
							{
								int nCodigoInspeccionObt = Convert.ToInt32(dsValuacionesReales.Tables[0].Rows[0][ContenedorValuaciones_reales.COD_INSPECCION_MENOR_TRES_MESES].ToString());

								if ((nCodigoInspeccionObt != nInspeccion) && (nInspeccion != -1))
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
									   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
									   ContenedorValuaciones_reales.COD_INSPECCION_MENOR_TRES_MESES,
									   oTraductor.TraducirTipoInspeccion3Meses(nCodigoInspeccionObt),
									   oTraductor.TraducirTipoInspeccion3Meses(nInspeccion));
								}
							}
							else
							{
								if (nInspeccion != -1)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										  2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										  ContenedorValuaciones_reales.COD_INSPECCION_MENOR_TRES_MESES,
										  string.Empty,
										  oTraductor.TraducirTipoInspeccion3Meses(nInspeccion));
								}
							}

							if (!dsValuacionesReales.Tables[0].Rows[0].IsNull(ContenedorValuaciones_reales.FECHA_CONSTRUCCION))
							{
								DateTime dFechaConstruccionObt = Convert.ToDateTime(dsValuacionesReales.Tables[0].Rows[0][ContenedorValuaciones_reales.FECHA_CONSTRUCCION].ToString());

								DateTime dFechaConstruccionConvertida = new DateTime();

								if (dFechaConstruccion != "")
								{
									dFechaConstruccionConvertida = Convert.ToDateTime(dFechaConstruccion);
								}
								else
									dFechaConstruccionConvertida = DateTime.MinValue;

								if (dFechaConstruccionObt != dFechaConstruccionConvertida)
								{
									if (dFechaConstruccion == string.Empty)
									{
										oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										   ContenedorValuaciones_reales.FECHA_CONSTRUCCION,
										   dFechaConstruccionObt.ToShortDateString(),
										   dFechaConstruccion);
									}
									else
									{
										oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										   2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
										   ContenedorValuaciones_reales.FECHA_CONSTRUCCION,
										   dFechaConstruccionObt.ToShortDateString(),
										   dFechaConstruccionConvertida.ToShortDateString());
									}
								}
							}
							else
							{
								if (dFechaConstruccion != string.Empty)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
											  2, 2, mstrGarantia, mstrOperacionCrediticia, strModificarValuacionReal, string.Empty,
											  ContenedorValuaciones_reales.FECHA_CONSTRUCCION,
											  string.Empty,
											  dFechaConstruccion);
								}
							}
						}

						#endregion
					}
				}
			}
			catch
			{
				throw;
			}
		}

		public void Eliminar(long nGarantiaReal, string dFechaValuacion, string strUsuario, string strIP)
		{
			try
			{
                DateTime dtFV = DateTime.Parse(dFechaValuacion);
                string strFV = dtFV.ToString("yyyyMMdd");

				string strEliminarValuacionReal = "DELETE GAR_VALUACIONES_REALES " +
								" WHERE cod_garantia_real = " + nGarantiaReal +
                                " AND fecha_valuacion = '" + strFV + "'";
                                
                                //dFechaValuacion.Substring(6,4).ToString() + "/" +
                                //                        dFechaValuacion.Substring(0,2).ToString() + "/" +
                                //                        dFechaValuacion.Substring(3,2).ToString() + "'";
				
                //AccesoBD.ejecutarConsulta(strModificarValuacionReal);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strEliminarValuacionReal, oConexion);

					//Obtener la información antes de borrarla, ocn el fin de insertarla en la bitácora
					DataSet dsValuacionReal = AccesoBD.ejecutarConsulta("select " + ContenedorValuaciones_reales.CEDULA_EMPRESA + "," +
						ContenedorValuaciones_reales.CEDULA_PERITO + "," + ContenedorValuaciones_reales.COD_INSPECCION_MENOR_TRES_MESES + "," +
						ContenedorValuaciones_reales.COD_RECOMENDACION_PERITO + "," + ContenedorValuaciones_reales.FECHA_CONSTRUCCION + "," +
						ContenedorValuaciones_reales.FECHA_ULTIMO_SEGUIMIENTO + "," + ContenedorValuaciones_reales.FECHA_VALUACION + "," +
						ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_NO_TERRENO + "," + ContenedorValuaciones_reales.MONTO_TASACION_ACTUALIZADA_TERRENO + "," +
						ContenedorValuaciones_reales.MONTO_TOTAL_AVALUO + "," + ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_NO_TERRENO + "," +
						ContenedorValuaciones_reales.MONTO_ULTIMA_TASACION_TERRENO +
						" from " + ContenedorValuaciones_reales.NOMBRE_ENTIDAD +
						" where " + ContenedorValuaciones_reales.COD_GARANTIA_REAL + " = " + nGarantiaReal.ToString() +
						" and " + ContenedorValuaciones_reales.FECHA_VALUACION + " = '" + strFV + "'");

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						#region Obtener Datos Relevantes

						CGarantiaReal oGarantia = CGarantiaReal.Current;

						if (oGarantia != null)
						{
							//Se genera el valor correspondiente a la operación crediticia
							if (oGarantia.Contabilidad != 0)
								mstrOperacionCrediticia = oGarantia.Contabilidad.ToString();

							if (oGarantia.Oficina != 0)
								mstrOperacionCrediticia += "-" + oGarantia.Oficina.ToString();

							if (oGarantia.Moneda != 0)
								mstrOperacionCrediticia += "-" + oGarantia.Moneda.ToString();

							if (oGarantia.TipoOperacion == int.Parse(ConfigurationManager.AppSettings["OPERACION_CREDITICIA"].ToString()))
							{
								if (oGarantia.Producto != 0)
									mstrOperacionCrediticia += "-" + oGarantia.Producto.ToString();
							}

							if (oGarantia.Numero != 0)
								mstrOperacionCrediticia += "-" + oGarantia.Numero.ToString();


							//Se genera el dato correspondiente a la garantía
							if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["HIPOTECAS"].ToString()))
							{
								mstrGarantia = "[H] ";

								if (oGarantia.Partido != -1)
									mstrGarantia += oGarantia.Partido.ToString();

								if (oGarantia.Finca != -1)
								{
									mstrGarantia += "-" + oGarantia.Finca.ToString();

									if (oGarantia.Partido == -1)
									{
										mstrGarantia += oGarantia.Finca.ToString();
									}
								}
							}
							else if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["CEDULAS_HIPOTECARIAS"].ToString()))
							{
								mstrGarantia = "[CH] ";

								if (oGarantia.Partido != -1)
									mstrGarantia += oGarantia.Partido.ToString();

								if (oGarantia.Finca != -1)
								{
									mstrGarantia += "-" + oGarantia.Finca.ToString();

									if (oGarantia.Partido == -1)
									{
										mstrGarantia += oGarantia.Finca.ToString();
									}
								}

							}
							else if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["PRENDAS"].ToString()))
							{
								mstrGarantia = "[P] ";

								if ((oGarantia.ClaseBien != null) && (oGarantia.ClaseBien != string.Empty))
									mstrGarantia += oGarantia.ClaseBien.ToString();

								if ((oGarantia.NumPlaca != null) && (oGarantia.NumPlaca != string.Empty))
								{
									mstrGarantia += "-" + oGarantia.NumPlaca.ToString();

									if ((oGarantia.ClaseBien == null) || (oGarantia.ClaseBien == string.Empty))
									{
										mstrGarantia += oGarantia.NumPlaca.ToString();
									}
								}
							}
						}

						#endregion

						if ((dsValuacionReal != null) && (dsValuacionReal.Tables.Count > 0) && (dsValuacionReal.Tables[0].Rows.Count > 0))
						{
							foreach (DataRow drValReal in dsValuacionReal.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drValReal.Table.Columns.Count; nIndice++)
								{
									if (drValReal.Table.Columns[nIndice].ColumnName.CompareTo(ContenedorValuaciones_reales.COD_INSPECCION_MENOR_TRES_MESES) == 0)
									{
										if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
										{
											oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
											   3, 2, mstrGarantia, mstrOperacionCrediticia, strEliminarValuacionReal, string.Empty,
											   drValReal.Table.Columns[nIndice].ColumnName,
											   oTraductor.TraducirTipoInspeccion3Meses(Convert.ToInt32(drValReal[nIndice, DataRowVersion.Current].ToString())),
											   string.Empty);
										}
										else
										{
											oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
											   3, 2, mstrGarantia, mstrOperacionCrediticia, strEliminarValuacionReal, string.Empty,
											   drValReal.Table.Columns[nIndice].ColumnName,
											   string.Empty,
											   string.Empty);
										}
									}
									else if (drValReal.Table.Columns[nIndice].ColumnName.CompareTo(ContenedorValuaciones_reales.COD_RECOMENDACION_PERITO) == 0)
									{
										if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
										{
											oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
											   3, 2, mstrGarantia, mstrOperacionCrediticia, strEliminarValuacionReal, string.Empty,
											   drValReal.Table.Columns[nIndice].ColumnName,
											   oTraductor.TraducirTipoRecomendacionPerito(Convert.ToInt32(drValReal[nIndice, DataRowVersion.Current].ToString())),
											   string.Empty);
										}
										else
										{
											oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
											   3, 2, mstrGarantia, mstrOperacionCrediticia, strEliminarValuacionReal, string.Empty,
											   drValReal.Table.Columns[nIndice].ColumnName,
											   string.Empty,
											   string.Empty);
										}
									}
									else
									{
										oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
										   3, 2, mstrGarantia, mstrOperacionCrediticia, strEliminarValuacionReal, string.Empty,
										   drValReal.Table.Columns[nIndice].ColumnName,
										   drValReal[nIndice, DataRowVersion.Current].ToString(),
										   string.Empty);
									}
								}
							}
						}
						else
						{
							oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
							 3, 2, mstrGarantia, mstrOperacionCrediticia, strEliminarValuacionReal, string.Empty,
							 string.Empty,
							 string.Empty,
							 string.Empty);
						}

						#endregion
					}
				}
			}
			catch
			{
				throw;
			}
		}

        public clsValuacionesReales<clsValuacionReal> Obtener_Avaluos(long nGarantia, string codigoBien, bool obtenerMasReciente, int catalogoRP, int catalogoIMT)
        {
            XmlReader oRetornoVGR = null;
            XmlDocument xmlTrama = new XmlDocument();
            XmlNode nodoAvaluos;
            clsValuacionesReales<clsValuacionReal> listaValuacionesReales = null;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string strFiltros = string.Empty;
            string vsObtenerVGR = string.Empty;
            string codErrorObtenido = string.Empty;

            StringBuilder sbVGR = new StringBuilder();

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piGarantia_Real", SqlDbType.BigInt),
                        new SqlParameter("pbObtenerMasReciente", SqlDbType.Bit),
                        new SqlParameter("piCatalogoRP", SqlDbType.Int),
                        new SqlParameter("piCatalogoIMT", SqlDbType.Int),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                parameters[0].Value = nGarantia;
                parameters[1].Value = obtenerMasReciente;
                parameters[2].Value = catalogoRP;
                parameters[3].Value = catalogoIMT;
                parameters[4].Value = null;
                parameters[4].Direction = ParameterDirection.Output;


                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    //Ejecuta el comando
                    oRetornoVGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "pa_Obtener_Valuaciones_Reales", parameters);

                    if (oRetornoVGR != null)
                    {
                        while (oRetornoVGR.Read())
                        {
                            sbVGR.AppendLine(oRetornoVGR.ReadOuterXml());
                        }

                        vsObtenerVGR = sbVGR.ToString();

                        if (vsObtenerVGR.Length > 0)
                        {
                            strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerVGR);
                            if (strMensajeObtenido.Length > 1)
                            {
                                if (strMensajeObtenido[0].CompareTo("0") == 0)
                                {
                                    if (vsObtenerVGR.Length > 0)
                                    {
                                        xmlTrama.LoadXml(vsObtenerVGR);

                                        if (xmlTrama != null)
                                        {
                                            nodoAvaluos = xmlTrama.SelectSingleNode("//" + _avaluos);

                                            if ((nodoAvaluos != null) && (nodoAvaluos.HasChildNodes))
                                            {
                                                clsValuacionReal entidadValuacionReal;
                                                listaValuacionesReales = new clsValuacionesReales<clsValuacionReal>();

                                                foreach (XmlNode nodoAvaluo in nodoAvaluos.ChildNodes)
                                                {
                                                    entidadValuacionReal = new clsValuacionReal(nodoAvaluo.OuterXml);
                                                    entidadValuacionReal.CodGarantiaReal = nGarantia;
                                                    entidadValuacionReal.MontoTotalAvaluo = 
                                                          entidadValuacionReal.MontoTasacionActualizadaTerreno 
                                                        + entidadValuacionReal.MontoTasacionActualizadaNoTerreno;

                                                    listaValuacionesReales.Agregar(entidadValuacionReal);
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY));
                                    }
                                }
                                else
                                {
                                    if (strMensajeObtenido[0].CompareTo("1") == 0)
                                    {
                                        listaValuacionesReales = null;
                                    }
                                    else
                                    {
                                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY));
                                    }
                                }
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY));
                            }
                        }
                        else
                        {
                            throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY));
                        }
                    }
                    else
                    {
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY));
                    }
                }
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, codigoBien, Mensajes.ASSEMBLY)));
            }

            return listaValuacionesReales;
        }

        /// <summary>
        /// Permite aplicar el proceso del cálculo del monto de la tasación actualizada del no terreno,esto para todos los avalúos más recientes
        /// </summary>
        /// <param name="strUsuario">Identificación del usuario que ejecuta el proceso</param>
        /// <param name="esServicioWindows">Indica si se ejecuta desde l servicio windows o no</param>
        /// <returns></returns>
        public string AplicarCalculoMTANTAvaluos(string strUsuario, bool esServicioWindows)
        {
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };
            
            string vsObtenerVGR = string.Empty;
            string descripcionErrorRetornado = string.Empty;

            StringBuilder sbVGR = new StringBuilder();

            try
            {
                SqlParameter[] parametrosProcedimiento = new SqlParameter[] { 
                        new SqlParameter("@psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                parametrosProcedimiento[0].Value = strUsuario;
                parametrosProcedimiento[1].Value = null;
                parametrosProcedimiento[1].Direction = ParameterDirection.Output;

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Aplicar_Calculo_Avaluo_MTAT_MTANT", 0, parametrosProcedimiento);

                    respuestaObtenida = parametrosProcedimiento[1].Value.ToString();
                }

                if (respuestaObtenida.Length > 0)
                {
                    strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                    if (strMensajeObtenido[0].CompareTo("0") != 0)
                    {
                        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Mensajes.ASSEMBLY);
                    }
                }

                //using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                //{
                //    oConexion.Open();
                    
                //    //Ejecuta el comando
                //    oRetornoVGR = AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Aplicar_Calculo_Avaluo_MTAT_MTANT", 0, parametrosProcedimiento);

                //    if (oRetornoVGR != null)
                //    {
                //        while (oRetornoVGR.Read())
                //        {
                //            sbVGR.AppendLine(oRetornoVGR.ReadOuterXml());
                //        }

                //        vsObtenerVGR = sbVGR.ToString();

                //        if (vsObtenerVGR.Length > 0)
                //        {
                //            strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerVGR);
                //            if (strMensajeObtenido.Length > 1)
                //            {
                //                if (strMensajeObtenido[0].CompareTo("0") == 0)
                //                {
                //                    if (vsObtenerVGR.Length == 0)
                //                    {
                //                        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Mensajes.ASSEMBLY);
                //                    }
                //                }
                //                else
                //                {
                //                    if (strMensajeObtenido[0].CompareTo("1") != 0)
                //                    {
                //                        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Mensajes.ASSEMBLY);

                //                        if ((strMensajeObtenido.Length > 1) && (strMensajeObtenido[1] != null) && (strMensajeObtenido[1].Length > 0))
                //                        {
                //                            if (!esServicioWindows)
                //                            {
                //                                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalleServicioWindows, strMensajeObtenido[1], Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                //                            }
                //                            else
                //                            {
                //                                descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalleServicioWindows, strMensajeObtenido[1], Mensajes.ASSEMBLY);
                //                            }
                //                        }
                //                    }
                //                }
                //            }
                //            else
                //            {
                //                descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Mensajes.ASSEMBLY);
                //            }
                //        }
                //        else
                //        {
                //            descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Mensajes.ASSEMBLY);
                //        }
                //    }
                //    else
                //    {
                //        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Mensajes.ASSEMBLY);
                //    }
                //}
            }
            catch (Exception ex)
            {
                if (!esServicioWindows)
                {
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalleServicioWindows, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                }

                descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalleServicioWindows, ex.Message, Mensajes.ASSEMBLY);
            }

            return descripcionErrorRetornado;
        }

        /// <summary>
        /// Método que permite la inserción de los semestres calculados dentro de la tabla temporal de la base de datos
        /// </summary>
        /// <param name="tramaSemestres">Trama con los semestres calculados</param>
        /// <param name="strUsuario">Usuario que realizó el cálculo</param>
        /// <returns>La descripción del estado de la transacción final</returns>
        public string InsertarSemetresCalculados(string tramaSemestres, string strUsuario)
        {
            string[] strMensajeObtenido = new string[] { string.Empty };
            string respuestaObtenida = string.Empty;
            string descripcionErrorRetornado = string.Empty;

            StringBuilder sbVGR = new StringBuilder();

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psTrama", SqlDbType.NText),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                parameters[0].Value = tramaSemestres;
                parameters[1].Value = strUsuario;
                parameters[2].Value = null;
                parameters[2].Direction = ParameterDirection.Output;

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    //Ejecuta el comando
                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "Insertar_Registro_Calculo_MTAT_MTANT", parameters);

                    respuestaObtenida = parameters[2].Value.ToString();

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);
                        if (strMensajeObtenido.Length > 1)
                        {
                            if (strMensajeObtenido[0].CompareTo("0") == 0)
                            {
                                if (respuestaObtenida.Length == 0)
                                {
                                    descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculados, Mensajes.ASSEMBLY);
                                }
                            }
                            else
                            {
                                if (strMensajeObtenido[0].CompareTo("1") != 0)
                                {
                                    descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculados, Mensajes.ASSEMBLY);

                                    if ((strMensajeObtenido.Length > 1) && (strMensajeObtenido[1] != null) && (strMensajeObtenido[1].Length > 0))
                                    {
                                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculadosDetalle, strMensajeObtenido[1], Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                                    }
                                }
                            }
                        }
                        else
                        {
                            descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculados, Mensajes.ASSEMBLY);
                        }
                    }
                    else
                    {
                        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculados, Mensajes.ASSEMBLY);
                    }
                }
            }
            catch (Exception ex)
            {
                descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculados, Mensajes.ASSEMBLY);
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoSemestresCalculadosDetalle, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
            }

            return descripcionErrorRetornado;
        }

        /// <summary>
        /// Método que permite la eliminación de los semestres calculados dentro de la tabla temporal de la base de datos. 
        /// Este método sólo es utilizado por el servicio windows que aplica el cálculode forma automática.
        /// </summary>
        /// <returns>La descripción del estado de la transacción final</returns>
        public string EliminarSemetresCalculados()
        {
            XmlReader oRetornoVGR = null;

            string[] strMensajeObtenido = new string[] { string.Empty };
            string vsObtenerVGR = string.Empty;
            string descripcionErrorRetornado = string.Empty;

            StringBuilder sbVGR = new StringBuilder();

            try
            {
                SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psRespuesta", SqlDbType.VarChar,1000)
                    };

                parameters[0].Value = null;
                parameters[0].Direction = ParameterDirection.Output;


                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    //Ejecuta el comando
                    oRetornoVGR = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Eliminar_Registro_Calculo_MTAT_MTANT", parameters);

                    if (oRetornoVGR != null)
                    {
                        while (oRetornoVGR.Read())
                        {
                            sbVGR.AppendLine(oRetornoVGR.ReadOuterXml());
                        }

                        vsObtenerVGR = sbVGR.ToString();

                        if (vsObtenerVGR.Length > 0)
                        {
                            strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(vsObtenerVGR);
                            if (strMensajeObtenido.Length > 1)
                            {
                                if (strMensajeObtenido[0].CompareTo("0") == 0)
                                {
                                    if (vsObtenerVGR.Length == 0)
                                    {
                                        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);
                                    }
                                }
                                else
                                {
                                    if (strMensajeObtenido[0].CompareTo("1") != 0)
                                    {
                                        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);

                                        if ((strMensajeObtenido.Length > 1) && (strMensajeObtenido[1] != null) && (strMensajeObtenido[1].Length > 0))
                                        {
                                            descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculadosDetalle, strMensajeObtenido[1], Mensajes.ASSEMBLY);
                                        }
                                    }
                                }
                            }
                            else
                            {
                                descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);
                            }
                        }
                        else
                        {
                            descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);
                        }
                    }
                    else
                    {
                        descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);
                    }
                }
            }
            catch (Exception ex)
            {
                descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculadosDetalle, ex.Message, Mensajes.ASSEMBLY);
                //descripcionErrorRetornado = Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculados, Mensajes.ASSEMBLY);
                //UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorEliminandoSemestresCalculadosDetalle, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
            }

            return descripcionErrorRetornado;
        }


		#endregion
	}
}
