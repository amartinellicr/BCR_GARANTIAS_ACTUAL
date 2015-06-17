using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Configuration;
using System.Timers;

using BCRGARANTIAS.Negocios;
using BCRGARANTIAS.Datos;
using BCRGARANTIAS.Utilidades;


namespace CargaArchivos
{
    partial class CargaArchivosService : ServiceBase
    {
        private Timer timer = null;
        private CalendarioServicio controlEjecucion;
            
        #region [ Propiedades ]
        private string rutaDestino
        {
            get
            {
                return ConfigurationManager.AppSettings["BCRGARANTIAS.RUTAARCHIVOSSUGEF"];
            }
        }

        private string usuarioServicios
        {
            get
            {
                return ConfigurationManager.AppSettings["BCRGARANTIAS.USUARIOSERVICIO"];
            }
        }

        private string nombreProceso
        {
            get
            {
                return ConfigurationManager.AppSettings["BCRGARANTIAS.NOMBREPROCESO"];
            }
        }
        #endregion


        public CargaArchivosService()
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

            cargarArchivos();
        }

        private bool procesoEjecutadoHoy()
        {
            return Procesos.SeEjecutoProceso(nombreProceso, DateTime.Now);
        }

        private void controlaTimer(bool encender)
        {
            timer.Enabled = encender;
        }

        private void cargarArchivos()
        {
            BitacoraBD bitacora = new BitacoraBD();
            bool indError;
            string mensajeError;
            bool fueEjecutado;


            mensajeError = "";
            indError = false;

            controlaTimer(false);

            fueEjecutado = Procesos.SeEjecutoProceso("GENERAARCHIVOSUGEF", DateTime.Now);
            try
            {
                mensajeError = "";
                indError = false;
				Gestor.GenerarGarantiasFiduciariasTXT(rutaDestino, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
                DateTime.Today,
                obtenerMensajeBitacora("GenerarGarantiasFiduciariasTXT", indError, mensajeError), indError);

            try
            {
                mensajeError = "";
                indError = false;
				Gestor.GenerarArchivoContratosTXT(rutaDestino, usuarioServicios, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
               DateTime.Today,
               obtenerMensajeBitacora("GenerarArchivoContratosTXT", indError, mensajeError), indError);


            try
            {
                mensajeError = "";
                indError = false;
				Gestor.GenerarArchivoGirosTXT(rutaDestino, usuarioServicios, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
               DateTime.Today,
               obtenerMensajeBitacora("GenerarArchivoGirosTXT", indError, mensajeError), indError);

            try
            {
                mensajeError = "";
                indError = false;
				Gestor.GenerarDeudoresTXT(rutaDestino, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
               DateTime.Today,
               obtenerMensajeBitacora("GenerarDeudoresTXT", indError, mensajeError), indError);


            try
            {
                mensajeError = "";
                indError = false;
				Gestor.GenerarGarantiasFiduciariasContratosTXT(rutaDestino, usuarioServicios, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
               DateTime.Today,
               obtenerMensajeBitacora("GenerarGarantiasFiduciariasContratosTXT", indError, mensajeError), indError);

            try
            {
                mensajeError = "";
                indError = false;
				Gestor.GenerarGarantiasFiduciariasInfoCompletaTXT(rutaDestino, usuarioServicios, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
               DateTime.Today,
               obtenerMensajeBitacora("GenerarGarantiasFiduciariasInfoCompletaTXT", indError, mensajeError), indError);

            try
            {
                mensajeError = "";
                indError = false;
				Gestor.GenerarGarantiasRealesContratosTXT(rutaDestino, usuarioServicios, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
               DateTime.Today,
               obtenerMensajeBitacora("GenerarGarantiasRealesContratosTXT", indError, mensajeError), indError);

            try
            {
                mensajeError = "";
                indError = false;
				Gestor.GenerarGarantiasRealesInfoCompletaTXT(rutaDestino, usuarioServicios, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
               DateTime.Today,
               obtenerMensajeBitacora("GenerarGarantiasRealesInfoCompletaTXT", indError, mensajeError), indError);

            try
            {
                mensajeError = "";
                indError = false;
                Gestor.GenerarGarantiasRealesTXT(rutaDestino, usuarioServicios, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
               DateTime.Today,
               obtenerMensajeBitacora("GenerarGarantiasRealesTXT", indError, mensajeError), indError);

            try
            {
                mensajeError = "";
                indError = false;
				Gestor.GenerarGarantiasValorContratosTXT(rutaDestino, usuarioServicios, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
               DateTime.Today,
               obtenerMensajeBitacora("GenerarGarantiasValorContratosTXT", indError, mensajeError), indError);

            try
            {
                mensajeError = "";
                indError = false;
				Gestor.GenerarGarantiasValorInfoCompletaTXT(rutaDestino, usuarioServicios, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
               DateTime.Today,
               obtenerMensajeBitacora("GenerarGarantiasValorInfoCompletaTXT", indError, mensajeError), indError);

            try
            {
                mensajeError = "";
                indError = false;
				Gestor.GenerarGarantiasValorTXT(rutaDestino, true);
            }
            catch (Exception ex)
            {
                indError = true;
                mensajeError = ex.Message;
            }

            bitacora.IngresaEjecucionProceso("GENERAARCHIVOSUGEF",
               DateTime.Today,
               obtenerMensajeBitacora("GenerarGarantiasValorTXT", indError, mensajeError), indError);

            controlaTimer(true);
        }


        private string obtenerMensajeBitacora(
               string procedimiento, bool error, string mensajeError)
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
	
    }
}
