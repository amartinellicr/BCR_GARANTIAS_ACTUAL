using System;
using System.DirectoryServices;
using System.Data.OleDb;
using System.Data;
using System.Configuration;
using Negocios.ActDirectory;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Seguridad.
    /// </summary>
    public class Seguridad
	{
		#region Constantes

		/// <summary>
		/// Código del estado de la validación del usuario, cuando ha sido éxitosa.
		/// </summary>
		public const string CODESTADOVALIDACIONUSUARIO_EXITOSA = "0";

		/// <summary>
		/// Código del estado de la validación del usuario, cuando el usuario no existe.
		/// </summary>
		public const string CODESTADOVALIDACIONUSUARIO_NO_EXISTE = "1";

		/// <summary>
		/// Código del estado de la validación del usuario, cuando ha fallado la autenticación.
		/// </summary>
		public const string CODESTADOVALIDACIONUSUARIO_FALLO_AUTENTICACION = "2";

        #endregion Constantes

        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };

        #endregion Variables Globales

        /// <summary>
        /// Valida los permisos de ingreso a la aplicacion
        /// </summary>
        /// <param name="strUsuario">Identificación del usuario</param>
        /// <param name="strPassword">Password del usuario</param>
        public bool ValidarUsuario(string strUsuario, string strPassword)
		{
			bool bErrorRegistrado = false;

			try
			{
				bool bRespuesta = false;
				ActiveDirectory BCRActiveDirectoryServicios = new ActiveDirectory();
                        BCRActiveDirectoryServicios.Url = ConfigurationManager.AppSettings.Get("WSACTIVEDIRECTORY_URL");
                        BCRActiveDirectoryServicios.Credentials = System.Net.CredentialCache.DefaultNetworkCredentials;

				if (BCRActiveDirectoryServicios.ExisteUsuario(strUsuario))
				{
					if (BCRActiveDirectoryServicios.Autenticar(strUsuario, strPassword))
					{						
						DataSet dsData = new DataSet();

						try
						{
                            listaCampos = new string[] { clsUsuario._cedulaUsuario,
                                                         clsUsuario._entidadUsuario,
                                                         clsUsuario._cedulaUsuario, strUsuario};

                            sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = '{3}'", listaCampos);

                            using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                            {
                                using (SqlCommand oComando = new SqlCommand(sentenciaSql, oConexion))
                                {
                                    oComando.Connection.Open();

                                    using (SqlDataAdapter cmdUsuario = new SqlDataAdapter(oComando))
                                    {
                                        cmdUsuario.Fill(dsData, "Usuarios");
                                    }

                                    oComando.Connection.Close();
                                    oComando.Connection.Dispose();
                                }
                            }
 						}
                        catch (SqlException sqlEx)
                        {
                            bErrorRegistrado = true;
                            Utilitarios.RegistraEventLog("Error al consultar la BD. Error: " + sqlEx.Message + ". Detalle: " + sqlEx.StackTrace, System.Diagnostics.EventLogEntryType.Error);
                            throw sqlEx;
                        }
                        catch (Exception ex)
						{
							bErrorRegistrado = true;
							Utilitarios.RegistraEventLog("Error al consultar la BD. Error: " + ex.Message + ". Detalle: " + ex.StackTrace, System.Diagnostics.EventLogEntryType.Error);
							throw ex;
						}

						if ((dsData != null) && (dsData.Tables.Count > 0) && (dsData.Tables["Usuarios"].Rows.Count > 0))
						{
							bRespuesta = true;
						}
						else
						{
							bRespuesta = false;
                            Utilitarios.RegistraEventLog("El usuario no exsite en la BD.",  System.Diagnostics.EventLogEntryType.Error);
                        }
					}
					else
					{
						bRespuesta = false;
                        Utilitarios.RegistraEventLog("El usuario tiene problemas al autenticar contra el AD.", System.Diagnostics.EventLogEntryType.Error);
                    }
				}
				else
				{
					bRespuesta = false;
                    Utilitarios.RegistraEventLog("El usuario no existe en el AD.", System.Diagnostics.EventLogEntryType.Error);
                }

				return bRespuesta;
			}
			catch (Exception ex)
			{
				if (!bErrorRegistrado)
				{
					Utilitarios.RegistraEventLog("Error al consumir servicio web del AD. Error: " + ex.Message + ". Detalle: " + ex.StackTrace, System.Diagnostics.EventLogEntryType.Error);
				}

				throw ex;
			}
		}

		
		/// <summary>
		/// Metodo para obtener el nombre del usuario
		/// </summary>
		/// <param name="strUsuario"></param>
		/// <returns></returns>
		public string ObtenerNombreUsuario(string strUsuario)
		{
			try
			{
				string strRetorno = "Usuario no existe en ActiveDirectory";

				ActiveDirectory BCRActiveDirectoryServicios = new ActiveDirectory();
				BCRActiveDirectoryServicios.Url = ConfigurationManager.AppSettings.Get("WSACTIVEDIRECTORY_URL");
				BCRActiveDirectoryServicios.Credentials = System.Net.CredentialCache.DefaultNetworkCredentials;

				if (BCRActiveDirectoryServicios.ExisteUsuario(strUsuario))
				{
					Usuario _userActiveDirectory = BCRActiveDirectoryServicios.TraerDatosUsuario(strUsuario);
					strRetorno = _userActiveDirectory.DisplayName;
				}

				return strRetorno;
			}
			catch (FieldAccessException e)
			{
				throw (e);
			}
			catch
			{
				throw (new InvalidOperationException());
			}
		}

		/// <summary>
		/// Metodo que valida si un usuario tiene un rol respectivo
		/// </summary>
		/// <param name="strUsuario"></param>
		/// <returns></returns>
		public bool IsInRol(string strUsuario, int nRol)
		{
			//Modificado por AMM
			bool bRespuesta = false;

			try
			{
				DataSet dsData = new DataSet();

                listaCampos = new string[] {clsUsuario._entidadUsuario, clsRolXPerfil._entidadRolXPerfil,
                                            clsUsuario._codigoPerfil, clsRolXPerfil._codigoPerfil,
                                            clsUsuario._cedulaUsuario, strUsuario,
                                            clsRolXPerfil._codigoRol, nRol.ToString()};

                sentenciaSql = string.Format("SELECT 1 FROM dbo.{0} SU1 INNER JOIN dbo.{1} SRP ON SU1.{2} = SRP.{3} WHERE SU1.{4} = '{5}' AND {6} = {7}", listaCampos);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(sentenciaSql, oConexion))
                    {
                        oComando.Connection.Open();

                        using (SqlDataAdapter cmdUsuario = new SqlDataAdapter(oComando))
                        {
                            cmdUsuario.Fill(dsData, "Roles");
                        }

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }

                if ((dsData != null) && (dsData.Tables["Roles"].Rows.Count > 0))
                {
                    bRespuesta = true;
                }
                else
                {
                    bRespuesta = false;
                }
			}
			catch(Exception ex)
			{
                Utilitarios.RegistraEventLog("Error IsInRol. Error: " + ex.Message + ". Detalle: " + ex.StackTrace, System.Diagnostics.EventLogEntryType.Error);
                throw;
			}

			return bRespuesta;
		}
	}

	/// <summary>
	/// Summary description for LDAPAuthentication.
	/// </summary>
	public class LDAPAuthentication
	{
		private string _path;
		private string _filterAttribute;

		public LDAPAuthentication(string path)
		{
			_path = path;
		}

		public bool IsAuthenticated(string username, string pwd)
		{
			string domainAndUsername = @"BCR\" + username;
			DirectoryEntry entry = new DirectoryEntry(_path, domainAndUsername, pwd);

			try
			{
				//Bind to the native AdsObject to force authentication
				Object obj = entry.NativeObject;
				DirectorySearcher search = new DirectorySearcher(entry);
				search.Filter = "(SAMAccountName=" + username + ")";
				search.PropertiesToLoad.Add("cn");
				SearchResult result = search.FindOne();
				if (null == result)
				{
					return false;
				}
				//Update the new path to the user in the directory
				_path = result.Path;
				_filterAttribute = (String) result.Properties["cn"][0];
			}
			catch (Exception e)
			{
				throw new Exception("Error autenticando usuario. " + e.Message);
			}
			return true;
		}
	}
}
