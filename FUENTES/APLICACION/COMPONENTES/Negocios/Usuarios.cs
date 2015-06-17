using System;
using BCRGARANTIAS.Datos;
using System.Data.SqlClient;
using System.Data;
using BCRGarantias.Contenedores;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Usuarios.
	/// </summary>
	public class Usuarios
	{
		#region Atributos de Clase
		private string mstrIdentificacion;
		private string mstrUsuario;
		private int mnPerfil;
		#endregion

		#region Constructores de Clase
		public Usuarios(string strIdentificacion, string strUsuario, int nPerfil)
		{
			mstrIdentificacion = strIdentificacion;
			mstrUsuario = strUsuario;
			mnPerfil = nPerfil;
		}
		#endregion

		#region Propiedades de Clase
		public string Identificacion
		{
			get {return mstrIdentificacion;}
			set {mstrIdentificacion = value;}
		}

		public string Usuario
		{
			get {return mstrUsuario;}
			set {mstrUsuario = value;}
		}

		public int Perfil
		{
			get {return mnPerfil;}
			set {mnPerfil = value;}
		}
		#endregion
	}

	/// <summary>
	/// Summary description for MultiUsuarios.
	/// </summary>
	public class MultiUsuarios
	{
		public Usuarios Crear(string strIdentificacion, string strNuevoUsuario, int nPerfil, string strUsuario, string strIP)
		{
			Usuarios UsuarioLocal;
			
            string strInsertarUsuario = "INSERT INTO SEG_USUARIO VALUES ('" + strIdentificacion + "','" + strNuevoUsuario + "', " + nPerfil + ");";
			
            try
			{
                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strInsertarUsuario, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					UsuarioLocal = new Usuarios(strIdentificacion, strUsuario, nPerfil);

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarUsuario, string.Empty, ContenedorUsuario.COD_USUARIO,
						   string.Empty,
						   strIdentificacion);

						oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarUsuario, string.Empty, ContenedorUsuario.DES_USUARIO,
						   string.Empty,
						   strNuevoUsuario);

						string strConsultaPerfil = "select " + ContenedorPerfil.DES_PERFIL +
						   " from " + ContenedorPerfil.NOMBRE_ENTIDAD +
						   " where " + ContenedorPerfil.COD_PERFIL + " = " + nPerfil.ToString();

						DataSet dsPerfil = AccesoBD.ejecutarConsulta(strConsultaPerfil);

						if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
						{
							oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
							   1, null, string.Empty, string.Empty, strInsertarUsuario, string.Empty, ContenedorUsuario.COD_PERFIL,
							   string.Empty,
							   dsPerfil.Tables[0].Rows[0][ContenedorPerfil.DES_PERFIL].ToString());
						}
						else
						{
							oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
							   1, null, string.Empty, string.Empty, strInsertarUsuario, string.Empty, ContenedorUsuario.COD_PERFIL,
							   string.Empty,
							   nPerfil.ToString());
						}

						#endregion
					}
				}
				
			}
			catch
			{
				throw;
			}

			return UsuarioLocal;
		}

		public Usuarios Modificar(string strIdentificacion, string strNuevoUsuario, int nPerfil, string strUsuario, string strIP)
		{
			Usuarios UsuarioLocal;
			string strModificarUsuario = "UPDATE SEG_USUARIO " +
					 "SET COD_PERFIL = " + nPerfil +  
					 " WHERE COD_USUARIO = '" + strIdentificacion + "'";
			try
			{
                //AccesoBD.ejecutarConsulta(strQry);

                DataSet dsUsuario = AccesoBD.ejecutarConsulta("select " + ContenedorUsuario.COD_PERFIL +
                    " from " + ContenedorUsuario.NOMBRE_ENTIDAD +
                    " where " + ContenedorUsuario.COD_USUARIO + " = '" + strIdentificacion + "'");


				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strModificarUsuario, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					UsuarioLocal = new Usuarios(strIdentificacion, strNuevoUsuario, nPerfil);

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						if ((dsUsuario != null) && (dsUsuario.Tables.Count > 0) && (dsUsuario.Tables[0].Rows.Count > 0))
						{
							Bitacora oBitacora = new Bitacora();

							if (!dsUsuario.Tables[0].Rows[0].IsNull(ContenedorUsuario.COD_PERFIL))
							{
								int nCodigoPerfilObt = Convert.ToInt32(dsUsuario.Tables[0].Rows[0][ContenedorUsuario.COD_PERFIL].ToString());

								if (nCodigoPerfilObt != nPerfil)
								{
									string strConsultaPerfilObt = "select " + ContenedorPerfil.DES_PERFIL +
									   " from " + ContenedorPerfil.NOMBRE_ENTIDAD +
									   " where " + ContenedorPerfil.COD_PERFIL + " = " + nCodigoPerfilObt.ToString();

									string strConsultaPerfil = "select " + ContenedorPerfil.DES_PERFIL +
									   " from " + ContenedorPerfil.NOMBRE_ENTIDAD +
									   " where " + ContenedorPerfil.COD_PERFIL + " = " + nPerfil.ToString();

									DataSet dsPerfilObt = AccesoBD.ejecutarConsulta(strConsultaPerfilObt);

									DataSet dsPerfil = AccesoBD.ejecutarConsulta(strConsultaPerfil);

									if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0)
									   && (dsPerfilObt != null) && (dsPerfilObt.Tables.Count > 0) && (dsPerfilObt.Tables[0].Rows.Count > 0))
									{
										oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
										   2, null, string.Empty, string.Empty, strModificarUsuario, string.Empty, ContenedorUsuario.COD_PERFIL,
										   dsPerfilObt.Tables[0].Rows[0][ContenedorPerfil.DES_PERFIL].ToString(),
										   dsPerfil.Tables[0].Rows[0][ContenedorPerfil.DES_PERFIL].ToString());
									}
									else
									{
										oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
										   2, null, string.Empty, string.Empty, strModificarUsuario, string.Empty, ContenedorUsuario.COD_PERFIL,
										   nCodigoPerfilObt.ToString(),
										   nPerfil.ToString());
									}
								}
							}
							else
							{
								oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarUsuario, string.Empty, ContenedorUsuario.COD_PERFIL,
									   string.Empty,
									   nPerfil.ToString());
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

			return UsuarioLocal;
		}

		public void Eliminar(string strIdentificacion, string strUsuario, string strIP)
		{
			string strEliminarUsuario = "DELETE SEG_USUARIO WHERE COD_USUARIO = '" + strIdentificacion + "'";

            string strConsultaUsuario = "select " + ContenedorUsuario.COD_PERFIL + "," +
                ContenedorUsuario.COD_USUARIO + "," + ContenedorUsuario.DES_USUARIO +
                    " from " + ContenedorUsuario.NOMBRE_ENTIDAD +
                    " where " + ContenedorUsuario.COD_USUARIO + " = '" + strIdentificacion + "'";

            try
			{
                //Se obtienen los datos antes de ser borrados, con el fin de poderlos insertar en la bitácora
                DataSet dsUsuario = AccesoBD.ejecutarConsulta(strConsultaUsuario);

                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strEliminarUsuario, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						if ((dsUsuario != null) && (dsUsuario.Tables.Count > 0) && (dsUsuario.Tables[0].Rows.Count > 0))
						{
							foreach (DataRow drUsuario in dsUsuario.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drUsuario.Table.Columns.Count; nIndice++)
								{
									if (drUsuario.Table.Columns[nIndice].ColumnName.CompareTo(ContenedorUsuario.COD_PERFIL) == 0)
									{
										string strConsultaPerfil = "select " + ContenedorPerfil.DES_PERFIL +
										   " from " + ContenedorPerfil.NOMBRE_ENTIDAD +
										   " where " + ContenedorPerfil.COD_PERFIL + " = " + dsUsuario.Tables[0].Rows[0][ContenedorUsuario.COD_PERFIL].ToString();

										DataSet dsPerfil = AccesoBD.ejecutarConsulta(strConsultaPerfil);

										if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
										{
											oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
											   3, null, string.Empty, string.Empty, strEliminarUsuario, string.Empty,
											   drUsuario.Table.Columns[nIndice].ColumnName,
											   dsPerfil.Tables[0].Rows[0][ContenedorPerfil.DES_PERFIL].ToString(),
											   string.Empty);
										}
										else
										{
											oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
											   3, null, string.Empty, string.Empty, strEliminarUsuario, string.Empty,
											   drUsuario.Table.Columns[nIndice].ColumnName,
											   drUsuario[nIndice, DataRowVersion.Current].ToString(),
											   string.Empty);
										}
									}
									else
									{
										oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
										   3, null, string.Empty, string.Empty, strEliminarUsuario, string.Empty,
										   drUsuario.Table.Columns[nIndice].ColumnName,
										   drUsuario[nIndice, DataRowVersion.Current].ToString(),
										   string.Empty);
									}
								}
							}
						}
						else
						{
							oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
							  3, null, string.Empty, string.Empty, strEliminarUsuario, string.Empty, string.Empty,
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

        public bool UsuarioExiste(string strIdentificacion)
        {
            bool bExisteUsuario = false;

            string strConsultarUsuarioExiste = "select DES_USUARIO from SEG_USUARIO where COD_USUARIO = '" + strIdentificacion + "'";

            try
            {
                DataSet dsValuacionesReales = AccesoBD.ejecutarConsulta(strConsultarUsuarioExiste);

                if ((dsValuacionesReales != null) && (dsValuacionesReales.Tables.Count > 0) && (dsValuacionesReales.Tables[0].Rows.Count > 0))
                {
                    bExisteUsuario = true;
                }
            }
            catch
            {
                throw;
            }

            return bExisteUsuario;
            
        }
	}
}
