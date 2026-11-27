<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");

    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;
    PreparedStatement ps = null;

    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_edgar",
            "postgres",
            "ctaticpy"   
        );
        st = conn.createStatement();
        String tipo = request.getParameter("tipo");

        if ("listarproveedores".equals(tipo)) {
            rs = st.executeQuery(
                "SELECT id, nombre, ruc FROM proveedores WHERE estado = true ORDER BY nombre"
            );
            out.print("<option value=''>Seleccionar Proveedor</option>");
            while (rs.next()) {
                out.print("<option value='" + rs.getInt(1) + "," + rs.getString(3) + "'>"
                        + rs.getString(2) + "</option>");
            }
        }
        else if ("listararticulos".equals(tipo)) {
            rs = st.executeQuery(
                "SELECT id, descripcion, precio FROM articulos WHERE estado = true ORDER BY descripcion"
            );
            out.print("<option value=''>Seleccionar Artículo</option>");
            while (rs.next()) {
                out.print("<option value='" + rs.getInt(1) + "," + rs.getDouble(3) + "'>"
                        + rs.getString(2) + "</option>");
            }
        }
        else if ("cargar".equals(tipo)) {
            int codproveedor = Integer.parseInt(request.getParameter("codproveedor"));
            int codproducto = Integer.parseInt(request.getParameter("codproducto"));
            double precio = Double.parseDouble(request.getParameter("precio"));
            int cantidad = Integer.parseInt(request.getParameter("cantidad"));

            conn.setAutoCommit(false);
            try {
                int idcompra = 0;
                rs = st.executeQuery(
                    "SELECT id FROM compras WHERE idproveedor = " + codproveedor +
                    " AND estado = 'PENDIENTE' ORDER BY id DESC LIMIT 1"
                );
                if (rs.next()) {
                    idcompra = rs.getInt(1);
                }
                rs.close();

                if (idcompra == 0) {
                    ps = conn.prepareStatement(
                        "INSERT INTO compras(idproveedor, fecha, estado) VALUES (?, CURRENT_DATE, 'PENDIENTE') RETURNING id"
                    );
                    ps.setInt(1, codproveedor);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        idcompra = rs.getInt(1);
                    }
                    rs.close();
                    ps.close();
                }

                ps = conn.prepareStatement(
                    "INSERT INTO compra_detalle(idcompra, idarticulo, precio, cantidad) VALUES (?, ?, ?, ?)"
                );
                ps.setInt(1, idcompra);
                ps.setInt(2, codproducto);
                ps.setDouble(3, precio);
                ps.setInt(4, cantidad);
                ps.executeUpdate();
                ps.close();

                conn.commit();
                out.print("<div class='alert alert-success'>Producto agregado a la compra</div>");
            } catch (Exception e) {
                try { conn.rollback(); } catch (Exception ex) {}
                out.print("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
            } finally {
                try { conn.setAutoCommit(true); } catch (Exception ex) {}
            }
        }
        else if ("rellenardetalle".equals(tipo)) {
            rs = st.executeQuery(
                "SELECT cd.id, a.descripcion, cd.precio, cd.cantidad, (cd.precio*cd.cantidad) as total " +
                "FROM compra_detalle cd " +
                "JOIN articulos a ON cd.idarticulo = a.id " +
                "JOIN compras c ON cd.idcompra = c.id " +
                "WHERE c.estado = 'PENDIENTE'"
            );
            while (rs.next()) {
                out.print("<tr>");
                out.print("<td><button class='btn btn-danger btn-sm' onclick='eliminarDetalleCompra("
                        + rs.getInt(1) + ")'>Eliminar</button></td>");
                out.print("<td>" + rs.getString(2) + "</td>");
                out.print("<td>" + rs.getDouble(3) + "</td>");
                out.print("<td>" + rs.getInt(4) + "</td>");
                out.print("<td>" + rs.getDouble(5) + "</td>");
                out.print("</tr>");
            }
        }
        else if ("eliminardetalle".equals(tipo)) {
            int iddetalle = Integer.parseInt(request.getParameter("iddetalle"));
            st.executeUpdate("DELETE FROM compra_detalle WHERE id = " + iddetalle);
            out.print("ok");
        }
        else if ("finalizar".equals(tipo)) {
            conn.setAutoCommit(false);
            try {
                st.executeUpdate("UPDATE compras SET estado = 'FINALIZADO' WHERE estado = 'PENDIENTE'");
                conn.commit();
                out.print("Compra finalizada correctamente");
            } catch (Exception e) {
                try { conn.rollback(); } catch (Exception ex) {}
                out.print("error: " + e.getMessage());
            } finally {
                try { conn.setAutoCommit(true); } catch (Exception ex) {}
            }
        }
        else if ("cancelar".equals(tipo)) {
            conn.setAutoCommit(false);
            try {
                st.executeUpdate("UPDATE compras SET estado = 'CANCELADO' WHERE estado = 'PENDIENTE'");
                conn.commit();
                out.print("Compra cancelada");
            } catch (Exception e) {
                try { conn.rollback(); } catch (Exception ex) {}
                out.print("error: " + e.getMessage());
            } finally {
                try { conn.setAutoCommit(true); } catch (Exception ex) {}
            }
        }

    } catch (Exception e) {
        out.print("error: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (st != null) try { st.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
