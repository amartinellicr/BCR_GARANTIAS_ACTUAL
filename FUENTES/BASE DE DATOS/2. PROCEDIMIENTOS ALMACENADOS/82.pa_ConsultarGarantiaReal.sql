USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Consultar_Garantia_Real', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Consultar_Garantia_Real;
GO


CREATE PROCEDURE [dbo].[Consultar_Garantia_Real]
	@piOperacion		BIGINT,
	@piGarantia			BIGINT,
	@psCedula_Usuario	VARCHAR(30),
	@psRespuesta		VARCHAR(1000) OUTPUT
AS

/*****************************************************************************************************************************************************
	<Nombre>Consultar_Garantia_Real</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtiene los datos de una garantía real específica.
	</Descripción>
	<Entradas>
			@piOperacion			= Consecutivo de la operación al a que está asociada la garantía real consultada. Este el dato llave usado para la búsqueda.
  			@piGarantia				= Consecutivo de la garantía real consultada. Este el dato llave usado para la búsqueda.
			@psCedula_Usuario		= Identificación del usuario que realiza la consulta. 
									  Este es dato llave usado para la búsqueda de los registros que deben 
									  ser eliminados de la tabla temporal.
	</Entradas>
	<Salidas>
		@psRespuesta				= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>22/08/2006</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>2.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>MODIFICACIONES EN EXTRACCIONES DE DATOS Y LINEAS DE CREDITO BCR GARANTIAS ORIGINAL</Requerimiento>
			<Fecha>02/12/2010</Fecha>
			<Descripción>
				Debido a las actualizaciones sufridas en otros procedimientos almacenados, en donde se logra determinar 
				con mayor certeza las garantías asociadas a operaciones o contratos, se elimina el uso del indicador "cod_estado", 
				esto debido a que no permite modificar las garantías cuyo estado es 2 pero que ya se determinó que deben estar activas.
		</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento> 
					008 Req_Garantías Reales Partido y Finca, Siebel No. 1-21317220.
					009 Req_Validaciones Indicador Inscripción, Siebel No. 1-21317176.
					012 Req_Garantías Real Tipo de bien, Sibel No. 1-21410161.
			</Requerimiento>
			<Fecha>27/07/2012</Fecha>
			<Descripción>
					Se ajusta el procedimiento almacenado con la finalidad de obtener las inconsistencias
					relacionadas a los campos evaluados en los requerimientos involucrados.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Req_Mantenimiento Valuaciones, Siebel No. 1-21537427</Requerimiento>
			<Fecha>29/05/2013</Fecha>
			<Descripción>
				Se ajusta el procedimiento almacenado para que extraíga la información correspondiente al avalúa más reciente.
				También se elimina la sección de la obtención de las inconsistencias, pasando esta a un nivel 
				de capa de negocio.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
				Cambios en la Extracción de los campos % de Aceptación, Indicador de Inscripción 
				y Actualización de Fecha de Valuación en Garantías Relacionadas, Siebel 1-24206841.
			</Requerimiento>
			<Fecha>24/03/2014</Fecha>
			<Descripción>
				Se extrae el valor del campo correspondiente a la fecha de valuación registrada en el SICC, 
				esto dentro de la tabla de valuaciones reales.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Actualizacion de procedimientos almacenados, Siebel No. 1-24307807.
			</Requerimiento>
			<Fecha>13/05/2014</Fecha>
			<Descripción>
					Se elimina la referencia al BNX, mediante el uso del link server, por la referencia a una base de datos local. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Ajustes por Fallas Técnicas, Siebel No. 1-24331191.
			</Requerimiento>
			<Fecha>28/05/2014</Fecha>
			<Descripción>
					Se modifica la forma en como se extrae la información del SICC, tomándo en 
					cuenta que las operación esté activa o el contrato vigente o vencido con giros 
					activos. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Leonardo Cortés Mora, Lidersoft Internacional S.A</Autor>
			<Requerimiento>
				Actualización de procedimientos almacenado, Siebel No. 1-24350791.			
			</Requerimiento>
			<Fecha>18/06/2014</Fecha>
			<Descripción>
					Se agregan los campos de Usuario_Modifico, Fecha_Modificacion, Fecha_Inserto,
					Fecha_Replica. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Req_Pólizas, Siebel No. 1-24342731</Requerimiento>
			<Fecha>19/06/2014</Fecha>
			<Descripción>
					Se agregan los campos referentes a la póliza asociada. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas S.A.</Autor>
			<Requerimiento>Requerimiento de Placas Alfauméricas</Requerimiento>
			<Fecha>01/07/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
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
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Incidente: 2015092810472305 - Solicitud de pase emergencia optimización de procesos 10472294</Requerimiento>
			<Fecha>28/09/2015</Fecha>
			<Descripción>
				Se realiza una optimización general, en donde se crean índices en estructuras y tablas nuevas. 
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

	-- Declaración de variables
	DECLARE @viCatTipoGarReal			SMALLINT, -- Catálogo de tipos de garantías reales = 23
			@viCatTipoBien				SMALLINT, -- Catálogo de tipos de bien = 12
			@viCatTipoMitigador			SMALLINT, -- Catálogo de tipos de mitigadores de riesgo = 22
			@viCatTipoDocumentoLegal	SMALLINT, -- Catálogo de tipos de documentos legales = 8
			@viCatInscripcion			SMALLINT, -- Catálogo de indicadores de inscripción = 9
			@viCatGradoGravamen			SMALLINT, -- Catálogo de grados de gravamen = 10
			@viCatOperacionEspecial		SMALLINT, -- Catálogo de tipos operaciones especiales = 11
			@viCatTipoPersona			SMALLINT, -- Catálogo de tipos de persona = 1
			@viCatTipoLiquidez			SMALLINT, -- Catálogo de tipos de liquidez = 13
			@viCatTipoTenencia			SMALLINT, -- Catálogo de tipos de tenencia = 14
			@viCatTipoMoneda			SMALLINT, -- Catálogo de tipos de moneda = 15
			@viCatParametrosCalculo		SMALLINT, -- Catálogo de los parámetros usados para le cálculo del monto de la tasación actualizada del no terreno = 28
			@viCatTiposPolizasSap		SMALLINT, -- Catálogo de los tipos de pólizas SAP.
			@vsCodigo_Bien				VARCHAR(30), -- Código del bien que será usado para obtener las operaciones en la cuales participa.
			@vbObtener_Operaciones		BIT, -- Indica si se deben obtener las operaciones en las cuales participa la garantía.
			@vdtFecha_Actual			DATETIME, --Fecha actual del sistema
			@vdtFecha_Avaluo			DATETIME, --Fecha del avalúo más reciente
			@vdMontoAvaluoSICC			DECIMAL(14,2), --Monto mínimo del avalúo de una garantía
			@vdPorcentajeInferior		DECIMAL(5,2), -- Porcentaje correpondiente al límite inferior
			@vdPorcentajeIntermedio		DECIMAL(5,2), -- Porcentaje correpondiente al límite intermedio
			@vdPorcentajeSuperior		DECIMAL(5,2), -- Porcentaje correpondiente al límite superior
			@viAnnoInferior				SMALLINT, -- Año correpondiente al límite inferior
			@viAnnoIntermedio			SMALLINT, -- Año correpondiente al límite intermedio/superior
			@viTipoBien					SMALLINT,  -- Código del tipo de bien asignado a la garantía
			@viFechaActualEntera		INT, --Corresponde al a fecha actual en formato numérico.
			@viFechaValuacionEntera		INT, -- Fecha de valuación registrada enel SICC
			@vsNombreUsuarioModifico	VARCHAR(100) --Nombre el usuario que modifico la garantia			
			

	--Inicialización de variables
	--Se asignan los códigos de los catálogos  
	SET @viCatTipoPersona			= 1
	SET @viCatTipoDocumentoLegal	= 8
	SET @viCatInscripcion			= 9
    SET @viCatGradoGravamen			= 10
	SET @viCatOperacionEspecial		= 11
	SET @viCatTipoBien				= 12		
	SET @viCatTipoLiquidez			= 13
	SET @viCatTipoTenencia			= 14
	SET @viCatTipoMoneda			= 15
	SET @viCatTipoMitigador			= 22
	SET	@viCatTipoGarReal			= 23
	SET @viCatParametrosCalculo		= 28
	SET	@viCatTiposPolizasSap		= 29

	SET @vsCodigo_Bien	= (SELECT	CASE GGR.cod_tipo_garantia_real  
										WHEN 1 THEN COALESCE((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + '-' + COALESCE(GGR.numero_finca, '')  
										WHEN 2 THEN COALESCE((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + '-' + COALESCE(GGR.numero_finca, '') 
										WHEN 3 THEN COALESCE(GGR.cod_clase_bien, '') + '-' + COALESCE(GGR.num_placa_bien, '')
									END
							FROM	dbo.GAR_GARANTIA_REAL GGR 
							WHERE	GGR.cod_garantia_real = @piGarantia)

	SET	@vdtFecha_Actual = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	
	SET @viFechaActualEntera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	
	SET @viFechaValuacionEntera =	(	SELECT	MAX(TMP.prmgt_pfeavaing)
										FROM	
										(	SELECT	MAX(MGT.prmgt_pfeavaing) AS prmgt_pfeavaing
											FROM	dbo.GAR_SICC_PRMGT MGT
											WHERE	MGT.prmgt_estado = 'A'
												AND MGT.prmgt_pfeavaing > 0
												AND EXISTS (SELECT	1
															FROM	dbo.GAR_GARANTIA_REAL GGR
															WHERE	GGR.cod_garantia_real = @piGarantia
																AND MGT.prmgt_pcoclagar	= GGR.cod_clase_garantia
																AND MGT.prmgt_pnu_part	= CASE
																							WHEN GGR.cod_clase_garantia BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
																							ELSE GGR.cod_partido
																						  END	
																AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
																AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, ''))
												AND EXISTS (SELECT	1
															FROM	dbo.GAR_SICC_PRMOC MOC
															WHERE	MOC.prmoc_pse_proces = 1
																AND MOC.prmoc_estado = 'A'
																AND MOC.prmoc_pnu_contr = 0
																AND ((MOC.prmoc_pcoctamay > 815)
																	OR (MOC.prmoc_pcoctamay < 815))
																AND MOC.prmoc_pco_ofici = MGT.prmgt_pco_ofici
																AND MOC.prmoc_pco_moned = MGT.prmgt_pco_moned
																AND MOC.prmoc_pco_produ = MGT.prmgt_pco_produ
																AND MOC.prmoc_pnu_oper = MGT.prmgt_pnu_oper)

											UNION ALL

											SELECT	MAX(MGT.prmgt_pfeavaing) AS prmgt_pfeavaing
											FROM	dbo.GAR_SICC_PRMGT MGT
											WHERE	MGT.prmgt_estado = 'A'
												AND MGT.prmgt_pfeavaing > 0
												AND EXISTS (SELECT	1
															FROM	dbo.GAR_GARANTIA_REAL GGR
															WHERE	GGR.cod_garantia_real = @piGarantia
																AND MGT.prmgt_pcoclagar	= GGR.cod_clase_garantia
																AND MGT.prmgt_pnu_part	= CASE
																							WHEN GGR.cod_clase_garantia BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
																							ELSE GGR.cod_partido
																						  END	
																AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
																AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, ''))
												AND EXISTS (SELECT	1
															FROM	dbo.GAR_SICC_PRMCA MCA
															WHERE	MCA.prmca_estado = 'A'
																AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
																AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
																AND MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper
																AND MGT.prmgt_pco_produ = 10)

											UNION ALL

											SELECT	MAX(MGT.prmgt_pfeavaing) AS prmgt_pfeavaing
											FROM	dbo.GAR_SICC_PRMGT MGT
											WHERE	MGT.prmgt_estado = 'A'
												AND MGT.prmgt_pfeavaing > 0
												AND EXISTS (SELECT	1
															FROM	dbo.GAR_GARANTIA_REAL GGR
															WHERE	GGR.cod_garantia_real = @piGarantia
																AND MGT.prmgt_pcoclagar	= GGR.cod_clase_garantia
																AND MGT.prmgt_pnu_part	= CASE
																							WHEN GGR.cod_clase_garantia BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
																							ELSE GGR.cod_partido
																						  END	
																AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
																AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, ''))
												AND EXISTS (SELECT	1
															FROM	dbo.GAR_SICC_PRMCA MCA
															WHERE	MCA.prmca_estado = 'A'
																AND MCA.prmca_pfe_defin < @viFechaActualEntera
																AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
																AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
																AND MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper
																AND MGT.prmgt_pco_produ = 10
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMOC MC1
																			WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																				AND MC1.prmoc_estado = 'A'	
																				AND ((MC1.prmoc_pcoctamay > 815)
																					OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																				AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																				AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																				AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))

											GROUP BY MGT.prmgt_pcoclagar, MGT.prmgt_pnu_part, MGT.prmgt_pnuidegar, MGT.prmgt_pnuide_alf) TMP
										WHERE TMP.prmgt_pfeavaing IS NOT NULL)

	SET @vdtFecha_Avaluo =	CASE 
								WHEN @viFechaValuacionEntera = 0 THEN NULL
								WHEN ISDATE(CONVERT(VARCHAR(10), @viFechaValuacionEntera)) = 1 THEN CONVERT(VARCHAR(10), @viFechaValuacionEntera,103)
								ELSE NULL
							END
							
	SET	@vdMontoAvaluoSICC	=	(	SELECT	COALESCE(MIN(TMP.prmgt_pmoavaing), 0)
									FROM	
									(	SELECT	MIN(MGT.prmgt_pmoavaing) AS prmgt_pmoavaing
										FROM	dbo.GAR_SICC_PRMGT MGT
										WHERE	MGT.prmgt_estado = 'A'
											AND MGT.prmgt_pfeavaing = @viFechaValuacionEntera
											AND MGT.prmgt_pfeavaing > 0
											AND EXISTS (SELECT	1
														FROM	dbo.GAR_GARANTIA_REAL GGR
														WHERE	GGR.cod_garantia_real = @piGarantia
															AND MGT.prmgt_pcoclagar	= GGR.cod_clase_garantia
															AND MGT.prmgt_pnu_part	= CASE
																						WHEN GGR.cod_clase_garantia BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
																						ELSE GGR.cod_partido
																					  END	
																AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
																AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, ''))
											AND EXISTS (SELECT	1
														FROM	dbo.GAR_SICC_PRMOC MOC
														WHERE	MOC.prmoc_pse_proces = 1
															AND MOC.prmoc_estado = 'A'
															AND MOC.prmoc_pnu_contr = 0
															AND ((MOC.prmoc_pcoctamay > 815)
																OR (MOC.prmoc_pcoctamay < 815))
															AND MOC.prmoc_pco_ofici = MGT.prmgt_pco_ofici
															AND MOC.prmoc_pco_moned = MGT.prmgt_pco_moned
															AND MOC.prmoc_pco_produ = MGT.prmgt_pco_produ
															AND MOC.prmoc_pnu_oper = MGT.prmgt_pnu_oper)

										UNION ALL

										SELECT	MIN(MGT.prmgt_pmoavaing) AS prmgt_pmoavaing
										FROM	dbo.GAR_SICC_PRMGT MGT
										WHERE	MGT.prmgt_estado = 'A'
											AND MGT.prmgt_pfeavaing = @viFechaValuacionEntera
											AND MGT.prmgt_pfeavaing > 0
											AND EXISTS (SELECT	1
														FROM	dbo.GAR_GARANTIA_REAL GGR
														WHERE	GGR.cod_garantia_real = @piGarantia
															AND MGT.prmgt_pcoclagar	= GGR.cod_clase_garantia
															AND MGT.prmgt_pnu_part	= CASE
																						WHEN GGR.cod_clase_garantia BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
																						ELSE GGR.cod_partido
																					  END	
																AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
																AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, ''))
											AND EXISTS (SELECT	1
														FROM	dbo.GAR_SICC_PRMCA MCA
														WHERE	MCA.prmca_estado = 'A'
															AND MCA.prmca_pfe_defin >= @viFechaActualEntera
															AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
															AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
															AND MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper
															AND MGT.prmgt_pco_produ = 10)

										UNION ALL

										SELECT	MIN(MGT.prmgt_pmoavaing) AS prmgt_pmoavaing
										FROM	dbo.GAR_SICC_PRMGT MGT
										WHERE	MGT.prmgt_estado = 'A'
											AND MGT.prmgt_pfeavaing = @viFechaValuacionEntera
											AND MGT.prmgt_pfeavaing > 0
											AND EXISTS (SELECT	1
														FROM	dbo.GAR_GARANTIA_REAL GGR
														WHERE	GGR.cod_garantia_real = @piGarantia
															AND MGT.prmgt_pcoclagar	= GGR.cod_clase_garantia
															AND MGT.prmgt_pnu_part	= CASE
																						WHEN GGR.cod_clase_garantia BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
																						ELSE GGR.cod_partido
																					  END	
																AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
																AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, ''))
											AND EXISTS (SELECT	1
														FROM	dbo.GAR_SICC_PRMCA MCA
														WHERE	MCA.prmca_estado = 'A'
															AND MCA.prmca_pfe_defin < @viFechaActualEntera
															AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
															AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
															AND MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper
															AND MGT.prmgt_pco_produ = 10
															AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))

										GROUP BY MGT.prmgt_pcoclagar, MGT.prmgt_pnu_part, MGT.prmgt_pnuidegar, MGT.prmgt_pnuide_alf, MGT.prmgt_pfeavaing) TMP
									WHERE TMP.prmgt_pmoavaing IS NOT NULL)
	
		
	
	SET @vdPorcentajeInferior = (SELECT		MIN(CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P','')))) 
								 FROM		dbo.CAT_ELEMENTO 
								 WHERE		cat_catalogo = @viCatParametrosCalculo
									AND cat_campo LIKE '%P')

	SET @vdPorcentajeSuperior = (SELECT		MAX(CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))))  
								 FROM		dbo.CAT_ELEMENTO 
								 WHERE		cat_catalogo = @viCatParametrosCalculo
									AND cat_campo LIKE '%P')

	SET @vdPorcentajeIntermedio = (SELECT	CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))) 
								   FROM		dbo.CAT_ELEMENTO 
								   WHERE	cat_catalogo = @viCatParametrosCalculo
									AND CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))) > @vdPorcentajeInferior
									AND CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))) < @vdPorcentajeSuperior
									AND cat_campo LIKE '%P')


	SET @viAnnoInferior = (SELECT	MIN(CONVERT(SMALLINT, (REPLACE(RTRIM(LTRIM(cat_campo)),'A','')))) 
						   FROM		dbo.CAT_ELEMENTO 
						   WHERE	cat_catalogo = @viCatParametrosCalculo
									AND cat_campo LIKE '%A')

	SET @viAnnoIntermedio = (SELECT	MAX(CONVERT(SMALLINT, (REPLACE(RTRIM(LTRIM(cat_campo)),'A','')))) 
						   FROM		dbo.CAT_ELEMENTO 
						   WHERE	cat_catalogo = @viCatParametrosCalculo
									AND cat_campo LIKE '%A')

	SET	@viTipoBien =  (SELECT	COALESCE(GGR.cod_tipo_bien, -1)
						FROM	dbo.GAR_GARANTIA_REAL GGR 
						WHERE	GGR.cod_garantia_real = @piGarantia)

	SET @vsNombreUsuarioModifico = (SELECT	COALESCE(SU.DES_USUARIO,'') 
									FROM	SEG_USUARIO SU
										INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
										ON SU.COD_USUARIO = GGR.Usuario_Modifico COLLATE DATABASE_DEFAULT
									WHERE	GGR.cod_garantia_real = @piGarantia )		

	/************************************************************************************************
	 *                                                                                              * 
	 *								INICIO DE LA SELECCION DE DATOS		     						*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/
	
	SELECT (
		SELECT DISTINCT	
			GRO.cod_operacion							AS "cod_operacion",
			GRO.cod_garantia_real						AS "cod_garantia_real", 
			GGR.cod_tipo_garantia						AS "cod_tipo_garantia", 
			GGR.cod_clase_garantia						AS "cod_clase_garantia", 
			GGR.cod_tipo_garantia_real					AS "cod_tipo_garantia_real", 
			CE1.cat_descripcion							AS "des_tipo_garantia_real", 
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN 'Partido: ' + COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + ' - Finca: ' + COALESCE(LTRIM(RTRIM(GGR.numero_finca)),'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN 'Partido: ' + COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + ' - Finca: ' + COALESCE(LTRIM(RTRIM(GGR.numero_finca)),'') + ' - Grado: ' + COALESCE(CONVERT(VARCHAR(2),GGR.cod_grado),'') + ' - Cédula Hipotecaria: ' + COALESCE(CONVERT(VARCHAR(2),GGR.cedula_hipotecaria),'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN 'Clase Bien: ' + COALESCE(GGR.cod_clase_bien,'') + ' - Número Placa: ' + COALESCE(LTRIM(RTRIM(GGR.num_placa_bien)),'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN 'Número Placa: ' + COALESCE(LTRIM(RTRIM(GGR.num_placa_bien)),'') 
			END											AS "garantia_real", 
			GGR.cod_partido								AS "cod_partido", 
			COALESCE(LTRIM(RTRIM(GGR.numero_finca)),'')					AS "numero_finca", 
			COALESCE(GGR.cod_grado,'')					AS "cod_grado", 
			COALESCE(GGR.cedula_hipotecaria,'')			AS "cedula_hipotecaria", 
			COALESCE(GGR.cod_clase_bien,'')				AS "cod_clase_bien", 
			COALESCE(LTRIM(RTRIM(GGR.num_placa_bien)),'')				AS "num_placa_bien", 
			COALESCE(GGR.cod_tipo_bien,-1)				AS "cod_tipo_bien", 
			COALESCE(GRO.cod_tipo_mitigador,-1)			AS "cod_tipo_mitigador", 
			COALESCE(GRO.cod_tipo_documento_legal,-1)		AS "cod_tipo_documento_legal", 
			COALESCE(GRO.monto_mitigador,0)				AS "monto_mitigador", 
			COALESCE(GRO.cod_inscripcion,-1)				AS "cod_inscripcion", 
			CONVERT(VARCHAR(10), (COALESCE(GRO.fecha_presentacion,'1900-01-01')), 103)	AS "fecha_presentacion", 
			COALESCE(GRO.porcentaje_responsabilidad,0)	AS "porcentaje_responsabilidad", 
			CASE 
				WHEN GRO.cod_grado_gravamen IS NULL THEN -1 
				WHEN GRO.cod_grado_gravamen < 1 THEN -1 
				ELSE GRO.cod_grado_gravamen 
			END											AS "cod_grado_gravamen", 
			COALESCE(GRO.cod_operacion_especial,0)		AS "cod_operacion_especial",
			CONVERT(VARCHAR(10), (COALESCE(GRO.fecha_constitucion,'1900-01-01')), 103)AS "fecha_constitucion",
			CONVERT(VARCHAR(10), (COALESCE(GRO.fecha_vencimiento,'1900-01-01')), 103)	AS "fecha_vencimiento", 
			CASE GRO.cod_tipo_acreedor 
				WHEN NULL THEN 2 
				WHEN -1 THEN 2 
				ELSE GRO.cod_tipo_acreedor 
			END											AS "cod_tipo_acreedor", 
			COALESCE(GRO.cedula_acreedor,'')				AS "ced_acreedor", 
			CASE GRO.cod_liquidez 
				WHEN NULL THEN -1 
				WHEN 0 THEN -1 
				ELSE GRO.cod_liquidez 
			END											AS "cod_liquidez", 
			CASE GRO.cod_tenencia 
				WHEN NULL THEN -1 
				WHEN 0 THEN -1 
				ELSE GRO.cod_tenencia 
			END											AS "cod_tenencia", 
			CASE GRO.cod_moneda 
				WHEN NULL THEN -1 
				WHEN 0 THEN -1 
				ELSE GRO.cod_moneda 
			END											AS "cod_moneda", 
			CONVERT(VARCHAR(10), (COALESCE(GRO.fecha_prescripcion,'1900-01-01')), 103)	AS "fecha_prescripcion",
			GRO.cod_estado								AS "cod_estado",
			CONVERT(VARCHAR(10), (COALESCE(VGR.fecha_valuacion,'1900-01-01')), 103)
														AS "fecha_valuacion",

			CASE 
				WHEN (COALESCE(VGR.monto_ultima_tasacion_terreno, 0) = 0)
					AND  (COALESCE(VGR.monto_ultima_tasacion_no_terreno, 0) = 0) THEN VGR.monto_total_avaluo
				ELSE (COALESCE(VGR.monto_ultima_tasacion_terreno, 0) + COALESCE(VGR.monto_ultima_tasacion_no_terreno, 0))
			END
														AS "monto_total_avaluo",

		    CASE GGR.cod_tipo_bien
				 WHEN NULL THEN '-'                                                                                                                                                                      
				 ELSE (SELECT CE2.cat_campo + '-' + CE2.cat_descripcion FROM CAT_ELEMENTO CE2  WHERE CE2.cat_campo = (CONVERT(VARCHAR(5), GGR.cod_tipo_bien))   AND CE2.cat_catalogo = @viCatTipoBien )  
			END											AS "des_tipo_bien",

			CASE GRO.cod_tipo_mitigador
				 WHEN NULL THEN '-'                                                                                                                                                                          
				 ELSE (SELECT CE3.cat_campo + '-' + CE3.cat_descripcion FROM CAT_ELEMENTO CE3  WHERE CE3.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tipo_mitigador))  AND CE3.cat_catalogo = @viCatTipoMitigador )
			END											AS "des_tipo_mitigador",

			CASE GRO.cod_tipo_documento_legal
				 WHEN NULL THEN '-'                                                                                                                                                                          
				 ELSE (SELECT CE4.cat_campo + '-' + CE4.cat_descripcion FROM CAT_ELEMENTO CE4  WHERE CE4.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tipo_documento_legal))  AND CE4.cat_catalogo = @viCatTipoDocumentoLegal )
			END											AS "des_tipo_documento",

			CASE GRO.cod_inscripcion
				 WHEN NULL THEN '-'                                                                                                                                                                          
				 ELSE (SELECT CE5.cat_campo + '-' + CE5.cat_descripcion FROM CAT_ELEMENTO CE5  WHERE CE5.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_inscripcion)) AND CE5.cat_catalogo = @viCatInscripcion)
			END											AS "des_tipo_inscripcion",

			CASE 
				WHEN GRO.cod_grado_gravamen IS NULL THEN '-' 
				WHEN GRO.cod_grado_gravamen > 3 THEN (SELECT CE6.cat_campo + '-' + CE6.cat_descripcion FROM CAT_ELEMENTO CE6  WHERE CE6.cat_campo = '4' AND CE6.cat_catalogo = @viCatGradoGravamen) 
				WHEN GRO.cod_grado_gravamen < 1 THEN '-' 
				ELSE (SELECT CE6.cat_campo + '-' + CE6.cat_descripcion FROM CAT_ELEMENTO CE6  WHERE CE6.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_grado_gravamen)) AND CE6.cat_catalogo = @viCatGradoGravamen)  
			END											AS "des_tipo_grado_gravamen",

			CASE GRO.cod_operacion_especial
				WHEN NULL THEN (SELECT CE7.cat_campo + '-' + CE7.cat_descripcion FROM CAT_ELEMENTO CE7  WHERE CE7.cat_campo = '0' AND CE7.cat_catalogo = @viCatOperacionEspecial)   
				WHEN -1 THEN '-'
				ELSE (SELECT CE7.cat_campo + '-' + CE7.cat_descripcion FROM CAT_ELEMENTO CE7  WHERE CE7.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_operacion_especial)) AND CE7.cat_catalogo = @viCatOperacionEspecial)     
			END											AS "des_tipo_operacion_especial",

			CASE GRO.cod_tipo_acreedor 
				WHEN NULL THEN (SELECT CE8.cat_campo + '-' + CE8.cat_descripcion FROM CAT_ELEMENTO CE8  WHERE CE8.cat_campo = '2' AND CE8.cat_catalogo = @viCatTipoPersona)      
				WHEN -1 THEN (SELECT CE8.cat_campo + '-' + CE8.cat_descripcion FROM CAT_ELEMENTO CE8  WHERE CE8.cat_campo = '2' AND CE8.cat_catalogo = @viCatTipoPersona)  
				ELSE (SELECT CE8.cat_campo + '-' + CE8.cat_descripcion FROM CAT_ELEMENTO CE8  WHERE CE8.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tipo_acreedor)) AND CE8.cat_catalogo = @viCatTipoPersona) 
			END											AS "des_tipo_persona",

			CASE GRO.cod_liquidez 
				WHEN NULL THEN '-'      
				WHEN -1 THEN '-'  
				ELSE (SELECT CE9.cat_campo + '-' + CE9.cat_descripcion FROM CAT_ELEMENTO CE9  WHERE CE9.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_liquidez)) AND CE9.cat_catalogo = @viCatTipoLiquidez) 
			END											AS "des_tipo_liquidez",

			CASE GRO.cod_tenencia 
				WHEN NULL THEN '-'      
				WHEN -1 THEN '-'  
				ELSE (SELECT CE10.cat_campo + '-' + CE10.cat_descripcion FROM CAT_ELEMENTO CE10  WHERE CE10.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tenencia)) AND CE10.cat_catalogo = @viCatTipoTenencia) 
			END											AS "des_tipo_tenencia",

			CASE GRO.cod_moneda 
				WHEN NULL THEN '-'      
				WHEN -1 THEN '-'  
				ELSE (SELECT CE11.cat_campo + '-' + CE11.cat_descripcion FROM CAT_ELEMENTO CE11  WHERE CE11.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_moneda)) AND CE11.cat_catalogo = @viCatTipoMoneda) 
			END											AS "des_tipo_moneda",

			COALESCE(GGR.Usuario_Modifico,'')				AS "Usuario_Modifico",
			COALESCE(@vsNombreUsuarioModifico,'')			AS "Nombre_Usuario_Modifico",
			CONVERT(VARCHAR(20), (COALESCE(GGR.Fecha_Modifico,'1900-01-01')), 120)  AS "Fecha_Modifico",
			CONVERT(VARCHAR(20), (COALESCE(GGR.Fecha_Inserto,'1900-01-01')), 120)   AS "Fecha_Inserto",
			CONVERT(VARCHAR(20), (COALESCE(GGR.Fecha_Replica	,'1900-01-01')), 120) AS "Fecha_Replica",			
			COALESCE(CPA.Porcentaje_Aceptacion,0)		AS "Porcentaje_Aceptacion_Calculado",			
			GGR.Indicador_Vivienda_Habitada_Deudor		AS "Indicador_Vivienda_Habitada_Deudor"
	
		FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
			ON GRO.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN dbo.CAT_ELEMENTO CE1 
			ON GGR.cod_tipo_garantia_real = CE1.cat_campo
			AND CE1.cat_catalogo = @viCatTipoGarReal
			LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES VGR 
			ON VGR.cod_garantia_real = GRO.cod_garantia_real
			AND VGR.fecha_valuacion = @vdtFecha_Avaluo
			LEFT OUTER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
			ON CPA.Codigo_Tipo_Garantia = 2
			AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador
		WHERE	GRO.cod_operacion = @piOperacion
			AND GRO.cod_garantia_real = @piGarantia
			
		FOR XML PATH('GARANTIA'), ELEMENTS, TYPE
	),
	(	SELECT	DISTINCT 
			CONVERT(VARCHAR(10), (COALESCE(GRV.fecha_valuacion,'1900-01-01')), 103) AS "fecha_valuacion",
			COALESCE(GRV.cedula_empresa, '')				AS "cedula_empresa",
			COALESCE(GRV.cedula_perito, '')				AS "cedula_perito",
			COALESCE(GRV.monto_ultima_tasacion_terreno, 0)			AS "monto_ultima_tasacion_terreno",
			COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0)			AS "monto_ultima_tasacion_no_terreno",
			COALESCE(GRV.monto_tasacion_actualizada_terreno, 0)		AS "monto_tasacion_actualizada_terreno",
			COALESCE(GRV.monto_tasacion_actualizada_no_terreno, 0)	AS "monto_tasacion_actualizada_no_terreno",
			CONVERT(VARCHAR(10), (COALESCE(GRV.fecha_ultimo_seguimiento,'1900-01-01')), 103) AS "fecha_ultimo_seguimiento",
			CASE 
				WHEN (COALESCE(GRV.monto_ultima_tasacion_terreno, 0) = 0)
					AND  (COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0) = 0) THEN GRV.monto_total_avaluo
				ELSE (COALESCE(GRV.monto_ultima_tasacion_terreno, 0) + COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0))
			END
														AS "monto_total_avaluo",
			CONVERT(VARCHAR(10), (COALESCE(GRV.fecha_construccion,'1900-01-01')), 103) AS "fecha_construccion",
			
			CONVERT(VARCHAR(10), (COALESCE((SELECT TOP 1 fecha_valuacion FROM dbo.GAR_VALUACIONES_REALES WHERE fecha_valuacion < (SELECT MAX(fecha_valuacion) FROM dbo.GAR_VALUACIONES_REALES)),'1900-01-01')), 103) AS "penultima_fecha_valuacion",
		
			CONVERT(VARCHAR(10), @vdtFecha_Actual, 103) AS "fecha_actual",
			(COALESCE(GRV.Indicador_Actualizado_Calculo, 0)) AS "avaluo_actualizado",
			CONVERT(VARCHAR(10), (COALESCE(GRV.Fecha_Semestre_Calculado,'1900-01-01')), 103) AS "fecha_semestre_actualizado",
			CONVERT(VARCHAR(10), (COALESCE(GRO.Fecha_Valuacion_SICC,'1900-01-01')), 103)     AS "fecha_valuacion_sicc"

		FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
			LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GRV 
			ON GRV.cod_garantia_real = GRO.cod_garantia_real
			AND GRV.fecha_valuacion  = @vdtFecha_Avaluo
		WHERE	GRO.cod_operacion = @piOperacion
			AND GRO.cod_garantia_real = @piGarantia
			
		FOR XML PATH('AVALUO_MAS_RECIENTE'), ELEMENTS, TYPE
	),
	(	SELECT	DISTINCT 
			@vdtFecha_Avaluo							AS "prmgt_pfeavaing",
			@vdMontoAvaluoSICC 							AS "prmgt_pmoavaing"
			
		FOR XML PATH('AVALUO_SICC'), ELEMENTS, TYPE
	),
	(	SELECT	DISTINCT 
			CAST((@vdPorcentajeInferior/100) AS DECIMAL(5,3))	AS "porcentaje_limite_inferior",
			CAST((@vdPorcentajeIntermedio/100) AS DECIMAL(5,3)) AS "porcentaje_limite_intermedio",
			CAST((@vdPorcentajeSuperior/100) AS DECIMAL(5,3)) 	AS "porcentaje_limite_superior",
			@viAnnoInferior										AS "annos_limite_inferior",
			@viAnnoIntermedio									AS "annos_limite_intermedio"
		WHERE	@viTipoBien IN (-1, 1, 2)
		
		FOR XML PATH('PARAM_CALCULO'), ELEMENTS, TYPE
	),
	(	SELECT	DISTINCT 
			OGV.Codigo_Contabilidad			AS "OPERACION/contabilidad",
			OGV.Codigo_Oficina				AS "OPERACION/oficina",
			OGV.Codigo_Moneda				AS "OPERACION/moneda",
			OGV.Codigo_Producto				AS "OPERACION/producto",
			OGV.Operacion					AS "OPERACION/numeroOperacion",
			OGV.Tipo_Operacion				AS "OPERACION/tipoOperacion",
			OGV.Codigo_Operacion			AS "OPERACION/codigoOperacion",
			OGV.Consecutivo_Garantia		AS "OPERACION/codigoGarantia",
			OGV.Monto_Acreencia				AS "OPERACION/Monto_Acreencia_Poliza"
		FROM	dbo.Obtener_Operaciones_Comunes_FT(@piOperacion, @piGarantia, @vsCodigo_Bien, @vdtFecha_Actual) OGV
		WHERE	OGV.Codigo_Operacion <> @piOperacion
		
		FOR XML PATH(''), ELEMENTS, TYPE
	) AS "OPERACIONES_ASOCIADAS",
	(	SELECT	DISTINCT 
			OFS.Numero_Semestre							AS "SEMESTRE/Numero_Semestre",
			OFS.Fecha_Semestre							AS "SEMESTRE/Fecha_Semestre",
			OFS.Tipo_Cambio								AS "SEMESTRE/Tipo_Cambio",
			OFS.IPC										AS "SEMESTRE/IPC",
			OFS.Tipo_Cambio_Anterior					AS "SEMESTRE/Tipo_Cambio_Anterior",
			OFS.IPC_Anterior							AS "SEMESTRE/IPC_Anterior",
			OFS.Total_Registros							AS "SEMESTRE/Total_Registros"
		FROM	Obtener_Fechas_Semestrales_FT(@vdtFecha_Avaluo, @vdtFecha_Actual, @piGarantia) OFS
		WHERE	@viTipoBien IN (-1, 1, 2)
		
		FOR XML PATH(''), ELEMENTS, TYPE
	) AS "SEMESTRES_A_CALCULAR",
	(	SELECT	 
			GPO.Codigo_SAP								AS "POLIZA/Codigo_SAP",
			GPO.Tipo_Poliza								AS "POLIZA/Tipo_Poliza",
			GPO.Monto_Poliza							AS "POLIZA/Monto_Poliza",
			GPO.Moneda_Monto_Poliza						AS "POLIZA/Moneda_Monto_Poliza",
			COALESCE((CONVERT(VARCHAR(10), GPO.Fecha_Vencimiento, 103)), '')	
														AS "POLIZA/Fecha_Vencimiento",
			GPO.Cedula_Acreedor							AS "POLIZA/Cedula_Acreedor",
			GPO.Nombre_Acreedor							AS "POLIZA/Nombre_Acreedor",
			GAP.Monto_Acreencia							AS "POLIZA/Monto_Acreencia",
			COALESCE(GPO.Detalle_Poliza, '')        	AS "POLIZA/Detalle_Poliza",
			CASE
				WHEN ((GPO.Estado_Registro = 1) AND (COALESCE(GAP.Estado_Registro, 0) = 1) AND (TPB.Codigo_Tipo_Bien = @viTipoBien)) THEN 1
				ELSE 0
			END											AS "POLIZA/Poliza_Seleccionada",
			COALESCE(CE1.cat_descripcion, '')			AS "POLIZA/Descripcion_Tipo_Poliza_Sap",
			COALESCE(CONVERT(CHAR(1), GPO.Estado_Registro), '') 	AS "POLIZA/Codigo_Sap_Valido",
			COALESCE(GPO.Monto_Poliza_Anterior, GPO.Monto_Poliza_Colonizado)	AS "POLIZA/Monto_Poliza_Anterior",
			COALESCE((CONVERT(VARCHAR(10), GPO.Fecha_Vencimiento_Anterior, 103)), '') AS "POLIZA/Fecha_Vencimiento_Anterior",
			COALESCE(GPO.Cedula_Acreedor_Anterior, '')	AS "POLIZA/Cedula_Acreedor_Anterior",
			COALESCE(GPO.Nombre_Acreedor_Anterior, '')	AS "POLIZA/Nombre_Acreedor_Anterior",
			COALESCE(TPB.Codigo_Tipo_Bien, -1)			AS "POLIZA/Tipo_Bien_Poliza",
			GPO.Monto_Poliza_Colonizado					AS "POLIZA/Monto_Poliza_Colonizado",
			CASE
				WHEN GAP.Estado_Registro IS NULL THEN 0
				ELSE 1
			END											AS "POLIZA/Poliza_Asociada",
			COALESCE(GPO.Indicador_Poliza_Externa, 0)	AS "POLIZA/Indicador_Poliza_Externa",
			COALESCE(GPO.Codigo_Partido, -1)			AS "POLIZA/Codigo_Partido",
			COALESCE(LTRIM(RTRIM(GPO.Identificacion_Bien)), '')		AS "POLIZA/Identificacion_Bien",
			COALESCE(GPO.Codigo_Tipo_Cobertura, -1)		AS "POLIZA/Codigo_Tipo_Cobertura",
			COALESCE(GPO.Codigo_Aseguradora, -1)		AS "POLIZA/Codigo_Aseguradora",
			
			
			--INICIO RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
			(	SELECT	DISTINCT  
					GC1.Codigo_Cobertura			AS "COBERTURA/Codigo_Cobertura",
					GC1.Descripcion_Cobertura		AS "COBERTURA/Descripcion_Cobertura",
					GC1.Descripcion_Corta_Cobertura	AS "COBERTURA/Descripcion_Corta_Cobertura",
					GC1.Indicador_Obligatoria		AS "COBERTURA/Indicador_Obligatoria"
				FROM	dbo.GAR_COBERTURAS GC1
				WHERE	GC1.Codigo_Tipo_Cobertura = GPO.Codigo_Tipo_Cobertura
					AND GC1.Codigo_Tipo_Poliza = GPO.Tipo_Poliza
					--AND GC1.Codigo_Aseguradora = GPO.Codigo_Aseguradora
					
				FOR XML PATH(''), TYPE
			) AS "POLIZA/COBERTURAS/POR_ASIGNAR",
			
			(	SELECT 	DISTINCT 
					GC1.Codigo_Cobertura			AS "COBERTURA/Codigo_Cobertura",
					GC1.Descripcion_Cobertura		AS "COBERTURA/Descripcion_Cobertura",
					GC1.Descripcion_Corta_Cobertura	AS "COBERTURA/Descripcion_Corta_Cobertura",
					GC1.Indicador_Obligatoria		AS "COBERTURA/Indicador_Obligatoria"
				FROM	dbo.GAR_COBERTURAS GC1
					INNER JOIN dbo.GAR_COBERTURAS_POLIZAS GCP
					ON GCP.Codigo_Tipo_Cobertura = GC1.Codigo_Tipo_Cobertura
					AND GCP.Codigo_Cobertura = GC1.Codigo_Cobertura
					AND GCP.Codigo_Tipo_Poliza = GC1.Codigo_Tipo_Poliza
				WHERE	GCP.Codigo_SAP = GPO.Codigo_SAP
					AND GCP.cod_operacion = GPO.cod_operacion
					--AND GC1.Codigo_Aseguradora = GPO.Codigo_Aseguradora
					
				FOR XML PATH(''), TYPE
			) AS "POLIZA/COBERTURAS/ASIGNADAS"
			--FIN RQ: RQ_MANT_2015062410418218_00030 Creación Coberturas bienes en pólizas
			
		FROM	dbo.GAR_POLIZAS GPO 
			LEFT OUTER JOIN	dbo.GAR_POLIZAS_RELACIONADAS GAP
			ON GAP.Codigo_SAP = GPO.Codigo_SAP
			AND GAP.cod_operacion = GPO.cod_operacion
			AND GAP.cod_garantia_real = @piGarantia		
			LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1
			ON CE1.cat_campo = GPO.Tipo_Poliza
			LEFT OUTER JOIN dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN TPB
			ON TPB.Codigo_Tipo_Poliza_Sap = GPO.Tipo_Poliza
					
		WHERE	GPO.cod_operacion = @piOperacion
			AND CE1.cat_catalogo = @viCatTiposPolizasSap
			/*AND GPO.Estado_Registro = 1	
			AND COALESCE(GAP.Estado_Registro,1) = 1	*/
		
		FOR XML PATH(''), ELEMENTS, TYPE
	) AS "POLIZAS"		

	FOR		XML PATH(''), ROOT('DATOS')

	SET @psRespuesta = N'<RESPUESTA>' +
							'<CODIGO>0</CODIGO>' +
							'<NIVEL></NIVEL>' +
							'<ESTADO></ESTADO>' +
							'<PROCEDIMIENTO>Consultar_Garantia_Real</PROCEDIMIENTO>' +
							'<LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactoriGRO.</MENSAJE>' +
							'<DETALLE></DETALLE>' +
						'</RESPUESTA>'

	RETURN 0

	/************************************************************************************************
	 *                                                                                              * 
	 *								 FIN DE LA SELECCION DE DATOS		     						*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

END

