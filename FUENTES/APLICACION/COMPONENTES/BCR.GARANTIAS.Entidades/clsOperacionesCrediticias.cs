using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Collections;
using System.Xml;
using System.IO;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsOperacionesCrediticias<T> : CollectionBase
        where T : clsOperacionCrediticia
    {
        #region Variables

        #endregion Variables

        #region Constantes

        /// <summary>
        /// Estas constantes representan los tag de la trama obtenida
        /// </summary>
        private const string _operacionesAsociadas = "OPERACIONES_ASOCIADAS";
        private const string _operacion = "OPERACION";

        /// <summary>
        /// Estas constantes representan los nombres de las columnas del dataset
        /// </summary>
        private const string _contabilidad = "contabilidad";
        private const string _oficina = "oficina";
        private const string _moneda = "moneda";
        private const string _producto = "producto";
        private const string _numeroOperacion = "numeroOperacion";
        private const string _tipoOperacion = "tipoOperacion";
        private const string _codigoOperacion = "codigoOperacion";
        private const string _codigoGarantia = "codigoGarantia";
        private const string _montoAcreenciaPoliza = "Monto_Acreencia_Poliza";

        #endregion Constantes

        #region Constructor - Finalizador

        #endregion Constructor - Finalizador

        #region Propiedades

        #endregion Propiedades

        #region Métodos

        /// <summary>
        /// Agrega una entidad del tipo operación a la colección
        /// </summary>
        /// <param name="CapacidadPago">Entidad de Capacidad Pago que se agregará a la colección</param>
        public void Agregar(clsOperacionCrediticia avaluoReal)
        {
            InnerList.Add(avaluoReal);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo operación del a colección
        /// </summary>
        /// <param name="indece">Posición de la entidad dentro de la colección</param>
        public void Remover(int indece)
        {
            InnerList.RemoveAt(indece);
        }

        /// <summary>
        /// Obtiene una entidad de operación específica
        /// </summary>
        /// <param name="indece">Posición, dentro de la colección, de la entidad que se requiere</param>
        /// <returns>Una entidad del tipo capacidad de pago</returns>
        public clsOperacionCrediticia Item(int indece)
        {
            return (clsOperacionCrediticia)InnerList[indece];
        }

        /// <summary>
        /// Permite convertir la entidad en un dataset
        /// </summary>
        /// <returns>DataSet que posee la información de la entidad</returns>
        public DataSet toDataSet()
        {
            //Se inicializan la variables locales
            DataSet dsOperaciones = new DataSet();
            DataTable dtOperaciones = new DataTable("Operaciones");


            #region Agregar columnas a la tabla

            DataColumn dcColumna = new DataColumn(_contabilidad, typeof(short));
            dtOperaciones.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_oficina, typeof(short));
            dtOperaciones.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_moneda, typeof(short));
            dtOperaciones.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_producto, typeof(short));
            dtOperaciones.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_operacion, typeof(long));
            dtOperaciones.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_tipoOperacion, typeof(short));
            dtOperaciones.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_codigoOperacion, typeof(Int64));
            dtOperaciones.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_codigoGarantia, typeof(Int64));
            dtOperaciones.Columns.Add(dcColumna);

            dcColumna = new DataColumn(_montoAcreenciaPoliza, typeof(decimal));
            dtOperaciones.Columns.Add(dcColumna);

            dtOperaciones.AcceptChanges();

            #endregion Agregar columnas a la tabla

            //Se verifica que existan registros
            if (InnerList.Count > 0)
            {
                #region Agregar filas y datos a la tabla

                DataRow drFila = dtOperaciones.NewRow();

                foreach (clsOperacionCrediticia operacionCredi in InnerList)
                {
                    drFila[_contabilidad] = operacionCredi.Contabilidad;
                    drFila[_oficina] = operacionCredi.Oficina;
                    drFila[_moneda] = operacionCredi.Moneda;
                    drFila[_producto] = operacionCredi.Producto;
                    drFila[_operacion] = operacionCredi.Operacion;
                    drFila[_tipoOperacion] = operacionCredi.TipoOperacion;
                    drFila[_codigoOperacion] = operacionCredi.CodigoOperacion;
                    drFila[_codigoGarantia] = operacionCredi.CodigoGarantia;
                    drFila[_montoAcreenciaPoliza] = operacionCredi.MontoAcreenciaPoliza;

                    dtOperaciones.Rows.Add(drFila);
                    drFila = dtOperaciones.NewRow();
                }

                #endregion Agregar filas y datos a la tabla

                dtOperaciones.AcceptChanges();

                dtOperaciones.DefaultView.Sort = _operacion + " desc";
            }

            dsOperaciones.Tables.Add(dtOperaciones);
            dsOperaciones.AcceptChanges();

            return dsOperaciones;
        }

        /// <summary>
        /// Se sobreescribe este método con la finalidad de propocionar los datos bajo un formato específico
        /// </summary>
        /// <returns>Cadena de texto con el formato Contabilidad - Oficina - Moneda - Producto - Operación, agregando el tag html 'br /'</returns>
        public override string ToString()
        {
            StringBuilder cadenaRetornada = new StringBuilder();

            if (InnerList.Count > 0)
            {
                foreach (clsOperacionCrediticia operacionCredi in InnerList)
                {
                    cadenaRetornada.Append(operacionCredi.Contabilidad.ToString());
                    cadenaRetornada.Append(" - ");
                    cadenaRetornada.Append(operacionCredi.Oficina.ToString());
                    cadenaRetornada.Append(" - ");
                    cadenaRetornada.Append(operacionCredi.Moneda.ToString());
                    cadenaRetornada.Append(" - ");
                    cadenaRetornada.Append(operacionCredi.Producto.ToString());
                    cadenaRetornada.Append(" - ");
                    cadenaRetornada.Append(operacionCredi.Operacion.ToString());
                }
            }

            cadenaRetornada.Append("<br />");

            return cadenaRetornada.ToString();
        }

        /// <summary>
        /// Obtiene la lista de operaciones y/o contratos a los que está relacionada una garantía específica. 
        /// los datos son suministrados bajo el formato Contabilidad - Oficina - Moneda - Producto (sólo para operaciones directas) - Operación, agregando el tag html 'br /'
        /// </summary>
        /// <param name="tipoOperaciones">El tipo de operación de la que se requiere la cadanena</param>
        /// <returns>Un arreglo de cadenas, en donde 0 = Operaciones Directas y 1 = Contratos</returns>
        public string[] ObtenerDatosOperaciones(Enumeradores.Tipos_Operaciones tipoOperaciones)
        {
            string[] datosOperaciones = { string.Empty, string.Empty };
            StringBuilder cadenaRetornadaOperDirectas = new StringBuilder();
            StringBuilder cadenaRetornadaOperContratos = new StringBuilder();
             bool operacionDuplicada = false;

            if (InnerList.Count > 0)
            {
                /*Se eliminan las operaciones o contratos duplicados, esto para generar un sólo código*/
                ArrayList operacionesValidas = new ArrayList();

                foreach (clsOperacionCrediticia operacionCredi in InnerList)
                {
                    foreach (clsOperacionCrediticia operacionCrediticia in operacionesValidas)
                    {
                        if (operacionCrediticia.ToString(false).CompareTo(operacionCredi.ToString(false)) == 0)
                        {
                            operacionDuplicada = true;                            
                        }
                    }

                    if (!operacionDuplicada)
                    {
                        operacionesValidas.Add(operacionCredi);
                    }

                    operacionDuplicada = false;
                }

                switch (tipoOperaciones)
                {
                    case Enumeradores.Tipos_Operaciones.Directa:
                        foreach (clsOperacionCrediticia operacionCredi in operacionesValidas)
                        {
                            if (operacionCredi.TipoOperacion == 1)
                            {
                                cadenaRetornadaOperDirectas.Append(operacionCredi.Contabilidad.ToString());
                                cadenaRetornadaOperDirectas.Append(" - ");
                                cadenaRetornadaOperDirectas.Append(operacionCredi.Oficina.ToString());
                                cadenaRetornadaOperDirectas.Append(" - ");
                                cadenaRetornadaOperDirectas.Append(operacionCredi.Moneda.ToString());
                                cadenaRetornadaOperDirectas.Append(" - ");
                                cadenaRetornadaOperDirectas.Append(operacionCredi.Producto.ToString());
                                cadenaRetornadaOperDirectas.Append(" - ");
                                cadenaRetornadaOperDirectas.Append(operacionCredi.Operacion.ToString());
                                cadenaRetornadaOperDirectas.Append(".");

                                cadenaRetornadaOperDirectas.Append("<br />");
                            }
                        }

                        break;
                    case Enumeradores.Tipos_Operaciones.Contrato:
                        foreach (clsOperacionCrediticia operacionCredi in operacionesValidas)
                        {
                            if (operacionCredi.TipoOperacion == 2)
                            {
                                cadenaRetornadaOperContratos.Append(operacionCredi.Contabilidad.ToString());
                                cadenaRetornadaOperContratos.Append(" - ");
                                cadenaRetornadaOperContratos.Append(operacionCredi.Oficina.ToString());
                                cadenaRetornadaOperContratos.Append(" - ");
                                cadenaRetornadaOperContratos.Append(operacionCredi.Moneda.ToString());
                                cadenaRetornadaOperContratos.Append(" - ");
                                cadenaRetornadaOperContratos.Append(operacionCredi.Operacion.ToString());
                                cadenaRetornadaOperContratos.Append(".");

                                cadenaRetornadaOperContratos.Append("<br />");
                            }
                        }

                        break;
                    case Enumeradores.Tipos_Operaciones.Todos:
                        foreach (clsOperacionCrediticia operacionCredi in operacionesValidas)
                        {
                            if (operacionCredi.TipoOperacion == 1)
                            {
                                cadenaRetornadaOperDirectas.Append(operacionCredi.Contabilidad.ToString());
                                cadenaRetornadaOperDirectas.Append(" - ");
                                cadenaRetornadaOperDirectas.Append(operacionCredi.Oficina.ToString());
                                cadenaRetornadaOperDirectas.Append(" - ");
                                cadenaRetornadaOperDirectas.Append(operacionCredi.Moneda.ToString());
                                cadenaRetornadaOperDirectas.Append(" - ");
                                cadenaRetornadaOperDirectas.Append(operacionCredi.Producto.ToString());
                                cadenaRetornadaOperDirectas.Append(" - ");
                                cadenaRetornadaOperDirectas.Append(operacionCredi.Operacion.ToString());
                                cadenaRetornadaOperDirectas.Append(".");

                                cadenaRetornadaOperDirectas.Append("<br />");
                            }
                            else if (operacionCredi.TipoOperacion == 2)
                            {
                                cadenaRetornadaOperContratos.Append(operacionCredi.Contabilidad.ToString());
                                cadenaRetornadaOperContratos.Append(" - ");
                                cadenaRetornadaOperContratos.Append(operacionCredi.Oficina.ToString());
                                cadenaRetornadaOperContratos.Append(" - ");
                                cadenaRetornadaOperContratos.Append(operacionCredi.Moneda.ToString());
                                cadenaRetornadaOperContratos.Append(" - ");
                                cadenaRetornadaOperContratos.Append(operacionCredi.Operacion.ToString());
                                cadenaRetornadaOperContratos.Append(".");

                                cadenaRetornadaOperContratos.Append("<br />");
                            }
                        }

                        break;
                    default:
                        break;
                }

                datosOperaciones = new string[2];
                datosOperaciones[0] = cadenaRetornadaOperDirectas.ToString().TrimEnd("<br />".ToCharArray());
                datosOperaciones[1] = cadenaRetornadaOperContratos.ToString().TrimEnd("<br />".ToCharArray());
            }

            return datosOperaciones;
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

            //Inicializa el nodo que poseerá los datos de las operaciones asociadas
            objEscritor.WriteStartElement(_operacionesAsociadas);

            if (InnerList.Count > 0)
            {
                foreach (clsOperacionCrediticia operacionCredi in InnerList)
                {
                    objEscritor.WriteStartElement(_operacion);

                    //Crea el nodo de la contabilidad
                    objEscritor.WriteStartElement(_contabilidad);
                    objEscritor.WriteString(operacionCredi.Contabilidad.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la oficina
                    objEscritor.WriteStartElement(_oficina);
                    objEscritor.WriteString(operacionCredi.Oficina.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la moneda
                    objEscritor.WriteStartElement(_moneda);
                    objEscritor.WriteString(operacionCredi.Moneda.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del producto
                    objEscritor.WriteStartElement(_producto);
                    objEscritor.WriteString(operacionCredi.Producto.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo de la operación
                    objEscritor.WriteStartElement(_numeroOperacion);
                    objEscritor.WriteString(operacionCredi.Operacion.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del tipo de operación
                    objEscritor.WriteStartElement(_tipoOperacion);
                    objEscritor.WriteString(operacionCredi.TipoOperacion.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del consecutivo de la operación
                    objEscritor.WriteStartElement(_codigoOperacion);
                    objEscritor.WriteString(operacionCredi.CodigoOperacion.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del consecutivo de la garantía
                    objEscritor.WriteStartElement(_codigoGarantia);
                    objEscritor.WriteString(operacionCredi.CodigoGarantia.ToString());
                    objEscritor.WriteEndElement();

                    //Crea el nodo del monto de la acreencia de la póliza
                    objEscritor.WriteStartElement(_montoAcreenciaPoliza);
                    objEscritor.WriteString(operacionCredi.MontoAcreenciaPoliza.ToString());
                    objEscritor.WriteEndElement();

                    //Final del tag OPERACION
                    objEscritor.WriteEndElement();
                }
            }

            //Final del tag OPERACIONES_ASOCIADAS
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
        /// Se genera la lista de los consecutivos de las operaciones relacionadas
        /// </summary>
        /// <returns>Lista con los consecutivos de las operaciones, separadas con un pipe "|"</returns>
        public string ListaConsecutivosOperaciones()
        {
            string listaConsecutivosOperaciones = string.Empty;

            if (InnerList.Count > 0)
            {
                foreach (clsOperacionCrediticia operacionCredi in InnerList)
                {
                    listaConsecutivosOperaciones += operacionCredi.CodigoOperacion.ToString() + "|";
                }
            }

            return listaConsecutivosOperaciones;
        }

        /// <summary>
        /// Determina si dentro de la lista de operaciones existen consecutivos de garantías diferentes
        /// </summary>
        /// <returns></returns>
        public bool TieneGarantiasDiferentes()
        {
            List<long> listaConsecutivosGarantias = new List<long>();

            if (InnerList.Count > 0)
            {
                foreach (clsOperacionCrediticia operacionCredi in InnerList)
                {
                    if (!listaConsecutivosGarantias.Contains(operacionCredi.CodigoGarantia))
                    {
                        listaConsecutivosGarantias.Add(operacionCredi.CodigoGarantia);
                    }
                }
            }


            return ((listaConsecutivosGarantias.Count > 1) ? true : false);
        }

        /// <summary>
        /// Permite determinar si alguna garantía posee un monto de acreencia diferente
        /// </summary>
        /// <returns>Arreglo con la lista de operaciones (índice 0) y contratos (índice 1) que poseen un monto de acreencia diferente. Si la lista es vacía indica que todos los montos son iguales.</returns>
        public string[] TieneMontosAcreenciaDistintos()
        {
            StringBuilder cadenaRetornada = new StringBuilder();
            string[] datosOperaciones = { string.Empty, string.Empty };

            StringBuilder cadenaRetornadaOperDirectas = new StringBuilder();
            StringBuilder cadenaRetornadaOperContratos = new StringBuilder();

            if (InnerList.Count > 0)
            {
                foreach (clsOperacionCrediticia operacionCrediInicial in InnerList)
                {
                    foreach (clsOperacionCrediticia operacionCrediActual in InnerList)
                    {
                        if (operacionCrediInicial.MontoAcreenciaPoliza != operacionCrediActual.MontoAcreenciaPoliza)
                        {
                            if (operacionCrediInicial.TipoOperacion == 1)
                            {
                                cadenaRetornadaOperDirectas.Append(operacionCrediInicial.ToString(true));
                            }
                            else if (operacionCrediInicial.TipoOperacion == 2)
                            {
                                cadenaRetornadaOperContratos.Append(operacionCrediInicial.ToString(true));
                            }
                        }
                    }
                }

                datosOperaciones = new string[2];
                datosOperaciones[0] = cadenaRetornadaOperDirectas.ToString().TrimEnd("<br />".ToCharArray());
                datosOperaciones[1] = cadenaRetornadaOperContratos.ToString().TrimEnd("<br />".ToCharArray());
            }

            return datosOperaciones;
        }

        #endregion Métodos

    }
}
