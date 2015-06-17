using System;
using System.Runtime.Serialization;

namespace BCR.GARANTIAS.Comun
{
	/// <summary>
	/// Excepción base utilizada para las excepciones controladas del sistema,
	/// y de la cual va a heredar cualquier excepción personalizada
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
		/// <param name="mensaje">Mensaje de la excepción</param>
		public ExcepcionBase(string mensaje):base(mensaje)
		{
		}

		/// <summary>
		/// Constructor sobrecargado que implementa lo que hay en el padre
		/// </summary>
		/// <param name="mensaje">Mensaje de la excepción</param>
		/// <param name="innerException">Excepción interna</param>
		public ExcepcionBase (string mensaje, Exception innerException):base(mensaje, innerException)
		{
		}

		/// <summary>
		/// Constructor que implementa la forma de serializar de la clase,
		/// tal y como lo hace el padre de la misma, este método es
		/// escencial para la trasmisión de una excepción serializable
		/// y por lo tanto para que pueda ser transmitida remotamente.
		/// </summary>
		/// <param name="info">Contiene la información del objeto serializado</param>
		/// <param name="context">Contiene información contextual sobre el origen o el destino</param>
		public ExcepcionBase(SerializationInfo info, StreamingContext context):base(info, context)
		{
		}
		#endregion

		#region Métodos

		/// <summary>
		/// Configura la System.Runtime.Serialization.SerializationInfo con
		/// información sobre la excepción, este método es
		/// escencial para la trasmisión de una excepción serializable
		/// y por lo tanto para que pueda ser transmitida remotamente.
		/// </summary>
		/// <param name="info">Contiene la información del objeto serializado</param>
		/// <param name="context">Contiene información contextual sobre el origen o el destino</param>
		public override void GetObjectData(SerializationInfo info, StreamingContext context)
		{
			base.GetObjectData (info, context);
		}

		#endregion
	}
}