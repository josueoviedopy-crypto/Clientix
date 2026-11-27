<%@page import="java.sql.*, java.io.*, java.util.*, net.sf.jasperreports.engine.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String reporte = request.getParameter("reporte");
    String tipo = request.getParameter("tipo");
    String id = request.getParameter("id");
    String fechaDesde = request.getParameter("fechaDesde");
    String fechaHasta = request.getParameter("fechaHasta");

    if (reporte == null) reporte = "clientes";
    if (tipo == null) tipo = "global";
    if (fechaDesde == null) fechaDesde = "";
    if (fechaHasta == null) fechaHasta = "";

    Connection conn = null;
    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_edgar",
            "postgres",
            "ctaticpy"
        );

        String nombreArchivo = reporte;
        if ("individual".equals(tipo)) {
            nombreArchivo = reporte + "_individual";
        }

        String path = application.getRealPath("/reportes/" + nombreArchivo + ".jrxml");
        java.io.File f = new java.io.File(path);
        if (!f.exists()) {
            out.print("<h3 style='color:red'>No se encontró el archivo del reporte:</h3>");
            out.print("<p>" + path + "</p>");
            out.print("<p>Verifica que el .jrxml esté en src/main/webapp/reportes/</p>");
            return;
        }

        Map<String, Object> parametros = new HashMap<>();

      
        if ("individual".equals(tipo)) {
            if (id == null || id.trim().isEmpty()) {
                out.print("<h3 style='color:red'>Falta el parámetro ID</h3>");
                return;
            }
            parametros.put("ID", Integer.parseInt(id));
        }

        
        parametros.put("FECHA_DESDE", fechaDesde);
        parametros.put("FECHA_HASTA", fechaHasta);

        JasperReport jasperReport = JasperCompileManager.compileReport(path);
        JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parametros, conn);

        if (jasperPrint.getPages() == null || jasperPrint.getPages().isEmpty()) {
            response.setContentType("text/html;charset=UTF-8");
            out.print("<h3 style='color:red'>El reporte no devolvió datos</h3>");
            out.print("<p>Reporte: " + reporte + "</p>");
            out.print("<p>Desde: " + fechaDesde + " | Hasta: " + fechaHasta + "</p>");
            if (id != null) out.print("<p>ID: " + id + "</p>");
            return;
        }

        response.setContentType("application/pdf");
        String nombrePDF = reporte + ("individual".equals(tipo) ? "_id" + id : "_global") + ".pdf";
        response.setHeader("Content-Disposition", "inline; filename=" + nombrePDF);

        OutputStream outStream = response.getOutputStream();
        JasperExportManager.exportReportToPdfStream(jasperPrint, outStream);
        outStream.flush();
        outStream.close();

    } catch (Exception e) {
        response.setContentType("text/html;charset=UTF-8");
        out.print("<h3 style='color:red'>Error al generar el reporte</h3>");
        out.print("<pre style='background:#f8f8f8;padding:15px;border:1px solid #ccc;'>");
        out.print(e.getMessage());
        out.print("\n\n");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.print("</pre>");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
