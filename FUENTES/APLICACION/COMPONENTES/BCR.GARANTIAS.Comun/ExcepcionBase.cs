using System;
using System.Runtime.Serialization;

namespace BCR.GARANTIAS.Comun
{
	/// <summary>
	/// Excepci�n base utilizada para las excepciones controladas del sistema,
	/// y de la cual va a heredar cualquier excepci�n personalizada
	/// Creado por Rodrigo Zumbado Moreira 2005
	/// </summary>
	[Serializable]
	public class ExcepcionBase:ApplicationException
	{
		#region Constructores
		/// <summary>
		/// Constructor por defecto, implemente lo que existe en ApplicationException
		/// </summary>
		public ExcepcionBase():base() {}
		/// <summary>
		/// Constructor sobrecargado que implementa lo que hay en el padre
		/// </summary>
		/// <param name="mensaje">Mensaje de la excepci�n</param>
		public ExcepcionBase(string mensaje):base(mensaje)
		{
		}

		/// <summary>
		/// Constructor sobrecargado que implementa lo que hay en el padre
		/// </summary>
		/// <param name="mensaje">Mensaje de la excepci�n</param>
		/// <param name="innerException">Excepci�n interna</param>
		public ExcepcionBase (string mensaje, Exception innerException):base(mensaje, innerException)
		{
		}

		/// <summary>
		/// Constructor que implementa la forma de serializar de la clase,
		/// tal y como lo hace el padre de la misma, este m�todo es
		/// escencial para la trasmisi�n de una excepci�n serializable
		/// y por lo tanto para que pueda ser transmitida remotamente.
		/// </summary>
		/// <param name="info">Contiene la informaci�n del objeto serializado</param>
		/// <param name="context">Contiene informaci�n contextual sobre el origen o el destino</param>
		public ExcepcionBase(SerializationInfo info, StreamingContext context):base(info, context)
		{
		}
		#endregion

		#region M�todos

		/// <summary>
		/// Configura la System.Runtime.Serialization.SerializationInfo con
		/// informaci�n sobre la excepci�n, este m�todo es
		/// escencial para la trasmisi�n de una excepci�n serializable
		/// y por lo tanto para que pueda ser transmitida remotamente.
		/// </summary>
		/// <param name="info">Contiene la informaci�n del objeto serializado</param>
		/// <param name="context">Contiene informaci�n contextual sobre el origen o el destino</param>
		public override void GetObjectData(SerializationInfo info, StreamingContext context)
		{
			base.GetObjectData (info, context);
		}

		#endregion
	}
}