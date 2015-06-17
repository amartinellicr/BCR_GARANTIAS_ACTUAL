using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Data.SqlClient;
using System.Data;
using System.IO;
using System.Reflection;

using BCR.GARANTIAS.Comun;
using BCRGARANTIAS.Datos;

namespace BCR.GARANTIAS.Entidades
{
    public class clsCatalogo
    {
        #region Constantes

        private const string _tagCatalogo       = "CATALAGO";

        private const string _catCatalogo       = "cat_catalogo";
        private const string _catCampo          = "cat_campo";
        private const string _catDescripcion    = "cat_descripcion";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// C�digo del cat�logo
        /// </summary>
        private int codCatalogo;
    
        /// <summary>
        /// C�digo del elemento que pertenence a un determinado cat�logo
        /// </summary>
        private string codElemento;

        /// <summary>
        /// Descripci�n del elemento que pertenence a un determinado cat�logo
        /// </summary>
        private string desElemento;

        /// <summary>
        /// Indicador de que se present� un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripci�n del error detectado
        /// </summary>
        private string descripcionError;

        #endregion Variables

        #region Propiedades

        /// <summary>
        /// Propiedad que obtiene y establece el c�digo del cat�logo
        /// </summary>
        public int CodigoCatalogo
        {
            get { return codCatalogo; }
            set { codCatalogo = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el c�digo del elemento
        /// </summary>
        public string CodigoElemento
        {
            get { return codElemento; }
            set { codElemento = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripci�n del elemento del cat�logo
        /// </summary>
        public string DescripcionElemento
        {
            get { return desElemento; }
            set { desElemento = value; }
        }

        /// <summary>
        /// Propiedad que obtiene el c�digo del elemento como entero
        /// </summary>
        public int IDElemento
        {
            get 
            {
                int idElemento;
                return (int.TryParse(codElemento, out idElemento) ? idElemento : -1); 
            }
        }

        /// <summary>
        /// Porpiedad que obtiene el c�digo del elemento y la descripci�n concatenados 
        /// </summary>
        public string DescripcionCodigoElemento
        {
            get { return ((IDElemento != -1) ? (string.Format("{0} - {1}", codElemento, desElemento)) : string.Empty); }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la indicaci�n de que se present� un error por problema de datos
        /// </summary>
        public bool ErrorDatos
        {
            get { return errorDatos; }
            set { errorDatos = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripci�n del error
        /// </summary>
        public string DescripcionError
        {
            get { return descripcionError; }
            set { descripcionError = value; }
        }

	
        #endregion Propiedades

        #region Constructores

        public clsCatalogo()
        {
            codCatalogo = -1;
            codElemento = string.Empty;
            desElemento = string.Empty;
        }

        public clsCatalogo(string tramaCatalogo)
        {
            #region Trama Ejemplo
            /*
                <CATALOGOS>
                  <CATALAGO>
                    <cat_catalogo>14</cat_catalogo>
                    <cat_campo>1</cat_campo>
                    <cat_descripcion>Due�o</cat_descripcion>
                  </CATALAGO>
                  <CATALAGO>
                    <cat_catalogo>14</cat_catalogo>
                    <cat_campo>2</cat_campo>
                    <cat_descripcion>Arrendatario</cat_descripcion>
                  </CATALAGO>
                  <CATALAGO>
                    <cat_catalogo>14</cat_catalogo>
                    <cat_campo>3</cat_campo>
                    <cat_descripcion>Due�o-Arrendatario</cat_descripcion>
                  </CATALAGO>
                  <CATALAGO>
                    <cat_catalogo>14</cat_catalogo>
                    <cat_campo>4</cat_campo>
                    <cat_descripcion>Consentidor</cat_descripcion>
                  </CATALAGO>
                  <CATALAGO>
                    <cat_catalogo>14</cat_catalogo>
                    <cat_campo>5</cat_campo>
                    <cat_descripcion>Due�o-Consentidor</cat_descripcion>
                  </CATALAGO>
                  <CATALAGO>
                    <cat_catalogo>14</cat_catalogo>
                    <cat_campo>6</cat_campo>
                    <cat_descripcion>No definido</cat_descripcion>
                  </CATALAGO>
                  <CATALAGO>
                    <cat_catalogo>15</cat_catalogo>
                    <cat_campo>1</cat_campo>
                    <cat_descripcion>Colones</cat_descripcion>
                  </CATALAGO>
                  <CATALAGO>
                    <cat_catalogo>15</cat_catalogo>
                    <cat_campo>2</cat_campo>
                    <cat_descripcion>D�lares</cat_descripcion>
                  </CATALAGO>
                  <CATALAGO>
                    <cat_catalogo>15</cat_catalogo>
                    <cat_campo>3</cat_campo>
                    <cat_descripcion>Euros</cat_descripcion>
                  </CATALAGO>
                </CATALOGOS>
             */
            #endregion Trama Ejemplo

            codCatalogo = -1;
            codElemento = string.Empty;
            desElemento = string.Empty;
            
            if (tramaCatalogo.Length > 0)
            {
                XmlDocument xmlCatalogo = new XmlDocument();

                try
                {
                    xmlCatalogo.LoadXml(tramaCatalogo);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS_DETALLE, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlCatalogo != null)
                {
                    int idCatalogo;

                    try
                    {
                        codCatalogo = ((xmlCatalogo.SelectSingleNode("//" + _catCatalogo)       != null) ? ((int.TryParse((xmlCatalogo.SelectSingleNode("//" + _catCatalogo).InnerText), out idCatalogo)) ? idCatalogo : -1) : -1);

                        codElemento = ((xmlCatalogo.SelectSingleNode("//" + _catCampo)          != null) ? xmlCatalogo.SelectSingleNode("//" + _catCampo).InnerText         : string.Empty);
                        desElemento = ((xmlCatalogo.SelectSingleNode("//" + _catDescripcion)    != null) ? xmlCatalogo.SelectSingleNode("//" + _catDescripcion).InnerText   : string.Empty);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS, Mensajes.ASSEMBLY);

                        string desError = "El error se da al cargar los datos del cat�logo: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS_DETALLE, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }
                }
            }
        }

        #endregion Constructores

        #region M�todos P�blicos

        #endregion M�todos P�blicos

        #region M�todos Privados

        #endregion M�todos Privados

    }
}
