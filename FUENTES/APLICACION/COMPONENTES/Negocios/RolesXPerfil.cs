using System.Data.SqlClient;
using System.Data;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
	/// Summary description for MultiRolesXPerfil.
	/// </summary>
	public class RolesXPerfil
    {
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        int nFilasAfectadas = 0;

        #endregion Variables Globales

        #region Métodos Públicos

        public void Crear(int nPerfil, int nRol, string strUsuario, string strIP)
        {
            try
            {
                listaCampos = new string[] { clsRolXPerfil._entidadRolXPerfil,
                                             clsRolXPerfil._codigoPerfil, clsRolXPerfil._codigoRol,
                                             nPerfil.ToString(), nRol.ToString()};

                string strInsertarRolesXPerfil = string.Format("INSERT INTO dbo.{0} ({1}, {2}) VALUES({3}, {4})", listaCampos);

                listaCampos = new string[] { clsPerfil._descripcionPerfil,
                                             clsPerfil._entidadPerfil,
                                             clsPerfil._codigoPerfil, nPerfil.ToString()};

                string strConsultaPerfil = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                listaCampos = new string[] { clsRol._descripcionRol,
                                             clsRol._entidadRol,
                                             clsRol._codigoRol, nRol.ToString()};

                string strConsultaRol = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                DataSet dsPerfil = AccesoBD.ejecutarConsulta(strConsultaPerfil);

                DataSet dsRol = AccesoBD.ejecutarConsulta(strConsultaRol);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strInsertarRolesXPerfil, oConexion))
                    {
                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.Text;
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        nFilasAfectadas = oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }

                if (nFilasAfectadas > 0)
                {
                    #region Inserción en Bitácora

                    Bitacora oBitacora = new Bitacora();

                    if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
                    {
                        oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
                       1, null, string.Empty, string.Empty, strInsertarRolesXPerfil, string.Empty,
                       clsRolXPerfil._codigoPerfil,
                       string.Empty,
                       dsPerfil.Tables[0].Rows[0][clsPerfil._descripcionPerfil].ToString());
                    }
                    else
                    {
                        oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
                           1, null, string.Empty, string.Empty, strInsertarRolesXPerfil, string.Empty, clsRolXPerfil._codigoPerfil,
                           string.Empty,
                           nPerfil.ToString());
                    }

                    if ((dsRol != null) && (dsRol.Tables.Count > 0) && (dsRol.Tables[0].Rows.Count > 0))
                    {
                        oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
                           1, null, string.Empty, string.Empty, strInsertarRolesXPerfil, string.Empty,
                           clsRolXPerfil._codigoRol,
                           string.Empty,
                           dsRol.Tables[0].Rows[0][clsRol._descripcionRol].ToString());
                    }
                    else
                    {
                        oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
                           1, null, string.Empty, string.Empty, strInsertarRolesXPerfil, string.Empty,
                           clsRolXPerfil._codigoRol,
                           string.Empty,
                           nRol.ToString());
                    }

                    #endregion
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
                listaCampos = new string[] { clsRolXPerfil._entidadRolXPerfil,
                                             clsRolXPerfil._codigoPerfil, nPerfil.ToString(),
                                             clsRol._codigoRol, nRol.ToString()};

                string strEliminarRolesXPerfil = string.Format("DELETE DBO.{0} WHERE {1} = {2} AND {3} = {4}", listaCampos);

                listaCampos = new string[] { clsRolXPerfil._codigoPerfil, clsRolXPerfil._codigoRol,
                                             clsRolXPerfil._entidadRolXPerfil,
                                             clsRolXPerfil._codigoPerfil, nPerfil.ToString(),
                                             clsRol._codigoRol, nRol.ToString()};

                sentenciaSql = string.Format("SELECT {0}, {1} FROM dbo.{2} WHERE {3} = {4} AND {5} = {6}", listaCampos);

                //Se obtienen los datos antes de ser borrados, para insertarlos en la bitácora
                DataSet dsRolXPerfil = AccesoBD.ejecutarConsulta(sentenciaSql);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strEliminarRolesXPerfil, oConexion))
                    {
                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.Text;
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        nFilasAfectadas = oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }

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
                                    if (drRolXPerfil.Table.Columns[nIndice].ColumnName.CompareTo(clsRolXPerfil._codigoPerfil) == 0)
                                    {
                                        int nCodigoPerfil;

                                        if (int.TryParse(drRolXPerfil[nIndice, DataRowVersion.Current].ToString(), out nCodigoPerfil))
                                        {
                                            listaCampos = new string[] { clsPerfil._descripcionPerfil,
                                             clsPerfil._entidadPerfil,
                                             clsPerfil._codigoPerfil, nPerfil.ToString()};

                                            string strConsultaPerfil = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                                            DataSet dsPerfil = AccesoBD.ejecutarConsulta(strConsultaPerfil);

                                            if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
                                            {
                                                oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
                                                  3, null, string.Empty, string.Empty, strEliminarRolesXPerfil, string.Empty,
                                                  drRolXPerfil.Table.Columns[nIndice].ColumnName,
                                                  dsPerfil.Tables[0].Rows[0][clsPerfil._descripcionPerfil].ToString(),
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
                                    else if (drRolXPerfil.Table.Columns[nIndice].ColumnName.CompareTo(clsRolXPerfil._codigoRol) == 0)
                                    {
                                        int nCodigoRol;

                                        if (int.TryParse(drRolXPerfil[nIndice, DataRowVersion.Current].ToString(), out nCodigoRol))
                                        {
                                            listaCampos = new string[] { clsRol._descripcionRol,
                                             clsRol._entidadRol,
                                             clsRol._codigoRol, nRol.ToString()};

                                            string strConsultaRol = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                                            DataSet dsRol = AccesoBD.ejecutarConsulta(strConsultaRol);

                                            if ((dsRol != null) && (dsRol.Tables.Count > 0) && (dsRol.Tables[0].Rows.Count > 0))
                                            {
                                                oBitacora.InsertarBitacora("SEG_ROLES_X_PERFIL", strUsuario, strIP, null,
                                                  3, null, string.Empty, string.Empty, strEliminarRolesXPerfil, string.Empty,
                                                  drRolXPerfil.Table.Columns[nIndice].ColumnName,
                                                  dsRol.Tables[0].Rows[0][clsRol._descripcionRol].ToString(),
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

        #endregion Métodos Públicos
    }
}
