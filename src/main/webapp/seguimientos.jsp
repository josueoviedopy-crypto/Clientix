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
            <h1 class="m-0">Seguimiento de Clientes</h1>
        </div>
    </div>

    <div class="content">
        <div class="container-fluid">

            
            <div class="mb-3">
                <button type="button" class="btn btn-success" onclick="nuevoSeguimiento()">
                    <i class="bi bi-plus-circle"></i> Nuevo Seguimiento
                </button>
                <button type="button" class="btn btn-outline-primary" onclick="cargarSeguimientos()">
                    Todos
                </button>
                <button type="button" class="btn btn-outline-warning" onclick="cargarPendientes()">
                    Pendientes / Próximos 7 días
                </button>
            </div>

            
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <strong>Listado de seguimientos</strong>
                </div>
                <div class="card-body table-responsive">
                    <table class="table table-bordered table-striped table-sm">
                        <thead class="table-dark">
                            <tr>
                                <th>ID</th>
                                <th>Cliente</th>
                                <th>Fecha</th>
                                <th>Tipo</th>
                                <th>Descripción</th>
                                <th>Próximo contacto</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody id="tablaBodySeguimientos">
                            <tr><td colspan="8" class="text-center text-muted">Cargando...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</div>


<div class="modal fade" id="modalSeguimiento" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="tituloModal">Nuevo Seguimiento</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="segId" value="0">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Cliente *</label>
                        <select id="idcliente" class="form-control"></select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Fecha *</label>
                        <input type="date" id="fecha" class="form-control" value="<%= fechaHoy %>">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Tipo *</label>
                        <select id="tipo_seg" class="form-control">
                            <option value="Llamada">Llamada</option>
                            <option value="Visita">Visita</option>
                            <option value="WhatsApp">WhatsApp</option>
                            <option value="Email">Email</option>
                            <option value="Reunion">Reunión</option>
                            <option value="Otro">Otro</option>
                        </select>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label">Descripción / Resultado</label>
                        <textarea id="descripcion" class="form-control" rows="3"
                                  placeholder="Ej: Cliente interesado en pedido semanal..."></textarea>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Próximo contacto</label>
                        <input type="date" id="proximo_contacto" class="form-control">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Estado</label>
                        <select id="estado" class="form-control">
                            <option value="PENDIENTE">PENDIENTE</option>
                            <option value="REALIZADO">REALIZADO</option>
                            <option value="CANCELADO">CANCELADO</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                <button type="button" class="btn btn-primary" onclick="guardarSeguimiento()">Guardar</button>
            </div>
        </div>
    </div>
</div>

<script>
var ctx = "<%=request.getContextPath()%>";

$(document).ready(function () {
    cargarClientesSelect();
    cargarSeguimientos();
});

function cargarClientesSelect() {
    $.post(ctx + "/controlador/seguimientos_controlador.jsp", { tipo: "listarclientes" }, function (data) {
        $("#idcliente").html(data);
    });
}

function cargarSeguimientos() {
    $.post(ctx + "/controlador/seguimientos_controlador.jsp", { tipo: "listar" }, function (data) {
        $("#tablaBodySeguimientos").html(data || "<tr><td colspan='8' class='text-center'>Sin registros</td></tr>");
    });
}

function cargarPendientes() {
    $.post(ctx + "/controlador/seguimientos_controlador.jsp", { tipo: "pendientes" }, function (data) {
        $("#tablaBodySeguimientos").html(data || "<tr><td colspan='8' class='text-center'>No hay pendientes</td></tr>");
    });
}

function nuevoSeguimiento() {
    $("#tituloModal").text("Nuevo Seguimiento");
    $("#segId").val("0");
    $("#idcliente").val("");
    $("#fecha").val("<%= fechaHoy %>");
    $("#tipo_seg").val("Llamada");
    $("#descripcion").val("");
    $("#proximo_contacto").val("");
    $("#estado").val("PENDIENTE");
    $("#modalSeguimiento").modal("show");
}

function editarSeguimiento(id) {
    $.post(ctx + "/controlador/seguimientos_controlador.jsp", { tipo: "obtener", id: id }, function (resp) {
        var p = (resp || "").trim().split("|");
        if (p.length < 7) {
            alert("No se pudo cargar el seguimiento");
            return;
        }
        $("#tituloModal").text("Editar Seguimiento");
        $("#segId").val(p[0]);
        $("#idcliente").val(p[1]);
        $("#fecha").val(p[2]);
        $("#tipo_seg").val(p[3]);
        $("#descripcion").val(p[4]);
        $("#proximo_contacto").val(p[5] || "");
        $("#estado").val(p[6] || "PENDIENTE");
        $("#modalSeguimiento").modal("show");
    });
}

function guardarSeguimiento() {
    var idcliente = $("#idcliente").val();
    var fecha = $("#fecha").val();
    var tipo_seg = $("#tipo_seg").val();
    if (!idcliente) { alert("Seleccione un cliente"); return; }
    if (!fecha) { alert("Indique la fecha"); return; }
    if (!tipo_seg) { alert("Seleccione el tipo"); return; }

    $.post(ctx + "/controlador/seguimientos_controlador.jsp", {
        tipo: "guardar",
        id: $("#segId").val(),
        idcliente: idcliente,
        fecha: fecha,
        tipo_seg: tipo_seg,
        descripcion: $("#descripcion").val(),
        proximo_contacto: $("#proximo_contacto").val(),
        estado: $("#estado").val()
    }, function (response) {
        response = (response || "").trim();
        if (response.indexOf("ok") === 0) {
            $("#modalSeguimiento").modal("hide");
            alert(response.indexOf("insert") >= 0 ? "Seguimiento creado" : "Seguimiento actualizado");
            cargarSeguimientos();
        } else {
            alert("Error: " + response);
        }
    });
}

function eliminarSeguimiento(id) {
    if (!confirm("¿Eliminar este seguimiento?")) return;
    $.post(ctx + "/controlador/seguimientos_controlador.jsp", { tipo: "eliminar", id: id }, function () {
        cargarSeguimientos();
    });
}

function marcarRealizado(id) {
    $.post(ctx + "/controlador/seguimientos_controlador.jsp", { tipo: "realizar", id: id }, function () {
        cargarPendientes();
    });
}
</script>
<script src="<%=request.getContextPath()%>/assets/js/bootstrap.bundle.min.js"></script>
<%@include file="footer.jsp" %>

