using System;
using System.Web;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for CGarantiaReal.
    /// </summary>
    [Serializable]
	public class CGarantiaReal
	{
		#region Variables
		//Campos llave
		private int _nTipoOperacion;
		private int _nContabilidad;
		private int _nOficina;
		private int _nMoneda;
		private int _nProducto;
		private long _nNumero;
		private int _nTipoGarantiaReal;
		private int _nClaseGarantia;
		private int _nPartido;
		private long _nNumeroFinca;
		private int _nGrado;
		private int _nCedulaFiduciaria;
		private string _strClaseBien;
		private string _strNumPlaca;
		private int _nTipoBien;
		//Informacion de la garantia
		private int _nTipoMitigador;
		private int _nTipoDocumento;
		private decimal _nMontoMitigador;
		private int _nInscripcion;
		private DateTime _dFechaPresentacion;
		private decimal _nPorcentajeResposabilidad;
		private DateTime _dFechaConstitucion;
		private int _nGradoGravamen;
		private int _nTipoAcreedor;
		private string _strCedulaAcreedor;
		private DateTime _dFechaVencimiento;
		private int _nOperacionEspecial;
		private int _nLiquidez;
		private int _nTenencia;
		private int _nMonedaValor;
		private DateTime _dFechaPrescripcion;
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

		public int TipoGarantiaReal
		{
			get {return _nTipoGarantiaReal;}
			set {_nTipoGarantiaReal = value;}
		}

		public int ClaseGarantia
		{
			get {return _nClaseGarantia;}
			set {_nClaseGarantia = value;}
		}

		public int Partido
		{
			get {return _nPartido;}
			set {_nPartido = value;}
		}

		public long Finca
		{
			get {return _nNumeroFinca;}
			set {_nNumeroFinca = value;}
		}

		public int Grado
		{
			get {return _nGrado;}
			set {_nGrado = value;}
		}

		public int CedulaFiduciaria
		{
			get {return _nCedulaFiduciaria;}
			set {_nCedulaFiduciaria = value;}
		}

		public string ClaseBien
		{
			get {return _strClaseBien;}
			set {_strClaseBien = value;}
		}

		public string NumPlaca
		{
			get {return _strNumPlaca;}
			set {_strNumPlaca = value;}
		}

		public int TipoBien
		{
			get {return _nTipoBien;}
			set {_nTipoBien = value;}
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

		public DateTime FechaPresentacion
		{
			get {return _dFechaPresentacion;}
			set {_dFechaPresentacion = value;}
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

		public DateTime FechaVencimientoInstrumento
		{
			get {return _dFechaVencimiento;}
			set {_dFechaVencimiento = value;}
		}

		public int OperacionEspecial
		{
			get {return _nOperacionEspecial;}
			set {_nOperacionEspecial = value;}
		}

		public int Liquidez
		{
			get {return _nLiquidez;}
			set {_nLiquidez = value;}
		}

		public int Tenencia
		{
			get {return _nTenencia;}
			set {_nTenencia = value;}
		}

		public int MonedaValor
		{
			get {return _nMonedaValor;}
			set {_nMonedaValor = value;}
		}

		public DateTime FechaPrescripcion
		{
			get {return _dFechaPrescripcion;}
			set {_dFechaPrescripcion = value;}
		}
		#endregion

		/// <summary>
		/// Constructor de la clase
		/// </summary>
		public CGarantiaReal()
		{
			ClaseGarantia = -1;
			TipoMitigador = -1;
			TipoDocumento = -1;
			OperacionEspecial = -1;
			Inscripcion = -1;
		}

		/// <summary>
		/// Metodo que retorna el objeto garantia actual en la session
		/// </summary>
		public static CGarantiaReal Current 
		{
			get 
			{ 
				//Obtiene el objeto CGarantiaFiduciaria del Session
				CGarantiaReal oCurrent = HttpContext.Current.Session["CGarantiaReal"] as CGarantiaReal;
				if (oCurrent == null) 
				{
					//si no existe crea el objeto en el session
					oCurrent = new CGarantiaReal();
					HttpContext.Current.Session["CGarantiaReal"] = oCurrent;
				}
				return oCurrent;
			}
		}
	}
}
