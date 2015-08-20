USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Procesar_Polizas_Migradas', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Procesar_Polizas_Migradas;
GO

CREATE PROCEDURE [dbo].[Procesar_Polizas_Migradas]
	@psCodigoProceso		VARCHAR(20),
	@piEjecutarParte	TINYINT	
AS
/*****************************************************************************************************************************************************
	<Nombre>Procesar_Polizas_Migradas</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que permite pasar las pólizas migradas, localizadas en la tabla 
		temporal, a la tabla oficial de los datos.
	</Descripción>
	<Entradas>
			@psCodigoProceso = Código del proceso que ejecuta este procedimiento almacenado.
            @piEjecutarParte = Indica la parte del procedimiento almacenado que será ejecutada.
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>16/06/2014</Fecha>
	<Requerimiento>
			Req_Polizas, Siebel No.1-24342731.
	</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas S.A.</Autor>
			<Requerimiento>Incidente: 2015073110439893 Relación pólizas de contratos</Requerimiento>
			<Fecha>19/08/2015</Fecha>
			<Descripción>
				Se modifica la forma en como se procesan las pólizas, se incluyen tablas nuevas y 
				se hace uso de estructuras nuevas dentro del proceso de réplica (paquete SSIS).
				Además, se cambia el mapeo de la fecha de vencimiento, para que refleje la 
				fecha pagado hasta. Adicionalmente se incluye el indicador de si la póliza es externa.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/
BEGIN

	SET NOCOUNT ON
	SET DATEFORMAT dmy

	--Declaración de variables 
	DECLARE	@vdTipo_Cambio NUMERIC(16,2), --Tipo de cambio de la compra del dólar americano para la fecha del proceso.
			@viError_Tran INT, -- Almacena el código del error generado durante la transacción
			@vdtFecha_Sin_Hora DATETIME, --Fecha actual sin hora
			@vdtFecha_Tipo_Cambio DATETIME, --Fecha más reciente del tipo de cambio del día actual
			@ciCatalogo_Tipo_Poliza INT, --Código del catálogo de los tipos de póliza SAP
			@vsDescripcion_Bitacora_Errores VARCHAR(5000), --Descripción del error que será guardado en la bitácora de errores.
			@viFechaActualEntera INT --Corresponde al a fecha actual en formato numérico.

	
	--Se inicializan las variables
	SET @ciCatalogo_Tipo_Poliza = 29
	
	SET @vdtFecha_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)

	SET	@vdTipo_Cambio = (	SELECT	TOP 1 CONVERT(NUMERIC(16,2), Tipo_Cambio)
							FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO
							WHERE	CONVERT(DATETIME,CAST(Fecha_Hora AS VARCHAR(11)),101) = @vdtFecha_Sin_Hora
							ORDER	BY Fecha_Hora DESC)
		
	
	SET @viFechaActualEntera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	
	
	IF(@piEjecutarParte = 0)
	BEGIN
	
		DELETE	FROM dbo.TMP_POLIZAS 
		WHERE	Registro_Activo = 0
			AND DATEDIFF(DAY, GETDATE(), Fecha_Replica) > 10
			
		DELETE	FROM  dbo.TMP_SAP_VWSGRPOLIZA
		WHERE	Registro_Activo = 0
			AND DATEDIFF(DAY, GETDATE(), Fecha_Replica) > 10
		
		DELETE	FROM dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO
		WHERE	Registro_Activo = 0
			AND DATEDIFF(DAY, GETDATE(), Fecha_Replica) > 10
			
		DELETE	FROM dbo.TMP_SAP_VWSGRPOLIZACONTRATOCREDITO
		WHERE	Registro_Activo = 0
			AND DATEDIFF(DAY, GETDATE(), Fecha_Replica) > 10		
			
		DELETE	FROM  dbo.TMP_SAP_POLIZASEXTERNAS
		WHERE	Registro_Activo = 0
			AND DATEDIFF(DAY, GETDATE(), Fecha_Replica) > 10
			
		DELETE	FROM dbo.TMP_SAP_SGRPOLIZAOTRO 
		WHERE	Registro_Activo = 0
			AND DATEDIFF(DAY, GETDATE(), Fecha_Replica) > 10
			
		DELETE	FROM  dbo.TMP_SAP_SGRPOLIZAPATRIMONIAL
		WHERE	Registro_Activo = 0
			AND DATEDIFF(DAY, GETDATE(), Fecha_Replica) > 10
				
		DELETE	FROM  dbo.TMP_SAP_VWSGRPOLIZAAUTO
		WHERE	Registro_Activo = 0
			AND DATEDIFF(DAY, GETDATE(), Fecha_Replica) > 10
	
		UPDATE dbo.TMP_POLIZAS
		SET Registro_Activo = 0
		WHERE Registro_Activo IS NULL
		
		UPDATE dbo.TMP_POLIZAS
		SET Registro_Activo = 0
		WHERE Registro_Activo = 1
		
		UPDATE dbo.TMP_SAP_VWSGRPOLIZA
		SET Registro_Activo = 0
		WHERE Registro_Activo IS NULL
		
		UPDATE dbo.TMP_SAP_VWSGRPOLIZA
		SET Registro_Activo = 0
		WHERE Registro_Activo = 1
				
		UPDATE dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO
		SET Registro_Activo = 0
		WHERE Registro_Activo IS NULL
		
		UPDATE dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO
		SET Registro_Activo = 0
		WHERE Registro_Activo = 1
		
		UPDATE dbo.TMP_SAP_VWSGRPOLIZACONTRATOCREDITO
		SET Registro_Activo = 0
		WHERE Registro_Activo IS NULL
		
		UPDATE dbo.TMP_SAP_VWSGRPOLIZACONTRATOCREDITO
		SET Registro_Activo = 0
		WHERE Registro_Activo = 1
		
		UPDATE dbo.TMP_SAP_POLIZASEXTERNAS
		SET Registro_Activo = 0
		WHERE Registro_Activo IS NULL
		
		UPDATE dbo.TMP_SAP_POLIZASEXTERNAS
		SET Registro_Activo = 0
		WHERE Registro_Activo = 1
		
		UPDATE dbo.TMP_SAP_SGRPOLIZAOTRO
		SET Registro_Activo = 0
		WHERE Registro_Activo IS NULL
		
		UPDATE dbo.TMP_SAP_SGRPOLIZAOTRO
		SET Registro_Activo = 0
		WHERE Registro_Activo = 1
		
		UPDATE dbo.TMP_SAP_SGRPOLIZAPATRIMONIAL
		SET Registro_Activo = 0
		WHERE Registro_Activo IS NULL
		
		UPDATE dbo.TMP_SAP_SGRPOLIZAPATRIMONIAL
		SET Registro_Activo = 0
		WHERE Registro_Activo = 1
		
		UPDATE dbo.TMP_SAP_VWSGRPOLIZAAUTO
		SET Registro_Activo = 0
		WHERE Registro_Activo IS NULL
		
		UPDATE dbo.TMP_SAP_VWSGRPOLIZAAUTO
		SET Registro_Activo = 0
		WHERE Registro_Activo = 1
		
	END
	ELSE IF(@piEjecutarParte = 1)
	BEGIN
	
		--Se carga la información de la tabla temporal de pólizas, con los datos relacionados a las operaciones.
		BEGIN TRANSACTION TRA_Ins_Tmp_Pol
			BEGIN TRY
				INSERT INTO dbo.TMP_POLIZAS
				  (Codigo_SAP, Tipo_Poliza, Codigo_Oficina_Operacion, Codigo_Moneda_Operacion, Codigo_Producto_Operacion, Numero_Operacion,
				   Numero_Contrato, Consecutivo_Operacion_Garantias, Monto_Poliza, Moneda_Monto_Poliza, Estado_Poliza, Simbolo_Moneda, 
				   Fecha_Vencimiento, Descripcion_Moneda_Monto_Poliza, Detalle_Poliza, Fecha_Replica, Registro_Activo,
				   Indicador_Poliza_Externa)
				
				SELECT	DISTINCT
					VGP.conpoliza,
					VGP.contipopoliza,
					VCB.codue,
					VCB.conmoneda AS Moneda_Operacion,
					VCB.codproducto,
					VCB.numoperacion,
					'-1' AS Numero_Contrato,
					GO1.cod_operacion AS Consecutivo_Operacion_Garantias,
					COALESCE(VGP.mtoasegurado, 0) AS Monto_Poliza,
					VGP.conmoneda,
					VCB.estpolizacreditobancario,
					VGP.monsigno,
					VCB.fecpagadohasta,
					VGP.nommoneda,
					VGP.memobservacion,
					GETDATE() AS Fecha_Replica,
					1 AS Registro_Activo,
					0 AS Indicador_Poliza_Externa
				FROM	dbo.TMP_SAP_VWSGRPOLIZA VGP
					INNER JOIN dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO VCB
					ON VCB.conpoliza = VGP.conpoliza
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_oficina = VCB.codue
					AND GO1.cod_moneda = VCB.conmoneda
					AND GO1.cod_producto = VCB.codproducto
					AND GO1.num_operacion = VCB.numoperacion
				WHERE	VGP.Registro_Activo = 1
					AND VCB.Registro_Activo = 1
					AND VCB.concontratocredito IS NULL
					AND GO1.num_contrato = 0
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	prmoc_estado = 'A'
									AND prmoc_pse_proces = 1
									AND ((prmoc_pcoctamay > 815) OR (prmoc_pcoctamay < 815))
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion
									AND MOC.prmoc_pnu_contr = 0)
			
				UNION ALL
			
				SELECT	DISTINCT
					VGP.conpoliza,
					VGP.contipopoliza,
					VCC.codue,
					VCC.conmoneda AS Moneda_Operacion,
					GO1.cod_producto,
					-1 AS Numero_Operacion,
					VCC.coccontratocredito AS Numero_Contrato,
					GO1.cod_operacion AS Consecutivo_Operacion_Garantias,
					COALESCE(VGP.mtoasegurado, 0) AS Monto_Poliza,
					VGP.conmoneda,
					VCC.estpolizacontratocredito,
					VGP.monsigno,
					VCC.fecpagadohasta,
					VGP.nommoneda,
					VGP.memobservacion,
					GETDATE() AS Fecha_Replica,
					1 AS Registro_Activo,
					0 AS Indicador_Poliza_Externa
				FROM	dbo.TMP_SAP_VWSGRPOLIZA VGP
					INNER JOIN dbo.TMP_SAP_VWSGRPOLIZACONTRATOCREDITO VCC
					ON VCC.conpoliza = VGP.conpoliza
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_oficina = VCC.codue
					AND GO1.cod_moneda = VCC.conmoneda
					AND GO1.num_contrato = VCC.coccontratocredito
				WHERE	VGP.Registro_Activo = 1
					AND VCC.Registro_Activo = 1
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pfe_defin >= @viFechaActualEntera)
				
				UNION ALL
			
				SELECT	DISTINCT
					VGP.conpoliza,
					VGP.contipopoliza,
					VCC.codue,
					VCC.conmoneda AS Moneda_Operacion,
					GO1.cod_producto,
					-1 AS Numero_Operacion,
					VCC.coccontratocredito AS Numero_Contrato,
					GO1.cod_operacion AS Consecutivo_Operacion_Garantias,
					COALESCE(VGP.mtoasegurado, 0) AS Monto_Poliza,
					VGP.conmoneda,
					VCC.estpolizacontratocredito,
					VGP.monsigno,
					VCC.fecpagadohasta,
					VGP.nommoneda,
					VGP.memobservacion,
					GETDATE() AS Fecha_Replica,
					1 AS Registro_Activo,
					0 AS Indicador_Poliza_Externa
				FROM	dbo.TMP_SAP_VWSGRPOLIZA VGP
					INNER JOIN dbo.TMP_SAP_VWSGRPOLIZACONTRATOCREDITO VCC
					ON VCC.conpoliza = VGP.conpoliza
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_oficina = VCC.codue
					AND GO1.cod_moneda = VCC.conmoneda
					AND GO1.num_contrato = VCC.coccontratocredito
				WHERE	VGP.Registro_Activo = 1
					AND VCC.Registro_Activo = 1
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pfe_defin < @viFechaActualEntera
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pcomonint = MCA.prmca_pco_moned
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pse_proces = 1
													AND ((MOC.prmoc_pcoctamay > 815) OR (MOC.prmoc_pcoctamay < 815))))
								
			END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Ins_Tmp_Pol

					SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al extraer e insertar las pólizas en la tabla temporal. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

				END CATCH
				
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Tmp_Pol
	
		
		/************************************************************************************************
		 *                                                                                              * 
		 *                       INICIO DE LA REPLICA DE POLIZAS EXISTENTES                             *
		 *                                                                                              *
		 *                                                                                              *
		 ************************************************************************************************/
		--Se actualiza el indicador de si es una póliza externa.
		BEGIN TRANSACTION TRA_Act_Pol_Ext
			BEGIN TRY

				UPDATE	TMP
				SET		TMP.Indicador_Poliza_Externa = 1
				FROM	dbo.TMP_POLIZAS TMP
					INNER JOIN dbo.TMP_SAP_POLIZASEXTERNAS SPE
					ON SPE.conpoliza = TMP.Codigo_SAP
				WHERE	TMP.Registro_Activo = 1
					AND SPE.Registro_Activo = 1
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Pol_Ext

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar el indicador de si es una póliza externa, en la tabla temporal de pólizas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Pol_Ext
		
		--Se actualizan los campos del monto de la póliza y fecha de vencimiento anterior, de las pólizas existentes.
		BEGIN TRANSACTION TRA_Act_Datos
			BEGIN TRY

				UPDATE	GP1
				SET		GP1.Monto_Poliza_Anterior = GP1.Monto_Poliza,
						GP1.Fecha_Vencimiento_Anterior = GP1.Fecha_Vencimiento,
						GP1.Cedula_Acreedor_Anterior = GP1.Cedula_Acreedor,
						GP1.Nombre_Acreedor_Anterior = GP1.Nombre_Acreedor
				FROM	dbo.GAR_POLIZAS GP1
					INNER JOIN dbo.GAR_POLIZAS GP2
					ON GP2.Codigo_SAP = GP1.Codigo_SAP
					AND GP2.cod_operacion = GP1.cod_operacion
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Datos

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar el monto y fecha de vencimiento anteriores, dentro de la tabla de pólizas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Datos	
		
		--Se setea el indicador del registro como si ninguna póliza existiera
		BEGIN TRANSACTION TRA_Act_Polizas
			BEGIN TRY

				UPDATE	dbo.GAR_POLIZAS
				SET		Estado_Registro = 0
				
				--Se actualizan los campos de las pólizas existentes y se habilitan las que existan en los dos sistemas
				UPDATE	GPO
				SET	    GPO.Tipo_Poliza = TMP.Tipo_Poliza, 
						GPO.Monto_Poliza = TMP.Monto_Poliza, 
						GPO.Moneda_Monto_Poliza = TMP.Moneda_Monto_Poliza, 
						GPO.Fecha_Vencimiento = TMP.Fecha_Vencimiento, 
						GPO.Descripcion_Moneda_Monto_Poliza = TMP.Descripcion_Moneda_Monto_Poliza, 
						GPO.Simbolo_Moneda = TMP.Simbolo_Moneda,
						GPO.Detalle_Poliza = TMP.Detalle_Poliza, 
						GPO.Estado_Poliza = TMP.Estado_Poliza,	
						GPO.Fecha_Replica = GETDATE(),
						GPO.Monto_Poliza_Colonizado =	CASE
															WHEN TMP.Moneda_Monto_Poliza = 2 THEN ISNULL((TMP.Monto_Poliza * @vdTipo_Cambio), 0)
															ELSE ISNULL(TMP.Monto_Poliza, 0)
														END,
						GPO.Estado_Registro =	CASE 
													WHEN TMP.Estado_Poliza = 'CAN' THEN 0
													WHEN TMP.Estado_Poliza = 'ELI' THEN 0
													ELSE 1
												END,
						GPO.Indicador_Poliza_Externa = TMP.Indicador_Poliza_Externa
				FROM	dbo.GAR_POLIZAS GPO
					INNER JOIN dbo.TMP_POLIZAS TMP
					ON TMP.Codigo_SAP = GPO.Codigo_SAP
					AND TMP.Consecutivo_Operacion_Garantias = GPO.cod_operacion
				WHERE   COALESCE(TMP.Consecutivo_Operacion_Garantias, -1) > -1
					AND TMP.Registro_Activo = 1
					AND EXISTS (SELECT	1
								FROM	dbo.CAT_ELEMENTO CE1
								WHERE	CE1.cat_catalogo = @ciCatalogo_Tipo_Poliza
									AND CE1.cat_campo = CONVERT(VARCHAR(5), TMP.Tipo_Poliza))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Polizas

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar las pólizas existentes, dentro de la tabla de pólizas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Polizas	
		
		/************************************************************************************************
		 *                                                                                              * 
		 *                       INICIO DE LA REPLICA DE POLIZAS NUEVAS                                 *
		 *                                                                                              *
		 *                                                                                              *
		 ************************************************************************************************/
		BEGIN TRANSACTION TRA_Ins_Polizas
			BEGIN TRY

				INSERT	INTO dbo.GAR_POLIZAS (Codigo_SAP, cod_operacion, Tipo_Poliza, Monto_Poliza, 
											  Moneda_Monto_Poliza, Fecha_Vencimiento, Cedula_Acreedor, 
											  Nombre_Acreedor, Descripcion_Moneda_Monto_Poliza, Simbolo_Moneda,
											  Detalle_Poliza, Estado_Poliza, Estado_Registro, Fecha_Inserto, Fecha_Replica,
											  Monto_Poliza_Anterior, Fecha_Vencimiento_Anterior, Monto_Poliza_Colonizado,
											  Indicador_Poliza_Externa)
				SELECT	DISTINCT 
					TMP.Codigo_SAP, 
					TMP.Consecutivo_Operacion_Garantias AS cod_operacion, 
					TMP.Tipo_Poliza, 
					TMP.Monto_Poliza, 
					TMP.Moneda_Monto_Poliza, 
					TMP.Fecha_Vencimiento, 
					'4000000019' AS Cedula_Acreedor, 
					'Banco de Costa Rica' AS Nombre_Acreedor, 
					TMP.Descripcion_Moneda_Monto_Poliza, 
					TMP.Simbolo_Moneda,
					TMP.Detalle_Poliza, 
					TMP.Estado_Poliza, 
					CASE 
						WHEN TMP.Estado_Poliza = 'CAN' THEN 0
						WHEN TMP.Estado_Poliza = 'ELI' THEN 0
						ELSE 1
					END AS Estado_Registro, 
					GETDATE() AS Fecha_Inserto, 
					GETDATE() AS Fecha_Replica,
					TMP.Monto_Poliza AS Monto_Poliza_Anterior, 
					TMP.Fecha_Vencimiento AS Fecha_Vencimiento_Anterior, 
					CASE
						WHEN TMP.Moneda_Monto_Poliza = 2 THEN ISNULL((TMP.Monto_Poliza * @vdTipo_Cambio), 0)
						ELSE ISNULL(TMP.Monto_Poliza, 0)
					END AS Monto_Poliza_Colonizado,
					TMP.Indicador_Poliza_Externa
				FROM	dbo.TMP_POLIZAS TMP
				WHERE	COALESCE(TMP.Consecutivo_Operacion_Garantias, -1) > -1
					AND TMP.Registro_Activo = 1
					AND EXISTS (SELECT	1
								FROM	dbo.CAT_ELEMENTO CE1
								WHERE	CE1.cat_catalogo = @ciCatalogo_Tipo_Poliza
									AND CE1.cat_campo = CONVERT(VARCHAR(5), TMP.Tipo_Poliza))
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_POLIZAS GPO
									WHERE	GPO.Codigo_SAP = TMP.Codigo_SAP
										AND GPO.cod_operacion = COALESCE(TMP.Consecutivo_Operacion_Garantias, -1))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Polizas

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al insertar las nuevas pólizas dentro de la tabla de pólizas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Polizas	

		/************************************************************************************************
		 *                                                                                              * 
		 *                       INICIO DE LA ACTUALIZACION DE LAS RELACIONES ENTRE                     *
		 *                                        GARANTIAS Y POLIZAS                                   *
		 *                                                                                              *
		 ************************************************************************************************/
		BEGIN TRANSACTION TRA_Act_Rel_Pol
			BEGIN TRY

				UPDATE	GPR
				SET		Estado_Registro = 0
				FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
					INNER JOIN dbo.GAR_POLIZAS GPO
					ON GPO.Codigo_SAP = GPR.Codigo_SAP
					AND GPO.cod_operacion = GPR.cod_operacion
				WHERE	GPO.Estado_Registro = 0

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Rel_Pol

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar el estado del registro de las relaciones entre las pólizas y las garantías asociadas a una operación/contrato. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Rel_Pol	

		/************************************************************************************************
		 *                                                                                              * 
		 *                        FIN DE LA REPICA DE POLIZAS                                           *
		 *                                                                                              *
		 ************************************************************************************************/
	END
END