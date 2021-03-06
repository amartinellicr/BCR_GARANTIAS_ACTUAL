using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Security.Permissions;
using System.IO;

using BCR.GARANTIAS.Comun;


/// <summary>
/// Summary description for Global
/// </summary>
public class Global : System.Web.HttpApplication 
{
    public Global()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static string UsuarioSistema
    {
        get
        {
            object o = HttpContext.Current.Session["strUSER"];
            //Si la session caduc� volver a solicitar credenciales
            if (o == null)
                HttpContext.Current.Response.Redirect("frmAccesoDenegado.aspx", true);

            return o.ToString();
        }
        set
        {
            HttpContext.Current.Session["strUSER"] = value;
        }
    }

    void Application_Start(object sender, EventArgs e)
    {
        Application.Lock();
        
        if (Application["Users"] != null)
            Application["Users"] = int.Parse(Application["Users"].ToString()) + 1;
        else
            Application["Users"] = 1;

        Application.UnLock();

        try
        {
            //Conexi�n a la BD
            Application["SERVIDOR"] = ConfigurationManager.AppSettings.Get("SERVIDOR");
            Application["BASE_DATOS"] = ConfigurationManager.AppSettings.Get("BASE_DATOS");
            Application["USUARIO"] = ConfigurationManager.AppSettings.Get("USUARIO");
            Application["PASSWORD"] = ConfigurationManager.AppSettings.Get("PASSWORD");

            //Roles de Seguridad
            Application["MNU_INICIO"] = ConfigurationManager.AppSettings.Get("MNU_INICIO");
            Application["MNU_PERFILES"] = ConfigurationManager.AppSettings.Get("MNU_PERFILES");
            Application["MNU_ROLES_X_PERFIL"] = ConfigurationManager.AppSettings.Get("MNU_ROLES_X_PERFIL");
            Application["MNU_USUARIO"] = ConfigurationManager.AppSettings.Get("MNU_USUARIO");
            Application["MNU_CATALOGOS"] = ConfigurationManager.AppSettings.Get("MNU_CATALOGOS");
            Application["MNU_MANT_CATALOGOS"] = ConfigurationManager.AppSettings.Get("MNU_MANT_CATALOGOS");
            Application["MNU_MANT_DEUDORES"] = ConfigurationManager.AppSettings.Get("MNU_MANT_DEUDORES");
            Application["MNU_SEL_GARANTIAS"] = ConfigurationManager.AppSettings.Get("MNU_SEL_GARANTIAS");
            Application["MNU_EMPRESA"] = ConfigurationManager.AppSettings.Get("MNU_EMPRESA");
            Application["MNU_GARANTIA_FIDUCIARIA"] = ConfigurationManager.AppSettings.Get("MNU_GARANTIA_FIDUCIARIA");
            Application["MNU_CALIFICACIONES"] = ConfigurationManager.AppSettings.Get("MNU_CALIFICACIONES");
            Application["MNU_CAPACIDAD_PAGO"] = ConfigurationManager.AppSettings.Get("MNU_CAPACIDAD_PAGO");
            Application["MNU_VALUACION_FIADOR"] = ConfigurationManager.AppSettings.Get("MNU_VALUACION_FIADOR");
            Application["MNU_GARANTIA_REAL"] = ConfigurationManager.AppSettings.Get("MNU_GARANTIA_REAL");
            Application["MNU_VALUACION_REAL"] = ConfigurationManager.AppSettings.Get("MNU_VALUACION_REAL");
            Application["MNU_GARANTIA_VALOR"] = ConfigurationManager.AppSettings.Get("MNU_GARANTIA_VALOR");
            Application["MNU_GARANTIA_GIRO"] = ConfigurationManager.AppSettings.Get("MNU_GARANTIA_GIRO");
            Application["MNU_ARCHIVOS_SEGUI"] = ConfigurationManager.AppSettings.Get("MNU_ARCHIVOS_SEGUI");
            Application["MNU_REPORTE_AVANCE_OFICINA"] = ConfigurationManager.AppSettings.Get("MNU_REPORTE_AVANCE_OFICINA");
            Application["MNU_REPORTE_IND_OPERACION"] = ConfigurationManager.AppSettings.Get("MNU_REPORTE_IND_OPERACION");
            Application["MNU_REPORTE_SUMATORIA_MONTOS_OPERACION"] = ConfigurationManager.AppSettings.Get("MNU_REPORTE_SUMATORIA_MONTOS_OPERACION");
            Application["MNU_REPORTE_TRANSACCIONES_BITACORA"] = ConfigurationManager.AppSettings.Get("MNU_REPORTE_TRANSACCIONES_BITACORA");
            Application["MNU_GARANTIAS_X_OPERACION"] = ConfigurationManager.AppSettings.Get("MNU_GARANTIAS_X_OPERACION");
            Application["MNU_MANT_BIN_TARJETA"] = ConfigurationManager.AppSettings.Get("MNU_MANT_BIN_TARJETA");
            Application["MNU_GARANTIA_X_PERFIL"] = ConfigurationManager.AppSettings.Get("MNU_GARANTIA_X_PERFIL");
            Application["MNU_GENERAR_ARCHIVO_INCONSISTENCIAS"] = ConfigurationManager.AppSettings.Get("MNU_GENERAR_ARCHIVO_INCONSISTENCIAS");
            Application["MNU_GENERAR_ARCHIVO_ALERTAS"] = ConfigurationManager.AppSettings.Get("MNU_GENERAR_ARCHIVO_ALERTAS");
            Application["MNU_MANT_INDICES_ACT_AVALUOS"] = ConfigurationManager.AppSettings.Get("MNU_MANT_INDICES_ACT_AVALUOS");
            Application["MNU_CONSULTA_HST_INDICES_ACT_AVALUOS"] = ConfigurationManager.AppSettings.Get("MNU_CONSULTA_HST_INDICES_ACT_AVALUOS");
            Application["MNU_CONSULTA_HST_AVALUOS"] = ConfigurationManager.AppSettings.Get("MNU_CONSULTA_HST_AVALUOS");
            Application["MNU_CONSULTA_CAMBIOS_GARANTIAS"] = ConfigurationManager.AppSettings.Get("MNU_CONSULTA_CAMBIOS_GARANTIAS");
            Application["MNU_REPORTE_EJECUCION_PROCESOS"] = ConfigurationManager.AppSettings.Get("MNU_REPORTE_EJECUCION_PROCESOS");
            Application["MNU_HISTORICO_PORCENTAJE_ACEPTACION"] = ConfigurationManager.AppSettings.Get("MNU_HISTORICO_PORCENTAJE_ACEPTACION");
            Application["MNU_SALDOS_TOTALES_PORCENTAJE_RESPONSABILIDAD"] = ConfigurationManager.AppSettings.Get("MNU_SALDOS_TOTALES_PORCENTAJE_RESPONSABILIDAD");

            //Cat�logos
            Application["CAT_TIPO_PERSONA"] = ConfigurationManager.AppSettings.Get("CAT_TIPO_PERSONA");
            Application["CAT_TIPO_GARANTIA"] = ConfigurationManager.AppSettings.Get("CAT_TIPO_GARANTIA");
            Application["CAT_CONDICION_ESPECIAL"] = ConfigurationManager.AppSettings.Get("CAT_CONDICION_ESPECIAL");
            Application["CAT_CODIGO_EMPRESA"] = ConfigurationManager.AppSettings.Get("CAT_CODIGO_EMPRESA");
            Application["CAT_TIPO_EMPRESA"] = ConfigurationManager.AppSettings.Get("CAT_TIPO_EMPRESA");
            Application["CAT_CLASE_GARANTIA"] = ConfigurationManager.AppSettings.Get("CAT_CLASE_GARANTIA");
            Application["CAT_TIPOS_DOCUMENTOS"] = ConfigurationManager.AppSettings.Get("CAT_TIPOS_DOCUMENTOS");
            Application["CAT_INSCRIPCION"] = ConfigurationManager.AppSettings.Get("CAT_INSCRIPCION");
            Application["CAT_GRADO_GRAVAMEN"] = ConfigurationManager.AppSettings.Get("CAT_GRADO_GRAVAMEN");
            Application["CAT_OPERACION_ESPECIAL"] = ConfigurationManager.AppSettings.Get("CAT_OPERACION_ESPECIAL");
            Application["CAT_TIPO_BIEN"] = ConfigurationManager.AppSettings.Get("CAT_TIPO_BIEN");
            Application["CAT_LIQUIDEZ"] = ConfigurationManager.AppSettings.Get("CAT_LIQUIDEZ");
            Application["CAT_TENENCIA"] = ConfigurationManager.AppSettings.Get("CAT_TENENCIA");
            Application["CAT_MONEDA"] = ConfigurationManager.AppSettings.Get("CAT_MONEDA");
            Application["CAT_RECOMENDACION_PERITO"] = ConfigurationManager.AppSettings.Get("CAT_RECOMENDACION_PERITO");
            Application["CAT_INSPECCION_3_MESES"] = ConfigurationManager.AppSettings.Get("CAT_INSPECCION_3_MESES");
            Application["CAT_CLASIFICACION_INSTRUMENTO"] = ConfigurationManager.AppSettings.Get("CAT_CLASIFICACION_INSTRUMENTO");
            Application["CAT_TIPO_ASIGNACION"] = ConfigurationManager.AppSettings.Get("CAT_TIPO_ASIGNACION");
            Application["CAT_TIPO_CAPACIDAD_PAGO"] = ConfigurationManager.AppSettings.Get("CAT_TIPO_CAPACIDAD_PAGO");
            Application["CAT_TIPO_GENERADOR"] = ConfigurationManager.AppSettings.Get("CAT_TIPO_GENERADOR");
            Application["CAT_VINCULADO_ENTIDAD"] = ConfigurationManager.AppSettings.Get("CAT_VINCULADO_ENTIDAD");
            Application["CAT_TIPO_MITIGADOR"] = ConfigurationManager.AppSettings.Get("CAT_TIPO_MITIGADOR");
            Application["CAT_TIPO_GARANTIA_REAL"] = ConfigurationManager.AppSettings.Get("CAT_TIPO_GARANTIA_REAL");
            Application["CAT_TIENE_CAPACIDAD"] = ConfigurationManager.AppSettings.Get("CAT_TIENE_CAPACIDAD");
            Application["CAT_PARAMETROS_CALCULO_MTAT_MTANT"] = ConfigurationManager.AppSettings.Get("CAT_PARAMETROS_CALCULO_MTAT_MTANT");
            Application["CAT_TIPOS_POLIZAS_SAP"] = ConfigurationManager.AppSettings.Get("CAT_TIPOS_POLIZAS_SAP");
            Application["CAT_TIPOS_POLIZAS_BIENES_RELACIONADOS"] = ConfigurationManager.AppSettings.Get("CAT_TIPOS_POLIZAS_BIENES_RELACIONADOS");
            Application["CAT_TIPOS_POLIZAS_SUGEF"] = ConfigurationManager.AppSettings.Get("CAT_TIPOS_POLIZAS_SUGEF");
            Application["CAT_PORCENTAJE_ACEPTACION"] = ConfigurationManager.AppSettings.Get("CAT_PORCENTAJE_ACEPTACION");


            //Tipos de Garantia
            Application["GARANTIA_FIDUCIARIA"] = ConfigurationManager.AppSettings.Get("GARANTIA_FIDUCIARIA");
            Application["GARANTIA_REAL"] = ConfigurationManager.AppSettings.Get("GARANTIA_REAL");
            Application["GARANTIA_VALOR"] = ConfigurationManager.AppSettings.Get("GARANTIA_VALOR");

            //Constantes
            Application["PRODUCTO_CONTRATO"] = ConfigurationManager.AppSettings.Get("PRODUCTO_CONTRATO");
            Application["OPERACION_CREDITICIA"] = ConfigurationManager.AppSettings.Get("OPERACION_CREDITICIA");
            Application["CONTRATO"] = ConfigurationManager.AppSettings.Get("CONTRATO");
            Application["TARJETA"] = ConfigurationManager.AppSettings.Get("TARJETA");

            //Tipos de garant�as reales
            Application["REAL_HIPOTECARIA"] = ConfigurationManager.AppSettings.Get("REAL_HIPOTECARIA");
            Application["REAL_PRENDARIA"] = ConfigurationManager.AppSettings.Get("REAL_PRENDARIA");

            //Tipos de hipotecas
            Application["HIPOTECAS"] = ConfigurationManager.AppSettings.Get("HIPOTECAS");
            Application["CEDULAS_HIPOTECARIAS"] = ConfigurationManager.AppSettings.Get("CEDULAS_HIPOTECARIAS");
            Application["PRENDAS"] = ConfigurationManager.AppSettings.Get("PRENDAS");

            //Clases de Garantia
            Application["CLASE_GARANTIA_FIADOR"] = ConfigurationManager.AppSettings.Get("CLASE_GARANTIA_FIADOR");

            //Rutas de Destino Archivos
            Application["ARCHIVOS"] = ConfigurationManager.AppSettings.Get("ARCHIVOS");
            Application["DOWNLOAD"] = ConfigurationManager.AppSettings.Get("DOWNLOAD");

            //Eventos del MQ
            Application["REFERENCIA"] = ConfigurationManager.AppSettings.Get("REFERENCIA");
            Application["CANAL"] = ConfigurationManager.AppSettings.Get("CANAL");
            Application["TRANS"] = ConfigurationManager.AppSettings.Get("TRANS");
            Application["ACCION"] = ConfigurationManager.AppSettings.Get("ACCION");
            Application["USUARIO"] = ConfigurationManager.AppSettings.Get("USUARIO");
            Application["OFICINAORIGEN"] = ConfigurationManager.AppSettings.Get("OFICINAORIGEN");
            Application["ESTACION"] = ConfigurationManager.AppSettings.Get("ESTACION");
            Application["FECHAHORA"] = ConfigurationManager.AppSettings.Get("FECHAHORA");

            //Constantes
            Application["DEFAULT_OPERACION_ESPECIAL"] = ConfigurationManager.AppSettings.Get("DEFAULT_OPERACION_ESPECIAL");
            Application["DEFAULT_VINCULADO_ENTIDAD"] = ConfigurationManager.AppSettings.Get("DEFAULT_VINCULADO_ENTIDAD");
            Application["DEFAULT_TIPO_ACREEDOR"] = ConfigurationManager.AppSettings.Get("DEFAULT_TIPO_ACREEDOR");
            Application["DEFAULT_INSCRIPCION"] = ConfigurationManager.AppSettings.Get("DEFAULT_INSCRIPCION");
            Application["DEFAULT_GRADO_PRIORIDAD"] = ConfigurationManager.AppSettings.Get("DEFAULT_GRADO_PRIORIDAD");
            Application["DEFAULT_TIPO_DOCUMENTO_LEGAL_FIADORES"] = ConfigurationManager.AppSettings.Get("DEFAULT_TIPO_DOCUMENTO_LEGAL_FIADORES");

            //Time-Out
            Application["TIME_OUT"] = ConfigurationManager.AppSettings.Get("TIME_OUT");

            //Configuraci�n MQ
            Application["Cola_Respuesta"] = ConfigurationManager.AppSettings.Get("Cola_Respuesta");
            Application["Cola_Entrada"] = ConfigurationManager.AppSettings.Get("Cola_Entrada");
            Application["Cola_Salida"] = ConfigurationManager.AppSettings.Get("Cola_Salida");
            Application["Qmanager"] = ConfigurationManager.AppSettings.Get("Qmanager");
            Application["Channel"] = ConfigurationManager.AppSettings.Get("Channel");
            Application["Port"] = ConfigurationManager.AppSettings.Get("Port");
            Application["IP"] = ConfigurationManager.AppSettings.Get("IP");

            Application["TIPO_MOVIMIENTO"] = ConfigurationManager.AppSettings.Get("TIPO_MOVIMIENTO");

            //Informaci�n General
            Application["AMBIENTE"] = ConfigurationManager.AppSettings.Get("AMBIENTE");

            //DFS para archivos de inconsistencias
            Application["BCRGARANTIAS.RUTA.ARCHIVOS.INCONSISTENCIAS.Y.ALERTAS"] = ConfigurationManager.AppSettings.Get("BCRGARANTIAS.RUTA.ARCHIVOS.INCONSISTENCIAS.Y.ALERTAS");
            Application["BCRGARANTIAS.USUARIODFS"] = ConfigurationManager.AppSettings.Get("BCRGARANTIAS.USUARIODFS");
            Application["BCRGARANTIAS.CLAVEUSUARIODFS"] = ConfigurationManager.AppSettings.Get("BCRGARANTIAS.CLAVEUSUARIODFS");
            Application["DOMINIO_DEFAULT"] = ConfigurationManager.AppSettings.Get("DOMINIO_DEFAULT");

            //A�OS USADOS PARA EL CALCULO DE LA FECHA DE PRESCRIPCION DE GARANTIAS REALES
            Application["ANNOS_FECHA_PRESCRIPCION_HIPOTECA"] = ConfigurationManager.AppSettings.Get("ANNOS_FECHA_PRESCRIPCION_HIPOTECA");
            Application["ANNOS_FECHA_PRESCRIPCION_CEDULA_HIPOTECARIA"] = ConfigurationManager.AppSettings.Get("ANNOS_FECHA_PRESCRIPCION_CEDULA_HIPOTECARIA");
            Application["ANNOS_FECHA_PRESCRIPCION_PRENDA"] = ConfigurationManager.AppSettings.Get("ANNOS_FECHA_PRESCRIPCION_PRENDA");

            Application["PERFILES_PERMISO_EDICION_STPR"] = ConfigurationManager.AppSettings.Get("PERFILES_PERMISO_EDICION_STPR");
            
        }
        catch (ConfigurationErrorsException ex)
        {
            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_ARCHIVO_CONFIGURACION_DETALLE, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);

            throw ex;
        }
        catch (Exception ex)
        {
            string strRutaActual = HttpContext.Current.Request.Path.Substring(0, HttpContext.Current.Request.Path.LastIndexOf("/"));
            strRutaActual = strRutaActual.Remove(strRutaActual.IndexOf("/App_Code"));

            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_ARCHIVO_CONFIGURACION_DETALLE, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);

            Response.Redirect(strRutaActual + "/frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Cargando P�gina" +
                                        "&strMensaje=Inicializando la aplicaci�n" +
                                        "&bBotonVisible=0", true);
        }
        string strRutaDestino = Application["ARCHIVOS"].ToString();

        if (Directory.Exists(strRutaDestino))
        {
            FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRutaDestino);

            Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, strRutaDestino);

            DirectoryInfo di = new DirectoryInfo(strRutaDestino);

            FileInfo[] rgFiles = di.GetFiles("*.*");
            foreach (FileInfo fi in rgFiles)
            {
                Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, fi.FullName);
            }
        }
    }

    void Application_End(object sender, EventArgs e)
    {
        Application.Lock();
        Application["Users"] = int.Parse(Application["Users"].ToString()) - 1;
        Application.UnLock();

    }

    void Application_Error(object sender, EventArgs e)
    {
        // Code that runs when an unhandled error occurs

    }

    void Session_Start(object sender, EventArgs e)
    {
        Application.Lock();

        if (Application["SessionCounter"] != null)
            Application["SessionCounter"] = int.Parse(Application["SessionCounter"].ToString()) + 1;
        else
            Application["SessionCounter"] = 1;

        Application.UnLock();

        //Este c�digo hace que se genere el SessionID y se supone sea persistente en toda la aplicaci�n
        if (this.Session["SesionCreada"] == null)
        {
            this.Session["SesionCreada"] = 1;
        }
    }

    void Session_End(object sender, EventArgs e)
    {
        // Code that runs when a session ends. 
        // Note: The Session_End event is raised only when the sessionstate mode
        // is set to InProc in the Web.config file. If session mode is set to StateServer 
        // or SQLServer, the event is not raised.

        Application.Lock();
        Application["SessionCounter"] = int.Parse(Application["SessionCounter"].ToString()) - 1;
        Application.UnLock();

        
        
    }
    protected void Application_BeginRequest(Object sender, EventArgs e)
    {
        InicializarCultura();
    }

    private void InicializarCultura()
    {
        //Inicializar configuracion de cultura
        System.Globalization.CultureInfo cultura = new System.Globalization.CultureInfo("es-CR");
        //Establece los formatos de numeros y montos
        System.Globalization.NumberFormatInfo numeros = cultura.NumberFormat;

        numeros.NumberDecimalSeparator = ".";
        numeros.NumberGroupSeparator = ",";
        numeros.NumberDecimalDigits = 2;

        numeros.CurrencyDecimalSeparator = ".";
        numeros.CurrencyGroupSeparator = ",";
        numeros.CurrencyDecimalDigits = 2;

        numeros.PercentDecimalSeparator = ".";
        numeros.PercentGroupSeparator = ",";
        numeros.PercentDecimalDigits = 2;
        numeros.PercentSymbol = "%";

        //Establece los formatos de fechas y horas
        System.Globalization.DateTimeFormatInfo fechas = cultura.DateTimeFormat;

        fechas.AMDesignator = "AM";
        fechas.PMDesignator = "PM";
        fechas.FullDateTimePattern = "dddd, dd MMMM yyyy hh:mm:ss tt";

        System.Threading.Thread.CurrentThread.CurrentCulture = cultura;
        System.Threading.Thread.CurrentThread.CurrentUICulture = cultura;
      
    }
}
