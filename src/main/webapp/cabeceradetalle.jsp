
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Date fechaActual = new Date();
    SimpleDateFormat formateador = new SimpleDateFormat("dd-MM-yyyy");
    String fechaFormateada = formateador.format(fechaActual);
%>
<%@include file="header.jsp" %>

<div class="content-wrapper">
    <section class="content">
        <form id="formCompra" enctype="multipart/form-data" method="POST" class="form-horizontal">
            <input type="hidden" id="tipo" name="tipo" value="cargar"/>
            <h3><i class="fa fa-shopping-cart"></i> Compras de Artículos</h3><br>

            <div class="row">
                <div class="col-lg-3">
                    <h5>Datos del Proveedor</h5>
                    <div class="form-group">
                        <label>Proveedor</label>
                        <select class="form-control" name="idproveedor" id="idproveedor" onchange="separarProveedor(this.value)"></select>
                    </div>
                    <div class="form-group">
                        <label>Documento (CI)</label>
                        <input type="hidden" id="codproveedor" name="codproveedor">
                        <input type="hidden" id="codproducto" name="codproducto">
                        <input class="form-control" type="text" id="ruc" readonly>
                    </div>
                    <div class="form-group">
                        <label>Fecha</label>
                        <input class="form-control" type="text" name="fecharegistro" value="<%= fechaFormateada %>" readonly>
                    </div>
                </div>

                <div class="col-lg-9">
                    <div class="panel panel-warning">
                        <div class="panel-heading">
                            <h4><strong>Detalle de la Compra</strong></h4>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-5">
                                    <label>Artículo</label>
                                    <select class="form-control" name="idproducto" id="idproducto" onchange="separarArticulo(this.value)"></select>
                                </div>
                                <div class="col-md-3">
                                    <label>Precio</label>
                                    <input class="form-control" type="text" id="precio" readonly>
                                </div>
                                <div class="col-md-2">
                                    <label>Cantidad</label>
                                    <input class="form-control" type="number" id="cantidad" value="1">
                                </div>
                            </div>
                            <br>
                            <button type="button" id="btnAgregar" class="btn btn-primary">Agregar</button>
                            <div id="respuesta"></div>

                            <hr>
                            <table class="table table-striped" id="tablaDetalle">
                                <thead>
                                    <tr>
                                        <th>Acción</th>
                                        <th>Artículo</th>
                                        <th>Precio</th>
                                        <th>Cantidad</th>
                                        <th>Total</th>
                                    </tr>
                                </thead>
                                <tbody id="resultados"></tbody>
                            </table>

                            <div class="text-right">
                                <strong>Total: <span id="lbltotal">0.00</span></strong>
                            </div>

                            <div class="modal-footer">
                                <button type="button" class="btn btn-danger" onclick="cancelarCompra()">Cancelar Compra</button>
                                <button type="button" class="btn btn-success" onclick="finalizarCompra()">Finalizar Compra</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </section>
</div>

<script src="<%=request.getContextPath()%>/assets/js/jquery-3.7.1.min.js"></script>
<script>
var ctx = "<%=request.getContextPath()%>";

$(document).ready(function () {
    rellenarProveedores();
    rellenarArticulos();
    rellenarDetalle();
});

function rellenarProveedores() {
    $.post(ctx + "/controlador/compras_controlador.jsp", {
        tipo: "listarproveedores"
    }, function (response) {
        $("#idproveedor").html(response);
    });
}

function rellenarArticulos() {
    $.post(ctx + "/controlador/compras_controlador.jsp", {
        tipo: "listararticulos"
    }, function (response) {
        $("#idproducto").html(response);
    });
}

function separarProveedor(val) {
    if (!val) {
        $("#codproveedor").val("");
        $("#ruc").val("");
        return;
    }
    var datos = val.split(",");
    $("#codproveedor").val(datos[0]);
    $("#ruc").val(datos[1] || "");
}

function separarArticulo(val) {
    if (!val) {
        $("#codproducto").val("");
        $("#precio").val("");
        return;
    }
    var datos = val.split(",");
    $("#codproducto").val(datos[0]);
    $("#precio").val(datos[1] || "");
}

$("#btnAgregar").click(function () {
    var codproveedor = $("#codproveedor").val();
    var codproducto = $("#codproducto").val();
    var precio = $("#precio").val();
    var cantidad = $("#cantidad").val();
    var fecharegistro = $("input[name='fecharegistro']").val();

    if (!codproveedor) {
        alert("Seleccione un proveedor");
        return;
    }
    if (!codproducto) {
        alert("Seleccione un artículo");
        return;
    }

    $.post(ctx + "/controlador/compras_controlador.jsp", {
        tipo: "cargar",
        codproveedor: codproveedor,
        codproducto: codproducto,
        precio: precio,
        cantidad: cantidad,
        fecharegistro: fecharegistro
    }, function (response) {
        $("#respuesta").html(response);
        rellenarDetalle();
    });
});

function rellenarDetalle() {
    $.post(ctx + "/controlador/compras_controlador.jsp", {
        tipo: "rellenardetalle"
    }, function (response) {
        $("#resultados").html(response);
    });
}

function eliminarDetalleCompra(id) {
    if (confirm("¿Eliminar este ítem?")) {
        $.post(ctx + "/controlador/compras_controlador.jsp", {
            tipo: "eliminardetalle",
            iddetalle: id
        }, function () {
            rellenarDetalle();
        });
    }
}

function finalizarCompra() {
    if (!confirm("¿Finalizar la compra pendiente?")) return;
    $.post(ctx + "/controlador/compras_controlador.jsp", {
        tipo: "finalizar"
    }, function (response) {
        alert(response);
        rellenarDetalle();
    });
}

function cancelarCompra() {
    if (!confirm("¿Cancelar la compra pendiente?")) return;
    $.post(ctx + "/controlador/compras_controlador.jsp", {
        tipo: "cancelar"
    }, function (response) {
        alert(response);
        rellenarDetalle();
    });
}
</script>

<%@include file="footer.jsp" %>

