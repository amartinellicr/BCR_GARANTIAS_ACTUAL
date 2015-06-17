    //El archivo debe ser minimizado, se usó la herramienta http://jscompress.com/, el resultado se copia en el archivo Utiles_min.js
    
    //Función donde inicializamos el dialog 
    function PageInit() { 
    
        $camposMensajeFechaPrescripcionMenor = '';
        
        $errorFechaPresentacion = '0';
        
        $arregloCamposValuacion = new Array(3);
        $arregloCamposValuacion[0] = '';
        $arregloCamposValuacion[1] = '';
        $arregloCamposValuacion[2] = '';
        

/************************************************************************/        
        /* VALIDACIONES DEL CAMPO REFERENTE A LA FECHA DE PRESENTACION */ 
          
        //Función que muestra el mensaje de alerta cuando la fecha de presentación es inválida
        $MensajeFechaPresentacion = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>La fecha de presentación es menor a la fecha de constitución, lo anterior no es correcto favor corregir o verificar los datos de la garantía.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha de Presentanción Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		            "Aceptar": function() {
			            $( this ).dialog( "close" );
			            
			            $errorFechaPresentacion = '1';
			            
			            document.body.style.cursor = 'default';		
			           
	            		$$('txtMontoMitigador').attr('disabled', 'disabled');
                        $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                        $$('btnValidarOperacion').attr('BCMM', '0');
                        $$('btnValidarOperacion').attr('BCPA', '0');
		            }
	            }
            });
                


/**************************************************************************/        
	     /* VALIDACIONES DEL CAMPO REFERENTE AL INDICADOR DE INSCRIPCION */
    	     
	     //Función que muestra el mensaje de alerta cuando el indicador de inscripción es inválido
         $MensajeIndicadorInscripcionFPFA = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El indicador de inscripción para esta garantía es incorrecto, favor modificar el mismo en el evento PRT83 del SICC según lo normado por SUGEF.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Indicador de Inscripción Inválido', 
                    resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
                    modal: true,
                    buttons: {
	                "Aceptar": function() {
		                $( this ).dialog( "close" );
			            
			            document.body.style.cursor = 'default';
			            
			            $$('txtMontoMitigador').attr('disabled', 'disabled');
	                    $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                        $$('btnValidarOperacion').attr('BCMM', '0');
                        $$('btnValidarOperacion').attr('BCPA', '0');
			            	            
	                }
                }
            });
    
        //Función que el mensaje de alerta cuando el indicador de inscripción es inválido y los campos de monto mitigador y % de aceptación no poseen valores
        $MensajeIndicadorInscripcionFCInvalida = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor incluido en la fecha de constitución es incorrecto favor revisar.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Indicador de Inscripción Inválido', 
	                resizable: false,
                    draggable: false,
                    height:235,
                    width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			            
			                document.body.style.cursor = 'default';
                           
	                        $$('txtMontoMitigador').attr('disabled', 'disabled');
	                        $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
    		                $$('btnValidarOperacion').attr('BCMM', '0');
                            $$('btnValidarOperacion').attr('BCPA', '0');
                        
			                $( this ).dialog( "close" );
	                        }
                        }
                    });
                
                

	    //Función que muestra el mensaje de alerta cuando el indicador de inscripción es inválido, según la lista cargada para el tipo de garantía real.
        $MensajeIndicadorInscripcionInvalido = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Favor revisar el valor incluido en el campo indicador de inscripción, ya que no es válido para este tipo de garantía.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Indicador de Inscripción Inválido', 
                    resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
                    modal: true,
                    buttons: {
	                    "Aceptar": function() {
		                    $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';
    			            
			                $$('txtMontoMitigador').attr('disabled', 'disabled');
	                        $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
	                        $$('btnValidarOperacion').attr('BCMM', '0');
                            $$('btnValidarOperacion').attr('BCPA', '0');
	                    }
                    }
                });



                
 /****************************************************************/        
	     /* VALIDACIONES DEL CAMPO REFERENTE AL MONTO MITIGADOR */
    	     
	    //Función que muestra el mensaje de alerta cuando la garantía tratada no posee avalúo asociado
        $MensajeMontoMitigadorSinAvaluo = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>La garantía no posee ningún avalúo asociado, por lo que la validación del monto mitigador no puede realizarse.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Monto Mitigador Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
	                        $$('txtMontoMitigador').attr('disabled', 'disabled');
	                        $$('btnValidarOperacion').attr('BCMM', '0');
    	                    
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';
			            
//			                if(($$('btnValidarOperacion').attr("MEMM")) == '1')
//			                {
//			                   ModificarGarantia();
//			                }
		                }
	                }
                });


	    //Función que muestra el mensaje de alerta cuando el monto mitigador calculado es mayor al digitado por el usuario
        $MensajeCalculoMontoMitigadorMayor = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Favor revisar el monto del mitigador ya que el mismo es mayor al % de aceptación permitido.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Monto Mitigador Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';

//			            if(($$('btnValidarOperacion').attr("MEMM")) == '1')
//			            {
//			                ModificarGarantia();
//			            }
//			            else
                        if(($$('btnValidarOperacion').attr("MEMM")) == '0')
			            {
			                ValidarPorcentajeAceptacion();
                        }
		              }
	               }
                });

    	
	    //Función que el mensaje de alerta cuando el monto mitigador calculado es menor al digitado por el usuario
        $MensajeCalculoMontoMitigadorMenor = $('<div class="ui-widget" style="padding-top:2.6em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Existe un faltante de mitigador, favor normalizar la situación.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Monto Mitigador Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';

//			            if(($$('btnValidarOperacion').attr("MEMM")) == '1')
//			            {
//			                ModificarGarantia();
//			            }
//			            else
                        if(($$('btnValidarOperacion').attr("MEMM")) == '0')
			            {
			                ValidarPorcentajeAceptacion();
                        }
		              }
	               }
                });

	    //Función que el mensaje de alerta cuando el monto mitigador es inválido para el indicador de inscripción
        $MensajeMontoMitigadorInvalido = $('<div class="ui-widget" style="padding-top:2.6em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Para este indicador de inscripción, el monto mitigador debe ser mayor a 0 (cero), favor corregir.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Monto Mitigador Inválido', 
	                resizable: false,
	                height:235,
                    width:650,
 	                position: { my: "center bottom", at: "center bottom", of: window },
                    closeOnEscape: false,
                    open: function(event, ui) { $(".ui-dialog-titlebar-close").hide();},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';
    			            
			                ValidarPorcentajeAceptacion();
		                }
	                }
                });


 /*************************************************************************/        
	     /* VALIDACIONES DEL CAMPO REFERENTE AL PORCENTAJE DE ACEPTACION */
    	     
	    //Función que el mensaje de alerta cuando el porcentaje de aceptación es inválido
        $MensajePorcentajeAceptacionInvalido = $('<div class="ui-widget" style="padding-top:2.6em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El porcentaje utilizado no es correcto para el tipo de garantía.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: '% Aceptación Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                $$('txtMontoMitigador').attr('disabled', 'disabled');
    			            
			                if(($$('btnValidarOperacion').attr("IEG")) == '1')
                            {
                                $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                                $$('btnValidarOperacion').attr('BCPA', '0');
                            }
                            else
                            {	
                                if(($$('btnValidarOperacion').attr("BCPA")) == '1')
                                {
		                            $$('txtPorcentajeAceptacion').removeAttr('disabled');
                                    $$('btnValidarOperacion').attr('BCPA', '1');
		                        }
			                }
    			            
			                document.body.style.cursor = 'default';
		                }
	                }
                });
                

          	//Función que el mensaje de alerta cuando el porcentaje de aceptación es inválido para el indicador de inscripción asignado
	        $MensajePorcentajeAceptacionInvalidoIndIns = $('<div class="ui-widget" style="padding-top:2.6em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Para este indicador de inscripción, el porcentaje de aceptación debe ser mayor a 0 (cero), favor corregir.</p></div></div>')
                .dialog({
	                    autoOpen: false, 
                        title: '% Aceptación Inválido', 
	                    resizable: false,
	                    height:235,
                        width:650,
	                    position: { my: "center bottom", at: "center bottom", of: window },
                        closeOnEscape: false,
                        open: function(event, ui) { $(".ui-dialog-titlebar-close").hide();},
	                    modal: true,
	                    buttons: {
		                    "Aceptar": function() { 
        			        
			                    $( this ).dialog( "close" );
        			            
			                    $$('txtMontoMitigador').attr('disabled', 'disabled');
        			            
			                    if(($$('btnValidarOperacion').attr("IEG")) == '1')
                                {
                                    $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                                    $$('btnValidarOperacion').attr('BCPA', '0');
                                }
                                else
                                {	
                                    if(($$('btnValidarOperacion').attr("BCPA")) == '1')
                                    {
		                                $$('txtPorcentajeAceptacion').removeAttr('disabled');
                                        $$('btnValidarOperacion').attr('BCPA', '1');
		                            }
			                    }
        			            
			                    document.body.style.cursor = 'default';
		                    }
	                    }
                    });



 /*******************************************************************/        
	     /* VALIDACIONES DEL CAMPO REFERENTE AL PARTIDO Y LA FINCA */

	    //Función que el mensaje de alerta cuando el código del partido es inválido
        $MensajePartidoInvalido = $('<div class="ui-widget" style="padding-top:2.6em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El partido no es un valor correcto, favor verificar el mismo antes de continuar.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Partido Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );

                            document.body.style.cursor = 'default';
		                }
	                }
                });


	    //Función que el mensaje de alerta cuando el número de la finca es inválido
        $MensajeFincaInvalida = $('<div class="ui-widget" style="padding-top:2.6em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>La finca excede el parámetro permitido por SUGEF, favor verificar el mismo antes de continuar.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Finca Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );

                            document.body.style.cursor = 'default';
		                }
	                }
                });



 /********************************************************************/        
	     /* VALIDACIONES DEL CAMPO REFERENTE A LA CLASE DE GARANTIA */

	    //Función que el mensaje de alerta cuando el código de la clase de garantía es inválida
        $MensajeClaseGarantiaInvalida = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor incluido, en la clase de garantía, no es correcto para el tipo de garantía real seleccionado, favor modificar el mismo desde el evento correspondiente en el SICC.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Clase Garantía Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
                            document.body.style.cursor = 'default';
		                }
	                }
                });

	    //Función que el mensaje de alerta cuando el código de la clase de garantía es inválida y posee el código 18
        $MensajeClaseGarantia18 = $('<div class="ui-widget" style="padding-top:1.0em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p style="text-align:justify;"><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 2.5em;"></span>El valor incluido, en la clase de garantía, no es correcto para el tipo de garantía real seleccionado, favor modificar el mismo desde el evento correspondiente en el SICC. Se debe tener presente que la clase 18 (Cédula Hipotecaria) de momento no puede ser consultada en este sistema.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Clase Garantía Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
                            document.body.style.cursor = 'default';
		                }
	                }
                });

	    //Función que el mensaje de alerta cuando el código de la clase de garantía es inválida y posee el código 19
        $MensajeClaseGarantia19 = $('<div class="ui-widget" style="padding-top:1.0em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p style="text-align:justify;"><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 2.5em;"></span>El valor incluido, en la clase de garantía, no es correcto para el tipo de garantía real seleccionado, favor modificar el mismo desde el evento correspondiente en el SICC. Se debe tener presente que la clase 19 (Finca Fideicometida) de momento no puede ser consultada en este sistema.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Clase Garantía Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
                            document.body.style.cursor = 'default';
		                }
	                }
                });
                

 /*************************************************************/        
	     /* VALIDACIONES DEL CAMPO REFERENTE AL TIPO DE BIEN */

	    //Función que el mensaje de alerta cuando el código del tipo de bien es inválido
        $MensajeTipoBienInvalido = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor incluido, en el tipo de bien, no es correcto para el tipo de garantía real y clase de garantía seleccionado, favor modificar el mismo.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Tipo de Bien Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                if(($$('btnValidarOperacion').attr("IEG")) == '1')
                            {
                                $$('cbMitigador').attr('disabled', 'disabled');
			                    $$('cbTipoBien').attr('disabled', 'disabled');
                            }
                            else
                            {		
			                    $$('cbTipoBien').removeAttr('disabled');
                                
                                var tipoBien = $$('cbTipoBien').val();
                                                            
                                if(tipoBien == '-1')
                                {
                                    $$('cbMitigador').attr('disabled', 'disabled');
                                }
                                else
                                {           
			                        $$('cbMitigador').removeAttr('disabled');
			                    }
			                }
    			            
                            $$('cbMitigador').val("-1"); 
                    			            
			                document.body.style.cursor = 'default';
		                }
	                }
                });


 /******************************************************************/        
	     /* VALIDACIONES DEL CAMPO REFERENTE AL TIPO DE MITIGADOR */

	    //Función que el mensaje de alerta cuando el código del tipo de mitigador de riesgo es inválido
        $MensajeTipoMitigadorInvalido = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor incluido, en el mitigador de riesgo, no es correcto para el tipo de garantía real,  clase de garantía y tipo de bien seleccionado, favor modificar el mismo.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Tipo de Mitigador Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                if(($$('btnValidarOperacion').attr("IEG")) == '1')
                            {
                                $$('cbMitigador').attr('disabled', 'disabled');
			                    $$('cbTipoBien').attr('disabled', 'disabled');
                            }
                            else
                            {	
                                var tipoBien = $$('cbTipoBien').val();
                                var tipoMitigador = $$('cbMitigador').val();
                                	
                                if(tipoBien == '-1') 
                                {
                                    $$('cbMitigador').attr('disabled', 'disabled');
                                }
                                else
                                {
			                        $$('cbMitigador').removeAttr('disabled');
			                        $$('cbTipoBien').removeAttr('disabled');
			                    }
			                }
    			            
			                document.body.style.cursor = 'default';
		                }
	                } 
                });


 /************************************************************************/        
	     /* VALIDACIONES DEL CAMPO REFERENTE AL TIPO DE DOCUMENTO LEGAL */

	    //Función que el mensaje de alerta cuando el código del tipo de documento legal es inválido
    $MensajeTipoDocumentoLegalInvalido = $('<div class="ui-widget" style="padding-top:1.8em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 1.8em;"></span>El valor incluido, en el tipo de documento legal, no es correcto para el tipo de garantía real,  clase de garantía, tipo de bien y tipo de mitigador seleccionado, favor modificar el mismo.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Tipo de Documento Legal Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';
		                }
	                }
                });

	    //Función que el mensaje de alerta cuando el código del tipo de documento legal es inválido
        $MensajeTipoDocumentoLegalInvalidoSegunGradoGravamen = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor incluido, en el tipo de documento legal, no es correcto para el grado de gravamen indicado en el SICC, por lo que será actualizado de forma automática.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Tipo de Documento Legal Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';
		                }
	                }
                });


        
 /***************************************************************/        
	     /* VALIDACIONES DEL CAMPO REFERENTE AL GRADO GRAVAMEN */

   	    //Función que el mensaje de alerta cuando el código del grado de gravamen es inválido
        $MensajeGradoGravamenInvalido = $('<div class="ui-widget" style="padding-top:1.8em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p style="text-align:justify;"><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 1.8em;"></span>El valor incluido en el grado gravamen no es correcto, favor de corregir en el evento correspondiente del SICC.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Grado de Gravamen Inválido', 
                    resizable: false,
                    draggable: false,
                    height:235,
                    width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
                    buttons: {
	                    "Aceptar": function() { 
    			        
		                    $$('cbTipoDocumento').val("-1");
		                    $$('cbGravamen').val("-1"); 
    			            
		                    $( this ).dialog( "close" );
    			            
		                    document.body.style.cursor = 'default';		            }
                    }
                });


 /***********************************************************************/        
	     /* VALIDACIONES DEL CAMPO REFERENTE A LAS VALUACIONES TERRENO */

	    //Función que el mensaje de alerta cuando se da la inconsistencia de de la valuaciones terreno
        $MensajeValuacionesTerreno = $('<div class="ui-widget" style="padding-top:2.0em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p style="text-align:justify;"><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 1.8em;"></span>Los campos Mto Última Tasación no Terreno y Mto Tasación Actualiz. no Terreno no deben contener un monto, favor eliminar el monto o verificar el tipo de bien seleccionado.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Campos de Terreno Inválidos', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';
    			            
			                $$('btnRegresar').attr('IMM', '0')
		                }
	                }
                });


        //Función que el mensaje de alerta cuando el monto de la última tasación del terreno es igual a 0 (cero)
        $MensajeMontoUltimaTasacionTerrenoCero = $('<div class="ui-widget" style="padding-top:1.0em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p style="text-align:justify;"><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 1.8em;"></span>El valor del campo Mto última Tasación Terreno debe tener un valor mayor que cero, o el tipo de bien registrado no es el correcto para esta garantía, favor corregir antes de continuar.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Campo Monto Ultima Tasación del Terreno Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';

			                $$('btnRegresar').attr('IMM', '0')
		                }
	                }
                });

 /**************************************************************************/        
	     /* VALIDACIONES DEL CAMPO REFERENTE A LAS VALUACIONES NO TERRENO */

	    //Función que el mensaje de alerta cuando se da la inconsistencia de la valuaciones del no terreno
        $MensajeValuacionesNoTerreno = $('<div class="ui-widget" style="padding-top:1.0em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p style="text-align:justify;"><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 2.3em;"></span>Los campos Mto última tasación Terreno, Mto última tasación No terreno y Mto Tasación Actualiz. Terreno Calculado,  Mto Tasación Actualiz. No Terreno Calculado deben presentar un valor mayor que cero y Fecha de construcción tienen que tener el formato (dd-mm-yyyy) favor incluir el valor correctamente o verificar el tipo de bien seleccionado.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Campos de No Terreno Inválidos', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';

			                $$('btnRegresar').attr('IMM', '0')
		                }
	                }
                });
                
           
   	    //Función que el mensaje de alerta cuando se da la inconsistencia de las valuaciones del no terreno, correspondiente a la fecha de construcción
        $MensajeValuacionesNoTerrenoFecha = $('<div class="ui-widget" style="padding-top:1.6em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p style="text-align:justify;"><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 1.8em;"></span>El valor incluido, en la fecha de construcción, es mayor al permitido favor verificar.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Campos de No Terreno Inválidos', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';

			                $$('btnRegresar').attr('IMM', '0')
		                }
	                }
                });
                
               
        //Función que el mensaje de alerta cuando el monto de la última tasación del no terreno es igual a 0 (cero)
        $MensajeMontoUltimaTasacionNoTerrenoCero = $('<div class="ui-widget" style="padding-top:1.0em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .8em;"><p style="text-align:justify;"><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 1.8em;"></span>El valor del campo Mto última Tasación No Terreno debe tener un valor mayor que cero, o el tipo de bien registrado no es el correcto para esta garantía, favor corregir antes de continuar.</p></div></div>')
            .dialog({
	                autoOpen: false, 
                    title: 'Campo Monto Ultima Tasación del No Terreno Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
                    closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() { 
    			        
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';

			                $$('btnRegresar').attr('IMM', '0')
		                }
	                }
                });
  /***************************************************************************/        
       /* VALIDACIONES DEL CAMPO REFERENTE A LA FECHA DE ULTIMO SEGUIMIENTO */ 
           
        //Función que muestra el mensaje de alerta cuando la fecha del último seguimiento es inválida
        $MensajeFechaUltimoSeguimiento = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor incluido en este campo es mayor al campo Fecha de valuación favor revisar antes de volver a realizar la inclusión.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha del Ultimo Seguimiento Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });
                
        //Función que muestra el mensaje de alerta cuando la fecha del último seguimiento no fue suministrada
        $MensajeFechaUltimoSeguimientoFaltante = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Por favor verificar el dato de la fecha de último seguimiento, y proceder a corregir antes de guardar la información.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha del Ultimo Seguimiento Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });
                


 /***********************************************************************/        
        /* VALIDACIONES DEL CAMPO REFERENTE A LA FECHA DE CONSTRUCCION */ 
           
        //Función que muestra el mensaje de alerta cuando la fecha de construcción es inválida
        $MensajeFechaConstruccion = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Por favor verificar el dato de la fecha construcción, ya que no es correcto para el tipo de bien seleccionado,  proceda a corregirlo.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha de Construcción Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });


        //Función que muestra el mensaje de alerta cuando la fecha de construcción es inválida, por ser mayor a la fecha de constitución
        $MensajeFechaConstruccionMayorFechaConstitucion = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Por favor verificar el dato de la fecha construcción no es correcto, y proceda a corregirlo.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha de Construcción Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });




 /***********************************************************/        
        /* VALIDACIONES DE LOS CAMPOS REFERENTES AL AVALUO */ 
        
        //Función que muestra el mensaje de alerta cuando el monto total y la fecha del avalúo son diferentes a los del SICC
        $MensajeFechaAvaluoNoExisteSICC = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Favor incluir una fecha de valuación para la garantía consultada, ya que no registra una en el evento PRT17 del SICC.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha de Valuación Inválida', 
                    resizable: false,
                    draggable: false,
                    height:235,
                    width:650,
                    closeOnEscape: false,
                    open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
                    modal: true,
                    buttons: {
                        "Aceptar": function() {
                            $( this ).dialog( "close" );
        		            
                            document.body.style.cursor = 'default';		
                        }
                    }
                }); 
                
        
        //Función que muestra el mensaje de alerta cuando la fecha del avalúo es diferente a la del SICC
        $MensajeFechaAvaluoDiferenteSICC = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor incluido en el campo fecha de avaluó no es acorde al valor registrado en el SICC, favor modificar antes de realizar los cambios.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha de Valuación Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });
                
                
        //Función que muestra el mensaje de alerta cuando el monto total del avalúo es diferente a la del SICC
        $MensajeMontoTotalAvaluoDiferenteSICC = $('<div class="ui-widget" style="padding-top:1.0em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 2.5em;"></span>El valor incluido en el campo monto total del avalúo no es acorde al valor registrado en el SICC, favor modificar antes de realizar los cambios.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Monto Total Avalúo Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });
                
         //Función que muestra el mensaje de alerta cuando el monto total del avalúo es diferente a la del SICC, se muestra al guardar la información
        $MensajeMontoTotalizadoAvaluoDiferenteSICC = $('<div class="ui-widget" style="padding-top:1.0em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 2.5em;"></span>El dato totalizado del avalúo es diferente al incluido en el SICC, favor verificar los montos con el fin de guardar los datos.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Monto Total Avalúo Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });
               
                
                
        //Función que muestra el mensaje de alerta cuando el monto total y la fecha del avalúo son diferentes a los del SICC
        $MensajeDatosAvaluoDiferenteSICC = $('<div class="ui-widget" style="padding-top:1.0em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 2.5em;"></span>El valor incluido en el SICC, evento PRT17, en los campos \"Fecha avalúo garantía\" y \"Monto avalúo garantía\" son diferentes a los valores registrados, favor verificar o corregir los mismos antes de su inclusión nuevamente.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Datos de la Valuación Inválidos', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });
         

 /***********************************************************************/        
         /* VALIDACIONES DEL CAMPO REFERENTE A LA FECHA DE VENCIMIENTO */ 
           
        //Función que muestra el mensaje de alerta cuando la fecha de vencimiento es inválida
        $MensajeFechaVencimiento = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>La fecha de vencimiento  incluida no es correcta, favor verificar los datos incluidos en el SICC.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha de Vencimiento Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });


 
 
  /***********************************************************************/        
         /* VALIDACIONES DEL CAMPO REFERENTE A LA FECHA DE PRESCRIPCION */ 
           
        //Función que muestra el mensaje de alerta cuando la fecha de prescripción es inválida
        $MensajeFechaPrescripcion = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Favor revisar el valor incluido en el campo del SICC \"Fecha Prescripción\" ya que no es igual al registrado en el sistema.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha de Prescripción Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });

        //Función que muestra el mensaje de alerta cuando la fecha de prescripción no ha podido ser claculada debido a que no se cuenta con la fecha de vencimiento
        $MensajeFechaPrescripcionSinCalcular = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Favor incluir el valor correspondiente en el SICC, evento PRT01, en el campo \"Fecha de Definitivo\", ya que el mismo es un campo obligatorio.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha de Prescripción Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });

       //Función que muestra el mensaje de alerta cuando la fecha de prescripción es inválida, por ser menor a la fecha de constitución, presentación, valuación y vencimiento
        //Esta función requiere que se setee la variable "$camposMensajeFechaPrescripcionMenor", con los campos que son mayores.
        $MensajeFechaPrescripcionMenor = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor incluido en el campo Fecha de prescripción es menor al campo' + (($camposMensajeFechaPrescripcionMenor.length > 0) ? $camposMensajeFechaPrescripcionMenor : ' Fecha de Constitución, Fecha de Presentación, Fecha de Valuación o Fecha de Vencimiento') + '. Favor verificar y ajustar.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha de Prescripción Inválida', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });



 /******************************************************************************/        
         /* VALIDEZ DEL CAMPO REFERENTE AL MONTO DEL AVALUO TASACION TERRRENO */ 
           
        //Función que muestra el mensaje de alerta cuando el porcentaje de aceptación es mayor a 40 y el avalúo es mayor a 5 años.
        $MensajeValidezMtoAvalActTerrenoPorcMay = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor del campo % de aceptación será reducido a un 40%, lo anterior en cumplimiento de la normativa SUGEF castigando a la mitad el valor real máximo aceptado de esta garantía.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Monto Avalúo Tasación Terreno Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });
                
                
        //Función que muestra el mensaje de alerta cuando el porcentaje de aceptación es menor a 40 y el avalúo es menor de 5 años.
        $MensajeValidezMtoAvalActTerrenoPorcMen = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Favor verificar el valor incluido en el porcentaje de aceptación, ya que el mismo no presenta ninguna inconsistencia por falta de avalúo o inspección.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Monto Avalúo Tasación Terreno Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });
                
 
         //Función que muestra el mensaje de alerta cuando no existen los elementos necesarios para realizar la validación.
        $MensajeValidezMtoAvalActTerrenoSinDatos = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 1.8em;"></span>El sistema no cuenta con los elementos necesarios para comprobar la validez del monto de la tasación actualizada del terreno calculado. Favor de verificar si se proporcionaron los siguientes datos: El tipo de bien, el porcentaje de aceptación y que exista un avalúo.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Monto Avalúo Tasación Terreno Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';	
			                
			                $$('txtFechaSeguimiento').attr('disabled', 'disabled');
                            $$('igbCalendarioSeguimiento').attr('disabled', 'disabled');
		                }
	                }
                });

         //Función que muestra el mensaje de alerta cuando no existe una diferencia entre el monto de la última tasación del terreno y la tasación actualizada del terreno calculado.
        $MensajeValidezMtoAvalActTerrenoMontosDiff = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Favor verificar el valor incluido en el monto de la última tasación del terreno y el monto de la tasación actualizada del terreno calculado, ya que son diferentes.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Monto Avalúo Tasación Terreno Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });
                
                

 /*********************************************************************************/        
         /* VALIDEZ DEL CAMPO REFERENTE AL MONTO DEL AVALUO TASACION NO TERRRENO */ 
           
        //Función que muestra el mensaje de alerta cuando existe discrepancia entre los datos, del avalúo, del sistema y los registrados en el SICC.
        $MensajeValidezMtoAvalActNoTerrenoDifSICC = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El cálculo del monto de la tasación actualizada del terreno y no terreno calculado no puede ser llevado a cabo debido a una inconsistencia con respecto a la información del SICC.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Cálculo Monto Tasación Actualizada Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';	
			                
			                $$('txtFechaSeguimiento').attr('disabled', 'disabled');
                            $$('igbCalendarioSeguimiento').attr('disabled', 'disabled');	
		                }
	                }
                });
                
                
        //Función que muestra el mensaje de alerta cuando existe el monto de la última tasación del no terreno es mayor que el calculado.
        $MensajeValidezMtoAvalActNoTerrenoMontosDif = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Favor de verificar el valor del campo monto de la última tasación del no terreno, ya que es mayor al monto de la tasación actualizada del no terreno calculado.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Monto Avalúo Tasación No Terreno Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });
                
        //Función que muestra el mensaje de alerta cuando no existe alguno de los elementos requeridos para la aplicación de la validación.
        $MensajeValidezMtoAvalActNoTerrenoSinDatos = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 1.8em;"></span>El sistema no cuenta con los elementos necesarios para comprobar la validez del monto de la tasación actualizada del no terreno calculado. Favor de verificar si se proporcionaron los siguientes datos: El tipo de bien y que exista un avalúo.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Monto Avalúo Tasación No Terreno Inválido', 
	                resizable: false,
	                draggable: false,
	                height:235,
	                width:650,
	                closeOnEscape: false,
	                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
	                modal: true,
	                buttons: {
		                "Aceptar": function() {
			                $( this ).dialog( "close" );
    			            
			                document.body.style.cursor = 'default';		
		                }
	                }
                });
                
 /***********************************************************************/        
         /* VALIDACIONES DEL CAMPO REFERENTE A LA FECHA DE CONSTITUCION */ 
           
        //Función que muestra el mensaje de alerta cuando la fecha de vencimiento es inválida
        $MensajeFechaConstitucion = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>La fecha de constitución incluida no es correcta, favor revisar el valor registrado en el SICC del evento PTR01, ya que no presenta un valor asociado.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha de Constitucion Inválida', 
                    resizable: false,
                    draggable: false,
                    height:235,
                    width:650,
                    closeOnEscape: false,
                    open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
                    modal: true,
                    buttons: {
	                    "Aceptar": function() {
		                    $( this ).dialog( "close" );
    			            
		                    document.body.style.cursor = 'default';		
	                    }
                    }
                });


   } 


 /*********************************************************************************/        
 /************************  FUNCIONES ADICIONALES ********************************/        
 /*******************************************************************************/        

    //Función que muestra el div flotante con el mensaje 
    function MostrarMensajeModal(mensajeTexto) { 
      $Alerta.text(mensajeTexto); 
      $Alerta.dialog('open'); 
    }

    //Función que obtiene un control específico
    function $$(id, context) {
        var el = $("#" + id, context);
        if (el.length < 1)
            el = $("[id$=_" + id + "]", context);
        return el;
    }

    //Función que valida la fecha de presnetación que fue ingresada por el usuario
    function validarFechaPresentacion(){
        
        var fecPresentacion = $.trim($$('txtFechaRegistro').val().replace("__/__/____", ""));

    $$('cbInscripcion').attr('disabled', 'disabled');
    $$('btnValidarOperacion').attr('BCII', '0');
    
        if(fecPresentacion.length > 0)
        {
            var fecPresent = fecPresentacion.split('/');
            var fechaPresentacion = new Date(fecPresent[2], fecPresent[1], fecPresent[0]);
            var fecConstitucion = $$('txtFechaConstitucion').val();
            
            if(fecConstitucion.length > 0)
            {
                var fecConst = fecConstitucion.split('/');

                var fechaConstitucion = new Date(fecConst[2], fecConst[1], fecConst[0]);
            
                if(fechaConstitucion.getTime() <= fechaPresentacion.getTime())
                {
                    validarIndicadorInscripcion();
                }
                else
                {
                    $$('txtMontoMitigador').attr('disabled', 'disabled');
	                $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
    	                    
                    $MensajeFechaPresentacion.dialog('open');
                }
            }
        }
        else
        {
            $$('txtMontoMitigador').attr('disabled', 'disabled');
            $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                    
            $MensajeFechaPresentacion.dialog('open');
        }

    }

    //Función que valida el indicador de inscripción que fue ingresado por el usuario
    function validarIndicadorInscripcion()
    {
        var fecPresentacion = $.trim($$('txtFechaRegistro').val().replace("__/__/____", ""));
        
        if(fecPresentacion.length > 0)
        {
            var indicador = $$('cbInscripcion').val();
            var fechaActual = new Date();
            var parteFechaActual = ($$('hdnFechaActual').val().length != 0) ? $$('hdnFechaActual').val() : '';
            
            $$('cbInscripcion').attr('disabled', 'disabled');
            $$('btnValidarOperacion').attr('BCII', '0');
            
            if(parteFechaActual.length > 0)
            {
                var partesFecha = parteFechaActual.split('|');
                
                fechaActual = new Date(partesFecha[0], partesFecha[1] - 1, partesFecha[2]);
            }
                
            switch(indicador)
            {
                case '0':
                
                    $$('btnValidarOperacion').attr('BCMM', '0');
                    $$('btnValidarOperacion').attr('BCPA', '0');
                    
                    $$('txtMontoMitigador').attr('disabled', 'disabled');
                    $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                    
                    $MensajeIndicadorInscripcionInvalido.dialog('open');
                    
                break;
                case '1': 
                
                    $$('btnValidarOperacion').attr('BCMM', '0');
                    $$('btnValidarOperacion').attr('BCPA', '0');
                    
                    var fecConstitucion         = $.trim($$('txtFechaConstitucion').val().replace("__/__/____", ""));

                    if(fecConstitucion.length > 0)
                    {
                        var fecConst                = fecConstitucion.split('/');
                        var fechaConstitucion       = new Date(fecConst[2], fecConst[1] - 1, fecConst[0]);
                        
                        var fechaConstitucionComp   = new Date(fechaConstitucion.getTime() + (30 * 24 * 3600 * 1000))
                        
                        var porcentajeAceptacion    = parseFloat($$('txtPorcentajeAceptacion').val());

                        if(fechaActual.getTime() < fechaConstitucionComp.getTime())
                        {
                            $$('btnValidarOperacion').attr('BCMM', '1');
                            $$('btnValidarOperacion').attr('BCPA', '1');
                            
                            $$('txtMontoMitigador').removeAttr('disabled');
                            $$('txtPorcentajeAceptacion').removeAttr('disabled');
                            
                            if((porcentajeAceptacion <= 0) || (porcentajeAceptacion > 80))
                            {
                                $$('btnValidarOperacion').attr('BCMM', '0');
                                $$('txtMontoMitigador').attr('disabled', 'disabled');
                            }
                            
                            if(($$('btnValidarOperacion').attr("HAYAVAL")) == '0')
                            {
                                $$('btnValidarOperacion').attr('BCMM', '0');
                                $$('txtMontoMitigador').attr('disabled', 'disabled');
                            }
                        }
                        else
                        {
                            var montoMitigador          = parseFloat($$('txtMontoMitigador').val());
                            var porcentajeAceptacion    = parseFloat($$('txtPorcentajeAceptacion').val());
                        
                            $$('btnValidarOperacion').attr('BCMM', '0');
                            $$('btnValidarOperacion').attr('BCPA', '0');
                            
                            $$('txtMontoMitigador').attr('disabled', 'disabled');
	                        $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
        	                
	                        if((montoMitigador == 0) && (porcentajeAceptacion == 0))
	                        {
	                            $MensajeIndicadorInscripcionFCInvalida.dialog('open');
	                        }
	                        else
	                        {
	                            $MensajeIndicadorInscripcionFPFA.dialog('open');
	                        }
                        }
                    }
                    
                break;
                case '2': 
                    
                    var fecConstitucion = $.trim($$('txtFechaConstitucion').val().replace("__/__/____", ""));

                    if(fecConstitucion.length > 0)
                    {
                        var fecConst                = fecConstitucion.split('/');
                        var fechaConstitucion       = new Date(fecConst[2], fecConst[1] - 1, fecConst[0]);
                        
                        var fechaConstitucionComp   = new Date(fechaConstitucion.getTime() + (60 * 24 * 3600 * 1000))
                        
                        var porcentajeAceptacion    = parseFloat($$('txtPorcentajeAceptacion').val());
                        
                        if(fechaActual.getTime() < fechaConstitucionComp.getTime())
                        {
                            $$('btnValidarOperacion').attr('BCMM', '1');
                            $$('btnValidarOperacion').attr('BCPA', '1');
                            
                            $$('txtMontoMitigador').removeAttr('disabled');
                            $$('txtPorcentajeAceptacion').removeAttr('disabled');
                            
                            if((porcentajeAceptacion <= 0) || (porcentajeAceptacion > 80))
                            {
                                $$('btnValidarOperacion').attr('BCMM', '0');
                                $$('txtMontoMitigador').attr('disabled', 'disabled');
                            }
                            
                            if(($$('btnValidarOperacion').attr("HAYAVAL")) == '0')
                            {
                                $$('btnValidarOperacion').attr('BCMM', '0');
                                $$('txtMontoMitigador').attr('disabled', 'disabled');
                            }
                        }
                        else
                        {
                            $$('btnValidarOperacion').attr('BCMM', '0');
                            $$('btnValidarOperacion').attr('BCPA', '0');
                            
                            $$('txtMontoMitigador').attr('disabled', 'disabled');
	                        $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
        	                
                            var montoMitigador          = parseFloat($$('txtMontoMitigador').val());
                            var porcentajeAceptacion    = parseFloat($$('txtPorcentajeAceptacion').val());

	                        if((montoMitigador == 0) && (porcentajeAceptacion == 0))
	                        {
	                            $MensajeIndicadorInscripcionFCInvalida.dialog('open');
	                        }
	                        else
	                        {
	                            $MensajeIndicadorInscripcionFPFA.dialog('open');
	                        }
                        }
                    }
                    
                break;
                case '3': 
                    var porcentajeAceptacion    = parseFloat($$('txtPorcentajeAceptacion').val());
                
                    $$('btnValidarOperacion').attr('BCMM', '1');
                    $$('btnValidarOperacion').attr('BCPA', '1');
                    
                    $$('txtMontoMitigador').removeAttr('disabled');
                    $$('txtPorcentajeAceptacion').removeAttr('disabled');

                    if((porcentajeAceptacion <= 0) || (porcentajeAceptacion > 80))
                    {
                        $$('btnValidarOperacion').attr('BCMM', '0');
                        $$('txtMontoMitigador').attr('disabled', 'disabled');
                    }
                    
                    if(($$('btnValidarOperacion').attr("HAYAVAL")) == '0')
                    {
                        $$('btnValidarOperacion').attr('BCMM', '0');
                        $$('txtMontoMitigador').attr('disabled', 'disabled');
                    }        
                break;
                case '-1':
                            $$('btnValidarOperacion').attr('BCMM', '0');
                            $$('btnValidarOperacion').attr('BCPA', '0');
                            
                            $$('txtMontoMitigador').attr('disabled', 'disabled');
	                        $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                break;
               default: break;
            }
        }
        else
        {
            $$('btnValidarOperacion').attr('BCMM', '0');
            $$('btnValidarOperacion').attr('BCPA', '0');
            
            $$('txtMontoMitigador').attr('disabled', 'disabled');
            $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
        }
    }

    //Función que valida el porcentaje de aceptación que fue ingresado por el usuario
    function ValidarPorcentajeAceptacion()
    {
        if(($$('btnValidarOperacion').attr("IEG")) == '0')
        {
            var fecPresentacion = $.trim($$('txtFechaRegistro').val().replace("__/__/____", ""));

            $$('cbInscripcion').attr('disabled', 'disabled');
            $$('btnValidarOperacion').attr('BCII', '0');
        
            if(fecPresentacion.length > 0)
            {
                var fecPresent = fecPresentacion.split('/');
                var fechaPresentacion = new Date(fecPresent[2], fecPresent[1], fecPresent[0]);
                var fecConstitucion = $$('txtFechaConstitucion').val();
                
                if(fecConstitucion.length > 0)
                {
                    var fecConst = fecConstitucion.split('/');

                    var fechaConstitucion = new Date(fecConst[2], fecConst[1], fecConst[0]);
                
                    if(fechaConstitucion.getTime() <= fechaPresentacion.getTime())
                    {
                        $$('txtPorcentajeAceptacion').removeAttr('disabled');
                        
                        var indicador = $$('cbInscripcion').val();
                        var fechaActual = new Date();
                        var parteFechaActual = ($$('hdnFechaActual').val().length != 0) ? $$('hdnFechaActual').val() : '';
                        
                        if(parteFechaActual.length > 0)
                        {
                            var partesFecha = parteFechaActual.split('|');
                            
                            fechaActual = new Date(partesFecha[0], partesFecha[1] - 1 , partesFecha[2]);
                        }
                            
                        switch(indicador)
                        {
                            case '0':
                            
                                $$('btnValidarOperacion').attr('BCMM', '0');
                                $$('btnValidarOperacion').attr('BCPA', '0');
                                
                                $$('txtMontoMitigador').attr('disabled', 'disabled');
                                $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                                
                                $MensajePorcentajeAceptacionInvalido.dialog('open');
                                
                            break;
                            case '1': 
                            
                                $$('btnValidarOperacion').attr('BCMM', '0');
                                $$('btnValidarOperacion').attr('BCPA', '0');
                                
                                var fecConstitucion         = $.trim($$('txtFechaConstitucion').val().replace("__/__/____", ""));

                                if(fecConstitucion.length > 0)
                                {
                                    var fecConst                = fecConstitucion.split('/');
                                    var fechaConstitucion       = new Date(fecConst[2], fecConst[1] - 1, fecConst[0]);
                                    
                                    var fechaConstitucionComp   = new Date(fechaConstitucion.getTime() + (30 * 24 * 3600 * 1000))
                                    
                                    var datoPorcentajeAcep      = (($$('txtPorcentajeAceptacion').val().length > 0) ? $$('txtPorcentajeAceptacion').val() : '0');
                                    var porcentajeAceptacion    = parseFloat(datoPorcentajeAcep);
                                    
                                    if(fechaActual.getTime() < fechaConstitucionComp.getTime())
                                    {
                                        $$('btnValidarOperacion').attr('BCMM', '1');
                                        $$('btnValidarOperacion').attr('BCPA', '1');
                                        
                                        $$('txtMontoMitigador').removeAttr('disabled');
                                        $$('txtPorcentajeAceptacion').removeAttr('disabled');
                                        
                                        if((porcentajeAceptacion <= 0) || (porcentajeAceptacion > 80))
                                        {
                                            $$('btnValidarOperacion').attr('BCMM', '0');
                                            $$('txtMontoMitigador').attr('disabled', 'disabled');
                                            
                                            if(porcentajeAceptacion != 0)
                                            {
    	                                        $MensajePorcentajeAceptacionInvalido.dialog('open');
    	                                    }
                                        }
                                        
                                        if(($$('btnValidarOperacion').attr("HAYAVAL")) == '0')
                                        {
                                            $$('btnValidarOperacion').attr('BCMM', '0');
                                            $$('txtMontoMitigador').attr('disabled', 'disabled');
                                        }
                                    }
                                    else
                                    {
                                        var montoMitigador          = parseFloat($$('txtMontoMitigador').val());
                                        var porcentajeAceptacion    = parseFloat($$('txtPorcentajeAceptacion').val());
                                    
                                        $$('btnValidarOperacion').attr('BCMM', '0');
                                        $$('btnValidarOperacion').attr('BCPA', '0');
                                        
                                        $$('txtMontoMitigador').attr('disabled', 'disabled');
                                        $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                        	            
    	                                $MensajePorcentajeAceptacionInvalido.dialog('open');
                                    }
                                }
                                
                            break;
                            case '2': 
                                
                                var fecConstitucion = $.trim($$('txtFechaConstitucion').val().replace("__/__/____", ""));

                                if(fecConstitucion.length > 0)
                                {
                                    var fecConst                = fecConstitucion.split('/');
                                    var fechaConstitucion       = new Date(fecConst[2], fecConst[1] - 1, fecConst[0]);
                                    
                                    var fechaConstitucionComp   = new Date(fechaConstitucion.getTime() + (60 * 24 * 3600 * 1000))
                                
                                    var datoPorcentajeAcep      = (($$('txtPorcentajeAceptacion').val().length > 0) ? $$('txtPorcentajeAceptacion').val() : '0');
                                    var porcentajeAceptacion    = parseFloat(datoPorcentajeAcep);
                                    
                                    if(fechaActual.getTime() < fechaConstitucionComp.getTime())
                                    {
                                        $$('btnValidarOperacion').attr('BCMM', '1');
                                        $$('btnValidarOperacion').attr('BCPA', '1');
                                        
                                        $$('txtMontoMitigador').removeAttr('disabled');
                                        $$('txtPorcentajeAceptacion').removeAttr('disabled');
                                        
                                        if((porcentajeAceptacion <= 0) || (porcentajeAceptacion > 80))
                                        {
                                            $$('btnValidarOperacion').attr('BCMM', '0');
                                            $$('txtMontoMitigador').attr('disabled', 'disabled');
                                            
                                            if(porcentajeAceptacion != 0)
                                            {
    	                                        $MensajePorcentajeAceptacionInvalido.dialog('open');
    	                                    }
                                        }
                                        
                                        if(($$('btnValidarOperacion').attr("HAYAVAL")) == '0')
                                        {
                                            $$('btnValidarOperacion').attr('BCMM', '0');
                                            $$('txtMontoMitigador').attr('disabled', 'disabled');
                                        }
                                    }
                                    else
                                    {
                                        $$('btnValidarOperacion').attr('BCMM', '0');
                                        $$('btnValidarOperacion').attr('BCPA', '0');
                                        
                                        $$('txtMontoMitigador').attr('disabled', 'disabled');
                                        $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                    	                
                                        $MensajePorcentajeAceptacionInvalido.dialog('open');
                                    }
                                }
                                
                            break;
                            case '3': 
                            
                                $$('btnValidarOperacion').attr('BCMM', '1');
                                $$('btnValidarOperacion').attr('BCPA', '1');

                                $$('txtMontoMitigador').removeAttr('disabled');
                                $$('txtPorcentajeAceptacion').removeAttr('disabled');
                            
                                var datoPorcentajeAcep      = (($$('txtPorcentajeAceptacion').val().length > 0) ? $$('txtPorcentajeAceptacion').val() : '0');
                                var porcentajeAceptacion    = parseFloat(datoPorcentajeAcep);
                                
                                if((porcentajeAceptacion <= 0) || (porcentajeAceptacion > 80))
                                {
                                    $$('btnValidarOperacion').attr('BCMM', '0');
                                    $$('txtMontoMitigador').attr('disabled', 'disabled');
                                    
                                    if(porcentajeAceptacion != 0)
                                    {
                                        $MensajePorcentajeAceptacionInvalido.dialog('open');
                                    }
                                    
                                    if(porcentajeAceptacion === 0)
                                    {
                                        $MensajePorcentajeAceptacionInvalidoIndIns.dialog('open');
                                    }                               
                                }
                                
                                if(($$('btnValidarOperacion').attr("HAYAVAL")) == '0')
                                {
                                    $$('btnValidarOperacion').attr('BCMM', '0');
                                    $$('txtMontoMitigador').attr('disabled', 'disabled');
                                }
                                                                    
                            break;
                            case '-1':
                                        $$('btnValidarOperacion').attr('BCMM', '0');
                                        $$('btnValidarOperacion').attr('BCPA', '0');
                                        
                                        $$('txtMontoMitigador').attr('disabled', 'disabled');
	                                    $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                            break;
                            default: break;
                        }
                    }
                    else
                    {
                        $$('txtMontoMitigador').attr('disabled', 'disabled');
                        $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                        $$('cbInscripcion').attr('disabled', 'disabled');
                    }
                }
                else
                {
                    $$('txtMontoMitigador').attr('disabled', 'disabled');
                    $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
                    $$('cbInscripcion').attr('disabled', 'disabled');
                }
            }
        }
        else
        {
            $$('txtMontoMitigador').attr('disabled', 'disabled');
            $$('txtPorcentajeAceptacion').attr('disabled', 'disabled');
            $$('cbInscripcion').attr('disabled', 'disabled');
            
            $$('btnValidarOperacion').attr('BCMM', '0');
            $$('btnValidarOperacion').attr('BCPA', '0');
            $$('btnValidarOperacion').attr('BCII', '0');
        }
    
        CalcularMontoMitigador();
    }

    //Se ajusta, de forma automática, el tipo de documento legal, según el código del grado de gravamen y el tipo de garantía real
    function ActualizarDocumentoLegal()
    {
        var tipoDocumentoLegal  = $$('cbTipoDocumento').val();
        var tipoGarantiaReal    = $$('cbTipoGarantiaReal').val();
        var gradoGravamen       = $$('cbGravamen').val();
        var existeOpcion        = false;
        var mapeoDocumentoLegal = "";
    
        $$('cbTipoDocumento').val("-1");   
        
        switch(tipoGarantiaReal)
        {
            case '1': 
                    $$('cbTipoDocumento').each(function() {
                                            if($(this).val() == gradoGravamen){
                                                $(this).attr("selected","selected");
                                                return false;
                                            }
                                          });
            break;
            
            case '2': 
                    switch(gradoGravamen)
                    {
                        case '1':  mapeoDocumentoLegal = "5"; 
                        break;
                        case '2':  mapeoDocumentoLegal = "6"; 
                        break;
                        case '3':  mapeoDocumentoLegal = "7"; 
                        break;
                        case '4':  mapeoDocumentoLegal = "8"; 
                        break;
                        default:   mapeoDocumentoLegal = "-1"; 
                        break;
                    }  
                    
                    $$('cbTipoDocumento').each(function() {
                                            if($(this).val() == mapeoDocumentoLegal){
                                                $(this).attr("selected","selected");
                                                return false;
                                            }
                                          });
            break;
            
            case '3':
                    switch(gradoGravamen)
                    {
                        case '1':  mapeoDocumentoLegal = "9"; 
                        break;
                        case '2':  mapeoDocumentoLegal = "10"; 
                        break;
                        case '3':  mapeoDocumentoLegal = "11"; 
                        break;
                        case '4':  mapeoDocumentoLegal = "12"; 
                        break;
                        default:   mapeoDocumentoLegal = "-1"; 
                        break;
                    }  
                    
                    $$('cbTipoDocumento').each(function() {
                                            if($(this).val() == mapeoDocumentoLegal){
                                                $(this).attr("selected","selected");
                                                return false;
                                            }
                                          });
            break;
            
            default: $$('cbTipoDocumento').val("-1");  
            break;
        }
    }
    
//Función que permite hacer el llamado asíncrono al método que permite calcular el monto mitigador
//Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.
function CalcularMontoMitigador() {
    
    var pageUrl = 'frmGarantiasReales.aspx'; 
    var datoPorcentajeAcep = (($$('txtPorcentajeAceptacion').val().length > 0) ? $$('txtPorcentajeAceptacion').val() : '0');
    var datoMontoTotalAvaluo = (($$('txtMontoAvaluo').val().length > 0) ? $$('txtMontoAvaluo').val() : (($$('btnValidarOperacion').attr("MTA").length > 0) ? $$('btnValidarOperacion').attr("MTA") : '0'));

    $.ajax({
        type: "POST",
        url: pageUrl + "/CalcularMontoMitigador",
        data: '{"porcentajeAceptacion":"' + datoPorcentajeAcep + '", "montoTotalAvaluo":"' + datoMontoTotalAvaluo + '"}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: OnSuccess,
        failure: function(response) {
            alert(response);
        }
    });
}

function OnSuccess(response) { 
   $$('txtMontoMitigadorCalculado').val(response);
}

//Función que permite mostrar el mensaje de error cuando la fecha de prescripción es menor a la de constitución, presentación, valuación y/o vencimiento
function MensajeFechaPrescripcionMenor()
{
    if(typeof($MensajeFechaPrescripcionMenor) !== 'undefined')
    { 
        //Función que muestra el mensaje de alerta cuando la fecha de prescripción es inválida, por ser menor a la fecha de constitución, presentación, valuación y vencimiento
        //Esta función requiere que se setee la variable "$camposMensajeFechaPrescripcionMenor", con los campos que son mayores.
        $MensajeFechaPrescripcionMenor = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor incluido en el campo Fecha de prescripción es menor al campo' + (($camposMensajeFechaPrescripcionMenor.length > 0) ? $camposMensajeFechaPrescripcionMenor : ' Fecha de Constitución, Fecha de Presentación, Fecha de Valuación o Fecha de Vencimiento') + '. Favor verificar y ajustar.</p></div></div>')
            .dialog({
                    autoOpen: false, 
                    title: 'Fecha de Prescripción Inválida', 
                    resizable: false,
                    draggable: false,
                    height:235,
                    width:650,
                    closeOnEscape: false,
                    open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
                    modal: true,
                    buttons: {
	                    "Aceptar": function() {
		                    $( this ).dialog( "close" );
    			            
		                    document.body.style.cursor = 'default';		
	                    }
                    }
                });
                
        $MensajeFechaPrescripcionMenor.dialog('open');
    }
}


//Muestra el mensaje de la inconsistencia correspondiente al monto mitigador cuando este tiene un faltante
function MensajeMontoMitigadorMenor()
{
    if(typeof($MensajeCalculoMontoMitigadorMenor) !== 'undefined')
    { 
        if(($$('btnValidarOperacion').attr("MMC")).length > 0) 
        { 
    	    //Función que el mensaje de alerta cuando el monto mitigador calculado es menor al digitado por el usuario
            $MensajeCalculoMontoMitigadorMenor = $('<div class="ui-widget" style="padding-top:2.6em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Existe un faltante de ¢' + ($$('btnValidarOperacion').attr("MMC")) + ', en relación a los datos incluidos en el sistema y lo registrado en el campo monto mitigador.</p></div></div>')
                .dialog({
                        autoOpen: false, 
                        title: 'Monto Mitigador Inválido', 
                        resizable: false,
	                    draggable: false,
                        height:235,
                        width:650,
	                    open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
                        closeOnEscape: false,
                        modal: true,
                        buttons: {
                            "Aceptar": function() { 
        			        
	                            $( this ).dialog( "close" );
        			            
	                            document.body.style.cursor = 'default';

//	                            if(($$('btnValidarOperacion').attr("MEMM")) == '1')
//	                            {
//	                                ModificarGarantia();
//	                            }
//	                            else
                                if(($$('btnValidarOperacion').attr("MEMM")) == '0')
	                            {
	                                ValidarPorcentajeAceptacion();
	                            }
	                            
                                $$('btnValidarOperacion').attr('MEMM', '1');	
                                ModificarGarantia();
                            }
                        }
                    });
        } 

        $MensajeCalculoMontoMitigadorMenor.dialog('open');
    }
}

	

//Muestra el mensaje de la inconsistencia correspondiente al monto mitigador cuando este tiene un sobrante
function MensajeMontoMitigadorMayor()
{
    if(typeof($MensajeCalculoMontoMitigadorMayor) !== 'undefined')
    { 
        if(($$('btnValidarOperacion').attr("MMC")).length > 0) 
        { 
            $MensajeCalculoMontoMitigadorMayor = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Existe un sobrante de ¢' + ($$('btnValidarOperacion').attr("MMC")) + ', en relación a los datos incluidos en el sistema y lo registrado en el campo monto mitigador.</p></div></div>')
                .dialog({
                        autoOpen: false, 
                        title: 'Monto Mitigador Inválido', 
                        resizable: false,
	                    draggable: false,
                        height:235,
                        width:650,
	                    open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
                        closeOnEscape: false,
                        modal: true,
                        buttons: {
	                        "Aceptar": function() { 
        			        
		                        $( this ).dialog( "close" );
        			            
		                        document.body.style.cursor = 'default';
        			            
		                        if(($$('btnValidarOperacion').attr("MEMM")) == '0')
		                        {
		                            ValidarPorcentajeAceptacion();
		                        }
		                        
                                $$('btnValidarOperacion').attr('MEMM', '1');	
                                ModificarGarantia();
	                        }
                        }
                    });
        } 

        $MensajeCalculoMontoMitigadorMayor.dialog('open');
    }
}

//Fin del Siebel 1-23914481. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 26/09/2013.

    //Función que presenta el mensaje en caso de que no exista la fecha de valuación del SICC
    function MensajeFechaValuacionNoExiste()
    {
        if(typeof($MensajeFechaAvaluoNoExisteSICC) !== 'undefined')
        { 
            if(($$('btnValidarOperacion').attr("LDG")).length > 0) 
            { 
                //Función que muestra el mensaje de alerta cuando el monto total y la fecha del avalúo son diferentes a los del SICC
                $MensajeFechaAvaluoNoExisteSICC = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Favor incluir una fecha de valuación para la garantía \"' + ($$('btnValidarOperacion').attr("LDG")) + '\", ya que no registra una en el evento PRT17 del SICC.</p></div></div>')
                    .dialog({
                            autoOpen: false, 
                            title: 'Fecha de Valuación Inválida', 
                            resizable: false,
                            draggable: false,
                            height:235,
                            width:650,
                            closeOnEscape: false,
                            open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
                            modal: true,
                            buttons: {
	                            "Aceptar": function() {
		                            $( this ).dialog( "close" );
            			            
		                            document.body.style.cursor = 'default';		
	                            }
                            }
                        }); 
            }
       
            $MensajeFechaAvaluoNoExisteSICC.dialog('open');
        }
    }

    //Permite ejecutar el evento del botón Modificar, esto del lado del servidor
    function DoHiddenFieldPostBack() 
    { 
        eval($$('hdnBtnPostback').val());
    } 

    //Función que permite modificar el cursor
    function CargarPagina()
    {
        document.body.style.cursor = 'wait';
        return true;
    }

    //Función que permite obtener la diferencia en entre dos fechas
    function getDateDiff(date1, date2, interval) {
        var second = 1000,
        minute = second * 60,
        hour = minute * 60,
        day = hour * 24,
        week = day * 7;
        date1 = new Date(date1).getTime();
        date2 = (date2 == 'now') ? new Date().getTime() : new Date(date2).getTime();
        var timediff = date2 - date1;
        if (isNaN(timediff)) return NaN;
        switch (interval) {
        case "years":
            return date2.getFullYear() - date1.getFullYear();
        case "months":
            return ((date2.getFullYear() * 12 + date2.getMonth()) - (date1.getFullYear() * 12 + date1.getMonth()));
        case "weeks":
            return Math.floor(timediff / week);
        case "days":
            return Math.floor(timediff / day);
        case "hours":
            return Math.floor(timediff / hour);
        case "minutes":
            return Math.floor(timediff / minute);
        case "seconds":
            return Math.floor(timediff / second);
        default:
            return undefined;
        }
   }
    
    /* VALIDACIONES DE LOS DATOS DEL AVALUO */ 
           
    //Función que muestra el mensaje de alerta cuando los datos del avalúo más reciente son diferentes a los registrados en el SICC
    //El formato de los que posee la variable de entrada debe ser: Contabilidad - Oficina - Moneda - Producto - Operación y finalizar con el tag html '<br />'
    function MostrarErrorDatosAvaluoInvalidos(listaOperacionesRelacionadas, listaContratosRelacionados)
    {
        var $mensaje = '';
        var mostrarMensaje = false;
        
        if((listaOperacionesRelacionadas.length > 0) && (listaContratosRelacionados.length > 0))
        {
            mostrarMensaje = true;
            
            $mensaje = $('<div class="ui-widget" style="padding-top:2.2em;">' + 
                            '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' + 
                                '<p>' +
                                    '<span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>' + 
                                    'La garantía ya está relacionada a las siguientes operaciones: <br /><br /><CENTER>' + 
                                    listaOperacionesRelacionadas + ' </CENTER><br />' +
                                    ' y a los siguientes contratos: <br /><br /><CENTER>' +
                                    listaContratosRelacionados + ' </CENTER><br />' +
                                    ' Favor de modificar esta fecha de valuación en el SICC con el fin de contener una homogeneidad de los' +
                                    ' de datos en los avalúos, caso contrario la garantía puede sufrir castigo en el mitigador.' + 
                                '</p>' +
                            '</div>' +
                        '</div>')
                        .dialog({
                            autoOpen: false, 
                            title: 'Operaciones Respaldas por la Garantía', 
                            resizable: false,
                            draggable: false,
                            height:235,
                            width:650,
                            closeOnEscape: false,
                            open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
                            modal: true,
                            buttons: {
	                            "Aceptar": function() {
		                            $( this ).dialog( "close" );
            			            
		                            document.body.style.cursor = 'default';	
		                            
                                    $$('btnValidarOperacion').attr('LISTAOPER', '1');	
                                    ModificarGarantia();
	                            }
                            }
                    });
        }
        else if(listaOperacionesRelacionadas.length > 0) 
        {
            mostrarMensaje = true;
        
            $mensaje = $('<div class="ui-widget" style="padding-top:2.2em;">' + 
                            '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' + 
                                '<p>' +
                                    '<span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>' + 
                                    'La garantía ya está relacionada a las siguientes operaciones: <br /><br /><CENTER>' + 
                                    listaOperacionesRelacionadas + ' </CENTER><br />' +
                                    ' Favor de modificar esta fecha de valuación en el SICC con el fin de contener una homogeneidad de los' +
                                    ' de datos en los avalúos, caso contrario la garantía puede sufrir castigo en el mitigador.' + 
                                '</p>' +
                            '</div>' +
                        '</div>')
                        .dialog({
                            autoOpen: false, 
                            title: 'Operaciones Respaldas por la Garantía', 
                            resizable: false,
                            draggable: false,
                            height:235,
                            width:650,
                            closeOnEscape: false,
                            open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
                            modal: true,
                            buttons: {
	                            "Aceptar": function() {
		                            $( this ).dialog( "close" );
            			            
		                            document.body.style.cursor = 'default';		
		                            
                                    $$('btnValidarOperacion').attr('LISTAOPER', '1');	
                                    ModificarGarantia();
	                            }
                            }
                    });
       }
        else if(listaContratosRelacionados.length > 0)
        {
            mostrarMensaje = true;
            
            $mensaje = $('<div class="ui-widget" style="padding-top:2.2em;">' + 
                            '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' + 
                                '<p>' +
                                    '<span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>' + 
                                    'La garantía ya está relacionada a los siguientes contratos: <br /><br /><CENTER>' + 
                                    listaContratosRelacionados + ' </CENTER><br />' +
                                    ' Favor de modificar esta fecha de valuación en el SICC con el fin de contener una homogeneidad de los' +
                                    ' de datos en los avalúos, caso contrario la garantía puede sufrir castigo en el mitigador.' + 
                                '</p>' +
                            '</div>' +
                        '</div>')
                        .dialog({
                            autoOpen: false, 
                            title: 'Operaciones Respaldas por la Garantía', 
                            resizable: false,
                            draggable: false,
                            height:235,
                            width:650,
                            closeOnEscape: false,
                            open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); $( this ).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" });},
                            modal: true,
                            buttons: {
	                            "Aceptar": function() {
		                            $( this ).dialog( "close" );
            			            
		                            document.body.style.cursor = 'default';	
		                            	
                                    $$('btnValidarOperacion').attr('LISTAOPER', '1');	
                                    ModificarGarantia();
	                            }
                            }
                    });
        }
        
        if(mostrarMensaje)
        {   
            $mensaje.dialog('open');
        }
    }
    
  
    function ModificarGarantia()
    {
        if((($$('btnValidarOperacion').attr("CARGAINICIAL")) == '0') 
              && (($$('btnValidarOperacion').attr("MEMM")) == '1') 
              && (($$('btnValidarOperacion').attr("LISTAOPER")) == '1'))
        {
            __doPostBack('btnModificar','Metodo');
        }
    }

    
    //CONTROL DEL TIPO ACORDEON DEL DETALLE DEL AVALUO
    function MostrarAvaluoReal(habilitarControl){
    
        var panelActivado = parseInt((($$('hdnIndiceAccordionActivo').val() != null) ? $$('hdnIndiceAccordionActivo').val() : "-1"));   
        var activarPanel = parseInt((($$('hdnHabilitarValuacion').val() != null) ? $$('hdnHabilitarValuacion').val() : "0"));

        if(panelActivado === -1)
        {
            panelActivado = false;
        }
    
        if(activarPanel === 1)
        {
            if(!habilitarControl)
            {
                habilitarControl = true;
            }
        }
        
        $( "#accordion" ).accordion({
          icons: { "header": "ui-icon-circle-arrow-e", "activeHeader": "ui-icon-circle-arrow-s"},
          collapsible: true,
          active: panelActivado,
          header: "h3",
          activate: function( event, ui ) {
                            var index = $( this ).accordion("option", "active");
                            
                            if(index === 0)
                            {
                                $$('hdnIndiceAccordionActivo').val("0"); 
                            }
                            else
                            {
                                $$('hdnIndiceAccordionActivo').val("-1");
                            }
                         },
          beforeActivate: function( event, ui ) {
                          
                            if((habilitarControl == false) && (activarPanel === 0))
                            {
                               event.preventDefault();
                            }
                          },
          create: function( event, ui ) {
          
                             if((habilitarControl) || (panelActivado === 0))
                             {
                               $(this).accordion("enable");
                             }
                             else
                             {
                               $(this).accordion("disable");
                               $(this).accordion( "option", "disabled", true );
                             }
                          }
        });
    };
    
    //HABILITAR O DESHABILITAR EL CONTROL DEL DETALLE DEL AVALUO
    function HabilitarAvaluoReal(habiltarControl)
    {
        if(habiltarControl)
        {
            $( "#accordion" ).accordion( "enable" );
            
        }
        else
        {
            $( "#accordion" ).accordion( "disable" );
            $( "#accordion" ).accordion( "option", "disabled", true );
        }
    }
    
    //DESHABILITA Y RETRAE EL CONTROL ACODEON DEL AVALUO DE GARANTIAS REALES
    function ContraerAvaluo()
    {  
        $$('hdnIndiceAccordionActivo').val("-1");
    }
    
    //Función que permite calcular la fecha de prescripción y actualizar este valor en el campo respectivo
    function ActualizarFechaPrescripcion()
    {
        if(($$('btnValidarOperacion').attr("ANNOS_CFP")) != null)
        {
            var annosCFP = parseInt(($$('btnValidarOperacion').attr("ANNOS_CFP")));
            
            if(annosCFP != 'NaN')
            {
                var fecVencimiento = $.trim($$('txtFechaVencimiento').val().replace("__/__/____", ""));

                if(fecVencimiento.length > 0)
                {
                    var fecVenci = fecVencimiento.split('/');
                    var fechaVencimiento = new Date(fecVenci[2], fecVenci[1], fecVenci[0]);
                    var fechaPrescripcionCalc =  new Date((fechaVencimiento.getFullYear() + annosCFP), fechaVencimiento.getMonth(), fechaVencimiento.getDate());
                    
                    var fechaPrecripCalcFormateada = (((fechaPrescripcionCalc.getDate() < 10) ? ('0' + fechaPrescripcionCalc.getDate()) : fechaPrescripcionCalc.getDate()) 
                                                     + '/' + 
                                                     ((fechaPrescripcionCalc.getMonth() < 10) ? ('0' + fechaPrescripcionCalc.getMonth()) : fechaPrescripcionCalc.getMonth())
                                                     + '/' + 
                                                     fechaPrescripcionCalc.getFullYear().toString());

                    if($$('txtFechaPrescripcion') != null)
                    {
                        $$('txtFechaPrescripcion').val(fechaPrecripCalcFormateada);
                    }
                }
                else
                {
                    $$('txtFechaPrescripcion').val('');
                }
            }
        }
    }
    
    //Función que asigna la lista de semestres que deberán ser evaluados en el cáclulo
    function AsignarListaSemestres(listaSemestEval)
    {
        $listaSemestreEvaluar = listaSemestEval;
    }

    //Función que se encargará de habilitar el monto mitigador cuando se ha ingresado un avalúo, esto en caso de que el mismo no exista.
    function HabilitarCampoMontoMitigador(numeroCampoIngresado)
    {
        $$('txtMontoMitigador').attr('disabled', 'disabled');

        var habilitarCampo = true;
        var valuadorEmpresa = parseInt((($$('cbEmpresa').val().length > 0) ? $$('cbEmpresa').val() : '-1'));
        var valuadorPerito = parseInt((($$('cbPerito').val().length > 0) ? $$('cbPerito').val() : '-1'));
        var montoUTT = parseFloat((($$('txtMontoUltTasacionTerreno').val().length > 0) ? $$('txtMontoUltTasacionTerreno').val() : '0'));
        var montoUTNT = parseFloat((($$('txtMontoUltTasacionNoTerreno').val().length > 0) ? $$('txtMontoUltTasacionNoTerreno').val() : '0'));
        var fechaSeguimiento = $.trim($$('txtFechaSeguimiento').val().replace("__/__/____", ""));
                                    

        if((valuadorPerito === -1) && (valuadorEmpresa === -1)) //Se verifica si se ingresó el perito o empresa
        {
            habilitarCampo = false;
        }
        else if((habilitarCampo) && (montoUTT === 0) && (montoUTNT === 0)) //Se revisa si se ingresó el monto de la última tasación terreno o no terreno
        {
            habilitarCampo = false;
        }
        else if((habilitarCampo) && (fechaSeguimiento.length === 0)) //Se verifica si se ingresó la fecha de seguimiento
        {
            habilitarCampo = false;
        }
        
        if(habilitarCampo)
        {
              $$('txtMontoMitigador').removeAttr('disabled');
              CalcularMontoMitigador();
        }
    }


    //Función que permite hacer el llamado asíncrono al método que permite calcular el monto de la tasación actualizada dle terreno y no terreno calculado
    //Siebel 1-24077731. Realizado por: Arnoldo Martinelli M. - Lidersoft Internacional S.A., 29/11/2013.
    function CalcularMontoTAT_TANT() {
        
        var pageUrl = 'frmGarantiasReales.aspx'; 
        var datoMontoUltTasTerr = (($$('txtMontoUltTasacionTerreno').val().length > 0) ? $$('txtMontoUltTasacionTerreno').val() : '');
        var datoMontoUltTasNoTerr = (($$('txtMontoUltTasacionNoTerreno').val().length > 0) ? $$('txtMontoUltTasacionNoTerreno').val() : '');
        var datoListaSemestres = (($listaSemestreEvaluar.length > 0) ? $listaSemestreEvaluar : '');
        var datoTipoBien = (($$('cbTipoBien').val().length > 0) ? $$('cbTipoBien').val() : '');
        var datoErrorGraveAvaluo = parseInt(($$('btnValidarOperacion').attr("EGA")));

        if((datoErrorGraveAvaluo != null) && (datoErrorGraveAvaluo == 0) && ((datoTipoBien === '1') || (datoTipoBien === '2')))
        {
            $.ajax({
                type: "POST",
                url: pageUrl + "/CalcularMontoTasacionActualizada",
                data: "{'montoUltimaTasacionTerreno':'" + datoMontoUltTasTerr + "', 'montoUltimaTasacionNoTerreno':'" + datoMontoUltTasNoTerr + "', 'listaSemestresJSON':'" + datoListaSemestres  + "', 'tipoBien':'" + datoTipoBien + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: calculoExitoso,
                failure: function(response) {
                    $$('lblMensaje').val(response);
                    alert(response);
                }
            });
        }
    }

    function calculoExitoso(response) { 
    
       if(response.length > 1)
       {
            var datosRetornados = response.split("|");
            var datoTipoBien = (($$('cbTipoBien').val().length > 0) ? $$('cbTipoBien').val() : '');
            
            if((datosRetornados != null) && (datosRetornados[0] != null))
            {
                $$('txtMontoTasActTerreno').val(datosRetornados[0]);
            }
            else
            {
                $$('txtMontoTasActTerreno').val('');
            }
            
            if((datosRetornados != null) && (datosRetornados[1] != null))
            {
                $$('txtMontoTasActNoTerreno').val(datosRetornados[1]);
            }
            else
            {
                $$('txtMontoTasActNoTerreno').val('');
            }
            
            if((datosRetornados != null) && (datosRetornados[2] != null))
            {
                $$('hdnListaSemestresCalculados').val(datosRetornados[2]);
            }
            else
            {
                $$('hdnListaSemestresCalculados').val('');
            }
            
            if((datoTipoBien === '1') && ($$('txtMontoTasActTerreno').val().length > 0))
            {
                $$('txtFechaSeguimiento').removeAttr('disabled');
                $$('igbCalendarioSeguimiento').removeAttr('disabled');
            }
            else if((datoTipoBien === '2') && ($$('txtMontoTasActTerreno').val().length > 0) && ($$('txtMontoTasActNoTerreno').val().length > 0))
            {
                $$('txtFechaSeguimiento').removeAttr('disabled');
                $$('igbCalendarioSeguimiento').removeAttr('disabled');
            }
            else
            {
                $$('txtFechaSeguimiento').attr('disabled', 'disabled');
                $$('igbCalendarioSeguimiento').attr('disabled', 'disabled');
            }
       }
       else
       {
           $$('txtMontoTasActTerreno').val('');
           $$('txtMontoTasActNoTerreno').val('');
           $$('txtFechaSeguimiento').attr('disabled', 'disabled');
           $$('igbCalendarioSeguimiento').attr('disabled', 'disabled');
       }
    }