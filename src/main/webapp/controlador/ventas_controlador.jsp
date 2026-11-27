<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");

    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;
    PreparedStatement ps = null;
    String tipo = request.getParameter("tipo");

    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_edgar",
            "postgres",
            "ctaticpy"
        );
        st = conn.createStatement();

        
        if ("listarcliente".equals(tipo) || "listarclientes".equals(tipo)) {
            rs = st.executeQuery(
                "SELECT id, nombre, documento FROM clientes WHERE estado = true ORDER BY nombre"
            );
            out.print("<option value=''>Seleccionar Cliente</option>");
            while (rs.next()) {
                out.print("<option value='" + rs.getInt("id") + "|" + rs.getString("documento") + "'>"
                        + rs.getString("nombre") + "</option>");
            }
        }

        
        else if ("listararticulos".equals(tipo) || "listararticulo".equals(tipo)) {
            rs = st.executeQuery(
                "SELECT id, codigo, descripcion, precio, COALESCE(iva, 10) AS iva " +
                "FROM articulos WHERE estado = true ORDER BY descripcion"
            );
            out.print("<option value=''>Seleccionar Artículo</option>");
            while (rs.next()) {
                out.print("<option value='" + rs.getInt("id")
                        + "|" + rs.getDouble("precio")
                        + "|" + rs.getDouble("iva")
                        + "|" + rs.getString("codigo")
                        + "|" + rs.getString("descripcion") + "'>"
                        + rs.getString("codigo") + " - " + rs.getString("descripcion")
                        + "</option>");
            }
        }

        
        else if ("cargar".equals(tipo)) {
            String idcliente = request.getParameter("idcliente");
            if (idcliente == null || idcliente.isEmpty()) {
                idcliente = request.getParameter("codcliente");
            }
            String idarticulo = request.getParameter("idarticulo");
            if (idarticulo == null || idarticulo.isEmpty()) {
                idarticulo = request.getParameter("codproducto");
            }
            String cantidad = request.getParameter("cantidad");
            String precio = request.getParameter("precio");
            String ivaStr = request.getParameter("iva");
            String idventa = request.getParameter("idventa");

            conn.setAutoCommit(false);
            try {
                int ventaId = 0;
                double prec = Double.parseDouble(precio);
                double iva = (ivaStr != null && !ivaStr.isEmpty()) ? Double.parseDouble(ivaStr) : 10;
                int cant = Integer.parseInt(cantidad != null ? cantidad : "1");
                double subtotal = prec * cant;

                if (idventa == null || idventa.isEmpty() || "0".equals(idventa)) {
                    
                    rs = st.executeQuery(
                        "SELECT id FROM ventas WHERE idcliente = " + Integer.parseInt(idcliente) +
                        " AND estado = 'PENDIENTE' ORDER BY id DESC LIMIT 1"
                    );
                    if (rs.next()) {
                        ventaId = rs.getInt(1);
                    }
                    rs.close();

                    if (ventaId == 0) {
                        ps = conn.prepareStatement(
                            "INSERT INTO ventas (idcliente, fecha, estado) VALUES (?, CURRENT_DATE, 'PENDIENTE') RETURNING id"
                        );
                        ps.setInt(1, Integer.parseInt(idcliente));
                        rs = ps.executeQuery();
                        if (rs.next()) {
                            ventaId = rs.getInt("id");
                        }
                        rs.close();
                        ps.close();
                    }
                } else {
                    ventaId = Integer.parseInt(idventa);
                }

                try {
                    ps = conn.prepareStatement(
                        "INSERT INTO venta_detalle (idventa, idarticulo, precio, cantidad, iva, subtotal) " +
                        "VALUES (?, ?, ?, ?, ?, ?)"
                    );
                    ps.setInt(1, ventaId);
                    ps.setInt(2, Integer.parseInt(idarticulo));
                    ps.setDouble(3, prec);
                    ps.setInt(4, cant);
                    ps.setDouble(5, iva);
                    ps.setDouble(6, subtotal);
                    ps.executeUpdate();
                    ps.close();
                } catch (Exception ex) {
                    ps = conn.prepareStatement(
                        "INSERT INTO venta_detalle (idventa, idarticulo, precio, cantidad) VALUES (?, ?, ?, ?)"
                    );
                    ps.setInt(1, ventaId);
                    ps.setInt(2, Integer.parseInt(idarticulo));
                    ps.setDouble(3, prec);
                    ps.setInt(4, cant);
                    ps.executeUpdate();
                    ps.close();
                }

                conn.commit();
                out.print("OK|" + ventaId);

            } catch (Exception e) {
                try { conn.rollback(); } catch (Exception ex) {}
                out.print("ERROR: " + e.getMessage());
            } finally {
                try { conn.setAutoCommit(true); } catch (Exception ex) {}
            }
        }

        
        else if ("rellenardetalle".equals(tipo)) {
            String idventa = request.getParameter("idventa");
            if (idventa == null || idventa.isEmpty() || "0".equals(idventa)) {
                out.print("");
                return;
            }

            rs = st.executeQuery(
                "SELECT dv.id, a.codigo, a.descripcion, dv.precio, " +
                "COALESCE(dv.iva, a.iva, 10) AS iva, dv.cantidad, " +
                "COALESCE(dv.subtotal, dv.precio * dv.cantidad) AS subtotal " +
                "FROM venta_detalle dv " +
                "JOIN articulos a ON dv.idarticulo = a.id " +
                "WHERE dv.idventa = " + idventa
            );

            double t0 = 0, t5 = 0, t10 = 0, total = 0;
            while (rs.next()) {
                double sub = rs.getDouble("subtotal");
                double iv = rs.getDouble("iva");
                total += sub;
                if (iv == 0) t0 += sub;
                else if (iv == 5) t5 += sub;
                else t10 += sub;

                out.print("<tr>");
                out.print("<td><button class='btn btn-danger btn-sm' onclick='eliminarDetalle("
                        + rs.getInt("id") + ")'>X</button></td>");
                out.print("<td>" + rs.getString("codigo") + "</td>");
                out.print("<td>" + rs.getString("descripcion") + "</td>");
                out.print("<td>" + String.format("%.0f", rs.getDouble("precio")) + "</td>");
                out.print("<td>" + String.format("%.0f", iv) + "%</td>");
                out.print("<td>" + rs.getInt("cantidad") + "</td>");
                out.print("<td>" + String.format("%.0f", sub) + "</td>");
                out.print("</tr>");
            }
            out.print("|TOTAL|" + String.format("%.0f", t0) + "|" + String.format("%.0f", t5)
                    + "|" + String.format("%.0f", t10) + "|" + String.format("%.0f", total));
        }

        
        else if ("eliminardetalle".equals(tipo)) {
            String id = request.getParameter("id");
            if (id == null) id = request.getParameter("iddetalle");
            st.executeUpdate("DELETE FROM venta_detalle WHERE id = " + id);
            out.print("OK");
        }

        
        else if ("finalizar".equals(tipo)) {
            String idventa = request.getParameter("idventa");
            conn.setAutoCommit(false);
            try {
                if (idventa != null && !idventa.isEmpty() && !"0".equals(idventa)) {
                    st.executeUpdate("UPDATE ventas SET estado = 'FINALIZADO' WHERE id = " + idventa);
                } else {
                    st.executeUpdate("UPDATE ventas SET estado = 'FINALIZADO' WHERE estado = 'PENDIENTE'");
                }
                conn.commit();
                out.print("Venta finalizada correctamente");
            } catch (Exception e) {
                try { conn.rollback(); } catch (Exception ex) {}
                out.print("ERROR: " + e.getMessage());
            } finally {
                try { conn.setAutoCommit(true); } catch (Exception ex) {}
            }
        }

        
        else if ("cancelar".equals(tipo) || "anular".equals(tipo)) {
            String idventa = request.getParameter("idventa");
            conn.setAutoCommit(false);
            try {
                if (idventa != null && !idventa.isEmpty() && !"0".equals(idventa)) {
                    st.executeUpdate("UPDATE ventas SET estado = 'CANCELADO' WHERE id = " + idventa);
                } else {
                    st.executeUpdate("UPDATE ventas SET estado = 'CANCELADO' WHERE estado = 'PENDIENTE'");
                }
                conn.commit();
                if ("anular".equals(tipo)) {
                    out.print("Venta anulada correctamente");
                } else {
                    out.print("Venta cancelada correctamente");
                }
            } catch (Exception e) {
                try { conn.rollback(); } catch (Exception ex) {}
                out.print("ERROR: " + e.getMessage());
            } finally {
                try { conn.setAutoCommit(true); } catch (Exception ex) {}
            }
        }

        
        else if ("listarfinalizadas".equals(tipo)) {
            rs = st.executeQuery(
                "SELECT v.id, c.nombre, v.fecha, v.estado " +
                "FROM ventas v " +
                "JOIN clientes c ON v.idcliente = c.id " +
                "WHERE v.estado = 'FINALIZADO' " +
                "ORDER BY v.id DESC"
            );
            while (rs.next()) {
                int idVenta = rs.getInt("id");
                out.print("<tr>");
                out.print("<td>" + idVenta + "</td>");
                out.print("<td>" + rs.getString("nombre") + "</td>");
                out.print("<td>" + rs.getString("fecha") + "</td>");
                out.print("<td><span class='badge bg-success'>" + rs.getString("estado") + "</span></td>");
                out.print("<td>");
                out.print("<button class='btn btn-danger btn-sm' onclick='anularVenta(" + idVenta + ")'>Anular</button> ");
                out.print("<a href='" + request.getContextPath()
                        + "/controlador/generar_reporte.jsp?reporte=ventas&tipo=individual&id=" + idVenta
                        + "' target='_blank' class='btn btn-info btn-sm' title='Ver PDF'><i class='bi bi-eye'></i></a>");
                out.print("</td>");
                out.print("</tr>");

                
                Statement st2 = conn.createStatement();
                ResultSet rsDet = st2.executeQuery(
                    "SELECT a.codigo, a.descripcion, dv.precio, " +
                    "COALESCE(dv.iva, a.iva, 10) AS iva, dv.cantidad, " +
                    "COALESCE(dv.subtotal, dv.precio * dv.cantidad) AS subtotal " +
                    "FROM venta_detalle dv " +
                    "JOIN articulos a ON dv.idarticulo = a.id " +
                    "WHERE dv.idventa = " + idVenta
                );
                out.print("<tr><td colspan='5'>");
                out.print("<table class='table table-sm table-bordered mb-0'>");
                out.print("<thead><tr><th>Código</th><th>Descripción</th><th>Precio</th><th>IVA</th><th>Cant</th><th>Subtotal</th></tr></thead><tbody>");
                double totalVenta = 0;
                while (rsDet.next()) {
                    double sub = rsDet.getDouble("subtotal");
                    totalVenta += sub;
                    out.print("<tr>");
                    out.print("<td>" + rsDet.getString("codigo") + "</td>");
                    out.print("<td>" + rsDet.getString("descripcion") + "</td>");
                    out.print("<td>" + String.format("%.0f", rsDet.getDouble("precio")) + "</td>");
                    out.print("<td>" + String.format("%.0f", rsDet.getDouble("iva")) + "%</td>");
                    out.print("<td>" + rsDet.getInt("cantidad") + "</td>");
                    out.print("<td>" + String.format("%.0f", sub) + "</td>");
                    out.print("</tr>");
                }
                out.print("<tr><td colspan='5' class='text-end'><strong>Total:</strong></td>");
                out.print("<td><strong>" + String.format("%.0f", totalVenta) + "</strong></td></tr>");
                out.print("</tbody></table></td></tr>");
                rsDet.close();
                st2.close();
            }
        }

        
        else if ("listaranuladas".equals(tipo)) {
            rs = st.executeQuery(
                "SELECT v.id, c.nombre, v.fecha, v.estado " +
                "FROM ventas v " +
                "JOIN clientes c ON v.idcliente = c.id " +
                "WHERE v.estado = 'CANCELADO' " +
                "ORDER BY v.id DESC"
            );
            while (rs.next()) {
                out.print("<tr>");
                out.print("<td>" + rs.getInt("id") + "</td>");
                out.print("<td>" + rs.getString("nombre") + "</td>");
                out.print("<td>" + rs.getString("fecha") + "</td>");
                out.print("<td><span class='badge bg-danger'>" + rs.getString("estado") + "</span></td>");
                out.print("</tr>");
            }
        }

        else {
            out.print("Tipo no reconocido: " + tipo);
        }

    } catch (Exception e) {
        out.print("ERROR: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (st != null) try { st.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

