using System.Data;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;


namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for MultiPerfiles.
    /// </summary>
    public class Perfiles
	{
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
       int nFilasAfectadas = 0;

        #endregion Variables Globales

        #region Metodos Publicos

        public void Crear(string strPerfil, string strUsuario, string strIP)
        {
            try
            {
                listaCampos = new string[] { clsPerfil._entidadPerfil,
                                             clsPerfil._descripcionPerfil,
                                             strPerfil};

                string strInsertarPerfil = string.Format("INSERT INTO dbo.{0} ({1}) VALUES ('{2}')", listaCampos);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strInsertarPerfil, oConexion))
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
                    Bitacora oBitacora = new Bitacora();

                    oBitacora.InsertarBitacora("SEG_PERFIL", strUsuario, strIP, null,
                       1, null, string.Empty, string.Empty, strInsertarPerfil, string.Empty, clsPerfil._descripcionPerfil,
                       string.Empty,
                       strPerfil);
                }
            }
            catch
            {
                throw;
            }
        }

		public void Modificar(int nPerfil, string strPerfil, string strUsuario, string strIP)
		{
            DataSet dsPerfil = new DataSet();

            try
            {
                listaCampos = new string[] { clsPerfil._entidadPerfil,
                                             clsPerfil._descripcionPerfil, strPerfil,
                                             clsPerfil._codigoPerfil, nPerfil.ToString()};

                string strModificarPerfil = string.Format("UPDATE dbo.{0} SET {1} = '{2}' WHERE {3} = {4}", listaCampos);

                listaCampos = new string[] { clsPerfil._descripcionPerfil,
                                             clsPerfil._entidadPerfil,
                                             clsPerfil._codigoPerfil, nPerfil.ToString()};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                dsPerfil = AccesoBD.ejecutarConsulta(sentenciaSql);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strModificarPerfil, oConexion))
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
                    if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
                    {
                        Bitacora oBitacora = new Bitacora();

                        if (!dsPerfil.Tables[0].Rows[0].IsNull(clsPerfil._descripcionPerfil))
                        {
                            string strDescripcionPerfilObt = dsPerfil.Tables[0].Rows[0][clsPerfil._descripcionPerfil].ToString();

                            if (strDescripcionPerfilObt.CompareTo(strPerfil) != 0)
                            {
                                oBitacora.InsertarBitacora("SEG_PERFIL", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerfil, string.Empty, clsPerfil._descripcionPerfil,
                                   strDescripcionPerfilObt,
                                   strPerfil);
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

		public void Eliminar(int nPerfil, string strUsuario, string strIP)
		{
            DataSet dsPerfil = new DataSet();

            try
            {
                listaCampos = new string[] { clsPerfil._entidadPerfil,
                                             clsPerfil._codigoPerfil, nPerfil.ToString()};

                string strEliminarPerfil = string.Format("DELETE FROM dbo.{0} WHERE {1} = {2}", listaCampos);

                listaCampos = new string[] { clsPerfil._descripcionPerfil,
                                             clsPerfil._entidadPerfil,
                                             clsPerfil._codigoPerfil, nPerfil.ToString()};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                dsPerfil = AccesoBD.ejecutarConsulta(sentenciaSql);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strEliminarPerfil, oConexion))
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
                    Bitacora oBitacora = new Bitacora();

                    if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
                    {
                        foreach (DataRow drPerfil in dsPerfil.Tables[0].Rows)
                        {
                            for (int nIndice = 0; nIndice < drPerfil.Table.Columns.Count; nIndice++)
                            {
                                oBitacora.InsertarBitacora("SEG_PERFIL", strUsuario, strIP, null,
                                   3, null, string.Empty, string.Empty, strEliminarPerfil, string.Empty,
                                   drPerfil.Table.Columns[nIndice].ColumnName,
                                   drPerfil[nIndice, DataRowVersion.Current].ToString(),
                                   string.Empty);
                            }
                        }
                    }
                    else
                    {
                        oBitacora.InsertarBitacora("SEG_PERFIL", strUsuario, strIP, null,
                          3, null, string.Empty, string.Empty, strEliminarPerfil, string.Empty, string.Empty,
                          string.Empty,
                          string.Empty);
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
