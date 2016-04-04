using System;
using System.Text;
using System.Data;
using System.Collections;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;


namespace BCR.GARANTIAS.Entidades
{
    [Serializable]
    public class clsSaldosTotalesPorcentajeResponsabilidad<T> : CollectionBase
        where T : clsSaldoTotalPorcentajeResponsabilidad
    {

        #region Constantes
        #endregion Constantes

        #region Propiedades
        #endregion Propiedades

        #region Constructores

        public clsSaldosTotalesPorcentajeResponsabilidad()
        {
            //clsSaldoTotalPorcentajeResponsabilidad registroCargar = new clsSaldoTotalPorcentajeResponsabilidad();

            //InnerList.Add(registroCargar);
        }

        public clsSaldosTotalesPorcentajeResponsabilidad(DataSet datosCargar)
        {
            //Se verfica que existan datos
            if ((datosCargar != null) && (datosCargar.Tables.Count > 0) && (datosCargar.Tables[0].Rows.Count > 0))
            {
                clsSaldoTotalPorcentajeResponsabilidad registroCargar;

                foreach (DataRow registroSaldo in datosCargar.Tables[0].Rows)
                {
                    registroCargar = new clsSaldoTotalPorcentajeResponsabilidad(registroSaldo);

                    if ((registroCargar != null) && (registroCargar.ConsecutivoOperacion > 0) && (registroCargar.ConsecutivoGarantia > 0) && (registroCargar.CodigoTipoGarantia > 0))
                    {
                        InnerList.Add(registroCargar);
                    }
                }
            }
        }

        public clsSaldosTotalesPorcentajeResponsabilidad(string cadenaJSON)
        {
            clsSaldoTotalPorcentajeResponsabilidad registroAgregar = null;

            //Se revisa que la cadena posea caracteres
            if (cadenaJSON.Length > 0)
            {
                //Se eliminan la llave inicial y final de la cadena
                cadenaJSON = cadenaJSON.Replace("{{", "{").Replace("}}", "}");

                StringBuilder cadenaRegistros = new StringBuilder();

                //Se recorre la cadena caracter por caracter
                for (int indiceCaracter = 0; indiceCaracter < cadenaJSON.Length; indiceCaracter++)
                {
                    cadenaRegistros.Append(cadenaJSON[indiceCaracter]);

                    //Se verifica que si la llave es de cierre indica que ya se obtuvo el equivalente a un semestre
                    if (cadenaJSON[indiceCaracter] == '}')
                    {
                        //Se carga el semestre obtenido
                        registroAgregar = new clsSaldoTotalPorcentajeResponsabilidad(cadenaRegistros.ToString());

                        if (registroAgregar != null)
                        {
                            //Se agrega a la lista el semestre generado
                            Agregar(registroAgregar);
                        }

                        //Se reincia la cadena de texto que permite obtener cada semestre
                        cadenaRegistros = new StringBuilder();
                    }
                }
            }
        }

        #endregion Constructores

        #region Métodos

        /// <summary>
        /// Agrega una entidad del tipo saldo total y porcentaje de responsabilidad a la colección
        /// </summary>
        /// <param name="saldoTotalPorcResp">Entidad de Saldo Total y Porcentaje de Responsabilidad que se agregará a la colección</param>
        public void Agregar(clsSaldoTotalPorcentajeResponsabilidad saldoTotalPorcResp)
        {
            InnerList.Add(saldoTotalPorcResp);
        }

        /// <summary>
        /// Remueve una determinada entidad del tipo saldo total y porcentaje de responsabilidad de la colección
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
        /// <returns>Una entidad del tipo saldo total y porcentaje de responsabilidad</returns>
        public clsSaldoTotalPorcentajeResponsabilidad Item(int indece)
        {
            return (clsSaldoTotalPorcentajeResponsabilidad)InnerList[indece];
        }
        
        /// <summary>
        /// Obtiene la lista de registros excluidos
        /// </summary>
        /// <returns>Lista con los registros que han sido excluidos de forma explícita por el usuario</returns>
        public ArrayList ObtenerRegistrosExcluidos()
        {
            ArrayList registrosExcluidos = new ArrayList();

            if((InnerList != null) && (InnerList.Count > 0))
            {
                foreach(clsSaldoTotalPorcentajeResponsabilidad registro in InnerList)
                {
                    if(registro.IndicadorExcluido)
                    {
                        registrosExcluidos.Add(registro);
                    }
                }
            }

            return registrosExcluidos;
        }

        /// <summary>
        /// Obtiene la lista de registros que han sido ajustados por el usuario
        /// </summary>
        /// <returns>Lista con los registros que han sido ajustados de forma explícita por el usuario</returns>
        public ArrayList ObtenerRegistrosAjustados()
        {
            ArrayList registrosAjustados = new ArrayList();

            if ((InnerList != null) && (InnerList.Count > 0))
            {
                foreach (clsSaldoTotalPorcentajeResponsabilidad registro in InnerList)
                {
                    if ((registro.IndicadorAjusteCampoSaldo) || (registro.IndicadorAjusteCampoPorcentaje))
                    {
                        registrosAjustados.Add(registro);
                    }
                }
            }

            return registrosAjustados;
        }

        /// <summary>
        /// Método que permite convertir la lista de elementos en formato JSON
        /// </summary>
        /// <returns>Cadena con las operaciones y garantías con saldos totales y porcentajes de responsabilidad de la lista, en formato JSON</returns>
        public string ObtenerJSON()
        {
            StringBuilder listaRegistrosJSON = new StringBuilder();

            //Se revisa que la lista posea pólizas
            if (InnerList.Count > 0)
            {
                //Se agrega la llave de inicio
                listaRegistrosJSON.Append("[");

                //Se recorren las pólizas y se genera la cedena JSON de cada uno
                foreach (clsSaldoTotalPorcentajeResponsabilidad convertirRegistro in InnerList)
                {
                    listaRegistrosJSON.Append(convertirRegistro.ConvertirJSON());
                    listaRegistrosJSON.Append(",");
                }

                //Se agrega la llave final
                listaRegistrosJSON.Append("]");

                //Se elimina la coma (,) final
                listaRegistrosJSON.Replace(",]", "]");
            }

            //Se retorna la cadena generada
            return listaRegistrosJSON.ToString();
        }
        
        /// <summary>
        /// Aplica el cálculo de la redistribución del porcentaje de responsabilidad entre las operaciones participantes.
        /// </summary>
        /// <returns></returns>
        public bool AplicarCalculoDistribucion()
        {
            bool calculoExitoso = true;
            decimal saldoParcial = 0;
            decimal SaldoRegistroAjustado = 0;
            decimal porcentajeRegistroAjustado = 0;
            decimal porcentajePorDistribuir = 0;

            try
            {
                if ((InnerList != null) && (InnerList.Count > 0))
                {
                    //Se obtienen los datos del saldo y porcentaje ajustados
                    foreach (clsSaldoTotalPorcentajeResponsabilidad registroAjustado in InnerList)
                    {
                        if ((registroAjustado.IndicadorAjusteCampoSaldo) || (registroAjustado.IndicadorAjusteCampoPorcentaje))
                        {
                            SaldoRegistroAjustado += registroAjustado.SaldoActualAjustado;
                            porcentajeRegistroAjustado += registroAjustado.PorcentajeResponsabilidadAjustado;
                        }
                    }

                    //Se calcula el porcentaje que resta por distribuir
                    porcentajePorDistribuir = 100 - porcentajeRegistroAjustado;


                    //Se obteiene el saldo parcial
                    foreach (clsSaldoTotalPorcentajeResponsabilidad registroActual in InnerList)
                    {
                        if ((!registroActual.IndicadorExcluido) && (!registroActual.IndicadorAjusteCampoSaldo) && (!registroActual.IndicadorAjusteCampoPorcentaje))
                        {
                            saldoParcial += ((registroActual.SaldoActualAjustado <= 0) ? registroActual.SaldoActual : registroActual.SaldoActualAjustado);
                        }
                    }

                    //Se recalculan los porcentajes de responsabilidad
                    foreach (clsSaldoTotalPorcentajeResponsabilidad registroActual in InnerList)
                    {
                        if ((!registroActual.IndicadorExcluido) && (!registroActual.IndicadorAjusteCampoSaldo) && (!registroActual.IndicadorAjusteCampoPorcentaje))
                        {
                            registroActual.PorcentajeResponsabilidadCalculado = (((registroActual.SaldoActual / saldoParcial) * porcentajePorDistribuir)); // / 100);
                            registroActual.PorcentajeResponsabilidadAjustado = registroActual.PorcentajeResponsabilidadCalculado;
                        }
                    }
                }
            }
            catch (ArithmeticException ex)
            {
                calculoExitoso = false;

                string detalleTecnico = string.Format("Método: AplicarCalculoDistribucion. Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoDistribucionPrDetalle, detalleTecnico, Mensajes.ASSEMBLY), EventLogEntryType.Error);

            }
            catch (Exception ex)
            {
                calculoExitoso = false;

                string detalleTecnico = string.Format("Método: AplicarCalculoDistribucion. Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoDistribucionPrDetalle, detalleTecnico, Mensajes.ASSEMBLY), EventLogEntryType.Error);

            }

            return calculoExitoso;
        }

        /// <summary>
        /// Aplica el cálculo de la representación porcentual del saldo de cada operación participante.
        /// </summary>
        /// <returns></returns>
        public bool AplicarCalculorRepresentacionPorcentualSaldos()
        {
            bool calculoExitoso = true;
            decimal saldoTotal = 0;
 
            try
            {

                if ((InnerList != null) && (InnerList.Count > 0))
                {                    
                    //Se obteiene el saldo total
                    foreach (clsSaldoTotalPorcentajeResponsabilidad registroActual in InnerList)
                    {                        
                            saldoTotal += registroActual.SaldoActual; 
                    }

                    //Se recalculan los porcentajes de responsabilidad
                    foreach (clsSaldoTotalPorcentajeResponsabilidad registroActual in InnerList)
                    {
                        registroActual.PorcentajeResponsabilidadCalculado = ((registroActual.SaldoActual / saldoTotal) * 100);
                    }
                }
            }
            catch (ArithmeticException ex)
            {
                calculoExitoso = false;

                string detalleTecnico = string.Format("Método: AplicarCalculorRepresentacionPorcentualSaldos. Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoDistribucionPrDetalle, detalleTecnico, Mensajes.ASSEMBLY), EventLogEntryType.Error);

            }
            catch (Exception ex)
            {
                calculoExitoso = false;

                string detalleTecnico = string.Format("Método: AplicarCalculorRepresentacionPorcentualSaldos. Error: {0}, Descripción: {1}", ex.Message, ex.StackTrace);

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorAplicandoCalculoDistribucionPrDetalle, detalleTecnico, Mensajes.ASSEMBLY), EventLogEntryType.Error);

            }

            return calculoExitoso;
        }

        #endregion Métodos
    }
}
