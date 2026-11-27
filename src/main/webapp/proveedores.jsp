<%@include file="header.jsp" %>
<script src="<%=request.getContextPath()%>/assets/js/jquery-3.7.1.min.js"></script>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <h1 class="m-0">Proveedores</h1>
        </div>
    </div>
    <div class="content">
        <div class="container-fluid">
            <div class="card">
                <div class="card-header">
                    <button class="btn btn-success" onclick="nuevoProveedor()">Nuevo Proveedor</button>
                </div>
                <div class="card-body table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nombre</th>
                                <th>RUC</th>
                                <th>Dirección</th>
                                <th>Teléfono</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody id="tablaBodyProveedores"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalProveedor" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="tituloProveedor">Proveedor</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="proveedorId">
                <div class="mb-3">
                    <label>Nombre *</label>
                    <input type="text" id="nombreProv" class="form-control">
                </div>
                <div class="mb-3">
                    <label>RUC *</label>
                    <input type="text" id="ruc" class="form-control">
                    <small id="rucError" class="text-danger"></small>
                </div>
                <div class="mb-3">
                    <label>Dirección</label>
                    <input type="text" id="direccionProv" class="form-control">
                </div>
                <div class="mb-3">
                    <label>Teléfono</label>
                    <input type="text" id="telefonoProv" class="form-control">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" onclick="guardarProveedor()">Guardar</button>
            </div>
        </div>
    </div>
</div>

<script>
var ctx = "<%=request.getContextPath()%>";

$(document).ready(function () {
    cargarProveedores();
});

function cargarProveedores() {
    $.post(ctx + "/controlador/proveedores_controlador.jsp", { tipo: "listar" }, function (data) {
        $("#tablaBodyProveedores").html(data);
    });
}

function nuevoProveedor() {
    $("#proveedorId").val("");
    $("#nombreProv").val("");
    $("#ruc").val("");
    $("#direccionProv").val("");
    $("#telefonoProv").val("");
    $("#rucError").text("");
    $("#tituloProveedor").text("Nuevo Proveedor");
    new bootstrap.Modal(document.getElementById("modalProveedor")).show();
}

function editarProveedor(id) {
    $.post(ctx + "/controlador/proveedores_controlador.jsp", { tipo: "obtener", id: id }, function (data) {
        var p = (data || "").split("|");
        $("#proveedorId").val(p[0] || "");
        $("#nombreProv").val(p[1] || "");
        $("#ruc").val(p[2] || "");
        $("#direccionProv").val(p[3] || "");
        $("#telefonoProv").val(p[4] || "");
        $("#rucError").text("");
        $("#tituloProveedor").text("Editar Proveedor");
        new bootstrap.Modal(document.getElementById("modalProveedor")).show();
    });
}

function guardarProveedor() {
    var id = $("#proveedorId").val();
    var nombre = $("#nombreProv").val();
    var ruc = $("#ruc").val();
    var direccion = $("#direccionProv").val();
    var telefono = $("#telefonoProv").val();

    if (!nombre || !ruc) {
        alert("Nombre y RUC son obligatorios");
        return;
    }

    $.post(ctx + "/controlador/proveedores_controlador.jsp", {
        tipo: "guardar",
        id: id,
        nombre: nombre,
        ruc: ruc,
        direccion: direccion,
        telefono: telefono
    }, function (response) {
        if ((response || "").includes("ruc_duplicado")) {
            $("#rucError").text("Este RUC ya existe");
        } else if ((response || "").includes("ok")) {
            var m = bootstrap.Modal.getInstance(document.getElementById("modalProveedor"));
            if (m) m.hide();
            alert("Proveedor guardado correctamente");
            cargarProveedores();
        } else {
            alert("Error: " + response);
        }
    });
}

function eliminarProveedor(id) {
    if (confirm("¿Eliminar este proveedor?")) {
        $.post(ctx + "/controlador/proveedores_controlador.jsp", { tipo: "eliminar", id: id }, function () {
            cargarProveedores();
        });
    }
}
</script>
<%@include file="footer.jsp" %>
