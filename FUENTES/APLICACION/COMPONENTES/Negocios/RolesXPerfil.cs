using System;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;
using System.Data.SqlClient;
using System.Data;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for RolesXPerfil.
	/// </summary>
	public class RolesXPerfil
	{
		#region Atributos de Clase
		private int mnPerfil;
		private int mnRol;
		#endregion

		#region Constructores de Clase
		public RolesXPerfil(int nPerfil, int nRol)
		{
			mnRol = nRol;
			mnPerfil = nPerfil;
		}
		#endregion

		#region Propiedades de Clase
		public int nRol
		{
			get {return mnRol;}
			set {mnRol = value;}
		}

		public int nPerfil
		{
			get {return mnPerfil;}
			set {mnPerfil = value;}
		}
		#endregion
	}

	
	/// <summary>
	/// Summary description for MultiRolesXPerfil.
	/// </summary>
	public class MultiRolesXPerfil
	{
		public void Crear(int nPerfil, int nRol, string strUsuario, string strIP)
		{
			try
			{
				string strInsertarRolesXPerfil = "INSERT INTO SEG_ROLES_X_PERFIL VALUES (" + nPerfil + ", " + nRol + ");";

                string strConsultaPerfil = "select " + ContenedorPerfil.DES_PERFIL +
                    " from " + ContenedorPerfil.NOMBRE_ENTIDAD +
                    " where " + ContenedorPerfil.COD_PERFIL + " = " + nPerfil.ToString();

                string strConsultaRol = "select " + ContenedorRol.DES_ROL +
                    " from " + ContenedorRol.NOMBRE_ENTIDAD +
                    " where " + ContenedorRol.COD_ROL + " = " + nRol.ToString();


                DataSet dsPerfil = AccesoBD.ejecutarConsulta(strConsultaPerfil);

                DataSet dsRol = AccesoBD.ejecutarConsulta(strConsultaRol);

                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strInsertarRolesXPerfil, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
						{
							oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarRolesXPerfil, string.Empty,
						   ContenedorRoles_x_perfil.COD_PERFIL,
						   string.Empty,
						   dsPerfil.Tables[0].Rows[0][ContenedorPerfil.DES_PERFIL].ToString());
						}
						else
						{
							oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
							   1, null, string.Empty, string.Empty, strInsertarRolesXPerfil, string.Empty, ContenedorRoles_x_perfil.COD_PERFIL,
							   string.Empty,
							   nPerfil.ToString());
						}

						if ((dsRol != null) && (dsRol.Tables.Count > 0) && (dsRol.Tables[0].Rows.Count > 0))
						{
							oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
							   1, null, string.Empty, string.Empty, strInsertarRolesXPerfil, string.Empty,
							   ContenedorRoles_x_perfil.COD_ROL,
							   string.Empty,
							   dsRol.Tables[0].Rows[0][ContenedorRol.DES_ROL].ToString());
						}
						else
						{
							oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
							   1, null, string.Empty, string.Empty, strInsertarRolesXPerfil, string.Empty,
							   ContenedorRoles_x_perfil.COD_ROL,
							   string.Empty,
							   nRol.ToString());
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

		public void Eliminar(int nPerfil, int nRol, string strUsuario, string strIP)
		{
			try
			{
				string strEliminarRolesXPerfil = "DELETE SEG_ROLES_X_PERFIL WHERE COD_PERFIL = " + nPerfil.ToString() + " AND COD_ROL = " + nRol;

                string strConsultaRolXPerfil = "select " + ContenedorRoles_x_perfil.COD_PERFIL + "," +
                    ContenedorRoles_x_perfil.COD_ROL +
                    " from " + ContenedorRoles_x_perfil.NOMBRE_ENTIDAD +
                    " where " + ContenedorRoles_x_perfil.COD_PERFIL + " = " + nPerfil.ToString() +
                    " and " + ContenedorRoles_x_perfil.COD_ROL + " = " + nRol.ToString();

                //AccesoBD.ejecutarConsulta(strQry);

                //Se obtienen los datos antes de ser borrados, para insertarlos en la bitácora
                DataSet dsRolXPerfil = AccesoBD.ejecutarConsulta(strConsultaRolXPerfil);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strEliminarRolesXPerfil, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						if ((dsRolXPerfil != null) && (dsRolXPerfil.Tables.Count > 0) && (dsRolXPerfil.Tables[0].Rows.Count > 0))
						{
							foreach (DataRow drRolXPerfil in dsRolXPerfil.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drRolXPerfil.Table.Columns.Count; nIndice++)
								{
									if (drRolXPerfil.Table.Columns[nIndice].ColumnName.CompareTo(ContenedorRoles_x_perfil.COD_PERFIL) == 0)
									{
										int nCodigoPerfil;

										if (int.TryParse(drRolXPerfil[nIndice, DataRowVersion.Current].ToString(), out nCodigoPerfil))
										{
											string strConsultaPerfil = "select " + ContenedorPerfil.DES_PERFIL +
											" from " + ContenedorPerfil.NOMBRE_ENTIDAD +
											" where " + ContenedorPerfil.COD_PERFIL + " = " + nPerfil.ToString();

											DataSet dsPerfil = AccesoBD.ejecutarConsulta(strConsultaPerfil);

											if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
											{
												oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
												  3, null, string.Empty, string.Empty, strEliminarRolesXPerfil, string.Empty,
												  drRolXPerfil.Table.Columns[nIndice].ColumnName,
												  dsPerfil.Tables[0].Rows[0][ContenedorPerfil.DES_PERFIL].ToString(),
												  string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
												  3, null, string.Empty, string.Empty, strEliminarRolesXPerfil, string.Empty,
												  drRolXPerfil.Table.Columns[nIndice].ColumnName,
												  drRolXPerfil[nIndice, DataRowVersion.Current].ToString(),
												  string.Empty);
											}
										}
										else
										{
											oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
											  3, null, string.Empty, string.Empty, strEliminarRolesXPerfil, string.Empty,
											  drRolXPerfil.Table.Columns[nIndice].ColumnName,
											  drRolXPerfil[nIndice, DataRowVersion.Current].ToString(),
											  string.Empty);
										}
									}
									else if (drRolXPerfil.Table.Columns[nIndice].ColumnName.CompareTo(ContenedorRoles_x_perfil.COD_ROL) == 0)
									{
										int nCodigoRol;

										if (int.TryParse(drRolXPerfil[nIndice, DataRowVersion.Current].ToString(), out nCodigoRol))
										{
											string strConsultaRol = "select " + ContenedorRol.DES_ROL +
												" from " + ContenedorRol.NOMBRE_ENTIDAD +
												" where " + ContenedorRol.COD_ROL + " = " + nRol.ToString();

											DataSet dsRol = AccesoBD.ejecutarConsulta(strConsultaRol);

											if ((dsRol != null) && (dsRol.Tables.Count > 0) && (dsRol.Tables[0].Rows.Count > 0))
											{
												oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
												  3, null, string.Empty, string.Empty, strEliminarRolesXPerfil, string.Empty,
												  drRolXPerfil.Table.Columns[nIndice].ColumnName,
												  dsRol.Tables[0].Rows[0][ContenedorRol.DES_ROL].ToString(),
												  string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
												  3, null, string.Empty, string.Empty, strEliminarRolesXPerfil, string.Empty,
												  drRolXPerfil.Table.Columns[nIndice].ColumnName,
												  drRolXPerfil[nIndice, DataRowVersion.Current].ToString(),
												  string.Empty);
											}
										}
										else
										{
											oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
											  3, null, string.Empty, string.Empty, strEliminarRolesXPerfil, string.Empty,
											  drRolXPerfil.Table.Columns[nIndice].ColumnName,
											  drRolXPerfil[nIndice, DataRowVersion.Current].ToString(),
											  string.Empty);
										}
									}
									else
									{
										oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
										   3, null, string.Empty, string.Empty, strEliminarRolesXPerfil, string.Empty,
										   drRolXPerfil.Table.Columns[nIndice].ColumnName,
										   drRolXPerfil[nIndice, DataRowVersion.Current].ToString(),
										   string.Empty);
									}
								}
							}
						}
						else
						{
							oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
							  3, null, string.Empty, string.Empty, strEliminarRolesXPerfil, string.Empty, string.Empty,
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
	}
}
