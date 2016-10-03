using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;
using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Garantias_Fiduciarias.
    /// </summary>
    public class Garantias_Fiduciarias
    {
        #region Metodos Publicos

        /// <summary>
        /// Método que permite insertar una garantía fiduciaria
        /// </summary>
        /// <param name="entidadGarantiaFiduciaria">Entidad que posee la información que será ingresada</param>
        /// <param name="direccionIP">Dirección IP de la máquina desde la cual se hace el ingreso de los datos</param>
        /// <param name="strOperacionCrediticia">Número de operación, bajo el formato Contabilidad - Oficina - Moneda - Producto - Num Operación / Num. Contrato</param>
        public void Crear(clsGarantiaFiduciaria entidadGarantiaFiduciaria, string direccionIP, string strOperacionCrediticia)
        {
            string identifiacionGarantia = string.Format("Fiduciaria: {0} - {1}, relacionada a la operación/contrato: {2}", entidadGarantiaFiduciaria.CedulaFiador, entidadGarantiaFiduciaria.NombreFiador, strOperacionCrediticia);
            int nFilasAfectadas = 0;

            try
            {
                //Se obtiene la información de la Garantía Fiduciaria, esto por si se debe insertar
                DataSet dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta(string.Format("SELECT {0} FROM dbo.GAR_GARANTIA_FIDUCIARIA WHERE {1} = '{2}'", clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, clsGarantiaFiduciaria._cedulaFiador, entidadGarantiaFiduciaria.CedulaFiador));

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_InsertarGarantiaFiduciaria", oConexion))
                    {
                        DataSet dsData = new DataSet();

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        //Agrega los parametros
                        oComando.Parameters.AddWithValue("@piTipo_Garantia", entidadGarantiaFiduciaria.CodigoTipoGarantia);
                        oComando.Parameters.AddWithValue("@piClase_Garantia", entidadGarantiaFiduciaria.CodigoClaseGarantia);
                        oComando.Parameters.AddWithValue("@psCedula_Fiador", entidadGarantiaFiduciaria.CedulaFiador);
                        oComando.Parameters.AddWithValue("@psNombre_Fiador", entidadGarantiaFiduciaria.NombreFiador);
                        oComando.Parameters.AddWithValue("@piTipo_Fiador", entidadGarantiaFiduciaria.CodigoTipoPersonaFiador);
                        oComando.Parameters.AddWithValue("@pbConsecutivo_Operacion", entidadGarantiaFiduciaria.ConsecutivoOperacion);
                        oComando.Parameters.AddWithValue("@piTipo_Mitigador", entidadGarantiaFiduciaria.CodigoTipoMitigador);
                        oComando.Parameters.AddWithValue("@piTipo_Documento_Legal", entidadGarantiaFiduciaria.CodigoTipoDocumentoLegal);
                        oComando.Parameters.AddWithValue("@pdMonto_Mitigador", entidadGarantiaFiduciaria.MontoMitigador);
                        oComando.Parameters.AddWithValue("@pdPorcentaje_Responsabilidad", entidadGarantiaFiduciaria.PorcentajeResponsabilidad);
                        oComando.Parameters.AddWithValue("@piOperacion_Especial", entidadGarantiaFiduciaria.CodigoOperacionEspecial);
                        oComando.Parameters.AddWithValue("@piTipo_Acreedor", entidadGarantiaFiduciaria.CodigoTipoPersonaAcreedor);
                        oComando.Parameters.AddWithValue("@psCedula_Acreedor", entidadGarantiaFiduciaria.CedulaAcreedor);
                        oComando.Parameters.AddWithValue("@pdPorcentaje_Aceptacion", entidadGarantiaFiduciaria.PorcentajeAceptacion);

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

                    if ((dsGarantiaFiduciaria == null) || (dsGarantiaFiduciaria.Tables.Count == 0) || (dsGarantiaFiduciaria.Tables[0].Rows.Count == 0))
                    {
                        #region Garantía Fiduciaria

                        string[] listaCampos = {clsGarantiaFiduciaria._codigoTipoGarantia, clsGarantiaFiduciaria._codigoClaseGarantia, clsGarantiaFiduciaria._cedulaFiador, 
                                                clsGarantiaFiduciaria._nombreFiador, clsGarantiaFiduciaria._codigoTipoPersonaFiador, entidadGarantiaFiduciaria.CodigoTipoGarantia.ToString(),
                                                entidadGarantiaFiduciaria.CodigoClaseGarantia.ToString(), entidadGarantiaFiduciaria.CedulaFiador, entidadGarantiaFiduciaria.NombreFiador, entidadGarantiaFiduciaria.CodigoTipoPersonaFiador.ToString()};

                        string strInsertaGarantiaFiduciaria = string.Format("INSERT INTO GAR_GARANTIA_FIDUCIARIA ({0}, {1}, {2}, {3}, {4}) VALUES({5}, {6}, {7}, {8}, {9})", listaCampos);

                        oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1,
                            entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarantiaFiduciaria, string.Empty,
                            clsGarantiaFiduciaria._cedulaFiador,
                            string.Empty,
                            entidadGarantiaFiduciaria.CedulaFiador);

                        oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarantiaFiduciaria, string.Empty,
                            clsGarantiaFiduciaria._codigoClaseGarantia,
                            string.Empty,
                            oTraductor.TraducirClaseGarantia(entidadGarantiaFiduciaria.CodigoClaseGarantia));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarantiaFiduciaria, string.Empty,
                            clsGarantiaFiduciaria._codigoTipoPersonaFiador,
                            string.Empty,
                            oTraductor.TraducirTipoPersona(entidadGarantiaFiduciaria.CodigoTipoPersonaFiador));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarantiaFiduciaria, string.Empty,
                            clsGarantiaFiduciaria._codigoTipoGarantia,
                            string.Empty,
                            oTraductor.TraducirTipoGarantia(entidadGarantiaFiduciaria.CodigoTipoGarantia));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarantiaFiduciaria, string.Empty,
                            clsGarantiaFiduciaria._nombreFiador,
                            string.Empty,
                            entidadGarantiaFiduciaria.NombreFiador);

                        dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta(string.Format("SELECT {0} FROM dbo.GAR_GARANTIA_FIDUCIARIA WHERE {1} = '{2}'", clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, clsGarantiaFiduciaria._cedulaFiador, entidadGarantiaFiduciaria.CedulaFiador));

                        #endregion
                    }

                    if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
                    {
                        #region Garantía Fiduciaria por Operación

                        string strCodigoGarFidu = dsGarantiaFiduciaria.Tables[0].Rows[0][clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria].ToString();

                        string[] listaCampos = {clsGarantiaFiduciaria._consecutivoOperacion, clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, clsGarantiaFiduciaria._codigoTipoMitigador,
                                                clsGarantiaFiduciaria._codigoTipoDocumentoLegal, clsGarantiaFiduciaria._montoMitigador, clsGarantiaFiduciaria._porcentajeResponsabilidad,
                                                clsGarantiaFiduciaria._codigoOperacionEspecial, clsGarantiaFiduciaria._codigoTipoPersonaAcreedor, clsGarantiaFiduciaria._cedulaAcreedor,
                                                clsGarantiaFiduciaria._porcentajeAceptacion, entidadGarantiaFiduciaria.ConsecutivoOperacion.ToString(),
                                                entidadGarantiaFiduciaria.ConsecutivoGarantiaFiduciaria.ToString(), entidadGarantiaFiduciaria.CodigoTipoMitigador.ToString(),
                                                entidadGarantiaFiduciaria.CodigoTipoDocumentoLegal.ToString(), entidadGarantiaFiduciaria.MontoMitigador.ToString(),
                                                entidadGarantiaFiduciaria.PorcentajeResponsabilidad.ToString(), entidadGarantiaFiduciaria.CodigoOperacionEspecial.ToString(),
                                                entidadGarantiaFiduciaria.CodigoTipoPersonaAcreedor.ToString(), entidadGarantiaFiduciaria.CedulaAcreedor, entidadGarantiaFiduciaria.PorcentajeAceptacion.ToString()};

                        string strInsertaGarFiduXOperacion = string.Format("INSERT INTO GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}) VALUES({10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19})", listaCampos);

                        long nGarantiaFiduciaria = (long)Convert.ToInt32(strCodigoGarFidu);

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
                            clsGarantiaFiduciaria._cedulaAcreedor,
                            string.Empty,
                            entidadGarantiaFiduciaria.CedulaAcreedor);

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
                            clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria,
                            string.Empty,
                            entidadGarantiaFiduciaria.CedulaFiador);

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
                            clsGarantiaFiduciaria._consecutivoOperacion,
                            string.Empty,
                            strOperacionCrediticia);

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
                            clsGarantiaFiduciaria._codigoOperacionEspecial,
                            string.Empty,
                            oTraductor.TraducirTipoOperacionEspecial(entidadGarantiaFiduciaria.CodigoOperacionEspecial));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
                            clsGarantiaFiduciaria._codigoTipoPersonaAcreedor,
                            string.Empty,
                            oTraductor.TraducirTipoPersona(entidadGarantiaFiduciaria.CodigoTipoPersonaAcreedor));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
                            clsGarantiaFiduciaria._codigoTipoDocumentoLegal,
                            string.Empty,
                            oTraductor.TraducirTipoDocumento(entidadGarantiaFiduciaria.CodigoTipoDocumentoLegal));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
                            clsGarantiaFiduciaria._codigoTipoMitigador,
                            string.Empty,
                            oTraductor.TraducirTipoMitigador(entidadGarantiaFiduciaria.CodigoTipoMitigador));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
                            clsGarantiaFiduciaria._montoMitigador, "0", entidadGarantiaFiduciaria.MontoMitigador.ToString());

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
                            clsGarantiaFiduciaria._porcentajeResponsabilidad, "0", entidadGarantiaFiduciaria.PorcentajeResponsabilidad.ToString());

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                            1, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strInsertaGarFiduXOperacion, string.Empty,
                            clsGarantiaFiduciaria._porcentajeAceptacion, "0", entidadGarantiaFiduciaria.PorcentajeAceptacion.ToString());

                        #endregion
                    }

                    #endregion
                }

            }
            catch (SqlException ex)
            {
                string errorBD = string.Format("Código del Error: {0}, Descripción del error: {1}", ex.ErrorCode.ToString(), ex.Message);
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoGarantiaDetalle, identifiacionGarantia, errorBD, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                throw ex;
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoGarantiaDetalle, identifiacionGarantia, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                throw ex;
            }
        }

        /// <summary>
        /// Método que permite modificar una garantía fiduciaria
        /// </summary>
        /// <param name="entidadGarantiaFiduciaria">Entidad que posee la información que será actualizada</param>
        /// <param name="strOperacionCrediticia">Número de operación, bajo el formato Contabilidad - Oficina - Moneda - Producto - Num Operación / Num. Contrato</param>
        /// <param name="direccionIP">Dirección IP de la máquina desde la cual se hace el ingreso de los datos</param>
        public void Modificar(clsGarantiaFiduciaria entidadGarantiaFiduciaria, string strOperacionCrediticia, string direccionIP)
        {
            string identifiacionGarantia = string.Format("Fiduciaria: {0} - {1}, relacionada a la operación/contrato: {2}", entidadGarantiaFiduciaria.CedulaFiador, entidadGarantiaFiduciaria.NombreFiador, strOperacionCrediticia);

            try
            {
                DataSet dsGarantiaFiduciariaXOperacion = new DataSet();

                DataSet dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta(string.Format("SELECT {0} FROM dbo.GAR_GARANTIA_FIDUCIARIA WHERE {1} = '{2}'", clsGarantiaFiduciaria._codigoTipoPersonaFiador, clsGarantiaFiduciaria._cedulaFiador, entidadGarantiaFiduciaria.CedulaFiador));

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_ModificarGarantiaFiduciaria", oConexion))
                    {
                        DataSet dsData = new DataSet();

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        //Agrega los parametros
                        oComando.Parameters.AddWithValue("@piConsecutivo_Garantia_Fiduciaria", entidadGarantiaFiduciaria.ConsecutivoGarantiaFiduciaria);
                        oComando.Parameters.AddWithValue("@piConsecutivo_Operacion", entidadGarantiaFiduciaria.ConsecutivoOperacion);
                        oComando.Parameters.AddWithValue("@psCedula_Fiador", entidadGarantiaFiduciaria.CedulaFiador);
                        oComando.Parameters.AddWithValue("@piTipo_Fiador", entidadGarantiaFiduciaria.CodigoTipoPersonaFiador);
                        oComando.Parameters.AddWithValue("@piTipo_Mitigador", entidadGarantiaFiduciaria.CodigoTipoMitigador);
                        oComando.Parameters.AddWithValue("@piTipo_Documento_Legal", entidadGarantiaFiduciaria.CodigoTipoDocumentoLegal);
                        oComando.Parameters.AddWithValue("@pdMonto_Mitigador", entidadGarantiaFiduciaria.MontoMitigador);
                        oComando.Parameters.AddWithValue("@pdPorcentaje_Responsabilidad", entidadGarantiaFiduciaria.PorcentajeResponsabilidad);
                        oComando.Parameters.AddWithValue("@piOperacion_Especial", entidadGarantiaFiduciaria.CodigoOperacionEspecial);
                        oComando.Parameters.AddWithValue("@piTipo_Acreedor", entidadGarantiaFiduciaria.CodigoTipoPersonaAcreedor);
                        oComando.Parameters.AddWithValue("@psCedula_Acreedor", entidadGarantiaFiduciaria.CedulaAcreedor);
                        oComando.Parameters.AddWithValue("@pdPorcentaje_Aceptacion", entidadGarantiaFiduciaria.PorcentajeAceptacion);
                        oComando.Parameters.AddWithValue("@psUsuario_Modifica", entidadGarantiaFiduciaria.UsuarioModifico);


                        string[] listaCampos = {clsGarantiaFiduciaria._codigoTipoMitigador, clsGarantiaFiduciaria._codigoTipoDocumentoLegal, clsGarantiaFiduciaria._montoMitigador,
                                                clsGarantiaFiduciaria._porcentajeResponsabilidad, clsGarantiaFiduciaria._codigoOperacionEspecial, clsGarantiaFiduciaria._codigoTipoPersonaAcreedor,
                                                clsGarantiaFiduciaria._cedulaAcreedor, clsGarantiaFiduciaria._porcentajeAceptacion, clsGarantiaFiduciaria._consecutivoOperacion, entidadGarantiaFiduciaria.ConsecutivoOperacion.ToString(),
                                                clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, entidadGarantiaFiduciaria.ConsecutivoGarantiaFiduciaria.ToString()};

                        dsGarantiaFiduciariaXOperacion = AccesoBD.ejecutarConsulta(string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7} FROM dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION WHERE {8} = {9} AND {10} = {11}", listaCampos));

                        //Abre la conexion
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        int nFilasAfectadas = oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }
                    #region Inserción en Bitácora

                    Bitacora oBitacora = new Bitacora();

                    TraductordeCodigos oTraductor = new TraductordeCodigos();

                    #region Garantía Fiduciaria por Operación

                    if ((dsGarantiaFiduciariaXOperacion != null) && (dsGarantiaFiduciariaXOperacion.Tables.Count > 0) && (dsGarantiaFiduciariaXOperacion.Tables[0].Rows.Count > 0))
                    {
                    string[] listaCampos = {clsGarantiaFiduciaria._entidadGarantiaFiduciariaXOperacion,
                                            clsGarantiaFiduciaria._codigoTipoMitigador, entidadGarantiaFiduciaria.CodigoTipoMitigador.ToString(),
                                            clsGarantiaFiduciaria._codigoTipoDocumentoLegal, entidadGarantiaFiduciaria.CodigoTipoDocumentoLegal.ToString(),
                                            clsGarantiaFiduciaria._montoMitigador, entidadGarantiaFiduciaria.MontoMitigador.ToString(),
                                            clsGarantiaFiduciaria._porcentajeResponsabilidad,  entidadGarantiaFiduciaria.PorcentajeResponsabilidad.ToString(),
                                            clsGarantiaFiduciaria._codigoOperacionEspecial, entidadGarantiaFiduciaria.CodigoOperacionEspecial.ToString(),
                                            clsGarantiaFiduciaria._codigoTipoPersonaAcreedor, entidadGarantiaFiduciaria.CodigoTipoPersonaAcreedor.ToString(),
                                            clsGarantiaFiduciaria._cedulaAcreedor, entidadGarantiaFiduciaria.CedulaAcreedor,
                                            clsGarantiaFiduciaria._porcentajeAceptacion, entidadGarantiaFiduciaria.PorcentajeAceptacion.ToString(),
                                            clsGarantiaFiduciaria._consecutivoOperacion, entidadGarantiaFiduciaria.ConsecutivoOperacion.ToString(),
                                            clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, entidadGarantiaFiduciaria.ConsecutivoGarantiaFiduciaria.ToString()};


                    string strModificarGarFiduXOperacion = string.Format("UPDATE dbo.{0} SET {1} = {2}, {3} = {4}, {5} = {6}, {7} = {8}, {9} = {10}, {11} = {12}, {13} = {14}, {15} = {16} WHERE {17} = {18} AND {19} = {20}", listaCampos);

                         //Campo deshabilitado en la interfaz
                        if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._codigoTipoMitigador))
                        {
                            int nTipoMitigadorObtenido = Convert.ToInt32(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][clsGarantiaFiduciaria._codigoTipoMitigador].ToString());

                            if (nTipoMitigadorObtenido != entidadGarantiaFiduciaria.CodigoTipoMitigador)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._codigoTipoMitigador,
                                   oTraductor.TraducirTipoMitigador(nTipoMitigadorObtenido),
                                   oTraductor.TraducirTipoMitigador(entidadGarantiaFiduciaria.CodigoTipoMitigador));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._codigoTipoMitigador,
                                   string.Empty,
                                   oTraductor.TraducirTipoMitigador(entidadGarantiaFiduciaria.CodigoTipoMitigador));
                        }

                        if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._codigoTipoDocumentoLegal))
                        {
                            int nTipoDocumentoObt = Convert.ToInt32(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][clsGarantiaFiduciaria._codigoTipoDocumentoLegal].ToString());

                            if (nTipoDocumentoObt != entidadGarantiaFiduciaria.CodigoTipoDocumentoLegal)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._codigoTipoDocumentoLegal,
                                   oTraductor.TraducirTipoDocumento(nTipoDocumentoObt),
                                   oTraductor.TraducirTipoDocumento(entidadGarantiaFiduciaria.CodigoTipoDocumentoLegal));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._codigoTipoDocumentoLegal,
                                   string.Empty,
                                   oTraductor.TraducirTipoDocumento(entidadGarantiaFiduciaria.CodigoTipoDocumentoLegal));
                        }

                        if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._montoMitigador))
                        {
                            decimal nMontoObtenido = Convert.ToDecimal(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][clsGarantiaFiduciaria._montoMitigador].ToString());

                            if (nMontoObtenido != entidadGarantiaFiduciaria.MontoMitigador)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._montoMitigador,
                                   nMontoObtenido.ToString("N2"),
                                   entidadGarantiaFiduciaria.MontoMitigador.ToString("N2"));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                  2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                  clsGarantiaFiduciaria._montoMitigador,
                                  string.Empty,
                                  entidadGarantiaFiduciaria.MontoMitigador.ToString("N2"));
                        }

                        if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._porcentajeResponsabilidad))
                        {
                            decimal nPorcentajeResponsabilidadObt = Convert.ToDecimal(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][clsGarantiaFiduciaria._porcentajeResponsabilidad].ToString());

                            if (nPorcentajeResponsabilidadObt != entidadGarantiaFiduciaria.PorcentajeResponsabilidad)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._porcentajeResponsabilidad,
                                   nPorcentajeResponsabilidadObt.ToString(),
                                   entidadGarantiaFiduciaria.PorcentajeResponsabilidad.ToString());
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._porcentajeResponsabilidad,
                                   string.Empty,
                                   entidadGarantiaFiduciaria.PorcentajeResponsabilidad.ToString());
                        }

                        if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._porcentajeAceptacion))
                        {
                            decimal porcentajeAceptacionObt = Convert.ToDecimal(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][clsGarantiaFiduciaria._porcentajeAceptacion].ToString());

                            if (porcentajeAceptacionObt != entidadGarantiaFiduciaria.PorcentajeAceptacion)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._porcentajeAceptacion,
                                   porcentajeAceptacionObt.ToString(),
                                   entidadGarantiaFiduciaria.PorcentajeAceptacion.ToString());
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._porcentajeAceptacion,
                                   string.Empty,
                                   entidadGarantiaFiduciaria.PorcentajeAceptacion.ToString());
                        }

                        if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._codigoOperacionEspecial))
                        {
                            int nOperacionEspecialObt = Convert.ToInt32(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][clsGarantiaFiduciaria._codigoOperacionEspecial].ToString());

                            if (nOperacionEspecialObt != entidadGarantiaFiduciaria.CodigoOperacionEspecial)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._codigoOperacionEspecial,
                                   oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecialObt),
                                   oTraductor.TraducirTipoOperacionEspecial(entidadGarantiaFiduciaria.CodigoOperacionEspecial));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._codigoOperacionEspecial,
                                   string.Empty,
                                   oTraductor.TraducirTipoOperacionEspecial(entidadGarantiaFiduciaria.CodigoOperacionEspecial));
                        }

                        if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._codigoTipoPersonaAcreedor))
                        {
                            int nTipoAcreedorObt = Convert.ToInt32(dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][clsGarantiaFiduciaria._codigoTipoPersonaAcreedor].ToString());

                            if (nTipoAcreedorObt != entidadGarantiaFiduciaria.CodigoTipoPersonaAcreedor)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._codigoTipoPersonaAcreedor,
                                   oTraductor.TraducirTipoPersona(nTipoAcreedorObt),
                                   oTraductor.TraducirTipoPersona(entidadGarantiaFiduciaria.CodigoTipoPersonaAcreedor));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._codigoTipoPersonaAcreedor,
                                    string.Empty,
                                   oTraductor.TraducirTipoPersona(entidadGarantiaFiduciaria.CodigoTipoPersonaAcreedor));
                        }

                        if (!dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._cedulaAcreedor))
                        {
                            string strCedulaAcreedorObt = dsGarantiaFiduciariaXOperacion.Tables[0].Rows[0][clsGarantiaFiduciaria._cedulaAcreedor].ToString();

                            if (strCedulaAcreedorObt.CompareTo(entidadGarantiaFiduciaria.CedulaAcreedor) != 0)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._cedulaAcreedor,
                                   strCedulaAcreedorObt,
                                   entidadGarantiaFiduciaria.CedulaAcreedor);
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarFiduXOperacion, string.Empty,
                                   clsGarantiaFiduciaria._cedulaAcreedor,
                                   string.Empty,
                                   entidadGarantiaFiduciaria.CedulaAcreedor);
                        }

                    }

                    #endregion

                    #region Garantía Fiduciaria

                    if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
                    {
                        string strModificarGarantiaFiduciaria = string.Format("UPDATE GAR_GARANTIA_FIDUCIARIA SET cod_tipo_fiador = {0} WHERE {1} = '{2}'", entidadGarantiaFiduciaria.CodigoTipoPersonaFiador.ToString(), clsGarantiaFiduciaria._cedulaFiador, entidadGarantiaFiduciaria.CedulaFiador);

                        if (!dsGarantiaFiduciaria.Tables[0].Rows[0].IsNull(clsGarantiaFiduciaria._codigoTipoPersonaFiador))
                        {
                            int nTipoFiadorObt = Convert.ToInt32(dsGarantiaFiduciaria.Tables[0].Rows[0][clsGarantiaFiduciaria._codigoTipoPersonaFiador].ToString());

                            if (nTipoFiadorObt != entidadGarantiaFiduciaria.CodigoTipoPersonaFiador)
                            {
                                oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarantiaFiduciaria, string.Empty,
                                   clsGarantiaFiduciaria._codigoTipoPersonaFiador,
                                   oTraductor.TraducirTipoPersona(nTipoFiadorObt),
                                   oTraductor.TraducirTipoPersona(entidadGarantiaFiduciaria.CodigoTipoPersonaFiador));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("GAR_GARANTIA_FIDUCIARIA", entidadGarantiaFiduciaria.UsuarioModifico, direccionIP, null,
                                   2, 1, entidadGarantiaFiduciaria.CedulaFiador, strOperacionCrediticia, strModificarGarantiaFiduciaria, string.Empty,
                                   clsGarantiaFiduciaria._codigoTipoPersonaFiador,
                                   string.Empty,
                                   oTraductor.TraducirTipoPersona(entidadGarantiaFiduciaria.CodigoTipoPersonaFiador));
                        }
                    }

                    #endregion

                    #endregion
            }
            catch (SqlException ex)
            {
                string errorBD = string.Format("Código del Error: {0}, Descripción del error: {1}", ex.ErrorCode.ToString(), ex.Message);
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA_DETALLE, identifiacionGarantia, errorBD, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                throw ex;
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA_DETALLE, identifiacionGarantia, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                throw ex;
            }
		}

        /// <summary>
        /// Método que permite eliminar una garantía fiduciaria
        /// </summary>
        /// <param name="nGarantiaFiduciaria">Consecutivo de la garantía fiduciaria que será eliminada</param>
        /// <param name="nOperacion">Consecutivo de la operación a la cual está relacaionada la garantía fiduciaria que será eliminada</param>
        /// <param name="strOperacionCrediticia">Número de operación, bajo el formato Contabilidad - Oficina - Moneda - Producto - Num Operación / Num. Contrato</param>
        /// <param name="direccionIP">Dirección IP de la máquina desde la cual se hace el ingreso de los datos</param>
        public void Eliminar(long nGarantiaFiduciaria, long nOperacion, string UsuarioModifico, string direccionIP, string strOperacionCrediticia)
		{
            DataSet dsData = new DataSet();
            int nFilasAfectadas = 0;

            try
			{
                string[] listaCampos = {clsGarantiaFiduciaria._cedulaAcreedor, clsGarantiaFiduciaria._indicadorEstadoRegistro, clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria,
                                        clsGarantiaFiduciaria._consecutivoOperacion, clsGarantiaFiduciaria._codigoOperacionEspecial, clsGarantiaFiduciaria._codigoTipoPersonaAcreedor,
                                        clsGarantiaFiduciaria._codigoTipoDocumentoLegal, clsGarantiaFiduciaria._codigoTipoMitigador, clsGarantiaFiduciaria._montoMitigador,
                                        clsGarantiaFiduciaria._porcentajeResponsabilidad, clsGarantiaFiduciaria._porcentajeAceptacion, clsGarantiaFiduciaria._consecutivoOperacion,  nOperacion.ToString(),
                                        clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, nGarantiaFiduciaria.ToString()};


                //Se obtiene los datos antes de ser borrados, para luego registrarlos en la bitácora
                string strConsultaGarFiduXOperacion = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10} FROM  dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION WHERE {11} = {12} AND {13} = {14}", listaCampos);

                DataSet dsGarantiaFiduciariaXOP = AccesoBD.ejecutarConsulta(strConsultaGarFiduXOperacion);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_EliminarGarantiaFiduciaria", oConexion))
                    {
                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        //Agrega los parametros
                        oComando.Parameters.AddWithValue("@nGarantiaFiduciaria", nGarantiaFiduciaria);
                        oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
                        oComando.Parameters.AddWithValue("@strUsuario", UsuarioModifico);
                        oComando.Parameters.AddWithValue("@strIP", direccionIP);

                        //Abre la conexion
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

						CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;

						string strEliminarGarFiduXOperacion = string.Format("DELETE dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION WHERE {0} = {1} AND {2} = {3}", clsGarantiaFiduciaria._consecutivoOperacion, nOperacion.ToString(), clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, nGarantiaFiduciaria.ToString());

						string CedulaFiador = "-";

						if (oGarantia.CedulaFiador != null)
						{
							CedulaFiador = oGarantia.CedulaFiador;
						}
						else
						{
							CedulaFiador = oTraductor.ObtenerCedulaFiadorGarFidu(nGarantiaFiduciaria.ToString());
						}

						if ((dsGarantiaFiduciariaXOP != null) && (dsGarantiaFiduciariaXOP.Tables.Count > 0) && (dsGarantiaFiduciariaXOP.Tables[0].Rows.Count > 0))
						{
							#region Garantía Fiduciaria por Operación

							foreach (DataRow drGarFiduXOP in dsGarantiaFiduciariaXOP.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drGarFiduXOP.Table.Columns.Count; nIndice++)
								{
									switch (drGarFiduXOP.Table.Columns[nIndice].ColumnName)
									{
										case clsGarantiaFiduciaria._indicadorEstadoRegistro:
											if (drGarFiduXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
													   3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
													   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
													   oTraductor.TraducirTipoEstado(Convert.ToInt32(drGarFiduXOP[nIndice, DataRowVersion.Current].ToString())),
													   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
													   3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
													   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
													   string.Empty,
													   string.Empty);
											}

											break;

										case clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria: oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
																									                           3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
																									                           drGarFiduXOP.Table.Columns[nIndice].ColumnName,
																									                           CedulaFiador,
																									                           string.Empty);
											break;

										case clsGarantiaFiduciaria._consecutivoOperacion: oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
																									                3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
																									                drGarFiduXOP.Table.Columns[nIndice].ColumnName,
																									                strOperacionCrediticia,
																									                string.Empty);
											break;

										case clsGarantiaFiduciaria._codigoOperacionEspecial:
											if (drGarFiduXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
													   3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
													   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
													   oTraductor.TraducirTipoOperacionEspecial(Convert.ToInt32(drGarFiduXOP[nIndice, DataRowVersion.Current].ToString())),
													   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
													   3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
													   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
													   string.Empty,
													   string.Empty);
											}

											break;

										case clsGarantiaFiduciaria._codigoTipoPersonaAcreedor:
											if (drGarFiduXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
														   3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
														   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
														   oTraductor.TraducirTipoPersona(Convert.ToInt32(drGarFiduXOP[nIndice, DataRowVersion.Current].ToString())),
														   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
														   3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
														   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
														   string.Empty,
														   string.Empty);
											}

											break;

										case clsGarantiaFiduciaria._codigoTipoDocumentoLegal:
											if (drGarFiduXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
															   3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
															   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
															   oTraductor.TraducirTipoDocumento(Convert.ToInt32(drGarFiduXOP[nIndice, DataRowVersion.Current].ToString())),
															   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
															   3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
															   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
															   string.Empty,
															   string.Empty);
											}
											break;

										case clsGarantiaFiduciaria._codigoTipoMitigador:
											if (drGarFiduXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
															   3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
															   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
															   oTraductor.TraducirTipoMitigador(Convert.ToInt32(drGarFiduXOP[nIndice, DataRowVersion.Current].ToString())),
															   string.Empty);
											}
											else
											{
												oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
															   3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
															   drGarFiduXOP.Table.Columns[nIndice].ColumnName,
															   string.Empty,
															   string.Empty);
											}

											break;

										default: oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
												  3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
												  drGarFiduXOP.Table.Columns[nIndice].ColumnName,
												  drGarFiduXOP[nIndice, DataRowVersion.Current].ToString(),
												  string.Empty);
											break;
									}


								}
							}

							#endregion
						}
						else
						{
							oBitacora.InsertarBitacora("GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION", UsuarioModifico, direccionIP, null,
									  3, 1, CedulaFiador, strOperacionCrediticia, strEliminarGarFiduXOperacion, string.Empty,
									  string.Empty,
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

        /// <summary>
        /// Método que obtiene el listado de las garantías fiduciarias asociadas a una operación o contrato
        /// </summary>
        /// <param name="tipoOperacion">Tipo de operación</param>
        /// <param name="consecutivoOperacion">Consecutivo de la operación</param>
        /// <param name="codigoContabilidad">Código de la contabilidad</param>
        /// <param name="codigoOficina">Código de la oficina</param>
        /// <param name="codigoMoneda">Código de la moneda</param>
        /// <param name="codigoProducto">Código del producto</param>
        /// <param name="numeroOperacion">Número de la operación o contrato</param>
        /// <param name="cedulaUsuario">Identificación del usuario que realiza la consulta</param>
        /// <returns>Lista de garantías relacionadas</returns>
        public DataSet ObtenerListaGarantias(int tipoOperacion, long consecutivoOperacion, int codigoContabilidad, int codigoOficina, int codigoMoneda, int codigoProducto, long numeroOperacion, string cedulaUsuario)
        {
            DataSet dsDatos = new DataSet();

            using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
            {
                SqlCommand oComando = null;

                switch (tipoOperacion)
                {
                    case ((int)Enumeradores.Tipos_Operaciones.Directa):
                        oComando = new SqlCommand("pa_ObtenerGarantiasFiduciariasOperaciones", oConexion);
                        break;
                    case ((int)Enumeradores.Tipos_Operaciones.Contrato):
                        oComando = new SqlCommand("pa_ObtenerGarantiasFiduciariasContratos", oConexion);
                        break;
                    default:
                        break;
                }

                //declara las propiedades del comando
                oComando.CommandType = CommandType.StoredProcedure;
                oComando.CommandTimeout = 120;
                oComando.Parameters.AddWithValue("@piConsecutivo_Operacion", consecutivoOperacion);
                oComando.Parameters.AddWithValue("@piCodigo_Contabilidad", codigoContabilidad);
                oComando.Parameters.AddWithValue("@piCodigo_Oficina", codigoOficina);
                oComando.Parameters.AddWithValue("@piCodigo_Moneda", codigoMoneda);

                if (tipoOperacion == ((int)Enumeradores.Tipos_Operaciones.Directa))
                {
                    oComando.Parameters.AddWithValue("@piCodigo_Producto", codigoProducto);
                    oComando.Parameters.AddWithValue("@pdNumero_Operacion", numeroOperacion);
                }
                else
                {
                    oComando.Parameters.AddWithValue("@pdNumero_Contrato", numeroOperacion);
                }

                oComando.Parameters.AddWithValue("@psCedula_Usuario", cedulaUsuario);

                using (SqlDataAdapter oDataAdapter = new SqlDataAdapter(oComando))
                {
                    //Abre la conexion
                    oComando.Connection.Open();

                    oDataAdapter.Fill(dsDatos, "Datos");

                    oComando.Connection.Close();
                    oComando.Connection.Dispose();
                }

                return dsDatos;
            }
        }

        /// <summary>
        /// Verifica si la garantía fiduciaria existe
        /// </summary>
        /// <param name="codigoContabilidad">Código de la contabilidad</param>
        /// <param name="codigoOficina">Código de la oficina</param>
        /// <param name="codigoMoneda">Código de la moneda</param>
        /// <param name="codigoProducto">Código del producto</param>
        /// <param name="numeroOperacion">Número de la operación o contrato</param>
        /// <param name="tipoOperacion">Tipo de operación</param>
        /// <param name="cedulaFiador">Cédula del fiador</param>
        /// <param name="tipoPersonaFiador">Tipo de persona del fiador</param>
        /// <returns>True: La garantía existe. False: La garantía no existe</returns>
        public bool ExisteGarantia(string codigoContabilidad, string codigoOficina, string codigoMoneda, string codigoProducto, string numeroOperacion, int tipoOperacion, string cedulaFiador, string tipoPersonaFiador)
        {
            bool existeGarantia = false;
            string[] listaCampos = new string[] { string.Empty };
            string sentenciaSql = string.Empty;
            int valorRetornado;

            try
            {
                if (tipoOperacion == ((int)Enumeradores.Tipos_Operaciones.Directa))
                {
                    listaCampos = new string[] {clsOperacionCrediticia._entidadOperacion,
                                                clsGarantiaFiduciaria._entidadGarantiaFiduciariaXOperacion,
                                                clsGarantiaFiduciaria._consecutivoOperacion, clsOperacionCrediticia._consecutivoOperacion,
                                                clsGarantiaFiduciaria._entidadGarantiaFiduciaria,
                                                clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria,
                                                clsOperacionCrediticia._codigoContabilidad, codigoContabilidad,
                                                clsOperacionCrediticia._codigoOficina, codigoOficina,
                                                clsOperacionCrediticia._codigoMoneda, codigoMoneda,
                                                clsOperacionCrediticia._codigoProducto, codigoProducto,
                                                clsOperacionCrediticia._numeroDeOperacion, numeroOperacion,
                                                clsOperacionCrediticia._numeroContrato, "0",
                                                clsGarantiaFiduciaria._cedulaFiador, cedulaFiador,
                                                clsGarantiaFiduciaria._codigoTipoPersonaFiador, tipoPersonaFiador};

                    sentenciaSql = string.Format("SELECT 1 FROM dbo.{0} GO1 INNER JOIN dbo.{1} GFO ON GFO.{2} = GO1.{3} INNER JOIN dbo.{4} GGF ON GGF.{5} = GFO.{6} WHERE GO1.{7} = {8} AND GO1.{9} = {10} AND GO1.{11} = {12} AND GO1.{13} = {14} AND GO1.{15} = {16}  AND GO1.{17} = {18} AND GGF.{19} = '{20}' AND GGF.{21} = {22}", listaCampos);
                }
                else if (tipoOperacion == ((int)Enumeradores.Tipos_Operaciones.Contrato))
                {
                    listaCampos = new string[] {clsOperacionCrediticia._entidadOperacion,
                                                clsGarantiaFiduciaria._entidadGarantiaFiduciariaXOperacion,
                                                clsGarantiaFiduciaria._consecutivoOperacion, clsOperacionCrediticia._consecutivoOperacion,
                                                clsGarantiaFiduciaria._entidadGarantiaFiduciaria,
                                                clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria, clsGarantiaFiduciaria._consecutivoGarantiaFiduciaria,
                                                clsOperacionCrediticia._codigoContabilidad, codigoContabilidad,
                                                clsOperacionCrediticia._codigoOficina, codigoOficina,
                                                clsOperacionCrediticia._codigoMoneda, codigoMoneda,
                                                clsOperacionCrediticia._codigoProducto, codigoProducto,
                                                clsOperacionCrediticia._numeroDeOperacion, "IS NULL",
                                                clsOperacionCrediticia._numeroContrato, numeroOperacion,
                                                clsGarantiaFiduciaria._cedulaFiador, cedulaFiador,
                                                clsGarantiaFiduciaria._codigoTipoPersonaFiador, tipoPersonaFiador};

                    sentenciaSql = string.Format("SELECT 1 FROM dbo.{0} GO1 INNER JOIN dbo.{1} GFO ON GFO.{2} = GO1.{3} INNER JOIN dbo.{4} GGF ON GGF.{5} = GFO.{6} WHERE GO1.{7} = {8} AND GO1.{9} = {10} AND GO1.{11} = {12} AND GO1.{13} = {14} AND GO1.{15} = {16}  AND GO1.{17} = {18} AND GGF.{19} = '{20}' AND GGF.{21} = {22}", listaCampos);
                }

                SqlParameter[] parameters = new SqlParameter[] { };

                object resultadoObtenido = AccesoBD.ExecuteScalar(CommandType.Text, sentenciaSql, parameters);
                existeGarantia = (((resultadoObtenido != null) && (int.TryParse(resultadoObtenido.ToString(), out valorRetornado))) ? ((valorRetornado != 0) ? true : false) : false);
            }
            catch
            {
                throw;
            }

            return existeGarantia;
        }
        #endregion
    }
}
