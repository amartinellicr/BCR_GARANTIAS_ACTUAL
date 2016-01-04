using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;
using BCRGARANTIAS.Datos;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Garantias_Fiduciarias_Tarjetas.
	/// </summary>
	public class Garantias_Fiduciarias_Tarjetas
	{
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        int nMensaje = -1;

        #endregion Variables Globales

        #region Metodos Publicos

        public int Crear(string strTarjeta, int nTipoGarantia, int nClaseGarantia, string strCedulaFiador,
						int nTipoFiador, string strNombreFiador, int nTipoMitigador, int nTipoDocumento, 
						decimal nMontoMitigador, decimal nPorcentajeResponsabilidad, int nOperacionEspecial,
						int nTipoAcreedor, string strCedulaAcreedor, DateTime dFechaExpiracion, decimal nMontoCobertura, 
						string strCedulaDeudor, long nBIN, long nCodigoInterno, int nMoneda, int nOficinaRegistra,
                        string strUsuario, string strIP,
                        string strOperacionCrediticia,
                        string strObservacion, int nCodigoCatalogo, decimal porcentajeAceptacion)
		{
            string identifiacionGarantia = string.Format("Fiduciaria: {0} - {1}, relacionada a la tarjeta: {2}", strCedulaFiador, strNombreFiador, strOperacionCrediticia);
            DataSet dsData = new DataSet();
            DataSet dsTarjeta = new DataSet();
            DataSet dsGarantiaFiduciaria = new DataSet();

            try
            {
                //Obtener la información sobre la Tarjeta y sobre la Garantía Fiduciaria, esto por si se deben insertar
                listaCampos = new string[] { clsTarjeta._consecutivoTarjeta, clsTarjeta._codigoTipoGarantia,
                                             clsTarjeta._entidadTarjeta,
                                             clsTarjeta._numeroTarjeta, strTarjeta};

                sentenciaSql = string.Format("SELECT {0}, {1} FROM dbo.{2} WHERE {3} = '{4}'", listaCampos);

                dsTarjeta = AccesoBD.ejecutarConsulta(sentenciaSql);

                listaCampos = new string[] { clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria,
                                             clsGarantiaFiduciariaTarjeta._entidadGarantiaFiduciariaTarjeta,
                                             clsGarantiaFiduciariaTarjeta._cedulaFiador, strCedulaFiador};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = '{3}'", listaCampos);
                dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta(sentenciaSql);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_InsertarGarantiaFiduciariaTarjeta", oConexion))
                    {
                        SqlParameter oParam = new SqlParameter();

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        //Agrega los parametros
                        oComando.Parameters.AddWithValue("@piTipo_Garantia", nTipoGarantia);
                        oComando.Parameters.AddWithValue("@piClase_Garantia", nClaseGarantia);
                        oComando.Parameters.AddWithValue("@psCedula_Fiador", strCedulaFiador);
                        oComando.Parameters.AddWithValue("@psNombre_Fiador", strNombreFiador);
                        oComando.Parameters.AddWithValue("@piTipo_Fiador", nTipoFiador);
                        oComando.Parameters.AddWithValue("@psTarjeta", strTarjeta);
                        oComando.Parameters.AddWithValue("@piTipo_Mitigador", nTipoMitigador);
                        oComando.Parameters.AddWithValue("@piTipo_Documento_Legal", nTipoDocumento);
                        oComando.Parameters.AddWithValue("@pdMonto_Mitigador", nMontoMitigador);
                        oComando.Parameters.AddWithValue("@pdPorcentaje_Responsabilidad", nPorcentajeResponsabilidad);
                        oComando.Parameters.AddWithValue("@piOperacion_Especial", nOperacionEspecial);
                        oComando.Parameters.AddWithValue("@piTipo_Acreedor", nTipoAcreedor);
                        oComando.Parameters.AddWithValue("@psCedula_Acreedor", strCedulaAcreedor);
                        oComando.Parameters.AddWithValue("@pdtFecha_Expiracion", dFechaExpiracion);
                        oComando.Parameters.AddWithValue("@pmMonto_Cobertura", nMontoCobertura);
                        oComando.Parameters.AddWithValue("@psCedula_Deudor", strCedulaDeudor);
                        oComando.Parameters.AddWithValue("@piBIN", nBIN);
                        oComando.Parameters.AddWithValue("@piCodigo_Interno_SISTAR", nCodigoInterno);
                        oComando.Parameters.AddWithValue("@piMoneda", nMoneda);
                        oComando.Parameters.AddWithValue("@piOficina_Registra", nOficinaRegistra);
                        oComando.Parameters.AddWithValue("@psObservacion", strObservacion);
                        oComando.Parameters.AddWithValue("@pdPorcentaje_Aceptacion", porcentajeAceptacion);
                        oComando.Parameters.AddWithValue("@piCodigo_Catalogo", nCodigoCatalogo);

                        //Abre la conexion
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        nMensaje = Convert.ToInt32(oComando.ExecuteScalar().ToString());

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }

                if (nMensaje == 0)
                {
                    #region Inserción en Bitácora

                    Bitacora oBitacora = new Bitacora();

                    TraductordeCodigos oTraductor = new TraductordeCodigos();

                    if ((dsTarjeta == null) || (dsTarjeta.Tables.Count == 0) || (dsTarjeta.Tables[0].Rows.Count == 0))
                    {
                        #region Tarjeta

                        string[] listaCampos = { strTarjeta, strCedulaDeudor, nBIN.ToString(), nCodigoInterno.ToString(), nMoneda.ToString(), nOficinaRegistra.ToString(), "1", "N" };

                        string strInsertaTarjeta = string.Format("INSERT INTO TAR_TARJETA (num_tarjeta, cedula_deudor, cod_bin, cod_interno_sistar, cod_moneda, cod_oficina_registra, cod_tipo_garantia, cod_estado_tarjeta) VALUES({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7})", listaCampos);

                        oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
                           1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
                           clsTarjeta._numeroTarjeta,
                           string.Empty,
                           strTarjeta);

                        oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
                           clsTarjeta._codigoBin,
                            string.Empty,
                            nBIN.ToString());

                        oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
                            clsTarjeta._codigoInternoSistar,
                            string.Empty,
                            nCodigoInterno.ToString());

                        oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
                            clsTarjeta._codigoMoneda,
                            string.Empty,
                            oTraductor.TraducirTipoMoneda(nMoneda));

                        oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
                            clsTarjeta._codigoOficinaRegistra,
                            string.Empty,
                            nOficinaRegistra.ToString());

                        oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
                            clsTarjeta._cedulaDeudor,
                            string.Empty,
                            strCedulaDeudor);

                        oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
                            clsTarjeta._codigoTipoGarantia,
                            string.Empty,
                            "1");

                        oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaTarjeta, string.Empty,
                            clsTarjeta._indicadorEstadoTarjeta,
                            string.Empty,
                            "N");

                        listaCampos = new string[] { clsTarjeta._consecutivoTarjeta, clsTarjeta._codigoTipoGarantia,
                                                         clsTarjeta._entidadTarjeta,
                                                         clsTarjeta._numeroTarjeta, strTarjeta};

                        sentenciaSql = string.Format("SELECT {0}, {1} FROM dbo.{2} WHERE {3} = '{4}'", listaCampos);
                        dsTarjeta = AccesoBD.ejecutarConsulta(sentenciaSql);

                        #endregion
                    }
                    else if ((dsTarjeta != null) || (dsTarjeta.Tables.Count > 0) || (dsTarjeta.Tables[0].Rows.Count > 0))
                    {
                        /*La tarjeta ya existe*/
                        #region Actualiza tipo de garantía y elimina la garantía por perfil

                        if (!dsTarjeta.Tables[0].Rows[0].IsNull(clsTarjeta._codigoTipoGarantia))
                        {
                            int nTipogarantiaObtenida = Convert.ToInt32(dsTarjeta.Tables[0].Rows[0][clsTarjeta._codigoTipoGarantia].ToString());

                            string strDescripcion = oTraductor.TraducirCodigoTipoGarantiaTarjeta(nTipogarantiaObtenida.ToString());

                            /*Se evalúa si la garantía es por perfil*/
                            if ((nTipogarantiaObtenida != 1) && (strDescripcion.CompareTo("-") != 0))
                            {
                                string codigoTarjeta = dsTarjeta.Tables[0].Rows[0][clsTarjeta._consecutivoTarjeta].ToString();

                                #region Actualiza Tipo de garantía de la tarjeta

                                listaCampos = new string[] { clsTarjeta._entidadTarjeta,
                                                                 clsTarjeta._codigoTipoGarantia,
                                                                 clsTarjeta._consecutivoTarjeta, codigoTarjeta};

                                string strActualizacionTipoGarantia = string.Format("UPDATE {0} SET {1} = 1 WHERE {2} = {3}", listaCampos);

                                oBitacora.InsertarBitacora("TAR_TARJETA", strUsuario, strIP, null,
                                2, nTipoGarantia, strCedulaFiador, strTarjeta, strActualizacionTipoGarantia, string.Empty,
                                clsTarjeta._codigoTipoGarantia,
                                nTipogarantiaObtenida.ToString(),
                                "1");

                                #endregion

                                #region Elimina garantía por perfil

                                listaCampos = new string[] { clsGarantiasXPerfil._entidadGarantiaPerfilXTarjeta,
                                                                 clsGarantiasXPerfil._consecutivoTarjeta, codigoTarjeta};

                                string streliminarGarantiaXPerfil = string.Format("DELETE FROM {0}  WHERE {1} = {2}", listaCampos);

                                /*Se obtiene la garantía por perfil antes de eliminarla*/
                                listaCampos = new string[] { clsGarantiasXPerfil._observacion,
                                                                 clsGarantiasXPerfil._entidadGarantiaPerfilXTarjeta,
                                                                 clsGarantiasXPerfil._consecutivoTarjeta, codigoTarjeta};

                                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                                DataSet dsGarantiaXPerfil = AccesoBD.ejecutarConsulta(sentenciaSql);

                                if ((dsGarantiaXPerfil != null) && (dsGarantiaXPerfil.Tables.Count > 0) && (dsGarantiaXPerfil.Tables[0].Rows.Count > 0))
                                {
                                    if (!dsGarantiaXPerfil.Tables[0].Rows[0].IsNull(clsGarantiasXPerfil._observacion))
                                    {
                                        string strObservacionesObt = dsGarantiaXPerfil.Tables[0].Rows[0][clsGarantiasXPerfil._observacion].ToString();

                                        if (strObservacionesObt != string.Empty)
                                        {
                                            oBitacora.InsertarBitacora("TAR_GARANTIAS_X_PERFIL_X_TARJETA", strUsuario, strIP, null,
                                            3, 4, string.Empty, strTarjeta, streliminarGarantiaXPerfil, string.Empty,
                                            clsGarantiasXPerfil._observacion,
                                            strObservacionesObt,
                                            string.Empty);
                                        }
                                    }
                                }
                                #endregion
                            }
                        }
                        #endregion
                    }

                    if ((dsGarantiaFiduciaria == null) || (dsGarantiaFiduciaria.Tables.Count == 0) || (dsGarantiaFiduciaria.Tables[0].Rows.Count == 0))
                    {
                        #region Garantía Fiduciaria

                        listaCampos = new string[] { clsGarantiaFiduciariaTarjeta._entidadGarantiaFiduciariaTarjeta,
                                                         clsGarantiaFiduciariaTarjeta._codigoTipoGarantia, clsGarantiaFiduciariaTarjeta._codigoClaseGarantia, clsGarantiaFiduciariaTarjeta._cedulaFiador, clsGarantiaFiduciariaTarjeta._nombreFiador, clsGarantiaFiduciariaTarjeta._codigoTipoPersonaFiador,
                                                         nTipoGarantia.ToString(), nClaseGarantia.ToString(), strCedulaFiador, strNombreFiador, nTipoFiador.ToString()};

                        string strInsertaGarFiduTarjeta = string.Format("INSERT INTO {0} ({1}, {2}, {3}, {4}, {5}) VALUES({6}, {7}, {8}, {9}, {10}", listaCampos);

                        oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._cedulaFiador,
                            string.Empty,
                            strCedulaFiador);

                        oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._codigoClaseGarantia,
                            string.Empty,
                            oTraductor.TraducirClaseGarantia(nClaseGarantia));

                        oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._codigoTipoPersonaFiador,
                            string.Empty,
                            oTraductor.TraducirTipoPersona(nTipoFiador));

                        oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._codigoTipoGarantia,
                            string.Empty,
                            oTraductor.TraducirTipoGarantia(nTipoGarantia));

                        oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._nombreFiador,
                            string.Empty,
                            strNombreFiador);

                        listaCampos = new string[] { clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria,
                                                         clsGarantiaFiduciariaTarjeta._entidadGarantiaFiduciariaTarjeta,
                                                         clsGarantiaFiduciariaTarjeta._cedulaFiador, strCedulaFiador};

                        sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = '{3}'", listaCampos);

                        dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta(sentenciaSql);

                        #endregion
                    }

                    if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
                    {
                        #region Garantía Fiduciciaria por Tarjeta

                        string strCodigoGarFidu = dsGarantiaFiduciaria.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria].ToString();
                        string strCodigoTarjeta = dsTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._consecutivoTarjeta].ToString();

                        long nGarantiaFiduciaria = (long)Convert.ToInt32(strCodigoGarFidu);

                        listaCampos = new string[] { clsGarantiaFiduciariaTarjeta._entidadGarantiaFiduciariaXTarjeta,
                                                         clsGarantiaFiduciariaTarjeta._consecutivoTarjeta, clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria,
                                                         clsGarantiaFiduciariaTarjeta._codigoTipoMitigador, clsGarantiaFiduciariaTarjeta._codigoTipoDocumentoLegal,
                                                         clsGarantiaFiduciariaTarjeta._montoMitigador, clsGarantiaFiduciariaTarjeta._porcentajeResponsabilidad,
                                                         clsGarantiaFiduciariaTarjeta._codigoOperacionEspecial, clsGarantiaFiduciariaTarjeta._codigoTipoPersonaAcreedor,
                                                         clsGarantiaFiduciariaTarjeta._cedulaAcreedor, clsGarantiaFiduciariaTarjeta._fechaExpiracion,
                                                         clsGarantiaFiduciariaTarjeta._montoCobertura, clsGarantiaFiduciariaTarjeta._observacion,
                                                         clsGarantiaFiduciariaTarjeta._porcentajeAceptacion,
                                                         strTarjeta, strCodigoGarFidu, nTipoMitigador.ToString(), nTipoDocumento.ToString(),
                                                         nMontoMitigador.ToString(), nPorcentajeResponsabilidad.ToString(), nOperacionEspecial.ToString(),
                                                         nTipoAcreedor.ToString(), strCedulaAcreedor, dFechaExpiracion.ToShortDateString(), nMontoCobertura.ToString(),
                                                         strObservacion, porcentajeAceptacion.ToString() };

                        string strInsertaGarFiduXTarjeta = string.Format("INSERT INTO {0} ({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}) VALUES({14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24}, {25}, {26})", listaCampos);

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._cedulaAcreedor,
                            string.Empty,
                            strCedulaAcreedor);

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria,
                            string.Empty,
                            strCedulaFiador);

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._consecutivoTarjeta,
                            string.Empty,
                            strTarjeta);

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._codigoOperacionEspecial,
                            string.Empty,
                            oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._codigoTipoPersonaAcreedor,
                            string.Empty,
                            oTraductor.TraducirTipoPersona(nTipoAcreedor));

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._codigoTipoDocumentoLegal,
                            string.Empty,
                            oTraductor.TraducirTipoDocumento(nTipoDocumento));

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._codigoTipoMitigador,
                            string.Empty,
                            oTraductor.TraducirTipoMitigador(nTipoMitigador));

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._montoMitigador,
                            string.Empty,
                            nMontoMitigador.ToString("N2"));

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._porcentajeResponsabilidad,
                            string.Empty,
                            nPorcentajeResponsabilidad.ToString());

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._fechaExpiracion,
                            string.Empty,
                            dFechaExpiracion.ToShortDateString());

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                           1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                           clsGarantiaFiduciariaTarjeta._montoCobertura,
                           string.Empty,
                           nMontoCobertura.ToString("N2"));

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                           1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                           clsGarantiaFiduciariaTarjeta._observacion, string.Empty,
                           strObservacion);

                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            1, nTipoGarantia, strCedulaFiador, strTarjeta, strInsertaGarFiduXTarjeta, string.Empty,
                            clsGarantiaFiduciariaTarjeta._porcentajeAceptacion,
                            string.Empty,
                            porcentajeAceptacion.ToString());

                        #endregion
                    }

                    #endregion
                }

                return nMensaje;
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

		public void Modificar(long nGarantiaFiduciaria, long nTarjeta, string strCedulaFiador, int nTipoFiador, 
							string strNombreFiador, int nTipoMitigador, int nTipoDocumento, decimal nMontoMitigador, 
							decimal nPorcentajeResponsabilidad, int nOperacionEspecial, int nTipoAcreedor, 
							string strCedulaAcreedor, DateTime dFechaExpiracion, decimal nMontoCobertura,
                            string strUsuario, string strIP,
                            string strOperacionCrediticia,
                            string strObservacion, decimal porcentajeAceptacion)
		{
            string identifiacionGarantia = string.Format("Fiduciaria: {0} - {1}, relacionada a la tarjeta: {2}", strCedulaFiador, strNombreFiador, strOperacionCrediticia);
            DataSet dsGarantiaFiduciariaXTarjeta = new DataSet();
            DataSet dsData = new DataSet();
            DataSet dsGarantiaFiduciaria = new DataSet();
            int nFilasAfectadas = 0;

            try
            {
                #region Obtener los datos de la BD antes de que cambien

                listaCampos = new string[] { clsGarantiaFiduciariaTarjeta._codigoTipoPersonaFiador,
                                             clsGarantiaFiduciariaTarjeta._entidadGarantiaFiduciariaTarjeta,
                                             clsGarantiaFiduciariaTarjeta._cedulaFiador, strCedulaFiador};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = '{3}'", listaCampos);

                dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta(sentenciaSql);

                if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
                {

                    listaCampos = new string[] { clsGarantiaFiduciariaTarjeta._codigoTipoMitigador, clsGarantiaFiduciariaTarjeta._codigoTipoDocumentoLegal,
                                                 clsGarantiaFiduciariaTarjeta._montoMitigador, clsGarantiaFiduciariaTarjeta._porcentajeResponsabilidad,
                                                 clsGarantiaFiduciariaTarjeta._codigoOperacionEspecial, clsGarantiaFiduciariaTarjeta._codigoTipoPersonaAcreedor,
                                                 clsGarantiaFiduciariaTarjeta._cedulaAcreedor, clsGarantiaFiduciariaTarjeta._fechaExpiracion,
                                                 clsGarantiaFiduciariaTarjeta._montoCobertura, clsGarantiaFiduciariaTarjeta._observacion,
                                                 clsGarantiaFiduciariaTarjeta._porcentajeAceptacion,
                                                 clsGarantiaFiduciariaTarjeta._entidadGarantiaFiduciariaXTarjeta,
                                                 clsGarantiaFiduciariaTarjeta._consecutivoTarjeta, nTarjeta.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria,  nGarantiaFiduciaria.ToString()};

                    sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10} FROM dbo.{11} WHERE {12} = {13} AND {14} = {15}", listaCampos);

                    dsGarantiaFiduciariaXTarjeta = AccesoBD.ejecutarConsulta(sentenciaSql);
                }

                //Se obtiene el número de tarjeta
                listaCampos = new string[] { clsTarjeta._numeroTarjeta,
                                             clsTarjeta._entidadTarjeta,
                                             clsTarjeta._consecutivoTarjeta, nTarjeta.ToString()};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                DataSet dsTarjeta = AccesoBD.ejecutarConsulta(sentenciaSql);

                string strNumeroTarjeta = "-";

                if ((dsTarjeta != null) && (dsTarjeta.Tables.Count > 0) && (dsTarjeta.Tables[0].Rows.Count > 0))
                {
                    if (!dsTarjeta.Tables[0].Rows[0].IsNull(clsTarjeta._numeroTarjeta))
                    {
                        strNumeroTarjeta = dsTarjeta.Tables[0].Rows[0][clsTarjeta._numeroTarjeta].ToString();
                    }
                }

                #endregion

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_ModificarGarantiaFiduciariaTarjeta", oConexion))
                    {
                        SqlParameter oParam = new SqlParameter();

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        //Agrega los parametros
                        oComando.Parameters.AddWithValue("@piConsecutivo_Garantia_Fiduciaria", nGarantiaFiduciaria);
                        oComando.Parameters.AddWithValue("@piTarjeta", nTarjeta);
                        oComando.Parameters.AddWithValue("@psCedula_Fiador", strCedulaFiador);
                        oComando.Parameters.AddWithValue("@piTipo_Fiador", nTipoFiador);
                        oComando.Parameters.AddWithValue("@piTipo_Mitigador", nTipoMitigador);
                        oComando.Parameters.AddWithValue("@piTipo_Documento_Legal", nTipoDocumento);
                        oComando.Parameters.AddWithValue("@pdMonto_Mitigador", nMontoMitigador);
                        oComando.Parameters.AddWithValue("@pdPorcentaje_Responsabilidad", nPorcentajeResponsabilidad);
                        oComando.Parameters.AddWithValue("@piOperacion_Especial", nOperacionEspecial);
                        oComando.Parameters.AddWithValue("@piTipo_Acreedor", nTipoAcreedor);
                        oComando.Parameters.AddWithValue("@psCedula_Acreedor", strCedulaAcreedor);
                        oComando.Parameters.AddWithValue("@pdtFecha_Expiracion", dFechaExpiracion);
                        oComando.Parameters.AddWithValue("@pmMonto_Cobertura", nMontoCobertura);
                        oComando.Parameters.AddWithValue("@psObservacion", strObservacion);
                        oComando.Parameters.AddWithValue("@pdPorcentaje_Aceptacion", porcentajeAceptacion);

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

                    if ((dsGarantiaFiduciariaXTarjeta != null) && (dsGarantiaFiduciariaXTarjeta.Tables.Count > 0) && (dsGarantiaFiduciariaXTarjeta.Tables[0].Rows.Count > 0))
                    {
                        #region Garantía Fiduciaria por Tarjeta

                        string[] listaCampos = { clsGarantiaFiduciariaTarjeta._entidadGarantiaFiduciariaXTarjeta,
                                                 clsGarantiaFiduciariaTarjeta._codigoTipoMitigador, nTipoMitigador.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._codigoTipoDocumentoLegal, nTipoDocumento.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._montoMitigador, nMontoMitigador.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._porcentajeResponsabilidad, nPorcentajeResponsabilidad.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._codigoOperacionEspecial, nOperacionEspecial.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._codigoTipoPersonaAcreedor, nTipoAcreedor.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._cedulaAcreedor, strCedulaAcreedor,
                                                 clsGarantiaFiduciariaTarjeta._fechaExpiracion, dFechaExpiracion.ToShortDateString(),
                                                 clsGarantiaFiduciariaTarjeta._montoCobertura, nMontoCobertura.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._porcentajeAceptacion, porcentajeAceptacion.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._consecutivoTarjeta, nTarjeta.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria, nGarantiaFiduciaria.ToString()};

                        string strModificaGarFiduXTarjeta = string.Format("UPDATE {0} SET {1} = {2}, {3} = {4}, {5} = {6}, {7} = {8}, {9} = {10}, {11} = {12}, {13} = {14}, {15} = {16}, {17} = {18}, {19} = {20} WHERE {21} = {22} AND {23} = {24}", listaCampos);

                        if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._codigoTipoMitigador))
                        {
                            int nTipoMitigadorObt = Convert.ToInt32(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._codigoTipoMitigador].ToString());

                            if (nTipoMitigadorObt != nTipoMitigador)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._codigoTipoMitigador,
                                   oTraductor.TraducirTipoMitigador(nTipoMitigadorObt),
                                   oTraductor.TraducirTipoMitigador(nTipoMitigador));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._codigoTipoMitigador,
                                   string.Empty,
                                   oTraductor.TraducirTipoMitigador(nTipoMitigador));
                        }

                        if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._codigoTipoDocumentoLegal))
                        {
                            int nTipoDocumentoLegalObt = Convert.ToInt32(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._codigoTipoDocumentoLegal].ToString());

                            if (nTipoDocumentoLegalObt != nTipoDocumento)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._codigoTipoDocumentoLegal,
                                   oTraductor.TraducirTipoDocumento(nTipoDocumentoLegalObt),
                                   oTraductor.TraducirTipoDocumento(nTipoDocumento));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._codigoTipoDocumentoLegal,
                                   string.Empty,
                                   oTraductor.TraducirTipoDocumento(nTipoDocumento));
                        }

                        if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._montoMitigador))
                        {
                            decimal nMontoMitigadorObt = Convert.ToDecimal(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._montoMitigador].ToString());

                            if (nMontoMitigadorObt != nMontoMitigador)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._montoMitigador,
                                   nMontoMitigadorObt.ToString("N2"),
                                   nMontoMitigador.ToString("N2"));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._montoMitigador,
                                   string.Empty,
                                   nMontoMitigador.ToString("N2"));
                        }

                        if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._porcentajeResponsabilidad))
                        {
                            decimal nPorcentajeResponsabilidadObt = Convert.ToDecimal(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._porcentajeResponsabilidad].ToString());

                            if (nPorcentajeResponsabilidadObt != nPorcentajeResponsabilidad)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._porcentajeResponsabilidad,
                                   nPorcentajeResponsabilidadObt.ToString(),
                                   nPorcentajeResponsabilidad.ToString());
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._porcentajeResponsabilidad,
                                   string.Empty,
                                   nPorcentajeResponsabilidad.ToString());
                        }

                        if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._porcentajeAceptacion))
                        {
                            decimal porcentajeAceptacionObt = Convert.ToDecimal(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._porcentajeAceptacion].ToString());

                            if (porcentajeAceptacionObt != porcentajeAceptacion)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                    clsGarantiaFiduciariaTarjeta._porcentajeAceptacion,
                                   porcentajeAceptacionObt.ToString(),
                                   porcentajeAceptacion.ToString());
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._porcentajeAceptacion,
                                   string.Empty,
                                   nPorcentajeResponsabilidad.ToString());
                        }

                        
                        if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._codigoOperacionEspecial))
                        {
                            int nOperacionEspecialObt = Convert.ToInt32(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._codigoOperacionEspecial].ToString());

                            if (nOperacionEspecialObt != nOperacionEspecial)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._codigoOperacionEspecial,
                                   oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecialObt),
                                   oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._codigoOperacionEspecial,
                                   string.Empty,
                                   oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));
                        }

                        if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._codigoTipoPersonaAcreedor))
                        {
                            int nTipoAcreedorObt = Convert.ToInt32(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._codigoTipoPersonaAcreedor].ToString());

                            if (nTipoAcreedorObt != nTipoAcreedor)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._codigoTipoPersonaAcreedor,
                                   oTraductor.TraducirTipoPersona(nTipoAcreedorObt),
                                   oTraductor.TraducirTipoPersona(nTipoAcreedor));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._codigoTipoPersonaAcreedor,
                                   string.Empty,
                                   oTraductor.TraducirTipoPersona(nTipoAcreedor));
                        }

                        if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._cedulaAcreedor))
                        {
                            string strCedulaAcreedorObt = dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._cedulaAcreedor].ToString();

                            if (strCedulaAcreedorObt.CompareTo(strCedulaAcreedor) != 0)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._cedulaAcreedor,
                                   strCedulaAcreedorObt,
                                   strCedulaAcreedor);
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._cedulaAcreedor,
                                   string.Empty,
                                   strCedulaAcreedor);
                        }

                        if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._fechaExpiracion))
                        {
                            DateTime dFechaExperiracionObtenida = Convert.ToDateTime(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._fechaExpiracion].ToString());

                            if (dFechaExperiracionObtenida != dFechaExpiracion)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._fechaExpiracion,
                                   dFechaExperiracionObtenida.ToShortDateString(),
                                   dFechaExpiracion.ToShortDateString());

                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._fechaExpiracion,
                                   string.Empty,
                                   dFechaExpiracion.ToShortDateString());
                        }

                        if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._montoCobertura))
                        {
                            decimal nMontoCoberturaObtenido = Convert.ToDecimal(dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._montoCobertura].ToString());

                            if (nMontoCoberturaObtenido != nMontoCobertura)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._montoCobertura,
                                   nMontoCoberturaObtenido.ToString(),
                                   nMontoCobertura.ToString());

                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._montoCobertura,
                                   string.Empty,
                                   nMontoCobertura.ToString());
                        }

                        if (!dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._observacion))
                        {
                            string strObservacionObtenida = dsGarantiaFiduciariaXTarjeta.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._observacion].ToString();

                            if (strObservacionObtenida.CompareTo(strObservacion) != 0)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._observacion,
                                   strObservacionObtenida,
                                   strObservacion);

                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduXTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._observacion,
                                   string.Empty,
                                   strObservacion);
                        }

                        #endregion
                    }

                    if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
                    {
                        #region Garantía Fiduciaria

                        string[] listaCampos = { clsGarantiaFiduciariaTarjeta._entidadGarantiaFiduciariaTarjeta,
                                                 clsGarantiaFiduciariaTarjeta._codigoTipoPersonaFiador, nTipoFiador.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._cedulaFiador, strCedulaFiador};


                        string strModificaGarFiduTarjeta = string.Format("UPDATE {0} SET {1} = {2} WHERE {3} = '{4}'", listaCampos);
 
                        if (!dsGarantiaFiduciaria.Tables[0].Rows[0].IsNull(clsGarantiaFiduciariaTarjeta._codigoTipoPersonaFiador))
                        {
                            int nTipoFiadorObt = Convert.ToInt32(dsGarantiaFiduciaria.Tables[0].Rows[0][clsGarantiaFiduciariaTarjeta._codigoTipoPersonaFiador].ToString());

                            if (nTipoFiadorObt != nTipoFiador)
                            {
                                oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
                                   2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduTarjeta, string.Empty,
                                   clsGarantiaFiduciariaTarjeta._codigoTipoPersonaFiador,
                                   oTraductor.TraducirTipoPersona(nTipoFiadorObt),
                                   oTraductor.TraducirTipoPersona(nTipoFiador));
                            }
                        }
                        else
                        {
                            oBitacora.InsertarBitacora("TAR_GARANTIA_FIDUCIARIA", strUsuario, strIP, null,
                                  2, 1, strCedulaFiador, strNumeroTarjeta, strModificaGarFiduTarjeta, string.Empty,
                                  clsGarantiaFiduciariaTarjeta._codigoTipoPersonaFiador,
                                  string.Empty,
                                  oTraductor.TraducirTipoPersona(nTipoFiador));
                        }

                        #endregion
                    }

                    #endregion
                }
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

        public void Eliminar(long nGarantiaFiduciaria, long nTarjeta, string strUsuario, string strIP,
                             string strOperacionCrediticia)
		{
            DataSet dsData = new DataSet();
            DataSet dsGarantiaFiduciariaXTarjeta = new DataSet();

            int nFilasAfectadas = 0;

            try
            {
                #region Obtener los datos de la BD antes de ser borrados

                //Se obtienen los datos antes de ser borrados, para luego insertalos en la bitácora
                listaCampos = new string[] { clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria,
                                              clsGarantiaFiduciariaTarjeta._consecutivoTarjeta,
                                              clsGarantiaFiduciariaTarjeta._codigoTipoMitigador,
                                              clsGarantiaFiduciariaTarjeta._codigoTipoDocumentoLegal,
                                              clsGarantiaFiduciariaTarjeta._montoMitigador,
                                              clsGarantiaFiduciariaTarjeta._porcentajeResponsabilidad,
                                              clsGarantiaFiduciariaTarjeta._codigoOperacionEspecial,
                                              clsGarantiaFiduciariaTarjeta._codigoTipoPersonaAcreedor,
                                              clsGarantiaFiduciariaTarjeta._cedulaAcreedor,
                                              clsGarantiaFiduciariaTarjeta._fechaExpiracion,
                                              clsGarantiaFiduciariaTarjeta._montoCobertura,
                                              clsGarantiaFiduciariaTarjeta._observacion,
                                              clsGarantiaFiduciariaTarjeta._porcentajeAceptacion,
                                              clsGarantiaFiduciariaTarjeta._entidadGarantiaFiduciariaXTarjeta,
                                              clsGarantiaFiduciariaTarjeta._consecutivoTarjeta, nTarjeta.ToString(),
                                              clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria, nGarantiaFiduciaria.ToString()};


                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12} FROM dbo.{13} WHERE {14} = {15} AND {16} = {17}", listaCampos);

                dsGarantiaFiduciariaXTarjeta = AccesoBD.ejecutarConsulta(sentenciaSql);

                //Se obtiene el número de la Tarjeta
                listaCampos = new string[] { clsTarjeta._numeroTarjeta,
                                             clsTarjeta._entidadTarjeta,
                                             clsTarjeta._consecutivoTarjeta, nTarjeta.ToString()};

                sentenciaSql = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3}", listaCampos);

                DataSet dsTarjeta = AccesoBD.ejecutarConsulta(sentenciaSql);

                string strNumeroTarjeta = "-";

                if ((dsTarjeta != null) && (dsTarjeta.Tables.Count > 0) && (dsTarjeta.Tables[0].Rows.Count > 0))
                {
                    if (!dsTarjeta.Tables[0].Rows[0].IsNull(clsTarjeta._numeroTarjeta))
                    {
                        strNumeroTarjeta = dsTarjeta.Tables[0].Rows[0][clsTarjeta._numeroTarjeta].ToString();
                    }
                }

                #endregion

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_EliminarGarantiaFiduciariaTarjeta", oConexion))
                    {
                        SqlParameter oParam = new SqlParameter();

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        //Agrega los parametros
                        oComando.Parameters.AddWithValue("@nGarantiaFiduciaria", nGarantiaFiduciaria);
                        oComando.Parameters.AddWithValue("@nTarjeta", nTarjeta);
                        oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
                        oComando.Parameters.AddWithValue("@strIP", strIP);
 
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

                    listaCampos = new string[] { clsGarantiaFiduciariaTarjeta._entidadGarantiaFiduciariaXTarjeta,
                                                 clsGarantiaFiduciariaTarjeta._consecutivoTarjeta, nTarjeta.ToString(),
                                                 clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria, nGarantiaFiduciaria.ToString()};


                    string strEliminarGarFiduXTarjeta = string.Format("DELETE {0} WHERE {1} = {2} AND {3} = {4}", listaCampos);

                    string strCedulaFiador = oTraductor.ObtenerCedulaFiadorGarFiduTar(nGarantiaFiduciaria.ToString());

                    if ((dsGarantiaFiduciariaXTarjeta != null) && (dsGarantiaFiduciariaXTarjeta.Tables.Count > 0) && (dsGarantiaFiduciariaXTarjeta.Tables[0].Rows.Count > 0))
                    {
                        #region Garantía Fiduciaria por Tarjeta

                        foreach (DataRow drGarFiduXTar in dsGarantiaFiduciariaXTarjeta.Tables[0].Rows)
                        {
                            for (int nIndice = 0; nIndice < drGarFiduXTar.Table.Columns.Count; nIndice++)
                            {
                                switch (drGarFiduXTar.Table.Columns[nIndice].ColumnName)
                                {
                                    case clsGarantiaFiduciariaTarjeta._consecutivoGarantiaFiduciaria:
                                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                            3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                            drGarFiduXTar.Table.Columns[nIndice].ColumnName,
                                            strCedulaFiador,
                                            string.Empty);
                                        break;

                                    case clsGarantiaFiduciariaTarjeta._consecutivoTarjeta:
                                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                        3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                        drGarFiduXTar.Table.Columns[nIndice].ColumnName,
                                                        strNumeroTarjeta,
                                                        string.Empty);
                                        break;

                                    case clsGarantiaFiduciariaTarjeta._codigoOperacionEspecial:
                                        if (drGarFiduXTar[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                               3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                               drGarFiduXTar.Table.Columns[nIndice].ColumnName,
                                               oTraductor.TraducirTipoOperacionEspecial(Convert.ToInt32(drGarFiduXTar[nIndice, DataRowVersion.Current].ToString())),
                                               string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                               3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                               drGarFiduXTar.Table.Columns[nIndice].ColumnName,
                                               string.Empty,
                                               string.Empty);
                                        }

                                        break;

                                    case clsGarantiaFiduciariaTarjeta._codigoTipoPersonaAcreedor:
                                        if (drGarFiduXTar[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                   3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                   drGarFiduXTar.Table.Columns[nIndice].ColumnName,
                                                   oTraductor.TraducirTipoPersona(Convert.ToInt32(drGarFiduXTar[nIndice, DataRowVersion.Current].ToString())),
                                                   string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                   3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                   drGarFiduXTar.Table.Columns[nIndice].ColumnName,
                                                   string.Empty,
                                                   string.Empty);
                                        }
                                        break;

                                    case clsGarantiaFiduciariaTarjeta._codigoTipoDocumentoLegal:
                                        if (drGarFiduXTar[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                       3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                       drGarFiduXTar.Table.Columns[nIndice].ColumnName,
                                                       oTraductor.TraducirTipoDocumento(Convert.ToInt32(drGarFiduXTar[nIndice, DataRowVersion.Current].ToString())),
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                       3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                       drGarFiduXTar.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }
                                        break;

                                    case clsGarantiaFiduciariaTarjeta._codigoTipoMitigador:
                                        if (drGarFiduXTar[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                           3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                           drGarFiduXTar.Table.Columns[nIndice].ColumnName,
                                                           oTraductor.TraducirTipoMitigador(Convert.ToInt32(drGarFiduXTar[nIndice, DataRowVersion.Current].ToString())),
                                                           string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                                          3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                                          drGarFiduXTar.Table.Columns[nIndice].ColumnName,
                                                          string.Empty,
                                                          string.Empty);
                                        }
                                        break;

                                    default:
                                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                                         3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
                                         drGarFiduXTar.Table.Columns[nIndice].ColumnName,
                                         drGarFiduXTar[nIndice, DataRowVersion.Current].ToString(),
                                         string.Empty);
                                        break;
                                }

                            }
                        }

                        #endregion
                    }
                    else
                    {
                        oBitacora.InsertarBitacora("TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA", strUsuario, strIP, null,
                            3, 1, strCedulaFiador, strNumeroTarjeta, strEliminarGarFiduXTarjeta, string.Empty,
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

		#endregion
	}
}
