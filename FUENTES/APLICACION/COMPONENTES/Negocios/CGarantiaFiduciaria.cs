using System;
using System.Web;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for CGarantiaFiduciaria.
    /// </summary>
    [Serializable]
	public class CGarantiaFiduciaria
	{
		#region Variables
		//Campos llave
		private int _nTipoOperacion;
		private int _nContabilidad;
		private int _nOficina;
		private int _nMoneda;
		private int _nProducto;
		private long _nNumero;
		private int _nClaseGarantia;
		//Informacion del fiador
		private int _nTipoFiador;
		private string _strCedulaFiador;
		private string _strNombreFiador;
		//Informacion de la garantia
		private int _nTipoMitigador;
		private int _nTipoDocumento;
		private decimal _nMontoMitigador;
		private int _nInscripcion;
		private DateTime _dFechaRegistro;
		private decimal _nPorcentajeResposabilidad;
		private DateTime _dFechaConstitucion;
		private int _nTipoAcreedor;
		private string _strCedulaAcreedor;
		private int _nOperacionEspecial;
		private DateTime _dFechaExpiracion;
		private decimal _nMontoCobertura;
		private string _strTarjeta;
        private string _strObservacion;

        private string _usuarioModifico;     
        private string _nombreUsuarioModifico;
        private DateTime _fechaModifico;       
        private DateTime _fechaInserto;      
        private DateTime _fechaReplica;

        private decimal _porcentajeAceptacion;
		#endregion

		#region Propiedades
		public int TipoOperacion
		{
			get {return _nTipoOperacion;}
			set {_nTipoOperacion = value;}
		}

		public int Contabilidad
		{
			get {return _nContabilidad;}
			set {_nContabilidad = value;}
		}

		public int Oficina
		{
			get {return _nOficina;}
			set {_nOficina = value;}
		}

		public int Moneda
		{
			get {return _nMoneda;}
			set {_nMoneda = value;}
		}

		public int Producto
		{
			get {return _nProducto;}
			set {_nProducto = value;}
		}

		public long Numero
		{
			get {return _nNumero;}
			set {_nNumero = value;}
		}

		public int ClaseGarantia
		{
			get {return _nClaseGarantia;}
			set {_nClaseGarantia = value;}
		}

		public int TipoFiador
		{
			get {return _nTipoFiador;}
			set {_nTipoFiador = value;}
		}

		public string CedulaFiador
		{
			get {return _strCedulaFiador;}
			set {_strCedulaFiador = value;}
		}

		public string NombreFiador
		{
			get {return _strNombreFiador;}
			set {_strNombreFiador = value;}
		}

		public int TipoMitigador
		{
			get {return _nTipoMitigador;}
			set {_nTipoMitigador = value;}
		}

		public int TipoDocumento
		{
			get {return _nTipoDocumento;}
			set {_nTipoDocumento = value;}
		}

		public decimal MontoMitigador
		{
			get {return _nMontoMitigador;}
			set {_nMontoMitigador = value;}
		}

		public int Inscripcion
		{
			get {return _nInscripcion;}
			set {_nInscripcion = value;}
		}

		public DateTime FechaRegistro
		{
			get {return _dFechaRegistro;}
			set {_dFechaRegistro = value;}
		}

		public decimal PorcentajeResposabilidad
		{
			get {return _nPorcentajeResposabilidad;}
			set {_nPorcentajeResposabilidad = value;}
		}

		public DateTime FechaConstitucion
		{
			get {return _dFechaConstitucion;}
			set {_dFechaConstitucion = value;}
		}

		public int TipoAcreedor
		{
			get {return _nTipoAcreedor;}
			set {_nTipoAcreedor = value;}
		}

		public string CedulaAcreedor
		{
			get {return _strCedulaAcreedor;}
			set {_strCedulaAcreedor = value;}
		}

		public int OperacionEspecial
		{
			get {return _nOperacionEspecial;}
			set {_nOperacionEspecial = value;}
		}

		public DateTime FechaExpiracion
		{
			get {return _dFechaExpiracion;}
			set {_dFechaExpiracion = value;}
		}

		public decimal MontoCobertura
		{
			get {return _nMontoCobertura;}
			set {_nMontoCobertura = value;}
		}
		public string Tarjeta
		{
			get {return _strTarjeta;}
			set {_strTarjeta = value;}
		}
        public string Observacion
        {
            get { return _strObservacion; }
            set { _strObservacion = value; }
        }


        #region Campos Bitacora

        public string UsuarioModifico
        {
            get { return _usuarioModifico; }
            set { _usuarioModifico = value; }
        }

    
        public string NombreUsuarioModifico
        {
            get { return _nombreUsuarioModifico; }
            set { _nombreUsuarioModifico = value; }
        }

      
        public DateTime FechaModifico
        {
            get { return _fechaModifico; }
            set { _fechaModifico = value; }
        }

   
        public DateTime FechaInserto
        {
            get { return _fechaInserto; }
            set { _fechaInserto = value; }
        }
     
        public DateTime FechaReplica
        {
            get { return _fechaReplica; }
            set { _fechaReplica = value; }
        }

        public decimal PorcentajeAceptacion
        {
            get { return _porcentajeAceptacion; }
            set { _porcentajeAceptacion = value; }
        }

        #endregion


        #endregion

        /// <summary>
        /// Constructor de la clase
        /// </summary>
        public CGarantiaFiduciaria()
		{
			ClaseGarantia = -1;
			TipoMitigador = -1;
			OperacionEspecial = -1;
		}

		/// <summary>
		/// Metodo que retorna el objeto garantia actual en la session
		/// </summary>
		public static CGarantiaFiduciaria Current 
		{
			get 
			{ 
				//Obtiene el objeto CGarantiaFiduciaria del Session
				CGarantiaFiduciaria oCurrent = HttpContext.Current.Session["CGarantiaFiduciaria"] as CGarantiaFiduciaria;
				if (oCurrent == null) 
				{
					//si no existe crea el objeto en el session
					oCurrent = new CGarantiaFiduciaria();
					HttpContext.Current.Session["CGarantiaFiduciaria"] = oCurrent;
				}
				return oCurrent;
			}
		}
	}
}
