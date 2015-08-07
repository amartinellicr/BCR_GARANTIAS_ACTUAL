using System;
using System.Resources;
using System.Reflection;

namespace BCR.GARANTIAS.Comun
{
	/// <summary>
	/// Clase utilitaria, utilizada para administrar datos de archivos de recursos.
	/// </summary>
	public class RecursosManager
	{
		#region Constantes
		private const string BACKSLASH = "\\";
		private const string SLASH = "/";
		#endregion
		/// <summary>
		/// Constructor por defecto
		/// </summary>
		private RecursosManager(){}
		
		/// <summary>
		/// Obtiene un texto a través de un archivo de recursos específico
		/// </summary>
		/// <param name="llave">Llave para buscar el texto</param>
		/// <param name="nombreAssembly">Nombre del Assembly que tiene el archivo de recursos</param>
		/// <param name="nombreClase">Nombre de la clase del archivo de recursos</param>
		/// <returns>Retorna el texto respectivo</returns>
		public static string Obtener(string llave, string nombreAssembly, string nombreClase)
		{
			string texto = string.Empty;
			ResourceManager resourceManager;
			string nombreLargoClase = string.Empty;

			try
			{
				if (nombreAssembly == null)
				{
					nombreLargoClase = Assembly.GetExecutingAssembly().GetName().Name +  "." + nombreClase;
					resourceManager = new ResourceManager (nombreLargoClase, Assembly.GetExecutingAssembly());
					texto = resourceManager.GetString(llave);

                    UtilitariosComun.RegistraEventLog("Error encontrando llave (1), nombre largo clase: " + nombreLargoClase, System.Diagnostics.EventLogEntryType.Error);

				}
				else
				{
					Assembly assembly = Assembly.GetExecutingAssembly();
					string rutaLibreria = assembly.CodeBase;
					rutaLibreria = rutaLibreria.Substring(8, rutaLibreria.Length-8);
					rutaLibreria = rutaLibreria.Replace(SLASH, BACKSLASH);
					rutaLibreria = rutaLibreria.Substring(0, rutaLibreria.LastIndexOf(BACKSLASH));
					rutaLibreria = rutaLibreria + BACKSLASH + nombreAssembly;

					assembly = Assembly.LoadFile(rutaLibreria);
					nombreLargoClase = assembly.GetName().Name + "." + nombreClase;
					resourceManager = new ResourceManager (nombreLargoClase, assembly);
					texto = resourceManager.GetString(llave);

					if (texto == null)
					{
						nombreLargoClase = Assembly.GetExecutingAssembly().GetName().Name +  "." + nombreClase;
						resourceManager = new ResourceManager (nombreLargoClase, Assembly.GetExecutingAssembly());
						texto = resourceManager.GetString(llave);

                        UtilitariosComun.RegistraEventLog("Error encontrando llave (2), nombre largo clase: " + nombreLargoClase, System.Diagnostics.EventLogEntryType.Error);
					}
				}				
				if (texto == null)
				{
					nombreLargoClase = Assembly.GetEntryAssembly().GetName().Name +  "." + nombreClase;
					resourceManager = new ResourceManager (nombreLargoClase, Assembly.GetEntryAssembly());

                    UtilitariosComun.RegistraEventLog("Error encontrando llave (3), nombre largo clase: " + nombreLargoClase, System.Diagnostics.EventLogEntryType.Error);
				}
				return texto;
			}
			catch (Exception e)
			{
                UtilitariosComun.RegistraEventLog("Error encontrando llave (4), nombre largo clase: " + nombreLargoClase, System.Diagnostics.EventLogEntryType.Error);

				throw new ExcepcionBase(Mensajes.ERROR_ACCESANDO_RECURSOS, e);
			}
		}

		/// <summary>
		/// Obtiene un texto a través de un archivo de recursos específico
		/// </summary>
		/// <param name="llave">Llave para buscar el texto</param>
		/// <param name="nombreClase">Nombre de la clase del archivo de recursos</param>
		/// <returns>Retorna el texto respectivo</returns>
		public static string Obtener(string llave, string nombreClase)
		{
			return Obtener(llave, null, nombreClase);
		}

        public static string Obtener(string llave, ResourceManager resourceManager)
        {
            return resourceManager.GetString(llave);
        }
	}
}