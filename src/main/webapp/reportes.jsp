<%@include file="header.jsp" %>
<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <h1 class="m-0">Informes</h1>
        </div>
    </div>
    <div class="content">
        <div class="container-fluid">
            
            <div class="card mb-3">
                <div class="card-header bg-dark text-white">
                    <strong>Filtros</strong>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label>Tipo de informe</label>
                            <select id="tipoInforme" class="form-control">
                                <option value="ventas_detalladas">Ventas detalladas</option>
                                <option value="ranking_clientes">Ranking de ventas por cliente</option>
                                <option value="ranking_productos">Ranking de productos</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label>Desde</label>
                            <input type="date" id="fechaDesde" class="form-control">
                        </div>
                        <div class="col-md-3">
                            <label>Hasta</label>
                            <input type="date" id="fechaHasta" class="form-control">
                        </div>
                        <div class="col-md-2 d-flex align-items-end">
                            <button class="btn btn-primary w-100" onclick="generarInforme()">Generar</button>
                        </div>
                    </div>
                </div>
            </div>

            
            <div class="row mb-3 g-2">
                <div class="col-md-4">
                    <button class="btn btn-outline-primary w-100" onclick="informeRapido('ventas_detalladas')">
                        Ventas detalladas
                    </button>
                </div>
                <div class="col-md-4">
                    <button class="btn btn-outline-success w-100" onclick="informeRapido('ranking_clientes')">
                        Ranking ventas por cliente
                    </button>
                </div>
                <div class="col-md-4">
                    <button class="btn btn-outline-warning w-100" onclick="informeRapido('ranking_productos')">
                        Ranking de productos
                    </button>
                </div>
            </div>

            
            <div class="card">
                <div class="card-header bg-secondary text-white d-flex justify-content-between align-items-center">
                    <strong id="tituloInforme">Seleccione un informe</strong>
                    <div>
                        <button class="btn btn-light btn-sm me-2" onclick="window.print()">Imprimir</button>
                        <a id="btnPdfInforme" href="#" target="_blank" class="btn btn-danger btn-sm" title="Ver PDF">
                            <i class="bi bi-eye"></i> PDF
                        </a>
                    </div>
                </div>
                <div class="card-body">
                    <div id="resultadoInforme" class="table-responsive">
                        <p class="text-muted">Use los filtros o los botones para generar un informe.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function informeRapido(tipo) {
    $("#tipoInforme").val(tipo);
    generarInforme();
}

function generarInforme() {
    var tipo = $("#tipoInforme").val();
    var desde = $("#fechaDesde").val() || "";
    var hasta = $("#fechaHasta").val() || "";

    var titulos = {
        ventas_detalladas: "Ventas detalladas",
        ranking_clientes: "Ranking de ventas por cliente",
        ranking_productos: "Ranking de productos"
    };
    $("#tituloInforme").text(titulos[tipo] || "Informe");

    
    var urlPdf = "controlador/generar_reporte.jsp?reporte=" + tipo +
                 "&tipo=global" +
                 "&fechaDesde=" + encodeURIComponent(desde) +
                 "&fechaHasta=" + encodeURIComponent(hasta);
    $("#btnPdfInforme").attr("href", urlPdf);

    $("#resultadoInforme").html("<div class='alert alert-info'>Generando informe...</div>");

    $.post("controlador/reportes_controlador.jsp", {
        tipo: tipo,
        fechaDesde: desde,
        fechaHasta: hasta
    }, function (html) {
        $("#resultadoInforme").html(html);
    }).fail(function () {
        $("#resultadoInforme").html("<div class='alert alert-danger'>Error al generar el informe</div>");
    });
}
</script>
<%@include file="footer.jsp" %>
