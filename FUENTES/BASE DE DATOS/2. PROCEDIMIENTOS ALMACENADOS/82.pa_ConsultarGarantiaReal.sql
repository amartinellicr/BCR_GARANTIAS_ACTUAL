--USE [GARANTIAS]
--GO

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
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfauméricas</Requerimiento>
			<Fecha>01/07/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
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
										ON SU.COD_USUARIO = GGR.Usuario_Modifico COLLATE Latin1_General_CI_AS
									WHERE	GGR.cod_garantia_real = @piGarantia )		

	/************************************************************************************************
	 *                                                                                              * 
	 *								INICIO DE LA SELECCION DE DATOS		     						*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/
	
	SELECT DISTINCT	
			1											AS Tag,
			NULL										AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia!element], 
			NULL										AS [GARANTIA!2!cod_clase_garantia!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!des_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_partido!element], 
			NULL										AS [GARANTIA!2!numero_finca!element], 
			NULL										AS [GARANTIA!2!cod_grado!element], 
			NULL										AS [GARANTIA!2!cedula_hipotecaria!element], 
			NULL										AS [GARANTIA!2!cod_clase_bien!element], 
			NULL										AS [GARANTIA!2!num_placa_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_tipo_documento_legal!element], 
			NULL										AS [GARANTIA!2!monto_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_inscripcion!element], 
			NULL										AS [GARANTIA!2!fecha_presentacion!element], 
			NULL										AS [GARANTIA!2!porcentaje_responsabilidad!element], 
			NULL										AS [GARANTIA!2!cod_grado_gravamen!element], 
			NULL										AS [GARANTIA!2!cod_operacion_especial!element], 
			NULL										AS [GARANTIA!2!fecha_constitucion!element], 
			NULL										AS [GARANTIA!2!fecha_vencimiento!element], 
			NULL										AS [GARANTIA!2!cod_tipo_acreedor!element], 
			NULL										AS [GARANTIA!2!ced_acreedor!element], 
			NULL										AS [GARANTIA!2!cod_liquidez!element], 
			NULL										AS [GARANTIA!2!cod_tenencia!element], 
			NULL										AS [GARANTIA!2!cod_moneda!element], 
			NULL										AS [GARANTIA!2!fecha_prescripcion!element],
			NULL										AS [GARANTIA!2!cod_estado!element],
			NULL										AS [GARANTIA!2!fecha_valuacion!element],
			NULL										AS [GARANTIA!2!monto_total_avaluo!element],
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!des_tipo_documento!element],
			NULL										AS [GARANTIA!2!des_tipo_inscripcion!element],
			NULL										AS [GARANTIA!2!des_tipo_grado_gravamen!element],
			NULL										AS [GARANTIA!2!des_tipo_operacion_especial!element],
			NULL										AS [GARANTIA!2!des_tipo_persona!element],
			NULL										AS [GARANTIA!2!des_tipo_liquidez!element],
			NULL										AS [GARANTIA!2!des_tipo_tenencia!element],
			NULL										AS [GARANTIA!2!des_tipo_moneda!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Nombre_Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Inserto!element],
			NULL										AS [GARANTIA!2!Fecha_Replica!element],
			NULL										AS [GARANTIA!2!Porcentaje_Aceptacion_Calculado!element],			
			NULL										AS [GARANTIA!2!Indicador_Vivienda_Habitada_Deudor!element],			
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!penultima_fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_actual!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!avaluo_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_semestre_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion_sicc!element],		
			NULL										AS [AVALUO_SICC!4!prmgt_pfeavaing!element],
			NULL										AS [AVALUO_SICC!4!prmgt_pmoavaing!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_intermedio!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_superior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_intermedio!element],
			NULL										AS [OPERACIONES_ASOCIADAS!6!],
			NULL										AS [OPERACION!7!contabilidad!element],
	   		NULL										AS [OPERACION!7!oficina!element],
			NULL										AS [OPERACION!7!moneda!element],
			NULL										AS [OPERACION!7!producto!element],
			NULL										AS [OPERACION!7!numeroOperacion!element],
			NULL										AS [OPERACION!7!tipoOperacion!element],
			NULL										AS [OPERACION!7!codigoOperacion!element],
			NULL										AS [OPERACION!7!codigoGarantia!element],
			NULL										AS [OPERACION!7!Monto_Acreencia_Poliza!element],
			NULL										AS [SEMESTRES_A_CALCULAR!8!],
			NULL										AS [SEMESTRE!9!Numero_Semestre!element],
			NULL										AS [SEMESTRE!9!Fecha_Semestre!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio!element],
			NULL										AS [SEMESTRE!9!IPC!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio_Anterior!element],
			NULL										AS [SEMESTRE!9!IPC_Anterior!element],
			NULL										AS [SEMESTRE!9!Total_Registros!element],
			NULL										AS [POLIZAS!10!],
			NULL										AS [POLIZA!11!Codigo_SAP!element],
			NULL										AS [POLIZA!11!Tipo_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza!element],
			NULL										AS [POLIZA!11!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor!element],
			NULL										AS [POLIZA!11!Monto_Acreencia!element],
			NULL										AS [POLIZA!11!Detalle_Poliza!element],
			NULL										AS [POLIZA!11!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!11!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!11!Codigo_Sap_Valido!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Anterior!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento_Anterior!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Tipo_Bien_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Colonizado!element],
			NULL										AS [POLIZA!11!Poliza_Asociada!element]

	UNION ALL

	SELECT DISTINCT	
			2											AS Tag,
			1											AS Parent,
			NULL										AS [DATOS!1!],
			GRO.cod_operacion							AS [GARANTIA!2!cod_operacion!element],
			GRO.cod_garantia_real						AS [GARANTIA!2!cod_garantia_real!element], 
			GGR.cod_tipo_garantia						AS [GARANTIA!2!cod_tipo_garantia!element], 
			GGR.cod_clase_garantia						AS [GARANTIA!2!cod_clase_garantia!element], 
			GGR.cod_tipo_garantia_real					AS [GARANTIA!2!cod_tipo_garantia_real!element], 
			CE1.cat_descripcion							AS [GARANTIA!2!des_tipo_garantia_real!element], 
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN 'Partido: ' + COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + ' - Finca: ' + COALESCE(LTRIM(RTRIM(GGR.numero_finca)),'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN 'Partido: ' + COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + ' - Finca: ' + COALESCE(LTRIM(RTRIM(GGR.numero_finca)),'') + ' - Grado: ' + COALESCE(CONVERT(VARCHAR(2),GGR.cod_grado),'') + ' - Cédula Hipotecaria: ' + COALESCE(CONVERT(VARCHAR(2),GGR.cedula_hipotecaria),'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN 'Clase Bien: ' + COALESCE(GGR.cod_clase_bien,'') + ' - Número Placa: ' + COALESCE(LTRIM(RTRIM(GGR.num_placa_bien)),'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN 'Número Placa: ' + COALESCE(LTRIM(RTRIM(GGR.num_placa_bien)),'') 
			END											AS [GARANTIA!2!garantia_real!element], 
			GGR.cod_partido								AS [GARANTIA!2!cod_partido!element], 
			COALESCE(LTRIM(RTRIM(GGR.numero_finca)),'')					AS [GARANTIA!2!numero_finca!element], 
			COALESCE(GGR.cod_grado,'')					AS [GARANTIA!2!cod_grado!element], 
			COALESCE(GGR.cedula_hipotecaria,'')			AS [GARANTIA!2!cedula_hipotecaria!element], 
			COALESCE(GGR.cod_clase_bien,'')				AS [GARANTIA!2!cod_clase_bien!element], 
			COALESCE(LTRIM(RTRIM(GGR.num_placa_bien)),'')				AS [GARANTIA!2!num_placa_bien!element], 
			COALESCE(GGR.cod_tipo_bien,-1)				AS [GARANTIA!2!cod_tipo_bien!element], 
			COALESCE(GRO.cod_tipo_mitigador,-1)			AS [GARANTIA!2!cod_tipo_mitigador!element], 
			COALESCE(GRO.cod_tipo_documento_legal,-1)		AS [GARANTIA!2!cod_tipo_documento_legal!element], 
			COALESCE(GRO.monto_mitigador,0)				AS [GARANTIA!2!monto_mitigador!element], 
			COALESCE(GRO.cod_inscripcion,-1)				AS [GARANTIA!2!cod_inscripcion!element], 
			CONVERT(VARCHAR(10), (COALESCE(GRO.fecha_presentacion,'1900-01-01')), 103)	AS [GARANTIA!2!fecha_presentacion!element], 
			COALESCE(GRO.porcentaje_responsabilidad,0)	AS [GARANTIA!2!porcentaje_responsabilidad!element], 
			CASE 
				WHEN GRO.cod_grado_gravamen IS NULL THEN -1 
				WHEN GRO.cod_grado_gravamen < 1 THEN -1 
				ELSE GRO.cod_grado_gravamen 
			END											AS [GARANTIA!2!cod_grado_gravamen!element], 
			COALESCE(GRO.cod_operacion_especial,0)		AS [GARANTIA!2!cod_operacion_especial!element],
			CONVERT(VARCHAR(10), (COALESCE(GRO.fecha_constitucion,'1900-01-01')), 103)AS [GARANTIA!2!fecha_constitucion!element],
			CONVERT(VARCHAR(10), (COALESCE(GRO.fecha_vencimiento,'1900-01-01')), 103)	AS [GARANTIA!2!fecha_vencimiento!element], 
			CASE GRO.cod_tipo_acreedor 
				WHEN NULL THEN 2 
				WHEN -1 THEN 2 
				ELSE GRO.cod_tipo_acreedor 
			END											AS [GARANTIA!2!cod_tipo_acreedor!element], 
			COALESCE(GRO.cedula_acreedor,'')				AS [GARANTIA!2!ced_acreedor!element], 
			CASE GRO.cod_liquidez 
				WHEN NULL THEN -1 
				WHEN 0 THEN -1 
				ELSE GRO.cod_liquidez 
			END											AS [GARANTIA!2!cod_liquidez!element], 
			CASE GRO.cod_tenencia 
				WHEN NULL THEN -1 
				WHEN 0 THEN -1 
				ELSE GRO.cod_tenencia 
			END											AS [GARANTIA!2!cod_tenencia!element], 
			CASE GRO.cod_moneda 
				WHEN NULL THEN -1 
				WHEN 0 THEN -1 
				ELSE GRO.cod_moneda 
			END											AS [GARANTIA!2!cod_moneda!element], 
			CONVERT(VARCHAR(10), (COALESCE(GRO.fecha_prescripcion,'1900-01-01')), 103)	AS [GARANTIA!2!fecha_prescripcion!element],
			GRO.cod_estado								AS [GARANTIA!2!cod_estado!element],
			CONVERT(VARCHAR(10), (COALESCE(VGR.fecha_valuacion,'1900-01-01')), 103)
														AS [GARANTIA!2!fecha_valuacion!element],

			CASE 
				WHEN (COALESCE(VGR.monto_ultima_tasacion_terreno, 0) = 0)
					AND  (COALESCE(VGR.monto_ultima_tasacion_no_terreno, 0) = 0) THEN VGR.monto_total_avaluo
				ELSE (COALESCE(VGR.monto_ultima_tasacion_terreno, 0) + COALESCE(VGR.monto_ultima_tasacion_no_terreno, 0))
			END
														AS [GARANTIA!2!monto_total_avaluo!element],

		    CASE GGR.cod_tipo_bien
				 WHEN NULL THEN '-'                                                                                                                                                                      
				 ELSE (SELECT CE2.cat_campo + '-' + CE2.cat_descripcion FROM CAT_ELEMENTO CE2  WHERE CE2.cat_campo = (CONVERT(VARCHAR(5), GGR.cod_tipo_bien))   AND CE2.cat_catalogo = @viCatTipoBien )  
			END											AS [GARANTIA!2!des_tipo_bien!element],

			CASE GRO.cod_tipo_mitigador
				 WHEN NULL THEN '-'                                                                                                                                                                          
				 ELSE (SELECT CE3.cat_campo + '-' + CE3.cat_descripcion FROM CAT_ELEMENTO CE3  WHERE CE3.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tipo_mitigador))  AND CE3.cat_catalogo = @viCatTipoMitigador )
			END											AS [GARANTIA!2!des_tipo_mitigador!element],

			CASE GRO.cod_tipo_documento_legal
				 WHEN NULL THEN '-'                                                                                                                                                                          
				 ELSE (SELECT CE4.cat_campo + '-' + CE4.cat_descripcion FROM CAT_ELEMENTO CE4  WHERE CE4.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tipo_documento_legal))  AND CE4.cat_catalogo = @viCatTipoDocumentoLegal )
			END											AS [GARANTIA!2!des_tipo_documento!element],

			CASE GRO.cod_inscripcion
				 WHEN NULL THEN '-'                                                                                                                                                                          
				 ELSE (SELECT CE5.cat_campo + '-' + CE5.cat_descripcion FROM CAT_ELEMENTO CE5  WHERE CE5.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_inscripcion)) AND CE5.cat_catalogo = @viCatInscripcion)
			END											AS [GARANTIA!2!des_tipo_inscripcion!element],

			CASE 
				WHEN GRO.cod_grado_gravamen IS NULL THEN '-' 
				WHEN GRO.cod_grado_gravamen > 3 THEN (SELECT CE6.cat_campo + '-' + CE6.cat_descripcion FROM CAT_ELEMENTO CE6  WHERE CE6.cat_campo = '4' AND CE6.cat_catalogo = @viCatGradoGravamen) 
				WHEN GRO.cod_grado_gravamen < 1 THEN '-' 
				ELSE (SELECT CE6.cat_campo + '-' + CE6.cat_descripcion FROM CAT_ELEMENTO CE6  WHERE CE6.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_grado_gravamen)) AND CE6.cat_catalogo = @viCatGradoGravamen)  
			END											AS [GARANTIA!2!des_tipo_grado_gravamen!element],

			CASE GRO.cod_operacion_especial
				WHEN NULL THEN (SELECT CE7.cat_campo + '-' + CE7.cat_descripcion FROM CAT_ELEMENTO CE7  WHERE CE7.cat_campo = '0' AND CE7.cat_catalogo = @viCatOperacionEspecial)   
				WHEN -1 THEN '-'
				ELSE (SELECT CE7.cat_campo + '-' + CE7.cat_descripcion FROM CAT_ELEMENTO CE7  WHERE CE7.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_operacion_especial)) AND CE7.cat_catalogo = @viCatOperacionEspecial)     
			END											AS [GARANTIA!2!des_tipo_operacion_especial!element],

			CASE GRO.cod_tipo_acreedor 
				WHEN NULL THEN (SELECT CE8.cat_campo + '-' + CE8.cat_descripcion FROM CAT_ELEMENTO CE8  WHERE CE8.cat_campo = '2' AND CE8.cat_catalogo = @viCatTipoPersona)      
				WHEN -1 THEN (SELECT CE8.cat_campo + '-' + CE8.cat_descripcion FROM CAT_ELEMENTO CE8  WHERE CE8.cat_campo = '2' AND CE8.cat_catalogo = @viCatTipoPersona)  
				ELSE (SELECT CE8.cat_campo + '-' + CE8.cat_descripcion FROM CAT_ELEMENTO CE8  WHERE CE8.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tipo_acreedor)) AND CE8.cat_catalogo = @viCatTipoPersona) 
			END											AS [GARANTIA!2!des_tipo_persona!element],

			CASE GRO.cod_liquidez 
				WHEN NULL THEN '-'      
				WHEN -1 THEN '-'  
				ELSE (SELECT CE9.cat_campo + '-' + CE9.cat_descripcion FROM CAT_ELEMENTO CE9  WHERE CE9.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_liquidez)) AND CE9.cat_catalogo = @viCatTipoLiquidez) 
			END											AS [GARANTIA!2!des_tipo_liquidez!element],

			CASE GRO.cod_tenencia 
				WHEN NULL THEN '-'      
				WHEN -1 THEN '-'  
				ELSE (SELECT CE10.cat_campo + '-' + CE10.cat_descripcion FROM CAT_ELEMENTO CE10  WHERE CE10.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tenencia)) AND CE10.cat_catalogo = @viCatTipoTenencia) 
			END											AS [GARANTIA!2!des_tipo_tenencia!element],

			CASE GRO.cod_moneda 
				WHEN NULL THEN '-'      
				WHEN -1 THEN '-'  
				ELSE (SELECT CE11.cat_campo + '-' + CE11.cat_descripcion FROM CAT_ELEMENTO CE11  WHERE CE11.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_moneda)) AND CE11.cat_catalogo = @viCatTipoMoneda) 
			END											AS [GARANTIA!2!des_tipo_moneda!element],

			COALESCE(GGR.Usuario_Modifico,'')				AS [GARANTIA!2!Usuario_Modifico!element],
			COALESCE(@vsNombreUsuarioModifico,'')			AS [GARANTIA!2!Nombre_Usuario_Modifico!element],
			CONVERT(VARCHAR(20), (COALESCE(GGR.Fecha_Modifico,'1900-01-01')), 120)  AS [GARANTIA!2!Fecha_Modifico!element],
			CONVERT(VARCHAR(20), (COALESCE(GGR.Fecha_Inserto,'1900-01-01')), 120)   AS [GARANTIA!2!Fecha_Inserto!element],
			CONVERT(VARCHAR(20), (COALESCE(GGR.Fecha_Replica	,'1900-01-01')), 120) AS [GARANTIA!2!Fecha_Replica!element],			
			COALESCE(CPA.Porcentaje_Aceptacion,0)		AS [GARANTIA!2!Porcentaje_Aceptacion_Calculado!element],			
			GGR.Indicador_Vivienda_Habitada_Deudor		AS [GARANTIA!2!Indicador_Vivienda_Habitada_Deudor!element],			
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!penultima_fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_actual!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!avaluo_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_semestre_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion_sicc!element],		
			NULL										AS [AVALUO_SICC!4!prmgt_pfeavaing!element],
			NULL										AS [AVALUO_SICC!4!prmgt_pmoavaing!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_intermedio!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_superior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_intermedio!element],
			NULL										AS [OPERACIONES_ASOCIADAS!6!],
			NULL										AS [OPERACION!7!contabilidad!element],
	   		NULL										AS [OPERACION!7!oficina!element],
			NULL										AS [OPERACION!7!moneda!element],
			NULL										AS [OPERACION!7!producto!element],
			NULL										AS [OPERACION!7!numeroOperacion!element],
			NULL										AS [OPERACION!7!tipoOperacion!element],
			NULL										AS [OPERACION!7!codigoOperacion!element],
			NULL										AS [OPERACION!7!codigoGarantia!element],
			NULL										AS [OPERACION!7!Monto_Acreencia_Poliza!element],
			NULL										AS [SEMESTRES_A_CALCULAR!8!],
			NULL										AS [SEMESTRE!9!Numero_Semestre!element],
			NULL										AS [SEMESTRE!9!Fecha_Semestre!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio!element],
			NULL										AS [SEMESTRE!9!IPC!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio_Anterior!element],
			NULL										AS [SEMESTRE!9!IPC_Anterior!element],
			NULL										AS [SEMESTRE!9!Total_Registros!element],
			NULL										AS [POLIZAS!10!],
			NULL										AS [POLIZA!11!Codigo_SAP!element],
			NULL										AS [POLIZA!11!Tipo_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza!element],
			NULL										AS [POLIZA!11!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor!element],
			NULL										AS [POLIZA!11!Monto_Acreencia!element],
			NULL										AS [POLIZA!11!Detalle_Poliza!element],
			NULL										AS [POLIZA!11!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!11!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!11!Codigo_Sap_Valido!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Anterior!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento_Anterior!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Tipo_Bien_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Colonizado!element],
			NULL										AS [POLIZA!11!Poliza_Asociada!element]
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

	UNION ALL

	SELECT DISTINCT	
			3											AS Tag,
			1											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia!element], 
			NULL										AS [GARANTIA!2!cod_clase_garantia!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!des_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_partido!element], 
			NULL										AS [GARANTIA!2!numero_finca!element], 
			NULL										AS [GARANTIA!2!cod_grado!element], 
			NULL										AS [GARANTIA!2!cedula_hipotecaria!element], 
			NULL										AS [GARANTIA!2!cod_clase_bien!element], 
			NULL										AS [GARANTIA!2!num_placa_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_tipo_documento_legal!element], 
			NULL										AS [GARANTIA!2!monto_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_inscripcion!element], 
			NULL										AS [GARANTIA!2!fecha_presentacion!element], 
			NULL										AS [GARANTIA!2!porcentaje_responsabilidad!element], 
			NULL										AS [GARANTIA!2!cod_grado_gravamen!element], 
			NULL										AS [GARANTIA!2!cod_operacion_especial!element], 
			NULL										AS [GARANTIA!2!fecha_constitucion!element], 
			NULL										AS [GARANTIA!2!fecha_vencimiento!element], 
			NULL										AS [GARANTIA!2!cod_tipo_acreedor!element], 
			NULL										AS [GARANTIA!2!ced_acreedor!element], 
			NULL										AS [GARANTIA!2!cod_liquidez!element], 
			NULL										AS [GARANTIA!2!cod_tenencia!element], 
			NULL										AS [GARANTIA!2!cod_moneda!element], 
			NULL										AS [GARANTIA!2!fecha_prescripcion!element],
			NULL										AS [GARANTIA!2!cod_estado!element],
			NULL										AS [GARANTIA!2!fecha_valuacion!element],
			NULL										AS [GARANTIA!2!monto_total_avaluo!element],
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!des_tipo_documento!element],
			NULL										AS [GARANTIA!2!des_tipo_inscripcion!element],
			NULL										AS [GARANTIA!2!des_tipo_grado_gravamen!element],
			NULL										AS [GARANTIA!2!des_tipo_operacion_especial!element],
			NULL										AS [GARANTIA!2!des_tipo_persona!element],
			NULL										AS [GARANTIA!2!des_tipo_liquidez!element],
			NULL										AS [GARANTIA!2!des_tipo_tenencia!element],
			NULL										AS [GARANTIA!2!des_tipo_moneda!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Nombre_Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Inserto!element],
			NULL										AS [GARANTIA!2!Fecha_Replica!element],
			NULL										AS [GARANTIA!2!Porcentaje_Aceptacion_Calculado!element],
			NULL										AS [GARANTIA!2!Indicador_Vivienda_Habitada_Deudor!element],			
			CONVERT(VARCHAR(10), (COALESCE(GRV.fecha_valuacion,'1900-01-01')), 103) AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			COALESCE(GRV.cedula_empresa, '')				AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			COALESCE(GRV.cedula_perito, '')				AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			COALESCE(GRV.monto_ultima_tasacion_terreno, 0)			AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0)			AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			COALESCE(GRV.monto_tasacion_actualizada_terreno, 0)		AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			COALESCE(GRV.monto_tasacion_actualizada_no_terreno, 0)	AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			CONVERT(VARCHAR(10), (COALESCE(GRV.fecha_ultimo_seguimiento,'1900-01-01')), 103) AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			CASE 
				WHEN (COALESCE(GRV.monto_ultima_tasacion_terreno, 0) = 0)
					AND  (COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0) = 0) THEN GRV.monto_total_avaluo
				ELSE (COALESCE(GRV.monto_ultima_tasacion_terreno, 0) + COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0))
			END
														AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			CONVERT(VARCHAR(10), (COALESCE(GRV.fecha_construccion,'1900-01-01')), 103) AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			
			CONVERT(VARCHAR(10), (COALESCE((SELECT TOP 1 fecha_valuacion FROM dbo.GAR_VALUACIONES_REALES WHERE fecha_valuacion < (SELECT MAX(fecha_valuacion) FROM dbo.GAR_VALUACIONES_REALES)),'1900-01-01')), 103) AS [AVALUO_MAS_RECIENTE!3!penultima_fecha_valuacion!element],
		
			CONVERT(VARCHAR(10), @vdtFecha_Actual, 103) AS [AVALUO_MAS_RECIENTE!3!fecha_actual!element],
			(COALESCE(GRV.Indicador_Actualizado_Calculo, 0)) AS [AVALUO_MAS_RECIENTE!3!avaluo_actualizado!element],
			CONVERT(VARCHAR(10), (COALESCE(GRV.Fecha_Semestre_Calculado,'1900-01-01')), 103) AS [AVALUO_MAS_RECIENTE!3!fecha_semestre_actualizado!element],
			CONVERT(VARCHAR(10), (COALESCE(GRO.Fecha_Valuacion_SICC,'1900-01-01')), 103)     AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion_sicc!element],		
			NULL										AS [AVALUO_SICC!4!prmgt_pfeavaing!element],
			NULL										AS [AVALUO_SICC!4!prmgt_pmoavaing!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_intermedio!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_superior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_intermedio!element],
			NULL										AS [OPERACIONES_ASOCIADAS!6!],
			NULL										AS [OPERACION!7!contabilidad!element],
	   		NULL										AS [OPERACION!7!oficina!element],
			NULL										AS [OPERACION!7!moneda!element],
			NULL										AS [OPERACION!7!producto!element],
			NULL										AS [OPERACION!7!numeroOperacion!element],
			NULL										AS [OPERACION!7!tipoOperacion!element],
			NULL										AS [OPERACION!7!codigoOperacion!element],
			NULL										AS [OPERACION!7!codigoGarantia!element],
			NULL										AS [OPERACION!7!Monto_Acreencia_Poliza!element],
			NULL										AS [SEMESTRES_A_CALCULAR!8!],
			NULL										AS [SEMESTRE!9!Numero_Semestre!element],
			NULL										AS [SEMESTRE!9!Fecha_Semestre!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio!element],
			NULL										AS [SEMESTRE!9!IPC!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio_Anterior!element],
			NULL										AS [SEMESTRE!9!IPC_Anterior!element],
			NULL										AS [SEMESTRE!9!Total_Registros!element],
			NULL										AS [POLIZAS!10!],
			NULL										AS [POLIZA!11!Codigo_SAP!element],
			NULL										AS [POLIZA!11!Tipo_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza!element],
			NULL										AS [POLIZA!11!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor!element],
			NULL										AS [POLIZA!11!Monto_Acreencia!element],
			NULL										AS [POLIZA!11!Detalle_Poliza!element],
			NULL										AS [POLIZA!11!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!11!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!11!Codigo_Sap_Valido!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Anterior!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento_Anterior!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Tipo_Bien_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Colonizado!element],
			NULL										AS [POLIZA!11!Poliza_Asociada!element]
	FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GRV 
		ON GRV.cod_garantia_real = GRO.cod_garantia_real
		AND GRV.fecha_valuacion  = @vdtFecha_Avaluo
	WHERE	GRO.cod_operacion = @piOperacion
		AND GRO.cod_garantia_real = @piGarantia
		
	UNION ALL

	SELECT DISTINCT	
			4											AS Tag,
			1											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia!element], 
			NULL										AS [GARANTIA!2!cod_clase_garantia!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!des_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_partido!element], 
			NULL										AS [GARANTIA!2!numero_finca!element], 
			NULL										AS [GARANTIA!2!cod_grado!element], 
			NULL										AS [GARANTIA!2!cedula_hipotecaria!element], 
			NULL										AS [GARANTIA!2!cod_clase_bien!element], 
			NULL										AS [GARANTIA!2!num_placa_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_tipo_documento_legal!element], 
			NULL										AS [GARANTIA!2!monto_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_inscripcion!element], 
			NULL										AS [GARANTIA!2!fecha_presentacion!element], 
			NULL										AS [GARANTIA!2!porcentaje_responsabilidad!element], 
			NULL										AS [GARANTIA!2!cod_grado_gravamen!element], 
			NULL										AS [GARANTIA!2!cod_operacion_especial!element], 
			NULL										AS [GARANTIA!2!fecha_constitucion!element], 
			NULL										AS [GARANTIA!2!fecha_vencimiento!element], 
			NULL										AS [GARANTIA!2!cod_tipo_acreedor!element], 
			NULL										AS [GARANTIA!2!ced_acreedor!element], 
			NULL										AS [GARANTIA!2!cod_liquidez!element], 
			NULL										AS [GARANTIA!2!cod_tenencia!element], 
			NULL										AS [GARANTIA!2!cod_moneda!element], 
			NULL										AS [GARANTIA!2!fecha_prescripcion!element],
			NULL										AS [GARANTIA!2!cod_estado!element],
			NULL										AS [GARANTIA!2!fecha_valuacion!element],
			NULL										AS [GARANTIA!2!monto_total_avaluo!element],
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!des_tipo_documento!element],
			NULL										AS [GARANTIA!2!des_tipo_inscripcion!element],
			NULL										AS [GARANTIA!2!des_tipo_grado_gravamen!element],
			NULL										AS [GARANTIA!2!des_tipo_operacion_especial!element],
			NULL										AS [GARANTIA!2!des_tipo_persona!element],
			NULL										AS [GARANTIA!2!des_tipo_liquidez!element],
			NULL										AS [GARANTIA!2!des_tipo_tenencia!element],
			NULL										AS [GARANTIA!2!des_tipo_moneda!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Nombre_Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Inserto!element],
			NULL										AS [GARANTIA!2!Fecha_Replica!element],
			NULL										AS [GARANTIA!2!Porcentaje_Aceptacion_Calculado!element],
			NULL										AS [GARANTIA!2!Indicador_Vivienda_Habitada_Deudor!element],			
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!penultima_fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_actual!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!avaluo_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_semestre_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion_sicc!element],		
			@vdtFecha_Avaluo							AS [AVALUO_SICC!4!prmgt_pfeavaing!element],
			@vdMontoAvaluoSICC 							AS [AVALUO_SICC!4!prmgt_pmoavaing!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_intermedio!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_superior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_intermedio!element],
			NULL										AS [OPERACIONES_ASOCIADAS!6!],
			NULL										AS [OPERACION!7!contabilidad!element],
	   		NULL										AS [OPERACION!7!oficina!element],
			NULL										AS [OPERACION!7!moneda!element],
			NULL										AS [OPERACION!7!producto!element],
			NULL										AS [OPERACION!7!numeroOperacion!element],
			NULL										AS [OPERACION!7!tipoOperacion!element],
			NULL										AS [OPERACION!7!codigoOperacion!element],
			NULL										AS [OPERACION!7!codigoGarantia!element],
			NULL										AS [OPERACION!7!Monto_Acreencia_Poliza!element],
			NULL										AS [SEMESTRES_A_CALCULAR!8!],
			NULL										AS [SEMESTRE!9!Numero_Semestre!element],
			NULL										AS [SEMESTRE!9!Fecha_Semestre!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio!element],
			NULL										AS [SEMESTRE!9!IPC!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio_Anterior!element],
			NULL										AS [SEMESTRE!9!IPC_Anterior!element],
			NULL										AS [SEMESTRE!9!Total_Registros!element],
			NULL										AS [POLIZAS!10!],
			NULL										AS [POLIZA!11!Codigo_SAP!element],
			NULL										AS [POLIZA!11!Tipo_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza!element],
			NULL										AS [POLIZA!11!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor!element],
			NULL										AS [POLIZA!11!Monto_Acreencia!element],
			NULL										AS [POLIZA!11!Detalle_Poliza!element],
			NULL										AS [POLIZA!11!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!11!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!11!Codigo_Sap_Valido!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Anterior!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento_Anterior!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Tipo_Bien_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Colonizado!element],
			NULL										AS [POLIZA!11!Poliza_Asociada!element]
	
	UNION ALL

	SELECT DISTINCT	
			5											AS Tag,
			1											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia!element], 
			NULL										AS [GARANTIA!2!cod_clase_garantia!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!des_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_partido!element], 
			NULL										AS [GARANTIA!2!numero_finca!element], 
			NULL										AS [GARANTIA!2!cod_grado!element], 
			NULL										AS [GARANTIA!2!cedula_hipotecaria!element], 
			NULL										AS [GARANTIA!2!cod_clase_bien!element], 
			NULL										AS [GARANTIA!2!num_placa_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_tipo_documento_legal!element], 
			NULL										AS [GARANTIA!2!monto_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_inscripcion!element], 
			NULL										AS [GARANTIA!2!fecha_presentacion!element], 
			NULL										AS [GARANTIA!2!porcentaje_responsabilidad!element], 
			NULL										AS [GARANTIA!2!cod_grado_gravamen!element], 
			NULL										AS [GARANTIA!2!cod_operacion_especial!element], 
			NULL										AS [GARANTIA!2!fecha_constitucion!element], 
			NULL										AS [GARANTIA!2!fecha_vencimiento!element], 
			NULL										AS [GARANTIA!2!cod_tipo_acreedor!element], 
			NULL										AS [GARANTIA!2!ced_acreedor!element], 
			NULL										AS [GARANTIA!2!cod_liquidez!element], 
			NULL										AS [GARANTIA!2!cod_tenencia!element], 
			NULL										AS [GARANTIA!2!cod_moneda!element], 
			NULL										AS [GARANTIA!2!fecha_prescripcion!element],
			NULL										AS [GARANTIA!2!cod_estado!element],
			NULL										AS [GARANTIA!2!fecha_valuacion!element],
			NULL										AS [GARANTIA!2!monto_total_avaluo!element],
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!des_tipo_documento!element],
			NULL										AS [GARANTIA!2!des_tipo_inscripcion!element],
			NULL										AS [GARANTIA!2!des_tipo_grado_gravamen!element],
			NULL										AS [GARANTIA!2!des_tipo_operacion_especial!element],
			NULL										AS [GARANTIA!2!des_tipo_persona!element],
			NULL										AS [GARANTIA!2!des_tipo_liquidez!element],
			NULL										AS [GARANTIA!2!des_tipo_tenencia!element],
			NULL										AS [GARANTIA!2!des_tipo_moneda!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Nombre_Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Inserto!element],
			NULL										AS [GARANTIA!2!Fecha_Replica!element],
			NULL										AS [GARANTIA!2!Porcentaje_Aceptacion_Calculado!element],
			NULL										AS [GARANTIA!2!Indicador_Vivienda_Habitada_Deudor!element],			
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!penultima_fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_actual!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!avaluo_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_semestre_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion_sicc!element],		
			NULL										AS [AVALUO_SICC!4!prmgt_pfeavaing!element],
			NULL										AS [AVALUO_SICC!4!prmgt_pmoavaing!element],
			CAST((@vdPorcentajeInferior/100) AS DECIMAL(5,3))
														AS [PARAM_CALCULO!5!porcentaje_limite_inferior!element],
			CAST((@vdPorcentajeIntermedio/100) AS DECIMAL(5,3))
														AS [PARAM_CALCULO!5!porcentaje_limite_intermedio!element],
			CAST((@vdPorcentajeSuperior/100) AS DECIMAL(5,3))
														AS [PARAM_CALCULO!5!porcentaje_limite_superior!element],
			@viAnnoInferior								AS [PARAM_CALCULO!5!annos_limite_inferior!element],
			@viAnnoIntermedio							AS [PARAM_CALCULO!5!annos_limite_intermedio!element],
			NULL										AS [OPERACIONES_ASOCIADAS!6!],
			NULL										AS [OPERACION!7!contabilidad!element],
	   		NULL										AS [OPERACION!7!oficina!element],
			NULL										AS [OPERACION!7!moneda!element],
			NULL										AS [OPERACION!7!producto!element],
			NULL										AS [OPERACION!7!numeroOperacion!element],
			NULL										AS [OPERACION!7!tipoOperacion!element],
			NULL										AS [OPERACION!7!codigoOperacion!element],
			NULL										AS [OPERACION!7!codigoGarantia!element],
			NULL										AS [OPERACION!7!Monto_Acreencia_Poliza!element],
			NULL										AS [SEMESTRES_A_CALCULAR!8!],
			NULL										AS [SEMESTRE!9!Numero_Semestre!element],
			NULL										AS [SEMESTRE!9!Fecha_Semestre!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio!element],
			NULL										AS [SEMESTRE!9!IPC!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio_Anterior!element],
			NULL										AS [SEMESTRE!9!IPC_Anterior!element],
			NULL										AS [SEMESTRE!9!Total_Registros!element],
			NULL										AS [POLIZAS!10!],
			NULL										AS [POLIZA!11!Codigo_SAP!element],
			NULL										AS [POLIZA!11!Tipo_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza!element],
			NULL										AS [POLIZA!11!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor!element],
			NULL										AS [POLIZA!11!Monto_Acreencia!element],
			NULL										AS [POLIZA!11!Detalle_Poliza!element],
			NULL										AS [POLIZA!11!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!11!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!11!Codigo_Sap_Valido!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Anterior!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento_Anterior!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Tipo_Bien_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Colonizado!element],
			NULL										AS [POLIZA!11!Poliza_Asociada!element]
	WHERE	@viTipoBien IN (-1, 1, 2)
	
	UNION ALL

	SELECT DISTINCT	
			6											AS Tag,
			1											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia!element], 
			NULL										AS [GARANTIA!2!cod_clase_garantia!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!des_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_partido!element], 
			NULL										AS [GARANTIA!2!numero_finca!element], 
			NULL										AS [GARANTIA!2!cod_grado!element], 
			NULL										AS [GARANTIA!2!cedula_hipotecaria!element], 
			NULL										AS [GARANTIA!2!cod_clase_bien!element], 
			NULL										AS [GARANTIA!2!num_placa_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_tipo_documento_legal!element], 
			NULL										AS [GARANTIA!2!monto_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_inscripcion!element], 
			NULL										AS [GARANTIA!2!fecha_presentacion!element], 
			NULL										AS [GARANTIA!2!porcentaje_responsabilidad!element], 
			NULL										AS [GARANTIA!2!cod_grado_gravamen!element], 
			NULL										AS [GARANTIA!2!cod_operacion_especial!element], 
			NULL										AS [GARANTIA!2!fecha_constitucion!element], 
			NULL										AS [GARANTIA!2!fecha_vencimiento!element], 
			NULL										AS [GARANTIA!2!cod_tipo_acreedor!element], 
			NULL										AS [GARANTIA!2!ced_acreedor!element], 
			NULL										AS [GARANTIA!2!cod_liquidez!element], 
			NULL										AS [GARANTIA!2!cod_tenencia!element], 
			NULL										AS [GARANTIA!2!cod_moneda!element], 
			NULL										AS [GARANTIA!2!fecha_prescripcion!element],
			NULL										AS [GARANTIA!2!cod_estado!element],
			NULL										AS [GARANTIA!2!fecha_valuacion!element],
			NULL										AS [GARANTIA!2!monto_total_avaluo!element],
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!des_tipo_documento!element],
			NULL										AS [GARANTIA!2!des_tipo_inscripcion!element],
			NULL										AS [GARANTIA!2!des_tipo_grado_gravamen!element],
			NULL										AS [GARANTIA!2!des_tipo_operacion_especial!element],
			NULL										AS [GARANTIA!2!des_tipo_persona!element],
			NULL										AS [GARANTIA!2!des_tipo_liquidez!element],
			NULL										AS [GARANTIA!2!des_tipo_tenencia!element],
			NULL										AS [GARANTIA!2!des_tipo_moneda!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Nombre_Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Inserto!element],
			NULL										AS [GARANTIA!2!Fecha_Replica!element],
			NULL										AS [GARANTIA!2!Porcentaje_Aceptacion_Calculado!element],
			NULL										AS [GARANTIA!2!Indicador_Vivienda_Habitada_Deudor!element],			
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!penultima_fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_actual!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!avaluo_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_semestre_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion_sicc!element],		
			NULL										AS [AVALUO_SICC!4!prmgt_pfeavaing!element],
			NULL										AS [AVALUO_SICC!4!prmgt_pmoavaing!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_intermedio!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_superior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_intermedio!element],
			NULL										AS [OPERACIONES_ASOCIADAS!6!],
			NULL										AS [OPERACION!7!contabilidad!element],
	   		NULL										AS [OPERACION!7!oficina!element],
			NULL										AS [OPERACION!7!moneda!element],
			NULL										AS [OPERACION!7!producto!element],
			NULL										AS [OPERACION!7!numeroOperacion!element],
			NULL										AS [OPERACION!7!tipoOperacion!element],
			NULL										AS [OPERACION!7!codigoOperacion!element],
			NULL										AS [OPERACION!7!codigoGarantia!element],
			NULL										AS [OPERACION!7!Monto_Acreencia_Poliza!element],
			NULL										AS [SEMESTRES_A_CALCULAR!8!],
			NULL										AS [SEMESTRE!9!Numero_Semestre!element],
			NULL										AS [SEMESTRE!9!Fecha_Semestre!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio!element],
			NULL										AS [SEMESTRE!9!IPC!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio_Anterior!element],
			NULL										AS [SEMESTRE!9!IPC_Anterior!element],
			NULL										AS [SEMESTRE!9!Total_Registros!element],
			NULL										AS [POLIZAS!10!],
			NULL										AS [POLIZA!11!Codigo_SAP!element],
			NULL										AS [POLIZA!11!Tipo_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza!element],
			NULL										AS [POLIZA!11!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor!element],
			NULL										AS [POLIZA!11!Monto_Acreencia!element],
			NULL										AS [POLIZA!11!Detalle_Poliza!element],
			NULL										AS [POLIZA!11!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!11!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!11!Codigo_Sap_Valido!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Anterior!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento_Anterior!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Tipo_Bien_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Colonizado!element],
			NULL										AS [POLIZA!11!Poliza_Asociada!element]

	UNION ALL

	SELECT DISTINCT	
			7											AS Tag,
			6											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia!element], 
			NULL										AS [GARANTIA!2!cod_clase_garantia!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!des_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_partido!element], 
			NULL										AS [GARANTIA!2!numero_finca!element], 
			NULL										AS [GARANTIA!2!cod_grado!element], 
			NULL										AS [GARANTIA!2!cedula_hipotecaria!element], 
			NULL										AS [GARANTIA!2!cod_clase_bien!element], 
			NULL										AS [GARANTIA!2!num_placa_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_tipo_documento_legal!element], 
			NULL										AS [GARANTIA!2!monto_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_inscripcion!element], 
			NULL										AS [GARANTIA!2!fecha_presentacion!element], 
			NULL										AS [GARANTIA!2!porcentaje_responsabilidad!element], 
			NULL										AS [GARANTIA!2!cod_grado_gravamen!element], 
			NULL										AS [GARANTIA!2!cod_operacion_especial!element], 
			NULL										AS [GARANTIA!2!fecha_constitucion!element], 
			NULL										AS [GARANTIA!2!fecha_vencimiento!element], 
			NULL										AS [GARANTIA!2!cod_tipo_acreedor!element], 
			NULL										AS [GARANTIA!2!ced_acreedor!element], 
			NULL										AS [GARANTIA!2!cod_liquidez!element], 
			NULL										AS [GARANTIA!2!cod_tenencia!element], 
			NULL										AS [GARANTIA!2!cod_moneda!element], 
			NULL										AS [GARANTIA!2!fecha_prescripcion!element],
			NULL										AS [GARANTIA!2!cod_estado!element],
			NULL										AS [GARANTIA!2!fecha_valuacion!element],
			NULL										AS [GARANTIA!2!monto_total_avaluo!element],
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!des_tipo_documento!element],
			NULL										AS [GARANTIA!2!des_tipo_inscripcion!element],
			NULL										AS [GARANTIA!2!des_tipo_grado_gravamen!element],
			NULL										AS [GARANTIA!2!des_tipo_operacion_especial!element],
			NULL										AS [GARANTIA!2!des_tipo_persona!element],
			NULL										AS [GARANTIA!2!des_tipo_liquidez!element],
			NULL										AS [GARANTIA!2!des_tipo_tenencia!element],
			NULL										AS [GARANTIA!2!des_tipo_moneda!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Nombre_Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Inserto!element],
			NULL										AS [GARANTIA!2!Fecha_Replica!element],
			NULL										AS [GARANTIA!2!Porcentaje_Aceptacion_Calculado!element],	
			NULL										AS [GARANTIA!2!Indicador_Vivienda_Habitada_Deudor!element],			
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!penultima_fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_actual!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!avaluo_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_semestre_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion_sicc!element],		
			NULL										AS [AVALUO_SICC!4!prmgt_pfeavaing!element],
			NULL										AS [AVALUO_SICC!4!prmgt_pmoavaing!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_intermedio!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_superior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_intermedio!element],
			NULL										AS [OPERACIONES_ASOCIADAS!6!],
			OGV.Codigo_Contabilidad						AS [OPERACION!7!contabilidad!element],
			OGV.Codigo_Oficina							AS [OPERACION!7!oficina!element],
			OGV.Codigo_Moneda							AS [OPERACION!7!moneda!element],
			OGV.Codigo_Producto							AS [OPERACION!7!producto!element],
			OGV.Operacion								AS [OPERACION!7!numeroOperacion!element],
			OGV.Tipo_Operacion							AS [OPERACION!7!tipoOperacion!element],
			OGV.Codigo_Operacion						AS [OPERACION!7!codigoOperacion!element],
			OGV.Consecutivo_Garantia					AS [OPERACION!7!codigoGarantia!element],
			OGV.Monto_Acreencia							AS [OPERACION!7!Monto_Acreencia_Poliza!element],
			NULL										AS [SEMESTRES_A_CALCULAR!8!],
			NULL										AS [SEMESTRE!9!Numero_Semestre!element],
			NULL										AS [SEMESTRE!9!Fecha_Semestre!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio!element],
			NULL										AS [SEMESTRE!9!IPC!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio_Anterior!element],
			NULL										AS [SEMESTRE!9!IPC_Anterior!element],
			NULL										AS [SEMESTRE!9!Total_Registros!element],
			NULL										AS [POLIZAS!10!],
			NULL										AS [POLIZA!11!Codigo_SAP!element],
			NULL										AS [POLIZA!11!Tipo_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza!element],
			NULL										AS [POLIZA!11!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor!element],
			NULL										AS [POLIZA!11!Monto_Acreencia!element],
			NULL										AS [POLIZA!11!Detalle_Poliza!element],
			NULL										AS [POLIZA!11!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!11!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!11!Codigo_Sap_Valido!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Anterior!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento_Anterior!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Tipo_Bien_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Colonizado!element],
			NULL										AS [POLIZA!11!Poliza_Asociada!element]
	FROM	dbo.Obtener_Operaciones_Comunes_FT(@piOperacion, @piGarantia, @vsCodigo_Bien, @vdtFecha_Actual) OGV
	WHERE	OGV.Codigo_Operacion <> @piOperacion

	UNION ALL

	SELECT DISTINCT	
			8											AS Tag,
			1											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia!element], 
			NULL										AS [GARANTIA!2!cod_clase_garantia!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!des_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_partido!element], 
			NULL										AS [GARANTIA!2!numero_finca!element], 
			NULL										AS [GARANTIA!2!cod_grado!element], 
			NULL										AS [GARANTIA!2!cedula_hipotecaria!element], 
			NULL										AS [GARANTIA!2!cod_clase_bien!element], 
			NULL										AS [GARANTIA!2!num_placa_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_tipo_documento_legal!element], 
			NULL										AS [GARANTIA!2!monto_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_inscripcion!element], 
			NULL										AS [GARANTIA!2!fecha_presentacion!element], 
			NULL										AS [GARANTIA!2!porcentaje_responsabilidad!element], 
			NULL										AS [GARANTIA!2!cod_grado_gravamen!element], 
			NULL										AS [GARANTIA!2!cod_operacion_especial!element], 
			NULL										AS [GARANTIA!2!fecha_constitucion!element], 
			NULL										AS [GARANTIA!2!fecha_vencimiento!element], 
			NULL										AS [GARANTIA!2!cod_tipo_acreedor!element], 
			NULL										AS [GARANTIA!2!ced_acreedor!element], 
			NULL										AS [GARANTIA!2!cod_liquidez!element], 
			NULL										AS [GARANTIA!2!cod_tenencia!element], 
			NULL										AS [GARANTIA!2!cod_moneda!element], 
			NULL										AS [GARANTIA!2!fecha_prescripcion!element],
			NULL										AS [GARANTIA!2!cod_estado!element],
			NULL										AS [GARANTIA!2!fecha_valuacion!element],
			NULL										AS [GARANTIA!2!monto_total_avaluo!element],
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!des_tipo_documento!element],
			NULL										AS [GARANTIA!2!des_tipo_inscripcion!element],
			NULL										AS [GARANTIA!2!des_tipo_grado_gravamen!element],
			NULL										AS [GARANTIA!2!des_tipo_operacion_especial!element],
			NULL										AS [GARANTIA!2!des_tipo_persona!element],
			NULL										AS [GARANTIA!2!des_tipo_liquidez!element],
			NULL										AS [GARANTIA!2!des_tipo_tenencia!element],
			NULL										AS [GARANTIA!2!des_tipo_moneda!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Nombre_Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Inserto!element],
			NULL										AS [GARANTIA!2!Fecha_Replica!element],
			NULL										AS [GARANTIA!2!Porcentaje_Aceptacion_Calculado!element],
			NULL										AS [GARANTIA!2!Indicador_Vivienda_Habitada_Deudor!element],			
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!penultima_fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_actual!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!avaluo_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_semestre_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion_sicc!element],		
			NULL										AS [AVALUO_SICC!4!prmgt_pfeavaing!element],
			NULL										AS [AVALUO_SICC!4!prmgt_pmoavaing!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_intermedio!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_superior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_intermedio!element],
			NULL										AS [OPERACIONES_ASOCIADAS!6!],
			NULL										AS [OPERACION!7!contabilidad!element],
	   		NULL										AS [OPERACION!7!oficina!element],
			NULL										AS [OPERACION!7!moneda!element],
			NULL										AS [OPERACION!7!producto!element],
			NULL										AS [OPERACION!7!numeroOperacion!element],
			NULL										AS [OPERACION!7!tipoOperacion!element],
			NULL										AS [OPERACION!7!codigoOperacion!element],
			NULL										AS [OPERACION!7!codigoGarantia!element],
			NULL										AS [OPERACION!7!Monto_Acreencia_Poliza!element],
			NULL										AS [SEMESTRES_A_CALCULAR!8!],
			NULL										AS [SEMESTRE!9!Numero_Semestre!element],
			NULL										AS [SEMESTRE!9!Fecha_Semestre!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio!element],
			NULL										AS [SEMESTRE!9!IPC!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio_Anterior!element],
			NULL										AS [SEMESTRE!9!IPC_Anterior!element],
			NULL										AS [SEMESTRE!9!Total_Registros!element],
			NULL										AS [POLIZAS!10!],
			NULL										AS [POLIZA!11!Codigo_SAP!element],
			NULL										AS [POLIZA!11!Tipo_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza!element],
			NULL										AS [POLIZA!11!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor!element],
			NULL										AS [POLIZA!11!Monto_Acreencia!element],
			NULL										AS [POLIZA!11!Detalle_Poliza!element],
			NULL										AS [POLIZA!11!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!11!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!11!Codigo_Sap_Valido!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Anterior!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento_Anterior!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Tipo_Bien_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Colonizado!element],
			NULL										AS [POLIZA!11!Poliza_Asociada!element]

	UNION ALL

	SELECT DISTINCT	
			9											AS Tag,
			8											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia!element], 
			NULL										AS [GARANTIA!2!cod_clase_garantia!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!des_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_partido!element], 
			NULL										AS [GARANTIA!2!numero_finca!element], 
			NULL										AS [GARANTIA!2!cod_grado!element], 
			NULL										AS [GARANTIA!2!cedula_hipotecaria!element], 
			NULL										AS [GARANTIA!2!cod_clase_bien!element], 
			NULL										AS [GARANTIA!2!num_placa_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_tipo_documento_legal!element], 
			NULL										AS [GARANTIA!2!monto_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_inscripcion!element], 
			NULL										AS [GARANTIA!2!fecha_presentacion!element], 
			NULL										AS [GARANTIA!2!porcentaje_responsabilidad!element], 
			NULL										AS [GARANTIA!2!cod_grado_gravamen!element], 
			NULL										AS [GARANTIA!2!cod_operacion_especial!element], 
			NULL										AS [GARANTIA!2!fecha_constitucion!element], 
			NULL										AS [GARANTIA!2!fecha_vencimiento!element], 
			NULL										AS [GARANTIA!2!cod_tipo_acreedor!element], 
			NULL										AS [GARANTIA!2!ced_acreedor!element], 
			NULL										AS [GARANTIA!2!cod_liquidez!element], 
			NULL										AS [GARANTIA!2!cod_tenencia!element], 
			NULL										AS [GARANTIA!2!cod_moneda!element], 
			NULL										AS [GARANTIA!2!fecha_prescripcion!element],
			NULL										AS [GARANTIA!2!cod_estado!element],
			NULL										AS [GARANTIA!2!fecha_valuacion!element],
			NULL										AS [GARANTIA!2!monto_total_avaluo!element],
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!des_tipo_documento!element],
			NULL										AS [GARANTIA!2!des_tipo_inscripcion!element],
			NULL										AS [GARANTIA!2!des_tipo_grado_gravamen!element],
			NULL										AS [GARANTIA!2!des_tipo_operacion_especial!element],
			NULL										AS [GARANTIA!2!des_tipo_persona!element],
			NULL										AS [GARANTIA!2!des_tipo_liquidez!element],
			NULL										AS [GARANTIA!2!des_tipo_tenencia!element],
			NULL										AS [GARANTIA!2!des_tipo_moneda!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Nombre_Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Inserto!element],
			NULL										AS [GARANTIA!2!Fecha_Replica!element],
			NULL										AS [GARANTIA!2!Porcentaje_Aceptacion_Calculado!element],
			NULL										AS [GARANTIA!2!Indicador_Vivienda_Habitada_Deudor!element],			
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!penultima_fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_actual!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!avaluo_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_semestre_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion_sicc!element],		
			NULL										AS [AVALUO_SICC!4!prmgt_pfeavaing!element],
			NULL										AS [AVALUO_SICC!4!prmgt_pmoavaing!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_intermedio!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_superior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_intermedio!element],
			NULL										AS [OPERACIONES_ASOCIADAS!6!],
			NULL										AS [OPERACION!7!contabilidad!element],
	   		NULL										AS [OPERACION!7!oficina!element],
			NULL										AS [OPERACION!7!moneda!element],
			NULL										AS [OPERACION!7!producto!element],
			NULL										AS [OPERACION!7!numeroOperacion!element],
			NULL										AS [OPERACION!7!tipoOperacion!element],
			NULL										AS [OPERACION!7!codigoOperacion!element],
			NULL										AS [OPERACION!7!codigoGarantia!element],
			NULL										AS [OPERACION!7!Monto_Acreencia_Poliza!element],
			NULL										AS [SEMESTRES_A_CALCULAR!8!],
			OFS.Numero_Semestre							AS [SEMESTRE!9!Numero_Semestre!element],
			OFS.Fecha_Semestre							AS [SEMESTRE!9!Fecha_Semestre!element],
			OFS.Tipo_Cambio								AS [SEMESTRE!9!Tipo_Cambio!element],
			OFS.IPC										AS [SEMESTRE!9!IPC!element],
			OFS.Tipo_Cambio_Anterior					AS [SEMESTRE!9!Tipo_Cambio_Anterior!element],
			OFS.IPC_Anterior							AS [SEMESTRE!9!IPC_Anterior!element],
			OFS.Total_Registros							AS [SEMESTRE!9!Total_Registros!element],
			NULL										AS [POLIZAS!10!],
			NULL										AS [POLIZA!11!Codigo_SAP!element],
			NULL										AS [POLIZA!11!Tipo_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza!element],
			NULL										AS [POLIZA!11!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor!element],
			NULL										AS [POLIZA!11!Monto_Acreencia!element],
			NULL										AS [POLIZA!11!Detalle_Poliza!element],
			NULL										AS [POLIZA!11!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!11!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!11!Codigo_Sap_Valido!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Anterior!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento_Anterior!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Tipo_Bien_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Colonizado!element],
			NULL										AS [POLIZA!11!Poliza_Asociada!element]
	
	FROM	Obtener_Fechas_Semestrales_FT(@vdtFecha_Avaluo, @vdtFecha_Actual, @piGarantia) OFS
	WHERE	@viTipoBien IN (-1, 1, 2)

	UNION ALL
	
	SELECT DISTINCT	
			10											AS Tag,
			1											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia!element], 
			NULL										AS [GARANTIA!2!cod_clase_garantia!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!des_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_partido!element], 
			NULL										AS [GARANTIA!2!numero_finca!element], 
			NULL										AS [GARANTIA!2!cod_grado!element], 
			NULL										AS [GARANTIA!2!cedula_hipotecaria!element], 
			NULL										AS [GARANTIA!2!cod_clase_bien!element], 
			NULL										AS [GARANTIA!2!num_placa_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_tipo_documento_legal!element], 
			NULL										AS [GARANTIA!2!monto_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_inscripcion!element], 
			NULL										AS [GARANTIA!2!fecha_presentacion!element], 
			NULL										AS [GARANTIA!2!porcentaje_responsabilidad!element], 
			NULL										AS [GARANTIA!2!cod_grado_gravamen!element], 
			NULL										AS [GARANTIA!2!cod_operacion_especial!element], 
			NULL										AS [GARANTIA!2!fecha_constitucion!element], 
			NULL										AS [GARANTIA!2!fecha_vencimiento!element], 
			NULL										AS [GARANTIA!2!cod_tipo_acreedor!element], 
			NULL										AS [GARANTIA!2!ced_acreedor!element], 
			NULL										AS [GARANTIA!2!cod_liquidez!element], 
			NULL										AS [GARANTIA!2!cod_tenencia!element], 
			NULL										AS [GARANTIA!2!cod_moneda!element], 
			NULL										AS [GARANTIA!2!fecha_prescripcion!element],
			NULL										AS [GARANTIA!2!cod_estado!element],
			NULL										AS [GARANTIA!2!fecha_valuacion!element],
			NULL										AS [GARANTIA!2!monto_total_avaluo!element],
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!des_tipo_documento!element],
			NULL										AS [GARANTIA!2!des_tipo_inscripcion!element],
			NULL										AS [GARANTIA!2!des_tipo_grado_gravamen!element],
			NULL										AS [GARANTIA!2!des_tipo_operacion_especial!element],
			NULL										AS [GARANTIA!2!des_tipo_persona!element],
			NULL										AS [GARANTIA!2!des_tipo_liquidez!element],
			NULL										AS [GARANTIA!2!des_tipo_tenencia!element],
			NULL										AS [GARANTIA!2!des_tipo_moneda!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Nombre_Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Inserto!element],
			NULL										AS [GARANTIA!2!Fecha_Replica!element],
			NULL										AS [GARANTIA!2!Porcentaje_Aceptacion_Calculado!element],
			NULL										AS [GARANTIA!2!Indicador_Vivienda_Habitada_Deudor!element],			
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!penultima_fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_actual!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!avaluo_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_semestre_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion_sicc!element],		
			NULL										AS [AVALUO_SICC!4!prmgt_pfeavaing!element],
			NULL										AS [AVALUO_SICC!4!prmgt_pmoavaing!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_intermedio!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_superior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_intermedio!element],
			NULL										AS [OPERACIONES_ASOCIADAS!6!],
			NULL										AS [OPERACION!7!contabilidad!element],
	   		NULL										AS [OPERACION!7!oficina!element],
			NULL										AS [OPERACION!7!moneda!element],
			NULL										AS [OPERACION!7!producto!element],
			NULL										AS [OPERACION!7!numeroOperacion!element],
			NULL										AS [OPERACION!7!tipoOperacion!element],
			NULL										AS [OPERACION!7!codigoOperacion!element],
			NULL										AS [OPERACION!7!codigoGarantia!element],
			NULL										AS [OPERACION!7!Monto_Acreencia_Poliza!element],
			NULL										AS [SEMESTRES_A_CALCULAR!8!],
			NULL										AS [SEMESTRE!9!Numero_Semestre!element],
			NULL										AS [SEMESTRE!9!Fecha_Semestre!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio!element],
			NULL										AS [SEMESTRE!9!IPC!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio_Anterior!element],
			NULL										AS [SEMESTRE!9!IPC_Anterior!element],
			NULL										AS [SEMESTRE!9!Total_Registros!element],
			NULL										AS [POLIZAS!10!],
			NULL										AS [POLIZA!11!Codigo_SAP!element],
			NULL										AS [POLIZA!11!Tipo_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza!element],
			NULL										AS [POLIZA!11!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor!element],
			NULL										AS [POLIZA!11!Monto_Acreencia!element],
			NULL										AS [POLIZA!11!Detalle_Poliza!element],
			NULL										AS [POLIZA!11!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!11!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!11!Codigo_Sap_Valido!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Anterior!element],
			NULL										AS [POLIZA!11!Fecha_Vencimiento_Anterior!element],
			NULL										AS [POLIZA!11!Cedula_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Nombre_Acreedor_Anterior!element],
			NULL										AS [POLIZA!11!Tipo_Bien_Poliza!element],
			NULL										AS [POLIZA!11!Monto_Poliza_Colonizado!element],
			NULL										AS [POLIZA!11!Poliza_Asociada!element]

	UNION ALL
	
	SELECT DISTINCT	
			11											AS Tag,
			10											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia!element], 
			NULL										AS [GARANTIA!2!cod_clase_garantia!element], 
			NULL										AS [GARANTIA!2!cod_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!des_tipo_garantia_real!element], 
			NULL										AS [GARANTIA!2!garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_partido!element], 
			NULL										AS [GARANTIA!2!numero_finca!element], 
			NULL										AS [GARANTIA!2!cod_grado!element], 
			NULL										AS [GARANTIA!2!cedula_hipotecaria!element], 
			NULL										AS [GARANTIA!2!cod_clase_bien!element], 
			NULL										AS [GARANTIA!2!num_placa_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_tipo_documento_legal!element], 
			NULL										AS [GARANTIA!2!monto_mitigador!element], 
			NULL										AS [GARANTIA!2!cod_inscripcion!element], 
			NULL										AS [GARANTIA!2!fecha_presentacion!element], 
			NULL										AS [GARANTIA!2!porcentaje_responsabilidad!element], 
			NULL										AS [GARANTIA!2!cod_grado_gravamen!element], 
			NULL										AS [GARANTIA!2!cod_operacion_especial!element], 
			NULL										AS [GARANTIA!2!fecha_constitucion!element], 
			NULL										AS [GARANTIA!2!fecha_vencimiento!element], 
			NULL										AS [GARANTIA!2!cod_tipo_acreedor!element], 
			NULL										AS [GARANTIA!2!ced_acreedor!element], 
			NULL										AS [GARANTIA!2!cod_liquidez!element], 
			NULL										AS [GARANTIA!2!cod_tenencia!element], 
			NULL										AS [GARANTIA!2!cod_moneda!element], 
			NULL										AS [GARANTIA!2!fecha_prescripcion!element],
			NULL										AS [GARANTIA!2!cod_estado!element],
			NULL										AS [GARANTIA!2!fecha_valuacion!element],
			NULL										AS [GARANTIA!2!monto_total_avaluo!element],
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!des_tipo_documento!element],
			NULL										AS [GARANTIA!2!des_tipo_inscripcion!element],
			NULL										AS [GARANTIA!2!des_tipo_grado_gravamen!element],
			NULL										AS [GARANTIA!2!des_tipo_operacion_especial!element],
			NULL										AS [GARANTIA!2!des_tipo_persona!element],
			NULL										AS [GARANTIA!2!des_tipo_liquidez!element],
			NULL										AS [GARANTIA!2!des_tipo_tenencia!element],
			NULL										AS [GARANTIA!2!des_tipo_moneda!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Nombre_Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Inserto!element],
			NULL										AS [GARANTIA!2!Fecha_Replica!element],
			NULL										AS [GARANTIA!2!Porcentaje_Aceptacion_Calculado!element],
			NULL										AS [GARANTIA!2!Indicador_Vivienda_Habitada_Deudor!element],			
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!penultima_fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_actual!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!avaluo_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_semestre_actualizado!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion_sicc!element],		
			NULL										AS [AVALUO_SICC!4!prmgt_pfeavaing!element],
			NULL										AS [AVALUO_SICC!4!prmgt_pmoavaing!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_intermedio!element],
			NULL										AS [PARAM_CALCULO!5!porcentaje_limite_superior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_inferior!element],
			NULL										AS [PARAM_CALCULO!5!annos_limite_intermedio!element],
			NULL										AS [OPERACIONES_ASOCIADAS!6!],
			NULL										AS [OPERACION!7!contabilidad!element],
	   		NULL										AS [OPERACION!7!oficina!element],
			NULL										AS [OPERACION!7!moneda!element],
			NULL										AS [OPERACION!7!producto!element],
			NULL										AS [OPERACION!7!numeroOperacion!element],
			NULL										AS [OPERACION!7!tipoOperacion!element],
			NULL										AS [OPERACION!7!codigoOperacion!element],
			NULL										AS [OPERACION!7!codigoGarantia!element],
			NULL										AS [OPERACION!7!Monto_Acreencia_Poliza!element],
			NULL										AS [SEMESTRES_A_CALCULAR!8!],
			NULL										AS [SEMESTRE!9!Numero_Semestre!element],
			NULL										AS [SEMESTRE!9!Fecha_Semestre!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio!element],
			NULL										AS [SEMESTRE!9!IPC!element],
			NULL										AS [SEMESTRE!9!Tipo_Cambio_Anterior!element],
			NULL										AS [SEMESTRE!9!IPC_Anterior!element],
			NULL										AS [SEMESTRE!9!Total_Registros!element],
			NULL										AS [POLIZAS!10!],
			GPO.Codigo_SAP								AS [POLIZA!11!Codigo_SAP!element],
			GPO.Tipo_Poliza								AS [POLIZA!11!Tipo_Poliza!element],
			GPO.Monto_Poliza							AS [POLIZA!11!Monto_Poliza!element],
			GPO.Moneda_Monto_Poliza						AS [POLIZA!11!Moneda_Monto_Poliza!element],
			COALESCE((CONVERT(VARCHAR(10), GPO.Fecha_Vencimiento, 103)), '')	
														AS [POLIZA!11!Fecha_Vencimiento!element],
			GPO.Cedula_Acreedor							AS [POLIZA!11!Cedula_Acreedor!element],
			GPO.Nombre_Acreedor							AS [POLIZA!11!Nombre_Acreedor!element],
			GAP.Monto_Acreencia							AS [POLIZA!11!Monto_Acreencia!element],
			--REPLACE((REPLACE((REPLACE((COALESCE(GPO.Detalle_Poliza, '')), '"', '\\"')), CHAR(10), '\\r')), CHAR(13), '\\n') AS [POLIZA!11!Detalle_Poliza!element],
			COALESCE(GPO.Detalle_Poliza, '') AS [POLIZA!11!Detalle_Poliza!element],
			CASE
				WHEN ((GPO.Estado_Registro = 1) AND (COALESCE(GAP.Estado_Registro, 0) = 1)) THEN 1
				ELSE 0
			END											AS [POLIZA!11!Poliza_Seleccionada!element],
			COALESCE(CE1.cat_descripcion, '')			AS [POLIZA!11!Descripcion_Tipo_Poliza_Sap!element],
			COALESCE(CONVERT(CHAR(1), GPO.Estado_Registro), '') 	AS [POLIZA!11!Codigo_Sap_Valido!element],
			COALESCE(GPO.Monto_Poliza_Anterior, GPO.Monto_Poliza_Colonizado)	AS [POLIZA!11!Monto_Poliza_Anterior!element],
			COALESCE((CONVERT(VARCHAR(10), GPO.Fecha_Vencimiento_Anterior, 103)), '') AS [POLIZA!11!Fecha_Vencimiento_Anterior!element],
			COALESCE(GPO.Cedula_Acreedor_Anterior, '')	AS [POLIZA!11!Cedula_Acreedor_Anterior!element],
			COALESCE(GPO.Nombre_Acreedor_Anterior, '')	AS [POLIZA!11!Nombre_Acreedor_Anterior!element],
			COALESCE(TPB.Codigo_Tipo_Bien, -1)			AS [POLIZA!11!Tipo_Bien_Poliza!element],
			GPO.Monto_Poliza_Colonizado					AS [POLIZA!11!Monto_Poliza_Colonizado!element],
			CASE
				WHEN GAP.Estado_Registro IS NULL THEN 0
				ELSE 1
			END											AS [POLIZA!11!Poliza_Asociada!element]
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

	FOR		XML EXPLICIT

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

