<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;

    String tipo = request.getParameter("tipo");
    String fechaDesde = request.getParameter("fechaDesde");
    String fechaHasta = request.getParameter("fechaHasta");

    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_edgar",
            "postgres",
            "ctaticpy"
        );
        st = conn.createStatement();

        String filtroFecha = "";
        if (fechaDesde != null && !fechaDesde.isEmpty()) {
            filtroFecha += " AND v.fecha >= '" + fechaDesde + "' ";
        }
        if (fechaHasta != null && !fechaHasta.isEmpty()) {
            filtroFecha += " AND v.fecha <= '" + fechaHasta + "' ";
        }

        
        if ("ventas_detalladas".equals(tipo)) {
            String sql =
                "SELECT v.id, c.nombre AS cliente, v.fecha, v.estado, " +
                "a.codigo, a.descripcion, dv.precio, COALESCE(dv.iva, a.iva, 10) AS iva, " +
                "dv.cantidad, COALESCE(dv.subtotal, dv.precio * dv.cantidad) AS subtotal " +
                "FROM ventas v " +
                "JOIN clientes c ON v.idcliente = c.id " +
                "JOIN venta_detalle dv ON dv.idventa = v.id " +
                "JOIN articulos a ON a.id = dv.idarticulo " +
                "WHERE v.estado = 'FINALIZADO' " + filtroFecha +
                " ORDER BY v.id DESC, a.descripcion";

            out.print("<table class='table table-bordered table-striped table-sm'>");
            out.print("<thead class='table-dark'><tr>");
            out.print("<th>N° Venta</th><th>Cliente</th><th>Fecha</th><th>Código</th>");
            out.print("<th>Descripción</th><th>Precio</th><th>IVA</th><th>Cant.</th><th>Subtotal</th>");
            out.print("</tr></thead><tbody>");

            rs = st.executeQuery(sql);
            boolean hay = false;
            double total = 0;
            while (rs.next()) {
                hay = true;
                double sub = rs.getDouble("subtotal");
                total += sub;
                out.print("<tr>");
                out.print("<td>" + rs.getInt("id") + "</td>");
                out.print("<td>" + rs.getString("cliente") + "</td>");
                out.print("<td>" + rs.getString("fecha") + "</td>");
                out.print("<td>" + rs.getString("codigo") + "</td>");
                out.print("<td>" + rs.getString("descripcion") + "</td>");
                out.print("<td>" + String.format("%.0f", rs.getDouble("precio")) + "</td>");
                out.print("<td>" + String.format("%.0f", rs.getDouble("iva")) + "%</td>");
                out.print("<td>" + rs.getInt("cantidad") + "</td>");
                out.print("<td>" + String.format("%.0f", sub) + "</td>");
                out.print("</tr>");
            }
            if (!hay) {
                out.print("<tr><td colspan='9' class='text-center text-muted'>Sin registros</td></tr>");
            } else {
                out.print("<tr class='table-success'><td colspan='8' class='text-end'><strong>TOTAL</strong></td>");
                out.print("<td><strong>" + String.format("%.0f", total) + "</strong></td></tr>");
            }
            out.print("</tbody></table>");
        }

       
        else if ("ranking_clientes".equals(tipo)) {
            String sql =
                "SELECT c.nombre AS cliente, c.documento AS ruc, " +
                "COUNT(DISTINCT v.id) AS cantidad_ventas, " +
                "COALESCE(SUM(COALESCE(dv.subtotal, dv.precio * dv.cantidad)), 0) AS monto_total " +
                "FROM ventas v " +
                "JOIN clientes c ON v.idcliente = c.id " +
                "JOIN venta_detalle dv ON dv.idventa = v.id " +
                "WHERE v.estado = 'FINALIZADO' " + filtroFecha +
                " GROUP BY c.id, c.nombre, c.documento " +
                " ORDER BY monto_total DESC, cantidad_ventas DESC";

            out.print("<table class='table table-bordered table-striped table-sm'>");
            out.print("<thead class='table-dark'><tr>");
            out.print("<th>#</th><th>Cliente</th><th>RUC</th><th>Cant. ventas</th><th>Monto total</th>");
            out.print("</tr></thead><tbody>");

            rs = st.executeQuery(sql);
            int pos = 0;
            boolean hay = false;
            while (rs.next()) {
                hay = true;
                pos++;
                out.print("<tr>");
                out.print("<td><strong>" + pos + "</strong></td>");
                out.print("<td>" + rs.getString("cliente") + "</td>");
                out.print("<td>" + (rs.getString("ruc") != null ? rs.getString("ruc") : "-") + "</td>");
                out.print("<td>" + rs.getInt("cantidad_ventas") + "</td>");
                out.print("<td>" + String.format("%.0f", rs.getDouble("monto_total")) + "</td>");
                out.print("</tr>");
            }
            if (!hay) {
                out.print("<tr><td colspan='5' class='text-center text-muted'>Sin registros</td></tr>");
            }
            out.print("</tbody></table>");
        }

        else if ("ranking_productos".equals(tipo)) {
            String sql =
                "SELECT a.codigo, a.descripcion, " +
                "COALESCE(SUM(dv.cantidad), 0) AS cantidad_vendida, " +
                "COALESCE(SUM(COALESCE(dv.subtotal, dv.precio * dv.cantidad)), 0) AS monto_total " +
                "FROM venta_detalle dv " +
                "JOIN articulos a ON a.id = dv.idarticulo " +
                "JOIN ventas v ON v.id = dv.idventa " +
                "WHERE v.estado = 'FINALIZADO' " + filtroFecha +
                " GROUP BY a.id, a.codigo, a.descripcion " +
                " ORDER BY cantidad_vendida DESC, monto_total DESC";

            out.print("<table class='table table-bordered table-striped table-sm'>");
            out.print("<thead class='table-dark'><tr>");
            out.print("<th>#</th><th>Código</th><th>Descripción</th>");
            out.print("<th>Cant. vendida</th><th>Monto total</th>");
            out.print("</tr></thead><tbody>");

            rs = st.executeQuery(sql);
            int pos = 0;
            boolean hay = false;
            while (rs.next()) {
                hay = true;
                pos++;
                out.print("<tr>");
                out.print("<td><strong>" + pos + "</strong></td>");
                out.print("<td>" + rs.getString("codigo") + "</td>");
                out.print("<td>" + rs.getString("descripcion") + "</td>");
                out.print("<td>" + rs.getInt("cantidad_vendida") + "</td>");
                out.print("<td>" + String.format("%.0f", rs.getDouble("monto_total")) + "</td>");
                out.print("</tr>");
            }
            if (!hay) {
                out.print("<tr><td colspan='5' class='text-center text-muted'>Sin registros</td></tr>");
            }
            out.print("</tbody></table>");
        }

        else {
            out.print("<div class='alert alert-warning'>Tipo de informe no válido</div>");
        }

    } catch (Exception e) {
        out.print("<div class='alert alert-danger'><strong>Error:</strong> " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (st != null) try { st.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

