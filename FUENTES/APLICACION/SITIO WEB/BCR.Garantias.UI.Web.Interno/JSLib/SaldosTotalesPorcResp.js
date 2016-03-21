//El archivo debe ser minimizado, se usó la herramienta http://jscompress.com/, el resultado se copia en el archivo SaldosTotalesPorcResp_min.js

function SaldosTotalesPorcResp_PageInit() {

    InicializarCamposBusqueda();
    HabilitarCamposBusqueda();

    MostrarGarantiasFiduciariasRelacionadas(true);
    MostrarGarantiasRealesRelacionadas(true);
    MostrarGarantiasValoresRelacionadas(true);

    $("#accordionGF").accordion();
    $("#accordionGR").accordion();
    $("#accordionGV").accordion();

    var $datosConsulta = '';
    var $arregloOperaciones = '';
    

    ValidarPermisoEdicion();
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
function HabilitarRegionBusqueda(codigoRegion)
{
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

    OcultarProgreso(0);

    switch (codigoRegion) {
        case 1: //Región de búsqueda por operación crediticia
            $$('filaBusquedaOperacion').show();
            $$('filaTipoGarantiaReal').hide();
            $$('filaClaseGarantiaReal').hide();
            $$('filaBusquedaGarantia').hide();
            break;
        case 2: //Región de búsqueda por contrato
            $$('filaBusquedaOperacion').show();
            $$('filaTipoGarantiaReal').hide();
            $$('filaClaseGarantiaReal').hide();
            $$('filaBusquedaGarantia').hide();
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
function InicializarCamposBusqueda() {
    $$('cbTipoBusqueda').val('1');
    $$('txtContabilidad').val('1');
    $$('txtOficina').val('220');
    $$('txtMoneda').val('1');
    $$('txtProducto').val('2');
    $$('txtOperacion').val('5904248');
    $$('cbTipoGarantia').val('1');
    $$('cbTipoGarantiaReal').val('1');
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

//SE INICIALIZAN TODOS LOS CAMPOS DE LA SECCIÓN DE BÚSQUEDA
function LimpiarCamposBusqueda() {
    $$('txtContabilidad').val('1');
    $$('txtOficina').val('220');
    $$('txtMoneda').val('1');
    $$('txtProducto').val('2');
    $$('txtOperacion').val('5904248');
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
function HabilitarCamposBusqueda()
{
    var tipoBusqueda = parseInt((($$('cbTipoBusqueda').val() != null) ? $$('cbTipoBusqueda').val() : "1"));

    LimpiarCamposBusqueda();
    $$('tablaGarantiasFiduciarias').empty();
    $$('tablaGarantiasReales').empty();
    $$('tablaGarantiasValor').empty();

    OcultarProgreso(0);


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

            OcultarProgreso(0);

            break;
        default:
            HabilitarRegionBusqueda(1);
            $$('columnaProducto').show();
            break;
    }
}

//SE HABILITAN LOS CAMPOS DE BUSQUEDA SEGUN EL TIPO DE GARANTIA SELECCIONADO
function HabilitarCamposBusquedaGarantia() {
    var tipoBusqueda = parseInt((($$('cbTipoGarantia').val() != null) ? $$('cbTipoGarantia').val() : "1"));
    var codigoCatalogo = "-1";
    OcultarProgreso(0);


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

            OcultarProgreso(0);

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

            OcultarProgreso(0);

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

            OcultarProgreso(0);

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
    OcultarProgreso(0);


    codigoCatalogo = parseInt((($$('hdnCatalogoClasesGarantia').val() != null) ? $$('hdnCatalogoClasesGarantia').val() : "-1"));

    CargarListaCatalogo(codigoCatalogo, $$('cbClaseGarantiaReal'), '2', tipoBusqueda);

    OcultarProgreso(0);

    $$('filaTipoGarantiaReal').show();
    $$('filaBusquedaGarantiaReal').show();
    $$('filaClaseGarantiaReal').show();
    $$('filaBusquedaGarantiaFiduciaria').hide();
    $$('filaBusquedaGarantiaValor').hide();

    switch (tipoBusqueda) {
        case 1:
            $$('filaGradoCedula').hide();

            $$('lblPartido').text('Partido:');
            $$('lblFinca').text('Número Finca:');

            break;
        case 2:
            $$('filaGradoCedula').show();
            $$('filaGradoCedula').css("display", "inline");

            $$('lblPartido').text('Partido:');
            $$('lblFinca').text('Número Finca:');

            break;
        case 3:
            $$('filaGradoCedula').hide();

            $$('lblPartido').text('Clase Bien:');
            $$('lblFinca').text('Id Bien:');

            break;
        default:
            $$('lblPartido').text('Partido:');
            $$('lblFinca').text('Número Finca:');

            $$('filaGradoCedula').hide();

            break;
    }
}


//SE VALIDAN LOS CAMPOS DE LA OPERACION O CONTRATO ANTES DE VERIFICAR SU EXISTENCIA A NIVEL DE BASE DE DATOS.
function ValidarCamposOpercion() {
    var tipoBusqueda = parseInt((($$('cbTipoBusqueda').val() != null) ? $$('cbTipoBusqueda').val() : "-1"));

    if ($$('txtContabilidad').val().length === 0) {
        $$('lblMensaje').val('Debe ingresar el código de contabilidad');
        return false;
    }
    else if ($$('txtOficina').val().length === 0) {
        $$('lblMensaje').val('Debe ingresar el código de oficina');
        return false;
    }
    else if ($$('txtMoneda').val().length === 0) {
        $$('lblMensaje').val('Debe ingresar el código de moneda');
        return false;
    }
    else if ((tipoBusqueda === 1) && ($$('txtProducto').val().length === 0)) {
        $$('lblMensaje').val('Debe ingresar el código del producto');
        return false;
    }
    else if ($$('txtOperacion').val().length === 0) {
        if (tipoBusqueda === 1) {
            $$('lblMensaje').val('Debe ingresar el número de operación');
        }
        else {
            $$('lblMensaje').val('Debe ingresar el número de contrato');
        }
        return false;
    }

    return true;

}


/********************************************************************************************************************************************************************************************************************

METODOS UTILITARIOS

********************************************************************************************************************************************************************************************************************/


//Muestra el mensaje informativo del paso que se esté ejecutando con AJAX
function MostrarProgreso(mensaje) {

    var textoEtiqueta = $$('textoCarga');

    textoEtiqueta.text(((mensaje.length > 0) ? mensaje : 'Procesando...'));

    //setTimeout(function () {
    var modal = $('<div />');
    modal.addClass("modal");
    $('body').append(modal);
    var loading = $(".loading");
    loading.show();
    var top = Math.max($(window).height() / 2 - loading[0].offsetHeight / 2, 0);
    var left = Math.max($(window).width() / 2 - loading[0].offsetWidth / 2, 0);
    loading.css({ top: top, left: left });
    //}, 200);

    return true;
}

//Oculta el mensaje informativo del paso que se esté ejecutando con AJAX
function OcultarProgreso(tiempoEspera) {

    var textoEtiqueta = $$('textoCarga');

    textoEtiqueta.text('Procesando...');

    //setTimeout(function () {
    var loading = $(".loading");
    var modal = $(".modal");
    loading.hide();
    modal.hide();
    // }, tiempoEspera);
}

//Cambia el texto de la etiqueta y muestra el mensaje informativo del paso que se esté ejecutando con AJAX
function CambiarEtiquetaProgreso(mensaje) {
    OcultarProgreso(200);
    MostrarProgreso(mensaje);

    $(document).bind("ajaxStart", function () {
        MostrarProgreso(mensaje);
    }).bind("ajaxStop", function () {
        OcultarProgreso(500);
    });

    return true;
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

function DesplegarAjustes(consecutivoOperacion, consecutivoGarantia){
        
    if ($arregloOperaciones.length > 0) {

        $$('filaDetalleAjuste').show();
        $PermisoEdicion = $$('hdnPermisoEdicion').val();

        for (var i = 0; i < $arregloOperaciones.length; i++) {
                        
            var saldoActualMostrar = (($arregloOperaciones[i].SaldoActualAjustado >= 0) ? $arregloOperaciones[i].SaldoActualAjustado : (($arregloOperaciones[i].SaldoActual > 0) ? $arregloOperaciones[i].SaldoActual : '0.00'));
            var porcentajeMostrar = (($arregloOperaciones[i].PorcentajeResponsabilidadAjustado >= 0) ? $arregloOperaciones[i].PorcentajeResponsabilidadAjustado : '0.00');
           
            if (($arregloOperaciones[i].NumeroRegistro === 1) && ($arregloOperaciones[i].ConsecutivoOperacion == consecutivoOperacion) && ($arregloOperaciones[i].ConsecutivoGarantia == consecutivoGarantia)) {
                   
                $RegistroExcluido = $arregloOperaciones[i].IndicadorExcluido;

                $registroSeleccionado = new RegistroSeleccionado(consecutivoOperacion, consecutivoGarantia, $arregloOperaciones[i].TipoGarantia, saldoActualMostrar, porcentajeMostrar, i);

                $$('lblNumeroOperacion').text($arregloOperaciones[i].OperacionLarga);
                $$('txtSaldoAjustado').val(saldoActualMostrar);
                $$('txtPorcentajeResponsabilidad').val(porcentajeMostrar);
                
                $$('txtSaldoAjustado').trigger('change');
                $$('txtPorcentajeResponsabilidad').trigger('change');                                

                if ($arregloOperaciones[i].IndicadorExcluido === 1) {
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

    if($PermisoEdicion === '0'){
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

        if ($RegistroExcluido === 1) {
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

function LimpiarCampos()
{
    $$('txtSaldoAjustado').val("0.00");
    $$('txtPorcentajeResponsabilidad').val("0.00");

    if ($RegistroExcluido === 1) {
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

function RegistroSiguiente() {

    if (($arregloOperaciones.length > 0) && ($registroSeleccionado != null)) {

        for (var i = 0; i < $arregloOperaciones.length; i++) {
            
            var indiceSiguiente = i+1;

            if(($registroSeleccionado.IndiceRegistro == i) && (indiceSiguiente < $arregloOperaciones.length))
            {
                DesplegarAjustes($arregloOperaciones[indiceSiguiente].ConsecutivoOperacion, $arregloOperaciones[indiceSiguiente].ConsecutivoGarantia);
                $$('Siguiente').removeAttr('disabled');
            }
            else {
                $$('Siguiente').attr('disabled', 'disabled');
            }
        }
    }
    else {
        $$('Siguiente').attr('disabled', 'disabled');
    }
}

function RegistroAnterior() {

    if (($arregloOperaciones.length > 0) && ($registroSeleccionado != null)) {

        for (var i = 0; i < $arregloOperaciones.length; i++) {

            var indiceAnterior = i-1;

            if (($registroSeleccionado.IndiceRegistro == i) && (indiceAnterior >= 0)) {
                DesplegarAjustes($arregloOperaciones[indiceAnterior].ConsecutivoOperacion, $arregloOperaciones[indiceAnterior].ConsecutivoGarantia);
                $$('Anterior').removeAttr('disabled');
            }
            else {
                $$('Anterior').attr('disabled', 'disabled');
            }
        }
    }
    else {
        $$('Anterior').attr('disabled', 'disabled');
    }
}

/********************************************************************************************************************************************************************************************************************

METODOS ASINCRONICOS

********************************************************************************************************************************************************************************************************************/

//METODO ASINCRONICO QUE PERMITE VALIDAR SI EL USUARIO POSEE PERMISOS DE EDICION
function ValidarPermisoEdicion() {

    var pageUrl = 'frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx';

    var listaPermisos = (($$('hdnPerfilesPermitidos').val() != null) ? $$('hdnPerfilesPermitidos').val() : "");


    OcultarProgreso(0);

    $.ajax({
        type: "POST",
        async: true,
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

    OcultarProgreso(0);

    $.ajax({
        type: "POST",
        async: true,
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
 
        OcultarProgreso(0);

        CambiarEtiquetaProgreso('Validando...');

        $.ajax({
            type: "POST",
            async: true,
            url: pageUrl + "/ValidarOperacion",
            data: "{'codigoContabilidad':'" + codigoContabilidad + "', 'codigoOficina':'" + codigoOficina + "', 'codigoMoneda':'" + codigoMoneda + "', 'codigoProducto':'" + codigoProducto + "', 'numeroOperacion':'" + codigoOperacion + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                if (response.length > 1) {
                          
                    $$('gdvOperaciones').hide();
                    $$('accordionGF').show();
                    $$('accordionGR').show();
                    $$('accordionGV').show();

                    
                    var datosRetornados = response.split("|");

                    if ((datosRetornados != null) && (datosRetornados[0] != null) && (datosRetornados[0].length > 0) && (datosRetornados[0] === '0')) {

                        consecutivoOperacion = ((datosRetornados[1].length > 0) ? datosRetornados[1] : '');

                        operacionValida = true;

                        /*******/
                        //Extraer la lista de las garantías
                        /*******/

                        for (var tipoGarantia = 1; tipoGarantia <= 3; tipoGarantia++) {

                            switch (tipoGarantia) {
                                case 1:
                                    CambiarEtiquetaProgreso('Obteniendo Garantías Fiduciarias...');
                                    break;
                                case 2:
                                    CambiarEtiquetaProgreso('Obteniendo Garantías Reales...');
                                    break;
                                case 3:
                                    CambiarEtiquetaProgreso('Obteniendo Garantías Valor...');
                                    break;
                                default:
                                    break;
                            }
                           
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
                else {
                    if ((datosRetornados != null) && (datosRetornados[0] != null) && (datosRetornados[0].length > 0) && (datosRetornados[0] !== '0') && (datosRetornados[1].length > 0)) {
                        $$('lblMensaje').text(datosRetornados[1]);                       
                    }
                }            
            },
            failure: function (response) {
                $$('lblMensaje').text(response);
            }
        });
   }
}

//METODO ASINCRONICO QUE PERMITE VALIDAR LA GARANTIA SUMINISTRADA   
function ValidarGarantia() {

    var tipoGarantia = parseInt((($$('cbTipoGarantia').val() != null) ? $$('cbTipoGarantia').val() : "-1"));
 
    switch (tipoGarantia) {
        case 1:
            CambiarEtiquetaProgreso('Obteniendo Garantías Fiduciarias...');
            var tipoPersona = $$('cbTipoPersona').val();
            var idFiador = $$('txtCedulaFiador').val();
            ConsultarGarantiaFiduciaria(tipoPersona, idFiador);
            break;
        case 2:
            CambiarEtiquetaProgreso('Obteniendo Garantías Reales...');
            var identificacionBien = $$('txtNumFinca').val();
            var claseGarantia = $$('cbClaseGarantiaReal').val();
            var partido = (($$('txtPartido').val().length > 0) ? $$('txtPartido').val() : '-1');
            var grado = (($$('txtGrado').val().length > 0) ? $$('txtGrado').val() : '-1');
            ConsultarGarantiaReal(identificacionBien, claseGarantia, partido, grado);
            break;
        case 3:
            CambiarEtiquetaProgreso('Obteniendo Garantías Valor...');
            var numeroSeguridad = $$('txtNumeroSeguridad').val();
            var claseGarantia = $$('cbClaseGarantiaValor').val();
            ConsultarGarantiaValor(numeroSeguridad, claseGarantia);
            break;
        default:
            break;
    }
        
    

}

//OBTIENE LOS DATOS DE LA GARANTIA SELECCIONADA
function ConsultarGarantiaFiduciaria(tipoPersonaFiador, cedulaFiador) {

    var pageUrl = 'frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx';
    
    if (cedulaFiador != null)  {

        OcultarProgreso(0);

        CambiarEtiquetaProgreso('Obteniendo Operaciones...');

        $.ajax({
            type: "POST",
            async: true,
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
                                $("td", row).eq(1).html(response[i].SaldoActual);
                                $("td", row).eq(2).html(((response[i].PorcentajeResponsabilidadCalculado >= 0) ? response[i].PorcentajeResponsabilidadCalculado : '0.00'));
                                $("td", row).eq(3).html(((response[i].CodigoTipoOperacion === 1) ? response[i].CuentaContable : "-"));
                                $("td", row).eq(4).html(response[i].TipoOperacion);
                                $("td", row).eq(5).html(((response[i].IndicadorExcluido === 1) ? checkBoxSeleccionado : checkBoxNoSeleccionado));
                                $("td", row).eq(6).html(response[i].ConsecutivoOperacion);
                                $("td", row).eq(7).html(response[i].ConsecutivoGarantia);
                                $("td", row).eq(8).html(response[i].CodigoTipoGarantia);
                                $("td", row).eq(9).html(response[i].IndicadorExcluido);
                                $("[id*=gdvOperaciones]").append(row);

                                row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
                            }
                        };

                        $$('gdvOperaciones').show();
                        // alert(($$('gdvOperaciones').is(":hidden")));
                    }
                    else {
                        $$('lblMensaje').text(response[0].DescripcionError);
                        $$('gdvOperaciones').hide();
                    }
                }

            },
            failure: function (response) {
                $$('lblMensaje').text(response);
                $$('gdvOperaciones').hide();
            }
        });
    }
}

//OBTIENE LOS DATOS DE LA GARANTIA SELECCIONADA
function ConsultarGarantiaReal(identificacionBien, claseGarantia, partido, grado) {

    var pageUrl = 'frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx';

    if ((identificacionBien != null) && (claseGarantia != null)) {

        OcultarProgreso(0);

        CambiarEtiquetaProgreso('Obteniendo Operaciones...');

        $.ajax({
            type: "POST",
            async: true,
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
                                $("td", row).eq(2).html(((response[i].PorcentajeResponsabilidadCalculado >= 0) ? response[i].PorcentajeResponsabilidadCalculado : '0.00'));
                                $("td", row).eq(3).html(((response[i].CodigoTipoOperacion === 1) ? response[i].CuentaContable : "-"));
                                $("td", row).eq(4).html(response[i].TipoOperacion);
                                $("td", row).eq(5).html(((response[i].IndicadorExcluido === 1) ? checkBoxSeleccionado : checkBoxNoSeleccionado));
                                $("td", row).eq(6).html(response[i].ConsecutivoOperacion);
                                $("td", row).eq(7).html(response[i].ConsecutivoGarantia);
                                $("td", row).eq(8).html(response[i].CodigoTipoGarantia);
                                $("td", row).eq(9).html(response[i].IndicadorExcluido);
                                $("[id*=gdvOperaciones]").append(row);

                                row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
                            }
                        };

                        $$('gdvOperaciones').show();
                       // alert(($$('gdvOperaciones').is(":hidden")));
                    }
                    else {
                        $$('lblMensaje').text(response[0].DescripcionError);
                        $$('gdvOperaciones').hide();
                    }
                }

            },
            failure: function (response) {
                $$('lblMensaje').text(response);
                $$('gdvOperaciones').hide();
            }
        });
    }
}

//OBTIENE LOS DATOS DE LA GARANTIA SELECCIONADA
function ConsultarGarantiaValor(numeroSeguridad, claseGarantia) {

    var pageUrl = 'frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx';

    if ((numeroSeguridad != null) && (claseGarantia != null)) {

        OcultarProgreso(0);

        CambiarEtiquetaProgreso('Obteniendo Operaciones...');

        $.ajax({
            type: "POST",
            async: true,
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
                                $("td", row).eq(1).html(response[i].SaldoActual);
                                $("td", row).eq(2).html(((response[i].PorcentajeResponsabilidadCalculado >= 0) ? response[i].PorcentajeResponsabilidadCalculado : '0.00'));
                                $("td", row).eq(3).html(((response[i].CodigoTipoOperacion === 1) ? response[i].CuentaContable : "-"));
                                $("td", row).eq(4).html(response[i].TipoOperacion);
                                $("td", row).eq(5).html(((response[i].IndicadorExcluido === 1) ? checkBoxSeleccionado : checkBoxNoSeleccionado));
                                $("td", row).eq(6).html(response[i].ConsecutivoOperacion);
                                $("td", row).eq(7).html(response[i].ConsecutivoGarantia);
                                $("td", row).eq(8).html(response[i].CodigoTipoGarantia);
                                $("td", row).eq(9).html(response[i].IndicadorExcluido);
                                $("[id*=gdvOperaciones]").append(row);

                                row = $("[id*=gdvOperaciones] tr:last-child").clone(true);
                            }
                        };

                        $$('gdvOperaciones').show();
                        // alert(($$('gdvOperaciones').is(":hidden")));
                    }
                    else {
                        $$('lblMensaje').text(response[0].DescripcionError);
                        $$('gdvOperaciones').hide();
                    }
                }

            },
            failure: function (response) {
                $$('lblMensaje').text(response);
                $$('gdvOperaciones').hide();
            }
        });
    }
}


function InsertarRegistro() {

    if ($registroSeleccionado != null) {

    }
}



/********************************************************************************************************************************************************************************************************************

CLASES

********************************************************************************************************************************************************************************************************************/

function RegistroSeleccionado(consecutivoOperacion, consecutivoGarantia, tipoGarantia, saldoAjustado, porcentajeAjustado, indiceRegistro) {
    this.ConsecutivoOperacion = consecutivoOperacion;
    this.ConsecutivoGarantia = consecutivoGarantia;
    this.TipoGarantia = tipoGarantia;
    this.SaldoActualAjustado = saldoAjustado;
    this.PorcentajeResponsabilidaAjustado = porcentajeAjustado;
    this.IndiceRegistro = indiceRegistro;
}




 