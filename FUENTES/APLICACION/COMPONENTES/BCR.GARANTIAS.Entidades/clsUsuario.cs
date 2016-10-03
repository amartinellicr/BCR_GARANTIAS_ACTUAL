

namespace BCR.GARANTIAS.Entidades
{
    public class clsUsuario
    {
        #region Constantes

        public const string _entidadUsuario = "SEG_USUARIO";
        public const string _cedulaUsuario = "COD_USUARIO";
        public const string _nombreUsuario = "DES_USUARIO";
        public const string _codigoPerfil = "COD_PERFIL";

        #endregion

        #region Propiedades

        public string CedulaUsuario { get; set; }

        public string NombreUsuario { get; set; }

        public int CodigoPerfil { get; set; }

        #endregion Propiedades

        #region Constructor

        public clsUsuario(string cedulaUsuario, string nombreUsuario, int codigoPerifl)
        {
            CedulaUsuario = cedulaUsuario;
            NombreUsuario = nombreUsuario;
            CodigoPerfil = codigoPerifl;
        }

        #endregion Constructor
    }
}
