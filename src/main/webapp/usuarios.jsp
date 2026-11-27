<<%@include file="header.jsp" %>
<script src="<%=request.getContextPath()%>/assets/js/jquery-3.7.1.min.js"></script>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <h1 class="m-0">Usuarios</h1>
        </div>
    </div>
    <div class="content">
        <div class="container-fluid">
            <div class="card">
                <div class="card-header">
                    <button class="btn btn-success" onclick="nuevoUsuario()">Nuevo Usuario</button>
                </div>
                <div class="card-body table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Usuario</th>
                                <th>Nombre</th>
                                <th>Rol</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody id="tablaBodyUsuarios"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalUsuario" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="tituloUsuario">Usuario</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="usuarioId">
                <div class="mb-3">
                    <label>Usuario *</label>
                    <input type="text" id="username" class="form-control">
                    <small id="userError" class="text-danger"></small>
                </div>
                <div class="mb-3">
                    <label>Contraseña <span id="passHint">(obligatoria al crear)</span></label>
                    <input type="password" id="password" class="form-control">
                </div>
                <div class="mb-3">
                    <label>Nombre</label>
                    <input type="text" id="nombreUser" class="form-control">
                </div>
                <div class="mb-3">
                    <label>Rol</label>
                    <select id="rol" class="form-control">
                        <option value="admin">admin</option>
                        <option value="usuario">usuario</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" onclick="guardarUsuario()">Guardar</button>
            </div>
        </div>
    </div>
</div>

<script>
var ctx = "<%=request.getContextPath()%>";

$(document).ready(function () {
    cargarUsuarios();
});

function cargarUsuarios() {
    $.post(ctx + "/controlador/usuarios_controlador.jsp", { tipo: "listar" }, function (data) {
        $("#tablaBodyUsuarios").html(data);
    });
}

function nuevoUsuario() {
    $("#usuarioId").val("");
    $("#username").val("");
    $("#password").val("");
    $("#nombreUser").val("");
    $("#rol").val("usuario");
    $("#userError").text("");
    $("#passHint").text("(obligatoria al crear)");
    $("#tituloUsuario").text("Nuevo Usuario");
    new bootstrap.Modal(document.getElementById("modalUsuario")).show();
}

function editarUsuario(id) {
    $.post(ctx + "/controlador/usuarios_controlador.jsp", { tipo: "obtener", id: id }, function (data) {
        var p = (data || "").split("|");
        $("#usuarioId").val(p[0] || "");
        $("#username").val(p[1] || "");
        $("#password").val("");
        $("#nombreUser").val(p[2] || "");
        $("#rol").val(p[3] || "usuario");
        $("#userError").text("");
        $("#passHint").text("(dejar vacío para no cambiar)");
        $("#tituloUsuario").text("Editar Usuario");
        new bootstrap.Modal(document.getElementById("modalUsuario")).show();
    });
}

function guardarUsuario() {
    var id = $("#usuarioId").val();
    var username = $("#username").val().trim();
    var password = $("#password").val();
    var nombre = $("#nombreUser").val();
    var rol = $("#rol").val();

    if (!username) {
        alert("El usuario es obligatorio");
        return;
    }
    if (!id && !password) {
        alert("La contraseña es obligatoria al crear");
        return;
    }

    $.post(ctx + "/controlador/usuarios_controlador.jsp", {
        tipo: "guardar",
        id: id,
        username: username,
        password: password,
        nombre: nombre,
        rol: rol
    }, function (response) {
        if ((response || "").includes("usuario_duplicado")) {
            $("#userError").text("Este usuario ya existe");
        } else if ((response || "").includes("ok")) {
            var m = bootstrap.Modal.getInstance(document.getElementById("modalUsuario"));
            if (m) m.hide();
            alert((response || "").includes("insert") ? "Usuario creado" : "Usuario actualizado");
            cargarUsuarios();
        } else {
            alert("Error: " + response);
        }
    });
}

function eliminarUsuario(id) {
    if (confirm("¿Eliminar este usuario?")) {
        $.post(ctx + "/controlador/usuarios_controlador.jsp", { tipo: "eliminar", id: id }, function () {
            cargarUsuarios();
        });
    }
}
</script>
<%@include file="footer.jsp" %>
