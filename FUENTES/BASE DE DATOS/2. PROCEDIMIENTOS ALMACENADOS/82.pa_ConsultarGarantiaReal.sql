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
	<Versión>2.1</Versión>
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
			<Autor>Arnoldo Martinelli Marín, GrupoMas S.A.</Autor>
			<Requerimiento>RQ_MANT_2015062410418218_00025 Segmentación campos % aceptacion Terreno y No terreno</Requerimiento>
			<Fecha>18/09/2015</Fecha>
			<Descripción>
				Se incorpora la obtención de los campos referentes al porcentaje de aceptación del terreno, porcentaje de aceptación del no terreno,
				porcentaje de aceptación del terreno calculado y el porcentaje de aceptación del no terreno calculado.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>02/12/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptación, este campo reemplazará al camp oporcentaje de responsabilidad dentro de 
				cualquier lógica existente. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00615, Mantenimiento de Saldos Totales y Procentajes de Responsabilidad</Requerimiento>
			<Fecha>10/03/2016</Fecha>
			<Descripción>
				El cambio es referente a la extracción de nuevos campos necesarios.
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
	DECLARE @viCatalogo_Tipo_Garantia_Real			SMALLINT, -- Catálogo de tipos de garantías reales = 23
			@viCatalogo_Tipo_Bien				SMALLINT, -- Catálogo de tipos de bien = 12
			@viCatalogo_Tipo_Mitigador			SMALLINT, -- Catálogo de tipos de mitigadores de riesgo = 22
			@viCatalogo_Tipo_Documento_Legal	SMALLINT, -- Catálogo de tipos de documentos legales = 8
			@viCatalogo_Indicador_Inscripcion			SMALLINT, -- Catálogo de indicadores de inscripción = 9
			@viCatalogo_Grado_Gravamen			SMALLINT, -- Catálogo de grados de gravamen = 10
			@viCatalogo_Operacion_Especial		SMALLINT, -- Catálogo de tipos operaciones especiales = 11
			@viCatalogo_Tipo_Persona			SMALLINT, -- Catálogo de tipos de persona = 1
			@viCatalogo_Tipo_Liquidez			SMALLINT, -- Catálogo de tipos de liquidez = 13
			@viCatalogo_Tipo_Tenencia			SMALLINT, -- Catálogo de tipos de tenencia = 14
			@viCatalogo_Tipo_Moneda			SMALLINT, -- Catálogo de tipos de moneda = 15
			@viCatalogo_Parametros_Calculo		SMALLINT, -- Catálogo de los parámetros usados para le cálculo del monto de la tasación actualizada del no terreno = 28
			@viCatalogoTipos_Polizas_Sap		SMALLINT, -- Catálogo de los tipos de pólizas SAP.
			@vsCodigo_Bien				VARCHAR(30), -- Código del bien que será usado para obtener las operaciones en la cuales participa.
			@vbObtener_Operaciones		BIT, -- Indica si se deben obtener las operaciones en las cuales participa la garantía.
			@vdtFecha_Actual			DATETIME, --Fecha actual del sistema
			@vdtFecha_Avaluo			DATETIME, --Fecha del avalúo más reciente
			@vdMonto_Avaluo_SICC			DECIMAL(14,2), --Monto mínimo del avalúo de una garantía
			@vdPorcentaje_Inferior		DECIMAL(5,2), -- Porcentaje correpondiente al límite inferior
			@vdPorcentaje_Intermedio		DECIMAL(5,2), -- Porcentaje correpondiente al límite intermedio
			@vdPorcentaje_Superior		DECIMAL(5,2), -- Porcentaje correpondiente al límite superior
			@viAnno_Inferior				SMALLINT, -- Año correpondiente al límite inferior
			@viAnno_Intermedio			SMALLINT, -- Año correpondiente al límite intermedio/superior
			@viTipo_Bien					SMALLINT,  -- Código del tipo de bien asignado a la garantía
			@viFecha_Actual_Entera		INT, --Corresponde al a fecha actual en formato numérico.
			@viFecha_Valuacion_Entera		INT, -- Fecha de valuación registrada enel SICC
			@vsNombre_Usuario_Modifico	VARCHAR(100), --Nombre el usuario que modifico la garantia			
			@viClase_Garantia			SMALLINT, --Código de la clase de garantía
			@viCodigo_Partido			SMALLINT, --Código del partido
			@vdIdentificacion_Bien		DECIMAL(12,0), --Identificación numérica del bien
			@vsIdentificacion_Bien		VARCHAR(25) --Identificación alfanumérica del bien

	--Inicialización de variables
	--Se asignan los códigos de los catálogos  
	SET @viCatalogo_Tipo_Persona			= 1
	SET @viCatalogo_Tipo_Documento_Legal	= 8
	SET @viCatalogo_Indicador_Inscripcion	= 9
    SET @viCatalogo_Grado_Gravamen			= 10
	SET @viCatalogo_Operacion_Especial		= 11
	SET @viCatalogo_Tipo_Bien				= 12		
	SET @viCatalogo_Tipo_Liquidez			= 13
	SET @viCatalogo_Tipo_Tenencia			= 14
	SET @viCatalogo_Tipo_Moneda				= 15
	SET @viCatalogo_Tipo_Mitigador			= 22
	SET	@viCatalogo_Tipo_Garantia_Real		= 23
	SET @viCatalogo_Parametros_Calculo		= 28
	SET	@viCatalogoTipos_Polizas_Sap		= 29

	SET @vsCodigo_Bien	= (SELECT	CASE GGR.cod_tipo_garantia_real  
										WHEN 1 THEN COALESCE((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + '-' + COALESCE(GGR.numero_finca, '')  
										WHEN 2 THEN COALESCE((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + '-' + COALESCE(GGR.numero_finca, '') 
										WHEN 3 THEN COALESCE(GGR.cod_clase_bien, '') + '-' + COALESCE(GGR.num_placa_bien, '')
									END
							FROM	dbo.GAR_GARANTIA_REAL GGR 
							WHERE	GGR.cod_garantia_real = @piGarantia)

	SET	@vdtFecha_Actual = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	
	SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	
	SELECT	@viClase_Garantia = cod_clase_garantia,
			@viCodigo_Partido = CASE
									WHEN cod_clase_garantia BETWEEN 30 AND 69 THEN NULL
									ELSE cod_partido
								END,
			@vdIdentificacion_Bien = Identificacion_Sicc,
			@vsIdentificacion_Bien = Identificacion_Alfanumerica_Sicc
	FROM	dbo.GAR_GARANTIA_REAL
	WHERE	cod_garantia_real = @piGarantia

	SET @viFecha_Valuacion_Entera =	(	SELECT	MAX(TMP.prmgt_pfeavaing)
										FROM	
										(	SELECT	MAX(MGT.prmgt_pfeavaing) AS prmgt_pfeavaing
											FROM	dbo.GAR_SICC_PRMGT MGT
												INNER JOIN dbo.GAR_SICC_PRMOC MOC
												ON MOC.prmoc_pnu_oper = MGT.prmgt_pnu_oper
												AND MOC.prmoc_pco_ofici = MGT.prmgt_pco_ofici
												AND MOC.prmoc_pco_moned = MGT.prmgt_pco_moned
												AND MOC.prmoc_pco_produ = MGT.prmgt_pco_produ
												AND MOC.prmoc_pco_conta = MGT.prmgt_pco_conta
											WHERE	MGT.prmgt_estado = 'A'
												AND MGT.prmgt_pfeavaing > 0
												AND MGT.prmgt_pcoclagar	= @viClase_Garantia
												AND MGT.prmgt_pnu_part = COALESCE(@viCodigo_Partido, MGT.prmgt_pnu_part)
												AND MGT.prmgt_pnuidegar = @vdIdentificacion_Bien
												AND MGT.prmgt_pnuide_alf = @vsIdentificacion_Bien
												AND MOC.prmoc_pse_proces = 1
												AND MOC.prmoc_estado = 'A'
												AND MOC.prmoc_pnu_contr = 0
												AND ((MOC.prmoc_pcoctamay > 815)
													OR (MOC.prmoc_pcoctamay < 815))
												
											UNION ALL

											SELECT	MAX(MGT.prmgt_pfeavaing) AS prmgt_pfeavaing
											FROM	dbo.GAR_SICC_PRMGT MGT
												INNER JOIN dbo.GAR_SICC_PRMCA MCA
												ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper
												AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
												AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
												AND MGT.prmgt_pco_produ = 10
												AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
											WHERE	MGT.prmgt_estado = 'A'
												AND MGT.prmgt_pfeavaing > 0
												AND MGT.prmgt_pcoclagar	= @viClase_Garantia
												AND MGT.prmgt_pnu_part = COALESCE(@viCodigo_Partido, MGT.prmgt_pnu_part)
												AND MGT.prmgt_pnuidegar = @vdIdentificacion_Bien
												AND MGT.prmgt_pnuide_alf = @vsIdentificacion_Bien
												AND MCA.prmca_estado = 'A'
												AND MCA.prmca_pfe_defin >= @viFecha_Actual_Entera

											UNION ALL

											SELECT	MAX(MGT.prmgt_pfeavaing) AS prmgt_pfeavaing
											FROM	dbo.GAR_SICC_PRMGT MGT
												INNER JOIN dbo.GAR_SICC_PRMCA MCA
												ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper
												AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
												AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
												AND MGT.prmgt_pco_produ = 10
												AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
												INNER JOIN dbo.GAR_SICC_PRMOC MC1
												ON MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
												AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
												AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr
											WHERE	MGT.prmgt_estado = 'A'
												AND MGT.prmgt_pfeavaing > 0
												AND MGT.prmgt_pcoclagar	= @viClase_Garantia
												AND MGT.prmgt_pnu_part = COALESCE(@viCodigo_Partido, MGT.prmgt_pnu_part)
												AND MGT.prmgt_pnuidegar = @vdIdentificacion_Bien
												AND MGT.prmgt_pnuide_alf = @vsIdentificacion_Bien
												AND MCA.prmca_estado = 'A'
												AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
												AND MC1.prmoc_pse_proces = 1
												AND MC1.prmoc_estado = 'A'
												AND ((MC1.prmoc_pcoctamay > 815)
													OR (MC1.prmoc_pcoctamay < 815))

											GROUP BY MGT.prmgt_pcoclagar, MGT.prmgt_pnu_part, MGT.prmgt_pnuidegar, MGT.prmgt_pnuide_alf) TMP
										WHERE TMP.prmgt_pfeavaing IS NOT NULL)

	SET @vdtFecha_Avaluo =	CASE 
								WHEN @viFecha_Valuacion_Entera = 0 THEN NULL
								WHEN ISDATE(CONVERT(VARCHAR(10), @viFecha_Valuacion_Entera)) = 1 THEN CONVERT(VARCHAR(10), @viFecha_Valuacion_Entera,103)
								ELSE NULL
							END
							
	SET	@vdMonto_Avaluo_SICC	=	(	SELECT	COALESCE(MIN(TMP.prmgt_pmoavaing), 0)
										FROM	
										(	SELECT	MIN(MGT.prmgt_pmoavaing) AS prmgt_pmoavaing
											FROM	dbo.GAR_SICC_PRMGT MGT
												INNER JOIN dbo.GAR_SICC_PRMOC MOC
												ON MOC.prmoc_pnu_oper = MGT.prmgt_pnu_oper
												AND MOC.prmoc_pco_ofici = MGT.prmgt_pco_ofici
												AND MOC.prmoc_pco_moned = MGT.prmgt_pco_moned
												AND MOC.prmoc_pco_produ = MGT.prmgt_pco_produ
												AND MOC.prmoc_pco_conta = MGT.prmgt_pco_conta
											WHERE	MGT.prmgt_estado = 'A'
												AND MGT.prmgt_pfeavaing > 0
												AND MGT.prmgt_pfeavaing = @viFecha_Valuacion_Entera
												AND MGT.prmgt_pcoclagar	= @viClase_Garantia
												AND MGT.prmgt_pnu_part = COALESCE(@viCodigo_Partido, MGT.prmgt_pnu_part)
												AND MGT.prmgt_pnuidegar = @vdIdentificacion_Bien
												AND MGT.prmgt_pnuide_alf = @vsIdentificacion_Bien
												AND MOC.prmoc_pse_proces = 1
												AND MOC.prmoc_estado = 'A'
												AND MOC.prmoc_pnu_contr = 0
												AND ((MOC.prmoc_pcoctamay > 815)
													OR (MOC.prmoc_pcoctamay < 815))

											UNION ALL

											SELECT	MIN(MGT.prmgt_pmoavaing) AS prmgt_pmoavaing
											FROM	dbo.GAR_SICC_PRMGT MGT
												INNER JOIN dbo.GAR_SICC_PRMCA MCA
												ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper
												AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
												AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
												AND MGT.prmgt_pco_produ = 10
												AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
											WHERE	MGT.prmgt_estado = 'A'
												AND MGT.prmgt_pfeavaing > 0
												AND MGT.prmgt_pfeavaing = @viFecha_Valuacion_Entera
												AND MGT.prmgt_pcoclagar	= @viClase_Garantia
												AND MGT.prmgt_pnu_part = COALESCE(@viCodigo_Partido, MGT.prmgt_pnu_part)
												AND MGT.prmgt_pnuidegar = @vdIdentificacion_Bien
												AND MGT.prmgt_pnuide_alf = @vsIdentificacion_Bien
												AND MCA.prmca_estado = 'A'
												AND MCA.prmca_pfe_defin >= @viFecha_Actual_Entera

											UNION ALL

											SELECT	MIN(MGT.prmgt_pmoavaing) AS prmgt_pmoavaing
											FROM	dbo.GAR_SICC_PRMGT MGT
												INNER JOIN dbo.GAR_SICC_PRMCA MCA
												ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper
												AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
												AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
												AND MGT.prmgt_pco_produ = 10
												AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
												INNER JOIN dbo.GAR_SICC_PRMOC MC1
												ON MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
												AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
												AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr
											WHERE	MGT.prmgt_estado = 'A'
												AND MGT.prmgt_pfeavaing > 0
												AND MGT.prmgt_pfeavaing = @viFecha_Valuacion_Entera
												AND MGT.prmgt_pcoclagar	= @viClase_Garantia
												AND MGT.prmgt_pnu_part = COALESCE(@viCodigo_Partido, MGT.prmgt_pnu_part)
												AND MGT.prmgt_pnuidegar = @vdIdentificacion_Bien
												AND MGT.prmgt_pnuide_alf = @vsIdentificacion_Bien
												AND MCA.prmca_estado = 'A'
												AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
												AND MC1.prmoc_pse_proces = 1
												AND MC1.prmoc_estado = 'A'
												AND ((MC1.prmoc_pcoctamay > 815)
													OR (MC1.prmoc_pcoctamay < 815))

											GROUP BY MGT.prmgt_pcoclagar, MGT.prmgt_pnu_part, MGT.prmgt_pnuidegar, MGT.prmgt_pnuide_alf, MGT.prmgt_pfeavaing) TMP
										WHERE TMP.prmgt_pmoavaing IS NOT NULL)
	
		
	
	SET @vdPorcentaje_Inferior = (	SELECT	MIN(CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P','')))) 
									FROM	dbo.CAT_ELEMENTO 
									WHERE	cat_catalogo = @viCatalogo_Parametros_Calculo
										AND cat_campo LIKE '%P')

	SET @vdPorcentaje_Superior = (	SELECT	MAX(CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))))  
									FROM	dbo.CAT_ELEMENTO 
									WHERE	cat_catalogo = @viCatalogo_Parametros_Calculo
										AND cat_campo LIKE '%P')

	SET @vdPorcentaje_Intermedio = (SELECT	CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))) 
									FROM	dbo.CAT_ELEMENTO 
									WHERE	cat_catalogo = @viCatalogo_Parametros_Calculo
										AND CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))) > @vdPorcentaje_Inferior
										AND CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))) < @vdPorcentaje_Superior
										AND cat_campo LIKE '%P')


	SET @viAnno_Inferior = (SELECT	MIN(CONVERT(SMALLINT, (REPLACE(RTRIM(LTRIM(cat_campo)),'A','')))) 
							FROM	dbo.CAT_ELEMENTO 
							WHERE	cat_catalogo = @viCatalogo_Parametros_Calculo
								AND cat_campo LIKE '%A')

	SET @viAnno_Intermedio = (	SELECT	MAX(CONVERT(SMALLINT, (REPLACE(RTRIM(LTRIM(cat_campo)),'A','')))) 
								FROM	dbo.CAT_ELEMENTO 
								WHERE	cat_catalogo = @viCatalogo_Parametros_Calculo
									AND cat_campo LIKE '%A')

	SET	@viTipo_Bien =  (	SELECT	COALESCE(GGR.cod_tipo_bien, -1)
							FROM	dbo.GAR_GARANTIA_REAL GGR 
							WHERE	GGR.cod_garantia_real = @piGarantia)

	SET @vsNombre_Usuario_Modifico = (	SELECT	COALESCE(SU.DES_USUARIO,'') 
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
			COALESCE(GRO.porcentaje_responsabilidad, -1)	AS "porcentaje_responsabilidad", 
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
				 ELSE (SELECT CE2.cat_campo + '-' + CE2.cat_descripcion FROM CAT_ELEMENTO CE2  WHERE CE2.cat_campo = (CONVERT(VARCHAR(5), GGR.cod_tipo_bien))   AND CE2.cat_catalogo = @viCatalogo_Tipo_Bien )  
			END											AS "des_tipo_bien",

			CASE GRO.cod_tipo_mitigador
				 WHEN NULL THEN '-'                                                                                                                                                                          
				 ELSE (SELECT CE3.cat_campo + '-' + CE3.cat_descripcion FROM CAT_ELEMENTO CE3  WHERE CE3.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tipo_mitigador))  AND CE3.cat_catalogo = @viCatalogo_Tipo_Mitigador )
			END											AS "des_tipo_mitigador",

			CASE GRO.cod_tipo_documento_legal
				 WHEN NULL THEN '-'                                                                                                                                                                          
				 ELSE (SELECT CE4.cat_campo + '-' + CE4.cat_descripcion FROM CAT_ELEMENTO CE4  WHERE CE4.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tipo_documento_legal))  AND CE4.cat_catalogo = @viCatalogo_Tipo_Documento_Legal )
			END											AS "des_tipo_documento",

			CASE GRO.cod_inscripcion
				 WHEN NULL THEN '-'                                                                                                                                                                          
				 ELSE (SELECT CE5.cat_campo + '-' + CE5.cat_descripcion FROM CAT_ELEMENTO CE5  WHERE CE5.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_inscripcion)) AND CE5.cat_catalogo = @viCatalogo_Indicador_Inscripcion)
			END											AS "des_tipo_inscripcion",

			CASE 
				WHEN GRO.cod_grado_gravamen IS NULL THEN '-' 
				WHEN GRO.cod_grado_gravamen > 3 THEN (SELECT CE6.cat_campo + '-' + CE6.cat_descripcion FROM CAT_ELEMENTO CE6  WHERE CE6.cat_campo = '4' AND CE6.cat_catalogo = @viCatalogo_Grado_Gravamen) 
				WHEN GRO.cod_grado_gravamen < 1 THEN '-' 
				ELSE (SELECT CE6.cat_campo + '-' + CE6.cat_descripcion FROM CAT_ELEMENTO CE6  WHERE CE6.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_grado_gravamen)) AND CE6.cat_catalogo = @viCatalogo_Grado_Gravamen)  
			END											AS "des_tipo_grado_gravamen",

			CASE GRO.cod_operacion_especial
				WHEN NULL THEN (SELECT CE7.cat_campo + '-' + CE7.cat_descripcion FROM CAT_ELEMENTO CE7  WHERE CE7.cat_campo = '0' AND CE7.cat_catalogo = @viCatalogo_Operacion_Especial)   
				WHEN -1 THEN '-'
				ELSE (SELECT CE7.cat_campo + '-' + CE7.cat_descripcion FROM CAT_ELEMENTO CE7  WHERE CE7.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_operacion_especial)) AND CE7.cat_catalogo = @viCatalogo_Operacion_Especial)     
			END											AS "des_tipo_operacion_especial",

			CASE GRO.cod_tipo_acreedor 
				WHEN NULL THEN (SELECT CE8.cat_campo + '-' + CE8.cat_descripcion FROM CAT_ELEMENTO CE8  WHERE CE8.cat_campo = '2' AND CE8.cat_catalogo = @viCatalogo_Tipo_Persona)      
				WHEN -1 THEN (SELECT CE8.cat_campo + '-' + CE8.cat_descripcion FROM CAT_ELEMENTO CE8  WHERE CE8.cat_campo = '2' AND CE8.cat_catalogo = @viCatalogo_Tipo_Persona)  
				ELSE (SELECT CE8.cat_campo + '-' + CE8.cat_descripcion FROM CAT_ELEMENTO CE8  WHERE CE8.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tipo_acreedor)) AND CE8.cat_catalogo = @viCatalogo_Tipo_Persona) 
			END											AS "des_tipo_persona",

			CASE GRO.cod_liquidez 
				WHEN NULL THEN '-'      
				WHEN -1 THEN '-'  
				ELSE (SELECT CE9.cat_campo + '-' + CE9.cat_descripcion FROM CAT_ELEMENTO CE9  WHERE CE9.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_liquidez)) AND CE9.cat_catalogo = @viCatalogo_Tipo_Liquidez) 
			END											AS "des_tipo_liquidez",

			CASE GRO.cod_tenencia 
				WHEN NULL THEN '-'      
				WHEN -1 THEN '-'  
				ELSE (SELECT CE10.cat_campo + '-' + CE10.cat_descripcion FROM CAT_ELEMENTO CE10  WHERE CE10.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tenencia)) AND CE10.cat_catalogo = @viCatalogo_Tipo_Tenencia) 
			END											AS "des_tipo_tenencia",

			CASE GRO.cod_moneda 
				WHEN NULL THEN '-'      
				WHEN -1 THEN '-'  
				ELSE (SELECT CE11.cat_campo + '-' + CE11.cat_descripcion FROM CAT_ELEMENTO CE11  WHERE CE11.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_moneda)) AND CE11.cat_catalogo = @viCatalogo_Tipo_Moneda) 
			END											AS "des_tipo_moneda",

			COALESCE(GGR.Usuario_Modifico,'')				AS "Usuario_Modifico",
			COALESCE(@vsNombre_Usuario_Modifico,'')			AS "Nombre_Usuario_Modifico",
			CONVERT(VARCHAR(20), (COALESCE(GGR.Fecha_Modifico,'1900-01-01')), 120)  AS "Fecha_Modifico",
			CONVERT(VARCHAR(20), (COALESCE(GGR.Fecha_Inserto,'1900-01-01')), 120)   AS "Fecha_Inserto",
			CONVERT(VARCHAR(20), (COALESCE(GGR.Fecha_Replica	,'1900-01-01')), 120) AS "Fecha_Replica",			
			COALESCE(CPA.Porcentaje_Aceptacion,0)		AS "Porcentaje_Aceptacion_Calculado",			
			GGR.Indicador_Vivienda_Habitada_Deudor		AS "Indicador_Vivienda_Habitada_Deudor",
			COALESCE(GRO.Porcentaje_Aceptacion, 0)	AS "Porcentaje_Aceptacion", --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			GRO.Indicador_Porcentaje_Responsabilidad_Maximo AS "Indicador_Porcentaje_Responsabilidad_Maximo" --RQ_MANT_2015111010495738_00615: Se agrega este campo.
		FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
			ON GRO.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN dbo.CAT_ELEMENTO CE1 
			ON GGR.cod_tipo_garantia_real = CE1.cat_campo
			AND CE1.cat_catalogo = @viCatalogo_Tipo_Garantia_Real
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
			CONVERT(VARCHAR(10), (COALESCE(GRO.Fecha_Valuacion_SICC,'1900-01-01')), 103)     AS "fecha_valuacion_sicc",
						
			--INICIO RQ:RQ_MANT_2015062410418218_00025, se agregan nuevos campos
			
			COALESCE(GRV.Porcentaje_Aceptacion_Terreno, 0)	AS "Porcentaje_Aceptacion_Terreno",
			COALESCE(GRV.Porcentaje_Aceptacion_No_Terreno, 0)	AS "Porcentaje_Aceptacion_No_Terreno",
			COALESCE(GRV.Porcentaje_Aceptacion_Terreno_Calculado, -1)	AS "Porcentaje_Aceptacion_Terreno_Calculado",
			COALESCE(GRV.Porcentaje_Aceptacion_No_Terreno_Calculado, -1)	AS "Porcentaje_Aceptacion_No_Terreno_Calculado"
			
			--FIN RQ:RQ_MANT_2015062410418218_00025, se agregan nuevos campos

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
			@vdMonto_Avaluo_SICC 							AS "prmgt_pmoavaing"
			
		FOR XML PATH('AVALUO_SICC'), ELEMENTS, TYPE
	),
	(	SELECT	DISTINCT 
			CAST((@vdPorcentaje_Inferior/100) AS DECIMAL(5,3))	AS "porcentaje_limite_inferior",
			CAST((@vdPorcentaje_Intermedio/100) AS DECIMAL(5,3)) AS "porcentaje_limite_intermedio",
			CAST((@vdPorcentaje_Superior/100) AS DECIMAL(5,3)) 	AS "porcentaje_limite_superior",
			@viAnno_Inferior										AS "annos_limite_inferior",
			@viAnno_Intermedio									AS "annos_limite_intermedio"
		WHERE	@viTipo_Bien IN (-1, 1, 2)
		
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
		WHERE	@viTipo_Bien IN (-1, 1, 2)
		
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
				WHEN ((GPO.Estado_Registro = 1) AND (COALESCE(GAP.Estado_Registro, 0) = 1) AND (TPB.Codigo_Tipo_Bien = @viTipo_Bien)) THEN 1
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
			AND CE1.cat_catalogo = @viCatalogoTipos_Polizas_Sap
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

