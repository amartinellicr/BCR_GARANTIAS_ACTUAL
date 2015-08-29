using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Xml;
using System.Data;
using System.Diagnostics;
using System.IO;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsPolizasSap<T> : CollectionBase
        where T : clsPolizaSap
    {
        #region Constantes

        private const string _tagPolizas = "POLIZAS";
        private const string _tagPoliza   = "POLIZA";

        private const string _codigoSap = "Codigo_SAP";
        private const string _tipoPoliza = "Tipo_Poliza";
        private const string _montoPoliza = "Monto_Poliza";
        private const string _monedaMontoPoliza = "Moneda_Monto_Poliza";
        private const string _fechaVencimientoPoliza = "Fecha_Vencimiento";
        private const string _cedulaAcreedorPoliza = "Cedula_Acreedor";
        private const string _nombreAcreedorPoliza = "Nombre_Acreedor";
        private const string _montoAcreencia = "Monto_Acreencia";
        private const string _detallePoliza = "Detalle_Poliza";
        private const string _polizaSeleccionada = "Poliza_Seleccionada";
        private const string _montoPolizaColonizado = "Monto_Poliza_Colonizado";
        private const string _descripcionTipoPolizaSap = "Descripcion_Tipo_Poliza_Sap";
        private const string _codigoSapValido = "Codigo_Sap_Valido";
        private const string _montoPolizaAnterior = "Monto_Poliza_Anterior";
        private const string _fechaVencimientoPolizaAnterior = "Fecha_Vencimiento_Anterior";
        private const string _cedulaAcreedorAnterior = "Cedula_Acreedor_Anterior";
        private const string _nombreAcreedorAnterior = "Nombre_Acreedor_Anterior";
        private const string _tipoBienPoliza = "Tipo_Bien_Poliza";
        private const string _polizaAsociada = "Poliza_Asociada";

        private const string _indicadorPolizaExterna = "Indicador_Poliza_Externa";

        private const string _codigoPartido = "Codigo_Partido";
        private const string _identificacionBien = "Identificacion_Bien";
        private const string _codigoTipoCobertura = "Codigo_Tipo_Cobertura";
        private const string _codigoAseguradora = "Codigo_Aseguradora";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Trama obtenida en la consulta inicial
        /// </summary>
        private string tramaPolizas;

        /// <summary>
        /// Indicador de que se present� un error de datos
        /// </summary>
        private bool errorDatos;

        /// <summary>
        /// Descripci�n del error detectado
        /// </summary>
        private string descripcionError;

        /// <summary>
        /// Indicador de que se present� un error en la p�liza seleccionada, pues no existe la relaci�n entre el tipo de bien y el tipo de p�liza SAP
        /// </summary>
        private bool errorRelacionTipoBienTipoPolizaSAP;
        #endregion Variables

        #region Propiedades

        /// <summary>
        /// Obtiene o establece la trama de respuesta obtenida de la consulta realizada a la Base de Datos
        /// </summary>
        public string TramaPolizas
        {
            get { return tramaPolizas; }
            set { tramaPolizas = value; }
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

        /// <summary>
        /// Propiedad que obtiene y establece la indicaci�n de que se present� un error por problema de datos, pues no existe la relaci�n entre el tipo de bien y el tipo de p�liza SAP
        /// </summary>
        public bool ErrorRelacionTipoBienPolizaSap
        {
            get { return errorRelacionTipoBienTipoPolizaSAP; }
            set { errorRelacionTipoBienTipoPolizaSAP = value; }
        }

        #endregion Propiedades

        #region Construtores

        /// <summary>
        /// Constructor base del a clase
        /// </summary>
        public clsPolizasSap()
        {
            this.tramaPolizas = string.Empty;
        }

        /// <summary>
        /// Constructor extendido de la clase, crea la clase en base al a trama suministrada
        /// </summary>
        /// <param name="tramaPolizasBD">Trama que posee los datos de las p�lizas obtenidas de la Base de Datos</param>
        public clsPolizasSap(string tramaPolizasBD)
        {
            this.tramaPolizas = string.Empty;

            if (tramaPolizasBD.Length > 0)
            {
                XmlDocument xmlPolizas = new XmlDocument();

                try
                {
                    xmlPolizas.LoadXml(tramaPolizasBD);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    descripcionError = Mensajes.Obtener(Mensajes._errorCargaPolizaSap, Mensajes.ASSEMBLY);

                    string desError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaPolizaSapDetalle, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlPolizas != null)
                {
                    this.tramaPolizas = tramaPolizasBD;

                    if (xmlPolizas.HasChildNodes)
                    {
                        clsPolizaSap entidadPoliza;

                        foreach (XmlNode nodoPoliza in xmlPolizas.SelectNodes("//" + _tagPolizas).Item(0).ChildNodes)
                        {
                            entidadPoliza = new clsPolizaSap(nodoPoliza.OuterXml);

                            if (entidadPoliza.ErrorDatos)
                            {
                                this.errorDatos = entidadPoliza.ErrorDatos;
                                this.descripcionError = entidadPoliza.DescripcionError;
                                break;
                            }
                            else
                            {
                                this.Agregar(entidadPoliza);
                            }
                        }
                    }
                }
            }
        }
        #endregion Constructores

        #region M�todos P�blicos

        /// <summary>
        /// Agrega una entidad del tipo p�liza SAP a la colecci�n
        /// </summary>
        /// <param name="poliza">Entidad de Poliza SAP que se agregar� a la colecci�n</param>
        public void Agregar(clsPolizaSap poliza)
        {
            InnerList.Add(poliza);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo p�liza SAP de la colecci�n
        /// </summary>
        /// <param name="indice">Posici�n de la entidad dentro de la colecci�n</param>
        public void Remover(int indice)
        {
            InnerList.RemoveAt(indice);
        }

        /// <summary>
        /// Obtiene una entidad del tipo p�liza SAP espec�fica
        /// </summary>
        /// <param name="indice">Posici�n, dentro de la colecci�n, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo p�liza SAP</returns>
        public clsPolizaSap Item(int indice)
        {
            return (clsPolizaSap)InnerList[indice];
        }

        /// <summary>
        /// Obtiene la lista de elementos del c�digo SAP especificado. 
        /// </summary>
        /// <param name="codigoSap">C�digo SAP del registro requerido</param>
        /// <param name="tipoBien">C�digo del tipo de bien</param>
        /// <returns>Lista de entidades del c�digo SAP</returns>
        public List<clsPolizaSap> Items(int codigoSap, int tipoBien)
        {
            List<clsPolizaSap> listaItems = new List<clsPolizaSap>();

            foreach (clsPolizaSap entidadPoliza in InnerList)
            {
                if ((entidadPoliza.CodigoPolizaSap == codigoSap) && (entidadPoliza.TipoBienPoliza == tipoBien))
                {
                    listaItems.Add(entidadPoliza);
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsPolizaSap>("CodigoPolizaSap", clsComparadorGenerico<clsPolizaSap>.SortOrder.Ascending));

            return listaItems;
        }

        /// <summary>
        /// Obtiene la lista de p�lizas seg�n el tipo de p�liza SAP especificado. 
        /// </summary>
        /// <param name="tipoPolizaSap">C�digo del tipo de p�liza SAP del registro requerido</param>
        /// <returns>Lista de entidades del tipo p�liza SAP</returns>
        public List<clsPolizaSap> ObtenerPolizas(int tipoPolizaSap)
        {
            List<clsPolizaSap> listaItems = new List<clsPolizaSap>();

            foreach (clsPolizaSap entidadPoliza in InnerList)
            {
                if ((entidadPoliza.CodigoSapValido) && (entidadPoliza.TipoPolizaSap == tipoPolizaSap))
                {
                    listaItems.Add(entidadPoliza);
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsPolizaSap>("CodigoPolizaSap", clsComparadorGenerico<clsPolizaSap>.SortOrder.Ascending));

            return listaItems;
        }

        /// <summary>
        /// Obtiene la lista de p�lizas seg�n el tipo de p�liza SAP especificado. 
        /// </summary>
        /// <param name="tipoPolizaSap">Lista con los c�digos del tipo de p�liza SAP requeridos</param>
        /// <returns>Lista de entidades del tipo p�liza SAP</returns>
        public List<clsPolizaSap> ObtenerPolizas(List<int> tipoPolizaSap)
        {
            List<clsPolizaSap> listaItems = new List<clsPolizaSap>();

            foreach (clsPolizaSap entidadPoliza in InnerList)
            {
                if ((entidadPoliza.CodigoSapValido) && (tipoPolizaSap.Contains(entidadPoliza.TipoPolizaSap)))
                {
                    listaItems.Add(entidadPoliza);
                }
            }

            listaItems.Sort(new clsComparadorGenerico<clsPolizaSap>("CodigoPolizaSap", clsComparadorGenerico<clsPolizaSap>.SortOrder.Ascending));

            return listaItems;
        }

        /// <summary>
        /// Obtiene toda la lista de elementos del tipo p�liza SAP. 
        /// </summary>
        /// <returns>Lista de entidades del tipo p�liza SAP</returns>
        public List<clsPolizaSap> Items()
        {
            List<clsPolizaSap> listaItems = new List<clsPolizaSap>();

            foreach (clsPolizaSap entidadPoliza in InnerList)
            {
                listaItems.Add(entidadPoliza);
            }

            listaItems.Sort(new clsComparadorGenerico<clsPolizaSap>("CodigoPolizaSap", clsComparadorGenerico<clsPolizaSap>.SortOrder.Ascending));

            return listaItems;
        }

        /// <summary>
        /// Obtiene toda la lista de p�lizas seg�n el tipo de bien. 
        /// </summary>
        /// <param name="tipoBien">Tipo bien del cual se requiere la lista de p�lizas</param>
        /// <returns>Lista de entidades del tipo p�liza SAP</returns>
        public List<clsPolizaSap> ObtenerPolizasPorTipoBien(int tipoBien)
        {
            List<clsPolizaSap> listaItems = new List<clsPolizaSap>();
            clsPolizaSap entidadSeleccionada = null;

            errorRelacionTipoBienTipoPolizaSAP = false;

            foreach (clsPolizaSap entidadPoliza in InnerList)
            {
                if (entidadPoliza.CodigoSapValido)
                {
                    if (entidadPoliza.TipoBienPoliza == tipoBien)
                    {
                        listaItems.Add(entidadPoliza);
                    }
                    else if ((entidadPoliza.TipoBienPoliza == -1) && (entidadPoliza.PolizaSapSeleccionada))
                    {
                        errorRelacionTipoBienTipoPolizaSAP = true;
                    }
                }
                else if ((!entidadPoliza.CodigoSapValido) && (entidadPoliza.PolizaAsociada))
                {
                    errorRelacionTipoBienTipoPolizaSAP = true;
                }

                if (entidadPoliza.PolizaSapSeleccionada)
                {
                    entidadSeleccionada = entidadPoliza;
                }
            }

            if ((entidadSeleccionada != null) && (!listaItems.Contains(entidadSeleccionada)))
            {
                errorRelacionTipoBienTipoPolizaSAP = true;
            }

            listaItems.Sort(new clsComparadorGenerico<clsPolizaSap>("CodigoPolizaSap", clsComparadorGenerico<clsPolizaSap>.SortOrder.Ascending));

            return listaItems;
        }

        /// <summary>
        /// Obtiene la entidad cuya p�liza ha sido asociada a la garant�a consultada
        /// </summary>
        /// <returns>Entidad del tipo p�liza SAP</returns>
        public clsPolizaSap ObtenerPolizaSapSeleccionada()
        {
            clsPolizaSap entidadSeleccionada = null;

            foreach (clsPolizaSap entidadPoliza in InnerList)
            {
                if (entidadPoliza.PolizaSapSeleccionada)
                {
                    entidadSeleccionada = entidadPoliza;
                }
            }

            return entidadSeleccionada;
        }

        /// <summary>
        /// Obtiene la cantidad de p�lizas que existen dentro de la estructura de p�lizas relacionadas
        /// </summary>
        /// <returns>Cantidad de p�lizas asociadas</returns>
        public int ObtenerCantidadPolizasAsociadas()
        {
           int cantidadRegistros = 0;

            foreach (clsPolizaSap entidadPoliza in InnerList)
            {
                if (entidadPoliza.PolizaAsociada)
                {
                    cantidadRegistros++;
                }
            }

            return cantidadRegistros;
        }

        /// <summary>
        /// Se genera la trama con los datos contenidos en la lista
        /// </summary>
        /// <returns>Trama con los datos que posee la lista</returns>
        public string ObtenerTrama()
        {
            string tramaGenerada = string.Empty;

            MemoryStream stream = new MemoryStream(200000);

            //Crea un escritor de XML con el path y el formato
            XmlTextWriter objEscritor = new XmlTextWriter(stream, Encoding.UTF8);

            //Se inicializa para que idente el archivo
            objEscritor.Formatting = Formatting.None;

            //Inicializa el Documento XML
            objEscritor.WriteStartDocument();

            //Inicializa el nodo que poseer� los datos de las operaciones asociadas
            objEscritor.WriteStartElement(_tagPolizas);

            if (InnerList.Count > 0)
            {
                foreach (clsPolizaSap polizaSap in this.InnerList)
                {
                    objEscritor.WriteStartElement(_tagPoliza);

                    //Crea el nodo del c�digo SAP
                    objEscritor.WriteStartElement(_codigoSap);
                    objEscritor.WriteString(polizaSap.CodigoPolizaSap.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del tipo de p�liza
                    objEscritor.WriteStartElement(_tipoPoliza);
                    objEscritor.WriteString(polizaSap.TipoPolizaSap.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto de la p�liza
                    objEscritor.WriteStartElement(_montoPoliza);
                    objEscritor.WriteString(polizaSap.MontoPolizaSap.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del c�digo de moneda del monto de la p�liza 
                    objEscritor.WriteStartElement(_monedaMontoPoliza);
                    objEscritor.WriteString(polizaSap.TipoMonedaPolizaSap.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha de vencimiento
                    objEscritor.WriteStartElement(_fechaVencimientoPoliza);
                    objEscritor.WriteString(polizaSap.FechaVencimientoPolizaSap.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la c�dula del acreedor
                    objEscritor.WriteStartElement(_cedulaAcreedorPoliza);
                    objEscritor.WriteString(polizaSap.CedulaAcreedorPolizaSap);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del nombre del acreedor
                    objEscritor.WriteStartElement(_nombreAcreedorPoliza);
                    objEscritor.WriteString(polizaSap.NombreAcreedorPolizaSap);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto de la acreencia de la p�liza
                    objEscritor.WriteStartElement(_montoAcreencia);
                    objEscritor.WriteString(polizaSap.MontoAcreenciaPolizaSap.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del detalle de la p�liza
                    objEscritor.WriteStartElement(_detallePoliza);
                    objEscritor.WriteString(polizaSap.DetallePolizaSap);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del indicador de que la p�liza haya sido seleccionada
                    objEscritor.WriteStartElement(_polizaSeleccionada);
                    objEscritor.WriteString(((polizaSap.PolizaSapSeleccionada) ? "1" : "0"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del tipo de bien asociado al tipo de la p�liza
                    objEscritor.WriteStartElement(_tipoBienPoliza);
                    objEscritor.WriteString(polizaSap.TipoBienPoliza.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto colonizado de la p�liza
                    objEscritor.WriteStartElement(_montoPolizaColonizado);
                    objEscritor.WriteString(polizaSap.MontoPolizaSapColonizado.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la descripci�n del tipo de p�liza SAP
                    objEscritor.WriteStartElement(_descripcionTipoPolizaSap);
                    objEscritor.WriteString(polizaSap.DecripcionTipoPolizaSap);
                    objEscritor.WriteEndElement();
                    
                    //Crea el nodo del indicador d� si la p�liza SAP es v�lida
                    objEscritor.WriteStartElement(_codigoSapValido);
                    objEscritor.WriteString(((polizaSap.CodigoSapValido) ? "1" : "0"));
                    objEscritor.WriteEndElement();

                   //Crea el nodo del monto anterior de la p�liza
                    objEscritor.WriteStartElement(_montoPolizaAnterior);
                    objEscritor.WriteString(polizaSap.MontoPolizaAnterior.ToString("N2"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la fecha de vencimiento anterior
                    objEscritor.WriteStartElement(_fechaVencimientoPolizaAnterior);
                    objEscritor.WriteString(polizaSap.FechaVencimientoAnterior.ToString("yyyyMMdd"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la c�dula anterior del acreedor
                    objEscritor.WriteStartElement(_cedulaAcreedorAnterior);
                    objEscritor.WriteString(polizaSap.CedulaAcreedorAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del nombre anterior del acreedor
                    objEscritor.WriteStartElement(_nombreAcreedorAnterior);
                    objEscritor.WriteString(polizaSap.NombreAcreedorAnterior);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del indicador d� si la p�liza SAP existe dentro de la estructura de p�lizas relacionadas
                    objEscritor.WriteStartElement(_polizaAsociada);
                    objEscritor.WriteString(((polizaSap.PolizaAsociada) ? "1" : "0"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del indicador de si la poliza SAP es externa o no, seg�n el SAP

                    objEscritor.WriteStartElement(_indicadorPolizaExterna);
                    objEscritor.WriteString(((polizaSap.IndicadorPolizaExterna) ? "1" : "0"));
                    objEscritor.WriteEndElement();

                    //Crea el nodo del c�digo del partido
                    objEscritor.WriteStartElement(_codigoPartido);
                    objEscritor.WriteString(polizaSap.CodigoPartido.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la identificaci�n del bien
                    objEscritor.WriteStartElement(_identificacionBien);
                    objEscritor.WriteString(polizaSap.IdentificacionBien);
                    objEscritor.WriteEndElement();

                    //Crea el nodo del tipo de cobertura de la p�liza
                    objEscritor.WriteStartElement(_codigoTipoCobertura);
                    objEscritor.WriteString(polizaSap.TipoCobertura.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la aseguradora de la p�liza
                    objEscritor.WriteStartElement(_codigoAseguradora);
                    objEscritor.WriteString(polizaSap.CodigoAseguradora.ToString());
                    objEscritor.WriteEndElement();

                    //Inicializa el nodo que poseer los datos de las coberturas de la p�liza
                    objEscritor.WriteString(polizaSap.ListaCoberturasPoliza.ObtenerTrama());

                    //Final del tag POLIZA
                    objEscritor.WriteEndElement();
                }
            }

            //Final del tag POLIZAS
            objEscritor.WriteEndElement();

            //Final del documento
            objEscritor.WriteEndDocument();

            //Flush
            objEscritor.Flush();

            tramaGenerada = UtilitariosComun.GetStringFromStream(stream).Replace("<?xml version=\"1.0\" encoding=\"utf-8\"?>", string.Empty);

            //Cierre del xml document
            objEscritor.Close();

            return tramaGenerada;
        }

        /// <summary>
        /// Resetea el indicador de selecci�n de las p�lizas a false
        /// </summary>
        public void QuitarSeleccion()
        {
            foreach (clsPolizaSap entidadPoliza in InnerList)
            {
                entidadPoliza.PolizaSapSeleccionada = false;
            }
        }

        /// <summary>
        /// Asigna la p�liza seleccionada
        /// </summary>
        public void AsignarPolizaSeleccionada(int codigoSap, int tipoBien)
        {
            foreach (clsPolizaSap entidadPoliza in InnerList)
            {
                if ((entidadPoliza.CodigoPolizaSap == codigoSap) && (entidadPoliza.TipoBienPoliza == tipoBien))
                {
                    entidadPoliza.PolizaSapSeleccionada = true;
                }
            }
        }

        /// <summary>
        /// Obtiene la p�liza que est� asociada al bien consultado
        /// </summary>
        /// <param name="codigoPartido">C�digo del partido</param>
        /// <param name="identificacionBien">Identificaci�n del bien</param>
        /// <returns>Una entidad de tipo p�liza, de no existir una o si existen varias se retornar� nulo</returns>
        public clsPolizaSap ObtenerPolizaRelacionadaBien(short codigoPartido, string identificacionBien, Enumeradores.Tipos_Garantia_Real tipoGarantia)
        {
            clsPolizaSap entidadRetornada = null;
            int cantidadPolizas = 0;


            if (this.InnerList.Count > 0)
            {
                if ((tipoGarantia != Enumeradores.Tipos_Garantia_Real.Prenda) && ((codigoPartido >= 1) && (codigoPartido <= 7)) && (identificacionBien.Length > 0))
                {
                    foreach (clsPolizaSap entidadPoliza in InnerList)
                    {
                        if ((entidadPoliza.CodigoPartido == codigoPartido) && (entidadPoliza.IdentificacionBien.CompareTo(identificacionBien) == 0))
                        {
                            entidadRetornada = entidadPoliza;
                            cantidadPolizas++;
                        }
                    }
                }
                else if ((tipoGarantia == Enumeradores.Tipos_Garantia_Real.Prenda) && (identificacionBien.Length > 0))
                {
                    foreach (clsPolizaSap entidadPoliza in InnerList)
                    {
                        if (entidadPoliza.IdentificacionBien.CompareTo(identificacionBien) == 0)
                        {
                            entidadRetornada = entidadPoliza;
                            cantidadPolizas++;
                        }
                    }
                }

                if (cantidadPolizas != 1)
                {
                    entidadRetornada = null;
                }
            }

            return entidadRetornada;
        }

        /// <summary>
        /// M�todo que permite convertir la lista de elementos en formato JSON
        /// </summary>
        /// <returns>Cadena con las p�lizas de la lista, en formato JSON</returns>
        public string ObtenerJSON()
        {
            StringBuilder listaPolizasJSON = new StringBuilder();

            //Se revisa que la lista posea p�lizas
            if (this.InnerList.Count > 0)
            {
                //Se agrega la llave de inicio
                listaPolizasJSON.Append("[");

                //Se recorren las p�lizas y se genera la cedena JSON de cada uno
                foreach (clsPolizaSap convertirPoliza in this.InnerList)
                {
                    listaPolizasJSON.Append(convertirPoliza.ConvertirJSON());
                    listaPolizasJSON.Append(",");
                }

                //Se agrega la llave final
                listaPolizasJSON.Append("]");

                //Se elimina la coma (,) final
                listaPolizasJSON.Replace(",]", "]");
            }

            //Se retorna la cadena generada
            return listaPolizasJSON.ToString();
        }
        #endregion M�todos P�blicos
    }
}
