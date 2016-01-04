using System;
using System.Data;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Peritos.
    /// </summary>
    public class Peritos
	{
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        int nFilasAfectadas = 0;

        #endregion Variables Globales

        #region Metodos Publicos

        public void Crear(string strCedula, string strNombre, int nTipoPersona, string strTelefono,
                          string strEmail, string strDireccion, string strUsuario, string strIP)
        {
            try
            {
                listaCampos = new string[] { clsPerito._entidadPerito,
                                             clsPerito._cedulaPerito, clsPerito._nombrePerito, clsPerito._codigoTipoPersona, clsPerito._numeroTelefono, clsPerito._correo, clsPerito._direccion,
                                             strCedula, strNombre, nTipoPersona.ToString(), strTelefono, strEmail, strDireccion};

                string strInsertarPerito = string.Format("INSERT INTO dbo.{0} ({1}, {2}, {3}, {4}, {5}, {6}) VALUES('{7}', '{8}', {9}, '{10}', '{11}', '{12}')", listaCampos);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strInsertarPerito, oConexion))
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

                    TraductordeCodigos oTraductor = new TraductordeCodigos();

                    oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                       1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, clsPerito._cedulaPerito,
                       string.Empty,
                       strCedula);

                    oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                       1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, clsPerito._nombrePerito,
                       string.Empty,
                       strNombre);

                    oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                       1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, clsPerito._codigoTipoPersona,
                       string.Empty,
                       oTraductor.TraducirTipoPersona(nTipoPersona));

                    oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                       1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, clsPerito._numeroTelefono,
                       string.Empty,
                       strTelefono);

                    oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                       1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, clsPerito._correo,
                       string.Empty,
                       strEmail);

                    oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                       1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, clsPerito._direccion,
                       string.Empty,
                       strDireccion);
                }
            }
            catch
            {
                throw;
            }
        }

		public void Modificar(string strCedula, string strNombre, int nTipoPersona, string strTelefono,
                              string strEmail, string strDireccion, string strUsuario, string strIP)
		{
            DataSet dsPerito = new DataSet();

            try
            {
                listaCampos = new string[] {clsPerito._cedulaPerito, clsPerito._nombrePerito, clsPerito._codigoTipoPersona, clsPerito._numeroTelefono, clsPerito._correo, clsPerito._direccion,
                                            clsPerito._entidadPerito,
                                            clsPerito._cedulaPerito, strCedula};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5} FROM dbo.{6} WHERE {7} = '{8}')", listaCampos);

                //Se obtienen los datos antes de ser modificados, con el fin de poder ingresarlos en la bitácora
                dsPerito = AccesoBD.ejecutarConsulta(sentenciaSql);


                listaCampos = new string[] {clsPerito._entidadPerito,
                                            clsPerito._cedulaPerito, strCedula,
                                            clsPerito._nombrePerito, strNombre,
                                            clsPerito._codigoTipoPersona, nTipoPersona.ToString(),
                                            clsPerito._numeroTelefono, strTelefono,
                                            clsPerito._correo, strEmail,
                                            clsPerito._direccion, strDireccion,
                                            clsPerito._cedulaPerito, strCedula};

                string strModificarPerito = string.Format("UPDATE dbo.{0} SET {1} = '{2}', {3} = '{4}', {5} = {6}, {7} = '{8}', {9} = '{10}', {11} = '{12}' WHERE {13} = '{14}'", listaCampos);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strModificarPerito, oConexion))
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

                    if ((dsPerito != null) && (dsPerito.Tables.Count > 0) && (dsPerito.Tables[0].Rows.Count > 0))
                    {
                        Bitacora oBitacora = new Bitacora();

                        TraductordeCodigos oTraductor = new TraductordeCodigos();

                        if (!dsPerito.Tables[0].Rows[0].IsNull(clsPerito._cedulaPerito))
                        {
                            string strCedulaPeritoObt = dsPerito.Tables[0].Rows[0][clsPerito._cedulaPerito].ToString();

                            if (strCedulaPeritoObt.CompareTo(strCedula) != 0)
                            {
                                oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._cedulaPerito,
                                   strCedulaPeritoObt,
                                   strCedula);
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._cedulaPerito,
                                   string.Empty,
                                   strCedula);
                        }

                        if (!dsPerito.Tables[0].Rows[0].IsNull(clsPerito._nombrePerito))
                        {
                            string strNombrePeritoObt = dsPerito.Tables[0].Rows[0][clsPerito._nombrePerito].ToString();

                            if (strNombrePeritoObt.CompareTo(strNombre) != 0)
                            {
                                oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._nombrePerito,
                                   strNombrePeritoObt,
                                   strNombre);
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._nombrePerito,
                                   string.Empty,
                                   strNombre);
                        }

                        if (!dsPerito.Tables[0].Rows[0].IsNull(clsPerito._codigoTipoPersona))
                        {
                            int nCodigoTipoPersonaObt = Convert.ToInt32(dsPerito.Tables[0].Rows[0][clsPerito._codigoTipoPersona].ToString());

                            if (nCodigoTipoPersonaObt != nTipoPersona)
                            {
                                oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._codigoTipoPersona,
                                   oTraductor.TraducirTipoPersona(nCodigoTipoPersonaObt),
                                   oTraductor.TraducirTipoPersona(nTipoPersona));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._codigoTipoPersona,
                                   string.Empty,
                                   oTraductor.TraducirTipoPersona(nTipoPersona));
                        }

                        if (!dsPerito.Tables[0].Rows[0].IsNull(clsPerito._numeroTelefono))
                        {
                            string strTelefonoObt = dsPerito.Tables[0].Rows[0][clsPerito._numeroTelefono].ToString();

                            if (strTelefonoObt.CompareTo(strTelefono) != 0)
                            {
                                oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._numeroTelefono,
                                   strTelefonoObt,
                                   strTelefono);
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._numeroTelefono,
                                   string.Empty,
                                   strTelefono);
                        }

                        if (!dsPerito.Tables[0].Rows[0].IsNull(clsPerito._correo))
                        {
                            string strEmailObt = dsPerito.Tables[0].Rows[0][clsPerito._correo].ToString();

                            if (strEmailObt.CompareTo(strEmail) != 0)
                            {
                                oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._correo,
                                   strEmailObt,
                                   strEmail);
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._correo,
                                   string.Empty,
                                   strEmail);
                        }

                        if (!dsPerito.Tables[0].Rows[0].IsNull(clsPerito._direccion))
                        {
                            string strDireccionObt = dsPerito.Tables[0].Rows[0][clsPerito._direccion].ToString();

                            if (strDireccionObt.CompareTo(strDireccion) != 0)
                            {
                                oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._direccion,
                                   strDireccionObt,
                                   strDireccion);
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, clsPerito._direccion,
                                   string.Empty,
                                   strDireccion);
                        }
                    }

                    #endregion
                }
            }
            catch
            {
                throw;
            }
		}

        public void Eliminar(string strCedula, string strUsuario, string strIP)
		{
            DataSet dsPerito = new DataSet();

            try
            {
                listaCampos = new string[] {clsPerito._cedulaPerito, clsPerito._nombrePerito, clsPerito._codigoTipoPersona, clsPerito._numeroTelefono, clsPerito._correo, clsPerito._direccion,
                                            clsPerito._entidadPerito,
                                            clsPerito._cedulaPerito, strCedula};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5} FROM dbo.{6} WHERE {7} = '{8}')", listaCampos);

                dsPerito = AccesoBD.ejecutarConsulta(sentenciaSql);

                listaCampos = new string[] {clsPerito._entidadPerito,
                                            clsPerito._cedulaPerito, strCedula};

                string strEliminarPerito = string.Format("DELETE FROM dbo.{0} WHERE {1} = '{2}'", listaCampos);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strEliminarPerito, oConexion))
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

                    TraductordeCodigos oTraductor = new TraductordeCodigos();

                    if ((dsPerito != null) && (dsPerito.Tables.Count > 0) && (dsPerito.Tables[0].Rows.Count > 0))
                    {
                        foreach (DataRow drPerito in dsPerito.Tables[0].Rows)
                        {
                            for (int nIndice = 0; nIndice < drPerito.Table.Columns.Count; nIndice++)
                            {
                                if (drPerito.Table.Columns[nIndice].ColumnName.CompareTo(clsPerito._codigoTipoPersona) == 0)
                                {
                                    if (drPerito[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                           3, null, string.Empty, string.Empty, strEliminarPerito, string.Empty,
                                           drPerito.Table.Columns[nIndice].ColumnName,
                                           oTraductor.TraducirTipoPersona(Convert.ToInt32(drPerito[nIndice, DataRowVersion.Current].ToString())),
                                           string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                           3, null, string.Empty, string.Empty, strEliminarPerito, string.Empty,
                                           drPerito.Table.Columns[nIndice].ColumnName,
                                           string.Empty,
                                           string.Empty);
                                    }
                                }
                                else
                                {
                                    oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                                       3, null, string.Empty, string.Empty, strEliminarPerito, string.Empty,
                                       drPerito.Table.Columns[nIndice].ColumnName,
                                       drPerito[nIndice, DataRowVersion.Current].ToString(),
                                       string.Empty);
                                }
                            }
                        }
                    }
                    else
                    {
                        oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
                          3, null, string.Empty, string.Empty, strEliminarPerito, string.Empty, string.Empty,
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
		#endregion
	}
}
