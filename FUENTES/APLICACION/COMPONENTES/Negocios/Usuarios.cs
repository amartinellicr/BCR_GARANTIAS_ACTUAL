using System;
using System.Data.SqlClient;
using System.Data;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{

    /// <summary>
    /// Summary description for MultiUsuarios.
    /// </summary>
    public class Usuarios
    {
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        int nFilasAfectadas = 0;

        #endregion Variables Globales

        #region Métodos Públicos

        public clsUsuario Crear(string strIdentificacion, string strNuevoUsuario, int nPerfil, string strUsuario, string strIP)
        {
            clsUsuario UsuarioLocal;

            listaCampos = new string[] {clsUsuario._entidadUsuario,
                                        clsUsuario._cedulaUsuario, clsUsuario._nombreUsuario, clsUsuario._codigoPerfil,
                                        strIdentificacion, strNuevoUsuario, nPerfil.ToString()};

            string strInsertarUsuario = string.Format("INSERT INTO dbo.{0} ({1}, {2}, {3}) VALUES('{4}', '{5}', {6})", listaCampos);

            try
            {
                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strInsertarUsuario, oConexion))
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

                UsuarioLocal = new clsUsuario(strIdentificacion, strUsuario, nPerfil);

                if (nFilasAfectadas > 0)
                {
                    #region Inserción en Bitácora

                    Bitacora oBitacora = new Bitacora();

                    oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
                       1, null, string.Empty, string.Empty, strInsertarUsuario, string.Empty, clsUsuario._cedulaUsuario,
                       string.Empty,
                       strIdentificacion);

                    oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
                       1, null, string.Empty, string.Empty, strInsertarUsuario, string.Empty, clsUsuario._nombreUsuario,
                       string.Empty,
                       strNuevoUsuario);

                    listaCampos = new string[] { clsPerfil._descripcionPerfil,
                                             clsPerfil._entidadPerfil,
                                             clsPerfil._codigoPerfil, nPerfil.ToString()};

                    string strConsultaPerfil = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                    DataSet dsPerfil = AccesoBD.ejecutarConsulta(strConsultaPerfil);

                    if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
                    {
                        oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
                           1, null, string.Empty, string.Empty, strInsertarUsuario, string.Empty, clsUsuario._codigoPerfil,
                           string.Empty,
                           dsPerfil.Tables[0].Rows[0][clsPerfil._descripcionPerfil].ToString());
                    }
                    else
                    {
                        oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
                           1, null, string.Empty, string.Empty, strInsertarUsuario, string.Empty, clsUsuario._codigoPerfil,
                           string.Empty,
                           nPerfil.ToString());
                    }

                    #endregion
                }
            }
            catch
            {
                throw;
            }

            return UsuarioLocal;
        }

        public clsUsuario Modificar(string strIdentificacion, string strNuevoUsuario, int nPerfil, string strUsuario, string strIP)
        {
            clsUsuario UsuarioLocal;

            listaCampos = new string[] {clsUsuario._entidadUsuario,
                                        clsUsuario._codigoPerfil, nPerfil.ToString(),
                                        clsUsuario._cedulaUsuario, strIdentificacion};

            string strModificarUsuario = string.Format("UPDATE dbo.{0} SET {1} = {2} WHERE {3} = '{4}'", listaCampos);

            try
            {
                listaCampos = new string[] {clsUsuario._codigoPerfil,
                                            clsUsuario._entidadUsuario,
                                            clsUsuario._cedulaUsuario, strIdentificacion};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = '{3}'", listaCampos);

                DataSet dsUsuario = AccesoBD.ejecutarConsulta(sentenciaSql);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strModificarUsuario, oConexion))
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

                UsuarioLocal = new clsUsuario(strIdentificacion, strNuevoUsuario, nPerfil);

                if (nFilasAfectadas > 0)
                {
                    #region Inserción en Bitácora

                    if ((dsUsuario != null) && (dsUsuario.Tables.Count > 0) && (dsUsuario.Tables[0].Rows.Count > 0))
                    {
                        Bitacora oBitacora = new Bitacora();

                        if (!dsUsuario.Tables[0].Rows[0].IsNull(clsUsuario._codigoPerfil))
                        {
                            int nCodigoPerfilObt = Convert.ToInt32(dsUsuario.Tables[0].Rows[0][clsUsuario._codigoPerfil].ToString());

                            if (nCodigoPerfilObt != nPerfil)
                            {
                                listaCampos = new string[] {clsPerfil._descripcionPerfil,
                                                            clsPerfil._entidadPerfil,
                                                            clsPerfil._codigoPerfil,  nCodigoPerfilObt.ToString()};

                                string strConsultaPerfilObt = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                                listaCampos = new string[] {clsPerfil._descripcionPerfil,
                                                            clsPerfil._entidadPerfil,
                                                            clsPerfil._codigoPerfil,  nPerfil.ToString()};

                                string strConsultaPerfil = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                                DataSet dsPerfilObt = AccesoBD.ejecutarConsulta(strConsultaPerfilObt);

                                DataSet dsPerfil = AccesoBD.ejecutarConsulta(strConsultaPerfil);

                                if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0)
                                   && (dsPerfilObt != null) && (dsPerfilObt.Tables.Count > 0) && (dsPerfilObt.Tables[0].Rows.Count > 0))
                                {
                                    oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
                                       2, null, string.Empty, string.Empty, strModificarUsuario, string.Empty, clsUsuario._codigoPerfil,
                                       dsPerfilObt.Tables[0].Rows[0][clsPerfil._descripcionPerfil].ToString(),
                                       dsPerfil.Tables[0].Rows[0][clsPerfil._descripcionPerfil].ToString());
                                }
                                else
                                {
                                    oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
                                       2, null, string.Empty, string.Empty, strModificarUsuario, string.Empty, clsUsuario._codigoPerfil,
                                       nCodigoPerfilObt.ToString(),
                                       nPerfil.ToString());
                                }
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarUsuario, string.Empty, clsUsuario._codigoPerfil,
                                   string.Empty,
                                   nPerfil.ToString());
                        }
                    }

                    #endregion
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
            try
            {
                listaCampos = new string[] {clsUsuario._entidadUsuario,
                                        clsUsuario._cedulaUsuario, strIdentificacion};

                string strEliminarUsuario = string.Format("DELETE FROM dbo.{0} WHERE {1} = '{2}'", listaCampos);

                listaCampos = new string[] {clsUsuario._cedulaUsuario, clsUsuario._nombreUsuario, clsUsuario._codigoPerfil,
                                        clsUsuario._entidadUsuario,
                                        clsUsuario._cedulaUsuario, strIdentificacion};

                string strConsultaUsuario = string.Format("SELECT {0}, {1}, {2} FROM dbo.{3} WHERE {4} = '{5}'", listaCampos);

                //Se obtienen los datos antes de ser borrados, con el fin de poderlos insertar en la bitácora
                DataSet dsUsuario = AccesoBD.ejecutarConsulta(strConsultaUsuario);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strEliminarUsuario, oConexion))
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

                    if ((dsUsuario != null) && (dsUsuario.Tables.Count > 0) && (dsUsuario.Tables[0].Rows.Count > 0))
                    {
                        foreach (DataRow drUsuario in dsUsuario.Tables[0].Rows)
                        {
                            for (int nIndice = 0; nIndice < drUsuario.Table.Columns.Count; nIndice++)
                            {
                                if (drUsuario.Table.Columns[nIndice].ColumnName.CompareTo(clsUsuario._codigoPerfil) == 0)
                                {
                                    listaCampos = new string[] {clsPerfil._descripcionPerfil,
                                                            clsPerfil._entidadPerfil,
                                                            clsPerfil._codigoPerfil,  dsUsuario.Tables[0].Rows[0][clsUsuario._codigoPerfil].ToString()};

                                    string strConsultaPerfil = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                                    DataSet dsPerfil = AccesoBD.ejecutarConsulta(strConsultaPerfil);

                                    if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
                                    {
                                        oBitacora.InsertarBitacora("SEG_USUARIO", strUsuario, strIP, null,
                                           3, null, string.Empty, string.Empty, strEliminarUsuario, string.Empty,
                                           drUsuario.Table.Columns[nIndice].ColumnName,
                                           dsPerfil.Tables[0].Rows[0][clsPerfil._descripcionPerfil].ToString(),
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
            catch
            {
                throw;
            }
        }

        public bool UsuarioExiste(string strIdentificacion)
        {
            bool bExisteUsuario = false;

            listaCampos = new string[] {clsUsuario._nombreUsuario, 
                                        clsUsuario._entidadUsuario,
                                        clsUsuario._cedulaUsuario, strIdentificacion};

            string strConsultarUsuarioExiste = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = '{3}'", listaCampos);

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

        public string[] ObtenerPerfilUsuario(string strIdentificacion)
        {
            string[] perfilUsuarioObtenido = { string.Empty, string.Empty };

            string strConsultarUsuarioExiste = string.Format("SELECT SEU.COD_PERFIL, SEP.DES_PERFIL FROM dbo.SEG_USUARIO SEU INNER JOIN dbo.SEG_PERFIL SEP ON SEP.COD_PERFIL = SEU.COD_PERFIL WHERE SEU.COD_USUARIO = '{0}'", strIdentificacion);
            
            try
            {
                DataSet DatosUsuario = AccesoBD.ejecutarConsulta(strConsultarUsuarioExiste);

                if ((DatosUsuario != null) && (DatosUsuario.Tables.Count > 0) && (DatosUsuario.Tables[0].Rows.Count > 0))
                {
                    perfilUsuarioObtenido[0] = ((!DatosUsuario.Tables[0].Rows[0].IsNull("COD_PERFIL")) ? DatosUsuario.Tables[0].Rows[0]["COD_PERFIL"].ToString() : "-1");
                    perfilUsuarioObtenido[1] = ((!DatosUsuario.Tables[0].Rows[0].IsNull("DES_PERFIL")) ? DatosUsuario.Tables[0].Rows[0]["DES_PERFIL"].ToString() : string.Empty);
                }
            }
            catch
            {
                throw;
            }

            return perfilUsuarioObtenido;

        }

        #endregion Métodos Públicos
    }
}
