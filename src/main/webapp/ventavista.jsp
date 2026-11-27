<%@include file="header.jsp" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Date fechaActual = new Date();
    SimpleDateFormat formateador = new SimpleDateFormat("dd-MM-yyyy");
    String fechaFormateada = formateador.format(fechaActual);
%>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <h1 class="m-0">Ventas de Artículos</h1>
        </div>
    </div>

    <div class="content">
        <div class="container-fluid">

            <div class="card mb-3">
                <div class="card-header bg-primary text-white">
                    <strong>Cabecera de Factura</strong>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label>Cliente</label>
                            <select class="form-control" id="idcliente" onchange="separarCliente(this.value)">
                                <option value="">Seleccionar Cliente</option>
                            </select>
                            <input type="hidden" id="codcliente">
                        </div>
                        <div class="col-md-4">
                            <label>RUC</label>
                            <input type="text" class="form-control" id="ruc" readonly>
                        </div>
                        <div class="col-md-4">
                            <label>Fecha de Factura</label>
                            <input type="text" class="form-control" value="<%= fechaFormateada %>" readonly>
                        </div>
                    </div>
                </div>
            </div>

            
            <div class="card mb-3">
                <div class="card-header bg-warning">
                    <strong>Agregar Artículo</strong>
                </div>
                <div class="card-body">
                    <div class="row g-2 align-items-end">
                        <div class="col-md-4">
                            <label>Artículo</label>
                            <select class="form-control" id="idproducto" onchange="separarProducto(this.value)">
                                <option value="">Seleccionar Artículo</option>
                            </select>
                            <input type="hidden" id="codproducto">
                            <input type="hidden" id="codigoArt">
                            <input type="hidden" id="descripcionArt">
                        </div>
                        <div class="col-md-2">
                            <label>Precio Unit.</label>
                            <input type="text" class="form-control" id="precio" readonly>
                        </div>
                        <div class="col-md-1">
                            <label>IVA %</label>
                            <input type="text" class="form-control" id="iva" readonly>
                        </div>
                        <div class="col-md-2">
                            <label>Cantidad</label>
                            <input type="number" class="form-control" id="cantidad" value="1" min="1">
                        </div>
                        <div class="col-md-2">
                            <button type="button" class="btn btn-primary w-100" id="btnAgregar">Agregar</button>
                        </div>
                    </div>
                    <div id="respuesta" class="mt-2"></div>
                </div>
            </div>

            
            <div class="card mb-3">
                <div class="card-header bg-secondary text-white">
                    <strong>Detalle</strong>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped table-sm">
                            <thead class="table-dark">
                                <tr>
                                    <th>Acción</th>
                                    <th>Código</th>
                                    <th>Descripción</th>
                                    <th>Precio Unit.</th>
                                    <th>IVA</th>
                                    <th>Cantidad</th>
                                    <th>Subtotal</th>
                                </tr>
                            </thead>
                            <tbody id="resultados"></tbody>
                        </table>
                    </div>

                    
                    <div class="row justify-content-end mt-3">
                        <div class="col-md-5">
                            <table class="table table-sm table-bordered">
                                <tr>
                                    <td><strong>Total Exenta (IVA 0%)</strong></td>
                                    <td class="text-end" id="total0">0</td>
                                </tr>
                                <tr>
                                    <td><strong>Total Gravada IVA 5%</strong></td>
                                    <td class="text-end" id="total5">0</td>
                                </tr>
                                <tr>
                                    <td><strong>Total Gravada IVA 10%</strong></td>
                                    <td class="text-end" id="total10">0</td>
                                </tr>
                                <tr class="table-success">
                                    <td><strong>TOTAL DE VENTA</strong></td>
                                    <td class="text-end"><strong id="lbltotal">0</strong></td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <div class="text-end mt-2">
                        <button type="button" class="btn btn-danger me-2" onclick="cancelarVenta()">Cancelar Venta</button>
                        <button type="button" class="btn btn-success" onclick="finalizarVenta()">Finalizar Venta</button>
                    </div>
                </div>
            </div>

            
            <div class="card">
                <div class="card-header bg-success text-white d-flex justify-content-between">
                    <strong>Ventas Finalizadas</strong>
                    <button class="btn btn-light btn-sm" onclick="cargarVentasFinalizadas()">Actualizar</button>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Cliente</th>
                                    <th>Fecha</th>
                                    <th>Estado</th>
                                    <th>Acción</th>
                                </tr>
                            </thead>
                            <tbody id="cuerpoFinalizadas">
                                <tr><td colspan="5" class="text-center text-muted">Cargando...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script src="<%=request.getContextPath()%>/assets/js/jquery-3.7.1.min.js"></script>                        
<script>
var idVentaActual = 0;
var ctx = "<%=request.getContextPath()%>";

$(document).ready(function () {
    cargarClientes();
    cargarArticulos();
    cargarVentasFinalizadas();
});

function cargarClientes() {
    $.post(ctx + "/controlador/ventas_controlador.jsp", { tipo: "listarcliente" }, function (data) {
        $("#idcliente").html(data);
    });
}

function cargarArticulos() {
    $.post(ctx + "/controlador/ventas_controlador.jsp", { tipo: "listararticulos" }, function (data) {
        $("#idproducto").html(data);
    });
}


function separarCliente(valor) {
    if (!valor) {
        $("#ruc").val("");
        $("#codcliente").val("");
        return;
    }
    var p = valor.split("|");
    $("#codcliente").val(p[0]);
    $("#ruc").val(p[1] || "");
}


function separarProducto(valor) {
    if (!valor) {
        $("#precio").val("");
        $("#iva").val("");
        $("#codproducto").val("");
        $("#codigoArt").val("");
        $("#descripcionArt").val("");
        return;
    }
    var p = valor.split("|");
    $("#codproducto").val(p[0]);
    $("#precio").val(p[1] || "");
    $("#iva").val(p[2] || "10");
    $("#codigoArt").val(p[3] || "");
    $("#descripcionArt").val(p[4] || "");
}

$("#btnAgregar").click(function () {
    var idcliente = $("#codcliente").val();
    var idarticulo = $("#codproducto").val();
    var precio = $("#precio").val();
    var iva = $("#iva").val();
    var cantidad = $("#cantidad").val();

    if (!idcliente) { alert("Seleccione un cliente"); return; }
    if (!idarticulo) { alert("Seleccione un artículo"); return; }
    if (!cantidad || cantidad < 1) { alert("Cantidad inválida"); return; }

    $.post(ctx + "/controlador/ventas_controlador.jsp", {
        tipo: "cargar",
        idcliente: idcliente,
        idarticulo: idarticulo,
        precio: precio,
        iva: iva,
        cantidad: cantidad,
        idventa: idVentaActual
    }, function (response) {
        response = (response || "").trim();
        if (response.indexOf("OK|") === 0) {
            idVentaActual = response.split("|")[1];
            $("#respuesta").html("<div class='alert alert-success py-1'>Producto agregado</div>");
            cargarDetalle();
            $("#idproducto").val("");
            $("#precio").val("");
            $("#iva").val("");
            $("#cantidad").val("1");
            $("#codproducto").val("");
            $("#codigoArt").val("");
            $("#descripcionArt").val("");
        } else {
            $("#respuesta").html("<div class='alert alert-danger py-1'>" + response + "</div>");
        }
    });
});

function cargarDetalle() {
    if (!idVentaActual || idVentaActual == 0) {
        $("#resultados").html("");
        $("#lbltotal").text("0");
        $("#total0").text("0");
        $("#total5").text("0");
        $("#total10").text("0");
        return;
    }
    $.post(ctx + "/controlador/ventas_controlador.jsp", {
        tipo: "rellenardetalle",
        idventa: idVentaActual
    }, function (data) {
        data = (data || "").trim();
        // formato: HTML_FILAS|TOTAL|t0|t5|t10|tGeneral
        var partes = data.split("|TOTAL|");
        $("#resultados").html(partes[0] || "");
        if (partes[1]) {
            var t = partes[1].split("|");
            $("#total0").text(Number(t[0] || 0).toLocaleString("es-PY"));
            $("#total5").text(Number(t[1] || 0).toLocaleString("es-PY"));
            $("#total10").text(Number(t[2] || 0).toLocaleString("es-PY"));
            $("#lbltotal").text(Number(t[3] || 0).toLocaleString("es-PY"));
        }
    });
}

function eliminarDetalle(id) {
    if (confirm("¿Eliminar este ítem?")) {
        $.post(ctx + "/controlador/ventas_controlador.jsp", { tipo: "eliminardetalle", id: id }, function () {
            cargarDetalle();
        });
    }
}

function finalizarVenta() {
    if (!idVentaActual || idVentaActual == 0) {
        alert("No hay una venta en curso");
        return;
    }
    if (confirm("¿Finalizar esta venta?")) {
        $.post(ctx + "/controlador/ventas_controlador.jsp", {
            tipo: "finalizar",
            idventa: idVentaActual
        }, function (response) {
            alert((response || "").trim() || "Venta finalizada correctamente");
            idVentaActual = 0;
            $("#resultados").html("");
            $("#lbltotal").text("0");
            $("#total0").text("0");
            $("#total5").text("0");
            $("#total10").text("0");
            $("#idcliente").val("");
            $("#ruc").val("");
            $("#codcliente").val("");
            $("#respuesta").html("");
            cargarVentasFinalizadas();
        });
    }
}

function cancelarVenta() {
    if (!idVentaActual || idVentaActual == 0) {
        alert("No hay una venta en curso");
        return;
    }
    if (confirm("¿Cancelar esta venta pendiente?")) {
        $.post(ctx + "/controlador/ventas_controlador.jsp", {
            tipo: "cancelar",
            idventa: idVentaActual
        }, function (response) {
            alert((response || "").trim() || "Venta cancelada correctamente");
            idVentaActual = 0;
            $("#resultados").html("");
            $("#lbltotal").text("0");
            $("#total0").text("0");
            $("#total5").text("0");
            $("#total10").text("0");
            $("#idcliente").val("");
            $("#ruc").val("");
            $("#codcliente").val("");
            $("#respuesta").html("");
        });
    }
}

function cargarVentasFinalizadas() {
    $.post(ctx + "/controlador/ventas_controlador.jsp", { tipo: "listarfinalizadas" }, function (data) {
        $("#cuerpoFinalizadas").html(data);
    });
}

function anularVenta(id) {
    if (confirm("¿Anular esta venta finalizada?")) {
        $.post(ctx + "/controlador/ventas_controlador.jsp", {
            tipo: "anular",
            idventa: id
        }, function (response) {
            alert(response || "Venta anulada correctamente");
            cargarVentasFinalizadas();
        });
    }
}
</script>

<%@include file="footer.jsp" %>


