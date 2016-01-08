using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Text;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Globalization;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Garantias_Reales.
    /// </summary>
    public class Garantias_Reales
    {
        #region Variables

        bool procesoNormalizacion = false;
        int nFilasAfectadas = 0;
        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        DateTime fechaBase = new DateTime(1900, 01, 01);

        #endregion Variables

        #region Métodos Públicos

        public void Crear(long nOperacion, int nTipoGarantia, int nClaseGarantia, int nTipoGarantiaReal,
                          int nPartido, string strFinca, int nGrado, int nCedulaFiduciaria,
                          string strClaseBien, string strNumPlaca, int nTipoBien,
                          int nTipoMitigador, int nTipoDocumento, decimal nMontoMitigador, int nInscripcion,
                          DateTime dFechaPresentacion, decimal nPorcentaje, int nGradoGravamen, int nOperacionEspecial,
                          DateTime dFechaConstitucion, DateTime dFechaVencimiento, int nTipoAcreedor,
                          string strCedulaAcreedor, int nLiquidez, int nTenencia, int nMoneda,
                          DateTime dFechaPrescripcion, string strUsuario, string strIP,
                          string strOperacionCrediticia, string strGarantia, decimal porcentajeAceptacion)
        {
            string identifiacionGarantia = string.Format("Real: {0}, relacionada a la operación/contrato: {1}", strGarantia, strOperacionCrediticia);
            DataSet dsData = new DataSet();
            DataSet dsGarantiaReal = new DataSet();
            string strConsultaGarantiasReales = string.Empty;


            try
            {
                //Se obtiene la información sobre la Garantía Real, esto por si se debe insertar
                #region Armar Consulta de la Garanta Real

                listaCampos = new string[] { clsGarantiaReal._codGarantiaReal,
                                             clsGarantiaReal._entidadGarantiaReal,
                                             clsGarantiaReal._codClaseGarantia, nClaseGarantia.ToString(),
                                             clsGarantiaReal._codTipoGarantiaReal, nTipoGarantiaReal.ToString()};

                string consultaBaseGarantiasReales = string.Format("SELECT {0} FROM dbo.{1} WHERE {2} = {3} AND {4} = {5}", listaCampos);

                switch (nTipoGarantiaReal)
                {
                    case ((int)Enumeradores.Tipos_Garantia_Real.Hipoteca):

                        listaCampos = new string[] { consultaBaseGarantiasReales,
                                                     clsGarantiaReal._codPartido, ((nPartido != -1) ? nPartido.ToString() : clsGarantiaReal._codPartido),
                                                     clsGarantiaReal._numeroFinca, ((strFinca.Trim().Length > 0) ? strFinca : clsGarantiaReal._numeroFinca)};

                        strConsultaGarantiasReales = string.Format("{0} AND {1} = {2} AND {3} = '{4}'", listaCampos);

                        break;

                    case ((int)Enumeradores.Tipos_Garantia_Real.Cedula_Hipotecaria):

                        listaCampos = new string[] { consultaBaseGarantiasReales,
                                                     clsGarantiaReal._codPartido, ((nPartido != -1) ? nPartido.ToString() : clsGarantiaReal._codPartido),
                                                     clsGarantiaReal._numeroFinca, ((strFinca.Trim().Length > 0) ? strFinca : clsGarantiaReal._numeroFinca),
                                                     clsGarantiaReal._codGrado, ((nGrado != -1) ? nGrado.ToString() : clsGarantiaReal._codGrado),
                                                     clsGarantiaReal._cedulaHipotecaria, ((nCedulaFiduciaria != -1) ? nCedulaFiduciaria.ToString() : clsGarantiaReal._cedulaHipotecaria)};

                        strConsultaGarantiasReales = string.Format("{0} AND {1} = {2} AND {3} = '{4}' AND {5} = {6} AND {7} = {8}", listaCampos);

                        break;

                    case ((int)Enumeradores.Tipos_Garantia_Real.Prenda):

                        listaCampos = new string[] { consultaBaseGarantiasReales,
                                                     clsGarantiaReal._codClaseBien, ((strClaseBien.Trim().Length > 0) ? strClaseBien : clsGarantiaReal._codClaseBien),
                                                     clsGarantiaReal._numPlacaBien, ((strNumPlaca.Trim().Length > 0) ? strNumPlaca : clsGarantiaReal._numPlacaBien)};

                        strConsultaGarantiasReales = string.Format("{0} AND {1} = {2} AND {3} = '{4}'", listaCampos);

                        break;
                    default:
                        strConsultaGarantiasReales = string.Empty;
                        break;
                }

                #endregion
                if (strConsultaGarantiasReales.Length > 0)
                {
                    dsGarantiaReal = AccesoBD.ejecutarConsulta(strConsultaGarantiasReales);
                }

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand("pa_InsertarGarantiaReal", oConexion))
                    {
                        SqlParameter oParam = new SqlParameter();

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.StoredProcedure;

                        //Agrega los parámetros
                        oComando.Parameters.AddWithValue("@piTipo_Garantia", nTipoGarantia);
                        oComando.Parameters.AddWithValue("@piClase_Garantia", nClaseGarantia);
                        oComando.Parameters.AddWithValue("@nTipoGarantiaReal", nTipoGarantiaReal);

                        if (nPartido != -1)
                            oComando.Parameters.AddWithValue("@piPartido", nPartido);

                        if (strFinca != "")
                            oComando.Parameters.AddWithValue("@psNumero_Finca", strFinca);

                        if (nGrado != -1)
                            oComando.Parameters.AddWithValue("@piGrado", nGrado);

                        if (nCedulaFiduciaria != -1)
                            oComando.Parameters.AddWithValue("@piCedula_Hipotecaria", nCedulaFiduciaria);

                        if (strClaseBien != "")
                            oComando.Parameters.AddWithValue("@psClase_Bien", strClaseBien);

                        if (strNumPlaca != "")
                            oComando.Parameters.AddWithValue("@psNumero_Placa", strNumPlaca);

                        if (nTipoBien != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Bien", nTipoBien);

                        oComando.Parameters.AddWithValue("@pbConsecutivo_Operacion", nOperacion);

                        if (nTipoMitigador != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Mitigador", nTipoMitigador);

                        if (nTipoDocumento != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Documento_Legal", nTipoDocumento);

                        oComando.Parameters.AddWithValue("@pdMonto_Mitigador", nMontoMitigador);

                        if (nInscripcion != -1)
                            oComando.Parameters.AddWithValue("@piInscripcion", nInscripcion);

                        oComando.Parameters.AddWithValue("@pdtFecha_Presentacion", dFechaPresentacion);
                        oComando.Parameters.AddWithValue("@pdPorcentaje_Responsabilidad", nPorcentaje);
                        oComando.Parameters.AddWithValue("@piGrado_Gravamen", nGradoGravamen);

                        if (nOperacionEspecial != -1)
                            oComando.Parameters.AddWithValue("@piOperacion_Especial", nOperacionEspecial);

                        oComando.Parameters.AddWithValue("@pdtFecha_Constitucion", dFechaConstitucion);
                        oComando.Parameters.AddWithValue("@pdtFecha_Vencimiento", dFechaVencimiento);

                        if (nTipoAcreedor != -1)
                            oComando.Parameters.AddWithValue("@piTipo_Acreedor", nTipoAcreedor);

                        if (strCedulaAcreedor != "")
                            oComando.Parameters.AddWithValue("@psCedula_Acreedor", strCedulaAcreedor);

                        oComando.Parameters.AddWithValue("@piLiquidez", nLiquidez);
                        oComando.Parameters.AddWithValue("@piTenencia", nTenencia);
                        oComando.Parameters.AddWithValue("@pdtFecha_Prescripcion", dFechaPrescripcion);
                        oComando.Parameters.AddWithValue("@piMoneda", nMoneda);
                        oComando.Parameters.AddWithValue("@pdPorcentaje_Aceptacion", porcentajeAceptacion);

                        //Abre la conexión
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        nFilasAfectadas = oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }
                }

                //Inserta en bitácora
                if (nFilasAfectadas > 0)
                {
                    #region Inserción en Bitácora

                    Bitacora oBitacora = new Bitacora();

                    TraductordeCodigos oTraductor = new TraductordeCodigos();


                    if ((dsGarantiaReal == null) || (dsGarantiaReal.Tables.Count == 0) || (dsGarantiaReal.Tables[0].Rows.Count == 0))
                    {
                        #region Inserción de Garantía Real

                        #region Armar String de Inserción de la Garantía Real

                        listaCampos = new string[] { clsGarantiaReal._entidadGarantiaReal,
                                                     clsGarantiaReal._codTipoGarantia, clsGarantiaReal._codClaseGarantia, clsGarantiaReal._codTipoGarantiaReal, clsGarantiaReal._codPartido,
                                                     clsGarantiaReal._numeroFinca, clsGarantiaReal._codGrado, clsGarantiaReal._cedulaHipotecaria, clsGarantiaReal._codClaseBien,
                                                     clsGarantiaReal._numPlacaBien, clsGarantiaReal._codTipoBien,
                                                     nTipoGarantia.ToString(), nClaseGarantia.ToString(),  nTipoGarantiaReal.ToString(), nPartido.ToString(),
                                                     (((strFinca != null) && (strFinca.Length > 0)) ? strFinca : "''"),
                                                     ((nGrado > 0) ? nGrado.ToString() : "-1"),
                                                     ((nCedulaFiduciaria > 0) ? nCedulaFiduciaria.ToString() : "-1"),
                                                     (((strClaseBien != null) && (strClaseBien.Length > 0)) ? strClaseBien : "''"),
                                                     (((strNumPlaca != null) && (strNumPlaca.Length > 0)) ? strNumPlaca : "''"),
                                                     ((nTipoBien > 0) ? nTipoBien.ToString() : "-1")};

                        string strInsertaGarantiaReal = string.Format("INSERT INTO {0} ({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}) VALUES ({11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20})", listaCampos);

                        #endregion

                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                            clsGarantiaReal._codTipoGarantia,
                            string.Empty,
                            oTraductor.TraducirTipoGarantia(nTipoGarantia));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                            clsGarantiaReal._codClaseGarantia,
                            string.Empty,
                            oTraductor.TraducirClaseGarantia(nClaseGarantia));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                            clsGarantiaReal._codTipoGarantiaReal,
                            string.Empty,
                            oTraductor.TraducirTipoGarantiaReal(nTipoGarantiaReal));

                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                            clsGarantiaReal._codPartido,
                            string.Empty,
                            nPartido.ToString());

                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                            clsGarantiaReal._numeroFinca,
                            string.Empty,
                            strFinca);

                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                            clsGarantiaReal._codGrado,
                            string.Empty,
                            nGrado.ToString());

                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                            clsGarantiaReal._cedulaHipotecaria,
                            string.Empty,
                            nCedulaFiduciaria.ToString());

                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                            clsGarantiaReal._codClaseBien,
                            string.Empty,
                            strClaseBien);

                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                            clsGarantiaReal._numPlacaBien,
                            string.Empty,
                            strNumPlaca);

                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarantiaReal, string.Empty,
                            clsGarantiaReal._codTipoBien,
                            string.Empty,
                            oTraductor.TraducirTipoBien(nTipoBien));

                        dsGarantiaReal = AccesoBD.ejecutarConsulta(strConsultaGarantiasReales);

                        #endregion
                    }

                    if ((dsGarantiaReal != null) && (dsGarantiaReal.Tables.Count > 0) && (dsGarantiaReal.Tables[0].Rows.Count > 0))
                    {
                        #region Inserción de Garantías Reales por Operación

                        string strCodigoGarantiaReal = dsGarantiaReal.Tables[0].Rows[0][clsGarantiaReal._codGarantiaReal].ToString();

                        #region Armar String de Inserción de la Garantía por Operación

                        listaCampos = new string[] { clsGarantiaReal._entidadGarantiaRealXOperacion,
                                                     clsGarantiaReal._codOperacion, clsGarantiaReal._codGarantiaReal, clsGarantiaReal._codTipoMitigador, clsGarantiaReal._codTipoDocumentoLegal,
                                                     clsGarantiaReal._montoMitigador, clsGarantiaReal._codInscripcion, clsGarantiaReal._fechaPresentacion, clsGarantiaReal._porcentajeResponsabilidad,
                                                     clsGarantiaReal._codGradoGravamen, clsGarantiaReal._codOperacionEspecial, clsGarantiaReal._fechaConstitucion, clsGarantiaReal._fechaVencimiento,
                                                     clsGarantiaReal._codTipoAcreedor, clsGarantiaReal._cedAcreedor, clsGarantiaReal._codLiquidez, clsGarantiaReal._codTenencia, clsGarantiaReal._fechaPrescripcion,
                                                     clsGarantiaReal._codMoneda, clsGarantiaReal._porcentajeAceptacion,
                                                     nOperacion.ToString(), strCodigoGarantiaReal,  nTipoMitigador.ToString(), nTipoDocumento.ToString(), nMontoMitigador.ToString(),
                                                     ((nInscripcion > 0) ? nInscripcion.ToString() : "-1"),
                                                     (((dFechaPresentacion != null) && (dFechaPresentacion != fechaBase) && (dFechaPresentacion != DateTime.MinValue)) ? dFechaPresentacion.ToShortDateString() : "''"),
                                                     ((nPorcentaje > 0) ? nPorcentaje.ToString() : "-1"),
                                                     nGradoGravamen.ToString(),
                                                     ((nOperacionEspecial > 0) ? nOperacionEspecial.ToString() : "-1"),
                                                     (((dFechaConstitucion != null) && (dFechaConstitucion != fechaBase) && (dFechaConstitucion != DateTime.MinValue)) ? dFechaConstitucion.ToShortDateString() : "''"),
                                                     (((dFechaVencimiento != null) && (dFechaVencimiento != fechaBase) && (dFechaVencimiento != DateTime.MinValue)) ? dFechaVencimiento.ToShortDateString() : "''"),
                                                     ((nTipoAcreedor > 0) ? nTipoAcreedor.ToString() : "-1"),
                                                     (((strCedulaAcreedor != null) && (strCedulaAcreedor.Length > 0)) ? strCedulaAcreedor : "''"),
                                                     nLiquidez.ToString(),
                                                     nTenencia.ToString(),
                                                     (((dFechaPrescripcion != null) && (dFechaPrescripcion != fechaBase) && (dFechaPrescripcion != DateTime.MinValue)) ? dFechaPrescripcion.ToShortDateString() : "''"),
                                                     nMoneda.ToString(),
                                                     ((porcentajeAceptacion > 0) ? porcentajeAceptacion.ToString() : "0")};

                        string strInsertaGarRealXOperacion = string.Format("INSERT INTO {0} ({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}) VALUES ({20}, {21}, {22}, {23}, {24}, {25}, {26}, {27}, {28}, {29}, {30}, {31}, {32}, {33}, {34}, {35}, {36}, {37}, {38})", listaCampos);

                        #endregion

                        #region Garantía Real por Operación

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._codOperacion,
                            string.Empty,
                            strOperacionCrediticia);

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._codGarantiaReal,
                            string.Empty,
                            strGarantia);

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._codTipoMitigador,
                            string.Empty,
                            oTraductor.TraducirTipoMitigador(nTipoMitigador));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._codTipoDocumentoLegal,
                            string.Empty,
                            oTraductor.TraducirTipoDocumento(nTipoDocumento));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._montoMitigador,
                            string.Empty,
                            nMontoMitigador.ToString("N2"));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._codInscripcion, UtilitariosComun.ValorNulo, nInscripcion.ToString());

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._fechaPresentacion,
                            string.Empty,
                            dFechaPresentacion.ToShortDateString());

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._porcentajeResponsabilidad,
                            string.Empty,
                            nPorcentaje.ToString());

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._codGradoGravamen,
                            string.Empty,
                            oTraductor.TraducirGradoGravamen(nGradoGravamen));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._codOperacionEspecial,
                            string.Empty,
                            oTraductor.TraducirTipoOperacionEspecial(nOperacionEspecial));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._fechaConstitucion, string.Empty, dFechaConstitucion.ToShortDateString());

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._fechaVencimiento,
                            string.Empty,
                            dFechaVencimiento.ToShortDateString());

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._codTipoAcreedor,
                            string.Empty,
                            oTraductor.TraducirTipoPersona(nTipoAcreedor));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._cedAcreedor,
                            string.Empty,
                            strCedulaAcreedor);

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._codLiquidez,
                            string.Empty,
                            oTraductor.TraducirTipoLiquidez(nLiquidez));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._codTenencia,
                            string.Empty,
                            oTraductor.TraducirTipoTenencia(nTenencia));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._fechaPrescripcion,
                            string.Empty,
                            dFechaPrescripcion.ToShortDateString());

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._codMoneda,
                            string.Empty,
                            oTraductor.TraducirTipoMoneda(nMoneda));

                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                            1, nTipoGarantia, strGarantia, strOperacionCrediticia, strInsertaGarRealXOperacion, string.Empty,
                            clsGarantiaReal._porcentajeAceptacion,
                            string.Empty,
                            porcentajeAceptacion.ToString());
                        #endregion

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

        public void Modificar(clsGarantiaReal datosGarantiaReal, string strUsuario, string strIP,
                              string strOperacionCrediticia, string strGarantia)
        {
            #region Ejemplo Trama Retornada

            //<DATOS>
            //    <MODIFICADOS>
            //        <GAROPER>
            //            <cod_operacion>136148</cod_operacion>
            //            <cod_garantia_real>13</cod_garantia_real>
            //            <cod_tipo_mitigador>2</cod_tipo_mitigador>
            //        </GAROPER>
            //    </MODIFICADOS>
            //    <PISTA_AUDITORIA>
            //        <BITACORA des_tabla="GAR_GARANTIA_REAL" cod_usuario="401640970" cod_ip="127.0.0.1" cod_oficina="NULL" cod_operacion="2" fecha_hora="20120814" cod_consulta="UPDATE GAR_GARANTIAS_REALES_X_OPERACION SET cod_tipo_mitigador=2" cod_tipo_garantia="2" cod_garantia="Partido: 1 - Finca: 355885" cod_operacion_crediticia="1-932-1-2-5895052" cod_consulta2="NULL" des_campo_afectado="cod_tipo_mitigador" est_anterior_campo_afectado="Hipotecas sobre residencias habitadas por el deudor (ponderacin del 50%)" est_actual_campo_afectado="2-Hipotecas sobre edificaciones" />
            //    </PISTA_AUDITORIA>
            //</DATOS>

            //<?xml version="1.0" encoding="utf-8"?><DATOS><MODIFICADOS><GAROPER><cod_operacion>136148</cod_operacion><cod_garantia_real>13</cod_garantia_real><cod_tipo_mitigador>2</cod_tipo_mitigador></GAROPER></MODIFICADOS><PISTA_AUDITORIA><BITACORA des_tabla="GAR_GARANTIA_REAL" cod_usuario="401640970" cod_ip="127.0.0.1" cod_oficina="NULL" cod_operacion="2" fecha_hora="20120814" cod_consulta="UPDATE GAR_GARANTIAS_REALES_X_OPERACION SET cod_tipo_mitigador=2" cod_tipo_garantia="2" cod_garantia="Partido: 1 - Finca: 355885" cod_operacion_crediticia="1-932-1-2-5895052" cod_consulta2="NULL" des_campo_afectado="cod_tipo_mitigador" est_anterior_campo_afectado="Hipotecas sobre residencias habitadas por el deudor (ponderacin del 50%)" est_actual_campo_afectado="2-Hipotecas sobre edificaciones" /></PISTA_AUDITORIA></DATOS>

            #endregion Ejemplo Trama Retornada

            string trama = datosGarantiaReal.ObtenerTramaDatosModificados(strUsuario, strIP);
            string respuestaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (trama.Length > 0)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psTrama", SqlDbType.NText),
                        new SqlParameter("piCodigo_Garantia_Real", SqlDbType.BigInt),
                        new SqlParameter("piCodigo_Operacion", SqlDbType.BigInt),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar,30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = trama;
                    parameters[1].Value = datosGarantiaReal.CodGarantiaReal;
                    parameters[2].Value = datosGarantiaReal.CodOperacion;
                    parameters[3].Value = strUsuario;
                    parameters[4].Direction = ParameterDirection.Output;

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "pa_ModificarGarantiaRealXML", parameters);

                        respuestaObtenida = parameters[4].Value.ToString();

                        oConexion.Close();
                        oConexion.Dispose();
                    }

                    if (respuestaObtenida.Length > 0)
                    {
                        strMensajeObtenido = UtilitariosComun.ObtenerCodigoMensaje(respuestaObtenida);

                        if (strMensajeObtenido[0].CompareTo("0") != 0)
                        {
                            if (procesoNormalizacion)
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA_DETALLE, strGarantia, strMensajeObtenido[1], Mensajes.ASSEMBLY));
                            }
                            else
                            {
                                throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA, strGarantia, Mensajes.ASSEMBLY));
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (procesoNormalizacion)
                    {
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA_DETALLE, strGarantia, strMensajeObtenido[1], Mensajes.ASSEMBLY));
                    }
                    else
                    {
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA_DETALLE, strGarantia, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA, strGarantia, Mensajes.ASSEMBLY));
                    }
                }
            }
        }

        public void Eliminar(long nOperacion, long nGarantia, string strUsuario, string strIP,
                             string strOperacionCrediticia, string strGarantia)
        {
            string identifiacionGarantia = string.Format("Real: {0}, relacionada a la operación/contrato: {1}", strGarantia, strOperacionCrediticia);
            DataSet dsGarantiaReal = new DataSet();
            DataSet dsGarantiaRealXOperacion = new DataSet();
            DataSet dsValuacionesReales = new DataSet();
            DataSet dsPolizasRelacionadas = new DataSet();
            string sentenciaSqlGarantiasXOperacion = string.Empty;

            try
            {
                //Se obtienen los datos antes de ser borrados, con el fin de poderlos insertar en la bitácora
                #region Obtener Datos previos a actualización

                listaCampos = new string[] { clsGarantiaReal._cedulaHipotecaria, clsGarantiaReal._codClaseBien, clsGarantiaReal._codClaseGarantia, clsGarantiaReal._codGarantiaReal,
                                             clsGarantiaReal._codGrado, clsGarantiaReal._codPartido, clsGarantiaReal._codTipoBien, clsGarantiaReal._codTipoGarantia,
                                             clsGarantiaReal._codTipoGarantiaReal, clsGarantiaReal._numPlacaBien, clsGarantiaReal._numeroFinca, clsGarantiaReal._identificacionSicc,
                                             clsGarantiaReal._identificacionAlfanumericaSicc, clsGarantiaReal._indicadorViviendaHabitadaDeudor, clsGarantiaReal._usuarioModifico,
                                             clsGarantiaReal._fechaModifico, clsGarantiaReal._fechaInserto, clsGarantiaReal._fechaReplica,
                                             clsGarantiaReal._entidadGarantiaReal,
                                             clsGarantiaReal._codGarantiaReal, nGarantia.ToString()};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17} FROM dbo.{18} WHERE {19} = {20}", listaCampos);

                dsGarantiaReal = AccesoBD.ejecutarConsulta(sentenciaSql);


                listaCampos = new string[] {clsGarantiaReal._cedAcreedor, clsGarantiaReal._codEstado,  clsGarantiaReal._codGarantiaReal, clsGarantiaReal._codGradoGravamen,  clsGarantiaReal._codInscripcion,
                                            clsGarantiaReal._codLiquidez,  clsGarantiaReal._codMoneda, clsGarantiaReal._codOperacion,  clsGarantiaReal._codOperacionEspecial,
                                            clsGarantiaReal._codTenencia,  clsGarantiaReal._codTipoAcreedor, clsGarantiaReal._codTipoDocumentoLegal,  clsGarantiaReal._codTipoMitigador,
                                            clsGarantiaReal._fechaConstitucion,  clsGarantiaReal._fechaPrescripcion, clsGarantiaReal._fechaPresentacion,  clsGarantiaReal._fechaVencimiento,
                                            clsGarantiaReal._montoMitigador,  clsGarantiaReal._porcentajeResponsabilidad, clsGarantiaReal._fechaValuacionSicc,  clsGarantiaReal._usuarioModifico,
                                            clsGarantiaReal._fechaModifico,  clsGarantiaReal._fechaInserto, clsGarantiaReal._fechaReplica,  clsGarantiaReal._porcentajeAceptacion,
                                            clsGarantiaReal._entidadGarantiaRealXOperacion,
                                            clsGarantiaReal._codOperacion, nOperacion.ToString(),
                                            clsGarantiaReal._codGarantiaReal, nGarantia.ToString()};

                sentenciaSqlGarantiasXOperacion = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24} FROM dbo.{25} WHERE {26} = {27} AND {28} = {29}", listaCampos);
             
                dsGarantiaRealXOperacion = AccesoBD.ejecutarConsulta(sentenciaSqlGarantiasXOperacion);


                listaCampos = new string[] {clsValuacionReal._cedulaEmpresa, clsValuacionReal._cedulaPerito,  clsValuacionReal._codGarantiaReal, clsValuacionReal._codInspeccionMenorTresMeses,
                                            clsValuacionReal._codRecomendacionPerito, clsValuacionReal._fechaConstruccion,  clsValuacionReal._fechaUltimoSeguimiento, clsValuacionReal._fechaValuacion,
                                            clsValuacionReal._montoTasacionActualizadaNoTerreno, clsValuacionReal._montoTasacionActualizadaTerreno,  clsValuacionReal._montoTotalAvaluo,
                                            clsValuacionReal._montoUltimaTasacionNoTerreno,  clsValuacionReal._montoUltimaTasacionTerreno, clsValuacionReal._indicadorTipoRegistro,
                                            clsValuacionReal._indicadorAvaluoActualizado, clsValuacionReal._fechaSemestreActualizado,  clsValuacionReal._usuarioModifico,
                                            clsValuacionReal._fechaModifico,  clsValuacionReal._fechaInserto, clsValuacionReal._fechaReplica,  clsValuacionReal._porcentajeAceptacionTerreno,
                                            clsValuacionReal._porcentajeAceptacionNoTerreno,  clsValuacionReal._porcentajeAceptacionTerrenoCalculado, clsValuacionReal._porcentajeAceptacionNoTerrenoCalculado,
                                            clsValuacionReal._entidadValuacionesReales,
                                            clsValuacionReal._codGarantiaReal, nGarantia.ToString()};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23} FROM dbo.{24} WHERE {25} = {26}", listaCampos);

                dsValuacionesReales = AccesoBD.ejecutarConsulta(sentenciaSql);


                listaCampos = new string[] {clsGarantiaReal._codigoSap, clsGarantiaReal._codOperacion, clsGarantiaReal._codGarantiaReal, clsPolizaSap._codigoEstadoRegistro, clsGarantiaReal._montoAcreencia,
                                            clsGarantiaReal._fechaInserto,  clsGarantiaReal._usuarioModifico, clsGarantiaReal._fechaModifico,  clsGarantiaReal._usuarioInserto,
                                            clsGarantiaReal._entidadPolizasRelaciondas +
                                            clsGarantiaReal._codOperacion, nOperacion.ToString(),
                                            clsGarantiaReal._codGarantiaReal, nGarantia.ToString()};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8} FROM dbo.{9} WHERE {10} = {11} AND {12} = {13}", listaCampos);

                dsPolizasRelacionadas = AccesoBD.ejecutarConsulta(sentenciaSql);


                #endregion

                SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("pbConsecutivo_Garantia_Real", SqlDbType.BigInt),
                        new SqlParameter("pbConsecutivo_Operacion", SqlDbType.BigInt)
                    };

                parameters[0].Value = nGarantia;
                parameters[1].Value = nOperacion;

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    oConexion.Open();

                    AccesoBD.ExecuteNonQuery(CommandType.StoredProcedure, "pa_EliminarGarantiaReal", parameters);

                    oConexion.Close();
                    oConexion.Dispose();
                }

                #region Inserción en Bitácora

                Bitacora oBitacora = new Bitacora();

                TraductordeCodigos oTraductor = new TraductordeCodigos();

                listaCampos = new string[] {clsGarantiaReal._entidadGarantiaRealXOperacion,
                                            clsGarantiaReal._codOperacion, nOperacion.ToString(),
                                            clsGarantiaReal._codGarantiaReal, nGarantia.ToString()};

                string strElimimarGarRealXOperacion = string.Format("DELETE FROM {0} WHERE {1} = {2} AND {3} = {4}", listaCampos);

                if ((dsGarantiaRealXOperacion != null) && (dsGarantiaRealXOperacion.Tables.Count > 0) && (dsGarantiaRealXOperacion.Tables[0].Rows.Count > 0))
                {
                    #region Garantía Real por Operación

                    foreach (DataRow drGarRealXOP in dsGarantiaRealXOperacion.Tables[0].Rows)
                    {
                        for (int nIndice = 0; nIndice < drGarRealXOP.Table.Columns.Count; nIndice++)
                        {
                            switch (drGarRealXOP.Table.Columns[nIndice].ColumnName)
                            {
                                case clsGarantiaReal._codEstado:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                               3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                               drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                               oTraductor.TraducirTipoEstado(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                               string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                               3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                               drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                               string.Empty,
                                               string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._codGarantiaReal:
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                            3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                            drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                            strGarantia,
                                                            string.Empty);
                                    break;

                                case clsGarantiaReal._codGradoGravamen:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                              drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              oTraductor.TraducirGradoGravamen(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                              string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                              drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              string.Empty,
                                              string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._codInscripcion:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                  3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                  drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                  oTraductor.TraducirTipoInscripcion(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                  string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                  3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                  drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                  string.Empty,
                                                  string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._codLiquidez:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                oTraductor.TraducirTipoLiquidez(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                               3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                               drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                               string.Empty,
                                               string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._codMoneda:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                  3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                  drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                  oTraductor.TraducirTipoMoneda(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                  string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                  3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                  drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                  string.Empty,
                                                  string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._codOperacion:
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                               3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                               drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                               strOperacionCrediticia,
                                                               string.Empty);
                                    break;

                                case clsGarantiaReal._codOperacionEspecial:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                   oTraductor.TraducirTipoOperacionEspecial(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                   string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                   string.Empty,
                                                   string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._codTenencia:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                      3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                      drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                      oTraductor.TraducirTipoTenencia(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                      string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                      3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                      drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                      string.Empty,
                                                      string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._codTipoAcreedor:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                           3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                           drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                           oTraductor.TraducirTipoPersona(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                           string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                           3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                           drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                           string.Empty,
                                                           string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._codTipoDocumentoLegal:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                               3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                               drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                               oTraductor.TraducirTipoDocumento(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                               string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                               3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                               drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                               string.Empty,
                                               string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._codTipoMitigador:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                   oTraductor.TraducirTipoMitigador(Convert.ToInt32(drGarRealXOP[nIndice, DataRowVersion.Current].ToString())),
                                                   string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                   string.Empty,
                                                   string.Empty);
                                    }

                                    break;

                                case clsGarantiaReal._montoMitigador:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        decimal montoMitigador = ((decimal.TryParse(drGarRealXOP[nIndice, DataRowVersion.Current].ToString(), out montoMitigador)) ? montoMitigador : 0);

                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                   montoMitigador.ToString("N2"),
                                                   string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                   string.Empty,
                                                   string.Empty);
                                    }

                                    break;


                                case clsGarantiaReal._porcentajeAceptacion:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        decimal porcentajeAceptacion = ((decimal.TryParse(drGarRealXOP[nIndice, DataRowVersion.Current].ToString(), out porcentajeAceptacion)) ? ((porcentajeAceptacion >= 0) ? porcentajeAceptacion : 0) : 0);

                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                   porcentajeAceptacion.ToString("N2"),
                                                   string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                   string.Empty,
                                                   string.Empty);
                                    }

                                    break;

                                case clsGarantiaReal._porcentajeResponsabilidad:
                                    if (drGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        decimal porcentajeRespons = ((decimal.TryParse(drGarRealXOP[nIndice, DataRowVersion.Current].ToString(), out porcentajeRespons)) ? ((porcentajeRespons >= 0) ? porcentajeRespons : 0) : 0);

                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                   porcentajeRespons.ToString("N2"),
                                                   string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                                   3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                                   drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                                   string.Empty,
                                                   string.Empty);
                                    }

                                    break;

                                default:
                                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                                     3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                                     drGarRealXOP.Table.Columns[nIndice].ColumnName,
                                     drGarRealXOP[nIndice, DataRowVersion.Current].ToString(),
                                     string.Empty);
                                    break;
                            }


                        }
                    }

                    #endregion
                }
                else
                {
                    oBitacora.InsertarBitacora("GAR_GARANTIAS_REALES_X_OPERACION", strUsuario, strIP, null,
                        3, 2, strGarantia, strOperacionCrediticia, strElimimarGarRealXOperacion, string.Empty,
                        string.Empty,
                        string.Empty,
                        string.Empty);
                }

                #region Pólizas Relacionadas

                listaCampos = new string[] {clsGarantiaReal._entidadPolizasRelaciondas,
                                            clsGarantiaReal._codOperacion, nOperacion.ToString(),
                                            clsGarantiaReal._codGarantiaReal, nGarantia.ToString()};

                string strElimimarPolizasXGarRealXOperacion = string.Format("DELETE FROM {0} WHERE {1} = {2} AND {3} = {4}", listaCampos);

                if ((dsPolizasRelacionadas != null) && (dsPolizasRelacionadas.Tables.Count > 0) && (dsPolizasRelacionadas.Tables[0].Rows.Count > 0))
                {
                    string[] formatosFecha = { "yyyyMMdd", "dd/MM/yyyy" };

                    #region Pólizas Relacionadas a Garantía Real por Operación

                    foreach (DataRow drPolGarRealXOP in dsPolizasRelacionadas.Tables[0].Rows)
                    {
                        for (int nIndice = 0; nIndice < drPolGarRealXOP.Table.Columns.Count; nIndice++)
                        {
                            switch (drPolGarRealXOP.Table.Columns[nIndice].ColumnName)
                            {
                                case clsGarantiaReal._codigoSap:
                                    oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                    3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                    drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                    drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString(),
                                    string.Empty);

                                    break;

                                case clsGarantiaReal._codOperacion:
                                    oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                    3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                    drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                    strOperacionCrediticia,
                                    string.Empty);

                                    break;

                                case clsGarantiaReal._codGarantiaReal:
                                    oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                    3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                    drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                    strGarantia,
                                    string.Empty);

                                    break;

                                case clsPolizaSap._codigoEstadoRegistro:
                                    if (drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        bool estadoAlmacenado;
                                        string estado = ((bool.TryParse(drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString(), out estadoAlmacenado)) ? ((estadoAlmacenado) ? "Activo" : "Inactivo") : "Inactivo");

                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              estado,
                                              string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              string.Empty,
                                              string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._montoAcreencia:
                                    if (drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {

                                        decimal montoAcreencia = ((decimal.TryParse(drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString(), out montoAcreencia)) ? montoAcreencia : 0);

                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              montoAcreencia.ToString("N2"),
                                              string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              string.Empty,
                                              string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._fechaInserto:
                                    if (drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        DateTime fechaConver;
                                        string fecha = DateTime.TryParseExact(drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString(), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fechaConver) ? fechaConver.ToString("dd/MM/yyyy") : string.Empty;

                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              fecha,
                                              string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              string.Empty,
                                              string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._usuarioModifico:
                                    if (drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString(),
                                              string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              string.Empty,
                                              string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._fechaModifico:
                                    if (drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        DateTime fechaConver;
                                        string fecha = DateTime.TryParseExact(drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString(), formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fechaConver) ? fechaConver.ToString("dd/MM/yyyy") : string.Empty;

                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              fecha,
                                              string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              string.Empty,
                                              string.Empty);
                                    }
                                    break;

                                case clsGarantiaReal._usuarioInserto:
                                    if (drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                    {
                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              drPolGarRealXOP[nIndice, DataRowVersion.Current].ToString(),
                                              string.Empty);
                                    }
                                    else
                                    {
                                        oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                                              3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                                              drPolGarRealXOP.Table.Columns[nIndice].ColumnName,
                                              string.Empty,
                                              string.Empty);
                                    }
                                    break;

                                default:

                                    break;
                            }


                        }
                    }

                    #endregion
                }
                else
                {
                    oBitacora.InsertarBitacora("GAR_POLIZAS_RELACIONADAS", strUsuario, strIP, null,
                        3, 2, strGarantia, strOperacionCrediticia, strElimimarPolizasXGarRealXOperacion, string.Empty,
                        string.Empty,
                        string.Empty,
                        string.Empty);
                }


                #endregion Pólizas Relacionadas


                #region Volver a obtener los datos referentes a la garantía real por operación

                dsGarantiaRealXOperacion = ((sentenciaSqlGarantiasXOperacion.Length > 0) ? AccesoBD.ejecutarConsulta(sentenciaSqlGarantiasXOperacion) : null);

                #endregion

                //Si la garantía real por operación ha sido borrada se procede a borrar la garantía real en las tablas 
                //GAR_VALUACIONES_REALES y GAR_GARANTIA_REAL.
                if ((dsGarantiaRealXOperacion == null) || (dsGarantiaRealXOperacion.Tables.Count == 0) || (dsGarantiaRealXOperacion.Tables[0].Rows.Count == 0))
                {
                    listaCampos = new string[] {clsGarantiaReal._entidadValuacionesReales,
                                                clsGarantiaReal._codGarantiaReal, nGarantia.ToString()};

                    string strEliminarValuacionReal = string.Format("DELETE FROM {0} WHERE {1} = {2}", listaCampos);

                    listaCampos = new string[] {clsGarantiaReal._entidadGarantiaReal,
                                                clsGarantiaReal._codGarantiaReal, nGarantia.ToString()};

                    string strEliminarGarantiaReal = string.Format("DELETE FROM {0} WHERE {1} = {2}", listaCampos);

                    if ((dsValuacionesReales != null) && (dsValuacionesReales.Tables.Count > 0) && (dsValuacionesReales.Tables[0].Rows.Count > 0))
                    {
                        #region Garantía Valuación Real

                        foreach (DataRow drValReal in dsValuacionesReales.Tables[0].Rows)
                        {
                            for (int nIndice = 0; nIndice < drValReal.Table.Columns.Count; nIndice++)
                            {
                                switch (drValReal.Table.Columns[nIndice].ColumnName)
                                {

                                    case clsValuacionReal._codGarantiaReal:
                                        oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                               3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                               drValReal.Table.Columns[nIndice].ColumnName,
                                                               strGarantia,
                                                               string.Empty);
                                        break;

                                    case clsValuacionReal._codInspeccionMenorTresMeses:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                      3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                      drValReal.Table.Columns[nIndice].ColumnName,
                                                      oTraductor.TraducirTipoInspeccion3Meses(Convert.ToInt32(drValReal[nIndice, DataRowVersion.Current].ToString())),
                                                      string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                      3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                      drValReal.Table.Columns[nIndice].ColumnName,
                                                      string.Empty,
                                                      string.Empty);
                                        }
                                        break;

                                    case clsValuacionReal._codRecomendacionPerito:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                         3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                         drValReal.Table.Columns[nIndice].ColumnName,
                                                         oTraductor.TraducirTipoRecomendacionPerito(Convert.ToInt32(drValReal[nIndice, DataRowVersion.Current].ToString())),
                                                         string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                         3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                         drValReal.Table.Columns[nIndice].ColumnName,
                                                         string.Empty,
                                                         string.Empty);
                                        }
                                        break;

                                    case clsValuacionReal._montoUltimaTasacionTerreno:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            decimal montoUTT = ((decimal.TryParse(drValReal[nIndice, DataRowVersion.Current].ToString(), out montoUTT)) ? montoUTT : 0);

                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       montoUTT.ToString("N2"),
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }

                                        break;

                                    case clsValuacionReal._montoUltimaTasacionNoTerreno:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            decimal montoUTNT = ((decimal.TryParse(drValReal[nIndice, DataRowVersion.Current].ToString(), out montoUTNT)) ? montoUTNT : 0);

                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       montoUTNT.ToString("N2"),
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }

                                        break;

                                    case clsValuacionReal._montoTasacionActualizadaTerreno:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            decimal montoTAT = ((decimal.TryParse(drValReal[nIndice, DataRowVersion.Current].ToString(), out montoTAT)) ? montoTAT : 0);

                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       montoTAT.ToString("N2"),
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }

                                        break;

                                    case clsValuacionReal._montoTasacionActualizadaNoTerreno:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            decimal montoTANT = ((decimal.TryParse(drValReal[nIndice, DataRowVersion.Current].ToString(), out montoTANT)) ? montoTANT : 0);

                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       montoTANT.ToString("N2"),
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }

                                        break;

                                    case clsValuacionReal._montoTotalAvaluo:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            decimal montoTotalAvaluo = ((decimal.TryParse(drValReal[nIndice, DataRowVersion.Current].ToString(), out montoTotalAvaluo)) ? montoTotalAvaluo : 0);

                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       montoTotalAvaluo.ToString("N2"),
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }

                                        break;


                                    case clsValuacionReal._indicadorAvaluoActualizado:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            bool estadoAlmacenado;
                                            string estado = ((bool.TryParse(drValReal[nIndice, DataRowVersion.Current].ToString(), out estadoAlmacenado)) ? ((estadoAlmacenado) ? "Sí" : "No") : "No");

                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       estado,
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }

                                        break;

                                    case clsValuacionReal._porcentajeAceptacionTerreno:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            decimal porcentajeAT = ((decimal.TryParse(drValReal[nIndice, DataRowVersion.Current].ToString(), out porcentajeAT)) ? ((porcentajeAT >= 0) ? porcentajeAT : 0) : 0);

                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       porcentajeAT.ToString("N2"),
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }

                                        break;

                                    case clsValuacionReal._porcentajeAceptacionNoTerreno:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            decimal porcentajeANT = ((decimal.TryParse(drValReal[nIndice, DataRowVersion.Current].ToString(), out porcentajeANT)) ? ((porcentajeANT >= 0) ? porcentajeANT : 0) : 0);

                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       porcentajeANT.ToString("N2"),
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }

                                        break;

                                    case clsValuacionReal._porcentajeAceptacionTerrenoCalculado:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            decimal porcentajeATC = ((decimal.TryParse(drValReal[nIndice, DataRowVersion.Current].ToString(), out porcentajeATC)) ? ((porcentajeATC >= 0) ? porcentajeATC : 0) : 0);

                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       porcentajeATC.ToString("N2"),
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }

                                        break;

                                    case clsValuacionReal._porcentajeAceptacionNoTerrenoCalculado:
                                        if (drValReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            decimal porcentajeANTC = ((decimal.TryParse(drValReal[nIndice, DataRowVersion.Current].ToString(), out porcentajeANTC)) ? ((porcentajeANTC >= 0) ? porcentajeANTC : 0) : 0);

                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       porcentajeANTC.ToString("N2"),
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                                       drValReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }

                                        break;

                                    default:
                                        oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                                         3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                                         drValReal.Table.Columns[nIndice].ColumnName,
                                         drValReal[nIndice, DataRowVersion.Current].ToString(),
                                         string.Empty);
                                        break;
                                }


                            }
                        }

                        #endregion
                    }
                    else
                    {
                        oBitacora.InsertarBitacora("GAR_VALUACIONES_REALES", strUsuario, strIP, null,
                            3, 2, strGarantia, strOperacionCrediticia, strEliminarValuacionReal, string.Empty,
                            string.Empty,
                            string.Empty,
                            string.Empty);
                    }

                    if ((dsGarantiaReal != null) && (dsGarantiaReal.Tables.Count > 0) && (dsGarantiaReal.Tables[0].Rows.Count > 0))
                    {
                        #region Garantía Real

                        foreach (DataRow drGarReal in dsGarantiaReal.Tables[0].Rows)
                        {
                            for (int nIndice = 0; nIndice < drGarReal.Table.Columns.Count; nIndice++)
                            {
                                switch (drGarReal.Table.Columns[nIndice].ColumnName)
                                {

                                    case clsGarantiaReal._codClaseGarantia:
                                        if (drGarReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                  3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                  drGarReal.Table.Columns[nIndice].ColumnName,
                                                  oTraductor.TraducirClaseGarantia(Convert.ToInt32(drGarReal[nIndice, DataRowVersion.Current].ToString())),
                                                  string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                  3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                  drGarReal.Table.Columns[nIndice].ColumnName,
                                                  string.Empty,
                                                  string.Empty);
                                        }
                                        break;

                                    case clsGarantiaReal._codGarantiaReal:
                                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                  3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                  drGarReal.Table.Columns[nIndice].ColumnName,
                                                  strGarantia,
                                                  string.Empty);
                                        break;

                                    case clsGarantiaReal._codTipoBien:
                                        if (drGarReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                       drGarReal.Table.Columns[nIndice].ColumnName,
                                                       oTraductor.TraducirTipoBien(Convert.ToInt32(drGarReal[nIndice, DataRowVersion.Current].ToString())),
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                       drGarReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }
                                        break;

                                    case clsGarantiaReal._codTipoGarantia:
                                        if (drGarReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                     3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                     drGarReal.Table.Columns[nIndice].ColumnName,
                                                     oTraductor.TraducirTipoGarantia(Convert.ToInt32(drGarReal[nIndice, DataRowVersion.Current].ToString())),
                                                     string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                     3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                     drGarReal.Table.Columns[nIndice].ColumnName,
                                                     string.Empty,
                                                     string.Empty);
                                        }
                                        break;


                                    case clsGarantiaReal._codTipoGarantiaReal:
                                        if (drGarReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                    3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                    drGarReal.Table.Columns[nIndice].ColumnName,
                                                    oTraductor.TraducirTipoGarantiaReal(Convert.ToInt32(drGarReal[nIndice, DataRowVersion.Current].ToString())),
                                                    string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                    3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                    drGarReal.Table.Columns[nIndice].ColumnName,
                                                    string.Empty,
                                                    string.Empty);
                                        }
                                        break;

                                    case clsGarantiaReal._indicadorViviendaHabitadaDeudor:
                                        if (drGarReal[nIndice, DataRowVersion.Current].ToString() != string.Empty)
                                        {
                                            bool estadoAlmacenado;
                                            string estado = ((bool.TryParse(drGarReal[nIndice, DataRowVersion.Current].ToString(), out estadoAlmacenado)) ? ((estadoAlmacenado) ? "Sí" : "No") : "No");

                                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                       drGarReal.Table.Columns[nIndice].ColumnName,
                                                       estado,
                                                       string.Empty);
                                        }
                                        else
                                        {
                                            oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                                       3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                                       drGarReal.Table.Columns[nIndice].ColumnName,
                                                       string.Empty,
                                                       string.Empty);
                                        }

                                        break;

                                    default:
                                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                                         3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                                         drGarReal.Table.Columns[nIndice].ColumnName,
                                         drGarReal[nIndice, DataRowVersion.Current].ToString(),
                                         string.Empty);
                                        break;
                                }
                            }
                        }

                        #endregion
                    }
                    else
                    {
                        oBitacora.InsertarBitacora("GAR_GARANTIA_REAL", strUsuario, strIP, null,
                            3, 2, strGarantia, strOperacionCrediticia, strEliminarGarantiaReal, string.Empty,
                            string.Empty,
                            string.Empty,
                            string.Empty);
                    }

                }

                #endregion
            }
            catch (SqlException ex)
            {
                string errorBD = string.Format("Código del Error: {0}, Descripción del error: {1}", ex.ErrorCode.ToString(), ex.Message);
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ELIMINANDO_GARANTIA_DETALLE, identifiacionGarantia, errorBD, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                throw ex;
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ELIMINANDO_GARANTIA_DETALLE, identifiacionGarantia, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                throw ex;
            }
        }

        /// <summary>
        /// Método que obtiene el listado de las garantías reales asociadas a una operación o contrato
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
                        oComando = new SqlCommand("pa_ObtenerGarantiasRealesOperaciones", oConexion);
                        break;
                    case ((int)Enumeradores.Tipos_Operaciones.Contrato):
                        oComando = new SqlCommand("pa_ObtenerGarantiasRealesContratos", oConexion);
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
        /// Permite obtener la información de una garantía especfica, así como las posibles inconsistencias que posea.
        /// </summary>
        /// <param name="idOperacion">Consecutivo de la operación de la cual se obtendrá la garantía</param>
        /// <param name="idGarantia">Consecutivo de la garantía de la cual se requiere la información</param>
        /// <param name="desOperacion">Número de operación, bajo el formato Contabilidad - Oficina - Moneda - Producto - Núm. Operación / Núm. Contrato</param>
        /// <param name="desGarantia">Número de garantía, bajo el formato Partido - Finca / Clase - Placa</param>
        /// <param name="identificacionUsuario">Identificación del usuario que realiza la consulta</param>
        /// <returns>Entidad del tipo clsGarantiaReal, con los datos de la garanta consultada</returns>
        public clsGarantiaReal ObtenerDatosGarantiaReal(long idOperacion, long idGarantia, string desOperacion, string desGarantia,
                                                        string identificacionUsuario, int annosCalculoPrescripcion)
        {
            clsGarantiaReal entidadGarantiaReal = new clsGarantiaReal();
            string tramaGarantiaReal = string.Empty;

            //Se realiza la consulta a la base de datos
            if ((idOperacion > 0) && (idGarantia > 0))
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piOperacion", SqlDbType.BigInt),
                        new SqlParameter("piGarantia", SqlDbType.BigInt),
                        new SqlParameter("psCedula_Usuario", SqlDbType.VarChar, 30),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = idOperacion;
                    parameters[1].Value = idGarantia;
                    parameters[2].Value = identificacionUsuario;
                    parameters[3].Value = null;
                    parameters[3].Direction = ParameterDirection.Output;


                    SqlParameter[] parametrosSalida = new SqlParameter[] { };

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        tramaGarantiaReal = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Consultar_Garantia_Real", out parametrosSalida, parameters);

                        oConexion.Close();
                        oConexion.Dispose();
                    }
                }
                catch (Exception ex)
                {
                    entidadGarantiaReal.ErrorDatos = true;
                    entidadGarantiaReal.DescripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, desGarantia, desOperacion, Mensajes.ASSEMBLY);

                    StringCollection parametros = new StringCollection();
                    parametros.Add(desGarantia);
                    parametros.Add(desOperacion);
                    parametros.Add(("El error se da al obtener la información de la base de datos: " + ex.Message));

                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS_DETALLE, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    tramaGarantiaReal = string.Empty;
                }
            }

            if (tramaGarantiaReal.Length > 0)
            {
                entidadGarantiaReal = new clsGarantiaReal(tramaGarantiaReal, desOperacion);
            }

            return entidadGarantiaReal;
        }

        /// <summary>
        /// Obtiene la lista de catálogos del mantenimiento de garantías reales
        /// </summary>
        /// <param name="listaCatalogosGarantiaReales">Lista de los catálogos que se deben obtener. La lista debe iniciar y finalizar con el 
        ///                                            caracter "|", así mismo, los valores deben ir separados por dicho caracter.
        /// </param>
        /// <returns>Enditad del tipo catálogos</returns>
        public clsCatalogos<clsCatalogo> ObtenerCatalogos(string listaCatalogosGarantiaReales)
        {
            clsCatalogos<clsCatalogo> entidadCatalogos = null;

            string tramaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (listaCatalogosGarantiaReales.Length > 0)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("psListaCatalogos", SqlDbType.VarChar, 150),
                    };

                    parameters[0].Value = listaCatalogosGarantiaReales;

                    SqlParameter[] parametrosSalida = new SqlParameter[] { };

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        tramaObtenida = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "pa_ObtenerCatalogos", out parametrosSalida, parameters);

                        oConexion.Close();
                        oConexion.Dispose();
                    }
                }
                catch (Exception ex)
                {
                    entidadCatalogos = new clsCatalogos<clsCatalogo>();

                    entidadCatalogos.ErrorDatos = true;
                    entidadCatalogos.DescripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS, Mensajes.ASSEMBLY);

                    string desError = "Error al obtener la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS_DETALLE, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    tramaObtenida = string.Empty;
                }
            }

            if (tramaObtenida.Length > 0)
            {
                entidadCatalogos = new clsCatalogos<clsCatalogo>(tramaObtenida);
            }

            return entidadCatalogos;
        }

        /// <summary>
        /// Obtiene la lista de valuadores del mantenimiento de garantías reales
        /// </summary>
        /// <param name="tipoValuador">Tipo de valuador del cual se obtendrán lo datos</param>
        /// <returns>Enditad del tipo valuadores</returns>
        public clsValuadores<clsValuador> ObtenerValuadores(Enumeradores.TiposValuadores tipoValuador)
        {
            clsValuadores<clsValuador> entidadValuadores = null;

            string tramaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            int indicadorTipoValuador = -1;

            string descripcionTipoValuador = "los valuadores";

            switch (tipoValuador)
            {
                case Enumeradores.TiposValuadores.Perito: indicadorTipoValuador = 1; descripcionTipoValuador = "los peritos";
                    break;
                case Enumeradores.TiposValuadores.Empresa: indicadorTipoValuador = 0; descripcionTipoValuador = "las empresas valuadoras";
                    break;
                default:
                    break;
            }

            if (indicadorTipoValuador != -1)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] { 
                        new SqlParameter("piTipoValuador", SqlDbType.TinyInt),
                        new SqlParameter("piDatosCompletos", SqlDbType.Bit),
                        new SqlParameter("psRespuesta", SqlDbType.VarChar, 1000)
                    };

                    parameters[0].Value = indicadorTipoValuador;
                    parameters[1].Value = 0; //Indica que se obtenedrá la lista de valuadores, bajo el formato cédula - nombre completo
                    parameters[2].Direction = ParameterDirection.Output;

                    SqlParameter[] parametrosSalida = new SqlParameter[] { };

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        tramaObtenida = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "Obtener_Valuadores", out parametrosSalida, parameters);

                        oConexion.Close();
                        oConexion.Dispose();
                    }
                }
                catch (Exception ex)
                {
                    entidadValuadores = new clsValuadores<clsValuador>();

                    entidadValuadores.ErrorDatos = true;
                    entidadValuadores.DescripcionError = Mensajes.Obtener(Mensajes._errorCargaListaValuadores, descripcionTipoValuador, Mensajes.ASSEMBLY);

                    string desError = "El error se da al cargar los datos del valuador: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaListaValuadoresDetalle, descripcionTipoValuador, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    tramaObtenida = string.Empty;
                }
            }

            if (tramaObtenida.Length > 0)
            {
                entidadValuadores = new clsValuadores<clsValuador>(tramaObtenida, tipoValuador);
            }

            return entidadValuadores;
        }

        /// <summary>
        /// Se encarga de ejecuta el proceso de normalización de algunos datos de la garantía a todos aquellos registros que sean de la misma finca o prenda.
        /// Siebel 1-24206841. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 24/03/2014.
        /// </summary>
        /// <param name="datosGarantiaReal">Contenedor de la información del a garantía y del avalúo</param>
        /// <param name="strUsuario">Usuario que realiza la acción</param>
        /// <param name="strIP">IP de la máquina desde donde se realzia el ajuste</param>
        /// <param name="strOperacionCrediticia">Código de la operación, bajo el formato oficina-moneda-producto-operación/contrato</param>
        /// <param name="strGarantia">Código del bien, bajo el formato Partido/Clase de bien – Finca/Placa)</param>
        public void NormalizarDatosGarantiaReal(clsGarantiaReal datosGarantiaReal, string strUsuario, string strIP,
                              string strOperacionCrediticia, string strGarantia)
        {
            #region Ejemplo Trama Retornada

            //<RESPUESTA>
            //    <CODIGO>0</CODIGO>
            //    <NIVEL></NIVEL>
            //    <ESTADO></ESTADO>
            //    <PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>
            //    <LINEA></LINEA>
            //    <MENSAJE>La replicación de avalúos ha sido satisfactoria.</MENSAJE>
            //    <DETALLE></DETALLE>
            //</RESPUESTA>
            #endregion Ejemplo Trama Retornada

            string respuestaObtenida = string.Empty;
            string detalleError = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };
            StringBuilder sbOperacionesSinNormalizar = new StringBuilder();
            bool errorReplica = false;
            clsGarantiaReal entidadGarantiaReal = new clsGarantiaReal();
            string tramaGarantiaReal = string.Empty;
            clsGarantiaReal garantiaRealNormalizar = null;
           
            if (datosGarantiaReal != null)
            {
                foreach (clsOperacionCrediticia GarOperActualizar in datosGarantiaReal.OperacionesRelacionadas)
                {
                    try
                    {
                        int annosCalculoPrescripcion = (datosGarantiaReal.FechaPrescripcion.Year - datosGarantiaReal.FechaVencimiento.Year);
                        garantiaRealNormalizar = ObtenerDatosGarantiaReal(GarOperActualizar.CodigoOperacion, GarOperActualizar.CodigoGarantia, GarOperActualizar.ToString(false), strGarantia, strUsuario, annosCalculoPrescripcion);
                    }
                    catch (Exception ex)
                    {
                        errorReplica = true;

                        detalleError = "Operación: " + GarOperActualizar.ToString(true) + ex.Message;

                        if (!sbOperacionesSinNormalizar.ToString().Contains(GarOperActualizar.ToString(true)))
                        {
                            sbOperacionesSinNormalizar.Append(GarOperActualizar.ToString(true));
                        }

                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorNormalizandoAvaluoDetalle, strGarantia, detalleError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    }

                    //Se revisa que la entidad haya sido creada
                    if (garantiaRealNormalizar != null)
                    {
                        //Se establecen los datos de la operación que será normalizada
                        garantiaRealNormalizar.Contabilidad = GarOperActualizar.Contabilidad;
                        garantiaRealNormalizar.Oficina = GarOperActualizar.Oficina;
                        garantiaRealNormalizar.MonedaOper = GarOperActualizar.Moneda;
                        garantiaRealNormalizar.Producto = GarOperActualizar.Producto;
                        garantiaRealNormalizar.NumeroOperacion = GarOperActualizar.Operacion;
                        garantiaRealNormalizar.TipoOperacion = GarOperActualizar.TipoOperacion;

                        //Se procede a modificar la información de la garantía y la relación de esta con la operación/contrato
                        garantiaRealNormalizar.CodTipoBien = datosGarantiaReal.CodTipoBien;
                        garantiaRealNormalizar.CodTipoMitigador = datosGarantiaReal.CodTipoMitigador;
                        garantiaRealNormalizar.ListaDescripcionValoresActualesCombos = datosGarantiaReal.ListaDescripcionValoresActualesCombos;

                        //Se procede a modificar la información del avalúo de la garantía
                        garantiaRealNormalizar.FechaValuacion = datosGarantiaReal.FechaValuacion;
                        garantiaRealNormalizar.FechaUltimoSeguimiento = datosGarantiaReal.FechaUltimoSeguimiento;
                        garantiaRealNormalizar.FechaConstruccion = datosGarantiaReal.FechaConstruccion;
                        garantiaRealNormalizar.MontoUltimaTasacionTerreno = datosGarantiaReal.MontoUltimaTasacionTerreno;
                        garantiaRealNormalizar.MontoUltimaTasacionNoTerreno = datosGarantiaReal.MontoUltimaTasacionNoTerreno;
                        garantiaRealNormalizar.MontoTasacionActualizadaTerreno = datosGarantiaReal.MontoTasacionActualizadaTerreno;
                        garantiaRealNormalizar.MontoTasacionActualizadaNoTerreno = datosGarantiaReal.MontoTasacionActualizadaNoTerreno;
                        garantiaRealNormalizar.MontoTotalAvaluo = datosGarantiaReal.MontoTotalAvaluo;
                        garantiaRealNormalizar.CedulaPerito = datosGarantiaReal.CedulaPerito;
                        garantiaRealNormalizar.CedulaEmpresa = datosGarantiaReal.CedulaEmpresa;
                        garantiaRealNormalizar.AvaluoActualizado = datosGarantiaReal.AvaluoActualizado;
                        garantiaRealNormalizar.FechaSemestreCalculado = datosGarantiaReal.FechaSemestreCalculado;

                        //RQ_MANT_2015062410418218_00025 Requerimiento Segmentación Campos Porcentaje Aceptación Terreno y No Terreno
                        garantiaRealNormalizar.PorcentajeAceptacionTerreno = datosGarantiaReal.PorcentajeAceptacionTerreno;
                        garantiaRealNormalizar.PorcentajeAceptacionNoTerreno = datosGarantiaReal.PorcentajeAceptacionNoTerreno;
                        garantiaRealNormalizar.PorcentajeAceptacionTerrenoCalculado = datosGarantiaReal.PorcentajeAceptacionTerrenoCalculado;
                        garantiaRealNormalizar.PorcentajeAceptacionNoTerrenoCalculado = datosGarantiaReal.PorcentajeAceptacionNoTerrenoCalculado;

                        //Se desliga cualquier póliza.
                        garantiaRealNormalizar.PolizaSapAsociada = null;

                       //Se procede a modificar la información de la póliza, sólo si dicha póliza está asociada a la operación replicada
                       List <clsPolizaSap> listaPolizas = garantiaRealNormalizar.PolizasSap.ObtenerPolizasPorTipoBien(garantiaRealNormalizar.CodTipoBien);

                        if ((listaPolizas != null) && (listaPolizas.Count > 0))
                        {
                            foreach (clsPolizaSap polizaSap in listaPolizas)
                            {
                                if (datosGarantiaReal.PolizaSapAsociada != null)
                                {
                                    if (polizaSap.CodigoPolizaSap == datosGarantiaReal.PolizaSapAsociada.CodigoPolizaSap)
                                    {
                                        garantiaRealNormalizar.PolizaSapAsociada = datosGarantiaReal.PolizaSapAsociada;
                                        break;
                                    }
                                }
                            }
                        }

                        //Se utilizan los mismos datos las pistas de auditoria 
                        garantiaRealNormalizar.UsuarioModifico = strUsuario;
                        garantiaRealNormalizar.FechaModifico = DateTime.Today;
                        garantiaRealNormalizar.FechaInserto = DateTime.Today;

                        //Se procede a modificar la operación respaldada por la garantía
                        procesoNormalizacion = true;

                        try
                        {
                            Modificar(garantiaRealNormalizar, strUsuario, strIP, strOperacionCrediticia, strGarantia);
                        }
                        catch (Exception ex)
                        {
                            errorReplica = true;

                            detalleError = "Operación: " + GarOperActualizar.ToString(true) + ex.Message;

                            if (!sbOperacionesSinNormalizar.ToString().Contains(GarOperActualizar.ToString(true)))
                            {
                                sbOperacionesSinNormalizar.Append(GarOperActualizar.ToString(true));
                            }

                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorNormalizandoAvaluoDetalle, strGarantia, detalleError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                        }
                    }
                }

                if (errorReplica)
                {
                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorNormalizandoAvaluo, sbOperacionesSinNormalizar.ToString(), Mensajes.ASSEMBLY));
                }
            }
        }

        #endregion
    }
}
