//El archivo debe ser minimizado, se usó la herramienta http://jscompress.com/, el resultado se copia en el archivo SaldosTotalesPorcResp_min.js

'use strict';

function SaldosTotalesPorcResp_PageInit() {

    document.body.style.cursor = 'default';
    document.documentElement.style.cursor = 'default';

    MostrarGarantiasFiduciariasRelacionadas(true);
    MostrarGarantiasRealesRelacionadas(true);
    MostrarGarantiasValoresRelacionadas(true);

    $("#accordionGF").accordion();
    $("#accordionGR").accordion();
    $("#accordionGV").accordion();

    $datosConsulta = '';
    $arregloOperaciones = '';
    $queryString = new Array();
    $cuentaMensajes = 0;
    $porcentajeCien = false;
    AsignarCambioManual(false);
    AsignarSumatoriaValida(true);

    HabilitarRegionBusqueda(-1);

    ValidarPermisoEdicion();

    $$('txtContabilidad').on("keydown", function (event) {
        var forbiddenKeys = new Array('c', 'x', 'v');
        var keyCode = (event.keyCode) ? event.keyCode : event.which;
        var isCtrl;
        isCtrl = event.ctrlKey
        if (isCtrl) {
            for (i = 0; i < forbiddenKeys.length; i++) {
                if (forbiddenKeys[i] == String.fromCharCode(keyCode).toLowerCase()) {
                    return true;
                }
            }
        }
        else if (!(event.keyCode == 8                                // backspace
        || event.keyCode == 9
        || event.keyCode == 46                              // delete
        || (event.keyCode >= 35 && event.keyCode <= 40)     // arrow keys/home/end
        || (event.keyCode >= 48 && event.keyCode <= 57)     // numbers on keyboard
        || (event.keyCode >= 96 && event.keyCode <= 105))   // number on keypad
        ) {
            event.preventDefault();     // Prevent character input
        }
    });

    $$('txtOficina').on("keydown", function (event) {
        var forbiddenKeys = new Array('c', 'x', 'v');
        var keyCode = (event.keyCode) ? event.keyCode : event.which;
        var isCtrl;
        isCtrl = event.ctrlKey
        if (isCtrl) {
            for (i = 0; i < forbiddenKeys.length; i++) {
                if (forbiddenKeys[i] == String.fromCharCode(keyCode).toLowerCase()) {
                    return true;
                }
            }
        }
        else if (!(event.keyCode == 8                                // backspace
        || event.keyCode == 9
        || event.keyCode == 46                              // delete
        || (event.keyCode >= 35 && event.keyCode <= 40)     // arrow keys/home/end
        || (event.keyCode >= 48 && event.keyCode <= 57)     // numbers on keyboard
        || (event.keyCode >= 96 && event.keyCode <= 105))   // number on keypad
        ) {
            event.preventDefault();     // Prevent character input
        }
    });

    $$('txtMoneda').on("keydown", function (event) {
        var forbiddenKeys = new Array('c', 'x', 'v');
        var keyCode = (event.keyCode) ? event.keyCode : event.which;
        var isCtrl;
        isCtrl = event.ctrlKey
        if (isCtrl) {
            for (i = 0; i < forbiddenKeys.length; i++) {
                if (forbiddenKeys[i] == String.fromCharCode(keyCode).toLowerCase()) {
                    return true;
                }
            }
        }
        else if (!(event.keyCode == 8                                // backspace
        || event.keyCode == 9
        || event.keyCode == 46                              // delete
        || (event.keyCode >= 35 && event.keyCode <= 40)     // arrow keys/home/end
        || (event.keyCode >= 48 && event.keyCode <= 57)     // numbers on keyboard
        || (event.keyCode >= 96 && event.keyCode <= 105))   // number on keypad
        ) {
            event.preventDefault();     // Prevent character input
        }
    });

    $$('txtProducto').on("keydown", function (event) {
        var forbiddenKeys = new Array('c', 'x', 'v');
        var keyCode = (event.keyCode) ? event.keyCode : event.which;
        var isCtrl;
        isCtrl = event.ctrlKey
        if (isCtrl) {
            for (i = 0; i < forbiddenKeys.length; i++) {
                if (forbiddenKeys[i] == String.fromCharCode(keyCode).toLowerCase()) {
                    return true;
                }
            }
        }
        else if (!(event.keyCode == 8                                // backspace
        || event.keyCode == 9
        || event.keyCode == 46                              // delete
        || (event.keyCode >= 35 && event.keyCode <= 40)     // arrow keys/home/end
        || (event.keyCode >= 48 && event.keyCode <= 57)     // numbers on keyboard
        || (event.keyCode >= 96 && event.keyCode <= 105))   // number on keypad
        ) {
            event.preventDefault();     // Prevent character input
        }
    });

    $$('txtOperacion').on("keydown", function (event) {
        var forbiddenKeys = new Array('c', 'x', 'v');
        var keyCode = (event.keyCode) ? event.keyCode : event.which;
        var isCtrl;
        isCtrl = event.ctrlKey
        if (isCtrl) {
            for (i = 0; i < forbiddenKeys.length; i++) {
                if (forbiddenKeys[i] == String.fromCharCode(keyCode).toLowerCase()) {
                    return true;
                }
            }
        }
        else if (!(event.keyCode == 8                                // backspace
        || event.keyCode == 9
        || event.keyCode == 46                              // delete
        || (event.keyCode >= 35 && event.keyCode <= 40)     // arrow keys/home/end
        || (event.keyCode >= 48 && event.keyCode <= 57)     // numbers on keyboard
        || (event.keyCode >= 96 && event.keyCode <= 105))   // number on keypad
        ) {
            event.preventDefault();     // Prevent character input
        }
    });


    $$('txtCedulaFiador').on("keydown", function (event) {
        var forbiddenKeys = new Array('c', 'x', 'v');
        var keyCode = (event.keyCode) ? event.keyCode : event.which;
        var isCtrl;
        isCtrl = event.ctrlKey
        if (isCtrl) {
            for (i = 0; i < forbiddenKeys.length; i++) {
                if (forbiddenKeys[i] == String.fromCharCode(keyCode).toLowerCase()) {
                    return true;
                }
            }
        }
        else if (!(event.keyCode == 8                                // backspace
        || event.keyCode == 9
        || event.keyCode == 46                              // delete
        || (event.keyCode >= 35 && event.keyCode <= 40)     // arrow keys/home/end
        || (event.keyCode >= 48 && event.keyCode <= 57)     // numbers on keyboard
        || (event.keyCode >= 96 && event.keyCode <= 105))   // number on keypad
        ) {
            event.preventDefault();     // Prevent character input
        }
    });

    $$('txtPartido').on("keydown", function (event) {
        var codigoTipoGarantiaReal = parseInt($$('cbTipoGarantiaReal').val());
        if (codigoTipoGarantiaReal != 3) {
            if (($(this).val().length + 1) <= 1) {
                if (!(event.keyCode == 8                                // backspace
                || event.keyCode == 9
                || event.keyCode == 46                              // delete
                || (event.keyCode >= 35 && event.keyCode <= 40)     // arrow keys/home/end
                || (event.keyCode >= 49 && event.keyCode <= 55)     // numbers on keyboard
                || (event.keyCode >= 97 && event.keyCode <= 103))   // number on keypad
                ) {
                    event.preventDefault();     // Prevent character input
                  }
                }
                else {
                    if (!(event.keyCode == 8                                // backspace
                    || event.keyCode == 9
                    || event.keyCode == 46                              // delete
                    || (event.keyCode >= 35 && event.keyCode <= 40))     // arrow keys/home/end
                    ) {
                        event.preventDefault();     // Prevent character input
                      }
                }
            //if ((!$.isNumeric(String.fromCharCode(event.which))) || (event.keyCode == 48) || (event.keyCode == 56) || (event.keyCode == 57) ||
            //    (event.keyCode == 96) || (event.keyCode == 104) || (event.keyCode == 105) || (($(this).val().length) >= 1)) {
            //    if ((event.keyCode != 8) && (event.keyCode != 9) && (event.keyCode != 46) && (!(event.keyCode >= 35 && event.keyCode <= 40))) {
            //        event.preventDefault();
            //    }
            //}
        }
    });

    $$('txtNumFinca').on("keydown", function (event) {
        var codigoClase = parseInt($$('cbClaseGarantiaReal').val());
        var forbiddenKeys = new Array('c', 'x', 'v');
        var keyCode = (event.keyCode) ? event.keyCode : event.which;
        var isCtrl;
        isCtrl = event.ctrlKey

        if ((codigoClase >= 10) && (codigoClase <= 29) && (codigoClase != 11)) {
            if (($(this).val().length + 1) <= 6) {
                if (isCtrl) {
                    for (i = 0; i < forbiddenKeys.length; i++) {
                        if (forbiddenKeys[i] == String.fromCharCode(keyCode).toLowerCase()) {
                            return true;
                        }
                    }
                }
                else if (!(event.keyCode == 8                                // backspace
                    || event.keyCode == 9
                    || event.keyCode == 46                              // delete
                    || (event.keyCode >= 35 && event.keyCode <= 40)     // arrow keys/home/end
                    || (event.keyCode >= 48 && event.keyCode <= 57)     // numbers on keyboard
                    || (event.keyCode >= 96 && event.keyCode <= 105))   // number on keypad
                    ) {
                    event.preventDefault();     // Prevent character input
                }
            }
            else {
                if ($.isNumeric(String.fromCharCode(event.which))) {
                    event.preventDefault();
                }
                else if (isCtrl) {
                    for (i = 0; i < forbiddenKeys.length; i++) {
                        if (forbiddenKeys[i] == String.fromCharCode(keyCode).toLowerCase()) {
                            return true;
                        }
                    }
                }
                else if (!(event.keyCode == 8                                // backspace
                    || event.keyCode == 9
                    || event.keyCode == 46                              // delete
                    || (event.keyCode >= 35 && event.keyCode <= 40))     // arrow keys/home/end
                    ) {
                    event.preventDefault();     // Prevent character input
                }
            }
        }
        else if ((codigoClase >= 30) && (codigoClase <= 69) && (codigoClase != 38) && (codigoClase != 43)) {
            if (isCtrl) {
                for (i = 0; i < forbiddenKeys.length; i++) {
                    if (forbiddenKeys[i] == String.fromCharCode(keyCode).toLowerCase()) {
                        return true;
                    }
                }
            }
            else if (!(event.keyCode == 8                                // backspace
                || event.keyCode == 9
                || event.keyCode == 46                              // delete
                || (event.keyCode >= 35 && event.keyCode <= 40)     // arrow keys/home/end
                || (event.keyCode >= 48 && event.keyCode <= 57)     // numbers on keyboard
                || (event.keyCode >= 96 && event.keyCode <= 105))   // number on keypad
                ) {
                        event.preventDefault();     // Prevent character input
            }
        }
    });

    $$('txtGrado').on("keydown", function (event) {
        if (!(event.keyCode == 8                                // backspace
        || event.keyCode == 9
        || event.keyCode == 46                              // delete
        || (event.keyCode >= 35 && event.keyCode <= 40)     // arrow keys/home/end
        || (event.keyCode >= 48 && event.keyCode <= 57)     // numbers on keyboard
        || (event.keyCode >= 96 && event.keyCode <= 105))   // number on keypad
        ) {
            event.preventDefault();     // Prevent character input
        }
    });    

    /********************************************************************************************************************************************************************************************************************
   
   MENSAJES 
   
   ********************************************************************************************************************************************************************************************************************/

    $MensajePorcentajeMaximo = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>Debido al valor ingresado sólo está operación o contrato mostrará un porcentaje de responsabilidad y monto mitigador.</p></div></div>')
                .dialog({
                    autoOpen: false,
                    title: 'Porcentaje Responsabilidad',
                    resizable: false,
                    draggable: false,
                    height: 235,
                    width: 650,
                    closeOnEscape: false,
                    open: function (event, ui) { $(".ui-dialog-titlebar-close").hide(); $(this).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" }); },
                    modal: true,
                    buttons: {
                        "Aceptar": function () {
                            $(this).dialog("close");

                            AsignarPorcentajeMinimo();
                        },
                        "Cancelar": function () {
                            $(this).dialog("close");

                            $$('txtPorcentajeResponsabilidad').focus();
                        }
                    }
                });


}



/********************************************************************************************************************************************************************************************************************

INICIALIZACION DE COMPONENTES, VALIDACIONES Y COMPORTAMIENTOS

********************************************************************************************************************************************************************************************************************/



//CONTROL DEL TIPO ACORDEON DE LAS GARANTIAS FIDUCIARIAS RELACIONADAS
function MostrarGarantiasFiduciariasRelacionadas(habilitarControl) {

    var panelActivado = parseInt((($$('hdnIndiceAccordionGFActivo').val() != null) ? $$('hdnIndiceAccordionGFActivo').val() : "-1"));
    var activarPanel = parseInt((($$('hdnHabilitarGF').val() != null) ? $$('hdnHabilitarGF').val() : "0"));

    if (panelActivado === -1) {
        panelActivado = false;
    }

    if (activarPanel === 1) {
        if (!habilitarControl) {
            habilitarControl = true;
        }
    }

    $("#accordionGF").accordion({
        icons: { "header": "ui-icon-circle-arrow-e", "activeHeader": "ui-icon-circle-arrow-s" },
        collapsible: true,
        active: panelActivado,
        header: "h3",
        activate: function (event, ui) {
            var index = $(this).accordion("option", "active");

            if (index === 0) {
                $$('hdnIndiceAccordionGFActivo').val("0");
            }
            else {
                $$('hdnIndiceAccordionGFActivo').val("-1");
            }
        },
        beforeActivate: function (event, ui) {

            if ((habilitarControl == false) && (activarPanel === 0)) {
                event.preventDefault();
            }
        },
        create: function (event, ui) {

            if ((habilitarControl) || (panelActivado === 0)) {
                $(this).accordion("enable");
            }
            else {
                $(this).accordion("disable");
                $(this).accordion("option", "disabled", true);
            }
        }
    });
}

//CONTROL DEL TIPO ACORDEON DE LAS GARANTIAS REALES RELACIONADAS
function MostrarGarantiasRealesRelacionadas(habilitarControl) {

    var panelActivado = parseInt((($$('hdnIndiceAccordionGRActivo').val() != null) ? $$('hdnIndiceAccordionGRActivo').val() : "-1"));
    var activarPanel = parseInt((($$('hdnHabilitarGR').val() != null) ? $$('hdnHabilitarGR').val() : "0"));

    if (panelActivado === -1) {
        panelActivado = false;
    }

    if (activarPanel === 1) {
        if (!habilitarControl) {
            habilitarControl = true;
        }
    }

    $("#accordionGR").accordion({
        icons: { "header": "ui-icon-circle-arrow-e", "activeHeader": "ui-icon-circle-arrow-s" },
        collapsible: true,
        active: panelActivado,
        header: "h3",
        activate: function (event, ui) {
            var index = $(this).accordion("option", "active");

            if (index === 0) {
                $$('hdnIndiceAccordionGRActivo').val("0");
            }
            else {
                $$('hdnIndiceAccordionGRActivo').val("-1");
            }
        },
        beforeActivate: function (event, ui) {

            if ((habilitarControl == false) && (activarPanel === 0)) {
                event.preventDefault();
            }
        },
        create: function (event, ui) {

            if ((habilitarControl) || (panelActivado === 0)) {
                $(this).accordion("enable");
            }
            else {
                $(this).accordion("disable");
                $(this).accordion("option", "disabled", true);
            }
        }
    });
}

//CONTROL DEL TIPO ACORDEON DE LAS GARANTIAS VALOR RELACIONADAS
function MostrarGarantiasValoresRelacionadas(habilitarControl) {

    var panelActivado = parseInt((($$('hdnIndiceAccordionGVActivo').val() != null) ? $$('hdnIndiceAccordionGVActivo').val() : "-1"));
    var activarPanel = parseInt((($$('hdnHabilitarGV').val() != null) ? $$('hdnHabilitarGV').val() : "0"));

    if (panelActivado === -1) {
        panelActivado = false;
    }

    if (activarPanel === 1) {
        if (!habilitarControl) {
            habilitarControl = true;
        }
    }

    $("#accordionGV").accordion({
        icons: { "header": "ui-icon-circle-arrow-e", "activeHeader": "ui-icon-circle-arrow-s" },
        collapsible: true,
        active: panelActivado,
        header: "h3",
        activate: function (event, ui) {
            var index = $(this).accordion("option", "active");

            if (index === 0) {
                $$('hdnIndiceAccordionGVActivo').val("0");
            }
            else {
                $$('hdnIndiceAccordionGVActivo').val("-1");
            }
        },
        beforeActivate: function (event, ui) {

            if ((habilitarControl == false) && (activarPanel === 0)) {
                event.preventDefault();
            }
        },
        create: function (event, ui) {

            if ((habilitarControl) || (panelActivado === 0)) {
                $(this).accordion("enable");
            }
            else {
                $(this).accordion("disable");
                $(this).accordion("option", "disabled", true);
            }
        }
    });
}

//HABILITAR O DESHABILITAR EL CONTROL DE LAS GARANTIAS FIDUCIARIAS RELACIONDAS
function HabilitarGF(habiltarControl) {
    if (habiltarControl) {
        $("#accordionGF").accordion("enable");

    }
    else {
        $("#accordionGF").accordion("disable");
        $("#accordionGF").accordion("option", "disabled", true);
    }
}

//HABILITAR O DESHABILITAR EL CONTROL DE LAS GARANTIAS REALES RELACIONDAS
function HabilitarGR(habiltarControl) {
    if (habiltarControl) {
        $("#accordionGR").accordion("enable");

    }
    else {
        $("#accordionGR").accordion("disable");
        $("#accordionGR").accordion("option", "disabled", true);
    }
}

//HABILITAR O DESHABILITAR EL CONTROL DE LAS GARANTIAS VALORES RELACIONDAS
function HabilitarGV(habiltarControl) {
    if (habiltarControl) {
        $("#accordionGV").accordion("enable");

    }
    else {
        $("#accordionGV").accordion("disable");
        $("#accordionGV").accordion("option", "disabled", true);
    }
}

//DESHABILITA Y RETRAE EL CONTROL ACORDEON DE LAS GARANTIAS FIDUCIARIAS RELACIONDAS
function ContraerGFR() {
    $$('hdnIndiceAccordionGFActivo').val("-1");
}

//DESHABILITA Y RETRAE EL CONTROL ACORDEON DE LAS GARANTIAS REALES RELACIONDAS
function ContraerGRR() {
    $$('hdnIndiceAccordionGRActivo').val("-1");
}

//DESHABILITA Y RETRAE EL CONTROL ACORDEON DE LAS GARANTIAS VALORES RELACIONDAS
function ContraerGVR() {
    $$('hdnIndiceAccordionGVActivo').val("-1");
}

//SE HABILITAN LAS REGIÓN DE BÚSQUEDA INDICADA
function HabilitarRegionBusqueda(codigoRegion) {
    $$('filaBusquedaGarantiaFiduciaria').hide();
    $$('filaTipoGarantiaReal').hide();
    $$('filaBusquedaGarantiaReal').hide();
    $$('filaClaseGarantiaReal').hide();
    $$('filaGradoCedula').hide();
    $$('filaBusquedaGarantiaValor').hide();
    $$('accordionGF').hide();
    $$('accordionGR').hide();
    $$('accordionGV').hide();
    $$('filaDetalleAjuste').hide();
    $$('gdvOperaciones').hide();

    
    switch (codigoRegion) {
        case 1: //Región de búsqueda por operación crediticia
            $$('filaBusquedaOperacion').show();
            $$('filaTipoGarantiaReal').hide();
            $$('filaClaseGarantiaReal').hide();
            $$('filaBusquedaGarantia').hide();

            $$('lblTipoOperacion').text('Operación:');

            break;
        case 2: //Región de búsqueda por contrato
            $$('filaBusquedaOperacion').show();
            $$('filaTipoGarantiaReal').hide();
            $$('filaClaseGarantiaReal').hide();
            $$('filaBusquedaGarantia').hide();

            $$('lblTipoOperacion').text('Contrato:');

            break;
        case 3: //Región de búsqueda por garantía
            $$('filaBusquedaGarantia').show();
            $$('filaTipoGarantiaReal').hide();
            $$('filaClaseGarantiaReal').hide();
            $$('filaBusquedaOperacion').hide();
            break;
        default:
            break;
    }
}

//SE INICIALIZAN TODOS LOS CAMPOS DE LA SECCIÓN DE BÚSQUEDA
function LimpiarCamposBusqueda() {
    $$('txtContabilidad').val('1');
    $$('txtOficina').val('');
    $$('txtMoneda').val('');
    $$('txtProducto').val('');
    $$('txtOperacion').val('');
    $$('cbTipoPersona').val('-1');
    $$('txtCedulaFiador').val('');
    $$('cbClaseGarantiaReal').val('-1');
    $$('txtPartido').val('');
    $$('txtNumFinca').val('');
    $$('txtGrado').val('');
    $$('txtCedulaHipotecaria').val('');
    $$('cbClaseGarantiaValor').val('-1');
    $$('txtNumeroSeguridad').val('');
}

//SE HABILITAN LOS CAMPOS DE BUSQUEDA SEGUN EL TIPO SELECCIONADO
function HabilitarCamposBusqueda() {
    var tipoBusqueda = parseInt((($$('cbTipoBusqueda').val() != null) ? $$('cbTipoBusqueda').val() : "1"));

    $$('lblMensaje').text('');

    $$('tablaGarantiasFiduciarias').empty();
    $$('tablaGarantiasReales').empty();
    $$('tablaGarantiasValor').empty();
  
    if ((typeof ($queryString) === 'undefined') || ((typeof ($queryString) !== 'undefined') && ($queryString.length == 0))) {
        LimpiarCamposBusqueda();
        $$('filaRetorno').hide();
    }

    switch (tipoBusqueda) {
        case 1:
            HabilitarRegionBusqueda(1);
            $$('columnaProducto').show();
            break;
        case 2:
            HabilitarRegionBusqueda(2);
            $$('columnaProducto').hide();
            break;
        case 3:
            HabilitarRegionBusqueda(3);

            var codigoCatalogo = parseInt((($$('hdnCatalogoGarantias').val() != null) ? $$('hdnCatalogoGarantias').val() : "-1"));

            CargarListaCatalogo(codigoCatalogo, $$('cbTipoGarantia'), '-1', '-1');

            break;
        default:
            HabilitarRegionBusqueda(1);
            $$('columnaProducto').show();
            break;
    }
}

//SE HABILITAN LOS CAMPOS DE BUSQUEDA SEGUN EL TIPO DE GARANTIA SELECCIONADO
function HabilitarCamposBusquedaGarantia() {
    var tipoBusqueda = parseInt(((($$('cbTipoGarantia').val() != null) ? $$('cbTipoGarantia').val() : "-1")));

    var codigoCatalogo = "-1";
 
    if ((typeof ($queryString) === 'undefined') || ((typeof ($queryString) !== 'undefined') && ($queryString.length == 0))) {
        LimpiarCamposBusqueda();
        $$('filaRetorno').hide();
    }

    switch (tipoBusqueda) {
        case 1:
            $$('filaBusquedaGarantiaFiduciaria').show();
            $$('filaTipoGarantiaReal').hide();
            $$('filaBusquedaGarantiaReal').hide();
            $$('filaClaseGarantiaReal').hide();
            $$('filaGradoCedula').hide();
            $$('filaBusquedaGarantiaValor').hide();

            codigoCatalogo = parseInt((($$('hdnCatalogoTiposPersona').val() != null) ? $$('hdnCatalogoTiposPersona').val() : "-1"));

            CargarListaCatalogo(codigoCatalogo, $$('cbTipoPersona'), '-1', '-1');
 
            break;
        case 2:
            $$('filaTipoGarantiaReal').show();
            $$('filaBusquedaGarantiaFiduciaria').hide();
            $$('filaBusquedaGarantiaReal').hide();
            $$('filaClaseGarantiaReal').hide();
            $$('filaGradoCedula').hide();
            $$('filaBusquedaGarantiaValor').hide();

            codigoCatalogo = parseInt((($$('hdnCatalogoTiposGarantiaReal').val() != null) ? $$('hdnCatalogoTiposGarantiaReal').val() : "-1"));

            CargarListaCatalogo(codigoCatalogo, $$('cbTipoGarantiaReal'), '-1', '-1');

            break;
        case 3:
            $$('filaBusquedaGarantiaValor').show();
            $$('filaBusquedaGarantiaFiduciaria').hide();
            $$('filaTipoGarantiaReal').hide();
            $$('filaClaseGarantiaReal').hide();
            $$('filaGradoCedula').hide();
            $$('filaBusquedaGarantiaReal').hide();

            codigoCatalogo = parseInt((($$('hdnCatalogoClasesGarantia').val() != null) ? $$('hdnCatalogoClasesGarantia').val() : "-1"));

            CargarListaCatalogo(codigoCatalogo, $$('cbClaseGarantiaValor'), '3', '-1');

            break;
        default:
            $$('filaBusquedaGarantiaFiduciaria').hide();
            $$('filaTipoGarantiaReal').hide();
            $$('filaClaseGarantiaReal').hide();
            $$('filaBusquedaGarantiaReal').hide();
            $$('filaGradoCedula').hide();
            $$('filaBusquedaGarantiaValor').hide();
            break;
    }
}

//SE HABILITAN LOS CAMPOS DE BUSQUEDA SEGUN EL TIPO DE GARANTIA SELECCIONADO
function HabilitarCamposBusquedaGarantiaReal() {
    var tipoBusqueda = parseInt((($$('cbTipoGarantiaReal').val() != null) ? $$('cbTipoGarantiaReal').val() : "1"));
    var codigoCatalogo = "-1";
 
    if ((typeof ($queryString) === 'undefined') || ((typeof ($queryString) !== 'undefined') && ($queryString.length == 0))) {
        LimpiarCamposBusqueda();
        $$('filaRetorno').hide();
    }

    codigoCatalogo = parseInt((($$('hdnCatalogoClasesGarantia').val() != null) ? $$('hdnCatalogoClasesGarantia').val() : "-1"));

    CargarListaCatalogo(codigoCatalogo, $$('cbClaseGarantiaReal'), '2', tipoBusqueda);

 
    $$('filaTipoGarantiaReal').show();
    $$('filaBusquedaGarantiaReal').show();
    $$('filaClaseGarantiaReal').show();
    $$('filaBusquedaGarantiaFiduciaria').hide();
    $$('filaBusquedaGarantiaValor').hide();

    switch (tipoBusqueda) {
        case 1:
            $$('filaGradoCedula').hide();

            $$('lblPartido').text('Partido:');
 
            break;
        case 2:
            $$('filaGradoCedula').show();
            $$('filaGradoCedula').css("display", "inline");

            $$('lblPartido').text('Partido:');
 
            break;
        case 3:
            $$('filaGradoCedula').hide();

            $$('lblPartido').text('Clase Bien:');
 
            break;
        default:
            $$('lblPartido').text('Partido:');
 
            $$('filaGradoCedula').hide();

            break;
    }
}

//SE VALIDAN LOS CAMPOS DE LA OPERACION O CONTRATO ANTES DE VERIFICAR SU EXISTENCIA A NIVEL DE BASE DE DATOS.
function ValidarCamposOpercion() {
    var tipoBusqueda = parseInt((($$('cbTipoBusqueda').val() != null) ? $$('cbTipoBusqueda').val() : "-1"));

    if ($$('txtContabilidad').val().length === 0) {
        $$('lblMensaje').text('Debe ingresar el código de contabilidad');
        return false;
    }
    else if ($$('txtOficina').val().length === 0) {
        $$('lblMensaje').text('Debe ingresar el código de oficina');
        return false;
    }
    else if ($$('txtMoneda').val().length === 0) {
        $$('lblMensaje').text('Debe ingresar el código de moneda');
        return false;
    }
    else if ((tipoBusqueda === 1) && ($$('txtProducto').val().length === 0)) {
        $$('lblMensaje').text('Debe ingresar el código del producto');
        return false;
    }
    else if ($$('txtOperacion').val().length === 0) {
        if (tipoBusqueda === 1) {
            $$('lblMensaje').text('Debe ingresar el número de operación');
        }
        else {
            $$('lblMensaje').text('Debe ingresar el número de contrato');
        }
        return false;
    }

    return true;
}

//SE VALIDAN LOS CAMPOS DE LA GARANTIA ANTES DE VERIFICAR SU EXISTENCIA A NIVEL DE BASE DE DATOS.
function ValidarCamposGarantia() {
    var tipoBusqueda = parseInt((($$('cbTipoGarantia').val() != null) ? $$('cbTipoGarantia').val() : "-1"));

    if ((tipoBusqueda === 1) && (($$('cbTipoPersona').val().length === 0) || ($$('cbTipoPersona').val() == '-1'))) {
        $$('lblMensaje').text('Debe seleccionar el tipo de persona del fiador');
        return false;
    }
    else if ((tipoBusqueda === 1) && ($$('txtCedulaFiador').val().length === 0)) {
        $$('lblMensaje').text('Debe ingresar la identificación del fiador');
        return false;
    }
    else if ((tipoBusqueda === 2) && (($$('cbTipoGarantiaReal').val().length === 0) || ($$('cbTipoGarantiaReal').val() == '-1'))) {
        $$('lblMensaje').text('Debe seleccionar el tipo de garantía real');
        return false;
    }
    else if ((tipoBusqueda === 2) && (($$('cbClaseGarantiaReal').val().length === 0) || ($$('cbClaseGarantiaReal').val() == '-1'))) {
        $$('lblMensaje').text('Debe seleccionar la clase de garantía');
        return false;
    }
    else if ((tipoBusqueda === 2) && ($$('cbTipoGarantiaReal').val() != '3') && ($$('txtPartido').val().length === 0)) {
        $$('lblMensaje').text('Debe ingresar el código del partido');
        return false;
    }
    else if ((tipoBusqueda === 2) && ($$('cbTipoGarantiaReal').val() != '3') && ($$('txtNumFinca').val().length === 0)) {
        $$('lblMensaje').text('Debe ingresar el Id Garantía');
        return false;
    }
    else if ((tipoBusqueda === 2) && ($$('cbTipoGarantiaReal').val() == '3') && ($$('txtNumFinca').val().length === 0)) {
        $$('lblMensaje').text('Debe ingresar el Id Garantía');
        return false;
    }
    else if ((tipoBusqueda === 2) && ($$('cbTipoGarantiaReal').val() == '2') && ($$('txtGrado').val().length === 0)) {
        $$('lblMensaje').text('Debe ingresar el código de grado');
        return false;
    }
    else if ((tipoBusqueda === 3) && (($$('cbClaseGarantiaValor').val().length === 0) || ($$('cbClaseGarantiaValor').val() == '-1'))) {
        $$('lblMensaje').text('Debe seleccionar la clase de garantía');
        return false;
    }
    else if ((tipoBusqueda === 3) && ($$('txtNumeroSeguridad').val().length === 0)) {
        $$('lblMensaje').text('Debe ingresar el número de seguridad');
        return false;
    }

    return true;
}

//SE EJECUTA AL CARGAR LA PAGINA PARA SABER SI LA PAGINA HA SIDO LLAMADA DESDE OTRA
function CargarPaginaSTPR(cadenaJson) {

    LimpiarCamposBusqueda();

    $queryString = new Array();

    $$('filaRetorno').hide();

    if (typeof ($queryString) !== 'undefined') {
        if ($queryString.length == 0) {
            if ((typeof (cadenaJson) !== 'undefined') && (cadenaJson.length > 0)) {
                var params = eval('(' + cadenaJson + ')');
                for (var i = 0; i < params.length; i++) {
                    var object = params[i];
                    for (var property in object) {

                        var key = property;
                        var value = object[property];
                        $queryString[key] = value;
                    }
                }

                if (($queryString["tipogarantia"] != null) && ($queryString["tipogarantia"] == '1')) {

                    $$('cbTipoBusqueda').val("3");
                    $$('cbTipoBusqueda').trigger('change');

                    $$('cbTipoGarantia').val("1");
                    $$('cbTipoGarantia').trigger('change');


                    if (($queryString["tipofiador"] != null) && ($queryString["idfiador"] != null)) {
                        $$('cbTipoPersona').val($queryString["tipofiador"]);
                        $$('txtCedulaFiador').val($queryString["idfiador"]);
                        ValidarGarantia();
                    }

                    $$('filaRetorno').show();
                }
                else if (($queryString["tipogarantia"] != null) && ($queryString["tipogarantia"] == '2')) {

                    $$('cbTipoBusqueda').val("3");
                    $$('cbTipoBusqueda').trigger('change');

                    $$('cbTipoGarantia').val("2");
                    $$('cbTipoGarantia').trigger('change');

                    if (($queryString["tipogarantiareal"] != null) && ($queryString["clase"] != null) && ($queryString["partido"] != null) && ($queryString["idgarantia"] != null) && ($queryString["grado"] != null)) {

                        $$('cbTipoGarantiaReal').val($queryString["tipogarantiareal"]);
                        $$('cbTipoGarantiaReal').trigger('change');

                        $$('cbClaseGarantiaReal').val($queryString["clase"]);
                        $$('txtPartido').val($queryString["partido"]);
                        $$('txtNumFinca').val($queryString["idgarantia"]);

                        if ($queryString["tipogarantiareal"] == '2') {
                            $$('txtGrado').val($queryString["grado"]);
                        }

                        ValidarGarantia();
                    }

                    $$('filaRetorno').show();
                }
                else if (($queryString["tipogarantia"] != null) && ($queryString["tipogarantia"] == '3')) {

                    $$('cbTipoBusqueda').val("3");
                    $$('cbTipoBusqueda').trigger('change');

                    $$('cbTipoGarantia').val("3");
                    $$('cbTipoGarantia').trigger('change');

                    if (($queryString["clase"] != null) && ($queryString["numseguridad"] != null)) {
                        $$('cbClaseGarantiaValor').val($queryString["clase"]);
                        $$('txtNumeroSeguridad').val($queryString["numseguridad"]);
                        ValidarGarantia();
                    }

                    $$('filaRetorno').show();
                }
                else {
                    $$('filaRetorno').hide();
                }
            }
        }
    }
    else {
        $$('cbTipoBusqueda').val("1");
        $$('cbTipoBusqueda').trigger('change');
    }
}



/********************************************************************************************************************************************************************************************************************

METODOS UTILITARIOS

********************************************************************************************************************************************************************************************************************/

function formatFloat(num, casasDec, sepDecimal, sepMilhar) {
    if (num < 0) {
        num = -num;
        sinal = -1;
    } else
        sinal = 1;
    var resposta = "";
    var part = "";
    if (num != Math.floor(num)) // decimal values present
    {
        part = Math.round((num - Math.floor(num)) * Math.pow(10, casasDec)).toString(); // transforms decimal part into integer (rounded)
        while (part.length < casasDec)
            part = '0' + part;
        if (casasDec > 0) {
            resposta = sepDecimal + part;
            num = Math.floor(num);
        } else
            num = Math.round(num);
    } // end of decimal part
    while (num > 0) // integer part
    {
        part = (num - Math.floor(num / 1000) * 1000).toString(); // part = three less significant digits
        num = Math.floor(num / 1000);
        if (num > 0)
            while (part.length < 3) // 123.023.123  if sepMilhar = '.'
                part = '0' + part; // 023
        resposta = part + resposta;
        if (num > 0)
            resposta = sepMilhar + resposta;
    }
    if (sinal < 0)
        resposta = '-' + resposta;
    return resposta;
}

function htmlDecode(value) {
    return $('<div/>').html(value).text();
}

function InicializarClaseTablasGarantias(celda) {

    $("#tablaGarantiasFiduciarias table tr").each(function () {
        $(this).children("td").each(function () {
            $(this).attr('class', 'celdaNormal');
        })
    });

    $("#tablaGarantiasReales table tr").each(function () {
        $(this).children("td").each(function () {
            $(this).attr('class', 'celdaNormal');

        })
    });

    $("#tablaGarantiasValor table tr").each(function () {
        $(this).children("td").each(function () {
            $(this).attr('class', 'celdaNormal');
        })
    });

    if (celda.parent().is("td")) {
        celda.parent().attr('class', 'celdaSeleccionada');
    }
}

function DesplegarAjustes(consecutivoOperacion, consecutivoGarantia) {

    var indiceSeleciconado = 0;

    if ($arregloOperaciones.length > 0) {

        $$('filaDetalleAjuste').show();
        $PermisoEdicion = $$('hdnPermisoEdicion').val();
        $$('lblMensaje').text('');

        for (var i = 0; i < $arregloOperaciones.length; i++) {

             indiceSeleciconado = i;

            if (($arregloOperaciones[i].NumeroRegistro === 1) && ($arregloOperaciones[i].ConsecutivoOperacion == consecutivoOperacion) && ($arregloOperaciones[i].ConsecutivoGarantia == consecutivoGarantia)) {

                var saldoActualMostrar = (($arregloOperaciones[i].SaldoActualAjustado > 0) ? $arregloOperaciones[i].SaldoActualAjustado : (($arregloOperaciones[i].SaldoActual > 0) ? $arregloOperaciones[i].SaldoActual : '0.00'));
                var porcentajeMostrar = (($arregloOperaciones[i].PorcentajeResponsabilidadAjustado >= 0) ? $arregloOperaciones[i].PorcentajeResponsabilidadAjustado : '0.00');

                $RegistroExcluido = $arregloOperaciones[i].IndicadorExcluido;

                $registroSeleccionado = new RegistroSeleccionado(consecutivoOperacion, consecutivoGarantia, $arregloOperaciones[i].CodigoTipoGarantia, saldoActualMostrar, $arregloOperaciones[i].SaldoActual, porcentajeMostrar, indiceSeleciconado, saldoActualMostrar);

                $$('lblNumeroOperacion').text($arregloOperaciones[i].OperacionLarga);
                $$('txtSaldoAjustado').val(saldoActualMostrar);
                $$('txtPorcentajeResponsabilidad').val(porcentajeMostrar);

                $$('txtSaldoAjustado').trigger('change');
                $$('txtPorcentajeResponsabilidad').trigger('change');

                if ($arregloOperaciones[i].IndicadorExcluido) {
                    $$('btnInsertar').show();
                    $$('btnModificar').hide();
                    $$('btnEliminar').hide();
                }
                else {
                    $$('btnModificar').show();
                    $$('btnEliminar').show();
                    $$('btnInsertar').hide();
                }
            }
        };

        if ($arregloOperaciones.length > 1) {
            $$('Siguiente').removeAttr('disabled');
            $$('Anterior').removeAttr('disabled');
        }
        else {
            $$('Siguiente').attr('disabled', 'disabled');
            $$('Anterior').attr('disabled', 'disabled');
        }
    }

    if ($PermisoEdicion === '0') {
        $$('txtSaldoAjustado').attr('disabled', 'disabled');
        $$('txtPorcentajeResponsabilidad').attr('disabled', 'disabled');
        $$('btnInsertar').hide();
        $$('btnModificar').hide();
        $$('btnEliminar').hide();
        $$('btnLimpiar').hide();
    }
    else {
        $$('txtSaldoAjustado').removeAttr('disabled');
        $$('txtPorcentajeResponsabilidad').removeAttr('disabled');

        if ($RegistroExcluido) {
            $$('btnInsertar').show();
            $$('btnModificar').hide();
            $$('btnEliminar').hide();
        }
        else {
            $$('btnModificar').show();
            $$('btnEliminar').show();
            $$('btnInsertar').hide();
        }
    }
}

function LimpiarCampos() {
    $$('txtSaldoAjustado').val("0.00");
    $$('txtPorcentajeResponsabilidad').val("0.00");
    $$('lblMensaje').text('');

    if ($RegistroExcluido) {
        $$('btnInsertar').show();
        $$('btnModificar').hide();
        $$('btnEliminar').hide();
    }
    else {
        $$('btnModificar').show();
        $$('btnEliminar').show();
        $$('btnInsertar').hide();
    }
}

function ObtenerRegistroValido(indiceInicial, esSiguiente) {

    var indiceRetorno = -1;

    if (($arregloOperaciones != null) && ($arregloOperaciones.length > 0)) {

        if(esSiguiente) {
            for (var i = (indiceInicial + 1); i < $arregloOperaciones.length; i++) {
                if ($arregloOperaciones[i].NumeroRegistro === 1) {
                    indiceRetorno = i;
                    break;
                }
            }
        }
        else {
            for (var i = (indiceInicial - 1) ; i >= 0; i--) {
                if ($arregloOperaciones[i].NumeroRegistro === 1) {
                    indiceRetorno = i;
                    break;
                }
            }
        }
        
    }

    return indiceRetorno;
}

function RegistroSiguiente() {

    $$('lblMensaje').text('');

    if (($arregloOperaciones.length > 0) && ($registroSeleccionado != null)) {

        var indiceSiguiente = ObtenerRegistroValido($registroSeleccionado.IndiceRegistro, true);
        var tamanoArreglo = $arregloOperaciones.length - 1;
        
        if (indiceSiguiente >= 0) {

            if ($CambioManual) {
                ActualizaValoresAjustados();
                ActualizarGrid();
            }

            if ((indiceSiguiente == tamanoArreglo) && ($arregloOperaciones[indiceSiguiente].NumeroRegistro === 1)) {
                DesplegarAjustes($arregloOperaciones[indiceSiguiente].ConsecutivoOperacion, $arregloOperaciones[indiceSiguiente].ConsecutivoGarantia);
                $$('Siguiente').attr('disabled', 'disabled');
            }
            else if ((indiceSiguiente < tamanoArreglo) && ($arregloOperaciones[indiceSiguiente].NumeroRegistro === 1)) {
                DesplegarAjustes($arregloOperaciones[indiceSiguiente].ConsecutivoOperacion, $arregloOperaciones[indiceSiguiente].ConsecutivoGarantia);
                $$('Siguiente').removeAttr('disabled');
            }
            else if (indiceSiguiente > tamanoArreglo) {
                $$('Siguiente').attr('disabled', 'disabled');
            }
        }
        else {
            $$('Siguiente').attr('disabled', 'disabled');
        }
    }
}

function RegistroAnterior() {

    $$('lblMensaje').text('');

    if (($arregloOperaciones.length > 0) && ($registroSeleccionado != null)) {

        var indiceAnterior = ObtenerRegistroValido($registroSeleccionado.IndiceRegistro, false);

        if (indiceAnterior >= 0) {
            
            if ($CambioManual) {
                ActualizaValoresAjustados();
                ActualizarGrid();
            }

            if ((indiceAnterior >= 0) && ($arregloOperaciones[indiceAnterior].NumeroRegistro === 1)) {
                DesplegarAjustes($arregloOperaciones[indiceAnterior].ConsecutivoOperacion, $arregloOperaciones[indiceAnterior].ConsecutivoGarantia);
                $$('Anterior').removeAttr('disabled');

                if (indiceAnterior === 0) {
                    DesplegarAjustes($arregloOperaciones[indiceAnterior].ConsecutivoOperacion, $arregloOperaciones[indiceAnterior].ConsecutivoGarantia);
                    $$('Anterior').attr('disabled', 'disabled');
                }
            }
            else if (indiceAnterior < 0) {
                $$('Anterior').attr('disabled', 'disabled');
            }
        }
        else {
            $$('Anterior').attr('disabled', 'disabled');
        }
    }
    else {
        $$('Anterior').attr('disabled', 'disabled');
    }
}

function ConvertirArregloOperacionesJson() {

    if ($arregloOperaciones.length > 0) {

        var ResultArray = '{';
        var tamannoArreglo = $arregloOperaciones.length;

        for (i = 0; i < tamannoArreglo; i++) {
            ResultArray += '"Consecutivo_Operacion":"' + $arregloOperaciones[i].ConsecutivoOperacion + '",';
            ResultArray += '"Consecutivo_Garantia":"' + $arregloOperaciones[i].ConsecutivoGarantia + '",';
            ResultArray += '"Codigo_Tipo_Garantia":"' + $arregloOperaciones[i].CodigoTipoGarantia + '",';
            ResultArray += '"Codigo_Tipo_Operacion":"' + $arregloOperaciones[i].CodigoTipoOperacion + '",';
            ResultArray += '"Cuenta_Contable":"' + $arregloOperaciones[i].CuentaContable + '",';
            ResultArray += '"Saldo_Actual":"' + $arregloOperaciones[i].SaldoActual + '",';
            ResultArray += '"Saldo_Actual_Ajustado":"' + $arregloOperaciones[i].SaldoActualAjustado + '",';
            ResultArray += '"Porcentaje_Responsabilidad_Ajustado":"' + $arregloOperaciones[i].PorcentajeResponsabilidadAjustado + '",';
            ResultArray += '"Tipo_Operacion":"' + $arregloOperaciones[i].TipoOperacion + '",';
            ResultArray += '"Operacion_Larga":"' + $arregloOperaciones[i].OperacionLarga + '",';
            ResultArray += '"Indicador_Ajuste_Saldo_Actual":"' + (($arregloOperaciones[i].IndicadorAjusteSaldoActual) ? '1' : '0') + '",';
            ResultArray += '"Indicador_Ajuste_Porcentaje":"' + (($arregloOperaciones[i].IndicadorAjustePorcentaje) ? '1' : '0') + '",';
            ResultArray += '"Indicador_Excluido":"' + (($arregloOperaciones[i].IndicadorExcluido) ? '1' : '0') + '",';
            ResultArray += '"IndicadorCuentaContableEspecial":"' + (($arregloOperaciones[i].IndicadorCuentaContableEspecial) ? '1' : '0') + '",';
            ResultArray += '"IdentificacionGarantia":"' + $arregloOperaciones[i].IdentificacionGarantia + '",';
            ResultArray += '"Indicador_Ajuste_Campo_Saldo":"' + (($arregloOperaciones[i].IndicadorAjusteCampoSaldo) ? '1' : '0') + '",';
            ResultArray += '"Indicador_Ajuste_Campo_Porcentaje":"' + (($arregloOperaciones[i].IndicadorAjusteCampoPorcentaje) ? '1' : '0') + '",';
            ResultArray += '"Porcentaje_Responsabilidad_Calculado":"' + $arregloOperaciones[i].PorcentajeResponsabilidadCalculado + '",';
            ResultArray += '"Numero_Registro":"' + $arregloOperaciones[i].NumeroRegistro + '"';
            ResultArray += '"}';

            if (i != tamannoArreglo - 1) {
                ResultArray += ',';
            }
        }

        return ResultArray; // += ']';
    }
}

function AsignarPorcentajeMinimo() {

    if (($arregloOperaciones.length > 0) && ($registroSeleccionado != null)) {

        for (var i = 0; i < $arregloOperaciones.length; i++) {

            if (($arregloOperaciones[i].ConsecutivoOperacion != $registroSeleccionado.ConsecutivoOperacion)
                && ($arregloOperaciones[i].ConsecutivoGarantia != $registroSeleccionado.ConsecutivoGarantia)
                && ($arregloOperaciones[i].CodigoTipoGarantia != $registroSeleccionado.CodigoTipoGarantia)) {
                $arregloOperaciones[i].PorcentajeResponsabilidadAjustado = 0;
                $arregloOperaciones[i].PorcentajeResponsabilidadCalculado = 0;
            }

            ActualizarGrid();
        }
    }
}

function ActualizarGrid() {
    if ($arregloOperaciones.length > 0) {
        var checkBoxSeleccionado = "<input type=\"checkbox\" checked=\"checked\" disabled=\"disabled\"/>";
        var checkBoxNoSeleccionado = "<input type=\"checkbox\"disabled=\"disabled\"/>";

        var row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
        $("[id*=gdvOperaciones] tr").not($("[id*=gdvOperaciones] tr:first-child")).remove();

        for (var i = 0; i < $arregloOperaciones.length; i++) {

            if ($arregloOperaciones[i].NumeroRegistro === 1) {

                $("td", row).eq(0).html("<a style=\"color: #333333\" href=\"javascript:DesplegarAjustes('" + $arregloOperaciones[i].ConsecutivoOperacion + "', '" + $arregloOperaciones[i].ConsecutivoGarantia + "');\" onclick=\"javascript:DesplegarAjustes('" + $arregloOperaciones[i].ConsecutivoOperacion + "', '" + $arregloOperaciones[i].ConsecutivoGarantia + "');\">" + $arregloOperaciones[i].OperacionLarga + "</a>");
                $("td", row).eq(1).html($arregloOperaciones[i].SaldoActualTexto);
                $("td", row).eq(2).html($arregloOperaciones[i].PorcentajeResponsabilidadTexto);
                $("td", row).eq(3).html((($arregloOperaciones[i].CodigoTipoOperacion !== 2) ? $arregloOperaciones[i].CuentaContable : "-"));
                $("td", row).eq(4).html($arregloOperaciones[i].TipoOperacion);
                $("td", row).eq(5).html((($arregloOperaciones[i].IndicadorExcluido) ? checkBoxSeleccionado : checkBoxNoSeleccionado));
                $("td", row).eq(6).html($arregloOperaciones[i].ConsecutivoOperacion);
                $("td", row).eq(7).html($arregloOperaciones[i].ConsecutivoGarantia);
                $("td", row).eq(8).html($arregloOperaciones[i].CodigoTipoGarantia);
                $("td", row).eq(9).html($arregloOperaciones[i].IndicadorExcluido);
                $("[id*=gdvOperaciones]").append(row);

                row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
            }
        };

        $$('gdvOperaciones').show();
    }
}

function ConfirmarInsertar() {
    var acepta = confirm('Está seguro que desea incluir el registro seleccionado?');
    if (acepta == true) {
        ValidarDatosAjustados(1);
        return true;
    }
    else {
        return false;
    }
}

function ConfirmarModificar() {
    var acepta = confirm('Está seguro que desea modificar el registro seleccionado?');

    if (acepta == true) {
        ValidarDatosAjustados(2);
        return true;
    }
    else {
        return false;
    }
}

function ConfirmarEliminar() {
    var acepta = confirm('Está seguro que desea eliminar el registro seleccionado?');
    if (acepta == true) {
        $cuentaMensajes = 1;
        AsignarCambioManual(false);
        ManipularRegistro(3);
        return true;
    }
    else {
        return false;
    }
}

function ManipularRegistro(accionRealizar) {

    $$('lblMensaje').text('');
    var mensajeExitoso = '';

    --$cuentaMensajes;

    if ((accionRealizar != 3) && ($CambioManual)) {
        ValidarSumatoriPorcentajes();
    }
    else {
        $SumatoriaValida = true;
    }

    AsignarSumatoriaValida((($CambioManual) ? $SumatoriaValida : true));

    if (!$SumatoriaValida) {
        var $MensajeSumatoriaPorcentajeInvalida = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>La sumatoria de los porcentajes de responsabilidad de todos los registros enlistados supera el 100%. Favor verificar.</p></div></div>')
                .dialog({
                    autoOpen: false,
                    title: 'Sumatoria Porcentaje Responsabilidad Inválida',
                    resizable: false,
                    draggable: false,
                    height: 235,
                    width: 650,
                    closeOnEscape: false,
                    open: function (event, ui) { $(".ui-dialog-titlebar-close").hide(); $(this).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" }); ++$cuentaMensajes; },
                    modal: true,
                    buttons: {
                        "Aceptar": function () {
                            $(this).dialog("close");
                        }
                    }
                });

        $MensajeSumatoriaPorcentajeInvalida.dialog("open");
    }
    else if (($SumatoriaValida) && ($cuentaMensajes === 0)) {
        var pageUrl = 'frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx';
        var metodoEjecutar = '';
        var saldoActualRegistrado = $$('txtSaldoAjustado').val();
        var porcentajeRespRegistrado = $$('txtPorcentajeResponsabilidad').val();
        var descripcionAccion = '';
        var datoListaOperaciones = (($arregloOperaciones.length > 0) ? ConvertirArregloOperacionesJson() : '');
        var ajusteManual = (((typeof ($CambioManual) !== 'undefined') && ($CambioManual)) ? '1' : '0');
        var datosEnviar = '';

        if ($registroSeleccionado != null) {

            switch (accionRealizar) {
                case 1:
                    descripcionAccion = 'Insertando';
                    metodoEjecutar = pageUrl + "/InsertarRegistro";
                    mensajeExitoso = 'La información se incluyó satisfactoriamente.';
                    datosEnviar = "{'consecutivoOperacion':'" + $registroSeleccionado.ConsecutivoOperacion + "', 'consecutivoGarantia':'" + $registroSeleccionado.ConsecutivoGarantia + "', 'tipoGarantia':'" + $registroSeleccionado.CodigoTipoGarantia + "', 'saldoActualAjustado':'" + saldoActualRegistrado + "', 'porcentajeRespAjustado':'" + porcentajeRespRegistrado + "', 'arregloElementos':'" + datoListaOperaciones + "', 'cambioManual':'" + ajusteManual + "'}";
                    break;
                case 2:
                    descripcionAccion = 'Modificando';
                    metodoEjecutar = pageUrl + "/ModificarRegistro";
                    mensajeExitoso = 'La información se modificó satisfactoriamente.';

                    if ($CambioManual) {
                        metodoEjecutar = pageUrl + "/ModificarRegistroManual";

                        datosEnviar = "{'arregloElementos':'" + datoListaOperaciones + "'}";
                    }
                    else {
                        ajusteManual = '0';
                        datosEnviar = "{'consecutivoOperacion':'" + $registroSeleccionado.ConsecutivoOperacion + "', 'consecutivoGarantia':'" + $registroSeleccionado.ConsecutivoGarantia + "', 'tipoGarantia':'" + $registroSeleccionado.CodigoTipoGarantia + "', 'saldoActualAjustado':'" + saldoActualRegistrado + "', 'porcentajeRespAjustado':'" + porcentajeRespRegistrado + "', 'arregloElementos':'" + datoListaOperaciones + "', 'cambioManual':'" + ajusteManual + "'}";
                    }

                    break;
                case 3:
                    descripcionAccion = 'Eliminando';
                    metodoEjecutar = pageUrl + "/EliminarRegistro";
                    mensajeExitoso = 'La información se eliminó satisfactoriamente.';
                    datosEnviar = "{'consecutivoOperacion':'" + $registroSeleccionado.ConsecutivoOperacion + "', 'consecutivoGarantia':'" + $registroSeleccionado.ConsecutivoGarantia + "', 'tipoGarantia':'" + $registroSeleccionado.CodigoTipoGarantia + "', 'saldoActualAjustado':'" + saldoActualRegistrado + "', 'porcentajeRespAjustado':'" + porcentajeRespRegistrado + "', 'arregloElementos':'" + datoListaOperaciones + "', 'cambioManual':'" + ajusteManual + "'}";
                    break;
                default:
                    break;
            }

            



            $.blockUI({
                message: null,
                onBlock: function () {
                    $.ajax({
                        type: "POST",
                        async: false,
                        url: metodoEjecutar,
                        data: datosEnviar,
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {

                            $CambioManual = false;

                            if (response.length > 0) {

                                if (response[0].CodigoError === 0) {

                                    $arregloOperaciones = response;
                                    var checkBoxSeleccionado = "<input type=\"checkbox\" checked=\"checked\" disabled=\"disabled\"/>";
                                    var checkBoxNoSeleccionado = "<input type=\"checkbox\"disabled=\"disabled\"/>";

                                    var row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
                                    $("[id*=gdvOperaciones] tr").not($("[id*=gdvOperaciones] tr:first-child")).remove();

                                    for (var i = 0; i < response.length; i++) {

                                        if (response[i].NumeroRegistro === 1) {

                                            $("td", row).eq(0).html("<a style=\"color: #333333\" href=\"javascript:DesplegarAjustes('" + response[i].ConsecutivoOperacion + "', '" + response[i].ConsecutivoGarantia + "');\" onclick=\"javascript:DesplegarAjustes('" + response[i].ConsecutivoOperacion + "', '" + response[i].ConsecutivoGarantia + "');\">" + response[i].OperacionLarga + "</a>");
                                            $("td", row).eq(1).html(response[i].SaldoActualTexto);
                                            $("td", row).eq(2).html(response[i].PorcentajeResponsabilidadTexto);
                                            $("td", row).eq(3).html(((response[i].CodigoTipoOperacion !== 2) ? response[i].CuentaContable : "-"));
                                            $("td", row).eq(4).html(response[i].TipoOperacion);
                                            $("td", row).eq(5).html(((response[i].IndicadorExcluido) ? checkBoxSeleccionado : checkBoxNoSeleccionado));
                                            $("td", row).eq(6).html(response[i].ConsecutivoOperacion);
                                            $("td", row).eq(7).html(response[i].ConsecutivoGarantia);
                                            $("td", row).eq(8).html(response[i].CodigoTipoGarantia);
                                            $("td", row).eq(9).html(response[i].IndicadorExcluido);
                                            $("[id*=gdvOperaciones]").append(row);

                                            row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
                                        }
                                    };
                                    DesplegarAjustes($registroSeleccionado.ConsecutivoOperacion, $registroSeleccionado.ConsecutivoGarantia);
                                    $$('lblMensaje').text(mensajeExitoso);
                                }
                                else {
                                    $$('lblMensaje').text(response[0].DescripcionError);
                                }
                            }
                        },
                        failure: function (response) {
                            $$('lblMensaje').text(response);
                        }
                    });
                }
            });
        }
    }
}

function ValidarPorcentajeResponsabilidad() {

    var datoPorcentajeResp = (($$('txtPorcentajeResponsabilidad').val().length > 0) ? $$('txtPorcentajeResponsabilidad').val() : '0');
    var porcentajeResponsabilidad = parseFloat(datoPorcentajeResp);

    if (porcentajeResponsabilidad == 100) {
        $MensajePorcentajeMaximo.dialog('open');
    }
}

function ActualizaValoresAjustados()
{
    if ($registroSeleccionado != null) {

        var datoSaldoIngresado = (($$('txtSaldoAjustado').val().length > 0) ? $$('txtSaldoAjustado').val() : '0').replace(/[^0-9-.]/g, '');
        var saldoAjustado = parseFloat(datoSaldoIngresado);
               
        var datoPorcentajeResp = (($$('txtPorcentajeResponsabilidad').val().length > 0) ? $$('txtPorcentajeResponsabilidad').val() : '0');
        var porcentajeResponsabilidad = parseFloat(datoPorcentajeResp);

        $registroSeleccionado.SaldoActualAjustado = saldoAjustado;
        $registroSeleccionado.PorcentajeResponsabilidadAjustado = datoPorcentajeResp;

        if ($arregloOperaciones.length > 0) {

            for (var i = 0; i < $arregloOperaciones.length; i++) {

                if (($registroSeleccionado.ConsecutivoOperacion == $arregloOperaciones[i].ConsecutivoOperacion) &&
                    ($registroSeleccionado.ConsecutivoGarantia == $arregloOperaciones[i].ConsecutivoGarantia) &&
                    ($registroSeleccionado.CodigoTipoGarantia == $arregloOperaciones[i].CodigoTipoGarantia)) {

                    $arregloOperaciones[i].IndicadorAjusteCampoSaldo = (($arregloOperaciones[i].SaldoActualAjustado != $registroSeleccionado.SaldoActualAjustado) ? true : false);
                    $arregloOperaciones[i].IndicadorAjusteCampoPorcentaje = (($arregloOperaciones[i].PorcentajeResponsabilidadAjustado != $registroSeleccionado.PorcentajeResponsabilidadAjustado) ? true : false);

                    $arregloOperaciones[i].SaldoActualAjustado = $registroSeleccionado.SaldoActualAjustado;
                    $arregloOperaciones[i].PorcentajeResponsabilidadAjustado = $registroSeleccionado.PorcentajeResponsabilidadAjustado;
                    //$arregloOperaciones[i].PorcentajeResponsabilidadCalculado = $registroSeleccionado.PorcentajeResponsabilidadAjustado;
                    $arregloOperaciones[i].SaldoActualTexto = accounting.formatMoney($registroSeleccionado.SaldoActualAjustado, { symbol: "", thousand: ",", decimal: "." });
                    $arregloOperaciones[i].PorcentajeResponsabilidadTexto = accounting.formatMoney($registroSeleccionado.PorcentajeResponsabilidadAjustado, { symbol: "", thousand: ",", decimal: "." });;
                }
            }
        }
    }
}

function ValidarSumatoriPorcentajes() {
    if ($arregloOperaciones.length > 0) {

        var sumatoriaPorcentaje = 0;

        for (var i = 0; i < $arregloOperaciones.length; i++) {

            if ($arregloOperaciones[i].NumeroRegistro === 1) {

                sumatoriaPorcentaje += parseFloat((($arregloOperaciones[i].PorcentajeResponsabilidadAjustado > 0) ? $arregloOperaciones[i].PorcentajeResponsabilidadAjustado : $arregloOperaciones[i].PorcentajeResponsabilidadCalculado));
            }
        }

        sumatoriaPorcentaje = accounting.toFixed(sumatoriaPorcentaje, 2);
        
        if (sumatoriaPorcentaje > 100) {
            AsignarSumatoriaValida(false);
        }
        else {
            AsignarSumatoriaValida(true);
        }
    }
}

function ValidarDatosAjustados(accion) {

    AsignarCambioManual(false);
    AsignarSumatoriaValida(true);
    
    if ($registroSeleccionado != null) {

        this.SaldoActualAjustado = saldoAjustado;
        this.SaldoActual

        var datoSaldoIngresado = (($$('txtSaldoAjustado').val().length > 0) ? $$('txtSaldoAjustado').val() : '0').replace(/[^0-9-.]/g, '');
        var saldoAjustado = parseFloat(datoSaldoIngresado);

        var saldoMostrado = parseFloat($registroSeleccionado.SaldoMostrado);
        var diferenciaSaldo = (parseFloat(((saldoAjustado > saldoMostrado) ? (saldoAjustado - saldoMostrado) : (saldoMostrado - saldoAjustado))).toFixed(2)).toString('N2');

        var datoPorcentajeResp = (($$('txtPorcentajeResponsabilidad').val().length > 0) ? $$('txtPorcentajeResponsabilidad').val() : '0');
        var porcentajeResponsabilidad = parseFloat(datoPorcentajeResp);

        var porcentajeOriginal = parseFloat($registroSeleccionado.PorcentajeResponsabilidadAjustado);
        var diferenciaPorcentaje = parseFloat(100 - porcentajeResponsabilidad);
        $cuentaMensajes = 0;
        $porcentajeCien = false;
        
        if ($CambioManual) {
            ActualizaValoresAjustados();
        }

        if ($arregloOperaciones.length > 0) {

            var sumatoriaPorcentaje = 0;

            for (var i = 0; i < $arregloOperaciones.length; i++) {

                if ($arregloOperaciones[i].NumeroRegistro === 1) {

                    if (($registroSeleccionado.ConsecutivoOperacion == $arregloOperaciones[i].ConsecutivoOperacion) &&
                        ($registroSeleccionado.ConsecutivoGarantia == $arregloOperaciones[i].ConsecutivoGarantia) &&
                        ($registroSeleccionado.CodigoTipoGarantia == $arregloOperaciones[i].CodigoTipoGarantia)) {
                        sumatoriaPorcentaje += porcentajeResponsabilidad;
                    }
                    else {
                        sumatoriaPorcentaje += parseFloat((($arregloOperaciones[i].PorcentajeResponsabilidadAjustado > 0) ? $arregloOperaciones[i].PorcentajeResponsabilidadAjustado : $arregloOperaciones[i].PorcentajeResponsabilidadCalculado));
                    }
                }
            }

            if (sumatoriaPorcentaje > 100) {
                AsignarSumatoriaValida(false);

                //var $MensajeSumatoriaPorcentajeInvalida = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>La sumatoria de los porcentajes de responsabilidad de todos los registros enlistados supera el 100%. Favor verificar.</p></div></div>')
                //.dialog({
                //    autoOpen: false,
                //    title: 'Sumatoria Porcentaje Responsabilidad Inválida',
                //    resizable: false,
                //    draggable: false,
                //    height: 235,
                //    width: 650,
                //    closeOnEscape: false,
                //    open: function (event, ui) { $(".ui-dialog-titlebar-close").hide(); $(this).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" }); ++$cuentaMensajes; },
                //    modal: true,
                //    buttons: {
                //        "Aceptar": function () {
                //            $(this).dialog("close");
                //        }
                //    },
                //    close: function () { ManipularRegistro(accion); }
                //});

                //$MensajeSumatoriaPorcentajeInvalida.dialog("open");
            }
        }

        if (saldoAjustado > $registroSeleccionado.SaldoActual) {

            var $MensajeSaldoMayor = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor ajustado a aumentado en ' + formatFloat(diferenciaSaldo, 2, '.', ',') + ', está seguro que desea modificar el valor, esto afectará la distribución de mitigadores.</p></div></div>')
                    .dialog({
                        autoOpen: false,
                        title: 'Saldo Ajustado Mayor',
                        resizable: false,
                        draggable: false,
                        height: 235,
                        width: 650,
                        closeOnEscape: false,
                        open: function (event, ui) { $(".ui-dialog-titlebar-close").hide(); $(this).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" }); ++$cuentaMensajes; },
                        modal: true,
                        buttons: {
                            "Aceptar": function () {
                                $(this).dialog("close");
                            }
                        },
                        close: function () { ManipularRegistro(accion); }
                    });

            $MensajeSaldoMayor.dialog("open");
        }
        else if (saldoAjustado < $registroSeleccionado.SaldoActual) {
            var $MensajeSaldoMenor = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>El valor ajustado disminuyó en ' + formatFloat(diferenciaSaldo, 2, '.', ',') + ', está seguro que desea modificar el valor, esto afectará la distribución de mitigadores.</p></div></div>')
                   .dialog({
                       autoOpen: false,
                       title: 'Saldo Ajustado Menor',
                       resizable: false,
                       draggable: false,
                       height: 235,
                       width: 650,
                       closeOnEscape: false,
                       open: function (event, ui) { $(".ui-dialog-titlebar-close").hide(); $(this).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" }); ++$cuentaMensajes; },
                       modal: true,
                       buttons: {
                           "Aceptar": function () {
                               $(this).dialog("close");
                           }
                       },
                       close: function () { ManipularRegistro(accion); }
                   });

            $MensajeSaldoMenor.dialog("open");
        }
        

        if (porcentajeResponsabilidad == 100) {
            $porcentajeCien = true;
            ++$cuentaMensajes;
            ManipularRegistro(accion);
        }
        else if (porcentajeResponsabilidad < porcentajeOriginal) {
            ++$cuentaMensajes;
            ManipularRegistro(accion);
        }
        else if (porcentajeResponsabilidad > porcentajeOriginal) {

            var $MensajeSaldoMayor = $('<div class="ui-widget" style="padding-top:2.2em;"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"><p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-bottom: 1.8em;"></span>Usted ha modificado el % de responsabilidad de una operación, si desea que el sistema respete este porcentaje y haga una nueva distribución con el porcentaje faltante de  ' + formatFloat(diferenciaPorcentaje, 2, '.', ',') + ' presione “Aceptar”, si no presione “Cambio Manual” para realizarlo usted.</p></div></div>')
                    .dialog({
                        autoOpen: false,
                        title: 'Porcentaje Responsabilidad Ajustado Mayor',
                        resizable: false,
                        draggable: false,
                        height: 235,
                        width: 650,
                        closeOnEscape: false,
                        open: function (event, ui) { $(".ui-dialog-titlebar-close").hide(); $(this).dialog('widget').position({ my: "center bottom", at: "center bottom", of: window, collision: "none" }); ++$cuentaMensajes; },
                        modal: true,
                        buttons: {
                            "Aceptar": function () {
                                $(this).dialog("close");
                                AsignarCambioManual(false);
                                ManipularRegistro(accion);
                            },
                            "Cambio Manual": function () {
                                $(this).dialog("close");
                                AsignarCambioManual(true);
                                //ManipularRegistro(accion);
                            }
                        }/*,
                        close: function () { ManipularRegistro(accion); }*/
                    });

            $MensajeSaldoMayor.dialog("open");
        }
        else {
            ++$cuentaMensajes;
            ManipularRegistro(accion);
        }
    }
}

function AsignarCambioManual(valor) {
    $CambioManual = (((typeof ($CambioManual) !== 'undefined') && ($CambioManual)) ? $CambioManual : valor);
}

function AsignarSumatoriaValida(valor) {
    $SumatoriaValida = valor;
}


/********************************************************************************************************************************************************************************************************************

METODOS ASINCRONICOS

********************************************************************************************************************************************************************************************************************/

//METODO ASINCRONICO QUE PERMITE VALIDAR SI EL USUARIO POSEE PERMISOS DE EDICION
function ValidarPermisoEdicion() {

    var pageUrl = 'frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx';

    var listaPermisos = (($$('hdnPerfilesPermitidos').val() != null) ? $$('hdnPerfilesPermitidos').val() : "");

    $$('lblMensaje').text('');
 
    $.ajax({
        type: "POST",
        async: false,
        url: pageUrl + "/ValidarPermisoEdicionUsuario",
        data: "{'perfilesPermitodos':'" + listaPermisos + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            $$('lblMensaje').text('');

            if ((response != null) && (response.length > 1)) {
                $PermisoEdicion = response;
            }
            else {
                $PermisoEdicion = '0';
            }

            $$('hdnPermisoEdicion').val(response);
        },
        failure: function (response) {
            $$('lblMensaje').text(response);
        }
    });

}

//METODO ASINCRONICO QUE PERMITE CARGAR LA LISTA DE CADA CATALOGO REQUERIDO
function CargarListaCatalogo(codigoCatalogo, objetoCargar, tipoGarantia, tipoGarantiaReal) {

    var pageUrl = 'frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx';

    $$('lblMensaje').text('');

     $.ajax({
        type: "POST",
        async: false,
        url: pageUrl + "/ExtraerCatalogo",
        data: "{'codigoCatologo':'" + codigoCatalogo + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            $$('lblMensaje').text('');

            if ((response != null) && (response.length > 1)) {
                var listaCargar = "";
                var codigoTipoGarantia = parseInt(tipoGarantia);
                var codigoTipoGarantiaReal = parseInt(tipoGarantiaReal);

                if (codigoTipoGarantia === -1) {
                    $($.parseJSON(response)).map(function () {
                        listaCargar += "<option value='" + this.cat_elemento + "'>" + this.cat_descripcion + "</option>";
                    });
                }
                else if (codigoTipoGarantia === 1) {
                    $($.parseJSON(response)).map(function () {
                        listaCargar += "<option value='" + this.cat_elemento + "'>" + this.cat_descripcion + "</option>";
                    });
                }
                else if (codigoTipoGarantia === 2) {
                    switch (codigoTipoGarantiaReal) {
                        case 1:
                            $($.parseJSON(response)).map(function () {
                                var codigoElemento = parseInt(this.cat_elemento);
                                if ((codigoElemento >= 10) && (codigoElemento <= 17)) {
                                    listaCargar += "<option value='" + this.cat_elemento + "'>" + this.cat_descripcion + "</option>";
                                }
                            });
                            break;
                        case 2:
                            $($.parseJSON(response)).map(function () {
                                var codigoElemento = parseInt(this.cat_elemento);
                                if ((codigoElemento == 18) || ((codigoElemento >= 20) && (codigoElemento <= 29))) {
                                    listaCargar += "<option value='" + this.cat_elemento + "'>" + this.cat_descripcion + "</option>";
                                }
                            });
                            break;
                        case 3:
                            $($.parseJSON(response)).map(function () {
                                var codigoElemento = parseInt(this.cat_elemento);
                                if ((codigoElemento >= 30) && (codigoElemento <= 69)) {
                                    listaCargar += "<option value='" + this.cat_elemento + "'>" + this.cat_descripcion + "</option>";
                                }
                            });
                            break;
                        default:
                            break;
                    }
                }
                else if (codigoTipoGarantia === 3) {
                    $($.parseJSON(response)).map(function () {
                        var codigoElemento = parseInt(this.cat_elemento);
                        if ((codigoElemento >= 20) && (codigoElemento <= 29)) {
                            listaCargar += "<option value='" + this.cat_elemento + "'>" + this.cat_descripcion + "</option>";
                        }
                    });
                }

                objetoCargar.html(listaCargar);
            }
            else {
                $$('lblMensaje').text(response);
            }
        },
        failure: function (response) {
            $$('lblMensaje').text(response);
        }
    });
}

//METODO ASINCRONICO QUE PERMITE VALIDAR LA OPERACION O CONTRATO
function ValidarOperacion() {

    $$('lblMensaje').text('');

    if (ValidarCamposOpercion()) {

        var pageUrl = 'frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx';

        var tipoOperacion = parseInt((($$('cbTipoBusqueda').val() != null) ? $$('cbTipoBusqueda').val() : "-1"));
        var codigoContabilidad = ($$('txtContabilidad').val());
        var codigoOficina = ($$('txtOficina').val());
        var codigoMoneda = ($$('txtMoneda').val());
        var codigoProducto = ((tipoOperacion === 1) ? $$('txtProducto').val() : "-1");
        var codigoOperacion = ($$('txtOperacion').val());
        var consecutivoOperacion = '';
        var operacionValida = false;

        $$('accordionGF').hide();
        $$('accordionGR').hide();
        $$('accordionGV').hide();
        $$('filaDetalleAjuste').hide();
        $$('gdvOperaciones').hide();

        $.blockUI({
            message: null,
            onBlock: function () {
                $.ajax({
                    type: "POST",
                    async: false,
                    url: pageUrl + "/ValidarOperacion",
                    data: "{'codigoContabilidad':'" + codigoContabilidad + "', 'codigoOficina':'" + codigoOficina + "', 'codigoMoneda':'" + codigoMoneda + "', 'codigoProducto':'" + codigoProducto + "', 'numeroOperacion':'" + codigoOperacion + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.length > 1) {

                            $$('gdvOperaciones').hide();

                            var datosRetornados = response.split("|");

                            if ((datosRetornados != null) && (datosRetornados[0] != null) && (datosRetornados[0].length > 0) && (datosRetornados[0] != '0') && (datosRetornados[1].length > 0)) {
                                $$('lblMensaje').text(datosRetornados[1]);
                                $$('accordionGF').hide();
                                $$('accordionGR').hide();
                                $$('accordionGV').hide();
                                $$('filaDetalleAjuste').hide();
                                $$('gdvOperaciones').hide();
                                return false;
                            }
                            else if ((datosRetornados != null) && (datosRetornados[0] != null) && (datosRetornados[0].length > 0) && (datosRetornados[0] == '0')) {
                                $$('accordionGF').show();
                                $$('accordionGR').show();
                                $$('accordionGV').show();

                                consecutivoOperacion = ((datosRetornados[1].length > 0) ? datosRetornados[1] : '');

                                operacionValida = true;

                                /*******/
                                //Extraer la lista de las garantías
                                /*******/

                                for (var tipoGarantia = 1; tipoGarantia <= 3; tipoGarantia++) {

                                     $.ajax({
                                        type: "POST",
                                        async: false,
                                        url: pageUrl + "/ObtenerGarantias",
                                        data: "{'tipoOperacion':'" + tipoOperacion.toString() + "', 'consecutivoOperacion':'" + consecutivoOperacion + "', 'codigoContabilidad':'" + codigoContabilidad + "', 'codigoOficina':'" + codigoOficina + "', 'codigoMoneda':'" + codigoMoneda + "', 'codigoProducto':'" + codigoProducto + "', 'numeroOperacion':'" + codigoOperacion + "', 'tipoGarantia':'" + tipoGarantia.toString() + "'}",
                                        contentType: "application/json; charset=utf-8",
                                        dataType: "text html",
                                        success: function (response) {

                                            if (response.length > 0) {

                                                switch (tipoGarantia) {
                                                    case 1:
                                                        $datosConsulta = htmlDecode(response).replace('"<table>', '<table>').replace('</table>"', '</table>');
                                                        $$('tablaGarantiasFiduciarias').empty().append($datosConsulta);
                                                        $$('accordionGF').accordion("refresh");
                                                        break;
                                                    case 2:
                                                        $datosConsulta = htmlDecode(response).replace('"<table>', '<table>').replace('</table>"', '</table>');
                                                        $$('tablaGarantiasReales').empty().append($datosConsulta);
                                                        $$('accordionGR').accordion("refresh");
                                                        break;
                                                    case 3:
                                                        $datosConsulta = htmlDecode(response).replace('"<table>', '<table>').replace('</table>"', '</table>');
                                                        $$('tablaGarantiasValor').empty().append($datosConsulta);
                                                        $$('accordionGV').accordion("refresh");
                                                        break;
                                                    default:
                                                        break;
                                                }
                                            }
                                        },
                                        failure: function (response) {
                                            $$('lblMensaje').text(response);
                                        }
                                    });
                                }
                            }
                        }
                    },
                    failure: function (response) {
                        $$('lblMensaje').text(response);
                    }
                });

            }
        });
    }
}

//METODO ASINCRONICO QUE PERMITE VALIDAR LA GARANTIA SUMINISTRADA   
function ValidarGarantia() {

    $$('lblMensaje').text('');

    $$('accordionGF').hide();
    $$('accordionGR').hide();
    $$('accordionGV').hide();
    $$('filaDetalleAjuste').hide();
    $$('gdvOperaciones').hide();

    var tipoGarantia = parseInt((($$('cbTipoGarantia').val() != null) ? $$('cbTipoGarantia').val() : "-1"));

    if (ValidarCamposGarantia()) {

        switch (tipoGarantia) {
            case 1:
                var tipoPersona = $$('cbTipoPersona').val();
                var idFiador = $$('txtCedulaFiador').val();
                ConsultarGarantiaFiduciaria(tipoPersona, idFiador);
                break;
            case 2:
                var identificacionBien = $$('txtNumFinca').val();
                var claseGarantia = $$('cbClaseGarantiaReal').val();
                var partido = (($$('txtPartido').val().length > 0) ? $$('txtPartido').val() : '-1');
                var grado = (($$('txtGrado').val().length > 0) ? $$('txtGrado').val() : '-1');
                ConsultarGarantiaReal(identificacionBien, claseGarantia, partido, grado);
                break;
            case 3:
                var numeroSeguridad = $$('txtNumeroSeguridad').val();
                var claseGarantia = $$('cbClaseGarantiaValor').val();
                ConsultarGarantiaValor(numeroSeguridad, claseGarantia);
                break;
            default: SaldosTotalesPorcResp_PageInit();
                break;
        }
    }
}

//OBTIENE LOS DATOS DE LA GARANTIA SELECCIONADA
function ConsultarGarantiaFiduciaria(tipoPersonaFiador, cedulaFiador) {

    $$('lblMensaje').text('');

    var pageUrl = 'frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx';

    $$('filaDetalleAjuste').hide();
    $$('gdvOperaciones').hide();


    if (cedulaFiador != null) {
 
        $.blockUI({
            message: null,
            onBlock: function () {
                $.ajax({
                    type: "POST",
                    async: false,
                    url: pageUrl + "/ObtenerOperacionesGarantiaFiduciaria",
                    data: "{'tipoPersona':'" + tipoPersonaFiador + "', 'identificacionFiador':'" + cedulaFiador + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {

                        if (response.length > 0) {

                            if (response[0].CodigoError === 0) {

                                $arregloOperaciones = response;
                                var checkBoxSeleccionado = "<input type=\"checkbox\" checked=\"checked\" disabled=\"disabled\"/>";
                                var checkBoxNoSeleccionado = "<input type=\"checkbox\"disabled=\"disabled\"/>";

                                var row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
                                $("[id*=gdvOperaciones] tr").not($("[id*=gdvOperaciones] tr:first-child")).remove();

                                for (var i = 0; i < response.length; i++) {

                                    if (response[i].NumeroRegistro === 1) {

                                        $("td", row).eq(0).html("<a style=\"color: #333333\" href=\"javascript:DesplegarAjustes('" + response[i].ConsecutivoOperacion + "', '" + response[i].ConsecutivoGarantia + "');\" onclick=\"javascript:DesplegarAjustes('" + response[i].ConsecutivoOperacion + "', '" + response[i].ConsecutivoGarantia + "');\">" + response[i].OperacionLarga + "</a>");
                                        $("td", row).eq(1).html(response[i].SaldoActualTexto);
                                        $("td", row).eq(2).html(response[i].PorcentajeResponsabilidadTexto);
                                        $("td", row).eq(3).html(((response[i].CodigoTipoOperacion !== 2) ? response[i].CuentaContable : "-"));
                                        $("td", row).eq(4).html(response[i].TipoOperacion);
                                        $("td", row).eq(5).html(((response[i].IndicadorExcluido) ? checkBoxSeleccionado : checkBoxNoSeleccionado));
                                        $("td", row).eq(6).html(response[i].ConsecutivoOperacion);
                                        $("td", row).eq(7).html(response[i].ConsecutivoGarantia);
                                        $("td", row).eq(8).html(response[i].CodigoTipoGarantia);
                                        $("td", row).eq(9).html(response[i].IndicadorExcluido);
                                        $("[id*=gdvOperaciones]").append(row);

                                        row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
                                    }
                                };

                                $$('gdvOperaciones').show();
                            }
                            else {
                                $$('lblMensaje').text(response[0].DescripcionError);
                                $$('filaDetalleAjuste').hide();
                                $$('gdvOperaciones').hide();
                            }
                        }

                    },
                    failure: function (response) {
                        $$('lblMensaje').text(response);
                        $$('filaDetalleAjuste').hide();
                        $$('gdvOperaciones').hide();
                    }
                });
            }
        });
    }
}

//OBTIENE LOS DATOS DE LA GARANTIA SELECCIONADA
function ConsultarGarantiaReal(identificacionBien, claseGarantia, partido, grado) {

    $$('lblMensaje').text('');

    var pageUrl = 'frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx';

    $$('filaDetalleAjuste').hide();
    $$('gdvOperaciones').hide();

    if ((identificacionBien != null) && (claseGarantia != null)) {
         
        $.blockUI({
            message: null,
            onBlock: function () {
                $.ajax({
                    type: "POST",
                    async: false,
                    url: pageUrl + "/ObtenerOperacionesGarantiaReal",
                    data: "{'identificacionBien':'" + identificacionBien + "', 'claseGarantia':'" + claseGarantia + "', 'codigoPartido':'" + partido + "', 'codigoGrado':'" + grado + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {

                        if (response.length > 0) {

                            if (response[0].CodigoError === 0) {

                                $arregloOperaciones = response;
                                var checkBoxSeleccionado = "<input type=\"checkbox\" checked=\"checked\" disabled=\"disabled\"/>";
                                var checkBoxNoSeleccionado = "<input type=\"checkbox\"disabled=\"disabled\"/>";

                                var row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
                                $("[id*=gdvOperaciones] tr").not($("[id*=gdvOperaciones] tr:first-child")).remove();

                                for (var i = 0; i < response.length; i++) {

                                    if (response[i].NumeroRegistro === 1) {

                                        $("td", row).eq(0).html("<a style=\"color: #333333\" href=\"javascript:DesplegarAjustes('" + response[i].ConsecutivoOperacion + "', '" + response[i].ConsecutivoGarantia + "');\" onclick=\"javascript:DesplegarAjustes('" + response[i].ConsecutivoOperacion + "', '" + response[i].ConsecutivoGarantia + "');\">" + response[i].OperacionLarga + "</a>");
                                        $("td", row).eq(1).html(response[i].SaldoActualTexto);
                                        $("td", row).eq(2).html(response[i].PorcentajeResponsabilidadTexto);
                                        $("td", row).eq(3).html(((response[i].CodigoTipoOperacion !== 2) ? response[i].CuentaContable : "-"));
                                        $("td", row).eq(4).html(response[i].TipoOperacion);
                                        $("td", row).eq(5).html(((response[i].IndicadorExcluido) ? checkBoxSeleccionado : checkBoxNoSeleccionado));
                                        $("td", row).eq(6).html(response[i].ConsecutivoOperacion);
                                        $("td", row).eq(7).html(response[i].ConsecutivoGarantia);
                                        $("td", row).eq(8).html(response[i].CodigoTipoGarantia);
                                        $("td", row).eq(9).html(response[i].IndicadorExcluido);
                                        $("[id*=gdvOperaciones]").append(row);

                                        row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
                                    }
                                };

                                $$('gdvOperaciones').show();
                            }
                            else {
                                $$('lblMensaje').text(response[0].DescripcionError);
                                $$('filaDetalleAjuste').hide();
                                $$('gdvOperaciones').hide();
                            }
                        }

                    },
                    failure: function (response) {
                        $$('lblMensaje').text(response);
                        $$('filaDetalleAjuste').hide();
                        $$('gdvOperaciones').hide();
                    }
                });
            }
        });
    }
}

//OBTIENE LOS DATOS DE LA GARANTIA SELECCIONADA
function ConsultarGarantiaValor(numeroSeguridad, claseGarantia) {

    $$('lblMensaje').text('');

    var pageUrl = 'frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx';

    $$('filaDetalleAjuste').hide();
    $$('gdvOperaciones').hide();

    if ((numeroSeguridad != null) && (claseGarantia != null)) {
         
        $.blockUI({
            message: null,
            onBlock: function () {
                $.ajax({
                    type: "POST",
                    async: false,
                    url: pageUrl + "/ObtenerOperacionesGarantiaValor",
                    data: "{'numeroSeguridad':'" + numeroSeguridad + "', 'claseGarantia':'" + claseGarantia + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {

                        if (response.length > 0) {

                            if (response[0].CodigoError === 0) {

                                $arregloOperaciones = response;
                                var checkBoxSeleccionado = "<input type=\"checkbox\" checked=\"checked\" disabled=\"disabled\"/>";
                                var checkBoxNoSeleccionado = "<input type=\"checkbox\"disabled=\"disabled\"/>";

                                var row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
                                $("[id*=gdvOperaciones] tr").not($("[id*=gdvOperaciones] tr:first-child")).remove();

                                for (var i = 0; i < response.length; i++) {

                                    if (response[i].NumeroRegistro === 1) {

                                        $("td", row).eq(0).html("<a style=\"color: #333333\" href=\"javascript:DesplegarAjustes('" + response[i].ConsecutivoOperacion + "', '" + response[i].ConsecutivoGarantia + "');\" onclick=\"javascript:DesplegarAjustes('" + response[i].ConsecutivoOperacion + "', '" + response[i].ConsecutivoGarantia + "');\">" + response[i].OperacionLarga + "</a>");
                                        $("td", row).eq(1).html(response[i].SaldoActualTexto);
                                        $("td", row).eq(2).html(response[i].PorcentajeResponsabilidadTexto);
                                        $("td", row).eq(3).html(((response[i].CodigoTipoOperacion !== 2) ? response[i].CuentaContable : "-"));
                                        $("td", row).eq(4).html(response[i].TipoOperacion);
                                        $("td", row).eq(5).html(((response[i].IndicadorExcluido) ? checkBoxSeleccionado : checkBoxNoSeleccionado));
                                        $("td", row).eq(6).html(response[i].ConsecutivoOperacion);
                                        $("td", row).eq(7).html(response[i].ConsecutivoGarantia);
                                        $("td", row).eq(8).html(response[i].CodigoTipoGarantia);
                                        $("td", row).eq(9).html(response[i].IndicadorExcluido);
                                        $("[id*=gdvOperaciones]").append(row);

                                        row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
                                    }
                                };

                                $$('gdvOperaciones').show();
                            }
                            else {
                                $$('lblMensaje').text(response[0].DescripcionError);
                                $$('filaDetalleAjuste').hide();
                                $$('gdvOperaciones').hide();
                            }
                        }

                    },
                    failure: function (response) {
                        $$('lblMensaje').text(response);
                        $$('filaDetalleAjuste').hide();
                        $$('gdvOperaciones').hide();
                    }
                });
            }
        });
    }
}


/********************************************************************************************************************************************************************************************************************

CLASES

********************************************************************************************************************************************************************************************************************/

function RegistroSeleccionado(consecutivoOperacion, consecutivoGarantia, tipoGarantia, saldoAjustado, saldoActual, porcentajeAjustado, indiceRegistro, saldoMostrado) {
    this.ConsecutivoOperacion = consecutivoOperacion;
    this.ConsecutivoGarantia = consecutivoGarantia;
    this.CodigoTipoGarantia = tipoGarantia;
    this.SaldoActualAjustado = saldoAjustado;
    this.SaldoActual = saldoActual;
    this.PorcentajeResponsabilidadAjustado = porcentajeAjustado;
    this.IndiceRegistro = indiceRegistro;
    this.SaldoMostrado = saldoMostrado;
}






