using System;
using System.Web;
using System.Collections;
using System.Runtime.Serialization;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for CGarantiaValor.
	/// </summary>
	[Serializable]
	public class CGarantiaValor
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
		private string _strNumeroSeguridad;
		//Informacion del deudor
		private int _nTipoDeudor;
		private string _strCedulaDeudor;
		private string _strNombreDeudor;
		private int _nCondicionEspecial;
		//Informacion de la garantia
		private int _nTipoMitigador;
		private int _nTipoDocumento;
		private decimal _nMontoMitigador;
		private int _nInscripcion;
		private DateTime _dFechaRegistro;
		private decimal _nPorcentajeResposabilidad;
		private DateTime _dFechaConstitucion;
		private int _nGradoGravamen;
		private int _nTipoAcreedor;
		private string _strCedulaAcreedor;
		private int _nGradoPrioridades;
		private decimal _nMontoPrioridades;
		private DateTime _dFechaVencimiento;
		private int _nOperacionEspecial;
		//Informacion adicional de la garantia
		private int _nClasificacion;
		private string _strInstrumento;
		private string _strSerie;
		private int _nTipoEmisor;
		private string _strCedulaEmisor;
		private decimal _nPremio;
		private string _strISIN;
		private decimal _nValorFacial;
		private int _nMonedaValorFacial;
		private decimal _nValorMercado;
		private int _nMonedaValorMercado;
		private int _nTenencia;
		private DateTime _dFechaPrescripcion;

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

		public string Seguridad
		{
			get {return _strNumeroSeguridad;}
			set {_strNumeroSeguridad = value;}
		}

		public int TipoDeudor
		{
			get {return _nTipoDeudor;}
			set {_nTipoDeudor = value;}
		}

		public string CedulaDeudor
		{
			get {return _strCedulaDeudor;}
			set {_strCedulaDeudor = value;}
		}

		public string NombreDeudor
		{
			get {return _strNombreDeudor;}
			set {_strNombreDeudor = value;}
		}

		public int CondicionEspecial
		{
			get {return _nCondicionEspecial;}
			set {_nCondicionEspecial = value;}
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

		public int GradoGravamen
		{
			get {return _nGradoGravamen;}
			set {_nGradoGravamen = value;}
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

		public int GradoPrioridades
		{
			get {return _nGradoPrioridades;}
			set {_nGradoPrioridades = value;}
		}

		public decimal MontoPrioridades
		{
			get {return _nMontoPrioridades;}
			set {_nMontoPrioridades = value;}
		}

		public DateTime FechaVencimiento
		{
			get {return _dFechaVencimiento;}
			set {_dFechaVencimiento = value;}
		}

		public int OperacionEspecial
		{
			get {return _nOperacionEspecial;}
			set {_nOperacionEspecial = value;}
		}

		public int Clasificacion
		{
			get {return _nClasificacion;}
			set {_nClasificacion = value;}
		}

		public string Instrumento
		{
			get {return _strInstrumento;}
			set {_strInstrumento = value;}
		}

		public string Serie
		{
			get {return _strSerie;}
			set {_strSerie = value;}
		}

		public int TipoEmisor
		{
			get {return _nTipoEmisor;}
			set {_nTipoEmisor = value;}
		}

		public string CedulaEmisor
		{
			get {return _strCedulaEmisor;}
			set {_strCedulaEmisor = value;}
		}

		public decimal Premio
		{
			get {return _nPremio;}
			set {_nPremio = value;}
		}

		public string ISIN
		{
			get {return _strISIN;}
			set {_strISIN = value;}
		}

		public decimal ValorFacial
		{
			get {return _nValorFacial;}
			set {_nValorFacial = value;}
		}

		public int MonedaValorFacial
		{
			get {return _nMonedaValorFacial;}
			set {_nMonedaValorFacial = value;}
		}

		public decimal ValorMercado
		{
			get {return _nValorMercado;}
			set {_nValorMercado = value;}
		}

		public int MonedaValorMercado
		{
			get {return _nMonedaValorMercado;}
			set {_nMonedaValorMercado = value;}
		}

		public int Tenencia
		{
			get {return _nTenencia;}
			set {_nTenencia = value;}
		}

		public DateTime FechaPrescripcion
		{
			get {return _dFechaPrescripcion;}
			set {_dFechaPrescripcion = value;}
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
        public CGarantiaValor()
		{
			ClaseGarantia = -1;
			TipoMitigador = -1;
			TipoDocumento = -1;
		}

		/// <summary>
		/// Metodo que retorna el objeto garantia actual en la session
		/// </summary>
		public static CGarantiaValor Current 
		{
			get 
			{ 
				//Obtiene el objeto CGarantiaFiduciaria del Session
				CGarantiaValor oCurrent = HttpContext.Current.Session["CGarantiaValor"] as CGarantiaValor;
				if (oCurrent == null) 
				{
					//si no existe crea el objeto en el session
					oCurrent = new CGarantiaValor();
					HttpContext.Current.Session["CGarantiaValor"] = oCurrent;
				}
				return oCurrent;
			}
		}
	}
}
