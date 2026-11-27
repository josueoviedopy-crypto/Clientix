<%@include file="header.jsp" %>
<script src="<%=request.getContextPath()%>/assets/js/jquery-3.7.1.min.js"></script>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <h1 class="m-0">Productos</h1>
        </div>
    </div>
    <div class="content">
        <div class="container-fluid">
            <div class="card">
                <div class="card-header">
                    <button class="btn btn-success" onclick="nuevoProducto()">Nuevo Producto</button>
                </div>
                <div class="card-body table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Código</th>
                                <th>Descripción</th>
                                <th>Precio</th>
                                <th>IVA</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody id="tablaBodyProductos"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalProducto" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="tituloProducto">Producto</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="productoId">
                <div class="mb-3">
                    <label>Código *</label>
                    <input type="text" id="codigo" class="form-control">
                    <small id="codigoError" class="text-danger"></small>
                </div>
                <div class="mb-3">
                    <label>Descripción *</label>
                    <input type="text" id="descripcion" class="form-control">
                </div>
                <div class="mb-3">
                    <label>Precio *</label>
                    <input type="number" id="precio" class="form-control" step="0.01">
                </div>
                <div class="mb-3">
                    <label>IVA *</label>
                    <select id="iva" class="form-control">
                        <option value="0">0%</option>
                        <option value="5">5%</option>
                        <option value="10" selected>10%</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" onclick="guardarProducto()">Guardar</button>
            </div>
        </div>
    </div>
</div>

<script>
var ctx = "<%=request.getContextPath()%>";

$(document).ready(function () {
    cargarProductos();
});

function cargarProductos() {
    $.post(ctx + "/controlador/productos_controlador.jsp", { tipo: "listar" }, function (data) {
        $("#tablaBodyProductos").html(data);
    });
}

function nuevoProducto() {
    $("#productoId").val("");
    $("#codigo").val("");
    $("#descripcion").val("");
    $("#precio").val("");
    $("#iva").val("10");
    $("#codigoError").text("");
    $("#tituloProducto").text("Nuevo Producto");
    new bootstrap.Modal(document.getElementById("modalProducto")).show();
}

function editarProducto(id) {
    $.post(ctx + "/controlador/productos_controlador.jsp", { tipo: "obtener", id: id }, function (data) {
        var p = (data || "").split("|");
        $("#productoId").val(p[0] || "");
        $("#codigo").val(p[1] || "");
        $("#descripcion").val(p[2] || "");
        $("#precio").val(p[3] || "");
        $("#iva").val(p[4] || "10");
        $("#codigoError").text("");
        $("#tituloProducto").text("Editar Producto");
        new bootstrap.Modal(document.getElementById("modalProducto")).show();
    });
}

function guardarProducto() {
    var id = $("#productoId").val();
    var codigo = $("#codigo").val();
    var descripcion = $("#descripcion").val();
    var precio = $("#precio").val();
    var iva = $("#iva").val();

    if (!codigo || !descripcion || precio === "") {
        alert("Complete los campos obligatorios");
        return;
    }

    $.post(ctx + "/controlador/productos_controlador.jsp", {
        tipo: "guardar",
        id: id,
        codigo: codigo,
        descripcion: descripcion,
        precio: precio,
        iva: iva
    }, function (response) {
        if ((response || "").includes("codigo_duplicado")) {
            $("#codigoError").text("Este código ya existe");
        } else if ((response || "").includes("ok")) {
            var m = bootstrap.Modal.getInstance(document.getElementById("modalProducto"));
            if (m) m.hide();
            alert("Producto guardado correctamente");
            cargarProductos();
        } else {
            alert("Error: " + response);
        }
    });
}

function eliminarProducto(id) {
    if (confirm("¿Eliminar este producto?")) {
        $.post(ctx + "/controlador/productos_controlador.jsp", { tipo: "eliminar", id: id }, function () {
            cargarProductos();
        });
    }
}
</script>
<%@include file="footer.jsp" %>
