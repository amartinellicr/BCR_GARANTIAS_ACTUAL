using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Configuration;
using System.Timers;
using System.Net;
using System.Net.Sockets;

using BCRGARANTIAS.Negocios;
using BCRGARANTIAS.Datos;
using BCRGARANTIAS.Utilidades;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;

namespace BCR.GARANTIAS.AplicaCalcAvaluo
{
    public partial class AplicaCalcAvaluo : ServiceBase
    {
        #region Variables

        private Timer timer = null;
        private CalendarioServicio controlEjecucion;
        private string ipMaquina;

        #endregion Variables

        #region Constantes

        #endregion Constantes

        #region Constructores - Finalizadores

        public AplicaCalcAvaluo()
        {
            InitializeComponent();

            controlEjecucion = new CalendarioServicio("EsquemaEjecucion");
            controlEjecucion.Leer();

            double interval = 60 * 60 * 1000;

            string servicepollinterval = ConfigurationManager.AppSettings["BCRGARANTIAS.INTERVAL"];
            try
            {
                interval = Convert.ToDouble(servicepollinterval) * 60 * 1000;
            }
            catch (Exception)
            {
            }

            timer = new Timer(interval);

            timer.Elapsed += new ElapsedEventHandler(this.ServiceTimer_Tick);
        }

        #endregion Constructores - Finalizadores

        #region Propiedades

        /// <summary>
        /// Ruta donde se guardará el archivo que onctiene el respaldo de los registros generados por el cálculo
        /// </summary>
        private string RutaDestino
        {
            get
            {
                return ConfigurationManager.AppSettings["BCRGARANTIAS.RUTAARCHIVOS"];
            }
        }

        /// <summary>
        /// Usuario que ejecuta el servicio windows
        /// </summary>
        private string UsuarioServicios
        {
            get
            {
                return ConfigurationManager.AppSettings["BCRGARANTIAS.USUARIOSERVICIO"];
            }
        }

        /// <summary>
        /// Nombre del proceso con que se bitacorea el servicio
        /// </summary>
        private string NombreProceso
        {
            get
            {
                return ConfigurationManager.AppSettings["BCRGARANTIAS.NOMBREPROCESO"];
            }
        }

        /// <summary>
        /// Ip de la máquina desde donde se ejecuta el proceso
        /// </summary>
        public string IPMaquina
        {
            get
            {
                IPHostEntry ipEntry = Dns.GetHostEntry(Dns.GetHostName());
                IPAddress[] addr = ipEntry.AddressList;
                foreach (IPAddress ipAddress in addr)
                {
                    if (ipAddress.AddressFamily == AddressFamily.InterNetwork)
                    {
                        ipMaquina = ipAddress.ToString();
                        break;
                    }
                }

                return ipMaquina;
            }
        }
	

        #endregion Propiedades
        
        #region Métodos

        protected override void OnStart(string[] args)
        {
            timer.AutoReset = true;
            timer.Enabled = true;
            timer.Start();
        }

        protected override void OnStop()
        {
            timer.AutoReset = false;
            timer.Enabled = false;
        }

        private void ServiceTimer_Tick(object sender, System.Timers.ElapsedEventArgs e)
        {
            if (procesoEjecutadoHoy())
            {
                return;
            }

            if (!controlEjecucion.DebeCorrerHoy)
            {
                return;
            }

            if (!controlEjecucion.DebeCorrerAhora)
            {
                return;
            }

            AplicarCalculoMTANT();
        }

        private bool procesoEjecutadoHoy()
        {
            return Procesos.SeEjecutoProceso(NombreProceso, DateTime.Now);
        }

        private void controlaTimer(bool encender)
        {
            timer.Enabled = encender;
        }

        private void AplicarCalculoMTANT()
        {
            BitacoraBD bitacora = new BitacoraBD();
            bool indError;
            string mensajeError;
            bool fueEjecutado;
            bool respaldoGenerado = false;

            mensajeError = string.Empty;
            indError = false;

            controlaTimer(false);

            fueEjecutado = Procesos.SeEjecutoProceso(NombreProceso, DateTime.Now);

            //Se ejecuta el proceso automático del cálculo
            try
            {
                mensajeError = string.Empty;
                indError = false;
                mensajeError = Gestor.AplicarCalculoMTANTAvaluos(UsuarioServicios, true);

                if (mensajeError.Length > 0)
                {
                    indError = true;
                }
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;

            }

            if (!indError)
            {
                /* Se ejecutala extracción y respaldo del proceso de cálculo, se debe tener presente que también serán respaldados los registros
                   de los cálculos realizados por la aplicación el día anterior a la ejecución deeste servicio.*/
                try
                {
                    Gestor.GenerarRespaldoRegistrosCalculadosTXT(RutaDestino, true);
                    respaldoGenerado = true;
                }
                catch (Exception ex)
                {
                    indError = true;
                    mensajeError = ex.Message;
                    respaldoGenerado = false;
                }

                //Si el respaldo fue generado se elimina el contenido de la tabla temporal que los almacena
                if (respaldoGenerado)
                {
                    try
                    {
                        Gestor.EliminarSemetresCalculados();
                    }
                    catch (Exception ex)
                    {
                        indError = true;
                        mensajeError = ex.Message;
                    }
                }
            }

            bitacora.IngresaEjecucionProceso(NombreProceso,
               DateTime.Today,
               obtenerMensajeBitacora("AplicarCalculoMTANTAvaluos", indError, mensajeError), indError);

            controlaTimer(true);
        }

        private string obtenerMensajeBitacora(string procedimiento, bool error, string mensajeError)
        {
            string mensajeEjecucion;
            if (!error)
            {
                mensajeEjecucion = "Generación correcta " + procedimiento;
            }
            else
            {
                mensajeEjecucion = "Generación Erronea " + procedimiento + " " + mensajeError;
            }

            return mensajeEjecucion;
        }

        #endregion Métodos
    }
}
