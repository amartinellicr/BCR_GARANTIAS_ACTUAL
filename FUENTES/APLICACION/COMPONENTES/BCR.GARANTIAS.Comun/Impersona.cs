using System; 
using System.Runtime.InteropServices; 
using System.Security.Principal;

namespace BCR.GARANTIAS.Comun
{
    //Esta clase impersonaliza un usuario temporalmente 
    // basada en el articulo http://msdn.microsoft.com/en-us/library/ms998351.aspx#paght000023_impersonatingorigcallertemp
    public class Impersonalizacion
    {

        enum LogonSessionType : uint
        {
            Interactive = 2,  //Esta tiene permisos sobre los recursos de red
            Network, //Esta No tiene permisos sobre los recursos de red (curioso no?)
            Batch,
            Service,
            NetworkCleartext = 8,
            NewCredentials
        }
        enum LogonProvider : uint
        {
            Default = 0, // default (usar esta)
            WinNT35,     // usa una señales dummy para autenticar (sends smoke signals to authority)
            WinNT40,     // usa NTLM
            WinNT50      // usa Kerberos o NTLM
        }


        //[DllImport("advapi32.dll", SetLastError = true)]
        //public static extern bool LogonUser(String lpszUsername, String lpszDomain, String lpszPassword, int dwLogonType, int dwLogonProvider, ref IntPtr phToken);

        [DllImport("advapi32.dll", SetLastError = true)]
        static extern bool LogonUser(
          string principal,
          string authority,
          string password,
          LogonSessionType logonType,
          LogonProvider logonProvider,
          out IntPtr token);


        [DllImport("advapi32.dll", EntryPoint = "DuplicateToken", ExactSpelling = false, CharSet = CharSet.Auto, SetLastError = true)]
        public static extern int DuplicateToken(IntPtr ExistingTokenHandle, int ImpersonationLevel, ref IntPtr DuplicateTokenHandle);

        public static WindowsImpersonationContext WinLogOn(string strUsuario, string strClave, string strDominio)
        {
            IntPtr tokenDuplicate = new IntPtr(0);
            IntPtr tokenHandle = new IntPtr(0);
            if (LogonUser(strUsuario, strDominio, strClave, LogonSessionType.Interactive, LogonProvider.Default, out tokenHandle))
            {
                if (DuplicateToken(tokenHandle, 2, ref tokenDuplicate) != 0)
                {
                    return (new WindowsIdentity(tokenDuplicate)).Impersonate();
                }
                else
                {
                    UtilitariosComun.RegistraEventLog(("DuplicateToken = 0, tokenHandle = " + tokenHandle.ToString() + ", tokenDuplicate = " + tokenDuplicate.ToString()), System.Diagnostics.EventLogEntryType.Error);
                }
            }
            else
            {
                UtilitariosComun.RegistraEventLog(("LogonUser = false, strUsuario = " + strUsuario + ", strDominio = " + strDominio + ", clave = " + strClave + ", tokenHandle = " + tokenHandle.ToString()), System.Diagnostics.EventLogEntryType.Error);
            }

            return null;

        }
    }
}