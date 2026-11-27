<%@include file="header.jsp" %>

<script src="<%=request.getContextPath()%>/assets/js/jquery-3.7.1.min.js"></script>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">Clientes</h1>
                </div>
            </div>
        </div>
    </div>

    <div class="content">
        <div class="container-fluid">
            <div class="card">
                <div class="card-header">
                    <button type="button" class="btn btn-success" onclick="nuevoCliente()">
                        Nuevo Cliente
                    </button>
                </div>
                <div class="card-body table-responsive">
                    <table class="table table-bordered table-striped" id="tablaClientes">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nombre</th>
                                <th>Documento</th>
                                <th>Email</th>
                                <th>Teléfono</th>
                                <th>Dirección</th>
                                <th>Ciudad</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody id="tablaBody"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>


<div class="modal fade" id="modalCliente" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">Cliente</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="formCliente">
                    <input type="hidden" id="clienteId" name="id">
                    <div class="mb-3">
                        <label>Nombre *</label>
                        <input type="text" id="nombre" name="nombre" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label>Documento *</label>
                        <input type="text" id="documento" name="documento" class="form-control" required>
                        <small id="docError" class="text-danger"></small>
                    </div>
                    <div class="mb-3">
                        <label>Email *</label>
                        <input type="email" id="email" name="email" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label>Teléfono</label>
                        <input type="text" id="telefono" name="telefono" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label>Dirección</label>
                        <input type="text" id="direccion" name="direccion" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label>Ciudad</label>
                        <input type="text" id="ciudad" name="ciudad" class="form-control">
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" onclick="guardarCliente()">Guardar</button>
            </div>
        </div>
    </div>
</div>

<script>
var ctx = "<%=request.getContextPath()%>";

$(document).ready(function () {
    cargarClientes();
});

function cargarClientes() {
    $.post(ctx + "/controlador/clientes_controlador.jsp", { tipo: "listar" }, function (response) {
        $("#tablaBody").html(response);
    });
}

function nuevoCliente() {
    $("#modalTitle").text("Nuevo Cliente");
    $("#formCliente")[0].reset();
    $("#clienteId").val("");
    $("#docError").text("");
    $("#direccion").val("");
    $("#ciudad").val("");
    new bootstrap.Modal(document.getElementById("modalCliente")).show();
}

function editarCliente(id) {
    $.post(ctx + "/controlador/clientes_controlador.jsp", { tipo: "obtener", id: id }, function (data) {
        var p = (data || "").split("|");
        $("#clienteId").val(p[0] || "");
        $("#nombre").val(p[1] || "");
        $("#documento").val(p[2] || "");
        $("#email").val(p[3] || "");
        $("#telefono").val(p[4] || "");
        $("#direccion").val(p[5] || "");
        $("#ciudad").val(p[6] || "");
        $("#docError").text("");
        $("#modalTitle").text("Editar Cliente");
        new bootstrap.Modal(document.getElementById("modalCliente")).show();
    });
}

function guardarCliente() {
    var id = $("#clienteId").val();
    var nombre = $("#nombre").val();
    var documento = $("#documento").val();
    var email = $("#email").val();
    var telefono = $("#telefono").val();
    var direccion = $("#direccion").val();
    var ciudad = $("#ciudad").val();

    if (!nombre || !documento || !email) {
        alert("Complete los campos obligatorios");
        return;
    }

    $.post(ctx + "/controlador/clientes_controlador.jsp", {
        tipo: "guardar",
        id: id,
        nombre: nombre,
        documento: documento,
        email: email,
        telefono: telefono,
        direccion: direccion,
        ciudad: ciudad
    }, function (response) {
        if ((response || "").includes("documento_duplicado")) {
            $("#docError").text("Este documento ya existe");
        } else if ((response || "").includes("ok")) {
            var modal = bootstrap.Modal.getInstance(document.getElementById("modalCliente"));
            if (modal) modal.hide();
            alert((response || "").includes("insert") ? "Cliente creado correctamente" : "Cliente actualizado");
            cargarClientes();
        } else {
            alert("Error: " + response);
        }
    });
}

function eliminarCliente(id) {
    if (confirm("¿Estás seguro de eliminar este cliente?")) {
        $.post(ctx + "/controlador/clientes_controlador.jsp", { tipo: "eliminar", id: id }, function () {
            cargarClientes();
        });
    }
}
</script>

<%@include file="footer.jsp" %>
