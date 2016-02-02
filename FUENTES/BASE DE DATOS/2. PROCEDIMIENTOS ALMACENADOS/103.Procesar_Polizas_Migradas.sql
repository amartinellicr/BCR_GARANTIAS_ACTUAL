USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Procesar_Polizas_Migradas', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Procesar_Polizas_Migradas;
GO

CREATE PROCEDURE [dbo].[Procesar_Polizas_Migradas]
	@psCodigoProceso	VARCHAR(20),
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
			<Autor>Arnoldo Martinelli Marín, GrupoMas S.A.</Autor>
			<Requerimiento>RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas</Requerimiento>
			<Fecha>12/08/2015</Fecha>
			<Descripción>
				Se modifica la forma en como se procesan las pólizas, adicionalmente, se agrega el procesamiento de las coberturas 
				asignadas a dichas pólizas.
			</Descripción>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Incidente: 2015092810472305 - Solicitud de pase emergencia optimización de procesos 10472294</Requerimiento>
			<Fecha>28/09/2015</Fecha>
			<Descripción>
				Se realiza una optimización general, en donde se crean índices en estructuras y tablas nuevas. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_2016012910535596 Cambio en Estado de Pólizas</Requerimiento>
			<Fecha>02/02/2016</Fecha>
			<Descripción>
				Se realiza un ajuste al momento de actualizar el indicador de estado del registro de las pólizas relacionadas a garantías,
				se busca activar todas las relaciones para luego desactivar aquellas cuya póliza ha sufrido un cambio de estado. 
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
			@viFechaActualEntera INT, --Corresponde a la fecha actual en formato numérico.
			@vdtFecha_Eliminar DATETIME  --Corresponde a la fecha a partir de la cual se eliminarán los registros.
	
	--Se inicializan las variables
	SET @ciCatalogo_Tipo_Poliza = 29
	
	SET @vdtFecha_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)

	SET	@vdTipo_Cambio = (	SELECT	TOP 1 CONVERT(NUMERIC(16,2), Tipo_Cambio)
							FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO
							WHERE	CONVERT(DATETIME,CAST(Fecha_Hora AS VARCHAR(11)),101) = @vdtFecha_Sin_Hora
							ORDER	BY Fecha_Hora DESC)
		
	
	SET @viFechaActualEntera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	
	--Se actualiza el indicador de si es un giro y de serlo se asigna el consecutivo del contrato.
	--Esto se hace dentro de la tabla temporal de pólizas relacionadas a operaciones y/o giros de contrato del SAP.
	IF(@piEjecutarParte = 0)
	BEGIN

		BEGIN TRANSACTION TRA_Act_Giros_Cont
			BEGIN TRY

				UPDATE	TMP
				SET		TMP.Es_Giro = 1,
						TMP.Consecutivo_Contrato = MCA.cod_operacion
				FROM	dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO TMP
					INNER JOIN (SELECT	GO1.cod_oficina AS Ofic_Giro,
										GO1.cod_moneda AS Moned_Giro,
										GO1.cod_producto AS Produc_Giro,
										GO1.num_operacion AS Num_Giro,
										GO2.cod_oficina, 
										GO2.cod_moneda, 
										GO2.cod_producto, 
										GO2.num_contrato,
										GO2.cod_operacion
								FROM	dbo.GAR_OPERACION GO1
									INNER JOIN (SELECT	prmoc_pco_ofici, prmoc_pco_moned, prmoc_pco_produ, prmoc_pnu_contr, prmoc_pnu_oper, prmoc_pco_oficon, prmoc_pcomonint
												FROM	dbo.GAR_SICC_PRMOC
												WHERE	prmoc_estado = 'A'
													AND prmoc_pse_proces = 1
													AND ((prmoc_pcoctamay > 815) OR (prmoc_pcoctamay < 815))
													AND prmoc_pnu_contr > 0
													AND prmoc_pnu_oper >= 0) MOC
									ON GO1.cod_oficina = MOC.prmoc_pco_ofici
									AND GO1.cod_moneda = MOC.prmoc_pco_moned
									AND GO1.cod_producto = MOC.prmoc_pco_produ
									AND GO1.num_contrato = MOC.prmoc_pnu_contr
									AND GO1.num_operacion = MOC.prmoc_pnu_oper
									INNER JOIN dbo.GAR_OPERACION GO2
									ON GO2.cod_oficina = MOC.prmoc_pco_oficon
									AND GO2.cod_moneda = MOC.prmoc_pcomonint
									AND GO2.num_contrato = MOC.prmoc_pnu_contr
								WHERE	GO1.num_contrato > 0
									AND GO1.num_operacion IS NOT NULL
									AND GO2.num_operacion IS NULL) MCA
					ON	MCA.Ofic_Giro = TMP.codue
					AND MCA.Moned_Giro = TMP.conmoneda
					AND MCA.Produc_Giro = TMP.codproducto
					AND MCA.Num_Giro = TMP.numoperacion
				WHERE	TMP.Registro_Activo = 1
					
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Giros_Cont

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar el indicador de si es un giro y el consecutivo del contrato, en la tabla temporal pólizas asociadas a operaciones crediticias del SAP. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
				
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Giros_Cont
	
	END
	
	--Se actualiza el indicador de si es un giro y de serlo se asigna el consecutivo del contrato.
	--Esto se hace dentro de la tabla temporal de operaciones y/o giros de contrato del SAP.
	IF(@piEjecutarParte = 1)
	BEGIN
	
		BEGIN TRANSACTION TRA_Act_Giros_Cont1
			BEGIN TRY

				UPDATE	TMP
				SET		TMP.Es_Giro = 1,
						TMP.Consecutivo_Contrato = MCA.cod_operacion
				FROM	dbo.TMP_SAP_VWSGRCREDITOBANCARIO TMP
					INNER JOIN (SELECT	GO1.cod_oficina AS Ofic_Giro,
										GO1.cod_moneda AS Moned_Giro,
										GO1.cod_producto AS Produc_Giro,
										GO1.num_operacion AS Num_Giro,
										GO2.cod_oficina, 
										GO2.cod_moneda, 
										GO2.cod_producto, 
										GO2.num_contrato,
										GO2.cod_operacion
								FROM	dbo.GAR_OPERACION GO1
									INNER JOIN (SELECT	prmoc_pco_ofici, prmoc_pco_moned, prmoc_pco_produ, prmoc_pnu_contr, prmoc_pnu_oper, prmoc_pco_oficon, prmoc_pcomonint
												FROM	dbo.GAR_SICC_PRMOC
												WHERE	prmoc_estado = 'A'
													AND prmoc_pse_proces = 1
													AND ((prmoc_pcoctamay > 815) OR (prmoc_pcoctamay < 815))
													AND prmoc_pnu_contr > 0
													AND prmoc_pnu_oper >= 0) MOC
									ON GO1.cod_oficina = MOC.prmoc_pco_ofici
									AND GO1.cod_moneda = MOC.prmoc_pco_moned
									AND GO1.cod_producto = MOC.prmoc_pco_produ
									AND GO1.num_contrato = MOC.prmoc_pnu_contr
									AND GO1.num_operacion = MOC.prmoc_pnu_oper
									INNER JOIN dbo.GAR_OPERACION GO2
									ON GO2.cod_oficina = MOC.prmoc_pco_oficon
									AND GO2.cod_moneda = MOC.prmoc_pcomonint
									AND GO2.num_contrato = MOC.prmoc_pnu_contr
								WHERE	GO1.num_contrato > 0
									AND GO1.num_operacion IS NOT NULL
									AND GO2.num_operacion IS NULL) MCA
					ON	MCA.Ofic_Giro = TMP.codue
					AND MCA.Moned_Giro = TMP.conmoneda
					AND MCA.Produc_Giro = TMP.codproducto
					AND MCA.Num_Giro = TMP.numoperacion
				WHERE	TMP.Registro_Activo = 1
					
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Giros_Cont1

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar el indicador de si es un giro y el consecutivo del contrato, en la tabla temporal de operaciones crediticias del SAP. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Giros_Cont1
	
	END

	--Se carga la estructura con los giros activos de contrato en el sistema.
	IF(@piEjecutarParte = 2)
	BEGIN
	
		BEGIN TRANSACTION TRA_Act_Giros_Activ
			BEGIN TRY

				INSERT INTO dbo.TMP_GIROS_CONTRATOS (Consecutivo_Giro, Contabilidad_Giro, Oficina_Giro, 
					Moneda_Giro, Producto_Giro, Numero_Giro, Consecutivo_Contrato, Contabilidad_Contrato, Oficina_Contrato, 
					Moneda_Contrato, Producto_Contrato, Numero_Contrato, Fecha_Pagado_Hasta, Codigo_SAP, Fecha_Vencimiento_Poliza, Usuario, Fecha_Replica, Registro_Activo)

				SELECT	DISTINCT
						GO1.cod_operacion AS Consecutivo_Giro,
						GO1.cod_contabilidad AS Contabilidad_Giro, 
						GO1.cod_oficina AS Oficina_Giro, 
						GO1.cod_moneda AS Moneda_Giro, 
						GO1.cod_producto AS Producto_Giro, 
						GO1.num_operacion AS Numero_Giro,
						GO2.cod_operacion AS Consecutivo_Contrato, 
						GO2.cod_contabilidad AS Contabilidad_Contrato,
						GO2.cod_oficina AS Oficina_Contrato, 
						GO2.cod_moneda AS Moneda_Contrato, 
						GO2.cod_producto AS Producto_Contrato, 
						GO2.num_contrato AS Numero_Contrato,
						NULL AS Fecha_Pagado_Hasta,
						PCD.conpoliza AS Codigo_SAP,
						VSP.fecvence AS Fecha_Vencimiento_Poliza,
						@psCodigoProceso AS Usuario,
						GETDATE() AS Fecha_Replica,
						1 AS Registro_Activo
				FROM	dbo.GAR_OPERACION GO1
						INNER JOIN dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO PCD
						ON PCD.codue = GO1.cod_oficina
						AND PCD.conmoneda = GO1.cod_moneda
						AND PCD.codproducto = GO1.cod_producto
						AND PCD.numoperacion = GO1.num_operacion
						INNER JOIN dbo.TMP_SAP_VWSGRPOLIZA VSP
						ON VSP.conpoliza = PCD.conpoliza,
						dbo.GAR_OPERACION GO2
				WHERE 	GO1.num_contrato > 0
					AND GO1.num_operacion IS NOT NULL
					AND PCD.Registro_Activo = 1
					AND PCD.estpolizacreditobancario <> 'ELI'
					AND GO2.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1
									AND ((MOC.prmoc_pcoctamay > 815) OR (MOC.prmoc_pcoctamay < 815))
									AND MOC.prmoc_pnu_contr > 0
									AND MOC.prmoc_pnu_oper >= 0
									AND MOC.prmoc_pnu_oper = GO1.num_operacion
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pnu_contr = GO2.num_contrato
									AND MOC.prmoc_pco_oficon = GO2.cod_oficina
									AND MOC.prmoc_pcomonint = GO2.cod_moneda)			
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Giros_Activ

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al cargar los giros de contrato activos, en la tabla temporal de giros de contrato. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Giros_Activ
	
	END

	--Se actualiza la fecha de pagado hasta de los giros con señal de cobro.
	IF(@piEjecutarParte = 3)
	BEGIN
	
		BEGIN TRANSACTION TRA_Act_Giros_Cobro
			BEGIN TRY

				UPDATE	TGC
				SET		Fecha_Pagado_Hasta = PC2.fecpagadohasta
				FROM	dbo.TMP_GIROS_CONTRATOS	TGC
					INNER JOIN dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO PCD
					ON PCD.Consecutivo_Contrato = TGC.Consecutivo_Contrato
					AND PCD.conpoliza = TGC.Codigo_SAP
					INNER JOIN (SELECT	PC1.Consecutivo_Contrato, PC1.conpoliza, MAX(PC1.fecpagadohasta) AS fecpagadohasta
								FROM	dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO PC1
								WHERE	PC1.Registro_Activo = 1
									AND PC1.estpolizacreditobancario <> 'ELI'
									AND PC1.codsenalcredito = 2
									AND PC1.Es_Giro = 1
									AND PC1.Consecutivo_Contrato > 0
								GROUP BY PC1.Consecutivo_Contrato, PC1.conpoliza) PC2
					ON PC2.Consecutivo_Contrato = PCD.Consecutivo_Contrato
					AND PC2.conpoliza = PCD.conpoliza					
				WHERE	TGC.Registro_Activo = 1
					AND TGC.Usuario = @psCodigoProceso
					AND TGC.Codigo_SAP IS NOT NULL
					AND PCD.Registro_Activo = 1
					AND PCD.estpolizacreditobancario <> 'ELI'
					AND PCD.codsenalcredito = 2					
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Giros_Cobro

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de pagado hasta de los giros de contrato con señal de cobro, en la tabla temporal de giros de contrato. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
				
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Giros_Cobro
	
	END
	
	--Se actualiza la fecha de pagado hasta de los giros con señal de cobro 5.
	IF(@piEjecutarParte = 4)
	BEGIN
	
		BEGIN TRANSACTION TRA_Act_Giros_ConCobro5
			BEGIN TRY

				UPDATE	TGC
				SET		Fecha_Pagado_Hasta = VGP.fecvence
				FROM	dbo.TMP_GIROS_CONTRATOS	TGC
					INNER JOIN dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO PCD
					ON PCD.Consecutivo_Contrato = TGC.Consecutivo_Contrato
					AND PCD.conpoliza = TGC.Codigo_SAP
					INNER JOIN (SELECT	PC1.Consecutivo_Contrato, PC1.conpoliza, MAX(PC1.fecpagadohasta) AS fecpagadohasta
								FROM	dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO PC1
								WHERE	PC1.Registro_Activo = 1
									AND PC1.estpolizacreditobancario <> 'ELI'
									AND PC1.codsenalcredito = 5
									AND PC1.Es_Giro = 1
									AND PC1.Consecutivo_Contrato > 0
								GROUP BY PC1.Consecutivo_Contrato, PC1.conpoliza) PC2
					ON PC2.Consecutivo_Contrato = PCD.Consecutivo_Contrato
					AND PC2.conpoliza = PCD.conpoliza
					INNER JOIN dbo.TMP_SAP_VWSGRPOLIZA VGP
					ON VGP.conpoliza = PC2.conpoliza
				WHERE	TGC.Registro_Activo = 1
					AND TGC.Usuario = @psCodigoProceso
					AND TGC.Codigo_SAP IS NOT NULL
					AND TGC.Fecha_Pagado_Hasta IS NULL
					AND PCD.Registro_Activo = 1
					AND PCD.estpolizacreditobancario <> 'ELI'
					AND PCD.codsenalcredito = 5
					AND VGP.Registro_Activo = 1					
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Giros_ConCobro5

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de pagado hasta de los giros de contrato con señal de cobro 5, en la tabla temporal de giros de contrato. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Giros_ConCobro5

	
	END
		
	--Se actualiza la fecha de pagado hasta de los giros sin señal de cobro.
	IF(@piEjecutarParte = 5)
	BEGIN
	
		BEGIN TRANSACTION TRA_Act_Giros_SinCobro
			BEGIN TRY

				UPDATE	TGC
				SET		Fecha_Pagado_Hasta = PC2.fecpagadohasta
				FROM	dbo.TMP_GIROS_CONTRATOS	TGC
					INNER JOIN dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO PCD
					ON PCD.Consecutivo_Contrato = TGC.Consecutivo_Contrato
					AND PCD.conpoliza = TGC.Codigo_SAP
					INNER JOIN (SELECT	PC1.Consecutivo_Contrato, PC1.conpoliza, MAX(PC1.fecpagadohasta) AS fecpagadohasta
								FROM	dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO PC1
								WHERE	PC1.Registro_Activo = 1
									AND PC1.estpolizacreditobancario <> 'ELI'
									AND PC1.codsenalcredito <> 2
									AND PC1.codsenalcredito <> 5
									AND PC1.Es_Giro = 1
									AND PC1.Consecutivo_Contrato > 0
								GROUP BY PC1.Consecutivo_Contrato, PC1.conpoliza) PC2
					ON PC2.Consecutivo_Contrato = PCD.Consecutivo_Contrato
					AND PC2.conpoliza = PCD.conpoliza						
				WHERE	TGC.Registro_Activo = 1
					AND TGC.Usuario = @psCodigoProceso
					AND TGC.Codigo_SAP IS NOT NULL
					AND TGC.Fecha_Pagado_Hasta IS NULL
					AND PCD.Registro_Activo = 1
					AND PCD.estpolizacreditobancario <> 'ELI'
					AND PCD.codsenalcredito <> 2
					AND PCD.codsenalcredito <> 5					
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Giros_SinCobro

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de pagado hasta de los giros de contrato sin señal de cobro, en la tabla temporal de giros de contrato. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Giros_SinCobro
	
	END
		
	--Se carga la información de la tabla temporal de pólizas, con los datos relacionados a las operaciones.
	IF(@piEjecutarParte = 6)
	BEGIN
	
		BEGIN TRANSACTION TRA_Ins_Op_Tmp_Pol
			BEGIN TRY
				INSERT INTO dbo.TMP_POLIZAS
				  (Codigo_SAP, Tipo_Poliza, Codigo_Oficina_Operacion, Codigo_Moneda_Operacion, Codigo_Producto_Operacion, Numero_Operacion,
				   Numero_Contrato, Consecutivo_Operacion_Garantias, Monto_Poliza, Moneda_Monto_Poliza, Estado_Poliza, Simbolo_Moneda, 
				   Fecha_Vencimiento, Descripcion_Moneda_Monto_Poliza, Detalle_Poliza, Fecha_Replica, Registro_Activo,
				   Indicador_Poliza_Externa, Codigo_Partido, Identificacion_Bien, Codigo_Tipo_Cobertura, Codigo_Aseguradora)
				
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
					VGP.estpoliza,
					VGP.monsigno,
					--CASE 
					--	WHEN VCB.codsenalcredito = 5 THEN VGP.fecvence
					--	ELSE COALESCE(VCB.fecpagadohasta, VGP.fecvence) 
					--END AS Fecha_Vencimiento,
					VGP.fecvence AS Fecha_Vencimiento,
					VGP.nommoneda,
					VGP.memobservacion,
					GETDATE() AS Fecha_Replica,
					1 AS Registro_Activo,
					0 AS Indicador_Poliza_Externa,
					
					--INICIO RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
					
					NULL AS Codigo_Partido,
					NULL AS Identificacion_Bien,
					VGP.contipocobertura AS Codigo_Tipo_Cobertura,
					VGP.conaseguradora AS Codigo_Aseguradora
					
					--FIN RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
					
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
					AND VCB.estpolizacreditobancario <> 'ELI'
					AND VCB.concontratocredito IS NULL
					AND GO1.num_contrato = 0
					AND GO1.num_operacion IS NOT NULL
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
					AND NOT EXISTS (SELECT	1
									FROM	dbo.TMP_POLIZAS TMP
									WHERE	TMP.Codigo_SAP = VGP.conpoliza
										AND TMP.Consecutivo_Operacion_Garantias = GO1.cod_operacion
										AND TMP.Registro_Activo = 1)
											
			END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Ins_Op_Tmp_Pol

					SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al extraer e insertar las pólizas, relacionadas a operaciones, en la tabla temporal. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

				END CATCH
				
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Op_Tmp_Pol
	
	END
		
	--Se carga la información de la tabla temporal de pólizas, con los datos relacionados a los contratos vigentes.
	IF(@piEjecutarParte = 7)
	BEGIN
	
		BEGIN TRANSACTION TRA_Ins_CVig_Tmp_Pol
			BEGIN TRY
				INSERT INTO dbo.TMP_POLIZAS
				  (Codigo_SAP, Tipo_Poliza, Codigo_Oficina_Operacion, Codigo_Moneda_Operacion, Codigo_Producto_Operacion, Numero_Operacion,
				   Numero_Contrato, Consecutivo_Operacion_Garantias, Monto_Poliza, Moneda_Monto_Poliza, Estado_Poliza, Simbolo_Moneda, 
				   Fecha_Vencimiento, Descripcion_Moneda_Monto_Poliza, Detalle_Poliza, Fecha_Replica, Registro_Activo,
				   Indicador_Poliza_Externa, Codigo_Partido, Identificacion_Bien, Codigo_Tipo_Cobertura, Codigo_Aseguradora)
						
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
					VGP.estpoliza,
					VGP.monsigno,
					--CASE 
					--	WHEN VCC.codsenal = 5 THEN VGP.fecvence
					--	ELSE COALESCE(VCC.fecpagadohasta, VGP.fecvence) 
					--END AS Fecha_Vencimiento,
					VGP.fecvence AS Fecha_Vencimiento,
					VGP.nommoneda,
					VGP.memobservacion,
					GETDATE() AS Fecha_Replica,
					1 AS Registro_Activo,
					0 AS Indicador_Poliza_Externa,
					
					--INICIO RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
					
					NULL AS Codigo_Partido,
					NULL AS Identificacion_Bien,
					VGP.contipocobertura AS Codigo_Tipo_Cobertura,
					VGP.conaseguradora
					
					--FIN RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
					
				FROM	dbo.TMP_SAP_VWSGRPOLIZA VGP
					INNER JOIN dbo.TMP_SAP_VWSGRPOLIZACONTRATOCREDITO VCC
					ON VCC.conpoliza = VGP.conpoliza
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_oficina = VCC.codue
					AND GO1.cod_moneda = VCC.conmoneda
					AND GO1.num_contrato = VCC.coccontratocredito
				WHERE	VGP.Registro_Activo = 1
					AND VCC.Registro_Activo = 1
					AND VCC.estpolizacontratocredito <> 'ELI'
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
					AND NOT EXISTS (SELECT	1
									FROM	dbo.TMP_GIROS_CONTRATOS TGC
									WHERE	TGC.Registro_Activo = 1
										AND TGC.Usuario = @psCodigoProceso
										AND TGC.Codigo_SAP = VGP.conpoliza
										AND TGC.Consecutivo_Contrato = GO1.cod_operacion)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.TMP_POLIZAS TMP
									WHERE	TMP.Registro_Activo = 1
										AND TMP.Codigo_SAP = VGP.conpoliza
										AND TMP.Consecutivo_Operacion_Garantias = GO1.cod_operacion)
									
			END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Ins_CVig_Tmp_Pol

					SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al extraer e insertar las pólizas, relacionadas a contratos vigentes, en la tabla temporal. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

				END CATCH
				
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_CVig_Tmp_Pol

	
	END
	
	--Se carga la información de la tabla temporal de pólizas, con los datos relacionados a los contratos vencidos con giros activos.
	IF(@piEjecutarParte = 8)
	BEGIN
	
		BEGIN TRANSACTION TRA_Ins_CVen_Tmp_Pol
			BEGIN TRY
				INSERT INTO dbo.TMP_POLIZAS
				  (Codigo_SAP, Tipo_Poliza, Codigo_Oficina_Operacion, Codigo_Moneda_Operacion, Codigo_Producto_Operacion, Numero_Operacion,
				   Numero_Contrato, Consecutivo_Operacion_Garantias, Monto_Poliza, Moneda_Monto_Poliza, Estado_Poliza, Simbolo_Moneda, 
				   Fecha_Vencimiento, Descripcion_Moneda_Monto_Poliza, Detalle_Poliza, Fecha_Replica, Registro_Activo,
				   Indicador_Poliza_Externa, Codigo_Partido, Identificacion_Bien, Codigo_Tipo_Cobertura, Codigo_Aseguradora)
							
				SELECT	DISTINCT
					VGP.conpoliza,
					VGP.contipopoliza,
					TGC.Oficina_Contrato,
					TGC.Moneda_Contrato AS Moneda_Operacion,
					TGC.Producto_Contrato,
					-1 AS Numero_Operacion,
					TGC.Numero_Contrato AS Numero_Contrato,
					TGC.Consecutivo_Contrato AS Consecutivo_Operacion_Garantias,
					COALESCE(VGP.mtoasegurado, 0) AS Monto_Poliza,
					VGP.conmoneda,
					VGP.estpoliza,
					VGP.monsigno, 
					--COALESCE(TGC.Fecha_Pagado_Hasta, TGC.Fecha_Vencimiento_Poliza),
					VGP.fecvence AS Fecha_Vencimiento,
					VGP.nommoneda,
					VGP.memobservacion,
					GETDATE() AS Fecha_Replica,
					1 AS Registro_Activo,
					0 AS Indicador_Poliza_Externa,
					
					--INICIO RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
					
					NULL AS Codigo_Partido,
					NULL AS Identificacion_Bien,
					VGP.contipocobertura AS Codigo_Tipo_Cobertura,
					VGP.conaseguradora
					
					--FIN RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
					
				FROM	dbo.TMP_GIROS_CONTRATOS TGC 
					INNER JOIN dbo.TMP_SAP_VWSGRPOLIZA VGP
					ON VGP.conpoliza = TGC.Codigo_SAP
				WHERE	TGC.Registro_Activo = 1
					AND TGC.Usuario = @psCodigoProceso
					AND VGP.Registro_Activo = 1
					AND NOT EXISTS (SELECT	1
									FROM	dbo.TMP_POLIZAS TMP
									WHERE	TMP.Codigo_SAP = TGC.Codigo_SAP
										AND TMP.Consecutivo_Operacion_Garantias = TGC.Consecutivo_Contrato
										AND TMP.Registro_Activo = 1)
								
			END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Ins_CVen_Tmp_Pol

					SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al extraer e insertar las pólizas, relacionadas a contratos vencidos con giros activos, en la tabla temporal. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

				END CATCH
				
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_CVen_Tmp_Pol
	
	END
	
	--Se actualiza el indicador de si es una póliza externa y la fecha de vencimiento para las mismas.
	IF(@piEjecutarParte = 9)
	BEGIN
	
		BEGIN TRANSACTION TRA_Act_Pol_Ext
			BEGIN TRY

				UPDATE	TMP
				SET		TMP.Indicador_Poliza_Externa = 1,
						TMP.Fecha_Vencimiento = VGP.fecvence
				FROM	dbo.TMP_POLIZAS TMP
					INNER JOIN dbo.TMP_SAP_POLIZASEXTERNAS SPE
					ON SPE.conpoliza = TMP.Codigo_SAP
					INNER JOIN dbo.TMP_SAP_VWSGRPOLIZA VGP
					ON VGP.conpoliza = SPE.conpoliza
				WHERE	TMP.Registro_Activo = 1
					AND SPE.Registro_Activo = 1
					AND VGP.Registro_Activo = 1
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Pol_Ext

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar el indicador de si es una póliza externa, en la tabla temporal de pólizas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Pol_Ext
	
	END
	
	--INICIO RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas	
	
	--Se actualizan los datos de la hipoteca de la póliza.
	IF(@piEjecutarParte = 10)
	BEGIN
	
		BEGIN TRANSACTION TRA_Act_Hipo_Pol
			BEGIN TRY

				UPDATE	TMP
				SET		TMP.Codigo_Partido = TM1.cod_partido,
						TMP.Identificacion_Bien = TM1.numero_finca
				FROM	dbo.TMP_POLIZAS TMP
					INNER JOIN (SELECT	DISTINCT 
										TS1.conpoliza, 
										TS1.desfolioreal AS Codigo_Finca
								FROM	dbo.TMP_SAP_SGRPOLIZAPATRIMONIAL TS1
								WHERE	TS1.Registro_Activo = 1
									AND CHARINDEX('-', TS1.desfolioreal) > 0
								
								UNION ALL
								
								SELECT DISTINCT 
										TS2.conpoliza, 
										(CAST(TS2.conprovincia AS VARCHAR(2)) + '-' +  TS2.desfolioreal) AS Codigo_Finca
								FROM	dbo.TMP_SAP_SGRPOLIZAPATRIMONIAL TS2
								WHERE	TS2.Registro_Activo = 1
									AND CHARINDEX('-', TS2.desfolioreal) <= 0) SPP
					ON SPP.conpoliza = TMP.Codigo_SAP
					INNER JOIN (SELECT	DISTINCT
										COALESCE((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + '-' + COALESCE(GGR.numero_finca, '') AS Codigo_Garantia,  
										GGR.cod_partido,
										GGR.numero_finca
								FROM	dbo.GAR_GARANTIA_REAL GGR
								WHERE	((GGR.cod_tipo_garantia_real = 1) OR (GGR.cod_tipo_garantia_real = 2))
									AND (GGR.cod_partido >= 1) 
									AND (GGR.cod_partido <= 7)
									AND LEN(LTRIM(RTRIM(GGR.numero_finca))) > 0
								GROUP BY GGR.cod_partido, GGR.numero_finca) TM1
					ON TM1.Codigo_Garantia = SPP.Codigo_Finca
				WHERE	TMP.Registro_Activo = 1

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Hipo_Pol

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar el partido y la finca de las pólizas, en la tabla temporal de pólizas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Hipo_Pol
	
	END
	
	--Se actualizan los datos de la prenda de la póliza.
	IF(@piEjecutarParte = 11)
	BEGIN
	
		BEGIN TRANSACTION TRA_Act_Prenda_Pol
			BEGIN TRY

				UPDATE	TMP
				SET		TMP.Codigo_Partido = NULL,
						TMP.Identificacion_Bien = TM1.num_placa_bien
				FROM	dbo.TMP_POLIZAS TMP
					INNER JOIN dbo.TMP_SAP_VWSGRPOLIZAAUTO SPA
					ON SPA.conpoliza = TMP.Codigo_SAP
					INNER JOIN (SELECT	DISTINCT
										GGR.num_placa_bien,
										LTRIM(RTRIM(GGR.num_placa_bien)) AS Placa_Bien
								FROM	dbo.GAR_GARANTIA_REAL GGR
								WHERE	GGR.cod_tipo_garantia_real = 3
									AND LEN(LTRIM(RTRIM(GGR.num_placa_bien))) > 0
								GROUP BY GGR.num_placa_bien) TM1
					ON TM1.Placa_Bien = SPA.cocplaca	
				WHERE	TMP.Registro_Activo = 1
					AND SPA.Registro_Activo = 1

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Prenda_Pol

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación de la prenda de las pólizas, en la tabla temporal de pólizas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Prenda_Pol
	
	END

	--Se actualizan los datos de otras prendas de la póliza.
	IF(@piEjecutarParte = 12)
	BEGIN
	
		BEGIN TRANSACTION TRA_Act_OPrenda_Pol
			BEGIN TRY

				UPDATE	TMP
				SET		TMP.Codigo_Partido = NULL,
						TMP.Identificacion_Bien = TM1.num_placa_bien
				FROM	dbo.TMP_POLIZAS TMP
					INNER JOIN dbo.TMP_SAP_SGRPOLIZAOTRO SPO
					ON SPO.conpoliza = TMP.Codigo_SAP
					INNER JOIN (SELECT	DISTINCT
										GGR.num_placa_bien
								FROM	dbo.GAR_GARANTIA_REAL GGR
								WHERE	GGR.cod_tipo_garantia_real = 3
									AND LEN(LTRIM(RTRIM(GGR.num_placa_bien))) > 0
								GROUP BY GGR.num_placa_bien) TM1
					ON TM1.num_placa_bien = SPO.cocplaca	
				WHERE	TMP.Registro_Activo = 1
					AND TMP.Identificacion_Bien IS NULL
					AND SPO.Registro_Activo = 1

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_OPrenda_Pol

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación de otras prendas de las pólizas, en la tabla temporal de pólizas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_OPrenda_Pol
		
	END
	
	--FIN RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
	
	--Se actualizan los campos del monto de la póliza y fecha de vencimiento anterior, de las pólizas existentes.
	IF(@piEjecutarParte = 13)
	BEGIN
	
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
	
	END

	--Se setea el indicador del registro como si ninguna póliza existiera
	--Se actualizan los campos de las pólizas existentes y se habilitan las que existan en los dos sistemas
	IF(@piEjecutarParte = 14)
	BEGIN
	
		BEGIN TRANSACTION TRA_Act_Polizas
			BEGIN TRY

				UPDATE	dbo.GAR_POLIZAS
				SET		Estado_Registro = 0
				
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
						GPO.Indicador_Poliza_Externa = TMP.Indicador_Poliza_Externa,
						
						--INICIO RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
						
						GPO.Codigo_Partido = TMP.Codigo_Partido,
						GPO.Identificacion_Bien = TMP.Identificacion_Bien,
						GPO.Codigo_Tipo_Cobertura = TMP.Codigo_Tipo_Cobertura,
						GPO.Codigo_Aseguradora = TMP.Codigo_Aseguradora
						
						--FIN RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas

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
	
	END

	--Se insertan las pólizas nuevas
	IF(@piEjecutarParte = 15)
	BEGIN
	
		BEGIN TRANSACTION TRA_Ins_Polizas
			BEGIN TRY

				INSERT	INTO dbo.GAR_POLIZAS (Codigo_SAP, cod_operacion, Tipo_Poliza, Monto_Poliza, 
											  Moneda_Monto_Poliza, Fecha_Vencimiento, Cedula_Acreedor, 
											  Nombre_Acreedor, Descripcion_Moneda_Monto_Poliza, Simbolo_Moneda,
											  Detalle_Poliza, Estado_Poliza, Estado_Registro, Fecha_Inserto, Fecha_Replica,
											  Monto_Poliza_Anterior, Fecha_Vencimiento_Anterior, Monto_Poliza_Colonizado,
											  Indicador_Poliza_Externa, Codigo_Partido, Identificacion_Bien, Codigo_Tipo_Cobertura,
											  Codigo_Aseguradora)

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
					TMP.Fecha_Vencimiento, 
					CASE
						WHEN TMP.Moneda_Monto_Poliza = 2 THEN ISNULL((TMP.Monto_Poliza * @vdTipo_Cambio), 0)
						ELSE ISNULL(TMP.Monto_Poliza, 0)
					END AS Monto_Poliza_Colonizado,
					TMP.Indicador_Poliza_Externa,
					
					--INICIO RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
					
					TMP.Codigo_Partido,
					TMP.Identificacion_Bien,
					TMP.Codigo_Tipo_Cobertura,
					TMP.Codigo_Aseguradora
					
					--FIN RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas

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
	
	END

	--INICIO RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
	
	
	--SE DEBEN ELIMINAR LAS COBERTURAS RELACONADAS Y LAS COBERTURAS
	
	--Se carga la información referentes a las coberturas.
	IF(@piEjecutarParte = 16)
	BEGIN
	
		BEGIN TRANSACTION TRA_Ins_Cober
			BEGIN TRY
				
				INSERT	INTO dbo.GAR_COBERTURAS
						(Codigo_Tipo_Cobertura, Codigo_Cobertura, Codigo_Tipo_Poliza, Codigo_Clase_Poliza, Codigo_Grupo_Poliza, 
						 Codigo_Moneda_Tipo_Poliza, Codigo_Aseguradora, Descripcion_Cobertura, Descripcion_Corta_Cobertura, 
						 Indicador_Obligatoria)
				
				SELECT	DISTINCT 
					TSS.Codigo_Tipo_Cobertura, 
					TSS.Codigo_Cobertura, 
					TSP.Codigo_Tipo_Poliza,
					TSP.Codigo_Clase_Poliza,
					TSP.Codigo_Grupo_Poliza,
					TSP.Codigo_Moneda,
					TSP.Codigo_Aseguradora,
					TSS.Descripcion_Cobertura, 
					TSS.Descripcion_Corta_Cobertura,
					TSS.Indicador_Obligatoria
					
				FROM	dbo.TMP_SAP_SGRCOBERTURAS TSS
					INNER JOIN dbo.TMP_SAP_SGRTIPOS_POLIZA TSP
					ON TSP.Codigo_Tipo_Cobertura = TSS.Codigo_Tipo_Cobertura
				WHERE	TSS.Registro_Activo = 1
					AND TSP.Registro_Activo = 1
					AND EXISTS (SELECT	1
								FROM	dbo.CAT_ELEMENTO CE1
								WHERE	CE1.cat_catalogo = @ciCatalogo_Tipo_Poliza
									AND CE1.cat_campo = CONVERT(VARCHAR(5), TSP.Codigo_Tipo_Poliza))	
						
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Cober

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al extraer e insertar las coberturas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
				
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Cober
	
	END

	--Se carga la información de la tabla de coberturas asociadas a las pólizas.
	IF(@piEjecutarParte = 17)
	BEGIN
	
		BEGIN TRANSACTION TRA_Ins_Cober_Pol
			BEGIN TRY
				
				INSERT INTO dbo.GAR_COBERTURAS_POLIZAS
                      (Codigo_SAP, cod_operacion, Codigo_Tipo_Cobertura, Codigo_Cobertura, Codigo_Tipo_Poliza)

				SELECT	DISTINCT
					GP1.Codigo_SAP,
					GP1.cod_operacion,
					TSC.Codigo_Tipo_Cobertura,
					TSC.Codigo_Cobertura,
					GP1.Tipo_Poliza
					
				FROM	dbo.TMP_SAP_COBERTURAS_POLIZAS TSC
					INNER JOIN dbo.GAR_POLIZAS GP1
					ON GP1.Codigo_SAP = TSC.Codigo_SAP
					AND GP1.Codigo_Tipo_Cobertura = TSC.Codigo_Tipo_Cobertura
				WHERE	TSC.Registro_Activo = 1
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Cober_Pol

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al extraer e insertar las coberturas relacionadas a las pólizas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
				
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Cober_Pol

	
	END

	--FIN RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas

	--Se actualiza la relación entre la póliza y la garantía, para inhabilitar aquellas cuya póliza está cancelada o eliminada
	IF(@piEjecutarParte = 18)
	BEGIN
	
		--INICIO RQ_MANT_2015111010495738_00610
		BEGIN TRANSACTION TRA_Activar_Rel_Pol
			BEGIN TRY

				UPDATE	dbo.GAR_POLIZAS_RELACIONADAS
				SET		Estado_Registro = 1
				
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Activar_Rel_Pol

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar el estado del registro de las relaciones entre las pólizas y las garantías asociadas a una operación/contrato. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Activar_Rel_Pol
		--FIN RQ_MANT_2015111010495738_00610

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

		--Se desactivan aquellos registros cuya relación entre la póliza y la operación no exista en el SAP
		BEGIN TRANSACTION TRA_Act_Relac_Pol
			BEGIN TRY

				UPDATE	GPR
				SET		Estado_Registro = 0
				FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
				WHERE	NOT EXISTS (SELECT	1
									FROM	dbo.GAR_POLIZAS GPO
									WHERE	GPO.Codigo_SAP = GPR.Codigo_SAP
										AND GPO.cod_operacion = GPR.cod_operacion)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Relac_Pol

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar el estado del registro de las relaciones entre las pólizas y las garantías asociadas a una operación/contrato cuya relación no existe en el SAP. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Relac_Pol
	
	END

	
END