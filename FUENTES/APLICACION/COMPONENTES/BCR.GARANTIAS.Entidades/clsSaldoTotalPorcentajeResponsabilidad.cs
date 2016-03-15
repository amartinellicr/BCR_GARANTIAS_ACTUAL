﻿using System;
using System.Data;
using System.Text;

using BCR.GARANTIAS.Comun;


namespace BCR.GARANTIAS.Entidades
{
    [Serializable]
    public class clsSaldoTotalPorcentajeResponsabilidad
    {
        #region Constantes

        //Nombre tablas
        public const string _entidadSaldoTotalPorcentajeResp = "GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD";

        //Campos
        public const string _consecutivoOperacion               = "Consecutivo_Operacion";
        public const string _consecutivoGarantia                = "Consecutivo_Garantia";
        public const string _codigoTipoGarantia                 = "Codigo_Tipo_Garantia";
        public const string _saldoActual                        = "Saldo_Actual";
        public const string _cuentaContable                     = "Cuenta_Contable";
        public const string _tipoOperacion                      = "Tipo_Operacion";
        public const string _codigoTipoOperacion                = "Codigo_Tipo_Operacion";
        public const string _operacionLarga                     = "Operacion_Larga";
        public const string _saldoActualAjustado                = "Saldo_Actual_Ajustado";
        public const string _porcentajeResponsabilidadAjustado  = "Porcentaje_Responsabilidad_Ajustado";
        public const string _indicadorAjusteSaldoActual         = "Indicador_Ajuste_Saldo_Actual";
        public const string _indicadorAjustePorcentaje          = "Indicador_Ajuste_Porcentaje";
        public const string _indicadorExcluido                  = "Indicador_Excluido";

        //ADICIONALES
        public const string _indicadorCuentaContableEspecial    = "IndicadorCuentaContableEspecial";
        public const string _identificacionGarantia             = "IdentificacionGarantia";
        public const string _indicadorAjusteCampoSaldo          = "Indicador_Ajuste_Campo_Saldo";
        public const string _indicadorAjusteCampoPorcentaje     = "Indicador_Ajuste_Campo_Porcentaje";
        public const string _porcentajeResponsabilidadCalculado = "PorcentajeResponsabilidadCalculado";


        #endregion Constantes

        #region Propiedades

        public long ConsecutivoOperacion { get; set; }
        public long ConsecutivoGarantia { get; set; }
        public short CodigoTipoGarantia { get; set; }
        public decimal SaldoActual { get; set; }
        public short CuentaContable { get; set; }
        public string TipoOperacion { get; set; }
        public Enumeradores.Tipos_Operaciones CodigoTipoOperacion { get; set; }
        public string OperacionLarga { get; set; }
        public decimal SaldoActualAjustado { get; set; }
        public decimal PorcentajeResponsabilidadAjustado { get; set; }
        public bool IndicadorAjusteSaldoActual { get; set; }
        public bool IndicadorAjustePorcentaje { get; set; }
        public bool IndicadorExcluido { get; set; }
        public bool IndicadorCuentaContableEspecial { get { return (((CuentaContable == 814) || (CuentaContable == 619)) ? true : false); } }
        public string IdentificacionGarantia { get; set; }
        public bool IndicadorAjusteCampoSaldo { get; set; }
        public bool IndicadorAjusteCampoPorcentaje { get; set; }
        public decimal PorcentajeResponsabilidadCalculado { get; set; }
        

        #endregion Propiedades

        #region Constructores

        /// <summary>
        /// Constructor básico de la clase
        /// </summary>
        public clsSaldoTotalPorcentajeResponsabilidad()
        {
            ConsecutivoOperacion = -1;
            ConsecutivoGarantia = -1;
            CodigoTipoGarantia = ((short)-1);
            SaldoActual = 0;
            CuentaContable = ((short) -1);
            TipoOperacion = string.Empty;
            CodigoTipoOperacion = Enumeradores.Tipos_Operaciones.Ninguno;
            OperacionLarga = string.Empty;
            SaldoActualAjustado = -1;
            PorcentajeResponsabilidadAjustado = -1;
            IndicadorAjusteSaldoActual = false;
            IndicadorAjustePorcentaje = false;
            IndicadorExcluido = false;
            IndicadorAjusteCampoSaldo = false;
            IndicadorAjusteCampoPorcentaje = false;
            IdentificacionGarantia = string.Empty;
            PorcentajeResponsabilidadCalculado = -1;
        }

        /// <summary>
        /// Constructor de la clase que carga los datos suministrados
        /// </summary>
        /// <param name="datosCargar">Contiene la información que será cargada en la entidad</param>
        public clsSaldoTotalPorcentajeResponsabilidad(DataSet datosCargar)
        {
            #region Inicialización

            ConsecutivoOperacion = -1;
            ConsecutivoGarantia = -1;
            CodigoTipoGarantia = ((short)-1);
            SaldoActual = 0;
            CuentaContable = ((short)-1);
            TipoOperacion = string.Empty;
            CodigoTipoOperacion = Enumeradores.Tipos_Operaciones.Ninguno;
            OperacionLarga = string.Empty;
            SaldoActualAjustado = -1;
            PorcentajeResponsabilidadAjustado = -1;
            IndicadorAjusteSaldoActual = false;
            IndicadorAjustePorcentaje = false;
            IndicadorExcluido = false;
            IndicadorAjusteCampoSaldo = false;
            IndicadorAjusteCampoPorcentaje = false;
            IdentificacionGarantia = string.Empty;
            PorcentajeResponsabilidadCalculado = -1;

            #endregion Inicialización

            #region Carga de Datos

            //Se verfica que existan datos
            if ((datosCargar != null) && (datosCargar.Tables.Count > 0) && (datosCargar.Tables[0].Rows.Count > 0))
            {
                long consecutivoOperacion;
                long consecutivoGarantia;
                decimal saldoActual;
                decimal saldoActualAjustado;
                decimal porcentajeResponsabilidadAjustado;
                decimal porcentajeResponsabilidadCalculado;
                short cuentaContable;
                short codigoTipoGarantia;
                int codigoTipoOperacion;
                
                
                ConsecutivoOperacion = ((!datosCargar.Tables[0].Rows[0].IsNull(_consecutivoOperacion) && (long.TryParse(datosCargar.Tables[0].Rows[0][_consecutivoOperacion].ToString(), out consecutivoOperacion))) ? consecutivoOperacion : ((long) -1));
                ConsecutivoGarantia = ((!datosCargar.Tables[0].Rows[0].IsNull(_consecutivoGarantia) && (long.TryParse(datosCargar.Tables[0].Rows[0][_consecutivoGarantia].ToString(), out consecutivoGarantia))) ? consecutivoGarantia : ((long)-1));

                SaldoActual = ((!datosCargar.Tables[0].Rows[0].IsNull(_saldoActual) && (decimal.TryParse(datosCargar.Tables[0].Rows[0][_saldoActual].ToString(), out saldoActual))) ? saldoActual : 0);
                SaldoActualAjustado = ((!datosCargar.Tables[0].Rows[0].IsNull(_saldoActualAjustado) && (decimal.TryParse(datosCargar.Tables[0].Rows[0][_saldoActualAjustado].ToString(), out saldoActualAjustado))) ? saldoActualAjustado : -1);
                PorcentajeResponsabilidadAjustado = ((!datosCargar.Tables[0].Rows[0].IsNull(_porcentajeResponsabilidadAjustado) && (decimal.TryParse(datosCargar.Tables[0].Rows[0][_porcentajeResponsabilidadAjustado].ToString(), out porcentajeResponsabilidadAjustado))) ? porcentajeResponsabilidadAjustado : -1);
                PorcentajeResponsabilidadCalculado = ((!datosCargar.Tables[0].Rows[0].IsNull(_porcentajeResponsabilidadCalculado) && (decimal.TryParse(datosCargar.Tables[0].Rows[0][_porcentajeResponsabilidadCalculado].ToString(), out porcentajeResponsabilidadCalculado))) ? porcentajeResponsabilidadCalculado : -1);

                CuentaContable = ((!datosCargar.Tables[0].Rows[0].IsNull(_cuentaContable) && (short.TryParse(datosCargar.Tables[0].Rows[0][_cuentaContable].ToString(), out cuentaContable))) ? cuentaContable : ((short)-1));
                CodigoTipoGarantia = ((!datosCargar.Tables[0].Rows[0].IsNull(_codigoTipoGarantia) && (short.TryParse(datosCargar.Tables[0].Rows[0][_codigoTipoGarantia].ToString(), out codigoTipoGarantia))) ? codigoTipoGarantia : ((short)-1));

                CodigoTipoOperacion = ((!datosCargar.Tables[0].Rows[0].IsNull(_codigoTipoOperacion) && (int.TryParse(datosCargar.Tables[0].Rows[0][_codigoTipoOperacion].ToString(), out codigoTipoOperacion))) ? ((Enumeradores.Tipos_Operaciones) codigoTipoOperacion) : Enumeradores.Tipos_Operaciones.Ninguno);
                
                IndicadorAjusteSaldoActual = ((!datosCargar.Tables[0].Rows[0].IsNull(_indicadorAjusteSaldoActual) && (datosCargar.Tables[0].Rows[0][_indicadorAjusteSaldoActual].ToString().CompareTo("0") == 0)) ? false : true);
                IndicadorAjustePorcentaje = ((!datosCargar.Tables[0].Rows[0].IsNull(_indicadorAjustePorcentaje) && (datosCargar.Tables[0].Rows[0][_indicadorAjustePorcentaje].ToString().CompareTo("0") == 0)) ? false : true);
                IndicadorExcluido = ((!datosCargar.Tables[0].Rows[0].IsNull(_indicadorExcluido) && (datosCargar.Tables[0].Rows[0][_operacionLarga].ToString().CompareTo("0") == 0)) ? false : true);


                TipoOperacion = ((!datosCargar.Tables[0].Rows[0].IsNull(_tipoOperacion)) ? datosCargar.Tables[0].Rows[0][_tipoOperacion].ToString() : string.Empty);
                OperacionLarga = ((!datosCargar.Tables[0].Rows[0].IsNull(_operacionLarga)) ? datosCargar.Tables[0].Rows[0][_operacionLarga].ToString() : string.Empty);
                                
            }


            #endregion Carga de Datos
        }

        /// <summary>
        /// Constructor de la clase que carga los datos suministrados
        /// </summary>
        /// <param name="datosCargar">Contiene la información que será cargada en la entidad</param>
        public clsSaldoTotalPorcentajeResponsabilidad(DataRow datosCargar)
        {
            #region Inicialización

            ConsecutivoOperacion = -1;
            ConsecutivoGarantia = -1;
            CodigoTipoGarantia = ((short)-1);
            SaldoActual = 0;
            CuentaContable = ((short)-1);
            TipoOperacion = string.Empty;
            CodigoTipoOperacion = Enumeradores.Tipos_Operaciones.Ninguno;
            OperacionLarga = string.Empty;
            SaldoActualAjustado = -1;
            PorcentajeResponsabilidadAjustado = -1;
            IndicadorAjusteSaldoActual = false;
            IndicadorAjustePorcentaje = false;
            IndicadorExcluido = false;
            IndicadorAjusteCampoSaldo = false;
            IndicadorAjusteCampoPorcentaje = false;
            IdentificacionGarantia = string.Empty;
            PorcentajeResponsabilidadCalculado = -1;

            #endregion Inicialización

            #region Carga de Datos

            //Se verfica que existan datos
            if (datosCargar != null) 
            {
                long consecutivoOperacion;
                long consecutivoGarantia;
                decimal saldoActual;
                decimal saldoActualAjustado;
                decimal porcentajeResponsabilidadAjustado;
                decimal porcentajeResponsabilidadCalculado;
                short cuentaContable;
                short codigoTipoGarantia;
                int codigoTipoOperacion;


                ConsecutivoOperacion = ((!datosCargar.IsNull(_consecutivoOperacion) && (long.TryParse(datosCargar[_consecutivoOperacion].ToString(), out consecutivoOperacion))) ? consecutivoOperacion : ((long)-1));
                ConsecutivoGarantia = ((!datosCargar.IsNull(_consecutivoGarantia) && (long.TryParse(datosCargar[_consecutivoGarantia].ToString(), out consecutivoGarantia))) ? consecutivoGarantia : ((long)-1));

                SaldoActual = ((!datosCargar.IsNull(_saldoActual) && (decimal.TryParse(datosCargar[_saldoActual].ToString(), out saldoActual))) ? saldoActual : 0);
                SaldoActualAjustado = ((!datosCargar.IsNull(_saldoActualAjustado) && (decimal.TryParse(datosCargar[_saldoActualAjustado].ToString(), out saldoActualAjustado))) ? saldoActualAjustado : -1);
                PorcentajeResponsabilidadAjustado = ((!datosCargar.IsNull(_porcentajeResponsabilidadAjustado) && (decimal.TryParse(datosCargar[_porcentajeResponsabilidadAjustado].ToString(), out porcentajeResponsabilidadAjustado))) ? porcentajeResponsabilidadAjustado : -1);
                PorcentajeResponsabilidadCalculado = ((!datosCargar.IsNull(_porcentajeResponsabilidadCalculado) && (decimal.TryParse(datosCargar[_porcentajeResponsabilidadCalculado].ToString(), out porcentajeResponsabilidadCalculado))) ? porcentajeResponsabilidadCalculado : -1);


                CuentaContable = ((!datosCargar.IsNull(_cuentaContable) && (short.TryParse(datosCargar[_cuentaContable].ToString(), out cuentaContable))) ? cuentaContable : ((short)-1));
                CodigoTipoGarantia = ((!datosCargar.IsNull(_codigoTipoGarantia) && (short.TryParse(datosCargar[_codigoTipoGarantia].ToString(), out codigoTipoGarantia))) ? codigoTipoGarantia : ((short)-1));

                CodigoTipoOperacion = ((!datosCargar.IsNull(_codigoTipoOperacion) && (int.TryParse(datosCargar[_codigoTipoOperacion].ToString(), out codigoTipoOperacion))) ? ((Enumeradores.Tipos_Operaciones)codigoTipoOperacion) : Enumeradores.Tipos_Operaciones.Ninguno);

                IndicadorAjusteSaldoActual = ((!datosCargar.IsNull(_indicadorAjusteSaldoActual) && (datosCargar[_indicadorAjusteSaldoActual].ToString().CompareTo("0") == 0)) ? false : true);
                IndicadorAjustePorcentaje = ((!datosCargar.IsNull(_indicadorAjustePorcentaje) && (datosCargar[_indicadorAjustePorcentaje].ToString().CompareTo("0") == 0)) ? false : true);
                IndicadorExcluido = ((!datosCargar.IsNull(_indicadorExcluido) && (datosCargar[_operacionLarga].ToString().CompareTo("0") == 0)) ? false : true);


                TipoOperacion = ((!datosCargar.IsNull(_tipoOperacion)) ? datosCargar[_tipoOperacion].ToString() : string.Empty);
                OperacionLarga = ((!datosCargar.IsNull(_operacionLarga)) ? datosCargar[_operacionLarga].ToString() : string.Empty);

            }


            #endregion Carga de Datos
        }

        /// <summary>
        /// Constructor de la clase que carga los datos suministrados
        /// </summary>
        /// <param name="datosCargar">Contiene la información que será cargada en la entidad</param>
        public clsSaldoTotalPorcentajeResponsabilidad(string datosCargar)
        {
            #region Inicialización

            ConsecutivoOperacion = -1;
            ConsecutivoGarantia = -1;
            CodigoTipoGarantia = ((short)-1);
            SaldoActual = 0;
            CuentaContable = ((short)-1);
            TipoOperacion = string.Empty;
            CodigoTipoOperacion = Enumeradores.Tipos_Operaciones.Ninguno;
            OperacionLarga = string.Empty;
            SaldoActualAjustado = -1;
            PorcentajeResponsabilidadAjustado = -1;
            IndicadorAjusteSaldoActual = false;
            IndicadorAjustePorcentaje = false;
            IndicadorExcluido = false;
            IndicadorAjusteCampoSaldo = false;
            IndicadorAjusteCampoPorcentaje = false;
            IdentificacionGarantia = string.Empty;
            PorcentajeResponsabilidadCalculado = -1;

            #endregion Inicialización

            #region Carga de Datos

            //Se verfica que existan datos
            if ((datosCargar != null) && (datosCargar.Length > 0))
            {
                long consecutivoOperacion;
                long consecutivoGarantia;
                decimal saldoActual;
                decimal saldoActualAjustado;
                decimal porcentajeResponsabilidadAjustado;
                decimal porcentajeResponsabilidadCalculado;
                short cuentaContable;
                short codigoTipoGarantia;
                int codigoTipoOperacion;


                //Se elimina el caracter inicial y final de la cadena
                string cadenaJSON = datosCargar.Replace("{", string.Empty).Replace("}", string.Empty);

                //Se revisa que tras la eliminación anterior la cadena aún posea caracteres
                if (cadenaJSON.Length > 0)
                {
                    //Se genera el arereglo con cada uno de los pares llave-valor
                    string[] datosFormatoJSON = cadenaJSON.Split(",".ToCharArray());

                    //Se revisa que el arreglo tenga pares
                    if (datosFormatoJSON.Length > 0)
                    {
                        //Se recorre el arrelo generado
                        foreach (string datoJSON in datosFormatoJSON)
                        {
                            //Se genera un nuevo arreglo, esta vez con el valor de la llave y del valor del par evaluado
                            string[] llaveValor = datoJSON.Split(":".ToCharArray());

                            //Se verifica que se haya obtenido el arereglo deseado
                            if (llaveValor.Length == 2)
                            {
                                //En base al valor de la llave, se convierte y se asigna el dato del valor
                                switch ((llaveValor[0].Replace('"', ' ').Trim()))
                                {
                                    case _consecutivoOperacion:
                                        ConsecutivoOperacion = ((long.TryParse(llaveValor[1], out consecutivoOperacion)) ? consecutivoOperacion : -1);
                                        break;
                                    case _consecutivoGarantia:
                                        ConsecutivoGarantia = ((long.TryParse(llaveValor[1], out consecutivoGarantia)) ? consecutivoGarantia : -1);
                                        break;
                                    case _codigoTipoGarantia:
                                        CodigoTipoGarantia = ((short.TryParse(llaveValor[1], out codigoTipoGarantia)) ? codigoTipoGarantia : ((short) -1));
                                        break;
                                    case _saldoActual:
                                        SaldoActual = ((llaveValor[1].CompareTo("null") != 0) && (decimal.TryParse(llaveValor[1], out saldoActual)) ? saldoActual : 0);
                                        break;
                                    case _saldoActualAjustado:
                                        SaldoActualAjustado = ((llaveValor[1].CompareTo("null") != 0) && (decimal.TryParse(llaveValor[1], out saldoActualAjustado)) ? saldoActualAjustado : -1);
                                        break;
                                    case _porcentajeResponsabilidadAjustado:
                                        PorcentajeResponsabilidadAjustado = ((llaveValor[1].CompareTo("null") != 0) && (decimal.TryParse(llaveValor[1], out porcentajeResponsabilidadAjustado)) ? porcentajeResponsabilidadAjustado : -1);
                                        break;
                                    case _cuentaContable:
                                        CuentaContable = ((short.TryParse(llaveValor[1], out cuentaContable)) ? cuentaContable : ((short)-1));
                                        break;
                                    case _codigoTipoOperacion:
                                        CodigoTipoOperacion = ((int.TryParse(llaveValor[1], out codigoTipoOperacion)) ? ((Enumeradores.Tipos_Operaciones) codigoTipoOperacion) : Enumeradores.Tipos_Operaciones.Ninguno);
                                        break;
                                    case _tipoOperacion:
                                        TipoOperacion = llaveValor[1];
                                        break;
                                    case _operacionLarga:
                                        OperacionLarga = llaveValor[1];
                                        break;
                                    case _indicadorAjusteSaldoActual:
                                        IndicadorAjusteSaldoActual = ((llaveValor[1].CompareTo("0") == 0)  ? false : true);
                                        break;
                                    case _indicadorAjustePorcentaje:
                                        IndicadorAjustePorcentaje = ((llaveValor[1].CompareTo("0") == 0) ? false : true);
                                        break;
                                    case _indicadorExcluido:
                                        IndicadorExcluido = ((llaveValor[1].CompareTo("0") == 0) ? false : true);
                                        break;
                                    case _identificacionGarantia:
                                        IdentificacionGarantia = llaveValor[1];
                                        break;
                                    case _indicadorAjusteCampoSaldo:
                                        IndicadorAjusteCampoSaldo = ((llaveValor[1].CompareTo("0") == 0) ? false : true);
                                        break;
                                    case _indicadorAjusteCampoPorcentaje:
                                        IndicadorAjusteCampoPorcentaje = ((llaveValor[1].CompareTo("0") == 0) ? false : true);
                                        break;
                                    case _porcentajeResponsabilidadCalculado:
                                        PorcentajeResponsabilidadCalculado = ((llaveValor[1].CompareTo("null") != 0) && (decimal.TryParse(llaveValor[1], out porcentajeResponsabilidadCalculado)) ? porcentajeResponsabilidadCalculado : -1);
                                        break;
                                    default:
                                        break;
                                }
                            }
                        }
                    }
                }
            }


            #endregion Carga de Datos
        }

        #endregion Constructores

        #region Métodos

        /// <summary>
        /// Método que permite generar el contenido de la clase en formato JSON
        /// </summary>
        /// <returns>Cadena de texto en formato JSON</returns>
        public string ConvertirJSON()
        {
            StringBuilder formatoJSON = new StringBuilder("{");

            formatoJSON.Append('"');
            formatoJSON.Append(_consecutivoOperacion);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(ConsecutivoOperacion.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_consecutivoGarantia);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(ConsecutivoGarantia.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_codigoTipoGarantia);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(CodigoTipoGarantia.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_codigoTipoOperacion);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(CodigoTipoOperacion.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_cuentaContable);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append(CuentaContable.ToString());
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_saldoActual);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(SaldoActual.ToString("N2"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");
            
            formatoJSON.Append('"');
            formatoJSON.Append(_saldoActualAjustado);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(SaldoActualAjustado.ToString("N2"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_porcentajeResponsabilidadAjustado);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(PorcentajeResponsabilidadAjustado.ToString("N2"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_tipoOperacion);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(TipoOperacion);
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_operacionLarga);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(OperacionLarga);
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_indicadorAjusteSaldoActual);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((IndicadorAjusteSaldoActual) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_indicadorAjustePorcentaje);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((IndicadorAjustePorcentaje) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_indicadorExcluido);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((IndicadorExcluido) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_indicadorCuentaContableEspecial);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((IndicadorCuentaContableEspecial) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_indicadorAjusteCampoSaldo);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((IndicadorAjusteCampoSaldo) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_indicadorAjusteCampoPorcentaje);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(((IndicadorAjusteCampoPorcentaje) ? "1" : "0"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_porcentajeResponsabilidadCalculado);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(PorcentajeResponsabilidadCalculado.ToString("N2"));
            formatoJSON.Append('"');
            formatoJSON.Append(",");

            formatoJSON.Append('"');
            formatoJSON.Append(_identificacionGarantia);
            formatoJSON.Append('"');
            formatoJSON.Append(':');
            formatoJSON.Append('"');
            formatoJSON.Append(IdentificacionGarantia);
            formatoJSON.Append('"');


            formatoJSON.Append('}');

            return formatoJSON.ToString();
        }


        #endregion Métodos

    }
}
