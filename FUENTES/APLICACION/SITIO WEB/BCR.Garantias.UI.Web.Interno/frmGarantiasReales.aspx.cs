using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Drawing;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Text;
using System.Threading;
using System.Collections.Specialized;
using System.Collections.Generic;

using BCRGARANTIAS.Datos;
using BCRGARANTIAS.Negocios;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Forms
{
    public partial class frmGarantiasReales : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Constantes

        private const string BLOQUEAR_CAMPO_FECHA_PRESENTACION = "BCFP";
        private const string BLOQUEAR_CAMPO_INDICADOR_INSCRIPCION = "BCII";
        private const string BLOQUEAR_CAMPO_MONTO_MITIGADOR = "BCMM";
        private const string BLOQUEAR_CAMPO_PORCENTAJE_ACEPTACION = "BCPA";
        private const string INDICADOR_BOTON_GUARDAR = "IBG";
        private const string INDICADOR_ERROR_GRAVE = "IEG";
        private const string LLAVE_ENTIDAD_GARANTIA = "LLAVE_ENTIDAD_GARANTIA";
        private const string LLAVE_ENTIDAD_CATALOGOS = "LLAVE_ENTIDAD_CATALOGOS";
        private const string LLAVE_CONSECUTIVO_OPERACION = "LLAVE_CONSECUTIVO_OPERACION";
        private const string LLAVE_CONSECUTIVO_GARANTIA = "LLAVE_CONSECUTIVO_GARANTIA";
        private const string LLAVE_DESCRIPCION_GARANTIA = "LDG";
        private const string LLAVE_DATOS_OPERACION = "LLAVE_DATOS_OPERACION";
        private const string LLAVE_TRAMA_INICIAL = "LLAVE_TRAMA_INICIAL";
        private const string LLAVE_ES_GIRO = "LLAVE_ES_GIRO";
        private const string LLAVE_CONSECUTIVO_CONTRATO = "LLAVE_CONSECUTIVO_CONTRATO";
        private const string LLAVE_TIPO_GARANTIA_REAL = "LLAVE_TIPO_GARANTIA_REAL";
        private const string ANNOS_CALCULO_FECHA_PRESCRIPCION = "ANNOS_CFP";
        private const string BLOQUEAR_CAMPO_FECHA_VENCIMIENTO = "BCFV";
        private const string LLAVE_ENTIDAD_PERITOS = "LLAVE_ENTIDAD_PERITOS";
        private const string LLAVE_ENTIDAD_EMPRESAS = "LLAVE_ENTIDAD_EMPRESAS";
        private const string LLAVE_BLOQUEAR_AVALUOS = "LLAVE_BLOQUEAR_AVALUOS";
        private const string LLAVE_EXISTE_AVALUO = "HAYAVAL";
        private const string LLAVE_MONTO_TOTAL_AVALUO = "MTA";
        private const string LLAVE_MOSTRAR_ERROR_MONTO_MITIGADOR = "MEMM";
        private const string LLAVE_MONTO_MITIGADOR_CALCULADO = "MMC";
        private const string LLAVE_AVALUO_ACTUALIZADO = "AAC";
        private const string LLAVE_FECHA_SEMESTRE_ACTUALIZADO = "FSA";
        private const string LLAVE_HABILITAR_AVALUO = "HAA";
        private const string LLAVE_ERROR_GRAVE_AVALUO = "EGA";
        private const string BLOQUEAR_CAMPOS_MTAT_MTANT = "BCTANT";
        private const string LLAVE_LISTA_OPERACIONES = "LISTAOPER";
        private const string LLAVE_CARGA_INICIAL = "CARGAINICIAL";
        private const string LLAVE_BLOQUEAR_POLIZA = "LLAVE_BLOQUEAR_POLIZA";
        private const string LLAVE_HABILITAR_POLIZA = "HAP";
        private const string LLAVE_FECHA_REPLICA = "LLAVE_FECHA_REPLICA";
        private const string LLAVE_FECHA_MODIFICACION = "LLAVE_FECHA_MODIFICACION";
        private const string LLAVE_LISTA_OPERACIONES_INFRA_SEGURO = "LISTAOPERINFRASEG";
        private const string LLAVE_LISTA_OPER_ACREENCIA_DIF = "LISTAOPERACREDIF";
        private const string LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO = "MOPAC";
        private const string LLAVE_ERROR_INDICADOR_INCONSISTENCIA = "EII";

        private const string LLAVE_ERROR_INCONSISTENCIA_SIN_POLIZA = "EISP";
        private const string LLAVE_ERROR_INCONSISTENCIA_POLIZA_INVALIDA = "EIPI";
        private const string LLAVE_ERROR_INCONSISTENCIA_POLIZA_NO_CUBRE_BIEN = "EIPNCB";

        private const string LLAVE_ERROR_INCONSISTENCIA_FECHA_ULTIMO_SEGUIMIENTO_MAYOR_1ANNO = "EIFUSM";
        private const string LLAVE_ERROR_INCONSISTENCIA_FECHA_VALUACION_MAYOR = "EIFVM";

        #endregion Constantes

        #region Variables Globales

        protected System.Data.OleDb.OleDbConnection oleDbConnection1;
        protected System.Web.UI.WebControls.Label lblOperacion;
        protected System.Web.UI.WebControls.Label lblTipoGarantia;
        protected System.Web.UI.WebControls.Button btnCalificaciones;
        protected System.Web.UI.WebControls.DropDownList cbGradoPrioridad;
        protected System.Web.UI.WebControls.DropDownList cbInspeccin;
        protected System.Web.UI.WebControls.Label lblTitulo2;
        protected System.Web.UI.WebControls.Label Label1;

        private string strOperacionCrediticia = "-";
        private string strGarantia = "-";
        private string _contratoDelGiro = string.Empty;

        private DataSet dsGarantiasReales = new DataSet("Garantías Reales");

        private clsGarantiaReal entidadGarantia;

        private decimal porcentajeAceptacionCalculado=0;

        private bool mostrarErrorRelacionPolizaGarantia = false;

        #endregion

        #region Propiedades

        /// <summary>
        /// Permite asignar en bloque los indicadores de bloqueo para los campos fecha de presentación, 
        /// indicador de inscripción, monto mitigador y porcentaje de aceptación. La cadena debe poseer el formato "0_0_0_0", donde el orden es el 
        /// citado anteriormente y los valores son 1 (habilitar) y 0 (no habilitar)
        /// </summary>
        public string BloquearCamposIndicadorInscripcion
        {
            set
            {
                string valorAsignado = value;

                if (value.Length == 0)
                {
                    valorAsignado = "0_0_0_0";
                }

                string[] indicadores = valorAsignado.Split("_".ToCharArray());

                if (indicadores.Length == 4)
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_FECHA_PRESENTACION, indicadores[0]);
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_INDICADOR_INSCRIPCION, "0");//indicadores[1]);
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_MONTO_MITIGADOR, indicadores[2]);
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_PORCENTAJE_ACEPTACION, indicadores[3]);
                }
            }
        }

        /// <summary>
        /// Se establece el indicador que determina si el campo referente a la fecha de presentación se habilita o no
        /// </summary>
        public bool BloquearFechaPresentacion
        {
            get
            {

                if ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_FECHA_PRESENTACION] != null)
                   && (btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_FECHA_PRESENTACION].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_FECHA_PRESENTACION].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_FECHA_PRESENTACION, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_FECHA_PRESENTACION, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_FECHA_PRESENTACION, "0");
                }
            }
        }

        /// <summary>
        /// Se establece el indicador que determina si el campo referente al indicador de inscripción se habilita o no
        /// </summary>
        public bool BloquearIndicadorInscripcion
        {
            get
            {

                if ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_INDICADOR_INSCRIPCION] != null)
                   && (btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_INDICADOR_INSCRIPCION].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_INDICADOR_INSCRIPCION].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_INDICADOR_INSCRIPCION, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_INDICADOR_INSCRIPCION, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_INDICADOR_INSCRIPCION, "0");
                }
            }
        }

        /// <summary>
        /// Se establece el indicador que determina si el campo referente al monto mitigador se habilita o no
        /// </summary>
        public bool BloquearMontoMitigador
        {
            get
            {

                if ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_MONTO_MITIGADOR] != null)
                   && (btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_MONTO_MITIGADOR].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_MONTO_MITIGADOR].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_MONTO_MITIGADOR, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_MONTO_MITIGADOR, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_MONTO_MITIGADOR, "0");
                }
            }
        }

        /// <summary>
        /// Se establece el indicador que determina si el campo referente al porcentaje de aceptación se habilita o no
        /// </summary>
        public bool BloquearPorcentajeAceptacion
        {
            get
            {

                if ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_PORCENTAJE_ACEPTACION] != null)
                   && (btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_PORCENTAJE_ACEPTACION].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_PORCENTAJE_ACEPTACION].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_PORCENTAJE_ACEPTACION, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_PORCENTAJE_ACEPTACION, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_PORCENTAJE_ACEPTACION, "0");
                }
            }
        }

        /// <summary>
        /// Se establece el indicador que determina si el botón de modificar fue presionado o no
        /// </summary>
        public bool IndicadorBotonGuardar
        {
            get
            {
                if ((btnModificar.Attributes[INDICADOR_BOTON_GUARDAR] != null)
                    && (btnModificar.Attributes[INDICADOR_BOTON_GUARDAR].Length > 0))
                {
                    return ((btnModificar.Attributes[INDICADOR_BOTON_GUARDAR].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnModificar.Attributes.Add(INDICADOR_BOTON_GUARDAR, "0");
                    return false;
                }
            }

            set
            {
                if (value)
                {
                    btnModificar.Attributes.Add(INDICADOR_BOTON_GUARDAR, "1");
                }
                else
                {
                    btnModificar.Attributes.Add(INDICADOR_BOTON_GUARDAR, "0");
                }
            }
        }

        /// <summary>
        /// Se almacena y se obtiene la entidad del tipo de entidad real
        /// </summary>
        public clsGarantiaReal Entidad_Real
        {
            get
            {
                if (Session[LLAVE_ENTIDAD_GARANTIA] != null)
                {
                    return new clsGarantiaReal(((string)Session[LLAVE_ENTIDAD_GARANTIA]), strOperacionCrediticia);
                }
                else
                {
                    return new clsGarantiaReal();
                }
            }

            set
            {
                Session.Add(LLAVE_ENTIDAD_GARANTIA, value.ToString(0));
            }
        }

        /// <summary>
        /// Permite obetener la lista de los códigos de los catálogos usados en este mantenimiento
        /// </summary>
        public string ListaCodigosCatalogos
        {
            get
            {
                return "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_CLASE_GARANTIA).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_GRADO_GRAVAMEN).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_INSCRIPCION).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_LIQUIDEZ).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_MONEDA).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_OPERACION_ESPECIAL).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TENENCIA).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_BIEN).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_GARANTIA_REAL).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_MITIGADOR).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_PERSONA).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS).ToString() + "|";
            }
        }

        /// <summary>
        /// Se almacena y se obtiene la entidad del tipo Catálogos
        /// </summary>
        public clsCatalogos<clsCatalogo> ListaCatalogosGR
        {
            get
            {
                if (ViewState[LLAVE_ENTIDAD_CATALOGOS] != null)
                {
                    return new clsCatalogos<clsCatalogo>(((string)ViewState[LLAVE_ENTIDAD_CATALOGOS]));
                }
                else
                {
                    return Gestor.ObtenerCatalogos(ListaCodigosCatalogos);
                }
            }

            set
            {
                ViewState.Add(LLAVE_ENTIDAD_CATALOGOS, value.TramaCatalogo);
            }
        }

        /// <summary>
        /// Se almacena y se obtiene la entidad del tipo valuadores, con la información de los peritos
        /// </summary>
        public clsValuadores<clsValuador> ListaPeritos
        {
            get
            {
                if (ViewState[LLAVE_ENTIDAD_PERITOS] != null)
                {
                    return new clsValuadores<clsValuador>(((string)ViewState[LLAVE_ENTIDAD_PERITOS]), Enumeradores.TiposValuadores.Perito);
                }
                else
                {
                    return Gestor.ObtenerValuadores(Enumeradores.TiposValuadores.Perito);
                }
            }

            set
            {
                ViewState.Add(LLAVE_ENTIDAD_PERITOS, value.TramaValuador);
            }
        }

        /// <summary>
        /// Se almacena y se obtiene la entidad del tipo valuadores, con la información de las empresas valuadoras
        /// </summary>
        public clsValuadores<clsValuador> ListaEmpresasValuadoras
        {
            get
            {
                if (ViewState[LLAVE_ENTIDAD_EMPRESAS] != null)
                {
                    return new clsValuadores<clsValuador>(((string)ViewState[LLAVE_ENTIDAD_EMPRESAS]), Enumeradores.TiposValuadores.Empresa);
                }
                else
                {
                    return Gestor.ObtenerValuadores(Enumeradores.TiposValuadores.Empresa);
                }
            }

            set
            {
                ViewState.Add(LLAVE_ENTIDAD_EMPRESAS, value.TramaValuador);
            }
        }

        /// <summary>
        /// Se guarda en sesión el consecutivo de la operación
        /// </summary>
        public long ConsecutivoOperacion
        {
            get
            {
                return ((Session[LLAVE_CONSECUTIVO_OPERACION] != null) ? long.Parse(Session[LLAVE_CONSECUTIVO_OPERACION].ToString()) : -1);
            }

            set
            {
                Session[LLAVE_CONSECUTIVO_OPERACION] = value.ToString();
            }
        }

        /// <summary>
        /// Se guarda en sesión el consecutivo de la garantía seleccionada
        /// </summary>
        public long ConsecutivoGarantia
        {
            get
            {
                return ((Session[LLAVE_CONSECUTIVO_GARANTIA] != null) ? long.Parse(Session[LLAVE_CONSECUTIVO_GARANTIA].ToString()) : -1);
            }

            set
            {
                Session[LLAVE_CONSECUTIVO_GARANTIA] = value.ToString();
            }
        }

        /// <summary>
        /// Se guarda en sesión la descripción de la garantía, en formato partido - finca / clase - id bien
        /// </summary>
        public string DescripcionGarantia
        {
            get
            {
                return ((Session[LLAVE_DESCRIPCION_GARANTIA] != null) ? Session[LLAVE_DESCRIPCION_GARANTIA].ToString() : string.Empty);
            }

            set
            {
                Session[LLAVE_DESCRIPCION_GARANTIA] = value;
                btnValidarOperacion.Attributes.Add(LLAVE_DESCRIPCION_GARANTIA, value);
            }
        }

        /// <summary>
        /// Se guarda en sesión los datos de la operación, en el formato tipoOperacion_oficina_moneda_producto_operacion
        /// </summary>
        public string DatosOperacion
        {
            get
            {
                return ((Session[LLAVE_DATOS_OPERACION] != null) ? Session[LLAVE_DATOS_OPERACION].ToString() : string.Empty);
            }

            set
            {
                Session[LLAVE_DATOS_OPERACION] = value;
            }
        }

        /// <summary>
        /// Retorna el tipo de operación
        /// </summary>
        public string TipoOperacion
        {
            get
            {
                string[] tipoOperacion = DatosOperacion.Split("_".ToCharArray());

                return ((tipoOperacion.Length == 5) ? tipoOperacion[0] : string.Empty);
            }
        }

        /// <summary>
        /// Retorna el código de oficina de la operación
        /// </summary>
        public string OficinaOperacion
        {
            get
            {
                string[] codigoOficina = DatosOperacion.Split("_".ToCharArray());

                return ((codigoOficina.Length == 5) ? codigoOficina[1] : string.Empty);
            }
        }

        /// <summary>
        /// Retorna el código de la moneda de la operación
        /// </summary>
        public string MonedaOperacion
        {
            get
            {
                string[] codigoMoneda = DatosOperacion.Split("_".ToCharArray());

                return ((codigoMoneda.Length == 5) ? codigoMoneda[2] : string.Empty);
            }
        }

        /// <summary>
        /// Retorna el código del producto de la operación
        /// </summary>
        public string ProductoOperacion
        {
            get
            {
                string[] codigoProducto = DatosOperacion.Split("_".ToCharArray());

                return ((codigoProducto.Length == 5) ? codigoProducto[3] : string.Empty);
            }
        }

        /// <summary>
        /// Retorna el número de la operación
        /// </summary>
        public string NumeroOperacion
        {
            get
            {
                string[] numeroOperacion = DatosOperacion.Split("_".ToCharArray());

                return ((numeroOperacion.Length == 5) ? numeroOperacion[4] : string.Empty);
            }
        }

        /// <summary>
        /// Se establece el indicador que determina si se produjo un error grave o no
        /// </summary>
        public bool ErrorGrave
        {
            get
            {

                if ((btnValidarOperacion.Attributes[INDICADOR_ERROR_GRAVE] != null)
                   && (btnValidarOperacion.Attributes[INDICADOR_ERROR_GRAVE].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[INDICADOR_ERROR_GRAVE].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(INDICADOR_ERROR_GRAVE, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(INDICADOR_ERROR_GRAVE, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(INDICADOR_ERROR_GRAVE, "0");
                }
            }
        }

        /// <summary>
        /// Se establece la trama que se obtiene de la consulta realizada a la base de datos
        /// </summary>
        public string TramaInicial
        {
            get
            {
                if (Session[LLAVE_TRAMA_INICIAL] != null)
                {
                    return ((string)Session[LLAVE_TRAMA_INICIAL]);
                }
                else
                {
                    return String.Empty;
                }
            }

            set { Session[LLAVE_TRAMA_INICIAL] = value; }
        }

        /// <summary>
        /// Se establece si la operación consultada corresponde a un giro de contrato
        /// </summary>
        public bool EsGiro
        {
            get
            {
                if (Session[LLAVE_ES_GIRO] != null)
                {
                    return ((Session[LLAVE_ES_GIRO].ToString().CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    return false;
                }
            }

            set
            {
                if (value)
                {
                    Session[LLAVE_ES_GIRO] = "1";
                }
                else
                {
                    Session[LLAVE_ES_GIRO] = "0";
                }
            }
        }

        /// <summary>
        /// Se establece si la operación consultada corresponde a un giro de contrato, de serlo, 
        /// esta propiedad contendrá el consecutivo de dicho contrato
        /// </summary>
        public long ConsecutivoContrato
        {
            get
            {
                return ((Session[LLAVE_CONSECUTIVO_CONTRATO] != null) ? long.Parse(Session[LLAVE_CONSECUTIVO_CONTRATO].ToString()) : -1);
            }

            set
            {
                Session[LLAVE_CONSECUTIVO_CONTRATO] = value.ToString();
            }
        }

        /// <summary>
        /// Se establece el tipo de garantía real que ser consultada 
        /// </summary>
        public int CodigoTipoGarantiaReal
        {
            get
            {
                return ((Session[LLAVE_TIPO_GARANTIA_REAL] != null) ? int.Parse(Session[LLAVE_TIPO_GARANTIA_REAL].ToString()) : -1);
            }
            set
            {
                Session[LLAVE_TIPO_GARANTIA_REAL] = value.ToString();
            }
        }

        /// <summary>
        /// Se establece la cantidad de años que se deben sumar a la fecha de vencimiento, con el fin de calcular la fecha de prescripción 
        /// </summary>
        public int AnnosCalculoFechaPrescripcion
        {
            get
            {
                int annosCFP;

                if ((btnValidarOperacion.Attributes[ANNOS_CALCULO_FECHA_PRESCRIPCION] != null)
                   && (btnValidarOperacion.Attributes[ANNOS_CALCULO_FECHA_PRESCRIPCION].Length > 0))
                {
                    return (int.TryParse(btnValidarOperacion.Attributes[ANNOS_CALCULO_FECHA_PRESCRIPCION], out annosCFP) ? annosCFP : 0);
                }
                else
                {
                    if (Session[LLAVE_TIPO_GARANTIA_REAL] != null)
                    {
                        int tipoGR = Convert.ToInt32(Session[LLAVE_TIPO_GARANTIA_REAL].ToString());
                        annosCFP = ObtenerCantidadAnnosPrescripcion(tipoGR);
                        btnValidarOperacion.Attributes.Add(ANNOS_CALCULO_FECHA_PRESCRIPCION, annosCFP.ToString());
                        return annosCFP;
                    }
                    else
                    {
                        btnValidarOperacion.Attributes.Add(ANNOS_CALCULO_FECHA_PRESCRIPCION, "0");
                        return 0;
                    }
                }
            }
            set
            {
                btnValidarOperacion.Attributes.Add(ANNOS_CALCULO_FECHA_PRESCRIPCION, value.ToString());
            }
        }

        /// <summary>
        /// Se establece el indicador que determina si el campo referente a la fecha de vencimiento se habilita o no
        /// </summary>
        public bool BloquearFechaVencimiento
        {
            get
            {

                if ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_FECHA_VENCIMIENTO] != null)
                   && (btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_FECHA_VENCIMIENTO].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_FECHA_VENCIMIENTO].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_FECHA_VENCIMIENTO, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_FECHA_VENCIMIENTO, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPO_FECHA_VENCIMIENTO, "0");
                }
            }
        }

        /// <summary>
        /// Se almacena y se obtiene el indicador que determina si se despliega o no el panel de avalúos
        /// </summary>
        public int ExpandirValuaciones
        {
            get
            {
                int datoRetornado;
                int datoObtenido;

                if ((Session[LLAVE_BLOQUEAR_AVALUOS] != null)
                   && (Session[LLAVE_BLOQUEAR_AVALUOS].ToString().Length > 0))
                {
                    datoObtenido = (int.TryParse(Session[LLAVE_BLOQUEAR_AVALUOS].ToString(), out datoRetornado) ? datoRetornado : -1);
                    hdnIndiceAccordionActivo.Value = datoObtenido.ToString();

                    return datoObtenido;
                }
                else
                {
                    Session[LLAVE_BLOQUEAR_AVALUOS] = "-1";
                    hdnIndiceAccordionActivo.Value = "-1";

                    return -1;
                }
            }
            set
            {
                Session[LLAVE_BLOQUEAR_AVALUOS] = value.ToString();
                hdnIndiceAccordionActivo.Value = value.ToString();
            }
        }

        /// <summary>
        /// Se almacena y se obtiene el indicador que determina si se despliega o no el panel de pólizas
        /// </summary>
        public int ExpandirPolizas
        {
            get
            {
                int datoRetornado;
                int datoObtenido;

                if ((Session[LLAVE_BLOQUEAR_POLIZA] != null)
                   && (Session[LLAVE_BLOQUEAR_POLIZA].ToString().Length > 0))
                {
                    datoObtenido = (int.TryParse(Session[LLAVE_BLOQUEAR_POLIZA].ToString(), out datoRetornado) ? datoRetornado : -1);
                    hdnIndiceAccordionPolizaActivo.Value = datoObtenido.ToString();
                    
                    return datoObtenido;
                }
                else
                {
                    Session[LLAVE_BLOQUEAR_POLIZA] = "-1";
                    hdnIndiceAccordionPolizaActivo.Value = "-1";

                    return -1;
                }
            }
            set
            {
                Session[LLAVE_BLOQUEAR_POLIZA] = value.ToString();
                hdnIndiceAccordionPolizaActivo.Value = value.ToString();
            }
        }

        /// <summary>
        /// Se establece si la garantía posee almenos un avalúo (1) o no (0)
        /// </summary>
        public bool ExisteValuacion
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_EXISTE_AVALUO] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_EXISTE_AVALUO].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_EXISTE_AVALUO].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_EXISTE_AVALUO, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_EXISTE_AVALUO, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_EXISTE_AVALUO, "0");
                }
            }
        }

        /// <summary>
        /// Se establece el monto total del avalúo, requerido para realizar el cálculo del monto mitigador
        /// </summary>
        public string MontoTotalAvaluo
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_MONTO_TOTAL_AVALUO] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_MONTO_TOTAL_AVALUO].Length > 0))
                {
                    return btnValidarOperacion.Attributes[LLAVE_MONTO_TOTAL_AVALUO];
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_MONTO_TOTAL_AVALUO, "0");
                    return "0";
                }
            }
            set
            {
                btnValidarOperacion.Attributes.Add(LLAVE_MONTO_TOTAL_AVALUO, value);
            }
        }

        /// <summary>
        /// Se establece si se debe mostrar el error del monto mitigador (1) o no (0)
        /// </summary>
        public bool MostrarErrorMontoMitigador
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_MOSTRAR_ERROR_MONTO_MITIGADOR] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_MOSTRAR_ERROR_MONTO_MITIGADOR].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_MOSTRAR_ERROR_MONTO_MITIGADOR].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_MOSTRAR_ERROR_MONTO_MITIGADOR, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_MOSTRAR_ERROR_MONTO_MITIGADOR, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_MOSTRAR_ERROR_MONTO_MITIGADOR, "0");
                }
            }
        }

        /// <summary>
        /// Se establece la diferencia entre monto mitigador calculado y el monto mitigador.
        /// </summary>
        public string DiferenciaMontosMitigadores
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_MONTO_MITIGADOR_CALCULADO] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_MONTO_MITIGADOR_CALCULADO].Length > 0))
                {
                    return btnValidarOperacion.Attributes[LLAVE_MONTO_MITIGADOR_CALCULADO];
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_MONTO_MITIGADOR_CALCULADO, "0.00");
                    return "0.00";
                }
            }
            set
            {
                btnValidarOperacion.Attributes.Add(LLAVE_MONTO_MITIGADOR_CALCULADO, value);
            }
        }

        /// <summary>
        /// Se almacena y se obtiene el indicador que determina si se habilita o no el panel de avalúos
        /// </summary>
        public bool HabilitarValuacion
        {
            get
            {
                int datoRetornado;
                int datoObtenido;

                if ((Session[LLAVE_HABILITAR_AVALUO] != null)
                   && (Session[LLAVE_HABILITAR_AVALUO].ToString().Length > 0))
                {
                    datoObtenido = (int.TryParse(Session[LLAVE_HABILITAR_AVALUO].ToString(), out datoRetornado) ? datoRetornado : 0);
                    hdnHabilitarValuacion.Value = datoObtenido.ToString();

                    return ((datoObtenido == 1) ? true : false);
                }
                else
                {
                    Session[LLAVE_HABILITAR_AVALUO] = "0";
                    hdnHabilitarValuacion.Value = "0";

                    return false;
                }
            }
            set
            {
                if (value)
                {
                    Session[LLAVE_HABILITAR_AVALUO] = "1";
                    hdnHabilitarValuacion.Value = "1";
                }
                else
                {
                    Session[LLAVE_HABILITAR_AVALUO] = "0";
                    hdnHabilitarValuacion.Value = "0";
                }
            }
        }

        /// <summary>
        /// Se almacena y se obtiene el indicador que determina si se habilita o no el panel de la póliza
        /// </summary>
        public bool HabilitarPoliza
        {
            get
            {
                int datoRetornado;
                int datoObtenido;

                if ((Session[LLAVE_HABILITAR_POLIZA] != null)
                   && (Session[LLAVE_HABILITAR_POLIZA].ToString().Length > 0))
                {
                    datoObtenido = (int.TryParse(Session[LLAVE_HABILITAR_POLIZA].ToString(), out datoRetornado) ? datoRetornado : 0);
                    hdnHabilitarPoliza.Value = datoObtenido.ToString();

                    return ((datoObtenido == 1) ? true : false);
                }
                else
                {
                    Session[LLAVE_HABILITAR_POLIZA] = "0";
                    hdnHabilitarPoliza.Value = "0";

                    return false;
                }
            }
            set
            {
                if (value)
                {
                    Session[LLAVE_HABILITAR_POLIZA] = "1";
                    hdnHabilitarPoliza.Value = "1";
                }
                else
                {
                    Session[LLAVE_HABILITAR_POLIZA] = "0";
                    hdnHabilitarPoliza.Value = "0";
                }
            }
        }

        /// <summary>
        /// Se establece si se ha ejecutado el cáculo de los montos del avalúo
        /// </summary>
        public bool AvaluoActualizado
        {
            get
            {
                if (Session[LLAVE_AVALUO_ACTUALIZADO] != null)
                {
                    return ((Session[LLAVE_AVALUO_ACTUALIZADO].ToString().CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    return false;
                }
            }

            set
            {
                if (value)
                {
                    Session[LLAVE_AVALUO_ACTUALIZADO] = "1";
                }
                else
                {
                    Session[LLAVE_AVALUO_ACTUALIZADO] = "0";
                }
            }
        }

        /// <summary>
        /// Se establece la fecha del último semestre calculado del avalúo
        /// </summary>
        public DateTime FechaSemestreActualizado
        {
            get
            {
                return ((Session[LLAVE_FECHA_SEMESTRE_ACTUALIZADO] != null) ? DateTime.Parse(Session[LLAVE_FECHA_SEMESTRE_ACTUALIZADO].ToString()) : new DateTime(1900, 01, 01));
            }

            set
            {
                Session[LLAVE_FECHA_SEMESTRE_ACTUALIZADO] = value.ToShortDateString();
            }
        }

        /// <summary>
        /// Se establece el indicador que determina si se ha presentado el error de que los datos del avalúo son difernetes a los del SICC
        /// </summary>
        public bool ErrorGraveAvaluo
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_ERROR_GRAVE_AVALUO] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_ERROR_GRAVE_AVALUO].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_ERROR_GRAVE_AVALUO].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_GRAVE_AVALUO, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_GRAVE_AVALUO, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_GRAVE_AVALUO, "0");
                }
            }
        }

        /// <summary>
        /// Se establece el indicador que determina si los campos de los montos de la tasación actualizada del terreno y no terreno calculados se habilita o no
        /// </summary>
        public bool BloquearCamposMTATMTANT
        {
            get
            {

                if ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPOS_MTAT_MTANT] != null)
                   && (btnValidarOperacion.Attributes[BLOQUEAR_CAMPOS_MTAT_MTANT].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[BLOQUEAR_CAMPOS_MTAT_MTANT].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPOS_MTAT_MTANT, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPOS_MTAT_MTANT, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(BLOQUEAR_CAMPOS_MTAT_MTANT, "0");
                }
            }
        }

        /// <summary>
        /// Se establece si se debe mostrar la lista de operaciones respaldada por la garantía
        /// </summary>
        public bool MostrarListaOperaciones
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_LISTA_OPERACIONES] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_LISTA_OPERACIONES].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_LISTA_OPERACIONES].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_LISTA_OPERACIONES, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_LISTA_OPERACIONES, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_LISTA_OPERACIONES, "0");
                }
            }
        }

        /// <summary>
        /// Se establece si se trata de la carga inicial
        /// </summary>
        public bool CargaInicial
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_CARGA_INICIAL] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_CARGA_INICIAL].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_CARGA_INICIAL].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_CARGA_INICIAL, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_CARGA_INICIAL, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_CARGA_INICIAL, "0");
                }
            }
        }

        /// <summary>
        /// Se establece si se debe mostrar el error de los infra seguros (1) o no (0)
        /// </summary>
        public bool MostrarErrorInfraSeguro
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_LISTA_OPERACIONES_INFRA_SEGURO] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_LISTA_OPERACIONES_INFRA_SEGURO].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_LISTA_OPERACIONES_INFRA_SEGURO].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_LISTA_OPERACIONES_INFRA_SEGURO, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_LISTA_OPERACIONES_INFRA_SEGURO, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_LISTA_OPERACIONES_INFRA_SEGURO, "0");
                }
            }
        }

        /// <summary>
        /// Se establece si se debe mostrar el error de los montos del as acreencias diferentes entre operaciones con misma garantía y misma póliza (1) o no (0)
        /// </summary>
        public bool MostrarErrorAcreenciasDiferentes
        {
            get
            {
                if ((btnValidarOperacion.Attributes[LLAVE_LISTA_OPER_ACREENCIA_DIF] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_LISTA_OPER_ACREENCIA_DIF].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_LISTA_OPER_ACREENCIA_DIF].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_LISTA_OPER_ACREENCIA_DIF, "0");
                    return false;
                }
            }
            set
            {
                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_LISTA_OPER_ACREENCIA_DIF, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_LISTA_OPER_ACREENCIA_DIF, "0");
                }
            }
        }


        /// <summary>
        /// Se establece si se debe mostrar el error de que no existe póliza asociada (1) o no (0)
        /// </summary>
        public bool MostrarErrorSinPolizaAsociada
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_SIN_POLIZA] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_SIN_POLIZA].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_SIN_POLIZA].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_SIN_POLIZA, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_SIN_POLIZA, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_SIN_POLIZA, "0");
                }
            }
        }

        /// <summary>
        /// Se establece si se debe mostrar el error de que la póliza asociada es inválida (1) o no (0)
        /// </summary>
        public bool MostrarErrorPolizaInvalida
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_POLIZA_INVALIDA] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_POLIZA_INVALIDA].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_POLIZA_INVALIDA].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_POLIZA_INVALIDA, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_POLIZA_INVALIDA, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_POLIZA_INVALIDA, "0");
                }
            }
        }

        /// <summary>
        /// Se establece si se debe mostrar el error de que el monto de la póliza asociada cubre el bien (1) o no (0)
        /// </summary>
        public bool MostrarErrorMontoPolizaCubreBien
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_POLIZA_NO_CUBRE_BIEN] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_POLIZA_NO_CUBRE_BIEN].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_POLIZA_NO_CUBRE_BIEN].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_POLIZA_NO_CUBRE_BIEN, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_POLIZA_NO_CUBRE_BIEN, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_POLIZA_NO_CUBRE_BIEN, "0");
                }
            }
        }

        /// <summary>
        /// Se establece si se debe mostrar el error de que la fecha de último seguimiento mayor a un año debe mostrarse (1) o no (0)
        /// </summary>
        public bool MostrarErrorFechaUltimoSeguimientoMayor
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_FECHA_ULTIMO_SEGUIMIENTO_MAYOR_1ANNO] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_FECHA_ULTIMO_SEGUIMIENTO_MAYOR_1ANNO].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_FECHA_ULTIMO_SEGUIMIENTO_MAYOR_1ANNO].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_FECHA_ULTIMO_SEGUIMIENTO_MAYOR_1ANNO, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_FECHA_ULTIMO_SEGUIMIENTO_MAYOR_1ANNO, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_FECHA_ULTIMO_SEGUIMIENTO_MAYOR_1ANNO, "0");
                }
            }
        }

        /// <summary>
        /// Se establece si se debe mostrar el error de que la fecha de valuación mayor a cinco años debe mostrarse (1) o no (0)
        /// </summary>
        public bool MostrarErrorFechaValuacionMayor
        {
            get
            {

                if ((btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_FECHA_VALUACION_MAYOR] != null)
                   && (btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_FECHA_VALUACION_MAYOR].Length > 0))
                {
                    return ((btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_FECHA_VALUACION_MAYOR].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_FECHA_VALUACION_MAYOR, "0");
                    return false;
                }
            }
            set
            {

                if (value)
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_FECHA_VALUACION_MAYOR, "1");
                }
                else
                {
                    btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INCONSISTENCIA_FECHA_VALUACION_MAYOR, "0");
                }
            }
        }



        #endregion Propiedades

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            Button2.Click += new EventHandler(Button2_Click);
            btnEliminar.Click += new EventHandler(btnEliminar_Click);
            btnLimpiar.Click += new EventHandler(btnLimpiar_Click);
            btnModificar.Click += new EventHandler(btnModificar_Click);
            btnValidarOperacion.Click += new EventHandler(btnValidarOperacion_Click);
            cbTipoCaptacion.SelectedIndexChanged += new EventHandler(cbTipoCaptacion_SelectedIndexChanged);
            cbTipoGarantiaReal.SelectedIndexChanged += new EventHandler(cbTipoGarantiaReal_SelectedIndexChanged);

            if (!IsPostBack)
            {
                ExpandirValuaciones = -1;
                ExpandirPolizas = -1;
                HabilitarValuacion = false;
                HabilitarPoliza = false;
            }
        }

        protected override void OnLoadComplete(EventArgs e)
        {
            bool habilitarAvaluo = false;
            bool habilitarPoliza = false;
            string funcionContraer = string.Empty;
            string funcionContraerPoliza = string.Empty;

            base.OnLoadComplete(e);

            habilitarAvaluo = HabilitarValuacion;
            habilitarPoliza = HabilitarPoliza;

            if (ExpandirValuaciones == -1)
            {
                funcionContraer = "ContraerAvaluo();";
            }

            if (ExpandirPolizas == -1)
            {
                funcionContraerPoliza = "ContraerPoliza();";
            }

            ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

            //Se ejecutan las funciones que manipulan el objeto "Acordeón" de la interfaz de usuario
            if (requestSM != null && requestSM.IsInAsyncPostBack)
            {
                ScriptManager.RegisterClientScriptBlock(this,
                                                        typeof(Page),
                                                        Guid.NewGuid().ToString(),
                                                        "<script type=\"text/javascript\" language=\"javascript\">document.body.style.cursor = 'default';" +
                                                        " $(document).ready(function () { " +
                                                        funcionContraer + funcionContraerPoliza +
                                                        " MostrarAvaluoReal(" + habilitarAvaluo.ToString().ToLower() + "); " +
                                                        " HabilitarAvaluoReal(" + habilitarAvaluo.ToString().ToLower() + "); " +
                                                        " MostrarPoliza(" + habilitarPoliza.ToString().ToLower() + "); " +
                                                        " HabilitarPoliza(" + habilitarPoliza.ToString().ToLower() + "); });" +
                                                       " </script>",
                                                        false);
            }
            else
            {
                this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                       Guid.NewGuid().ToString(),
                                                        "<script type=\"text/javascript\" language=\"javascript\">document.body.style.cursor = 'default';" +
                                                        " $(document).ready(function () { " +
                                                        funcionContraer + funcionContraerPoliza +
                                                        " MostrarAvaluoReal(" + habilitarAvaluo.ToString().ToLower() + "); " +
                                                        " HabilitarAvaluoReal(" + habilitarAvaluo.ToString().ToLower() + "); " +
                                                        " MostrarPoliza(" + habilitarPoliza.ToString().ToLower() + "); " +
                                                        " HabilitarPoliza(" + habilitarPoliza.ToString().ToLower() + "); });" +
                                                        " </script>",
                                                       false);
            }
            if ((ErrorGrave) || (ErrorGraveAvaluo))
            {
                this.txtMontoTasActTerreno.Text = string.Empty;
                this.txtMontoTasActNoTerreno.Text = string.Empty;
                this.txtMontoTasActTerreno.Enabled = false;
                this.txtMontoTasActNoTerreno.Enabled = false;
                this.txtMontoUltTasacionTerreno.Enabled = false;
                this.txtMontoUltTasacionNoTerreno.Enabled = false;
                this.cbPerito.Enabled = false;
                this.cbEmpresa.Enabled = false;
                this.txtFechaConstruccion.Enabled = false;
                this.igbCalendarioConstruccion.Enabled = false;
                this.txtFechaSeguimiento.Enabled = false;
                this.igbCalendarioSeguimiento.Enabled = false;
            }

            if ((IsPostBack) && ((!ErrorGrave) && (!ErrorGraveAvaluo)))
            {
                if ((cbTipoBien.SelectedItem != null) && (cbTipoBien.SelectedItem.Value.CompareTo("1") == 0) && (txtMontoTasActTerreno.Text.Length > 0))
                {
                    this.txtFechaSeguimiento.Enabled = true;
                    this.igbCalendarioSeguimiento.Enabled = true;
                }
                else if ((cbTipoBien.SelectedItem != null) && (cbTipoBien.SelectedItem.Value.CompareTo("2") == 0) && (txtMontoTasActTerreno.Text.Length > 0) && (txtMontoTasActNoTerreno.Text.Length > 0))
                {
                    this.txtFechaSeguimiento.Enabled = true;
                    this.igbCalendarioSeguimiento.Enabled = true;
                }
                else if ((cbTipoBien.SelectedItem != null) && (cbTipoBien.SelectedItem.Value.CompareTo("1") != 0) && (cbTipoBien.SelectedItem.Value.CompareTo("2") != 0))
                {
                    this.txtFechaSeguimiento.Enabled = true;
                    this.igbCalendarioSeguimiento.Enabled = true;
                }
            }

            if ((Session["Accion"] != null) && (Session["Accion"].ToString() == "CARGACOMBO"))
            {
                HabilitarCamposValidados();
                AplicarCalculoMontoMitigador();
                Session["Accion"] = String.Empty;
            }   
            
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            txtAcreedor.Enabled = false;
            contenedorDatosModificacion.Visible = false;

            txtContabilidad.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOficina.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtMoneda.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtProducto.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOperacion.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtGrado.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtCedulaHipotecaria.Attributes["onblur"] = "javascript:EsNumerico(this);";
            btnEliminar.Attributes["onclick"] = "javascript:var acepta = confirm('Está seguro que desea eliminar la garantía seleccionada?'); if(acepta == true) { document.body.style.cursor = 'wait'; return true;} else { document.body.style.cursor = 'default'; return false;}";
            btnModificar.Attributes["onclick"] = "javascript:var acepta = confirm('Está seguro que desea modificar la garantía seleccionada?'); if(acepta == true) { document.body.style.cursor = 'wait'; return true;} else { document.body.style.cursor = 'default'; return false;}";

            txtMontoMitigador.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoMitigador.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            #region Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

            txtMontoMitigadorCalculado.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoMitigadorCalculado.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            #endregion Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

            txtPorcentajeAceptacion.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtPorcentajeAceptacion.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,true); ValidarPorcentajeAceptacion();");


            #region Siebel 1-24613011. Realizado por: Leonardo Cortés Mora. - Lidersoft Internacional S.A., 12/12/2014.

            txtPorcentajeAceptacionCalculado.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtPorcentajeAceptacionCalculado.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            txtFechaSeguimiento.Attributes.Add("onblur", "javascript:ValidarPorcentajeAceptacionCalculado();");

            #endregion Siebel 1-24613011. Realizado por: Leonardo Cortés Mora. - Lidersoft Internacional S.A., 12/12/2014.

            txtFechaRegistro.Attributes.Add("onblur", "javascript:validarFechaPresentacion();");

            hdnBtnPostback.Value = Page.ClientScript.GetPostBackEventReference(btnModificar, string.Empty);

            hdnFechaActual.Value = DateTime.Now.Year.ToString() + "|" + DateTime.Now.Month.ToString().PadLeft(2, '0') + "|" + DateTime.Now.Day.ToString().PadLeft(2, '0');

            cbInscripcion.Attributes.Add("onblur", "javascript:validarIndicadorInscripcion();");

            txtFechaVencimiento.Attributes.Add("onblur", "javascript:ActualizarFechaPrescripcion();");

            txtMontoUltTasacionTerreno.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoUltTasacionTerreno.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false); javascript:CalcularMontoTAT_TANT();");

            txtMontoUltTasacionNoTerreno.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoUltTasacionNoTerreno.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false); javascript:CalcularMontoTAT_TANT();");

            txtMontoTasActTerreno.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoTasActTerreno.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false);");

            txtMontoTasActNoTerreno.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoTasActNoTerreno.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false);");

            txtMontoAvaluo.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoAvaluo.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false);");

            txtMontoAcreenciaPoliza.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoAcreenciaPoliza.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false);");

            cbCodigoSap.Attributes.Add("onchange", "javascript:cargarDatosPoliza();");

            btnValidarOperacion.Attributes["onclick"] = "javascript:document.body.style.cursor = 'wait'; return true;";
            btnLimpiar.Attributes["onclick"] = "javascript:document.body.style.cursor = 'wait'; return true;";

            chkDeudorHabitaVivienda.Attributes.Add("onclick", "javascript:ValidarPorcentajeAceptacionCalculado();");

            gdvGarantiasReales.Attributes.Add("OnDataBinding", "document.body.style.cursor = 'wait'; document.documentElement.style.cursor = 'wait';");

            MostrarListaOperaciones = false;
            MostrarErrorMontoMitigador = false;
            MostrarErrorInfraSeguro = false;
            MostrarErrorAcreenciasDiferentes = false;
            MostrarErrorSinPolizaAsociada = false;
            MostrarErrorPolizaInvalida = false;
            MostrarErrorMontoPolizaCubreBien = false;
            MostrarErrorFechaUltimoSeguimientoMayor = false;
            MostrarErrorFechaValuacionMayor = false;

            btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INDICADOR_INCONSISTENCIA, "0");

            if (!IsPostBack)
            {
                try
                {
                    int nProducto = -1;

                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_GARANTIA_REAL"].ToString())))
                    {
                        FormatearCamposNumericos();

                        DiferenciaMontosMitigadores = "0.00";

                        btnValidarOperacion.Attributes.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, "0.00");
                        btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INDICADOR_INCONSISTENCIA, "0");

                        CargaInicial = true;

                        if ((Request.Form["__EVENTARGUMENT"] != null) && (Request.Form["__EVENTARGUMENT"].Length > 0) &&
                            (Request.Form["__EVENTARGUMENT"].CompareTo("Metodo") == 0))
                        {
                            MostrarListaOperaciones = true;
                            MostrarErrorMontoMitigador = true;
                            MostrarErrorInfraSeguro = true;
                            MostrarErrorAcreenciasDiferentes = true;
                            MostrarErrorSinPolizaAsociada = true;
                            MostrarErrorPolizaInvalida = true;
                            MostrarErrorMontoPolizaCubreBien = true;
                            MostrarErrorFechaUltimoSeguimientoMayor = true;
                            MostrarErrorFechaValuacionMayor = true;
                        }

                        AplicarCalculoMontoMitigador();                                            

                        #region Bloquear campos según requerimiento Siebel No. 1-21317176  ---> 009 Req_Validaciones Indicador Inscripción, por AMM-Lidersoft Internacional S.A., el 11/07/2012

                        txtMontoMitigador.Enabled = false;
                        txtPorcentajeAceptacion.Enabled = false;

                        #endregion Bloquear campos según requerimiento Siebel No. 1-21317176  ---> 009 Req_Validaciones Indicador Inscripción, por AMM-Lidersoft Internacional S.A., el 11/07/2012

                        ErrorGrave = false;

                        BloquearFechaVencimiento = false;
                        BloquearCamposIndicadorInscripcion = "0_0_0_0";
                        BloquearCampos(false, true);

                        IndicadorBotonGuardar = false;

                        lblGrado.Visible = false;
                        txtGrado.Visible = false;
                        lblCedula.Visible = false;
                        txtCedulaHipotecaria.Visible = false;
                        Session["Tipo_Operacion"] = int.Parse(Application["OPERACION_CREDITICIA"].ToString());
                        Session["EsOperacionValida"] = false;

                        if ((Session["EsOperacionValidaReal"] != null) && (bool.Parse(Session["EsOperacionValidaReal"].ToString())))
                        {
                            if ((Session["Accion"] == null) || (Session["Accion"].ToString().Length == 0))
                            {
                                btnModificar.Enabled = false;
                                btnEliminar.Enabled = false;
                            }
                            else if ((Session["Accion"] != null) && ((Session["Accion"].ToString() == "INSERTAR") ||
                                (Session["Accion"].ToString() == "ELIMINAR")))
                            {
                                LimpiarCampos();
                                contenedorDatosModificacion.Visible = false;
                                contenedorDatosModificacion.Controls.Clear();

                                btnModificar.Enabled = false;
                                btnEliminar.Enabled = false;
                                ExpandirValuaciones = -1;
                                ExpandirPolizas = -1;
                                HabilitarValuacion = false;
                                HabilitarPoliza = false;
                                CargarInfoConsulta();
                                btnValidarOperacion_Click(this.btnValidarOperacion, new EventArgs());
                            }
                            else if ((Session["Accion"] != null) && ((Session["Accion"].ToString() == "DEUDOR_MOD") ||
                           (Session["Accion"].ToString() == "GARANTIA_MOD")))
                            {
                                BloquearCamposIndicadorInscripcion = "1_0_0_0";
                                BloquearCampos(true, false);

                                btnModificar.Enabled = true;
                                btnEliminar.Enabled = true;
                                CargarDatosSession(false);

                                if (txtNumFinca.Text.Trim().Length > 0)
                                    cbTipoGarantiaReal.Enabled = false;
                                else
                                    cbTipoGarantiaReal.Enabled = true;

                                lblDeudor.Visible = true;
                                lblNombreDeudor.Visible = true;
                                lblNombreDeudor.Text = Session["Nombre_Deudor"].ToString();


                                if (txtProducto.Text.Length != 0)
                                    nProducto = int.Parse(txtProducto.Text);

                                if ((ConsecutivoOperacion != -1)
                                    && (txtContabilidad.Text.Length > 0) && (txtOficina.Text.Length > 0)
                                    && (txtMoneda.Text.Length > 0) && (txtOperacion.Text.Length > 0))
                                {
                                    CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
                                               ((EsGiro) ? ConsecutivoContrato : ConsecutivoOperacion),
                                               int.Parse(txtContabilidad.Text),
                                               int.Parse(txtOficina.Text),
                                               int.Parse(txtMoneda.Text),
                                               nProducto,
                                               long.Parse(txtOperacion.Text));
                                }

                                Session["Accion"] = string.Empty;
                            }
                            else if ((Session["Accion"] != null) && (Session["Accion"].ToString() == "MODIFICAR"))
                            {
                                btnModificar.Enabled = true;
                                btnEliminar.Enabled = true;

                                MostrarErrorMontoMitigador = true;
                                MostrarListaOperaciones = true;
                                MostrarErrorInfraSeguro = true;
                                MostrarErrorAcreenciasDiferentes = true;
                                MostrarErrorSinPolizaAsociada = true;
                                MostrarErrorPolizaInvalida = true;
                                MostrarErrorMontoPolizaCubreBien = true;
                                MostrarErrorFechaUltimoSeguimientoMayor = true;
                                MostrarErrorFechaValuacionMayor = true;

                                CargarDatosSession(true);

                                if (txtNumFinca.Text.Trim().Length > 0)
                                    cbTipoGarantiaReal.Enabled = false;
                                else
                                    cbTipoGarantiaReal.Enabled = true;

                                lblDeudor.Visible = true;
                                lblNombreDeudor.Visible = true;
                                lblNombreDeudor.Text = Session["Nombre_Deudor"].ToString();


                                if (txtProducto.Text.Length != 0)
                                    nProducto = int.Parse(txtProducto.Text);

                                if ((ConsecutivoOperacion != -1)
                                    && (txtContabilidad.Text.Length > 0) && (txtOficina.Text.Length > 0)
                                    && (txtMoneda.Text.Length > 0) && (txtOperacion.Text.Length > 0))
                                {
                                    CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
                                               ((EsGiro) ? ConsecutivoContrato : ConsecutivoOperacion),
                                               int.Parse(txtContabilidad.Text),
                                               int.Parse(txtOficina.Text),
                                               int.Parse(txtMoneda.Text),
                                               nProducto,
                                               long.Parse(txtOperacion.Text));
                                }

                                Session["Accion"] = string.Empty;

                                ExpandirValuaciones = -1;
                                ExpandirPolizas = -1;
                            }
                            else
                            {
                                LimpiarCampos();
                                contenedorDatosModificacion.Visible = false;
                                contenedorDatosModificacion.Controls.Clear();
                            }
                        }
                    }
                    else
                    {
                        //El usuario no tiene acceso a esta página
                        throw new Exception("ACCESO DENEGADO");
                    }
                }
                catch (Exception ex)
                {
                    if (ex.Message.StartsWith("ACCESO DENEGADO"))
                        Response.Redirect("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Acceso Denegado" +
                            "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_ACCESO_DENEGADO, Mensajes.ASSEMBLY) +
                            "&bBotonVisible=0");
                    else
                    {
                        Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_PAGINA_DETALLE, "del mantenimiento de garantías reales", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                        Response.Redirect("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Problemas Cargando Página" +
                            "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_CARGANDO_PAGINA, Mensajes.ASSEMBLY) +
                            "&bBotonVisible=0");
                    }
                }
            }
            else
            {
                //Se agrega dentro de un atributo la cadena que posee los indicadores de los campos que deben habilitarse (1) o no (0), según requerimiento Siebel No. 1-21317176  ---> 009 Req_Validaciones Indicador Inscripción, por AMM-Lidersoft Internacional S.A., el 17/07/2012
                //El orden de los campos es el siguiente: 1 (fecha de presentación), 0 (indicador de inscripción), 0 (monto mitigador) y 0 (porcentaje de aceptación).
                BloquearCamposIndicadorInscripcion = "1_0_0_0";

                CargaInicial = false;

                if ((this.gdvGarantiasReales.Rows.Count > 0) && (this.gdvGarantiasReales.Rows[0].Cells.Count > 0))
                {
                    if (this.gdvGarantiasReales.Rows[0].Cells[0].Text == "No existen registros")
                    {
                        int TotalColumns = this.gdvGarantiasReales.Rows[0].Cells.Count;
                        this.gdvGarantiasReales.Rows[0].Cells.Clear();
                        this.gdvGarantiasReales.Rows[0].Cells.Add(new TableCell());
                        this.gdvGarantiasReales.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        this.gdvGarantiasReales.Rows[0].Cells[0].Text = "No existen registros";
                    }
                }

                if ((Request.Form["__EVENTARGUMENT"] != null) && (Request.Form["__EVENTARGUMENT"].Length > 0) &&
                            (Request.Form["__EVENTARGUMENT"].CompareTo("Metodo") == 0))
                {
                    MostrarListaOperaciones = true;
                    MostrarErrorMontoMitigador = true;
                    MostrarErrorInfraSeguro = true;
                    MostrarErrorAcreenciasDiferentes = true;
                    MostrarErrorSinPolizaAsociada = true;
                    MostrarErrorPolizaInvalida = true;
                    MostrarErrorMontoPolizaCubreBien = true;
                    MostrarErrorFechaUltimoSeguimientoMayor = true;
                    MostrarErrorFechaValuacionMayor = true;
                    btnModificar_Click(sender, e);
                }
            }

            if(btnModificar.Enabled)
            {
                contenedorDatosModificacion.Visible = true;
            }
        }

        private void Button2_Click(object sender, System.EventArgs e)
        {
            FormatearCamposNumericos();
        }

        /// <summary>
        /// Este evento permite verificar si la información de la operación es valida
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnValidarOperacion_Click(object sender, System.EventArgs e)
        {
            int nProducto = -1;
            string numeroOperacion = string.Empty;

            BloquearCampos(false, true);

            FormatearCamposNumericos();

            EliminarDatosGlobales();
            Session["Tipo_Operacion"] = int.Parse(cbTipoCaptacion.SelectedValue.ToString());

            if (ValidarDatosOperacion())
            {
                string strProducto = ((int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString())) ? txtProducto.Text : string.Empty);
                DataSet dsDatos = new DataSet();

                try
                {
                    oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                    OleDbCommand oComando = new OleDbCommand("pa_ValidarOperaciones", oleDbConnection1);
                    oComando.CommandTimeout = 120;
                    oComando.CommandType = CommandType.StoredProcedure;
                    oComando.Parameters.AddWithValue("@Contabilidad", txtContabilidad.Text);
                    oComando.Parameters.AddWithValue("@Oficina", txtOficina.Text);
                    oComando.Parameters.AddWithValue("@Moneda", txtMoneda.Text);

                    if (strProducto.Length > 0)
                    {
                        oComando.Parameters.AddWithValue("@Producto", strProducto);
                    }
                    else
                    {
                        oComando.Parameters.AddWithValue("@Producto", DBNull.Value);
                    }

                    oComando.Parameters.AddWithValue("@Operacion", txtOperacion.Text);
                    oComando.Parameters["@Producto"].IsNullable = true;

                    numeroOperacion = ((strProducto.Length > 0) ? (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + strProducto + "-" + txtOperacion.Text) : (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + txtOperacion.Text));

                    OleDbDataAdapter cmdConsulta = new OleDbDataAdapter();

                    if ((oleDbConnection1 != null) && (oleDbConnection1.State == ConnectionState.Closed))
                    {
                        oleDbConnection1.Open();
                    }

                    cmdConsulta.SelectCommand = oComando;
                    cmdConsulta.SelectCommand.Connection = oleDbConnection1;
                    cmdConsulta.Fill(dsDatos, "Operacion");

                }
                catch (Exception ex)
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_VALIDANDO_OPERACION_DETALLE, (" '" + numeroOperacion + "'"), ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Validando Operación" +
                        "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_VALIDANDO_OPERACION, (" '" + numeroOperacion + "'"), Mensajes.ASSEMBLY) +
                        "&bBotonVisible=0");
                }
                finally
                {
                    if ((oleDbConnection1 != null) && (oleDbConnection1.State == ConnectionState.Open))
                    {
                        oleDbConnection1.Close();
                    }
                }

                ResetearCampos();

                try
                {
                    if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Operacion"].Rows.Count > 0))
                    {
                        EsGiro = (((dsDatos.Tables["Operacion"].Columns.Contains("esGiro")) && (!dsDatos.Tables["Operacion"].Rows[0].IsNull("esGiro")) && (dsDatos.Tables["Operacion"].Rows[0]["esGiro"].ToString().CompareTo("1") == 0)) ? true : false);

                        ConsecutivoContrato = (((dsDatos.Tables["Operacion"].Columns.Contains("consecutivoContrato")) && (!dsDatos.Tables["Operacion"].Rows[0].IsNull("consecutivoContrato"))) ? (long.Parse(dsDatos.Tables["Operacion"].Rows[0]["consecutivoContrato"].ToString())) : -1);

                        _contratoDelGiro = (((EsGiro) && (dsDatos.Tables["Operacion"].Columns.Contains("Contrato")) && (!dsDatos.Tables["Operacion"].Rows[0].IsNull("Contrato"))) ? (dsDatos.Tables["Operacion"].Rows[0]["Contrato"].ToString()) : string.Empty);

                        if (!EsGiro)
                        {
                            ConsecutivoOperacion = long.Parse(dsDatos.Tables["Operacion"].Rows[0]["cod_operacion"].ToString());

                            DatosOperacion = cbTipoCaptacion.SelectedItem.Value + "_" + txtOficina.Text + "_" + txtMoneda.Text + "_" + txtProducto.Text + "_" + txtOperacion.Text;

                            Session["Deudor"] = dsDatos.Tables["Operacion"].Rows[0]["cedula_deudor"].ToString();

                            if (txtProducto.Text.Length != 0)
                                nProducto = int.Parse(txtProducto.Text);

                            CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
                                        ((EsGiro) ? ConsecutivoContrato : ConsecutivoOperacion),
                                        int.Parse(txtContabilidad.Text),
                                        int.Parse(txtOficina.Text),
                                        int.Parse(txtMoneda.Text),
                                        nProducto,
                                        long.Parse(txtOperacion.Text));

                            lblDeudor.Visible = true;
                            lblNombreDeudor.Visible = true;

                            Session["Nombre_Deudor"] = dsDatos.Tables["Operacion"].Rows[0]["cedula_deudor"].ToString() + " - " +
                                                        dsDatos.Tables["Operacion"].Rows[0]["nombre_deudor"].ToString();

                            lblNombreDeudor.Text = Session["Nombre_Deudor"].ToString();
                            btnModificar.Enabled = false;
                            btnEliminar.Enabled = false;
                            Session["EsOperacionValidaReal"] = true;
                        }
                        else
                        {
                            BloquearCamposIndicadorInscripcion = "0_0_0_0";
                            BloquearCampos(false, true);
                            lblDeudor.Text = string.Empty;
                            lblNombreDeudor.Text = string.Empty;

                            gdvGarantiasReales.DataSource = null;
                            gdvGarantiasReales.DataBind();

                            lblMensaje.Text = Mensajes.Obtener(Mensajes._errorConsultaGiro, _contratoDelGiro, Mensajes.ASSEMBLY);
                        }
                    }
                    else
                    {
                        Session["EsOperacionValida"] = false;
                        lblDeudor.Visible = false;
                        lblNombreDeudor.Visible = false;
                        Session["Nombre_Deudor"] = "";

                        if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                            lblMensaje.Text = "La operación crediticia no existe en el sistema o se encuentra cancelada. Por favor verifique.";
                        else if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["CONTRATO"].ToString()))
                            lblMensaje.Text = "El contrato no existe en el sistema o se encuentra cancelada. Por favor verifique.";

                        gdvGarantiasReales.DataSource = null;
                        gdvGarantiasReales.DataBind();
                    }

                    lblGrado.Visible = false;
                    txtGrado.Visible = false;
                    lblCedula.Visible = false;
                    txtCedulaHipotecaria.Visible = false;
                }
                catch (Exception ex)
                {
                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_DETALLE, (" '" + numeroOperacion + "'"), ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Cargando Garantías" +
                        "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS, (" '" + numeroOperacion + "'"), Mensajes.ASSEMBLY) +
                        "&bBotonVisible=0");
                }
            }
        }

        private void cbInscripcion_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            FormatearCamposNumericos();
            if (cbInscripcion.SelectedItem.Text == string.Empty || int.Parse(cbInscripcion.SelectedValue.ToString()) == 0 || int.Parse(cbInscripcion.SelectedValue.ToString()) == 1)
            {
                txtFechaRegistro.Enabled = false;
                cleFechaRegistro.Enabled = false;
                igbCalendario.Visible = false;
            }
            else
            {
                txtFechaRegistro.Enabled = true;
                cleFechaRegistro.Enabled = true;
                igbCalendario.Visible = true;
            }
        }

        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

            try
            {
                FormatearCamposNumericos();
                LimpiarCampos();
                CargarCombos();
                btnModificar.Enabled = false;
                btnEliminar.Enabled = false;
                lblPartido.Text = "Partido:";
                lblFinca.Text = "Número Finca:";
                lblGrado.Visible = false;
                lblCedula.Visible = false;
                txtGrado.Visible = false;
                txtCedulaHipotecaria.Visible = false;
                cbTipoGarantiaReal.Enabled = true;

                BloquearCamposIndicadorInscripcion = "0_0_0_0";
                BloquearCampos(false, false);
                HabilitarValuacion = false;
                ExpandirValuaciones = -1;
                HabilitarPoliza = false;
                ExpandirPolizas = -1;

                contenedorDatosModificacion.Visible = false;
                contenedorDatosModificacion.Controls.Clear();
                
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "btnLimpiar_Click", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
            }
        }

        private void btnModificar_Click(object sender, System.EventArgs e)
        {

            lblMensaje3.Text = string.Empty;
            lblMensaje.Text = string.Empty;
            bool entidadValida = false;

            try
            {
                Session["Accion"] = "MODIFICAR";
                IndicadorBotonGuardar = true;

                GuardarDatosSession();              

                entidadGarantia = Entidad_Real;
                entidadGarantia.TramaInicial = TramaInicial;
                entidadGarantia.MostrarErrorRelacionTipoBienTipoPolizaSap = false;

                //Siebel 1-23914481. Se verifica si el error de validación de la entidad es debido al monto mitigador, ante lo cual el flujo corre
                //de forma normal, como si la entidad no tueviera errores, exceptuando si la inconsistencia es sobre una garantía inscrita y el 
                //monto es igual a 0 (cero).
                //Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.
                entidadValida = entidadGarantia.EntidadValida(true);

                if ((!entidadValida) && (entidadGarantia.ListaErroresValidaciones.Count == 0) &&
                   ((entidadGarantia.InconsistenciaMontoMitigador == 3) || (entidadGarantia.InconsistenciaMontoMitigador == 4)))
                {
                    entidadValida = true;
                }

                AplicarCalculoMontoMitigador();

                if (entidadValida)
                {
                    if ((!MostrarErrorMontoMitigador) || (!MostrarListaOperaciones) || (!MostrarErrorInfraSeguro) || (!MostrarErrorAcreenciasDiferentes)
                        || (!MostrarErrorSinPolizaAsociada) || (!MostrarErrorPolizaInvalida) || (!MostrarErrorMontoPolizaCubreBien)
                        || (!MostrarErrorFechaUltimoSeguimientoMayor) || (!MostrarErrorFechaValuacionMayor))
                    {
                        if ((entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.MontoMitigador))) ||
                            (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.ListaOperaciones))) ||
                            (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaNoAsociada))) ||
                            (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaInvalida))) ||
                            (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.MontoPolizaNoCubreBien))) ||
                            (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor))) ||
                            (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.FechaValuacionMayor)))
                            )
                        {
                            MostrarMensajesInformativos();
                            return;
                        }
                    }

                    ModificarGarantia();
                }
                else
                {
                    CargaInicial = true;
                    VerificarValidaciones(entidadGarantia, true);
                }

                contenedorDatosModificacion.Visible = true;
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA_DETALLE, "real", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                if ((ex.Source.CompareTo("-1") == 0) || (ex.Source.CompareTo("-2") == 0) ||
                    (ex.Source.CompareTo("-3") == 0) || (ex.Source.CompareTo("-4") == 0) ||
                    (ex.Source.CompareTo("-5") == 0))
                {
                    lblMensaje.Text = ex.Message;
                    lblMensaje.Visible = true;
                }
                else
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_MODIFICANDO_GARANTIA, "real", Mensajes.ASSEMBLY) +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasReales.aspx");
                }
            }
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                int nTipoGarantiaReal = int.Parse(cbTipoGarantiaReal.SelectedValue.ToString());

                Session["Accion"] = "ELIMINAR";
                GuardarDatosSession();

                //Se crea el dato correspondiente a operación crediticia que se almacenará en la bitácora
                strOperacionCrediticia = (txtContabilidad.Text.StartsWith("0") ? txtContabilidad.Text.Remove(0, 1) : txtContabilidad.Text) + "-" + 
                                        txtOficina.Text + "-" +
                                        (txtMoneda.Text.StartsWith("0")? txtMoneda.Text.Remove(0, 1) : txtMoneda.Text);               


                if (txtProducto.Visible)
                {
                   // strOperacionCrediticia += txtProducto.Text;
                    strOperacionCrediticia += "-" + (txtProducto.Text.StartsWith("0") ? txtProducto.Text.Remove(0, 1) : txtProducto.Text);
                }

                strOperacionCrediticia += "-" + txtOperacion.Text;

                if (nTipoGarantiaReal == int.Parse(Application["HIPOTECAS"].ToString()))
                {
                    strGarantia = "[H] " + txtPartido.Text + "-" + txtNumFinca.Text.Trim();
                }
                else if (nTipoGarantiaReal == int.Parse(Application["CEDULAS_HIPOTECARIAS"].ToString()))
                {
                    strGarantia = "[CH] " + txtPartido.Text + "-" + txtNumFinca.Text.Trim();
                }
                else if (nTipoGarantiaReal == int.Parse(Application["PRENDAS"].ToString()))
                {
                    //Clase de bien, numero placa
                    if (txtPartido.Text.Trim() != string.Empty)
                    {
                        strGarantia = "[P] " + txtPartido.Text + "-" + txtNumFinca.Text.Trim();
                    }
                    else
                    {
                        strGarantia = "[P] " + txtNumFinca.Text.Trim();
                    }
                }

                Gestor.EliminarGarantiaReal(ConsecutivoOperacion,
                                            ConsecutivoGarantia,
                                            Session["strUSER"].ToString(),
                                            Request.UserHostAddress.ToString(),
                                            strOperacionCrediticia, strGarantia);

                CargarCombos();
                LimpiarCampos();
                contenedorDatosModificacion.Visible = false;
                contenedorDatosModificacion.Controls.Clear();

                Response.Redirect("frmMensaje.aspx?" +
                                "bError=0" +
                                "&strTitulo=" + "Eliminación Exitosa" +
                                "&strMensaje=" + Mensajes.Obtener(Mensajes.ELIMINACION_SATISFACTORIA_GARANTIA, "real", Mensajes.ASSEMBLY) +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmGarantiasReales.aspx", false);
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ELIMINANDO_GARANTIA_DETALLE, "real", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                Response.Redirect("frmMensaje.aspx?" +
                                "bError=1" +
                                "&strTitulo=" + "Problemas Eliminando Registro" +
                                "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_ELIMINANDO_GARANTIA, "real", Mensajes.ASSEMBLY) +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmGarantiasReales.aspx");
            }
        }

        private void cbTipoCaptacion_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            try
            {
                //Campos llave
                FormatearCamposNumericos();
                txtOficina.Text = "";
                txtMoneda.Text = "";
                txtProducto.Text = "";
                txtOperacion.Text = "";
                ResetearCampos();
                gdvGarantiasReales.DataSource = null;
                gdvGarantiasReales.DataBind();

                if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    lblTipoOperacion.Text = "Operación:";
                    lblCatalogo.Text = "Garantías Reales de la Operación";
                    btnValidarOperacion.Text = "Validar Operación";
                    btnValidarOperacion.ToolTip = "Verifica que la operación sea válida";
                    Session["Tipo_Operacion"] = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                    lblProducto.Visible = true;
                    txtProducto.Visible = true;
                }
                else if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["CONTRATO"].ToString()))
                {
                    lblTipoOperacion.Text = "Contrato:";
                    lblCatalogo.Text = "Garantías Reales del Contrato";
                    btnValidarOperacion.Text = "Validar Contrato";
                    btnValidarOperacion.ToolTip = "Verifica que el contrato sea válido";
                    Session["Tipo_Operacion"] = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                    lblProducto.Visible = false;
                    txtProducto.Visible = false;
                }
                lblDeudor.Visible = false;
                lblNombreDeudor.Visible = false;

                HabilitarValuacion = false;
                ExpandirValuaciones = -1;
                HabilitarPoliza = false;
                ExpandirPolizas = -1;
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "cbTipoCaptacion_SelectedIndexChanged", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
            }
        }

        private void cbTipoGarantiaReal_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            try
            {
                FormatearCamposNumericos();
                LimpiarGarantiaReal();
                Session["EsCambioTipoGarantia"] = true;

                if (int.Parse(cbTipoGarantiaReal.SelectedValue.ToString()) == int.Parse(Application["HIPOTECAS"].ToString()))
                {
                    lblPartido.Text = "Partido:";
                    txtPartido.Enabled = true;
                    txtPartido.Visible = true;
                    lblFinca.Text = "Número Finca:";
                    txtNumFinca.Enabled = true;
                    lblGrado.Visible = false;
                    txtGrado.Visible = false;
                    lblCedula.Visible = false;
                    txtCedulaHipotecaria.Visible = false;
                }
                else if (int.Parse(cbTipoGarantiaReal.SelectedValue.ToString()) == int.Parse(Application["CEDULAS_HIPOTECARIAS"].ToString()))
                {
                    lblPartido.Text = "Partido:";
                    txtPartido.Enabled = true;
                    txtPartido.Visible = true;
                    lblFinca.Text = "Número Finca:";
                    txtNumFinca.Enabled = true;
                    lblGrado.Visible = true;
                    txtGrado.Visible = true;
                    lblCedula.Visible = true;
                    txtCedulaHipotecaria.Visible = true;
                }
                else if (int.Parse(cbTipoGarantiaReal.SelectedValue.ToString()) == int.Parse(Application["PRENDAS"].ToString()))
                {
                    lblPartido.Text = "Clase Bien:";
                    txtPartido.Enabled = true;
                    txtPartido.Visible = true;
                    lblFinca.Text = "Id Bien:";
                    txtNumFinca.Enabled = true;
                    lblGrado.Visible = false;
                    txtGrado.Visible = false;
                    lblCedula.Visible = false;
                    txtCedulaHipotecaria.Visible = false;
                }
                else
                {
                    Session["EsCambioTipoGarantia"] = false;
                }
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "cbTipoGarantiaReal_SelectedIndexChanged", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
            }
        }

        protected void cbTipoBien_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            try
            {
                int tipoBien = -1;
                int tipoGarantiaReal = int.Parse(((cbTipoGarantiaReal.Items.Count > 0) ? cbTipoGarantiaReal.SelectedItem.Value : "-1"));
                lblMensaje3.Text = string.Empty;
                lblMensaje.Text = string.Empty;                            
                
                if (tipoGarantiaReal != -1)
                {
                    Session["Accion"] = "CARGACOMBO";

                    tipoBien = int.Parse(((cbTipoBien.Items.Count > 0) ? cbTipoBien.SelectedItem.Value : "-1"));
                    
                    if (tipoBien == -1)
                    {
                        txtPorcentajeAceptacionCalculado.Text = "0.00";
                        txtPorcentajeAceptacion.Text = "0.00";
                        btnValidarOperacion.Attributes.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, "0.00");
                        ViewState.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, 0);
                    }

                    if ((tipoGarantiaReal != 1) && (porcentajeAceptacionCalculado == 0))
                    {
                        int tipoMitigador = int.Parse(((cbMitigador.Items.Count > 0) ? cbMitigador.SelectedItem.Value : "-1"));

                        if (tipoMitigador != -1)
                        {
                            porcentajeAceptacionCalculado = Gestor.ObtenerValorPorcentajeAceptacion(null, 2, tipoMitigador, 4);
                        }
                    }

                    if ((tipoBien > 4) || (porcentajeAceptacionCalculado == 0))
                    {
                        txtPorcentajeAceptacionCalculado.Text = txtPorcentajeAceptacion.Text;
                        btnValidarOperacion.Attributes.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, "0.00");
                        ViewState.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, 0);
                    }

                    if (tipoGarantiaReal == 1)
                    {
                        CargarTipoMitigador(tipoGarantiaReal, tipoBien);

                        if (cbMitigador.SelectedItem.Value.CompareTo("-1") != 0)
                        {
                            int tipoMitigadorSel = int.Parse(((cbMitigador.Items.Count > 0) ? cbMitigador.SelectedItem.Value : "-1"));
                        }

                        if (tipoBien != -1)
                        {
                            cbMitigador.Enabled = true;
                        }
                        else
                        {
                            cbMitigador.Enabled = false;
                        }
                    }

                    chkDeudorHabitaVivienda.Enabled = true;

                    if (tipoBien != 2)
                    {
                        chkDeudorHabitaVivienda.Enabled = false;
                        chkDeudorHabitaVivienda.Checked = false;
                    }
                                      

                    FiltrarPolizasSap(tipoBien);

                    BloquearCamposAvaluo();
                }

                contenedorDatosModificacion.Visible = true;
            }
            catch (Exception ex)
            {
                string numeroOperacion = ((txtProducto.Text.Length > 0) ? (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + txtProducto.Text + "-" + txtOperacion.Text) : (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + txtOperacion.Text));
                string numeroGarantia = ((gdvGarantiasReales.SelectedDataKey[3] != null) ? gdvGarantiasReales.SelectedDataKey[3].ToString() : "Sin Definir");
                StringCollection listaDatosError = new StringCollection();
                listaDatosError.Add(numeroGarantia);
                listaDatosError.Add(numeroOperacion);
                listaDatosError.Add(ex.Message);

                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS_DETALLE, listaDatosError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, numeroGarantia, numeroOperacion, Mensajes.ASSEMBLY);
            }
        }

        protected void cbMitigador_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            try
            {
                int tipoBien = -1;
                int tipoMitigador = int.Parse(((cbMitigador.Items.Count > 0) ? cbMitigador.SelectedItem.Value : "-1"));
                lblMensaje3.Text = string.Empty;
                lblMensaje.Text = string.Empty;               

                tipoBien = int.Parse(((cbTipoBien.Items.Count > 0) ? cbTipoBien.SelectedItem.Value : "-1"));

                GuardarDatosSession();

                entidadGarantia = Entidad_Real; // se ejecuta entidad valida
                
                #region Mantener Datos de la Póliza

                //decimal montoAcreenciaBien;

                //Session["Accion"] = "GARANTIA_MOD";

                //montoAcreenciaBien = Convert.ToDecimal((((txtMontoAcreenciaPoliza.Text.Length > 0) && (txtMontoAcreenciaPoliza.Text.CompareTo("0.00") != 0)) ? txtMontoAcreenciaPoliza.Text : "0"));
                              
                ////Datos de la póliza
                //if ((cbCodigoSap != null) && (cbCodigoSap.Items.Count > 0) && (cbCodigoSap.SelectedItem.Value.CompareTo("-1") != 0)
                //    && (entidadGarantia.PolizasSap.Count > 0))
                //{
                //    List<clsPolizaSap> listapolizaSap = entidadGarantia.PolizasSap.Items((int.Parse(cbCodigoSap.SelectedItem.Value)));

                //    if (listapolizaSap.Count > 0)
                //    {
                //        entidadGarantia.PolizasSap.QuitarSeleccion();

                //        clsPolizaSap entidadPolizaSap = listapolizaSap[0];

                //        entidadPolizaSap.PolizaSapSeleccionada = true;
                //        entidadPolizaSap.MontoAcreenciaPolizaSap = montoAcreenciaBien;

                //        entidadGarantia.PolizaSapAsociada = entidadPolizaSap;
                //    }
                //}
                //else
                //{
                //    entidadGarantia.PolizasSap.QuitarSeleccion();
                //    entidadGarantia.PolizaSapAsociada = null;
                //}           
              
                #endregion Mantener Datos de la Póliza
                               
                
                if (tipoMitigador != -1)
                {              

                    decimal porcentajeOriginal =  Gestor.ObtenerValorPorcentajeAceptacion(null, 2, tipoMitigador, 4);

                    porcentajeAceptacionCalculado = porcentajeOriginal;
                    entidadGarantia.PorcentajeAceptacionCalculadoOriginal = porcentajeOriginal;

                    entidadGarantia.EntidadValida(false); // true: validar campos requeridos esten con datos, false: aplica solo validaciones sin tomar en cuanta datos requeridos
                                 

                    if ((tipoBien > 4) || (porcentajeOriginal == 0)) 
                    {
                        txtPorcentajeAceptacionCalculado.Text = txtPorcentajeAceptacion.Text;
                        btnValidarOperacion.Attributes.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, "0.00");
                        ViewState.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, 0);
                    }
                    else
                    {
                        MostrarListaOperaciones = true;
                        VerificarValidaciones(entidadGarantia,false);

                        ////se debe validar para que  cuando da error el % calculado no sea borrado por el original                    
                        if (entidadGarantia.InconsistenciaPorcentajeAceptacionCalculado)
                        {
                            //porcentajeAceptacionCalculado = decimal.Parse(entidadGarantia.PorcentajeAceptacionCalculado.ToString("N2"));
                            btnValidarOperacion.Attributes.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, porcentajeAceptacionCalculado.ToString("N2"));
                            ViewState.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, porcentajeAceptacionCalculado.ToString("N2"));
                        }
                        else
                        {
                            txtPorcentajeAceptacionCalculado.Text = entidadGarantia.PorcentajeAceptacionCalculadoOriginal.ToString("N2");
                            porcentajeAceptacionCalculado = decimal.Parse((txtPorcentajeAceptacionCalculado.Text.Length > 0) ? txtPorcentajeAceptacionCalculado.Text : "0.00");
                            btnValidarOperacion.Attributes.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, porcentajeAceptacionCalculado.ToString("N2"));
                            ViewState.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, porcentajeAceptacionCalculado.ToString("N2"));                      

                        }   

                    }                                        
                }
                else
                {
                    txtPorcentajeAceptacionCalculado.Text = "0.00";
                    btnValidarOperacion.Attributes.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, "0.00");
                    ViewState.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, 0);
                }                               
                               
                BloquearCamposAvaluo();
                Entidad_Real = entidadGarantia; //guarda la informacion 
                contenedorDatosModificacion.Visible = true;

            }
            catch (Exception ex)
            {
                string numeroOperacion = ((txtProducto.Text.Length > 0) ? (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + txtProducto.Text + "-" + txtOperacion.Text) : (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + txtOperacion.Text));
                string numeroGarantia = ((gdvGarantiasReales.SelectedDataKey[3] != null) ? gdvGarantiasReales.SelectedDataKey[3].ToString() : "Sin Definir");
                string errorObtenido = "Error Porcentaje Aceptación Calculado: " + ex.Message;
                StringCollection listaDatosError = new StringCollection();
                listaDatosError.Add(numeroGarantia);
                listaDatosError.Add(numeroOperacion);
                listaDatosError.Add(errorObtenido);

                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS_DETALLE, listaDatosError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, numeroGarantia, numeroOperacion, Mensajes.ASSEMBLY);
            }
        }

        #endregion

        #region Métodos GridView

        protected void gdvGarantiasReales_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvGarantiasReales = (GridView)sender;
            int rowIndex = 0;
            bool bloquearControles = false;
            int tipoGarantiaReal = -1;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedGarantiaReal"):

                        LimpiarCampos();                      

                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvGarantiasReales.SelectedIndex = rowIndex;

                        ConsecutivoGarantia = long.Parse(gdvGarantiasReales.SelectedDataKey[1].ToString());
                        DescripcionGarantia = gdvGarantiasReales.SelectedDataKey[3].ToString();

                        tipoGarantiaReal = int.Parse(gdvGarantiasReales.SelectedDataKey[2].ToString());

                        AnnosCalculoFechaPrescripcion = ObtenerCantidadAnnosPrescripcion(tipoGarantiaReal);

                        lblMensaje.Text = "";
                        lblMensaje3.Text = "";

                        CargaInicial = true;

                        CargarDatosGarantia(((EsGiro) ? ConsecutivoContrato : ConsecutivoOperacion), ConsecutivoGarantia, DescripcionGarantia, out bloquearControles, true, tipoGarantiaReal);

                        if (!bloquearControles)
                        {
                            cbTipoGarantiaReal.Enabled = false;
                            btnModificar.Enabled = true;
                            btnEliminar.Enabled = true;
                        }

                        break;
                }
            }
            catch (Exception ex)
            {
                string numeroOperacion = ((txtProducto.Text.Length > 0) ? (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + txtProducto.Text + "-" + txtOperacion.Text) : (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + txtOperacion.Text));
                string numeroGarantia = ((gdvGarantiasReales.SelectedDataKey[3] != null) ? gdvGarantiasReales.SelectedDataKey[3].ToString() : "Sin Definir");
                StringCollection listaDatosError = new StringCollection();
                listaDatosError.Add(numeroGarantia);
                listaDatosError.Add(numeroOperacion);
                listaDatosError.Add(ex.Message);

                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS_DETALLE, listaDatosError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, numeroGarantia, numeroOperacion, Mensajes.ASSEMBLY);
                ErrorGrave = true;
                BloquearCampos(false, true);
                BloquearCamposAvaluo();
            }
        }

        protected void gdvGarantiasReales_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvGarantiasReales.SelectedIndex = -1;
            this.gdvGarantiasReales.PageIndex = e.NewPageIndex;

            int nProducto = -1;

            if (txtProducto.Text.Length > 0)
                nProducto = int.Parse(txtProducto.Text);

            try
            {
                CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
                           ((EsGiro) ? ConsecutivoContrato : ConsecutivoOperacion),
                           int.Parse(txtContabilidad.Text),
                           int.Parse(txtOficina.Text),
                           int.Parse(txtMoneda.Text),
                           nProducto,
                           long.Parse(txtOperacion.Text));
            }
            catch (Exception ex)
            {
                string numeroOperacion = ((txtProducto.Text.Length > 0) ? (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + txtProducto.Text + "-" + txtOperacion.Text) : (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + txtOperacion.Text));

                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_DETALLE, (" '" + numeroOperacion + "'"), ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS, (" '" + numeroOperacion + "'"), Mensajes.ASSEMBLY);
            }
        }

        protected void gdvGarantiasReales_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                LinkButton tipoGarantia = ((LinkButton)e.Row.Cells[0].Controls[0]);
                LinkButton garantia = ((LinkButton)e.Row.Cells[1].Controls[0]);

                tipoGarantia.Attributes.Add("onclick", "javascript:return CargarPagina();" + this.Page.ClientScript.GetPostBackClientHyperlink(this.gdvGarantiasReales, "SelectedGarantiaReal$" + e.Row.RowIndex));
                garantia.Attributes.Add("onclick", "javascript:return CargarPagina();" + this.Page.ClientScript.GetPostBackClientHyperlink(this.gdvGarantiasReales, "SelectedGarantiaReal$" + e.Row.RowIndex));
            }
        }

        #endregion

        #region Métodos Privados

        /// <summary>
        /// Este método permite limpiar los campos del formulario
        /// </summary>
        private void LimpiarCampos()
        {
            try
            {
                txtPartido.Text = string.Empty;
                txtNumFinca.Text = string.Empty;
                txtGrado.Text = string.Empty;
                txtCedulaHipotecaria.Text = string.Empty;
                txtMontoMitigador.Text = string.Empty;
                txtPorcentajeAceptacion.Text = string.Empty;
                txtFechaRegistro.Text = string.Empty;
                txtFechaConstitucion.Text = string.Empty;
                txtFechaPrescripcion.Text = string.Empty;
                txtFechaVencimiento.Text = string.Empty;
                lblMensaje.Text = string.Empty;
                lblMensaje3.Text = string.Empty;

                #region Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

                txtMontoMitigadorCalculado.Text = "";

                #endregion Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

                txtFechaValuacion.Text = string.Empty;
                txtFechaValuacionSICC.Text = string.Empty;
                txtMontoAvaluo.Text = string.Empty;
                txtMontoUltTasacionTerreno.Text = string.Empty;
                txtMontoUltTasacionNoTerreno.Text = string.Empty;
                txtMontoTasActTerreno.Text = string.Empty;
                txtMontoTasActNoTerreno.Text = string.Empty;
                txtFechaSeguimiento.Text = string.Empty;
                txtFechaConstruccion.Text = string.Empty;

                cbCodigoSap.SelectedIndex = -1;
                txtMontoPoliza.Text = string.Empty; 
                cbMonedaPoliza.SelectedIndex = -1;
                txtCedulaAcreedorPoliza.Text = string.Empty;
                txtNombreAcreedorPoliza.Text = string.Empty;
                txtFechaVencimientoPoliza.Text = string.Empty;
                txtMontoAcreenciaPoliza.Text = string.Empty;
                txtDetallePoliza.Text = string.Empty;
                rdlEstadoPoliza.SelectedIndex = -1;

                #region Siebel 1-24613011. Realizado por: Leonardo Cortés Mora. - Lidersoft Internacional S.A., 12/12/2014.

                txtPorcentajeAceptacionCalculado.Text = string.Empty;

                #endregion Siebel 1-24613011. Realizado por: Leonardo Cortés Mora. - Lidersoft Internacional S.A., 12/12/2014.

            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "LimpiarCampos", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
            }
        }

        /// <summary>
        /// Este método permite limpiar los campos del formulario
        /// </summary>
        private void ResetearCampos()
        {
            try
            {
                txtPartido.Text = string.Empty;
                txtNumFinca.Text = string.Empty;
                txtGrado.Text = string.Empty;
                txtCedulaHipotecaria.Text = string.Empty;
                txtMontoMitigador.Text = string.Empty;
                txtPorcentajeAceptacion.Text = string.Empty;
                txtFechaRegistro.Text = string.Empty;
                txtFechaConstitucion.Text = string.Empty;
                txtFechaPrescripcion.Text = string.Empty;
                txtFechaVencimiento.Text = string.Empty;
                lblMensaje.Text = string.Empty;
                lblMensaje3.Text = string.Empty;

                #region Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

                txtMontoMitigadorCalculado.Text = string.Empty;

                #endregion Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

                cbClase.ClearSelection();
                cbClase.Items.Clear();

                cbGravamen.ClearSelection();
                cbGravamen.Items.Clear();

                cbInscripcion.ClearSelection();
                cbInscripcion.Items.Clear();

                cbMitigador.ClearSelection();
                cbMitigador.Items.Clear();

                cbTipoAcreedor.ClearSelection();
                cbTipoAcreedor.Items.Clear();

                cbTipoBien.ClearSelection();
                cbTipoBien.Items.Clear();

                cbTipoDocumento.ClearSelection();
                cbTipoDocumento.Items.Clear();

                cbTipoGarantiaReal.ClearSelection();
                cbTipoGarantiaReal.Items.Clear();

                txtFechaValuacion.Text = string.Empty;
                txtFechaValuacionSICC.Text = string.Empty;
                txtMontoAvaluo.Text = string.Empty;
                txtMontoUltTasacionTerreno.Text = string.Empty;
                txtMontoUltTasacionNoTerreno.Text = string.Empty;
                txtMontoTasActTerreno.Text = string.Empty;
                txtMontoTasActNoTerreno.Text = string.Empty;
                txtFechaSeguimiento.Text = string.Empty;
                txtFechaConstruccion.Text = string.Empty;

                cbEmpresa.ClearSelection();
                cbEmpresa.Items.Clear();

                cbPerito.ClearSelection();
                cbPerito.Items.Clear();

                cbCodigoSap.ClearSelection();
                cbCodigoSap.Items.Clear(); 
                txtMontoPoliza.Text = string.Empty;
                cbMonedaPoliza.ClearSelection();
                cbMonedaPoliza.Items.Clear();
                txtCedulaAcreedorPoliza.Text = string.Empty;
                txtNombreAcreedorPoliza.Text = string.Empty;
                txtFechaVencimientoPoliza.Text = string.Empty;
                txtMontoAcreenciaPoliza.Text = string.Empty;
                txtDetallePoliza.Text = string.Empty;
                rdlEstadoPoliza.SelectedIndex = -1;

                #region Siebel 1-24613011. Realizado por: Leonardo Cortés Mora. - Lidersoft Internacional S.A., 12/12/2014.

                txtPorcentajeAceptacionCalculado.Text = string.Empty;

                #endregion Siebel 1-24613011. Realizado por: Leonardo Cortés Mora. - Lidersoft Internacional S.A., 12/12/2014.
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "ResetearCampos", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
            }
        }

        /// <summary>
        /// Este método permite bloquear o desbloquear los campos del formulario
        /// </summary>
        /// <param name="bBloqueado">Indica si los controles están bloqueados o no</param>
        private void BloquearCampos(bool bBloqueado, bool? cargaInicial)
        {
            try
            {
                bool bloqueoInicial = (cargaInicial.HasValue) ? ((bool)cargaInicial) : false;

                if (bloqueoInicial)
                {
                    LimpiarCampos();
                }

                cbTipoGarantiaReal.Enabled = false;
                txtGrado.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                txtCedulaHipotecaria.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                cbTipoBien.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                cbMitigador.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                txtMontoMitigador.Enabled = BloquearMontoMitigador;
                txtFechaRegistro.Enabled = BloquearFechaPresentacion;
                cleFechaRegistro.Enabled = BloquearFechaPresentacion;
                igbCalendario.Enabled = BloquearFechaPresentacion;
                txtPorcentajeAceptacion.Enabled = BloquearPorcentajeAceptacion;
                txtFechaSeguimiento.Enabled = false;
                igbCalendarioSeguimiento.Enabled = false;
                chkDeudorHabitaVivienda.Enabled = ((bloqueoInicial) ? false : bBloqueado);

                //Avalúo
                cbEmpresa.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                cbPerito.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                txtMontoUltTasacionTerreno.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                txtMontoUltTasacionNoTerreno.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                txtFechaSeguimiento.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                igbCalendarioSeguimiento.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                txtFechaConstruccion.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                igbCalendarioConstruccion.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                txtMontoTasActTerreno.Enabled = ((bloqueoInicial) ? false : ((BloquearCamposMTATMTANT) ? false : true));
                txtMontoTasActNoTerreno.Enabled = ((bloqueoInicial) ? false : ((BloquearCamposMTATMTANT) ? false : true));

                //Pólizas
                cbCodigoSap.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                txtMontoAcreenciaPoliza.Enabled = ((bloqueoInicial) ? false : bBloqueado);

                //Botones
                btnLimpiar.Enabled = ((bloqueoInicial) ? false : bBloqueado);
                btnModificar.Enabled = bBloqueado;
                btnEliminar.Enabled = bBloqueado;
                //Mensajes
                lblMensaje.Text = "";
                lblMensaje3.Text = "";
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "BloquearCampos", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
            }
        }

        private void FormatearCamposNumericos()
        {
            System.Globalization.NumberFormatInfo a = new System.Globalization.NumberFormatInfo();
            a.NumberDecimalSeparator = ".";
        }

        private void CargarGrid(int nTipoOperacion, long nCodOperacion, int nContabilidad,
                                int nOficina, int nMoneda, int nProducto, long nOperacion)
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

            using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
            {
                SqlCommand oComando = null;

                if (nTipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                    oComando = new SqlCommand("pa_ObtenerGarantiasRealesOperaciones", oConexion);
                else if (nTipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
                    oComando = new SqlCommand("pa_ObtenerGarantiasRealesContratos", oConexion);

                SqlDataAdapter oDataAdapter = new SqlDataAdapter();
                //declara las propiedades del comando
                oComando.CommandType = CommandType.StoredProcedure;
                oComando.CommandTimeout = 120;
                oComando.Parameters.AddWithValue("@nCodOperacion", nCodOperacion);
                oComando.Parameters.AddWithValue("@nContabilidad", nContabilidad);
                oComando.Parameters.AddWithValue("@nOficina", nOficina);
                oComando.Parameters.AddWithValue("@nMoneda", nMoneda);

                if (nTipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    oComando.Parameters.AddWithValue("@nProducto", nProducto);
                    oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
                }
                else if (nTipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
                {
                    oComando.Parameters.AddWithValue("@nContrato", nOperacion);
                }

                oComando.Parameters.AddWithValue("@IDUsuario", Global.UsuarioSistema);


                //Abre la conexión
                oConexion.Open();
                oDataAdapter.SelectCommand = oComando;
                oDataAdapter.SelectCommand.Connection = oConexion;
                oDataAdapter.Fill(dsDatos, "Datos");

                if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Datos"].Rows.Count > 0))
                {

                    if ((!dsDatos.Tables["Datos"].Rows[0].IsNull("tipo_garantia_real")) &&
                        (!dsDatos.Tables["Datos"].Rows[0].IsNull("Garantia_Real")))
                    {
                        this.gdvGarantiasReales.DataSource = dsDatos.Tables["Datos"].DefaultView;
                        this.gdvGarantiasReales.DataBind();
                    }
                    else
                    {
                        dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
                        this.gdvGarantiasReales.DataSource = dsDatos;
                        this.gdvGarantiasReales.DataBind();

                        int TotalColumns = this.gdvGarantiasReales.Rows[0].Cells.Count;
                        this.gdvGarantiasReales.Rows[0].Cells.Clear();
                        this.gdvGarantiasReales.Rows[0].Cells.Add(new TableCell());
                        this.gdvGarantiasReales.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        this.gdvGarantiasReales.Rows[0].Cells[0].Text = "No existen registros";
                    }
                }
                else
                {
                    dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
                    this.gdvGarantiasReales.DataSource = dsDatos;
                    this.gdvGarantiasReales.DataBind();

                    int TotalColumns = this.gdvGarantiasReales.Rows[0].Cells.Count;
                    this.gdvGarantiasReales.Rows[0].Cells.Clear();
                    this.gdvGarantiasReales.Rows[0].Cells.Add(new TableCell());
                    this.gdvGarantiasReales.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                    this.gdvGarantiasReales.Rows[0].Cells[0].Text = "No existen registros";
                }

                //Se cambia el puntero del cursor
                if (requestSM != null && requestSM.IsInAsyncPostBack)
                {
                    ScriptManager.RegisterClientScriptBlock(this,
                                                            typeof(Page),
                                                            Guid.NewGuid().ToString(),
                                                            "<script type=\"text/javascript\" language=\"javascript\">document.body.style.cursor = 'default'; </script>",
                                                            false);
                }
                else
                {
                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                           Guid.NewGuid().ToString(),
                                                           "<script type=\"text/javascript\" language=\"javascript\">document.body.style.cursor = 'default'; </script>",
                                                           false);
                }

            }
        }

        /// <summary>
        /// Método que carga la información de la garantía que se encuentra almacenada en el objeto Session.
        /// </summary>
        private void CargarDatosSession(bool obtenerDatosBD)
        {
            try
            {
                bool bloquearControles = false;

                //Campos llave
                if (TipoOperacion.Length > 0)
                {
                    cbTipoCaptacion.ClearSelection();
                    cbTipoCaptacion.Items.FindByValue(TipoOperacion).Selected = true;
                }

                txtContabilidad.Text = "1";

                if (OficinaOperacion.Length > 0)
                    txtOficina.Text = OficinaOperacion;

                if (MonedaOperacion.Length > 0)
                    txtMoneda.Text = MonedaOperacion;

                if (TipoOperacion.CompareTo(Application["OPERACION_CREDITICIA"].ToString()) == 0)
                {
                    lblProducto.Visible = true;
                    txtProducto.Visible = true;

                    if (ProductoOperacion.Length > 0)
                        txtProducto.Text = ProductoOperacion;
                }
                else
                {
                    lblProducto.Visible = false;
                    txtProducto.Visible = false;
                }

                if (NumeroOperacion.Length > 0)
                    txtOperacion.Text = NumeroOperacion;

                CargarDatosGarantia(((EsGiro) ? ConsecutivoContrato : ConsecutivoOperacion), ConsecutivoGarantia, DescripcionGarantia, out bloquearControles, obtenerDatosBD, CodigoTipoGarantiaReal);

                if (!bloquearControles)
                {
                    cbTipoGarantiaReal.Enabled = false;
                    btnModificar.Enabled = true;
                    btnEliminar.Enabled = true;
                    lblMensaje.Text = "";
                    lblMensaje3.Text = "";
                }
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_SESION_DETALLE, "CargarDatosSession", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_SESION, Mensajes.ASSEMBLY);
            }
        }

        /// <summary>
        /// Este método guarda los datos de la pantalla en el objeto Session
        /// </summary>
        private void GuardarDatosSession()
        {
            int indicePanel;
            int indicePanelPoliza;

            try
            {
                #region Conversión e inicialización de datos

                Dictionary<string, string> listaDescripcionValoresActualesCombos = new Dictionary<string, string>();
                decimal nPorcentaje;
                int nTipoDocumento;
                DateTime dFechaPresentacion;
                DateTime dFechaVencimiento;
                int nPartido = -1;
                string strFinca = "";
                int nGrado = -1;
                int nCedulaFiduciaria = -1;
                string strClaseBien = "";
                string strNumPlaca = "";

                long nOperacion = ConsecutivoOperacion;
                int nTipoGarantia = int.Parse(Application["GARANTIA_REAL"].ToString());
                int nTipoGarantiaReal = int.Parse(cbTipoGarantiaReal.SelectedValue.ToString());
                int nClaseGarantia = int.Parse(cbClase.SelectedValue.ToString());

                //Datos del avalúo
                DateTime fechaValuacion;
                DateTime fechaValuacionSICC;
                DateTime fechaUltimoSeguimiento;
                DateTime fechaConstruccion;

                decimal montoUltTasacionTerreno;
                decimal montoUltTasacionNoTerreno;
                decimal montoTasacionActTerreno;
                decimal montoTasacionActNoTerreno;
                decimal montoTotalAvaluo;

                decimal montoAcreenciaBien;

                if (nTipoGarantiaReal == int.Parse(Application["HIPOTECAS"].ToString()))
                {
                    nPartido = int.Parse(((txtPartido.Text.Length > 0) ? txtPartido.Text : "-1"));
                    strFinca = txtNumFinca.Text.Trim();

                    strGarantia = "[H] " + txtPartido.Text + "-" + txtNumFinca.Text.Trim();
                }
                else if (nTipoGarantiaReal == int.Parse(Application["CEDULAS_HIPOTECARIAS"].ToString()))
                {
                    nPartido = int.Parse(((txtPartido.Text.Length > 0) ? txtPartido.Text : "-1"));
                    strFinca = txtNumFinca.Text.Trim();
                    nGrado = int.Parse(((txtGrado.Text.Length > 0) ? txtGrado.Text : "-1"));
                    nCedulaFiduciaria = int.Parse(((txtCedulaHipotecaria.Text.Length > 0) ? txtCedulaHipotecaria.Text : "-1"));

                    strGarantia = "[CH] " + txtPartido.Text + "-" + txtNumFinca.Text.Trim();
                }
                else if (nTipoGarantiaReal == int.Parse(Application["PRENDAS"].ToString()))
                {
                    strClaseBien = txtPartido.Text;
                    strNumPlaca = txtNumFinca.Text.Trim();

                    if (txtPartido.Text.Trim() != string.Empty)
                    {
                        strGarantia = "[P] " + txtPartido.Text + "-" + txtNumFinca.Text.Trim();
                    }
                    else
                    {
                        strGarantia = "[P] " + txtNumFinca.Text.Trim();
                    }
                }

                int nTipoBien = int.Parse(cbTipoBien.SelectedValue.ToString());
                int nTipoMitigador = int.Parse(cbMitigador.SelectedValue.ToString());
                nTipoDocumento = int.Parse(cbTipoDocumento.SelectedValue.ToString());
                decimal nMontoMitigador = Convert.ToDecimal(((txtMontoMitigador.Text.Length > 0) ? txtMontoMitigador.Text : "-1"));
                int nInscripcion = int.Parse(cbInscripcion.SelectedValue.ToString());

                if (txtFechaRegistro.Text.Trim().Length > 0)
                    dFechaPresentacion = DateTime.Parse(txtFechaRegistro.Text.ToString());
                else
                    dFechaPresentacion = DateTime.Parse("1900-01-01");

                nPorcentaje = Convert.ToDecimal(((txtPorcentajeAceptacion.Text.Trim().Length > 0) ? txtPorcentajeAceptacion.Text : "-1"));


                DateTime dFechaConstitucion = DateTime.Parse(((txtFechaConstitucion.Text.Length > 0) ? txtFechaConstitucion.Text : "1900-01-01"));
                int nGradoGravamen = int.Parse(cbGravamen.SelectedValue.ToString());
                int nTipoAcreedor = int.Parse(cbTipoAcreedor.SelectedValue.ToString());
                string strAcreedor = txtAcreedor.Text.Trim();

                if (txtFechaVencimiento.Text.Trim().Length > 0)
                    dFechaVencimiento = DateTime.Parse(((txtFechaVencimiento.Text.Length > 0) ? txtFechaVencimiento.Text : "1900-01-01"));
                else
                    dFechaVencimiento = DateTime.Parse("1900-01-01");

                DateTime dFechaPrescripcion = DateTime.Parse(((txtFechaPrescripcion.Text.Length > 0) ? txtFechaPrescripcion.Text : "1900-01-01"));


                //Se crea el dato correspondiente a operación crediticia que se almacenará en la bitácora
                strOperacionCrediticia = (txtContabilidad.Text.StartsWith("0") ? txtContabilidad.Text.Remove(0, 1) : txtContabilidad.Text) + "-" + 
                                         txtOficina.Text + "-" +
                                         (txtMoneda.Text.StartsWith("0")? txtMoneda.Text.Remove(0, 1) : txtMoneda.Text);

                if (txtProducto.Visible)
                {
                   // strOperacionCrediticia += "-" + txtProducto.Text;
                    strOperacionCrediticia += "-" + (txtProducto.Text.StartsWith("0")? txtProducto.Text.Remove(0, 1) : txtProducto.Text);
                }

                strOperacionCrediticia += "-" + txtOperacion.Text;

                #region Datos del avalúo

                fechaValuacion = DateTime.Parse(((txtFechaValuacion.Text.Length > 0) ? txtFechaValuacion.Text : "1900-01-01"));
                fechaValuacionSICC = DateTime.Parse(((txtFechaValuacionSICC.Text.Length > 0) ? txtFechaValuacionSICC.Text : "1900-01-01"));
                fechaUltimoSeguimiento = DateTime.Parse(((txtFechaSeguimiento.Text.Length > 0) ? txtFechaSeguimiento.Text : "1900-01-01"));
                fechaConstruccion = DateTime.Parse(((txtFechaConstruccion.Text.Length > 0) ? txtFechaConstruccion.Text : "1900-01-01"));

                montoUltTasacionTerreno = Convert.ToDecimal((((txtMontoUltTasacionTerreno.Text.Length > 0) && (txtMontoUltTasacionTerreno.Text.CompareTo("0.00") != 0)) ? txtMontoUltTasacionTerreno.Text : "0"));
                montoUltTasacionNoTerreno = Convert.ToDecimal((((txtMontoUltTasacionNoTerreno.Text.Length > 0) && (txtMontoUltTasacionNoTerreno.Text.CompareTo("0.00") != 0)) ? txtMontoUltTasacionNoTerreno.Text : "0"));
                montoTasacionActTerreno = Convert.ToDecimal(((txtMontoTasActTerreno.Text.Length > 0) ? txtMontoTasActTerreno.Text : "0"));
                montoTasacionActNoTerreno = Convert.ToDecimal(((txtMontoTasActNoTerreno.Text.Length > 0) ? txtMontoTasActNoTerreno.Text : "0"));

                montoTotalAvaluo = ((montoUltTasacionTerreno > 0) ? montoUltTasacionTerreno : 0) + ((montoUltTasacionNoTerreno > 0) ? montoUltTasacionNoTerreno : 0);

                BloquearCamposMTATMTANT = (((nTipoBien == 1) || (nTipoBien == 2)) ? true : false);

                #endregion Datos del avalúo

                #region Datos de la Póliza

                montoAcreenciaBien = Convert.ToDecimal((((txtMontoAcreenciaPoliza.Text.Length > 0) && (txtMontoAcreenciaPoliza.Text.CompareTo("0.00") != 0)) ? txtMontoAcreenciaPoliza.Text : "0"));
                
                #endregion Datos de la Póliza

                #endregion Conversión e inicialización de datos

                #region Carga de la entidad

                entidadGarantia = Entidad_Real;
                entidadGarantia.TramaInicial = TramaInicial;

                entidadGarantia.OperacionesRelacionadas = entidadGarantia.ObtenerListaOperaciones(entidadGarantia.TramaInicial);
                entidadGarantia.PolizasSap = entidadGarantia.ObtenerListaPolizas(entidadGarantia.TramaInicial);

                entidadGarantia.TipoOperacion = short.Parse(cbTipoCaptacion.SelectedItem.Value);
                entidadGarantia.Contabilidad = short.Parse(txtContabilidad.Text);
                entidadGarantia.Oficina = short.Parse(txtOficina.Text);
                entidadGarantia.MonedaOper = short.Parse(txtMoneda.Text);
                entidadGarantia.Producto = short.Parse(((txtProducto.Visible) ? txtProducto.Text : "-1"));
                entidadGarantia.NumeroOperacion = long.Parse(txtOperacion.Text);
                entidadGarantia.CodOperacion = nOperacion;
                entidadGarantia.CodGarantiaReal = ConsecutivoGarantia;
                entidadGarantia.CodTipoGarantia = ((short)nTipoGarantia);
                entidadGarantia.CodClaseGarantia = ((short)nClaseGarantia);
                entidadGarantia.CodTipoGarantiaReal = ((short)nTipoGarantiaReal);
                entidadGarantia.CodPartido = ((short)nPartido);
                entidadGarantia.NumeroFinca = strFinca;
                entidadGarantia.CodGrado = nGrado.ToString();
                entidadGarantia.CedulaHipotecaria = nCedulaFiduciaria.ToString();
                entidadGarantia.CodClaseBien = strClaseBien;
                entidadGarantia.NumPlacaBien = strNumPlaca;
                entidadGarantia.CodTipoBien = ((short)nTipoBien);
                entidadGarantia.CodTipoMitigador = ((short)nTipoMitigador);
                entidadGarantia.CodTipoDocumentoLegal = ((short)nTipoDocumento);
                entidadGarantia.MontoMitigador = nMontoMitigador;
                entidadGarantia.CodInscripcion = ((short)nInscripcion);
                entidadGarantia.FechaPresentacion = dFechaPresentacion;
                entidadGarantia.PorcentajeResponsabilidad = nPorcentaje;
                entidadGarantia.CodGradoGravamen = ((short)nGradoGravamen);
                entidadGarantia.FechaConstitucion = dFechaConstitucion;
                entidadGarantia.FechaVencimiento = dFechaVencimiento;
                entidadGarantia.CodTipoAcreedor = ((short)nTipoAcreedor);
                entidadGarantia.CedulaAcreedor = strAcreedor;
                entidadGarantia.FechaPrescripcion = dFechaPrescripcion;
                entidadGarantia.Operacion = strOperacionCrediticia;
                entidadGarantia.Garantia = strGarantia;
                entidadGarantia.FechaModifico = DateTime.Now;

                string porAceptCalc = (((ViewState[LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO] != null) && (ViewState[LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO].ToString().Length > 0)) ? ViewState[LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO].ToString() : "0.00");

                entidadGarantia.PorcentajeAceptacionCalculado = Convert.ToDecimal((txtPorcentajeAceptacionCalculado.Text.Length > 0) ? txtPorcentajeAceptacionCalculado.Text : porAceptCalc);

                porcentajeAceptacionCalculado = decimal.Parse(porAceptCalc);
               
                entidadGarantia.IndicadorViviendaHabitadaDeudor = ((nTipoBien != 2) ? false: chkDeudorHabitaVivienda.Checked);

               //Datos del avalúo
                entidadGarantia.FechaValuacion = fechaValuacion;
                entidadGarantia.FechaUltimoSeguimiento = fechaUltimoSeguimiento;
                entidadGarantia.FechaConstruccion = fechaConstruccion;

                entidadGarantia.MontoUltimaTasacionTerreno = montoUltTasacionTerreno;
                entidadGarantia.MontoUltimaTasacionNoTerreno = montoUltTasacionNoTerreno;
                entidadGarantia.MontoTasacionActualizadaTerreno = montoTasacionActTerreno;
                entidadGarantia.MontoTasacionActualizadaNoTerreno = montoTasacionActNoTerreno;
                entidadGarantia.MontoTotalAvaluo = montoTotalAvaluo;

                entidadGarantia.CedulaPerito = (((cbPerito.Items.Count > 0) && (cbPerito.SelectedItem != null)) ? cbPerito.SelectedItem.Value : string.Empty);
                entidadGarantia.CedulaEmpresa = (((cbEmpresa.Items.Count > 0) && (cbEmpresa.SelectedItem != null)) ? cbEmpresa.SelectedItem.Value : string.Empty);

                entidadGarantia.AvaluoActualizado = AvaluoActualizado;
                entidadGarantia.FechaSemestreCalculado = FechaSemestreActualizado;

                //Datos generales
                listaDescripcionValoresActualesCombos.Add(clsGarantiaReal._codTipoBien, cbTipoBien.SelectedItem.Text);
                listaDescripcionValoresActualesCombos.Add(clsGarantiaReal._codTipoDocumentoLegal, cbTipoDocumento.SelectedItem.Text);
                listaDescripcionValoresActualesCombos.Add(clsGarantiaReal._codGradoGravamen, cbGravamen.SelectedItem.Text);
                listaDescripcionValoresActualesCombos.Add(clsGarantiaReal._codInscripcion, cbInscripcion.SelectedItem.Text);
                listaDescripcionValoresActualesCombos.Add(clsGarantiaReal._codTipoMitigador, cbMitigador.SelectedItem.Text);
                listaDescripcionValoresActualesCombos.Add(clsGarantiaReal._codTipoAcreedor, cbTipoAcreedor.SelectedItem.Text);
                listaDescripcionValoresActualesCombos.Add(clsGarantiaReal._cedulaPerito, (((cbPerito.Items.Count > 0) && (cbPerito.SelectedItem != null)) ? cbPerito.SelectedItem.Text : string.Empty));
                listaDescripcionValoresActualesCombos.Add(clsGarantiaReal._cedulaEmpresa, (((cbEmpresa.Items.Count > 0) && (cbEmpresa.SelectedItem != null)) ? cbEmpresa.SelectedItem.Text : string.Empty));

                entidadGarantia.ListaDescripcionValoresActualesCombos = listaDescripcionValoresActualesCombos;

                //Datos de la póliza
                if ((cbCodigoSap != null) && (cbCodigoSap.Items.Count > 0) && (cbCodigoSap.SelectedItem.Value.CompareTo("-1") != 0) 
                    && (entidadGarantia.PolizasSap.Count > 0))
                {
                    List<clsPolizaSap> listapolizaSap = entidadGarantia.PolizasSap.Items((int.Parse(cbCodigoSap.SelectedItem.Value)), nTipoBien);

                    if (listapolizaSap.Count > 0)
                    {
                        entidadGarantia.PolizasSap.QuitarSeleccion();

                        clsPolizaSap entidadPolizaSap = listapolizaSap[0];

                        entidadPolizaSap.PolizaSapSeleccionada = true;
                        entidadPolizaSap.MontoAcreenciaPolizaSap = montoAcreenciaBien;

                        entidadGarantia.PolizaSapAsociada = entidadPolizaSap;
                        entidadGarantia.PolizasSap.AsignarPolizaSeleccionada(entidadPolizaSap.CodigoPolizaSap, entidadPolizaSap.TipoBienPoliza);
                    }
                }
                else
                {
                    entidadGarantia.PolizasSap.QuitarSeleccion();
                    entidadGarantia.PolizaSapAsociada = null;
                }

                entidadGarantia.MostrarErrorRelacionTipoBienTipoPolizaSap = false;
                entidadGarantia.EntidadValida(false);

                Entidad_Real = entidadGarantia;

                #endregion Carga de la entidad

                ExpandirValuaciones = (((hdnIndiceAccordionActivo != null)
                                        && (hdnIndiceAccordionActivo.Value.Length > 0)
                                        && (int.TryParse(hdnIndiceAccordionActivo.Value, out indicePanel))) ? indicePanel : -1);

                ExpandirPolizas = (((hdnIndiceAccordionPolizaActivo != null)
                                        && (hdnIndiceAccordionPolizaActivo.Value.Length > 0)
                                        && (int.TryParse(hdnIndiceAccordionPolizaActivo.Value, out indicePanelPoliza))) ? indicePanelPoliza : -1);

            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_GUARDANDO_SESION_DETALLE, "GuardarDatosSession", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                throw ex;
            }
        }

        private void LimpiarGarantiaReal()
        {
            try
            {
                CGarantiaReal oGarantia = CGarantiaReal.Current;

                //Información general de la garantía
                oGarantia.TipoGarantiaReal = 0;
                oGarantia.ClaseGarantia = -1;
                oGarantia.Partido = 0;
                oGarantia.Finca = 0;
                oGarantia.Grado = 0;
                oGarantia.CedulaFiduciaria = 0;
                oGarantia.ClaseBien = "";
                oGarantia.NumPlaca = "";
                oGarantia.TipoBien = 0;
                oGarantia.TipoMitigador = -1;
                oGarantia.TipoDocumento = -1;
                oGarantia.MontoMitigador = 0;
                oGarantia.Inscripcion = 0;
                oGarantia.FechaPresentacion = DateTime.Today;
                oGarantia.PorcentajeResposabilidad = 0;
                oGarantia.FechaConstitucion = DateTime.Today;
                oGarantia.GradoGravamen = 0;
                oGarantia.TipoAcreedor = 0;
                oGarantia.CedulaAcreedor = null;
                oGarantia.FechaVencimientoInstrumento = DateTime.Today;
                oGarantia.OperacionEspecial = 0;
                oGarantia.Partido = 0;
                oGarantia.Liquidez = 0;
                oGarantia.Tenencia = 0;
                oGarantia.MonedaValor = 0;
                oGarantia.FechaPrescripcion = DateTime.Today;

                oGarantia = null;
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "LimpiarGarantiaReal", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
            }
        }

        private void CargarCombos()
        {
            try
            {
                CargarTiposGarantiaReal();
                CargarClasesGarantia(null);
                CargarTiposPersona();
                CargarInscripciones();
                CargarGrados(null, null);
                CargarTiposBien(null);
                CargarTipoMitigador(null, null);
                CargarTiposDocumentos(null, null);
                CargarValuadores(Enumeradores.TiposValuadores.Empresa);
                CargarValuadores(Enumeradores.TiposValuadores.Perito);
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "CargarCombos", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
            }
        }

        private void CargarTiposGarantiaReal()
        {
            if (!ListaCatalogosGR.ErrorDatos)
            {
                List<clsCatalogo> listaTiposGR = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_GARANTIA_REAL));

                cbTipoGarantiaReal.DataSource = null;
                cbTipoGarantiaReal.DataSource = listaTiposGR;
                cbTipoGarantiaReal.DataValueField = "CodigoElemento";
                cbTipoGarantiaReal.DataTextField = "DescripcionCodigoElemento";
                cbTipoGarantiaReal.DataBind();
                cbTipoGarantiaReal.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGR.DescripcionError;
            }
        }

        private void CargarTipoMitigador(int? tipoGarantiaReal, int? tipoBien)
        {
            int tipoGR = ((tipoGarantiaReal.HasValue) ? tipoGarantiaReal.Value : ((cbTipoGarantiaReal.Items.Count > 0) ? (int.Parse(cbTipoGarantiaReal.SelectedItem.Value)) : -1));
            int tipoBienGR = ((tipoBien.HasValue) ? tipoBien.Value : ((cbTipoBien.Items.Count > 0) ? (int.Parse(cbTipoBien.SelectedItem.Value)) : -1));

            if (!ListaCatalogosGR.ErrorDatos)
            {
                List<clsCatalogo> listaTiposMitigador = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_MITIGADOR));

                switch (tipoGR)
                {
                    case 1:
                        switch (tipoBienGR)
                        {
                            case 1: listaTiposMitigador = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_MITIGADOR)).FindAll((delegate(clsCatalogo catalogo) { return catalogo.IDElemento == 1 || catalogo.IDElemento == -1; }));
                                break;
                            case 2: listaTiposMitigador = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_MITIGADOR)).FindAll((delegate(clsCatalogo catalogo) { return catalogo.IDElemento == 2 || catalogo.IDElemento == 3 || catalogo.IDElemento == -1; }));
                                break;
                            default: listaTiposMitigador = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_MITIGADOR)).FindAll((delegate(clsCatalogo catalogo) { return catalogo.IDElemento >= 1 && catalogo.IDElemento <= 3 || catalogo.IDElemento == -1; }));
                                break;
                        }
                        break;
                    case 2: break;
                    case 3: break;
                    default: break;
                }

                cbMitigador.DataSource = null;
                cbMitigador.DataSource = listaTiposMitigador;
                cbMitigador.DataValueField = "CodigoElemento";
                cbMitigador.DataTextField = "DescripcionCodigoElemento";
                cbMitigador.DataBind();
                cbMitigador.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGR.DescripcionError;
            }
        }

        private void CargarTiposBien(int? tipoGarantiaReal)
        {
            if (!ListaCatalogosGR.ErrorDatos)
            {
                int tipoGR = ((tipoGarantiaReal.HasValue) ? tipoGarantiaReal.Value : ((cbTipoGarantiaReal.Items.Count > 0) ? (int.Parse(cbTipoGarantiaReal.SelectedItem.Value)) : -1));
                int tipoClase = ((cbClase.Items.Count > 0) ? (int.Parse(cbClase.SelectedItem.Value)) : -1);

                List<clsCatalogo> listaTiposBien = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_BIEN));

                switch (tipoGR)
                {
                    case 1:
                        listaTiposBien = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_BIEN)).FindAll((delegate(clsCatalogo catalogo) { return catalogo.IDElemento == 1 || catalogo.IDElemento == 2 || catalogo.IDElemento == -1; }));
                        break;
                    case 2: break;
                    case 3:
                        switch (tipoClase)
                        {
                            case 38:
                                listaTiposBien = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_BIEN)).FindAll((delegate(clsCatalogo catalogo) { return catalogo.IDElemento == 3 || catalogo.IDElemento == 4 || catalogo.IDElemento == -1; }));
                                break;
                            case 43:
                                listaTiposBien = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_BIEN)).FindAll((delegate(clsCatalogo catalogo) { return catalogo.IDElemento == 3 || catalogo.IDElemento == 4 || catalogo.IDElemento == -1; }));
                                break;
                            default: break;
                        }
                        break;
                    default: break;
                }

                cbTipoBien.DataSource = null;
                cbTipoBien.DataSource = listaTiposBien;
                cbTipoBien.DataValueField = "CodigoElemento";
                cbTipoBien.DataTextField = "DescripcionCodigoElemento";
                cbTipoBien.DataBind();
                cbTipoBien.ClearSelection();

            }
            else
            {
                lblMensaje.Text = ListaCatalogosGR.DescripcionError;
            }
        }

        private void CargarGrados(int? tipoGarantiaReal, int? tipoDocumentoLegal)
        {
            if (!ListaCatalogosGR.ErrorDatos)
            {
                int tipoGR = ((tipoGarantiaReal.HasValue) ? tipoGarantiaReal.Value : ((cbTipoGarantiaReal.Items.Count > 0) ? (int.Parse(cbTipoGarantiaReal.SelectedItem.Value)) : -1));
                int tipoDocumento = ((tipoDocumentoLegal.HasValue) ? tipoDocumentoLegal.Value : ((cbTipoDocumento.Items.Count > 0) ? (int.Parse(cbTipoDocumento.SelectedItem.Value)) : -1));

                List<clsCatalogo> listaGradosGravamen = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_GRADO_GRAVAMEN));

                cbGravamen.DataSource = null;
                cbGravamen.DataSource = listaGradosGravamen;
                cbGravamen.DataValueField = "CodigoElemento";
                cbGravamen.DataTextField = "DescripcionCodigoElemento";
                cbGravamen.DataBind();
                cbGravamen.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGR.DescripcionError;
            }
        }

        private void CargarClasesGarantia(int? tipoGarantiaReal)
        {
            if (!ListaCatalogosGR.ErrorDatos)
            {
                List<clsCatalogo> listaClasesGarantia = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_CLASE_GARANTIA)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento >= 10 && catalogo.IDElemento <= 69) || catalogo.IDElemento == -1; }));

                int tipoGR = ((tipoGarantiaReal.HasValue) ? tipoGarantiaReal.Value : ((cbTipoGarantiaReal.Items.Count > 0) ? (int.Parse(cbTipoGarantiaReal.SelectedItem.Value)) : -1));

                switch (tipoGR)
                {
                    case 1:
                        listaClasesGarantia = listaClasesGarantia.FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento >= 10 && catalogo.IDElemento <= 17) || catalogo.IDElemento == -1; }));
                        break;
                    case 2: break;
                    case 3: break;
                    default:
                        break;
                }

                cbClase.DataSource = null;
                cbClase.DataSource = listaClasesGarantia;
                cbClase.DataValueField = "CodigoElemento";
                cbClase.DataTextField = "DescripcionCodigoElemento";
                cbClase.DataBind();
                cbClase.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGR.DescripcionError;
            }
        }

        private void CargarInscripciones()
        {
            if (!ListaCatalogosGR.ErrorDatos)
            {
                /*Se filtran los datos según requerimiento Siebel No. 1-21317176  ---> 009 Req_Validaciones Indicador Inscripción, por AMM-Lidersoft Internacional S.A., el 11/07/2012*/
                List<clsCatalogo> listaInscripciones = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_INSCRIPCION)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento >= 1 && catalogo.IDElemento <= 3) || catalogo.IDElemento == -1; }));

                cbInscripcion.DataSource = null;
                cbInscripcion.DataSource = listaInscripciones;
                cbInscripcion.DataValueField = "CodigoElemento";
                cbInscripcion.DataTextField = "DescripcionCodigoElemento";
                cbInscripcion.DataBind();
                cbInscripcion.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGR.DescripcionError;
            }
        }

        private void CargarTiposDocumentos(int? tipoGarantiaReal, int? tipoGradoGravamen)
        {
            if (!ListaCatalogosGR.ErrorDatos)
            {
                int tipoGR = ((tipoGarantiaReal.HasValue) ? tipoGarantiaReal.Value : ((cbTipoGarantiaReal.Items.Count > 0) ? (int.Parse(cbTipoGarantiaReal.SelectedItem.Value)) : -1));
                int tipoGradoGravamenGR = ((tipoGradoGravamen.HasValue) ? tipoGradoGravamen.Value : ((cbGravamen.Items.Count > 0) ? (int.Parse(cbGravamen.SelectedItem.Value)) : -1));

                List<clsCatalogo> listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS));

                switch (tipoGR)
                {
                    case 1:
                        switch (tipoGradoGravamenGR)
                        {
                            case 1: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 1) || catalogo.IDElemento == -1; }));
                                break;
                            case 2: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 2) || catalogo.IDElemento == -1; }));
                                break;
                            case 3: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 3) || catalogo.IDElemento == -1; }));
                                break;
                            case 4: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 4) || catalogo.IDElemento == -1; }));
                                break;
                            default: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return catalogo.IDElemento == -1; }));
                                break;
                        }
                        break;
                    case 2:
                        switch (tipoGradoGravamenGR)
                        {
                            case 1: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 5) || catalogo.IDElemento == -1; }));
                                break;
                            case 2: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 6) || catalogo.IDElemento == -1; }));
                                break;
                            case 3: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 7) || catalogo.IDElemento == -1; }));
                                break;
                            case 4: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 8) || catalogo.IDElemento == -1; }));
                                break;
                            default: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return catalogo.IDElemento == -1; }));
                                break;
                        }
                        break;
                    case 3:
                        switch (tipoGradoGravamenGR)
                        {
                            case 1: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 9) || catalogo.IDElemento == -1; }));
                                break;
                            case 2: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 10) || catalogo.IDElemento == -1; }));
                                break;
                            case 3: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 11) || catalogo.IDElemento == -1; }));
                                break;
                            case 4: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return (catalogo.IDElemento == 12) || catalogo.IDElemento == -1; }));
                                break;
                            default: listaTiposDocumento = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPOS_DOCUMENTOS)).FindAll((delegate(clsCatalogo catalogo) { return catalogo.IDElemento == -1; }));
                                break;
                        }
                        break;
                    default: break;
                }

                cbTipoDocumento.DataSource = null;
                cbTipoDocumento.DataSource = listaTiposDocumento;
                cbTipoDocumento.DataValueField = "CodigoElemento";
                cbTipoDocumento.DataTextField = "DescripcionCodigoElemento";
                cbTipoDocumento.DataBind();
                cbTipoDocumento.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGR.DescripcionError;
            }
        }

        private void CargarTiposPersona()
        {
            if (!ListaCatalogosGR.ErrorDatos)
            {
                List<clsCatalogo> listaTiposPersona = ListaCatalogosGR.Items(((int)Enumeradores.Catalogos_Garantias_Reales.CAT_TIPO_PERSONA));

                cbTipoAcreedor.DataSource = null;
                cbTipoAcreedor.DataSource = listaTiposPersona;
                cbTipoAcreedor.DataValueField = "CodigoElemento";
                cbTipoAcreedor.DataTextField = "DescripcionCodigoElemento";
                cbTipoAcreedor.DataBind();
                cbTipoAcreedor.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGR.DescripcionError;
            }
        }

        /// <summary>
        /// Carga la información de los valuadores, sean peritos o empresas.
        /// </summary>
        /// <param name="tipoValuador">Indica el tipo de valuador sobre el cual se desea obtener la lista</param>
        private void CargarValuadores(Enumeradores.TiposValuadores tipoValuador)
        {
            if (tipoValuador == Enumeradores.TiposValuadores.Perito)
            {
                if (!ListaPeritos.ErrorDatos)
                {
                    List<clsValuador> listaValuadores = ListaPeritos.Items();

                    cbPerito.DataSource = null;
                    cbPerito.DataSource = listaValuadores;
                    cbPerito.DataValueField = "CedulaValuador";
                    cbPerito.DataTextField = "DatosValuador";
                    cbPerito.DataBind();
                    cbPerito.ClearSelection();
                }
                else
                {
                    lblMensaje.Text = ListaPeritos.DescripcionError;
                }
            }
            else
            {
                if (!ListaEmpresasValuadoras.ErrorDatos)
                {
                    List<clsValuador> listaValuadores = ListaEmpresasValuadoras.Items();

                    cbEmpresa.DataSource = null;
                    cbEmpresa.DataSource = listaValuadores;
                    cbEmpresa.DataValueField = "CedulaValuador";
                    cbEmpresa.DataTextField = "DatosValuador";
                    cbEmpresa.DataBind();
                    cbEmpresa.ClearSelection();
                }
                else
                {
                    lblMensaje.Text = ListaEmpresasValuadoras.DescripcionError;
                }
            }
        }

        /// <summary>
        /// Carga la lista de tipos de moneda de las pólizas
        /// </summary>
        private void CargarTiposMonedaPoliza()
        {
            try
            {
                string catalogoTipoMoneda = "|" + Application["CAT_MONEDA"].ToString() + "|";
                List<clsCatalogo> catalogoTiposMonedas = Gestor.ObtenerCatalogos(catalogoTipoMoneda).Items((int.Parse(Application["CAT_MONEDA"].ToString())));

                cbMonedaPoliza.DataSource = null;
                cbMonedaPoliza.DataSource = catalogoTiposMonedas;
                cbMonedaPoliza.DataValueField = "CodigoElemento";
                cbMonedaPoliza.DataTextField = "DescripcionCodigoElemento";
                cbMonedaPoliza.DataBind();
                cbMonedaPoliza.ClearSelection();

            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }                

        /// <summary>
        /// Método de validación de datos
        /// </summary>
        /// <returns></returns>
        private bool ValidarDatos()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = "";
                lblMensaje3.Text = "";

                if (bRespuesta && txtContabilidad.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de contabilidad";
                    bRespuesta = false;
                }
                if (bRespuesta && txtOficina.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de oficina";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMoneda.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de moneda";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    if (txtProducto.Text.Trim().Length == 0)
                    {
                        lblMensaje.Text = "Debe ingresar el código del producto";
                        bRespuesta = false;
                    }
                }
                if (bRespuesta && txtOperacion.Text.Trim().Length == 0)
                {
                    if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                        lblMensaje.Text = "Debe ingresar el número de operación";
                    else
                        lblMensaje.Text = "Debe ingresar el número de contrato";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoGarantiaReal.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el tipo de garantía real.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbClase.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar la clase de garantía.";
                    bRespuesta = false;
                }

                if (bRespuesta && int.Parse(cbTipoGarantiaReal.SelectedValue.ToString()) == int.Parse(Application["HIPOTECAS"].ToString()))
                {
                    if (bRespuesta && txtPartido.Text.Trim().Length == 0)
                    {
                        lblMensaje3.Text = "Debe ingresar el partido.";
                        bRespuesta = false;
                    }
                    if (bRespuesta && txtNumFinca.Text.Trim().Length == 0)
                    {
                        lblMensaje3.Text = "Debe ingresar el número de finca.";
                        bRespuesta = false;
                    }
                }
                else if (bRespuesta && int.Parse(cbTipoGarantiaReal.SelectedValue.ToString()) == int.Parse(Application["CEDULAS_HIPOTECARIAS"].ToString()))
                {
                    if (bRespuesta && txtPartido.Text.Trim().Length == 0)
                    {
                        lblMensaje3.Text = "Debe ingresar el partido.";
                        bRespuesta = false;
                    }
                    if (bRespuesta && txtNumFinca.Text.Trim().Length == 0)
                    {
                        lblMensaje3.Text = "Debe ingresar el número de finca.";
                        bRespuesta = false;
                    }
                    if (bRespuesta && txtGrado.Text.Trim().Length == 0)
                    {
                        lblMensaje3.Text = "Debe ingresar el grado.";
                        bRespuesta = false;
                    }
                    if (bRespuesta && txtCedulaHipotecaria.Text.Trim().Length == 0)
                    {
                        lblMensaje3.Text = "Debe ingresar la cédula hipotecaria.";
                        bRespuesta = false;
                    }
                }
                else if (bRespuesta && int.Parse(cbTipoGarantiaReal.SelectedValue.ToString()) == int.Parse(Application["PRENDAS"].ToString()))
                {
                    if (bRespuesta && txtNumFinca.Text.Trim().Length == 0)
                    {
                        lblMensaje3.Text = "Debe ingresar el número de placa del bien.";
                        bRespuesta = false;
                    }
                }
                if (bRespuesta && int.Parse(cbTipoBien.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el tipo de bien.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbMitigador.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el tipo mitigador de riesgo.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoDocumento.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el tipo de documento legal.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMontoMitigador.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe ingresar el monto mitigador.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtFechaConstitucion.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe ingresar la fecha de constitución de la garantía.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbGravamen.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el grado de gravamen.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtFechaPrescripcion.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe seleccionar la fecha de prescripción.";
                    bRespuesta = false;
                }
                if (!bRespuesta)
                    FormatearCamposNumericos();

            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }

            return bRespuesta;
        }

        /// <summary>
        /// Este método permite validar los campos llave de la operación
        /// </summary>
        /// <returns>True - Si los datos son correctos; False - Si los datos son incorrectos</returns>
        private bool ValidarDatosOperacion()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = "";

                if (bRespuesta && txtContabilidad.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de contabilidad";
                    bRespuesta = false;
                }
                if (bRespuesta && txtOficina.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de oficina";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMoneda.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de moneda";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    if (txtProducto.Text.Trim().Length == 0)
                    {
                        lblMensaje.Text = "Debe ingresar el código del producto";
                        bRespuesta = false;
                    }
                }
                if (bRespuesta && txtOperacion.Text.Trim().Length == 0)
                {
                    if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                        lblMensaje.Text = "Debe ingresar el número de operación";
                    else
                        lblMensaje.Text = "Debe ingresar el número de contrato";

                    bRespuesta = false;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
            return bRespuesta;
        }

        private bool ValidarDatosLlave()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = "";

                if (bRespuesta && txtContabilidad.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de contabilidad";
                    bRespuesta = false;
                }
                if (bRespuesta && txtOficina.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de oficina";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMoneda.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de moneda";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    if (txtProducto.Text.Trim().Length == 0)
                    {
                        lblMensaje.Text = "Debe ingresar el código del producto";
                        bRespuesta = false;
                    }
                }
                if (bRespuesta && txtOperacion.Text.Trim().Length == 0)
                {
                    if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                        lblMensaje.Text = "Debe ingresar el número de operación";
                    else
                        lblMensaje.Text = "Debe ingresar el número de contrato";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbClase.SelectedValue.ToString()) == -1)
                {
                    lblMensaje.Text = "Debe seleccionar la clase de garantía.";
                    bRespuesta = false;
                }
                if (txtNumFinca.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el número de finca.";
                    bRespuesta = false;
                }
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog((Mensajes.Obtener(Mensajes.ERROR_VALIDANDO_DATOS_DETALLE, "de los campos requeridos de la garantía", ex.Message, Mensajes.ASSEMBLY)), EventLogEntryType.Error);
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_VALIDANDO_DATOS, "de los campos requeridos de la garantía", Mensajes.ASSEMBLY);
            }
            return bRespuesta;
        }

        private void CargarDatosGarantia(long nOperacion, long nGarantia, string desGarantia, out bool bloquearControles, bool obtenerDatosBD, int tipoGarantiaReal)
        {
            ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);
            DateTime fechaBase = new DateTime(1900, 01, 01);

            ErrorGraveAvaluo = false;

            ExisteValuacion = false;
            
            BloquearCampos(true, false);

            bloquearControles = false;

            int annosCalculoPrescripcion = 0;

            string datosOperacion = txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + ((txtProducto.Text.Length > 0) ?
                (txtProducto.Text + "-" + txtOperacion.Text) : txtOperacion.Text);

            strOperacionCrediticia = datosOperacion;

            if (obtenerDatosBD)
            {
                annosCalculoPrescripcion = ObtenerCantidadAnnosPrescripcion(tipoGarantiaReal);

                entidadGarantia = new clsGarantiaReal();
                entidadGarantia = Gestor.ObtenerDatosGarantiaReal(nOperacion, nGarantia, datosOperacion, desGarantia, Session["strUSER"].ToString(), annosCalculoPrescripcion);
                TramaInicial = entidadGarantia.TramaInicial;

                mostrarErrorRelacionPolizaGarantia = true;

                porcentajeAceptacionCalculado = decimal.Parse(entidadGarantia.PorcentajeAceptacionCalculado.ToString("N2")); 

                ViewState.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, porcentajeAceptacionCalculado.ToString("N2"));

                string m = ViewState[LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO].ToString();
              
                if ((entidadGarantia.FechaValuacion != DateTime.MinValue) && ((entidadGarantia.MontoUltimaTasacionTerreno + entidadGarantia.MontoUltimaTasacionNoTerreno) > 0))
                {
                    ExisteValuacion = true;
                }
            }
            else
            {
                entidadGarantia.MostrarErrorRelacionTipoBienTipoPolizaSap = true;
                entidadGarantia = Entidad_Real;
                entidadGarantia.TramaInicial = TramaInicial;

                int cantidadAvaluos = (((entidadGarantia.MontoUltimaTasacionTerreno + entidadGarantia.MontoUltimaTasacionNoTerreno) > 0) ? 1 : 0);

                if ((cantidadAvaluos == -1) && (entidadGarantia.InconsistenciaMontoMitigador == 1))
                {
                    entidadGarantia.MontoTotalAvaluo = 0;
                    ExisteValuacion = false;
                }
                else if (entidadGarantia != null)
                {
                    entidadGarantia.InconsistenciaMontoMitigador = ((cantidadAvaluos == 0) ? ((short)1) : ((entidadGarantia.InconsistenciaMontoMitigador == 1 ? ((short)0) : entidadGarantia.InconsistenciaMontoMitigador)));

                    if (entidadGarantia.InconsistenciaMontoMitigador == 1)
                    {
                        entidadGarantia.MontoTotalAvaluo = 0;
                        ExisteValuacion = false;
                    }
                    else
                    {
                        entidadGarantia.MontoTotalAvaluo = ObtenerMontoTotalValuacionReciente(nGarantia, desGarantia);

                        if (entidadGarantia.MontoTotalAvaluo > 0)
                        {
                            ExisteValuacion = true;
                        }
                        else
                        {
                            entidadGarantia.InconsistenciaMontoMitigador = 1;
                            ExisteValuacion = false;
                        }
                    }
                }
            }

            if ((entidadGarantia != null) && (!entidadGarantia.ErrorDatos))
            {
                Entidad_Real = entidadGarantia;
                                
                MontoTotalAvaluo = entidadGarantia.MontoTotalAvaluo.ToString("N");

                FormatearCamposNumericos();
                int nTGarantiaReal = -1;

                #region Datos de la Garantía

                if ((Session["EsCambioTipoGarantia"] != null)
                   && (Session["Accion"] != null)
                   && ((!bool.Parse(Session["EsCambioTipoGarantia"].ToString())) ||
                    (Session["Accion"].ToString() == "INSERTAR")))
                {
                    CargarTiposGarantiaReal();
                    cbTipoGarantiaReal.ClearSelection();
                    cbTipoGarantiaReal.Items.FindByValue(((cbTipoGarantiaReal.Items.FindByValue(entidadGarantia.CodTipoGarantiaReal.ToString()) != null) ? entidadGarantia.CodTipoGarantiaReal.ToString() : "-1")).Selected = true;
                    nTGarantiaReal = entidadGarantia.CodTipoGarantiaReal;
                }
                else
                {
                    nTGarantiaReal = (((cbTipoGarantiaReal.SelectedValue.Length > 0) && (cbTipoGarantiaReal.SelectedValue.CompareTo("-1") != 0)) ? int.Parse(cbTipoGarantiaReal.SelectedValue.ToString()) : entidadGarantia.CodTipoGarantiaReal);

                    if ((nTGarantiaReal != -1) && (cbTipoGarantiaReal.SelectedValue.Length > 0) && (cbTipoGarantiaReal.SelectedValue.CompareTo(nTGarantiaReal.ToString()) != 0))
                    {
                        CargarTiposGarantiaReal();
                        cbTipoGarantiaReal.ClearSelection();
                        cbTipoGarantiaReal.Items.FindByValue(((cbTipoGarantiaReal.Items.FindByValue(entidadGarantia.CodTipoGarantiaReal.ToString()) != null) ? entidadGarantia.CodTipoGarantiaReal.ToString() : "-1")).Selected = true;
                    }
                    else if ((nTGarantiaReal != -1) && (cbTipoGarantiaReal.SelectedValue.Length == 0))
                    {
                        CargarTiposGarantiaReal();
                        cbTipoGarantiaReal.ClearSelection();
                        cbTipoGarantiaReal.Items.FindByValue(((cbTipoGarantiaReal.Items.FindByValue(entidadGarantia.CodTipoGarantiaReal.ToString()) != null) ? entidadGarantia.CodTipoGarantiaReal.ToString() : "-1")).Selected = true;
                    }
                }

                if ((nTGarantiaReal == -1) && (entidadGarantia.CodTipoGarantiaReal != -1))
                {
                    CargarTiposGarantiaReal();
                    cbTipoGarantiaReal.ClearSelection();
                    cbTipoGarantiaReal.Items.FindByValue(((cbTipoGarantiaReal.Items.FindByValue(entidadGarantia.CodTipoGarantiaReal.ToString()) != null) ? entidadGarantia.CodTipoGarantiaReal.ToString() : "-1")).Selected = true;
                    nTGarantiaReal = entidadGarantia.CodTipoGarantiaReal;
                }

                if ((nTGarantiaReal != -1) && (entidadGarantia.CodTipoGarantiaReal != -1) && (nTGarantiaReal != entidadGarantia.CodTipoGarantiaReal))
                {
                    CargarTiposGarantiaReal();
                    cbTipoGarantiaReal.ClearSelection();
                    cbTipoGarantiaReal.Items.FindByValue(((cbTipoGarantiaReal.Items.FindByValue(entidadGarantia.CodTipoGarantiaReal.ToString()) != null) ? entidadGarantia.CodTipoGarantiaReal.ToString() : "-1")).Selected = true;
                    nTGarantiaReal = entidadGarantia.CodTipoGarantiaReal;
                }

                Session["EsCambioTipoGarantia"] = false;

                CargarClasesGarantia(nTGarantiaReal);
                cbClase.ClearSelection();
                cbClase.Items.FindByValue(((!entidadGarantia.InconsistenciaClaseGarantia) ? ((cbClase.Items.FindByValue(entidadGarantia.CodClaseGarantia.ToString()) != null) ? entidadGarantia.CodClaseGarantia.ToString() : "-1") : "-1")).Selected = true;

                txtPartido.Enabled = false;
                txtNumFinca.Enabled = false;

                if (nTGarantiaReal == int.Parse(Application["HIPOTECAS"].ToString()))
                {
                    lblGrado.Visible = false;
                    lblCedula.Visible = false;
                    txtGrado.Visible = false;
                    txtCedulaHipotecaria.Visible = false;

                    lblPartido.Text = "Partido: ";
                    txtPartido.Text = ((entidadGarantia.CodPartido != -1) ? entidadGarantia.CodPartido.ToString() : string.Empty);

                    lblFinca.Text = "Finca: ";
                    txtNumFinca.Text = ((!entidadGarantia.InconsistenciaPartido) ? entidadGarantia.NumeroFinca : string.Empty);
                }
                else if (nTGarantiaReal == int.Parse(Application["CEDULAS_HIPOTECARIAS"].ToString()))
                {
                    lblPartido.Text = "Partido: ";
                    txtPartido.Text = ((entidadGarantia.CodPartido != -1) ? entidadGarantia.CodPartido.ToString() : string.Empty);
                    lblFinca.Text = "Finca: ";
                    txtNumFinca.Text = ((!entidadGarantia.InconsistenciaPartido) ? entidadGarantia.NumeroFinca : string.Empty);
                    txtGrado.Text = entidadGarantia.CodGrado;
                    txtCedulaHipotecaria.Text = entidadGarantia.CedulaHipotecaria;

                    lblGrado.Visible = true;
                    lblCedula.Visible = true;
                    txtGrado.Visible = true;
                    txtCedulaHipotecaria.Visible = true;
                }
                else if (nTGarantiaReal == int.Parse(Application["PRENDAS"].ToString()))
                {
                    lblPartido.Text = "Clase Bien: ";
                    txtPartido.Enabled = (((entidadGarantia.CodClaseGarantia == 38) || (entidadGarantia.CodClaseGarantia == 43)) ? false : true);
                    txtPartido.Text = entidadGarantia.CodClaseBien;
                    lblFinca.Text = "Id Bien: ";
                    txtNumFinca.Text = entidadGarantia.NumPlacaBien;

                    lblGrado.Visible = false;
                    lblCedula.Visible = false;
                    txtGrado.Visible = false;
                    txtCedulaHipotecaria.Visible = false;
                }

                CargarTiposBien(nTGarantiaReal);
                cbTipoBien.ClearSelection();
                cbTipoBien.Items.FindByValue(((cbTipoBien.Items.FindByValue(entidadGarantia.CodTipoBien.ToString()) != null) ? entidadGarantia.CodTipoBien.ToString() : "-1")).Selected = true;

                BloquearCamposMTATMTANT = (((entidadGarantia.CodTipoBien == 1) || (entidadGarantia.CodTipoBien == 2)) ? true : false);

                CargarTipoMitigador(nTGarantiaReal, entidadGarantia.CodTipoBien);
                cbMitigador.ClearSelection();
                cbMitigador.Items.FindByValue(((!entidadGarantia.InconsistenciaTipoMitigador) ? ((cbMitigador.Items.FindByValue(entidadGarantia.CodTipoMitigador.ToString()) != null) ? entidadGarantia.CodTipoMitigador.ToString() : "-1") : "-1")).Selected = true;

                CargarGrados(null, null);
                cbGravamen.ClearSelection();
                cbGravamen.Items.FindByValue(((!entidadGarantia.InconsistenciaGradoGravamen) ? ((cbGravamen.Items.FindByValue(entidadGarantia.CodGradoGravamen.ToString()) != null) ? entidadGarantia.CodGradoGravamen.ToString() : "-1") : "-1")).Selected = true;

                CargarTiposDocumentos(nTGarantiaReal, entidadGarantia.CodGradoGravamen);
                cbTipoDocumento.ClearSelection();
                cbTipoDocumento.Items.FindByValue((((!entidadGarantia.InconsistenciaTipoDocumentoLegal) && (!entidadGarantia.InconsistenciaGradoGravamen)) ? ((cbTipoDocumento.Items.FindByValue(entidadGarantia.CodTipoDocumentoLegal.ToString()) != null) ? entidadGarantia.CodTipoDocumentoLegal.ToString() : "-1") : "-1")).Selected = true;

                if (cbTipoDocumento.SelectedItem.Value.CompareTo("-1") == 0)
                {
                    cbTipoDocumento.ClearSelection();

                    foreach (ListItem liDocumento in cbTipoDocumento.Items)
                    {
                        if (liDocumento.Value.CompareTo("-1") != 0)
                        {
                            cbTipoDocumento.Items.FindByValue(liDocumento.Value).Selected = true;
                            break;
                        }
                    }
                }


                txtMontoMitigador.Text = entidadGarantia.MontoMitigador.ToString("N");

                CargarInscripciones();
                cbInscripcion.ClearSelection();
                cbInscripcion.Items.FindByValue(((cbInscripcion.Items.FindByValue(entidadGarantia.CodInscripcion.ToString()) != null) ? entidadGarantia.CodInscripcion.ToString() : "-1")).Selected = true;

                txtFechaRegistro.Text = ((entidadGarantia.FechaPresentacion != DateTime.MinValue) ? entidadGarantia.FechaPresentacion.ToShortDateString() : string.Empty);

                txtPorcentajeAceptacion.Text = entidadGarantia.PorcentajeResponsabilidad.ToString("N2");

                if (entidadGarantia.CodTipoBien == 2)
                {
                    chkDeudorHabitaVivienda.Checked = entidadGarantia.IndicadorViviendaHabitadaDeudor;
                }
                else
                {
                    chkDeudorHabitaVivienda.Checked = false;
                    chkDeudorHabitaVivienda.Enabled = false;
                }

                //Se valida que si existe diferencia en referencia a los datos del SICC esta no sea la inexistencia del avalúo en el SICC, 
                //caso contrario no se mostrará ningún dato y se bloquearán los campos
                if ((entidadGarantia.AvaluoDiferenteSicc != 4) && (entidadGarantia.InconsistenciaMontoMitigador != 1))
                {
                    //Se calcula el monto mitigador
                    #region Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

                    AplicarCalculoMontoMitigador();

                    #endregion Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.
                }
                else
                {
                    txtMontoMitigadorCalculado.Text = "0.00";
                }

                CargarTiposPersona();
                cbTipoAcreedor.ClearSelection();
                cbTipoAcreedor.Items.FindByValue(((cbTipoAcreedor.Items.FindByValue(entidadGarantia.CodTipoAcreedor.ToString()) != null) ? entidadGarantia.CodTipoAcreedor.ToString() : "-1")).Selected = true;

                txtAcreedor.Text = entidadGarantia.CedulaAcreedor;

                txtFechaConstitucion.Text = ((entidadGarantia.FechaConstitucion != DateTime.MinValue) ? entidadGarantia.FechaConstitucion.ToShortDateString() : string.Empty);

                txtFechaVencimiento.Text = ((entidadGarantia.FechaVencimiento != DateTime.MinValue) ? entidadGarantia.FechaVencimiento.ToShortDateString() : string.Empty);

                txtFechaPrescripcion.Text = ((entidadGarantia.FechaPrescripcion != DateTime.MinValue) ? entidadGarantia.FechaPrescripcion.ToShortDateString() : string.Empty);

                #endregion Datos de la Garantía

                #region Datos del avalúo más reciente

                //Se habilitan o no los campos, según el tipo de bien
                txtMontoTasActTerreno.Enabled = ((BloquearCamposMTATMTANT) ? false : true);
                txtMontoTasActNoTerreno.Enabled = ((BloquearCamposMTATMTANT) ? false : true);


                //Se cargan las fechas
                txtFechaValuacion.Text = (((entidadGarantia.FechaValuacion != DateTime.MinValue) && (entidadGarantia.FechaValuacion != fechaBase)) ? entidadGarantia.FechaValuacion.ToShortDateString() : string.Empty);
                txtFechaSeguimiento.Text = (((entidadGarantia.FechaUltimoSeguimiento != DateTime.MinValue) && (entidadGarantia.FechaUltimoSeguimiento != fechaBase)) ? entidadGarantia.FechaUltimoSeguimiento.ToShortDateString() : txtFechaValuacion.Text);
                txtFechaConstruccion.Text = (((entidadGarantia.FechaConstruccion != DateTime.MinValue) && (entidadGarantia.FechaConstruccion != fechaBase)) ? entidadGarantia.FechaConstruccion.ToShortDateString() : string.Empty);
                txtFechaValuacionSICC.Text = (((entidadGarantia.FechaValuacionSICC != DateTime.MinValue) && (entidadGarantia.FechaValuacionSICC != fechaBase)) ? entidadGarantia.FechaValuacionSICC.ToShortDateString() : string.Empty);

                //Se cargan los montos
                txtMontoUltTasacionTerreno.Text = entidadGarantia.MontoUltimaTasacionTerreno.ToString("N");
                txtMontoUltTasacionNoTerreno.Text = entidadGarantia.MontoUltimaTasacionNoTerreno.ToString("N");
                txtMontoTasActTerreno.Text = entidadGarantia.MontoTasacionActualizadaTerreno.ToString("N");
                txtMontoTasActNoTerreno.Text = entidadGarantia.MontoTasacionActualizadaNoTerreno.ToString("N");
                txtMontoAvaluo.Text = entidadGarantia.MontoTotalAvaluoSICC.ToString("N");

                //Se cargan los peritos
                CargarValuadores(Enumeradores.TiposValuadores.Perito);
                cbPerito.ClearSelection();
                cbPerito.Items.FindByValue(((cbPerito.Items.FindByValue(entidadGarantia.CedulaPerito.ToString()) != null) ? entidadGarantia.CedulaPerito.ToString() : "-1")).Selected = true;

                //Se cargan las empresas valuadoras
                CargarValuadores(Enumeradores.TiposValuadores.Empresa);
                cbEmpresa.ClearSelection();
                cbEmpresa.Items.FindByValue(((cbEmpresa.Items.FindByValue(entidadGarantia.CedulaEmpresa.ToString()) != null) ? entidadGarantia.CedulaEmpresa.ToString() : "-1")).Selected = true;

                //Se habilitan o no controles, según el tipo de bien seleccionado
                if (entidadGarantia.CodTipoBien == 1)
                {
                    if (entidadGarantia.MontoUltimaTasacionNoTerreno > 0)
                    {
                        txtMontoUltTasacionNoTerreno.Enabled = true;
                    }
                    else
                    {
                        txtMontoUltTasacionNoTerreno.Enabled = false;
                    }

                    if ((entidadGarantia.FechaConstruccion != DateTime.MinValue) && (entidadGarantia.FechaConstruccion != fechaBase))
                    {
                        txtFechaConstruccion.Enabled = true;
                        igbCalendarioConstruccion.Enabled = true;
                    }
                    else
                    {
                        txtFechaConstruccion.Enabled = false;
                        igbCalendarioConstruccion.Enabled = false;
                    }
                }
                else
                {
                    txtMontoUltTasacionNoTerreno.Enabled = true;
                    txtFechaConstruccion.Enabled = true;
                    igbCalendarioConstruccion.Enabled = true;
                }

                HabilitarValuacion = true;

                #endregion Datos del avalúo más reciente

                #region Datos de la póliza

                HabilitarPoliza = true;

                if (entidadGarantia.PolizasSap.Count > 0)
                {
                    ListItem valorNulo = new ListItem(string.Empty, "-1");
                    string polizasSap = string.Empty;

                    CargarTiposMonedaPoliza();

                    cbCodigoSap.DataSource = null;
                    cbCodigoSap.DataSource = entidadGarantia.PolizasSap.ObtenerPolizasPorTipoBien(entidadGarantia.CodTipoBien);
                    cbCodigoSap.DataValueField = "CodigoPolizaSap";
                    cbCodigoSap.DataTextField = "CodigoDescripcionPolizaSap";
                    cbCodigoSap.DataBind();
                    cbCodigoSap.ClearSelection();

                    cbCodigoSap.Items.Insert(0, valorNulo);

                    if ((entidadGarantia.PolizasSap.ObtenerPolizaSapSeleccionada() != null) && (!entidadGarantia.PolizasSap.ErrorRelacionTipoBienPolizaSap))
                    {
                        clsPolizaSap entidadPolizaSap = entidadGarantia.PolizasSap.ObtenerPolizaSapSeleccionada();

                        if (cbCodigoSap.Items.FindByValue(entidadPolizaSap.CodigoPolizaSap.ToString()) != null)
                        {
                            cbCodigoSap.Items.FindByValue(entidadPolizaSap.CodigoPolizaSap.ToString()).Selected = true;
                            txtMontoPoliza.Text = entidadPolizaSap.MontoPolizaSapColonizado.ToString("N");
                            cbMonedaPoliza.Items.FindByValue(entidadPolizaSap.TipoMonedaPolizaSap.ToString()).Selected = true;
                            txtCedulaAcreedorPoliza.Text = entidadPolizaSap.CedulaAcreedorPolizaSap;
                            txtNombreAcreedorPoliza.Text = entidadPolizaSap.NombreAcreedorPolizaSap;
                            txtFechaVencimientoPoliza.Text = entidadPolizaSap.FechaVencimientoPolizaSap.ToString("dd/MM/yyyy");
                            txtMontoAcreenciaPoliza.Text = entidadPolizaSap.MontoAcreenciaPolizaSap.ToString("N");
                            txtDetallePoliza.Text = entidadPolizaSap.DetallePolizaSap;
                            rdlEstadoPoliza.Items.FindByValue(((entidadPolizaSap.IndicadorPolizaSapVigente) ? "1" : "0")).Selected = true;

                            if (requestSM != null && requestSM.IsInAsyncPostBack)
                            {
                                ScriptManager.RegisterClientScriptBlock(this,
                                                                        typeof(Page),
                                                                        Guid.NewGuid().ToString(),
                                                                        "<script type=\"text/javascript\" language=\"javascript\">IndicarPolizaViegente('" + ((entidadPolizaSap.IndicadorPolizaSapVigente) ? "1" : "0") + "');</script>",
                                                                        false);
                            }
                            else
                            {
                                this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                       Guid.NewGuid().ToString(),
                                                                       "<script type=\"text/javascript\" language=\"javascript\">IndicarPolizaViegente('" + ((entidadPolizaSap.IndicadorPolizaSapVigente) ? "1" : "0") + "');</script>",
                                                                       false);
                            }
                        }
                    }
                }
                else
                {
                    cbCodigoSap.ClearSelection();
                    cbCodigoSap.Items.Clear();
                }

                #endregion Datos de la póliza

                ConsecutivoGarantia = entidadGarantia.CodGarantiaReal;

                cbTipoGarantiaReal.Enabled = false;
                btnModificar.Enabled = true;
                btnEliminar.Enabled = true;
                lblMensaje.Text = "";
                lblMensaje3.Text = "";

                #region Aplicación de Validaciones

                VerificarValidaciones(entidadGarantia, null);

                txtMontoMitigador.Enabled = BloquearMontoMitigador;
                txtFechaRegistro.Enabled = BloquearFechaPresentacion;
                cleFechaRegistro.Enabled = BloquearFechaPresentacion;
                igbCalendario.Enabled = BloquearFechaPresentacion;
                txtPorcentajeAceptacion.Enabled = BloquearPorcentajeAceptacion;

                #endregion Aplicación de Validaciones

                if (entidadGarantia.CodTipoGarantiaReal == 1)
                {
                    if (cbTipoBien.SelectedValue.CompareTo("-1") == 0)
                    {
                        cbMitigador.Enabled = false;
                    }
                }

                //Se valida que en casode que el porcentaje de aceptación sea igual a 0 (cero) se bloquee el campo del monto mitigador
                if (entidadGarantia.PorcentajeResponsabilidad == 0)
                {
                    txtMontoMitigador.Enabled = false;
                    BloquearMontoMitigador = false;
                }

                //Se verifica si se debe ejecutar el cálculo de los montos de tasación actualizada del terreno y no terreno, luego del cual se habilitará 
                //el campo de la fecha de último seguimiento
                if (entidadGarantia.AvaluoActualizado)
                {
                    this.txtFechaSeguimiento.Enabled = true;
                    this.igbCalendarioSeguimiento.Enabled = true;
                    AvaluoActualizado = entidadGarantia.AvaluoActualizado;
                    FechaSemestreActualizado = entidadGarantia.FechaSemestreCalculado;
                }
                else
                {
                    if (entidadGarantia.AvaluoDiferenteSicc == 0)
                    {
                        if ((entidadGarantia.CodTipoBien == 1) || (entidadGarantia.CodTipoBien == 2))
                        {
                            entidadGarantia.AplicarCalculoMTATyMTANT(false);
                            this.txtMontoTasActTerreno.Text = ((entidadGarantia.MontoTasacionActualizadaTerrenoCalculado.HasValue) ? ((decimal)entidadGarantia.MontoTasacionActualizadaTerrenoCalculado).ToString("N2") : string.Empty);
                            this.txtMontoTasActNoTerreno.Text = ((entidadGarantia.MontoTasacionActualizadaNoTerrenoCalculado.HasValue) ? ((decimal)entidadGarantia.MontoTasacionActualizadaNoTerrenoCalculado).ToString("N2") : string.Empty);

                            if ((entidadGarantia.CodTipoBien == 1) && (this.txtMontoTasActTerreno.Text.Length > 0))
                            {
                                this.txtFechaSeguimiento.Enabled = true;
                                this.igbCalendarioSeguimiento.Enabled = true;
                            }
                            else if ((entidadGarantia.CodTipoBien == 2) && (this.txtMontoTasActTerreno.Text.Length > 0) && (this.txtMontoTasActNoTerreno.Text.Length > 0))
                            {
                                this.txtFechaSeguimiento.Enabled = true;
                                this.igbCalendarioSeguimiento.Enabled = true;
                            }
                            else
                            {
                                this.txtFechaSeguimiento.Enabled = false;
                                this.igbCalendarioSeguimiento.Enabled = false;
                            }

                            AvaluoActualizado = entidadGarantia.AvaluoActualizado;
                            FechaSemestreActualizado = entidadGarantia.FechaSemestreCalculado;
                        }
                        else
                        {
                            if (ErrorGrave)
                            {
                                BloquearCamposAvaluo();
                            }
                            else
                            {
                                txtMontoTasActTerreno.Enabled = true;
                                txtMontoTasActNoTerreno.Enabled = true;
                            }
                        }
                    }
                    else
                    {
                        if ((entidadGarantia.CodTipoBien == 1) || (entidadGarantia.CodTipoBien == 2))
                        {
                            this.txtMontoTasActTerreno.Text = string.Empty;
                            this.txtMontoTasActNoTerreno.Text = string.Empty;
                            this.txtFechaSeguimiento.Enabled = false;
                            this.igbCalendarioSeguimiento.Enabled = false;
                        }

                        ErrorGraveAvaluo = ((entidadGarantia.AvaluoDiferenteSicc == 2) ? false : true);
                    }
                }

                //Se valida que si existe diferencia en referencia a los datos del SICC esta no sea la inexistencia del avalúo en el SICC, 
                //caso contrario no se mostrará ningún dato y se bloquearán los campos
                if ((entidadGarantia.AvaluoDiferenteSicc != 0) && (entidadGarantia.AvaluoDiferenteSicc != 2))
                {
                    ErrorGraveAvaluo = true;

                    //Se bloquean los campos
                    txtMontoUltTasacionTerreno.Enabled = false;
                    txtMontoUltTasacionNoTerreno.Enabled = false;
                    txtMontoTasActTerreno.Enabled = false;
                    txtMontoTasActNoTerreno.Enabled = false;
                    cbPerito.Enabled = false;
                    cbEmpresa.Enabled = false;
                    txtFechaSeguimiento.Enabled = false;
                    txtFechaConstruccion.Enabled = false;
                    igbCalendarioSeguimiento.Enabled = false;
                    igbCalendarioConstruccion.Enabled = false; 
                }

                if ((entidadGarantia.CodTipoBien == 0) || (entidadGarantia.CodTipoBien == -1) || (entidadGarantia.CodTipoMitigador == -1))
                {
                    txtPorcentajeAceptacion.Text = "0.00";
                    txtPorcentajeAceptacionCalculado.Text = "0.00";
                }
                else
                {           

                    //Se valida tipos de bien diferente 1-2-3-4, lo que no se evalua y no tiene % calculado respetará el % aceptacion,no debe de aplicar validaciones para % ingresado por el usuario
                   
                    //if ((entidadGarantia.CodTipoBien > 4) || (entidadGarantia.PorcentajeAceptacionCalculado == 0))
                    //if ((entidadGarantia.CodTipoBien > 4) || (entidadGarantia.PorcentajeAceptacionCalculadoOriginal == 0))
                    if (entidadGarantia.CodTipoBien > 4)
                    {
                        txtPorcentajeAceptacionCalculado.Text = entidadGarantia.PorcentajeResponsabilidad.ToString("N2");
                        entidadGarantia.PorcentajeAceptacionCalculado = entidadGarantia.PorcentajeResponsabilidad;
                        Entidad_Real = entidadGarantia;
                    }
                    else if (entidadGarantia.PorcentajeAceptacionCalculadoOriginal == 0)
                    {
                        txtPorcentajeAceptacionCalculado.Text = "0.00";
                    }
                    else
                    {
                        ////se debe validar para que  cuando da error el % calculado no sea borrado por el original                    
                        if (entidadGarantia.InconsistenciaPorcentajeAceptacionCalculado)
                        {
                            porcentajeAceptacionCalculado = decimal.Parse(entidadGarantia.PorcentajeAceptacionCalculado.ToString("N2"));   
                            btnValidarOperacion.Attributes.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, porcentajeAceptacionCalculado.ToString("N2"));
                            ViewState.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, porcentajeAceptacionCalculado.ToString("N2"));
                        }
                        else
                        {
                            txtPorcentajeAceptacionCalculado.Text = entidadGarantia.PorcentajeAceptacionCalculado.ToString("N2");
                            porcentajeAceptacionCalculado = decimal.Parse((txtPorcentajeAceptacionCalculado.Text.Length > 0) ? txtPorcentajeAceptacionCalculado.Text : "0.00");                         
                            btnValidarOperacion.Attributes.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, porcentajeAceptacionCalculado.ToString("N2"));
                            ViewState.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, porcentajeAceptacionCalculado.ToString("N2"));

                        }                

                    }
                
                }                

            }
            else
            {
                lblMensaje.Text = ((entidadGarantia.DescripcionError.Length > 0) ? entidadGarantia.DescripcionError : Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, desGarantia, datosOperacion, Mensajes.ASSEMBLY));
            }

            //Se cambia el puntero del cursor
            if (requestSM != null && requestSM.IsInAsyncPostBack)
            {
                ScriptManager.RegisterClientScriptBlock(this,
                                                        typeof(Page),
                                                        Guid.NewGuid().ToString(),
                                                        "<script type=\"text/javascript\" language=\"javascript\">document.body.style.cursor = 'default'; $(document).ready(function(){ AsignarListaSemestres('" + entidadGarantia.ListaSemestresCalcular.ObtenerJSON() + "'); AsignarListaPolizasSap('" + entidadGarantia.PolizasSap.ObtenerJSON() + "'); });</script>",
                                                        false);
            }
            else
            {
                this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                       Guid.NewGuid().ToString(),
                                                       "<script type=\"text/javascript\" language=\"javascript\">document.body.style.cursor = 'default';  $(document).ready(function(){ AsignarListaSemestres('" + entidadGarantia.ListaSemestresCalcular.ObtenerJSON() + "'); AsignarListaPolizasSap('" + entidadGarantia.PolizasSap.ObtenerJSON() + "'); });</script>",
                                                       false);
            }

            contenedorDatosModificacion.Visible = true;

            ViewState.Add(LLAVE_FECHA_REPLICA, entidadGarantia.FechaReplica);
            ViewState.Add(LLAVE_FECHA_MODIFICACION, entidadGarantia.FechaModifico);

            string usuarioModifico = (((entidadGarantia.UsuarioModifico.Length > 0) && (entidadGarantia.NombreUsuarioModifico.Length > 0)) ? (entidadGarantia.UsuarioModifico + " - " + entidadGarantia.NombreUsuarioModifico) : string.Empty);
            string fechaModifico = ((entidadGarantia.FechaModifico != DateTime.MinValue) ? entidadGarantia.FechaModifico.ToString("dd/MM/yyyy hh:mm:ss tt") : string.Empty);
            string fechaReplica = ((entidadGarantia.FechaReplica != DateTime.MinValue) ? (entidadGarantia.FechaReplica.ToString("dd/MM/yyyy hh:mm:ss tt")) : string.Empty);

            lblUsrModifico.Text = " Usuario Modificó: " + usuarioModifico;
            lblFechaModificacion.Text = "Fecha Modificación: " + fechaModifico;
            lblFechaReplica.Text = "Fecha Replica: " + fechaReplica;
        }

        /// <summary>
        /// Método que carga la información de la garantia que se encuentra almacenada en el objeto Session.
        /// </summary>
        private void CargarInfoConsulta()
        {

            entidadGarantia = Entidad_Real;
            entidadGarantia.TramaInicial = TramaInicial;

            //Campos llave
            if (entidadGarantia.TipoOperacion != 0)
            {
                cbTipoCaptacion.ClearSelection();
                cbTipoCaptacion.Items.FindByValue(entidadGarantia.TipoOperacion.ToString()).Selected = true;
            }

            if (entidadGarantia.Contabilidad != 0)
                txtContabilidad.Text = entidadGarantia.Contabilidad.ToString();

            if (entidadGarantia.Oficina != 0)
                txtOficina.Text = entidadGarantia.Oficina.ToString();

            if (entidadGarantia.MonedaOper != 0)
                txtMoneda.Text = entidadGarantia.MonedaOper.ToString();

            if (entidadGarantia.TipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
            {
                lblProducto.Visible = true;
                txtProducto.Visible = true;

                if (entidadGarantia.Producto != 0)
                    txtProducto.Text = entidadGarantia.Producto.ToString();
            }
            else
            {
                lblProducto.Visible = false;
                txtProducto.Visible = false;
            }

            if (entidadGarantia.NumeroOperacion != 0)
                txtOperacion.Text = entidadGarantia.NumeroOperacion.ToString();
        }

        /// <summary>
        /// Verifica y despliega los mensajes de error que posea la entidad al ser validada.
        /// </summary>
        /// <param name="entidadGarantiaReal">Entidad del tipo GarantiaReal que fue validada y de la cual se obtendrán los errores que se hayan presentado</param>
        /// <param name="mostrarError">Indica si se despliega el error o no, esto para cuando se requiere sólo habilitar o no los campos</param>
        /// <returns>True: Si la verificación fue exitosa. False: La entidad presenta algún error.</returns>
        private bool VerificarValidaciones(clsGarantiaReal entidadGarantiaReal, bool? mostrarError)
        {
            bool estadoVerificacion = true;
            bool mostrarErrorEmergente = ((mostrarError.HasValue) ? ((bool)mostrarError) : true);
            bool errorGrave = false;
            bool errorPorcAcep = false;
            bool errorMontoMitiga = false;

            ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

            ErrorGrave = false;
            decimal porceAceptaCalculadoMenor = -1;
            decimal porceAceptaCalculadoMitad = porcentajeAceptacionCalculado / 2;        

            if (entidadGarantiaReal != null)
            {
                //Se verifica si se detectó algún error
                if (entidadGarantiaReal.ErrorValidaciones) //&& (!entidadGarantiaReal.InconsistenciaValuacionesTerreno) && (!entidadGarantiaReal.InconsistenciaValuacionesNoTerreno))
                {
                    if (entidadGarantiaReal.DesplegarErrorVentanaEmergente)
                    {
                        /*Las validaciones se colocan al revés, del orden establecido en el enumerador "Inconsistencias", con el fin de que los 
                         * mensajes se desplieguen en el orden establecido en dicho enumerador.*/
                        

                        #region Inconsistencia de % Aceptacion Calculado, porcentaje aceptacion mayor al porcentaje de aceptacion calculado

                        txtPorcentajeAceptacionCalculado.Text = porcentajeAceptacionCalculado.ToString("N2");

                        if (entidadGarantiaReal.InconsistenciaPorceAcepMayorPorceAcepCalculado)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.PorcentajeAceptacionMayorCalculado)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.PorcentajeAceptacionMayorCalculado)],
                                                                           false);
                                }
                            }
                            
                        }

                        #endregion


                        //VALIDACIONES REDUCEN A 0

                        #region Inconsistencia de % Aceptacion Calculado, Indicador Inscripcion

                        //Solo es para colocar en campo % aceptacion calculado en 0, luego mas adelante realiza la validacion de inscripcion normal
                        if (entidadGarantiaReal.InconsistenciaIndicadorInscripcion)
                        {
                            estadoVerificacion = false;
                            txtPorcentajeAceptacionCalculado.Text = "0.00";
                            // btnValidarOperacion.Attributes.Add(LLAVE_MONTO_ORIGINAL_PORCENTAJE_ACEPTACION_CALCULADO, "0.00");
                            porceAceptaCalculadoMenor = 0;
                            btnValidarOperacion.Attributes.Add(LLAVE_ERROR_INDICADOR_INCONSISTENCIA, "1");
                        }

                        #endregion Inconsistencia de % Aceptacion Calculado, Indicador Inscripcion

                        #region Inconsistencia de % Aceptacion Calculado, cuando el tipo de bien es igual a 1 y tiene una poliza asociada

                        //Se valida si el error es debido a la 
                        if (entidadGarantiaReal.InconsistenciaPorceAcepTipoBienUnoPolizaAsociada)
                        {
                            estadoVerificacion = false;
                            txtPorcentajeAceptacionCalculado.Text = "0.00";
                            porceAceptaCalculadoMenor = 0;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.PolizaAsociada)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.PolizaAsociada)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de % Aceptacion Calculado,  cuando el tipo de bien es igual a 1 y tiene una poliza asociada

                        #region Inconsistencia de % Aceptacion Calculado, que fecha de valuacion es mayor en 5 años en relacion a la del sistema tipo de bien 3


                        if (cbTipoBien.SelectedItem.Value.Equals("3") || cbTipoBien.SelectedItem.Value.Equals("4"))
                        {
                            //Se valida si el error es debido a la 
                            if (entidadGarantiaReal.InconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienTres)
                            {
                                estadoVerificacion = false;

                                MostrarErrorFechaValuacionMayor = false;

                                switch (cbTipoBien.SelectedItem.Value)
                                {
                                    case "3":
                                        txtPorcentajeAceptacionCalculado.Text = "0.00";
                                        porceAceptaCalculadoMenor = 0;

                                        break;

                                    case "4":

                                        txtPorcentajeAceptacionCalculado.Text = porceAceptaCalculadoMitad.ToString("N2");
                                        break;
                                }

                                if (mostrarErrorEmergente)
                                {
                                    //Se obtiene el error de la lista de errores
                                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                                    {
                                        ScriptManager.RegisterClientScriptBlock(this,
                                                                                typeof(Page),
                                                                                Guid.NewGuid().ToString(),
                                                                                entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaValuacionMayor)],
                                                                                false);
                                    }
                                    else
                                    {
                                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                               Guid.NewGuid().ToString(),
                                                                               entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaValuacionMayor)],
                                                                               false);
                                    }
                                }
                            }


                        }



                        #endregion Inconsistencia de % Aceptacion Calculado, que fecha de valuacion es mayor en 5 años en relacion a la del sistema tipo de bien 3

                        #region Inconsistencia de % Aceptacion Calculado, que la fecha de seguimiento es mayor a un año en relacion a la del sistema tipo de bien 3

                        //Se valida si el error es debido a la 
                        if (entidadGarantiaReal.InconsistenciaPorceAcepFechaSeguimientoMayorUnAnnoBienTres)
                        {
                            estadoVerificacion = false;
                            txtPorcentajeAceptacionCalculado.Text = "0.00";
                            porceAceptaCalculadoMenor = 0;

                            MostrarErrorFechaUltimoSeguimientoMayor = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de % Aceptacion Calculado, que la fecha de seguimiento es mayor a un año en relacion a la del sistema tipo de bien 3

                        //VALIDACIONES REDUCEN A 0


                        //VALIDACIONES REDUCEN A LA MITAD

                        #region Inconsistencia de % Aceptacion Calculado,que la fecha de valuacion es mayor en 5 años en relacion a la del sistema tipo de bien uno

                        //Se valida si el error es debido a la 
                        if ( (entidadGarantiaReal.InconsistenciaPorceAcepFechaValuacionMayorCincoAnnosBienUno ) && ( porceAceptaCalculadoMenor == -1))
                        {
                            estadoVerificacion = false;                  
                            txtPorcentajeAceptacionCalculado.Text = porceAceptaCalculadoMitad.ToString("N2");

                            MostrarErrorFechaValuacionMayor = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaValuacionMayor)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaValuacionMayor)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de % Aceptacion Calculado,que la fecha de valuacion es mayor en 5 años en relacion a la del sistema tipo de bien uno                        

                        #region Inconsistencia de % Aceptacion Calculado, que la fecha de valuacion es mayor a 18 meses tipo de bien 2

                        //Se valida si el error es debido a la 
                        if ((entidadGarantiaReal.InconsistenciaPorceAcepFechaValuacionMayorDieciochoMeses) && (porceAceptaCalculadoMenor == -1))
                        {
                            estadoVerificacion = false;
                            txtPorcentajeAceptacionCalculado.Text = porceAceptaCalculadoMitad.ToString("N2");

                            MostrarErrorFechaValuacionMayor = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaValuacionMayor)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaValuacionMayor)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de % Aceptacion Calculado, que la fecha de valuacion es mayor a 18 meses tipo de bien 2             

                        #region Inconsistencia de % Aceptacion Calculado, que la  fecha de seguimiento es mayor a seis meses tipo de bien 4

                        //Se valida si el error es debido a la 
                        if ( (entidadGarantiaReal.InconsistenciaPorceAcepFechaSeguimientoMayorSeisMeses ) && (porceAceptaCalculadoMenor == -1))
                        {
                            estadoVerificacion = false;                  
                            txtPorcentajeAceptacionCalculado.Text = porceAceptaCalculadoMitad.ToString("N2");

                            MostrarErrorFechaUltimoSeguimientoMayor = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de % Aceptacion Calculado, que la  fecha de seguimiento es mayor a seis meses tipo de bien 4

                        #region Inconsistencia de % Aceptacion Calculado, que la fecha de seguimiento es mayor a un año en relacion a la del sistema tipo bien 1- 2

                        //Se valida si el error es debido a la 
                        if ((entidadGarantiaReal.InconsistenciaPorceAcepFechaSeguimientoMayorUnAnno ) && (porceAceptaCalculadoMenor == -1))
                        {
                            estadoVerificacion = false;                       
                            txtPorcentajeAceptacionCalculado.Text = porceAceptaCalculadoMitad.ToString("N2");

                            MostrarErrorFechaUltimoSeguimientoMayor = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de % Aceptacion Calculado, que la fecha de seguimiento es mayor a un año en relacion a la del sistema

                        #region Inconsistencia de % Aceptacion Calculado, cuando no tiene poliza asociada

                        //Se valida si el error es debido a la 
                        if ( (entidadGarantiaReal.InconsistenciaPorceAcepNoPolizaAsociada ) && (porceAceptaCalculadoMenor == -1))
                        {
                            estadoVerificacion = false;
                            //txtPorcentajeAceptacionCalculado.Text = porceAceptaCalculadoMitad.ToString("N2");
                            
                           MostrarErrorSinPolizaAsociada = false;

                            if (mostrarErrorEmergente)
                            {

                                if (entidadGarantiaReal.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaNoAsociada)))
                                {

                                    //Se obtiene el error de la lista de errores
                                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                                    {
                                        ScriptManager.RegisterClientScriptBlock(this,
                                                                                typeof(Page),
                                                                                Guid.NewGuid().ToString(),
                                            //  entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.PolizaNoAsociada)],
                                                                               entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.PolizaNoAsociada)],
                                                                                false);

                                    }
                                    else
                                    {
                                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                               Guid.NewGuid().ToString(),
                                            // entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.PolizaNoAsociada)],
                                                                              entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.PolizaNoAsociada)],
                                                                               false);
                                    }
                                
                                }

                                
                            }
                        }

                        #endregion Inconsistencia de % Aceptacion Calculado,  cuando no tiene poliza asociada

                        #region Inconsistencia de % Aceptacion Calculado, cuando tiene una poliza asociada y tiene la fecha de vencimiento es menor a la fecha del sistema

                        //Se valida si el error es debido a la 
                        if ((entidadGarantiaReal.InconsistenciaPorceAcepPolizaFechaVencimientoMenor) && (porceAceptaCalculadoMenor == -1) )
                        {
                            estadoVerificacion = false;
                            //txtPorcentajeAceptacionCalculado.Text = porceAceptaCalculadoMitad.ToString("N2");                            

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.PolizaAsociadaVencimientoMenor)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.PolizaAsociadaVencimientoMenor)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de % Aceptacion Calculado,  cuando tiene una poliza asociada y tiene la fecha de vencimiento es menor a la fecha del sistema

                        #region Inconsistencia de % Aceptacion Calculado,cuando tiene una poliza asociada y tiene la fecha de vencimiento es mayor a la fecha del sistema, y monto de la poliza no cubre el monto ultima tasacion no terreno

                        //Se valida si el error es debido a la 
                        if ( (entidadGarantiaReal.InconsistenciaPorceAcepPolizaFechaVencimientoMontoNoTerreno )  && (porceAceptaCalculadoMenor == -1))
                        {
                            estadoVerificacion = false;
                            //txtPorcentajeAceptacionCalculado.Text = porceAceptaCalculadoMitad.ToString("N2");

                        }

                        #endregion Inconsistencia de % Aceptacion Calculado,  cuando tiene una poliza asociada y tiene la fecha de vencimiento es mayor a la fecha del sistema, y monto de la poliza no cubre el monto ultima tasacion no terreno

                        //VALIDACIONES REDUCEN A LA MITAD


                        #region Inconsistencia de que los datos del acreedor de la póliza fueron modificados en el SAP

                        //Se valida si el error es debido a la validación de los datos del acreedor de la póliza
                        if (entidadGarantiaReal.InconsistenciaCambioDatosAcreedor)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.DatosAcreedorDiferentes)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.DatosAcreedorDiferentes)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de que los datos del acreedor de la póliza fueron modificados en el SAP

                        #region Inconsistencia de que el nombre del acreedor de la póliza ha sido modificado en el SAP

                        //Se valida si el error es debido a la validación del nombre del acreedor de la póliza
                        if (entidadGarantiaReal.InconsistenciaCambioAcreedor)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.NombreAcreedorDiferente)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.NombreAcreedorDiferente)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de que el nombre del acreedor de la póliza ha sido modificado en el SAP

                        #region Inconsistencia de que la cédula del acreedor de la póliza ha sido modificada en el SAP

                        //Se valida si el error es debido a la validación de la cédula dle acreedor de la póliza
                        if (entidadGarantiaReal.InconsistenciaCambioIdAcreedor)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.IdAcreedorDiferente)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.IdAcreedorDiferente)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de que la cédula del acreedor de la póliza ha sido modificada en el SAP

                        #region Inconsistencia de que el monto de la acreencia de la póliza es inválido

                        //Se valida si el error es debido a la validación del monto del a acreencia de la póliza
                        if (entidadGarantiaReal.InconsistenciaMontoAcreenciaInvalido)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.MontoAcreenciaInvalido)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.MontoAcreenciaInvalido)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de que el monto de la acreencia de la póliza es inválido

                        #region Inconsistencia de que la fecha de vencimiento de la póliza fue modificada en el SAP y es menor a la anterior

                        //Se valida si el error es debido a la validación de la fecha de vencimiento de la póliza
                        if (entidadGarantiaReal.InconsistenciaCambioFechaVencimiento)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.VencimientoPolizaMenor)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.VencimientoPolizaMenor)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de que la fecha de vencimiento de la póliza fue modificada en el SAP y es menor a la anterior

                        #region Inconsistencia de que el monto de la póliza fue modificado en el SAP y es menor al anterior

                        //Se valida si el error es debido a la validación del monto de la póliza
                        if (entidadGarantiaReal.InconsistenciaCambioMontoPoliza)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.MontoPolizaMenor)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.MontoPolizaMenor)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de que el monto de la póliza fue modificado en el SAP y es menor al anterior

                        #region Inconsistencia de infraseguro de una sola operación

                        //Se valida si el error es debido a la validación de la póliza
                        if (entidadGarantiaReal.InconsistenciaGarantiaInfraSeguro)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se revisa si hay mensaje de que el monto de la póliza no cubre el bien, se muestra
                                if (entidadGarantiaReal.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.MontoPolizaNoCubreBien)))
                                {
                                    //Se obtiene el error de la lista de errores
                                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                                    {
                                        ScriptManager.RegisterClientScriptBlock(this,
                                                                                typeof(Page),
                                                                                Guid.NewGuid().ToString(),
                                                                                entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.MontoPolizaNoCubreBien)],
                                                                                false);
                                    }
                                    else
                                    {
                                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                               Guid.NewGuid().ToString(),
                                                                               entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.MontoPolizaNoCubreBien)],
                                                                               false);
                                    }
                                }
                            }
                        }

                        #endregion Inconsistencia de infraseguro de una sola operación

                        #region Inconsistencia de que la póliza es inválida

                        //Se valida si el error es debido a la validación de la póliza
                        if (entidadGarantiaReal.InconsistenciaPolizaInvalida)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.PolizaInvalida)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.PolizaInvalida)],
                                                                           false);
                                }
                            }
                        }

                        //Se valida si el error es debido a la validación de la relación entre el tipo de bien y el tipo de póliza SAP
                        if ((entidadGarantiaReal.PolizasSap != null)
                            && (entidadGarantiaReal.PolizasSap.ErrorRelacionTipoBienPolizaSap) 
                            && (mostrarErrorRelacionPolizaGarantia)
                            && (entidadGarantiaReal.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaInvalidaTipoBienPoliza))))
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.PolizaInvalidaTipoBienPoliza)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.PolizaInvalidaTipoBienPoliza)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia de que la póliza es inválida

                        #region Inconsistencia en la validez del monto de la tasación actualizada del no terreno

                        //Se valida si el error es debido a la validez del monto de la tasación actualizada del no terreno
                        if ((entidadGarantiaReal.InconsistenciaValidezMontoAvaluoActualizadoNoTerreno == 1) ||
                            (entidadGarantiaReal.InconsistenciaValidezMontoAvaluoActualizadoNoTerreno == 2) ||
                            (entidadGarantiaReal.InconsistenciaValidezMontoAvaluoActualizadoNoTerreno == 3))
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ValidezMontoTasActNoTerreno)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ValidezMontoTasActNoTerreno)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en la validez del monto de la tasación actualizada del no terreno

                        #region Inconsistencia en la validez del monto de la tasación actualizada del terreno

                        //Se valida si el error es debido a la validez del monto de la tasación actualizada del terreno
                        if ((entidadGarantiaReal.InconsistenciaValidezMontoAvaluoActualizadoTerreno == 1) ||
                            (entidadGarantiaReal.InconsistenciaValidezMontoAvaluoActualizadoTerreno == 2) ||
                            (entidadGarantiaReal.InconsistenciaValidezMontoAvaluoActualizadoTerreno == 3))
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ValidezMontoTasActTerreno)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ValidezMontoTasActTerreno)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en la validez del monto de la tasación actualizada del terreno

                        #region Inconsistencia en la fecha de constitución

                        //Se valida si el error es debido a la validación de la fecha de constitución
                        if (entidadGarantiaReal.InconsistenciaFechaConstitucion)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaConstitucion)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaConstitucion)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en la fecha de constitución

                        #region Inconsistencia en la fecha de prescripción

                        //Se valida si el error es debido a la validación de la fecha de precripción
                        if (entidadGarantiaReal.InconsistenciaFechaPrescripcion)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaPrescripcion)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaPrescripcion)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en la fecha de prescripción

                        #region Inconsistencia en la fecha de vencimiento

                        //Se valida si el error es debido a la validación de la fecha de vencimiento
                        if ((entidadGarantiaReal.InconsistenciaFechaVencimiento == 1) ||
                            (entidadGarantiaReal.InconsistenciaFechaVencimiento == 2))
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaVencimiento)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaVencimiento)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en la fecha de vencimiento

                        #region Inconsistencia en los datos del avalúo con el SICC

                        //Se valida si el error es debido a la validación de los datos del avalúo con respecto al SICC
                        if ((entidadGarantiaReal.AvaluoDiferenteSicc == 1) ||
                            (entidadGarantiaReal.AvaluoDiferenteSicc == 2) ||
                            (entidadGarantiaReal.AvaluoDiferenteSicc == 3) ||
                            (entidadGarantiaReal.AvaluoDiferenteSicc == 4))
                        {
                            estadoVerificacion = false;

                            if (entidadGarantiaReal.AvaluoDiferenteSicc == 4)
                            {
                                txtMontoMitigador.Enabled = false;
                                BloquearMontoMitigador = false;
                                errorMontoMitiga = true;
                            }

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.DatosAvaluosIncorrectos)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.DatosAvaluosIncorrectos)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en los datos del avalúo con el SICC

                        #region Inconsistencia en la fecha de construcción

                        //Se valida si el error es debido a la validación de la fecha de último seguimiento
                        if ((entidadGarantiaReal.InconsistenciaFechaConstruccion == 1) ||
                            (entidadGarantiaReal.InconsistenciaFechaConstruccion == 2) ||
                            (entidadGarantiaReal.InconsistenciaFechaConstruccion == 3))
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaConstruccion)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaConstruccion)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en la fecha de construcción

                        #region Inconsistencia en la fecha del último seguimiento

                        //Se valida si el error es debido a la validación de la fecha de último seguimiento
                        if ((entidadGarantiaReal.InconsistenciaFechaUltimoSeguimiento == 1) || (entidadGarantiaReal.InconsistenciaFechaUltimoSeguimiento == 2))
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaUltimoSeguimiento)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaUltimoSeguimiento)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en la fecha del último seguimiento

                        #region Inconsistencia en las valuaciones del no terreno

                        //Se valida si el error es debido a la validación de las valuaciones del no terreno
                        if ((entidadGarantiaReal.InconsistenciaValuacionesNoTerreno == 1) ||
                            (entidadGarantiaReal.InconsistenciaValuacionesNoTerreno == 2) ||
                            (entidadGarantiaReal.InconsistenciaValuacionesNoTerreno == 3))
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ValuacionesNoTerreno)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ValuacionesNoTerreno)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en las valuaciones del no terreno

                        #region Inconsistencia en las valuaciones del terreno

                        //Se valida si el error es debido a la validación de las valuaciones del terreno
                        if (entidadGarantiaReal.InconsistenciaValuacionesTerreno)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ValuacionesTerreno)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ValuacionesTerreno)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en las valuaciones del terreno

                        #region Inconsistencia en el código del tipo de grado de gravamen

                        //Se valida si el error es debido a la validación del código del tipo de grado de gravamen
                        if (entidadGarantiaReal.InconsistenciaGradoGravamen)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.GradoGravamen)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.GradoGravamen)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en el código del tipo de grado de gravamen

                        #region Inconsistencia en el código del tipo de documento legal

                        //Se valida si el error es debido a la validación del código del tipo de documento legal
                        if (entidadGarantiaReal.InconsistenciaTipoDocumentoLegal)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.TipoDocumentoLegal)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.TipoDocumentoLegal)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en el código del tipo de documento legal

                        #region Inconsistencia en el código del tipo de mitigador

                        //Se valida si el error es debido a la validación del código del tipo de mitigador
                        if (entidadGarantiaReal.InconsistenciaTipoMitigador)
                        {
                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.TipoMitigador)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.TipoMitigador)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en el código del tipo de mitigador

                        #region Inconsistencia en el tipo de bien

                        //Se valida si el error es debido a la validación del código de la clase de garantía
                        if (entidadGarantiaReal.InconsistenciaTipoBien)
                        {
                            estadoVerificacion = false;

                            cbMitigador.Enabled = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.TipoBien)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.TipoBien)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en el tipo de bien

                        #region Inconsistencia en la clase de garantía

                        //Se valida si el error es debido a la validación del código de la clase de garantía
                        if (entidadGarantiaReal.InconsistenciaClaseGarantia)
                        {
                            BloquearCamposIndicadorInscripcion = "0_0_0_0";
                            BloquearCampos(false, false);
                            errorGrave = true;
                            ErrorGrave = true;
                            BloquearCamposMTATMTANT = true;

                            estadoVerificacion = false;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ClaseGarantia)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ClaseGarantia)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en la clase de garantía

                        #region Inconsistencia en el código del partido

                        //Se valida si el error es debido a la validación del código de partido
                        if (entidadGarantiaReal.InconsistenciaPartido)
                        {
                            BloquearCamposIndicadorInscripcion = "0_0_0_0";
                            BloquearCampos(false, false);

                            estadoVerificacion = false;
                            errorGrave = true;
                            ErrorGrave = true;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.Partido)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.Partido)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en el código del partido

                        #region Inconsistencia en el código del número de finca

                        //Se valida si el error es debido a la validación del código de partido
                        if (entidadGarantiaReal.InconsistenciaFinca)
                        {
                            BloquearCamposIndicadorInscripcion = "0_0_0_0";
                            BloquearCampos(false, false);

                            estadoVerificacion = false;
                            errorGrave = true;
                            ErrorGrave = true;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.Finca)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.Finca)],
                                                                           false);
                                }
                            }
                        }

                        #endregion Inconsistencia en el código del número de finca

                        #region Inconsistencia en el porcentaje de aceptación

                        //Se valida si el error es debido a la validación del porcentaje de aceptación
                        if (entidadGarantiaReal.InconsistenciaPorcentajeAceptacion)
                        {
                            estadoVerificacion = false;

                            BloquearMontoMitigador = false;
                            BloquearPorcentajeAceptacion = ((errorGrave) ? false : true);
                            errorPorcAcep = true;

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.PorcentajeAceptacion)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.PorcentajeAceptacion)],
                                                                           false);
                                }
                            }
                        }

                        if (entidadGarantiaReal.PorcentajeResponsabilidad == 0)
                        {
                            errorMontoMitiga = true;
                        }

                        #endregion Inconsistencia en el porcentaje de aceptación

                        #region Inconsistencia en el monto mitigador

                        //Se valida si el error es debido a la validación del monto mitigador
                        if (entidadGarantiaReal.InconsistenciaMontoMitigador != 0)
                        {
                            StringCollection parametrosCalculo = new StringCollection();
                            estadoVerificacion = false;
                            bool visualizarMensaje = true;
                            bool esInformativo = false;

                            switch (entidadGarantiaReal.InconsistenciaMontoMitigador)
                            {
                                case 1:
                                    EstablecerMetodoHabilitarMontoMitigador();

                                    errorMontoMitiga = true;
                                    txtMontoMitigador.Enabled = false;
                                    txtPorcentajeAceptacion.Enabled = false;
                                    BloquearMontoMitigador = false;
                                    BloquearPorcentajeAceptacion = false;
                                    BloquearCamposIndicadorInscripcion = ((errorGrave) ? "0_0_0_0" : ((errorPorcAcep) ? "1_0_0_1" : "1_0_0_0"));

                                    break;
                                case 2:
                                    break;
                                case 3:

                                    esInformativo = true;
                                    parametrosCalculo.Add(entidadGarantiaReal.MontoTotalAvaluo.ToString());
                                    parametrosCalculo.Add(entidadGarantiaReal.FechaValuacion.ToShortDateString());
                                    parametrosCalculo.Add(entidadGarantiaReal.PorcentajeResponsabilidad.ToString());
                                    parametrosCalculo.Add(entidadGarantiaReal.MontoMitigador.ToString());
                                    parametrosCalculo.Add(((DatosOperacion.Length > 0) ? DatosOperacion.Replace('_', '-'): "--"));

                                    Utilitarios.RegistraEventLog((Mensajes.Obtener(Mensajes.ERROR_MONTO_MITIGADOR_CALCULADO_MAYOR, parametrosCalculo, Mensajes.ASSEMBLY)), EventLogEntryType.Information);

                                    break;
                                case 4:

                                    esInformativo = true;
                                    parametrosCalculo.Add(entidadGarantiaReal.MontoTotalAvaluo.ToString());
                                    parametrosCalculo.Add(entidadGarantiaReal.FechaValuacion.ToShortDateString());
                                    parametrosCalculo.Add(entidadGarantiaReal.PorcentajeResponsabilidad.ToString());
                                    parametrosCalculo.Add(entidadGarantiaReal.MontoMitigador.ToString());
                                    parametrosCalculo.Add(((DatosOperacion.Length > 0) ? DatosOperacion.Replace('_', '-') : "--"));

                                    Utilitarios.RegistraEventLog((Mensajes.Obtener(Mensajes.ERROR_MONTO_MITIGADOR_CALCULADO_MENOR, parametrosCalculo, Mensajes.ASSEMBLY)), EventLogEntryType.Information);
                                    break;
                                case 5: visualizarMensaje = ((mostrarError.HasValue) ? ((bool)mostrarError) : false);

                                    break;
                                default:
                                    break;
                            }

                            if ((mostrarErrorEmergente) && (visualizarMensaje))
                            {
                                DiferenciaMontosMitigadores = ObtenerDiferenciaMontosMitigadores();

                                if (esInformativo)
                                {
                                    if (entidadGarantiaReal.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.MontoMitigador)))
                                    {
                                        MostrarErrorMontoMitigador = false;

                                        //Se obtiene el error de la lista de errores
                                        if (requestSM != null && requestSM.IsInAsyncPostBack)
                                        {
                                            ScriptManager.RegisterClientScriptBlock(this,
                                                                                    typeof(Page),
                                                                                    Guid.NewGuid().ToString(),
                                                                                    entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.MontoMitigador)],
                                                                                    false);
                                        }
                                        else
                                        {
                                            this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                                   Guid.NewGuid().ToString(),
                                                                                   entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.MontoMitigador)],
                                                                                   false);
                                        }
                                    }
                                }
                                else
                                {
                                    if (entidadGarantiaReal.ListaErroresValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.MontoMitigador)))
                                    {
                                        //Se obtiene el error de la lista de errores
                                        if (requestSM != null && requestSM.IsInAsyncPostBack)
                                        {
                                            ScriptManager.RegisterClientScriptBlock(this,
                                                                                    typeof(Page),
                                                                                    Guid.NewGuid().ToString(),
                                                                                    entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.MontoMitigador)],
                                                                                    false);
                                        }
                                        else
                                        {
                                            this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                                   Guid.NewGuid().ToString(),
                                                                                   entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.MontoMitigador)],
                                                                                   false);
                                        }
                                    }
                                }
                            }
                        }

                        #endregion Inconsistencia en el monto mitigador

                        #region Inconsistencia en el indicador de inscripción

                        //Se valida si el error es debido a la validación del indicador de inscripción
                        if (entidadGarantiaReal.InconsistenciaIndicadorInscripcion)
                        {
                            BloquearCamposIndicadorInscripcion = ((errorGrave) ? "0_0_0_0" : ((errorPorcAcep) ? "1_0_0_1" : "1_0_0_0"));
                            BloquearMontoMitigador = false;
                            BloquearPorcentajeAceptacion = false;

                            estadoVerificacion = false;

                            if ((entidadGarantiaReal.CodInscripcion == 1) || (entidadGarantiaReal.CodInscripcion == 2))
                            {
                                txtMontoMitigador.Enabled = false;
                                txtPorcentajeAceptacion.Enabled = false;
                            }

                            if (mostrarErrorEmergente)
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.IndicadorInscripcion)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.IndicadorInscripcion)],
                                                                           false);
                                }
                            }

                        }
                        else
                        {
                            txtMontoMitigador.Enabled = (((errorGrave) || (errorMontoMitiga)) ? false : true);
                            txtPorcentajeAceptacion.Enabled = ((errorGrave) ? false : true);
                            BloquearMontoMitigador = (((errorGrave) || (errorMontoMitiga)) ? false : true);
                            BloquearPorcentajeAceptacion = ((errorGrave) ? false : true);

                            string cadenaActivacionCampos = "1_0_" + ((BloquearMontoMitigador) ? "1" : "0") + ((BloquearPorcentajeAceptacion) ? "_1" : "_0");
                            BloquearCamposIndicadorInscripcion = ((errorGrave) ? "0_0_0_0" : cadenaActivacionCampos);
                        }

                        #endregion Inconsistencia en el indicador de inscripción

                        #region Inconsistencia en la fecha de presentación

                        //Se valida si el error es debido a la validación de la fecha de presentación
                        if (entidadGarantiaReal.InconsistenciaFechaPresentacion)
                        {
                            BloquearCamposIndicadorInscripcion = ((errorGrave) ? "0_0_0_0" : "1_0_0_0");
                            txtMontoMitigador.Enabled = false;
                            txtPorcentajeAceptacion.Enabled = false;
                            BloquearMontoMitigador = false;
                            BloquearPorcentajeAceptacion = false;

                            estadoVerificacion = false;

                            if ((mostrarErrorEmergente) && ((mostrarError.HasValue) || (entidadGarantiaReal.FechaPresentacion != DateTime.MinValue)))
                            {
                                //Se obtiene el error de la lista de errores
                                if (requestSM != null && requestSM.IsInAsyncPostBack)
                                {
                                    ScriptManager.RegisterClientScriptBlock(this,
                                                                            typeof(Page),
                                                                            Guid.NewGuid().ToString(),
                                                                            entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaPresentacion)],
                                                                            false);
                                }
                                else
                                {
                                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                           Guid.NewGuid().ToString(),
                                                                           entidadGarantiaReal.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.FechaPresentacion)],
                                                                           false);
                                }
                            }
                        }
                        else
                        {
                            cbInscripcion.Enabled = false;
                            BloquearIndicadorInscripcion = false;

                            string cadenaActivacionCampos = "1_0" + ((((errorPorcAcep) || (BloquearMontoMitigador)) && (!entidadGarantiaReal.InconsistenciaIndicadorInscripcion)) ? "_1" : "_0") + ((BloquearPorcentajeAceptacion) ? "_1" : "_0");
                            BloquearCamposIndicadorInscripcion = ((errorGrave) ? "0_0_0_0" : (((errorPorcAcep) && (!entidadGarantiaReal.InconsistenciaIndicadorInscripcion)) ? "1_0_0_1" : cadenaActivacionCampos));
                        }

                        #endregion Inconsistencia en la fecha de presentación
                    }
                    else
                    {
                        lblMensaje3.Text = ((entidadGarantiaReal.DescripcionError.Length > 0) ? entidadGarantiaReal.DescripcionError : string.Empty);

                        if (lblMensaje3.Text.Trim().Length == 0)
                        {
                            txtMontoMitigador.Enabled = true;
                            txtPorcentajeAceptacion.Enabled = true;

                            BloquearMontoMitigador = true;
                            BloquearPorcentajeAceptacion = true;
                            BloquearCamposIndicadorInscripcion = "1_0_1_1";

                            cbMitigador.Enabled = true;
                            cbTipoBien.Enabled = true;
                        }
                    }
                }
                else
                {
                    if (entidadGarantiaReal.DescripcionError.Length > 0)
                    {
                        lblMensaje3.Text = entidadGarantiaReal.DescripcionError;
                    }
                    else
                    {
                        txtMontoMitigador.Enabled = true;
                        txtPorcentajeAceptacion.Enabled = true;

                        BloquearMontoMitigador = true;
                        BloquearPorcentajeAceptacion = true;
                        BloquearCamposIndicadorInscripcion = "1_0_1_1";

                        cbMitigador.Enabled = true;
                        cbTipoBien.Enabled = true;
                    }

                }

                #region Mostrar Lista de Operaciones Comunes

                if ((!MostrarListaOperaciones) && (!entidadGarantiaReal.ErrorDatosRequeridos) && (entidadGarantiaReal.OperacionesRelacionadas != null) && (entidadGarantiaReal.OperacionesRelacionadas.Count > 0)
                   && (entidadGarantiaReal.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.ListaOperaciones))))
                {
                    MostrarListaOperaciones = false;

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.ListaOperaciones)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.ListaOperaciones)],
                                                               false);
                    }
                }

                #endregion Mostrar Lista de Operaciones Comunes

                #region Mostrar Lista de Operaciones con Infra Seguro

                if ((!MostrarErrorInfraSeguro) && (!entidadGarantiaReal.ErrorDatosRequeridos) && (entidadGarantiaReal.OperacionesRelacionadas != null) && (entidadGarantiaReal.OperacionesRelacionadas.Count > 0)
                   && (entidadGarantiaReal.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.InfraSeguro))))
                {
                    MostrarErrorInfraSeguro = false;

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.InfraSeguro)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.InfraSeguro)],
                                                               false);
                    }
                }

                #endregion Mostrar Lista de Operaciones con Infra Seguro

                #region Mostrar Lista de Operaciones con misma garantía y misma póliza pero montos de acreencia diferentes

                if ((!MostrarErrorAcreenciasDiferentes) && (!entidadGarantiaReal.ErrorDatosRequeridos) && (entidadGarantiaReal.OperacionesRelacionadas != null) && (entidadGarantiaReal.OperacionesRelacionadas.Count > 0)
                   && (entidadGarantiaReal.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.AcreenciasDiferentes))))
                {
                    MostrarErrorAcreenciasDiferentes = false;

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.AcreenciasDiferentes)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantiaReal.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.AcreenciasDiferentes)],
                                                               false);
                    }
                }

                #endregion Mostrar Lista de Operaciones con misma garantía y misma póliza pero montos de acreencia diferentes
            }

            return estadoVerificacion;
        }

        /// <summary>
        /// Se habilitan o no ciertos controles, todo segn el indicador obtenido al aplicar la validaciones
        /// </summary>
        private void HabilitarCamposValidados()
        {
            GuardarDatosSession();
            entidadGarantia.EntidadValida(false);

            entidadGarantia.ListaMensajesValidaciones = new SortedDictionary<int, string>();

            VerificarValidaciones(entidadGarantia, false);

            txtMontoMitigador.Enabled = BloquearMontoMitigador;
            cbInscripcion.Enabled = false;
            txtFechaRegistro.Enabled = BloquearFechaPresentacion;
            cleFechaRegistro.Enabled = BloquearFechaPresentacion;
            igbCalendario.Enabled = BloquearFechaPresentacion;
            txtPorcentajeAceptacion.Enabled = BloquearPorcentajeAceptacion;
        }

        /// <summary>
        /// Se encarga de eliminar las variables de sesión propias de la validación de cada operación y garantía,
        /// así mismo de los atributos agregados a controles o al ViewState de la página,
        /// </summary>
        private void EliminarDatosGlobales()
        {
            #region Datos guardados en Session

            if (Session[LLAVE_ENTIDAD_GARANTIA] != null)
            {
                Session.Remove(LLAVE_ENTIDAD_GARANTIA);
            }

            if (Session[LLAVE_CONSECUTIVO_OPERACION] != null)
            {
                Session.Remove(LLAVE_CONSECUTIVO_OPERACION);
            }

            if (Session[LLAVE_CONSECUTIVO_GARANTIA] != null)
            {
                Session.Remove(LLAVE_CONSECUTIVO_GARANTIA);
            }

            if (Session[LLAVE_DESCRIPCION_GARANTIA] != null)
            {
                Session.Remove(LLAVE_DESCRIPCION_GARANTIA);
            }

            if (Session[LLAVE_DATOS_OPERACION] != null)
            {
                Session.Remove(LLAVE_DATOS_OPERACION);
            }

            if (Session[LLAVE_TRAMA_INICIAL] != null)
            {
                Session.Remove(LLAVE_TRAMA_INICIAL);
            }

            if (Session[LLAVE_ES_GIRO] != null)
            {
                Session.Remove(LLAVE_ES_GIRO);
            }

            if (Session[LLAVE_CONSECUTIVO_CONTRATO] != null)
            {
                Session.Remove(LLAVE_CONSECUTIVO_CONTRATO);
            }

            if (Session["Accion"] != null)
            {
                Session.Remove("Accion");
            }

            if (Session["EsOperacionValidaReal"] != null)
            {
                Session.Remove("EsOperacionValidaReal");
            }

            if (Session["EsOperacionValida"] != null)
            {
                Session.Remove("EsOperacionValida");
            }

            if (Session["Nombre_Deudor"] != null)
            {
                Session.Remove("Nombre_Deudor");
            }

            if (Session["Tipo_Operacion"] != null)
            {
                Session.Remove("Tipo_Operacion");
            }

            if (Session["Operacion"] != null)
            {
                Session.Remove("Operacion");
            }

            if (Session["Deudor"] != null)
            {
                Session.Remove("Deudor");
            }

            if (Session["GarantiaReal"] != null)
            {
                Session.Remove("GarantiaReal");
            }

            if (Session["EsCambioTipoGarantia"] != null)
            {
                Session.Remove("EsCambioTipoGarantia");
            }

            if (Session[LLAVE_TIPO_GARANTIA_REAL] != null)
            {
                Session.Remove(LLAVE_TIPO_GARANTIA_REAL);
            }

            if (Session[LLAVE_BLOQUEAR_AVALUOS] != null)
            {
                Session.Remove(LLAVE_BLOQUEAR_AVALUOS);
            }

            if (Session[LLAVE_HABILITAR_AVALUO] != null)
            {
                Session.Remove(LLAVE_HABILITAR_AVALUO);
            }

            if (Session[LLAVE_AVALUO_ACTUALIZADO] != null)
            {
                Session.Remove(LLAVE_AVALUO_ACTUALIZADO);
            }

            if (Session[LLAVE_FECHA_SEMESTRE_ACTUALIZADO] != null)
            {
                Session.Remove(LLAVE_FECHA_SEMESTRE_ACTUALIZADO);
            }

            if (Session[LLAVE_BLOQUEAR_POLIZA] != null)
            {
                Session.Remove(LLAVE_BLOQUEAR_POLIZA);
            }

            if (Session[LLAVE_HABILITAR_POLIZA] != null)
            {
                Session.Remove(LLAVE_HABILITAR_POLIZA);
            }

            #endregion Datos guardados en Session

            #region Datos guardados en el botón btnValidaroOperacion

            if (btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_FECHA_PRESENTACION] != null)
            {
                btnValidarOperacion.Attributes.Remove(BLOQUEAR_CAMPO_FECHA_PRESENTACION);
            }

            if (btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_INDICADOR_INSCRIPCION] != null)
            {
                btnValidarOperacion.Attributes.Remove(BLOQUEAR_CAMPO_INDICADOR_INSCRIPCION);
            }

            if (btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_MONTO_MITIGADOR] != null)
            {
                btnValidarOperacion.Attributes.Remove(BLOQUEAR_CAMPO_MONTO_MITIGADOR);
            }

            if (btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_PORCENTAJE_ACEPTACION] != null)
            {
                btnValidarOperacion.Attributes.Remove(BLOQUEAR_CAMPO_PORCENTAJE_ACEPTACION);
            }

            if (btnValidarOperacion.Attributes[INDICADOR_ERROR_GRAVE] != null)
            {
                btnValidarOperacion.Attributes.Remove(INDICADOR_ERROR_GRAVE);
            }

            #region Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

            if (btnValidarOperacion.Attributes[LLAVE_MONTO_TOTAL_AVALUO] != null)
            {
                btnValidarOperacion.Attributes.Remove(LLAVE_MONTO_TOTAL_AVALUO);
            }

            #endregion Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

            if (btnValidarOperacion.Attributes[ANNOS_CALCULO_FECHA_PRESCRIPCION] != null)
            {
                btnValidarOperacion.Attributes.Remove(ANNOS_CALCULO_FECHA_PRESCRIPCION);
            }

            if (btnValidarOperacion.Attributes[BLOQUEAR_CAMPO_FECHA_VENCIMIENTO] != null)
            {
                btnValidarOperacion.Attributes.Remove(BLOQUEAR_CAMPO_FECHA_VENCIMIENTO);
            }

            if (btnValidarOperacion.Attributes[LLAVE_EXISTE_AVALUO] != null)
            {
                btnValidarOperacion.Attributes.Remove(LLAVE_EXISTE_AVALUO);
            }

            if (btnValidarOperacion.Attributes[LLAVE_MOSTRAR_ERROR_MONTO_MITIGADOR] != null)
            {
                btnValidarOperacion.Attributes.Remove(LLAVE_MOSTRAR_ERROR_MONTO_MITIGADOR);
            }

            if (btnValidarOperacion.Attributes[LLAVE_MONTO_MITIGADOR_CALCULADO] != null)
            {
                btnValidarOperacion.Attributes.Remove(LLAVE_MONTO_MITIGADOR_CALCULADO);
            }

            if (btnValidarOperacion.Attributes[LLAVE_ERROR_GRAVE_AVALUO] != null)
            {
                btnValidarOperacion.Attributes.Remove(LLAVE_ERROR_GRAVE_AVALUO);
            }

            if (btnValidarOperacion.Attributes[LLAVE_DESCRIPCION_GARANTIA] != null)
            {
                btnValidarOperacion.Attributes.Remove(LLAVE_DESCRIPCION_GARANTIA);
            }

            if (btnValidarOperacion.Attributes[BLOQUEAR_CAMPOS_MTAT_MTANT] != null)
            {
                btnValidarOperacion.Attributes.Remove(BLOQUEAR_CAMPOS_MTAT_MTANT);
            }

            if (btnValidarOperacion.Attributes[LLAVE_LISTA_OPERACIONES] != null)
            {
                btnValidarOperacion.Attributes.Remove(LLAVE_LISTA_OPERACIONES);
            }

            if (btnValidarOperacion.Attributes[LLAVE_CARGA_INICIAL] != null)
            {
                btnValidarOperacion.Attributes.Remove(LLAVE_CARGA_INICIAL);
            }

            if (btnValidarOperacion.Attributes[LLAVE_ERROR_INCONSISTENCIA_SIN_POLIZA] != null)
            {
                btnValidarOperacion.Attributes.Remove(LLAVE_ERROR_INCONSISTENCIA_SIN_POLIZA);
            }
            
            #endregion Datos guardados en el botón btnValidaroOperacion

            #region Datos guardados en el botón btnModificar

            if (btnModificar.Attributes[INDICADOR_BOTON_GUARDAR] != null)
            {
                btnModificar.Attributes.Remove(INDICADOR_BOTON_GUARDAR);
            }

            #endregion Datos guardados en el botón btnModificar

            #region Datos guardados en el ViewState

            if (ViewState[LLAVE_ENTIDAD_CATALOGOS] != null)
            {
                ViewState.Remove(LLAVE_ENTIDAD_CATALOGOS);
            }

            if (ViewState[LLAVE_ENTIDAD_PERITOS] != null)
            {
                ViewState.Remove(LLAVE_ENTIDAD_PERITOS);
            }

            if (ViewState[LLAVE_ENTIDAD_EMPRESAS] != null)
            {
                ViewState.Remove(LLAVE_ENTIDAD_EMPRESAS);
            }

            #endregion Datos guardados en el ViewState
        }

        /// <summary>
        /// Obtiene la cantidad de años requeridos para calcular la fecha de prescripción, segn el tipo de garantía real
        /// </summary>
        /// <param name="tipoGarantiaReal">Código del tipo de garantía real</param>
        /// <returns>Cantidad de años usados para el cálculo de la fecha de prescripción</returns>
        private int ObtenerCantidadAnnosPrescripcion(int tipoGarantiaReal)
        {
            int cantidadAnnos;

            try
            {
                switch (tipoGarantiaReal)
                {
                    case 1: cantidadAnnos = (int.TryParse(Application["ANNOS_FECHA_PRESCRIPCION_HIPOTECA"].ToString(), out cantidadAnnos) ? cantidadAnnos : 0);
                        break;
                    case 2: cantidadAnnos = (int.TryParse(Application["ANNOS_FECHA_PRESCRIPCION_CEDULA_HIPOTECARIA"].ToString(), out cantidadAnnos) ? cantidadAnnos : 0);
                        break;
                    case 3: cantidadAnnos = (int.TryParse(Application["ANNOS_FECHA_PRESCRIPCION_PRENDA"].ToString(), out cantidadAnnos) ? cantidadAnnos : 0);
                        break;
                    default: cantidadAnnos = 0;
                        break;
                }
            }
            catch (Exception ex)
            {
                cantidadAnnos = 0;

                lblMensaje3.Text = Mensajes.Obtener(Mensajes._errorDatosArchivoConfiguracion, Mensajes.ASSEMBLY);

                Utilitarios.RegistraEventLog((Mensajes.Obtener(Mensajes._errorDatosArchivoConfiguracionDetalle,
                    "los aos configurados para el cálculo de la fecha de prescripción",
                    ex.Message, Mensajes.ASSEMBLY)), EventLogEntryType.Error);
            }


            return cantidadAnnos;
        }

        /// <summary>
        /// Se encarga de obtener el monto total del avalúo más reciente.
        /// </summary>
        /// <param name="nGarantia">Consecutivo de la garantía</param>
        /// <param name="desGarantia">Identificación del bien</param>
        /// <returns>Monto total del avalúo más reciente. En caso de encontrarse se retorna 0</returns>
        private decimal ObtenerMontoTotalValuacionReciente(long nGarantia, string desGarantia)
        {
            clsValuacionesReales<clsValuacionReal> avaluoReciente = new clsValuacionesReales<clsValuacionReal>();

            decimal montoRetornado = 0;

            int catRP;
            int catIMM;

            int catalogoRP = (int.TryParse(Application["CAT_RECOMENDACION_PERITO"].ToString(), out catRP) ? catRP : -1);
            int catalogoIMM = (int.TryParse(Application["CAT_INSPECCION_3_MESES"].ToString(), out catIMM) ? catIMM : -1);

            avaluoReciente = Gestor.Obtener_Avaluos(nGarantia, desGarantia, true, catalogoRP, catalogoIMM);

            if ((avaluoReciente != null) && (avaluoReciente.Count > 0))
            {
                montoRetornado = (avaluoReciente.Item(0).MontoTasacionActualizadaTerreno + avaluoReciente.Item(0).MontoTasacionActualizadaNoTerreno);
            }

            return montoRetornado;
        }

        /// <summary>
        /// Permite modificar la información de una garantía.
        /// </summary>
        private void ModificarGarantia()
        {
            ExisteValuacion = true;

            entidadGarantia.FechaModifico = DateTime.Now;

            //entidadGarantia.PorcentajeResponsabilidad >hace referencia al porcentaje aceptacion 
            //se selecciona el valor del campo menor entre el % aceptacion y % aceptacion calculado

            if (entidadGarantia.CodTipoBien <= 4)
            {
                if ((entidadGarantia.PorcentajeResponsabilidad > entidadGarantia.PorcentajeAceptacionCalculado) || (entidadGarantia.PorcentajeResponsabilidad == 0))
                {
                    entidadGarantia.PorcentajeResponsabilidad = entidadGarantia.PorcentajeAceptacionCalculado;
                } 
            }
                               

            Gestor.ModificarGarantiaReal(entidadGarantia, Session["strUSER"].ToString(), Request.UserHostAddress.ToString(), strOperacionCrediticia, strGarantia);

            #region Siebel 1-24206841. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 24/03/2014.

            if (entidadGarantia.OperacionesRelacionadas.Count > 0)
            {
                Gestor.NormalizarDatosGarantiaReal(entidadGarantia, Session["strUSER"].ToString(), Request.UserHostAddress.ToString(), strOperacionCrediticia, strGarantia);
            }

            #endregion Siebel 1-24206841. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 24/03/2014.

            //Se obtiene la lista de semestres actualizados, esto si se dio algún cambio en los datos del avalúo que disparara el recalculo de los montos.
            if (this.hdnListaSemestresCalculados.Value.Length > 0)
            {
                clsSemestres<clsSemestre> listaSemestre = new clsSemestres<clsSemestre>(this.hdnListaSemestresCalculados.Value, true);

                if ((listaSemestre != null) && (listaSemestre.Count > 0))
                {
                    clsGarantiaReal garantiaSemestres = entidadGarantia;
                    garantiaSemestres.ListaSemestresCalcular = listaSemestre;

                    string tramaSemestres = garantiaSemestres.ToString(2);

                    if (tramaSemestres.Length > 0)
                    {
                        Gestor.InsertarSemetresCalculados(tramaSemestres, Session["strUSER"].ToString());
                    }
                }
            }

            CargarCombos();
            LimpiarCampos();

            StringBuilder url = new StringBuilder(Page.ResolveUrl("frmMensaje.aspx"));
            url.Append("?bError=0&strTitulo=Modificación Exitosa&strMensaje=");
            url.Append(Mensajes.Obtener(Mensajes.MODIFICACION_SATISFACTORIA_GARANTIA, "real", Mensajes.ASSEMBLY));
            url.Append("&bBotonVisible=1&strTextoBoton=Regresar&strHref=frmGarantiasReales.aspx");

            Response.Redirect(url.ToString(), false);
        }

        /// <summary>
        /// Método que muestra el error del monto mitigador, cuando la garantía tiene sólo esta inconsistencia.
        /// </summary>
        private void MostrarError()
        {
            DiferenciaMontosMitigadores = ObtenerDiferenciaMontosMitigadores();

            ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

            //Se obtiene el error de la lista de errores
            if (requestSM != null && requestSM.IsInAsyncPostBack)
            {
                ScriptManager.RegisterClientScriptBlock(this,
                                                        typeof(Page),
                                                        Guid.NewGuid().ToString(),
                                                        entidadGarantia.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.MontoMitigador)],
                                                        false);
            }
            else
            {
                this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                       Guid.NewGuid().ToString(),
                                                       entidadGarantia.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.MontoMitigador)],
                                                       false);
            }
        }

        /// <summary>
        /// Método que obtiene la diferencia entre el monto mitigador registrado y el cálculado.
        /// </summary>
        /// <returns>Diferencia entre los montos, formateado.</returns>
        private string ObtenerDiferenciaMontosMitigadores()
        {
            string diferenciaMontos = "0.00";

            if (entidadGarantia != null)
            {
                decimal porcentaje = Convert.ToDecimal((entidadGarantia.PorcentajeResponsabilidad / 100));
                decimal montoMitigaCalc = Convert.ToDecimal(entidadGarantia.MontoTotalAvaluo * porcentaje);

                decimal diferenciaEntreMontos = (((montoMitigaCalc >= entidadGarantia.MontoMitigador)) ? (Convert.ToDecimal(montoMitigaCalc - entidadGarantia.MontoMitigador)) : (Convert.ToDecimal(entidadGarantia.MontoMitigador - montoMitigaCalc)));

                diferenciaMontos = diferenciaEntreMontos.ToString("N");
            }

            return diferenciaMontos;
        }

        /// <summary>
        /// Método que se encarga de aplicar el cálculo del monto mitigador cada vez que se refresque la página.
        /// </summary>
        private void AplicarCalculoMontoMitigador()
        {
            if (entidadGarantia != null)
            {
                decimal montoMitigadorCalculado = 0;

                //Se calcula el monto mitigador
                montoMitigadorCalculado = Convert.ToDecimal((entidadGarantia.MontoTotalAvaluo * (Convert.ToDecimal((entidadGarantia.PorcentajeResponsabilidad / 100)))));

                //Si el monto calculado es menor a 0 (cero), se asignará este valor.
                txtMontoMitigadorCalculado.Text = ((montoMitigadorCalculado >= 0) ? montoMitigadorCalculado.ToString("N") : "0.00");

                DiferenciaMontosMitigadores = ObtenerDiferenciaMontosMitigadores();
            }
        }

        /// <summary>
        /// Método que se encarga de asignar la función de javascript que permite habilitar el monto mitigador cuando se ingresa el avalúo
        /// </summary>
        private void EstablecerMetodoHabilitarMontoMitigador()
        {
            string eventoOnBlur = string.Empty;

            eventoOnBlur = ((cbPerito.Attributes["onblur"] != null) ? cbPerito.Attributes["onblur"] : string.Empty);
            eventoOnBlur = eventoOnBlur.Replace("javascript:HabilitarCampoMontoMitigador(1);", string.Empty);
            eventoOnBlur = ((eventoOnBlur.Length > 0) ? (eventoOnBlur + " javascript:HabilitarCampoMontoMitigador(1);") : "javascript:HabilitarCampoMontoMitigador(1);");

            cbPerito.Attributes.Add("onblur", eventoOnBlur);

            eventoOnBlur = ((cbEmpresa.Attributes["onblur"] != null) ? cbEmpresa.Attributes["onblur"] : string.Empty);
            eventoOnBlur = eventoOnBlur.Replace("javascript:HabilitarCampoMontoMitigador(1);", string.Empty);
            eventoOnBlur = ((eventoOnBlur.Length > 0) ? (eventoOnBlur + " javascript:HabilitarCampoMontoMitigador(1);") : "javascript:HabilitarCampoMontoMitigador(1);");

            cbEmpresa.Attributes.Add("onblur", eventoOnBlur);

            eventoOnBlur = ((txtMontoUltTasacionTerreno.Attributes["onblur"] != null) ? txtMontoUltTasacionTerreno.Attributes["onblur"] : string.Empty);
            eventoOnBlur = eventoOnBlur.Replace("javascript:HabilitarCampoMontoMitigador(2);", string.Empty);
            eventoOnBlur = ((eventoOnBlur.Length > 0) ? (eventoOnBlur + " javascript:HabilitarCampoMontoMitigador(2);") : "javascript:HabilitarCampoMontoMitigador(2);");

            txtMontoUltTasacionTerreno.Attributes.Add("onblur", eventoOnBlur);

            eventoOnBlur = ((txtMontoUltTasacionNoTerreno.Attributes["onblur"] != null) ? txtMontoUltTasacionNoTerreno.Attributes["onblur"] : string.Empty);
            eventoOnBlur = eventoOnBlur.Replace("javascript:HabilitarCampoMontoMitigador(2);", string.Empty);
            eventoOnBlur = ((eventoOnBlur.Length > 0) ? (eventoOnBlur + " javascript:HabilitarCampoMontoMitigador(2);") : "javascript:HabilitarCampoMontoMitigador(2);");

            txtMontoUltTasacionNoTerreno.Attributes.Add("onblur", eventoOnBlur);

            eventoOnBlur = ((txtFechaSeguimiento.Attributes["onblur"] != null) ? txtFechaSeguimiento.Attributes["onblur"] : string.Empty);
            eventoOnBlur = eventoOnBlur.Replace("javascript:HabilitarCampoMontoMitigador(3);", string.Empty);
            eventoOnBlur = ((eventoOnBlur.Length > 0) ? (eventoOnBlur + " javascript:HabilitarCampoMontoMitigador(3);") : "javascript:HabilitarCampoMontoMitigador(3);");

            txtFechaSeguimiento.Attributes.Add("onblur", eventoOnBlur);
        }

        /// <summary>
        /// Método que se encarga de bloquear o habilitar ciertos campos del avalúo, según el tipo de bien
        /// </summary>
        private void BloquearCamposAvaluo()
        {
            if (!ErrorGrave)
            {
                bool fechaAval = (txtFechaValuacion.Text.Trim().Length > 0) ? true : false;
                bool fechaAvalSicc = (txtFechaValuacionSICC.Text.Trim().Length > 0) ? true : false;

                if ((fechaAval) && (fechaAvalSicc) && (txtFechaValuacion.Text.Trim().CompareTo(txtFechaValuacionSICC.Text.Trim()) == 0))
                {
                    int tipoBien = int.Parse((((cbTipoBien != null) && (cbTipoBien.Items != null) && (cbTipoBien.Items.Count > 0)) ? cbTipoBien.SelectedItem.Value : "-1"));

                    if (tipoBien == 1)
                    {
                        BloquearCamposMTATMTANT = true;
                        txtMontoTasActTerreno.Enabled = false;
                        txtMontoTasActNoTerreno.Enabled = false;
                        txtMontoUltTasacionNoTerreno.Enabled = false;
                        txtFechaConstruccion.Enabled = false;
                        txtFechaSeguimiento.Enabled = AvaluoActualizado;
                        igbCalendarioConstruccion.Enabled = false;
                        igbCalendarioSeguimiento.Enabled = AvaluoActualizado;

                        if (txtMontoUltTasacionNoTerreno.Text.Length > 0)
                        {
                            if (txtMontoUltTasacionNoTerreno.Text.CompareTo("0.00") == 0)
                            {
                                txtMontoUltTasacionNoTerreno.Enabled = false;
                            }
                            else
                            {
                                txtMontoUltTasacionNoTerreno.Enabled = true;
                            }
                        }
                        else
                        {
                            txtMontoUltTasacionNoTerreno.Enabled = false;
                        }

                        if (txtFechaConstruccion.Text.Length == 0)
                        {
                            txtFechaConstruccion.Enabled = false;
                            igbCalendarioConstruccion.Visible = false;
                        }
                        else
                        {
                            txtFechaConstruccion.Enabled = true;
                        }
                    }
                    else if (tipoBien == 2)
                    {
                        BloquearCamposMTATMTANT = true;
                        txtMontoTasActTerreno.Enabled = false;
                        txtMontoTasActNoTerreno.Enabled = false;
                        txtMontoUltTasacionNoTerreno.Enabled = true;
                        txtFechaConstruccion.Enabled = true;
                        txtFechaSeguimiento.Enabled = AvaluoActualizado;
                        igbCalendarioConstruccion.Enabled = true;
                        igbCalendarioSeguimiento.Enabled = AvaluoActualizado;
                    }
                    else
                    {
                        BloquearCamposMTATMTANT = false;
                        txtMontoTasActTerreno.Enabled = true;
                        txtMontoTasActNoTerreno.Enabled = true;
                        txtMontoUltTasacionNoTerreno.Enabled = true;
                        txtFechaConstruccion.Enabled = true;
                        txtFechaSeguimiento.Enabled = true;
                        igbCalendarioConstruccion.Enabled = true;
                        igbCalendarioSeguimiento.Enabled = true;
                    }
                }
                else
                {
                    BloquearCamposMTATMTANT = true;
                    txtMontoTasActTerreno.Enabled = false;
                    txtMontoTasActNoTerreno.Enabled = false;
                    txtMontoUltTasacionNoTerreno.Enabled = false;
                    txtFechaConstruccion.Enabled = false;
                    txtFechaSeguimiento.Enabled = false;
                    igbCalendarioConstruccion.Enabled = false;
                    igbCalendarioSeguimiento.Enabled = false;
                }
            }
            else
            {
                BloquearCamposMTATMTANT = true;
                txtMontoTasActTerreno.Enabled = false;
                txtMontoTasActNoTerreno.Enabled = false;
                txtMontoUltTasacionNoTerreno.Enabled = false;
                txtFechaConstruccion.Enabled = false;
                txtFechaSeguimiento.Enabled = false;
                igbCalendarioConstruccion.Enabled = false;
                igbCalendarioSeguimiento.Enabled = false;
            }
        }

        /// <summary>
        /// Método que muestra el mensaje que enlista las operaciones al as que está asociada la garantía.
        /// </summary>
        private void MostrarListadoOperaciones()
        {
            if (entidadGarantia.ListaErroresValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.ListaOperaciones)))
            {
                ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

                //Se obtiene el error de la lista de errores
                if (requestSM != null && requestSM.IsInAsyncPostBack)
                {
                    ScriptManager.RegisterClientScriptBlock(this,
                                                            typeof(Page),
                                                            Guid.NewGuid().ToString(),
                                                            entidadGarantia.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ListaOperaciones)],
                                                            false);
                }
                else
                {
                    this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                           Guid.NewGuid().ToString(),
                                                           entidadGarantia.ListaErroresValidaciones[((int)Enumeradores.Inconsistencias.ListaOperaciones)],
                                                           false);
                }
            }
        }

        /// <summary>
        /// Muestra los mensajes de información al momento de guardar los datos de la garantía
        /// </summary>
        private void MostrarMensajesInformativos()
        {
            bool existeMensaje = false;

            if (entidadGarantia.ListaMensajesValidaciones.Count > 0)
            {
                ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

                if (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.MontoMitigador)))
                {
                    existeMensaje = true;
                    MostrarErrorMontoMitigador = false;
                    DiferenciaMontosMitigadores = ObtenerDiferenciaMontosMitigadores();

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.MontoMitigador)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.MontoMitigador)],
                                                               false);
                    }
                }
                else
                {
                    MostrarErrorMontoMitigador = true;
                }

                if (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.ListaOperaciones)))
                {
                    existeMensaje = true;
                    MostrarListaOperaciones = false;

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.ListaOperaciones)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.ListaOperaciones)],
                                                               false);
                    }
                }
                else
                {
                    MostrarListaOperaciones = true;
                }

                if (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.InfraSeguro)))
                {
                    existeMensaje = true;
                    MostrarErrorInfraSeguro = false;

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.InfraSeguro)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.InfraSeguro)],
                                                               false);
                    }
                }
                else
                {
                    MostrarErrorInfraSeguro = true;
                }

                if (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.AcreenciasDiferentes)))
                {
                    existeMensaje = true;
                    MostrarErrorAcreenciasDiferentes = false;

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.AcreenciasDiferentes)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.AcreenciasDiferentes)],
                                                               false);
                    }
                }
                else
                {
                    MostrarErrorAcreenciasDiferentes = true;
                }

                //
                if (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaInvalida)))
                {
                    existeMensaje = true;
                    MostrarErrorPolizaInvalida = false;

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.PolizaInvalida)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.PolizaInvalida)],
                                                               false);
                    }
                }
                else
                {
                    MostrarErrorPolizaInvalida = true;
                }

                //
                if (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.PolizaNoAsociada)))
                {
                    existeMensaje = true;
                    MostrarErrorSinPolizaAsociada = false;

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.PolizaNoAsociada)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.PolizaNoAsociada)],
                                                               false);
                    }
                }
                else
                {
                    MostrarErrorSinPolizaAsociada = true;
                }

                //
                if (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.MontoPolizaNoCubreBien)))
                {
                    existeMensaje = true;
                    MostrarErrorMontoPolizaCubreBien = false;

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.MontoPolizaNoCubreBien)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.MontoPolizaNoCubreBien)],
                                                               false);
                    }
                }
                else
                {
                    MostrarErrorMontoPolizaCubreBien = true;
                }

                //
                if (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)))
                {
                    existeMensaje = true;
                    MostrarErrorFechaUltimoSeguimientoMayor = false;

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaSeguimientoMayor)],
                                                               false);
                    }
                }
                else
                {
                    MostrarErrorFechaUltimoSeguimientoMayor = true;
                }

                //
                if (entidadGarantia.ListaMensajesValidaciones.ContainsKey(((int)Enumeradores.Inconsistencias.FechaValuacionMayor)))
                {
                    existeMensaje = true;
                    MostrarErrorFechaValuacionMayor = false;

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaValuacionMayor)],
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               entidadGarantia.ListaMensajesValidaciones[((int)Enumeradores.Inconsistencias.FechaValuacionMayor)],
                                                               false);
                    }
                }
                else
                {
                    MostrarErrorFechaValuacionMayor = true;
                }
                //


                if (existeMensaje)
                {
                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                "ModifGarantia",
                                                                "<script type=\"text/javascript\" language=\"javascript\"> ModificarGarantia(); </script>",
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               "ModifGarantia",
                                                                "<script type=\"text/javascript\" language=\"javascript\"> ModificarGarantia(); </script>",
                                                                false);
                    }
                }
            }

        }

        /// <summary>
        /// Método que se encarga de cargar la lista de pólizas según el tipo de bien seleccionado
        /// </summary>
        /// <param name="tipoBien">Código del tipo de bien seleccionado</param>
        private void FiltrarPolizasSap(int tipoBien)
        {
            clsTiposBienRelacionados<clsTipoBienRelacionado> entidadTiposBienRelacionados = new clsTiposBienRelacionados<clsTipoBienRelacionado>();

            try
            {
                if (tipoBien != -1)
                {
                    ListItem valorNulo = new ListItem(string.Empty, "-1");

                    cbCodigoSap.DataSource = null;
                    cbCodigoSap.DataSource = Entidad_Real.PolizasSap.ObtenerPolizasPorTipoBien(tipoBien);
                    cbCodigoSap.DataValueField = "CodigoPolizaSap";
                    cbCodigoSap.DataTextField = "CodigoDescripcionPolizaSap";
                    cbCodigoSap.DataBind();
                    cbCodigoSap.ClearSelection();

                    cbCodigoSap.Items.Insert(0, valorNulo);
                }
                else
                {
                    cbCodigoSap.ClearSelection();
                    cbCodigoSap.Items.Clear();
                }

                txtMontoPoliza.Text = string.Empty;
                cbMonedaPoliza.SelectedIndex = -1;
                txtCedulaAcreedorPoliza.Text = string.Empty;
                txtNombreAcreedorPoliza.Text = string.Empty;
                txtFechaVencimientoPoliza.Text = string.Empty;
                txtMontoAcreenciaPoliza.Text = string.Empty;
                txtDetallePoliza.Text = string.Empty;
                rdlEstadoPoliza.SelectedIndex = -1;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

  
        #endregion

        #region Métodos Web para consumir con AJAX

        #region Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

        /// <summary>
        /// Se encarga de realizar el cálculo del monto mitigador, mismo que será mostrado, de forma asicrónica, 
        /// en el campo del Monto Mitigador Calculado.
        /// </summary>
        /// <param name="porcentajeAceptacion">Porcentaje de aceptación</param>
        /// <param name="montoTotalAvaluo">Monto Total del Avalúo más reciente</param>
        /// <returns>Monto mitigador cálculado, se envía como cadena de caracteres</returns>
        [System.Web.Services.WebMethod]
        public static string CalcularMontoMitigador(string porcentajeAceptacion, string montoTotalAvaluo)
        {
            string monMitigadorCalculado = string.Empty;
            bool errorConversion = false;
            decimal porcentAcept;
            decimal montoTotalValuacion;
            decimal montoMitigadorCalculado = 0;
            StringCollection parametrosExcepcion = new StringCollection();

            try
            {
                //Se conviente a "decimal" cada dato, en caso de que no se pueda implica que el cálculo no puede ser llevado a cabo.
                if (!decimal.TryParse(porcentajeAceptacion, out porcentAcept))
                {
                    monMitigadorCalculado = "0.00";
                    errorConversion = true;

                    parametrosExcepcion.Add(porcentajeAceptacion);
                    parametrosExcepcion.Add("decimal");
                    parametrosExcepcion.Add("frmGarantiasReales.aspx");

                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConvirtiendoDatoDetalle, parametrosExcepcion, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                }

                if (!decimal.TryParse(montoTotalAvaluo, out montoTotalValuacion))
                {
                    monMitigadorCalculado = "0.00";
                    errorConversion = true;

                    parametrosExcepcion.Add(montoTotalAvaluo);
                    parametrosExcepcion.Add("decimal");
                    parametrosExcepcion.Add("frmGarantiasReales.aspx");

                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConvirtiendoDatoDetalle, parametrosExcepcion, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                }

                //Se verifica que no se haya producido ningún error al momento de convertir los valores.
                if (!errorConversion)
                {
                    //Se realiza el cálculo del monto
                    porcentAcept = Convert.ToDecimal((porcentAcept / 100));

                    montoMitigadorCalculado = Convert.ToDecimal(montoTotalValuacion * porcentAcept);

                    //En caso de que el monto calculado sea menor a 0 (cero), se mostrará este valor con el fin de no presentar monto negativos.
                    monMitigadorCalculado = ((montoMitigadorCalculado >= 0) ? montoMitigadorCalculado.ToString("N") : "0.00");
                }
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCalculandoMontoMitigadorDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                monMitigadorCalculado = Mensajes.Obtener(Mensajes._errorCalculandoMontoMitigador, Mensajes.ASSEMBLY);
            }

            return monMitigadorCalculado;
        }

        #endregion Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

        #region Siebel 1-24077737. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 29/11/2013.

        /// <summary>
        /// Se encarga de realizar el cálculo del monto de la tasación actualizada del terreno y no terreno, mismo que será mostrado, de forma asicrónica, 
        /// en el campo correspondiente para cada monto.
        /// </summary>
        /// <param name="montoUltimaTasacionTerreno">Monto de la última tasación del terreno ingresado por el usuario</param>
        /// <param name="montoUltimaTasacionNoTerreno">Monto de la última tasación del no terreno ingresado por el usuario</param>
        /// <param name="listaSemestresJSON">Lista de los semestres a calcular, esta se encuentra en formato JSON</param>
        /// <returns>Monto mitigador cálculado, se envía como cadena de caracteres</returns>
        [System.Web.Services.WebMethod]
        public static string CalcularMontoTasacionActualizada(string montoUltimaTasacionTerreno, string montoUltimaTasacionNoTerreno, string listaSemestresJSON, string tipoBien)
        {
            string monMitigadorCalculado = string.Empty;
            bool errorConversion = false;
            bool aplicarCalculoMTAT = false;
            bool aplicarCalculoMTANT = false;
            decimal montoUltimaTasTerreno;
            decimal montoUltimaTasNoTerreno;
            string montoTasacionActualizadaTerrenoCalculado = string.Empty;
            string montoTasacionActualizadaNoTerrenoCalculado = string.Empty;
            string listaSemestresCalculados = string.Empty;
            StringCollection parametrosExcepcion = new StringCollection();

            short codigoTipoBien;

            try
            {
                //Se conviente a "decimal" cada dato, en caso de que no se pueda implica que el cálculo no puede ser llevado a cabo.
                if (!decimal.TryParse(montoUltimaTasacionTerreno, out montoUltimaTasTerreno))
                {
                    montoTasacionActualizadaTerrenoCalculado = "0.00";
                    errorConversion = true;

                    parametrosExcepcion.Add(montoUltimaTasacionTerreno);
                    parametrosExcepcion.Add("decimal");
                    parametrosExcepcion.Add("frmGarantiasReales.aspx");

                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConvirtiendoDatoDetalle, parametrosExcepcion, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                }

                if (!decimal.TryParse(montoUltimaTasacionNoTerreno, out montoUltimaTasNoTerreno))
                {
                    montoTasacionActualizadaNoTerrenoCalculado = "0.00";
                    errorConversion = true;

                    parametrosExcepcion.Add(montoUltimaTasacionNoTerreno);
                    parametrosExcepcion.Add("decimal");
                    parametrosExcepcion.Add("frmGarantiasReales.aspx");

                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConvirtiendoDatoDetalle, parametrosExcepcion, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                }

                if (listaSemestresJSON.Length == 0)
                {
                    errorConversion = true;

                    parametrosExcepcion.Add(listaSemestresJSON);
                    parametrosExcepcion.Add("string");
                    parametrosExcepcion.Add("frmGarantiasReales.aspx");

                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConvirtiendoDatoDetalle, parametrosExcepcion, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                }

                if (!short.TryParse(tipoBien, out codigoTipoBien))
                {
                    codigoTipoBien = 0;
                    errorConversion = true;

                    parametrosExcepcion.Add(tipoBien);
                    parametrosExcepcion.Add("short");
                    parametrosExcepcion.Add("frmGarantiasReales.aspx");

                    Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorConvirtiendoDatoDetalle, parametrosExcepcion, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                }

                //Se verifica que no se haya producido ningún error al momento de convertir los valores.
                if (!errorConversion)
                {
                    //Se determina si el cálculo es aplicable, según el tipo de bien seleccionado
                    aplicarCalculoMTAT = (((codigoTipoBien == 1) || (codigoTipoBien == 2)) ? true : false);
                    aplicarCalculoMTANT = ((codigoTipoBien == 2) ? true : false);

                    //Se genera la lista de semestres, en base a la cadena JSON sumistrada
                    clsSemestres<clsSemestre> listaSemestresCalc = new clsSemestres<clsSemestre>(listaSemestresJSON, true);

                    //Se crean las variables en las que se almacenarán los montos anteriores
                    decimal montoTATAnterior = 0;
                    decimal montoTANTAnterior = 0;

                    //Se recorre la lista de semestres generada, con el fin de actualizar los montos
                    foreach (clsSemestre entidadSemestre in listaSemestresCalc)
                    {
                        if (entidadSemestre.NumeroSemestre == 1)
                        {
                            entidadSemestre.MontoUltimaTasacionTerreno = montoUltimaTasTerreno;
                            entidadSemestre.MontoUltimaTasacionNoTerreno = montoUltimaTasNoTerreno;
                        }

                        entidadSemestre.Aplicar_Calculo_Semestre(montoTATAnterior, montoTANTAnterior, aplicarCalculoMTAT, aplicarCalculoMTANT);

                        if (entidadSemestre.ErrorDatos)
                        {
                            string errorObtenido = entidadSemestre.DescripcionError + " " + entidadSemestre.ToString();
                            parametrosExcepcion.Add(entidadSemestre.OperacionCrediticia);
                            parametrosExcepcion.Add(entidadSemestre.IdentificacionGarantia);
                            parametrosExcepcion.Add(errorObtenido);

                            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANTDetalle, parametrosExcepcion, Mensajes.ASSEMBLY), EventLogEntryType.Error);


                            if ((!entidadSemestre.MontoTasacionActualizadaTerreno.HasValue) &&
                                (!entidadSemestre.MontoTasacionActualizadaNoTerreno.HasValue))
                            {
                                break;
                            }
                        }
                        else
                        {
                            if (entidadSemestre.MontoTasacionActualizadaTerreno.HasValue)
                            {
                                montoTATAnterior = ((decimal)entidadSemestre.MontoTasacionActualizadaTerreno);
                            }

                            if (entidadSemestre.MontoTasacionActualizadaNoTerreno.HasValue)
                            {
                                montoTANTAnterior = ((decimal)entidadSemestre.MontoTasacionActualizadaNoTerreno);
                            }
                        }

                        if ((entidadSemestre.NumeroSemestre == entidadSemestre.TotalRegistros)) //&& (!entidadSemestre.ErrorDatos))
                        {
                            montoTasacionActualizadaTerrenoCalculado = ((entidadSemestre.MontoTasacionActualizadaTerreno.HasValue) ? ((decimal)entidadSemestre.MontoTasacionActualizadaTerreno).ToString("N2") : string.Empty);
                            montoTasacionActualizadaNoTerrenoCalculado = ((entidadSemestre.MontoTasacionActualizadaNoTerreno.HasValue) ? ((decimal)entidadSemestre.MontoTasacionActualizadaNoTerreno).ToString("N2") : string.Empty);
                        }
                    }

                    listaSemestresCalculados = listaSemestresCalc.ObtenerJSON();
                }
                else
                {
                    throw new Exception(Mensajes.Obtener(Mensajes._errorAplicandoCalculoMontoTATTANT, Mensajes.ASSEMBLY));
                }
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCalculandoMontoMitigadorDetalle, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                monMitigadorCalculado = Mensajes.Obtener(Mensajes._errorCalculandoMontoMitigador, Mensajes.ASSEMBLY);
            }

            return (montoTasacionActualizadaTerrenoCalculado + "|" + montoTasacionActualizadaNoTerrenoCalculado + "|" + listaSemestresCalculados);
        }

        #endregion Siebel 1-24077737. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 29/11/2013.
               

        #endregion Métodos Web para consumir con AJAX
    }
}
