<%@include file="header.jsp" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Date fechaActual = new Date();
    SimpleDateFormat formateador = new SimpleDateFormat("yyyy-MM-dd");
    String fechaHoy = formateador.format(fechaActual);
%>
<script src="<%=request.getContextPath()%>/assets/js/jquery-3.7.1.min.js"></script>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <h1 class="m-0">Tareas / Recordatorios</h1>
            <p class="text-muted">Agenda de pendientes y recordatorios del equipo comercial</p>
        </div>
    </div>

    <div class="content">
        <div class="container-fluid">

            <div class="mb-3 d-flex flex-wrap gap-2">
                <button type="button" class="btn btn-success" onclick="nuevaTarea()">
                    Nueva Tarea
                </button>
                <button type="button" class="btn btn-outline-primary" onclick="cargarTareas('todos')">Todas</button>
                <button type="button" class="btn btn-outline-warning" onclick="cargarTareas('pendientes')">Pendientes</button>
                <button type="button" class="btn btn-outline-info" onclick="cargarTareas('hoy')">Vencen hoy</button>
                <button type="button" class="btn btn-outline-danger" onclick="cargarTareas('vencidas')">Vencidas</button>
            </div>

            <div class="card">
                <div class="card-header bg-dark text-white">
                    <strong>Listado de tareas</strong>
                </div>
                <div class="card-body table-responsive">
                    <table class="table table-bordered table-striped table-sm">
                        <thead class="table-dark">
                            <tr>
                                <th>ID</th>
                                <th>Título</th>
                                <th>Cliente</th>
                                <th>Vencimiento</th>
                                <th>Prioridad</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody id="tablaBodyTareas">
                            <tr><td colspan="7" class="text-center text-muted">Cargando...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</div>


<div class="modal fade" id="modalTarea" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title" id="tituloModalTarea">Nueva Tarea</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="tareaId" value="0">
                <div class="row g-3">
                    <div class="col-md-8">
                        <label class="form-label">Título *</label>
                        <input type="text" id="titulo" class="form-control" maxlength="200"
                               placeholder="Ej: Llamar a cliente para confirmar pedido">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Prioridad</label>
                        <select id="prioridad" class="form-control">
                            <option value="BAJA">BAJA</option>
                            <option value="MEDIA" selected>MEDIA</option>
                            <option value="ALTA">ALTA</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Cliente (opcional)</label>
                        <select id="idcliente" class="form-control"></select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Fecha vencimiento</label>
                        <input type="date" id="fecha_vencimiento" class="form-control" value="<%= fechaHoy %>">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Estado</label>
                        <select id="estado" class="form-control">
                            <option value="PENDIENTE">PENDIENTE</option>
                            <option value="REALIZADO">REALIZADO</option>
                            <option value="CANCELADO">CANCELADO</option>
                        </select>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label">Descripción / notas</label>
                        <textarea id="descripcion" class="form-control" rows="3"
                                  placeholder="Detalle de la tarea..."></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                <button type="button" class="btn btn-primary" onclick="guardarTarea()">Guardar</button>
            </div>
        </div>
    </div>
</div>

<script>
var ctx = "<%=request.getContextPath()%>";
var filtroActual = "pendientes";

$(document).ready(function () {
    cargarClientesSelect();
    cargarTareas("pendientes");
});

function cargarClientesSelect() {
    $.post(ctx + "/controlador/tareas_controlador.jsp", { tipo: "listarclientes" }, function (data) {
        $("#idcliente").html(data);
    });
}

function cargarTareas(filtro) {
    filtroActual = filtro || "todos";
    $.post(ctx + "/controlador/tareas_controlador.jsp", {
        tipo: "listar",
        filtro: filtroActual
    }, function (data) {
        $("#tablaBodyTareas").html(data || "<tr><td colspan='7' class='text-center'>Sin tareas</td></tr>");
    });
}

function nuevaTarea() {
    $("#tituloModalTarea").text("Nueva Tarea");
    $("#tareaId").val("0");
    $("#titulo").val("");
    $("#descripcion").val("");
    $("#fecha_vencimiento").val("<%= fechaHoy %>");
    $("#idcliente").val("");
    $("#prioridad").val("MEDIA");
    $("#estado").val("PENDIENTE");
    $("#modalTarea").modal("show");
}

function editarTarea(id) {
    $.post(ctx + "/controlador/tareas_controlador.jsp", { tipo: "obtener", id: id }, function (resp) {
        var p = (resp || "").trim().split("|");
        if (p.length < 7) {
            alert("No se pudo cargar la tarea");
            return;
        }
        $("#tituloModalTarea").text("Editar Tarea");
        $("#tareaId").val(p[0]);
        $("#titulo").val(p[1]);
        $("#descripcion").val(p[2]);
        $("#fecha_vencimiento").val(p[3] || "");
        $("#idcliente").val(p[4] || "");
        $("#prioridad").val(p[5] || "MEDIA");
        $("#estado").val(p[6] || "PENDIENTE");
        $("#modalTarea").modal("show");
    });
}

function guardarTarea() {
    var titulo = $("#titulo").val().trim();
    if (!titulo) {
        alert("El título es obligatorio");
        return;
    }
    $.post(ctx + "/controlador/tareas_controlador.jsp", {
        tipo: "guardar",
        id: $("#tareaId").val(),
        titulo: titulo,
        descripcion: $("#descripcion").val(),
        fecha_vencimiento: $("#fecha_vencimiento").val(),
        idcliente: $("#idcliente").val(),
        prioridad: $("#prioridad").val(),
        estado: $("#estado").val()
    }, function (response) {
        response = (response || "").trim();
        if (response.indexOf("ok") === 0) {
            $("#modalTarea").modal("hide");
            alert(response.indexOf("insert") >= 0 ? "Tarea creada" : "Tarea actualizada");
            cargarTareas(filtroActual);
        } else {
            alert("Error: " + response);
        }
    });
}

function eliminarTarea(id) {
    if (!confirm("¿Eliminar esta tarea?")) return;
    $.post(ctx + "/controlador/tareas_controlador.jsp", { tipo: "eliminar", id: id }, function () {
        cargarTareas(filtroActual);
    });
}

function marcarHecha(id) {
    $.post(ctx + "/controlador/tareas_controlador.jsp", { tipo: "realizar", id: id }, function () {
        cargarTareas(filtroActual);
    });
}
</script>
<script src="<%=request.getContextPath()%>/assets/js/bootstrap.bundle.min.js"></script>
<%@include file="footer.jsp" %>

