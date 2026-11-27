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

        
        if ("listar".equals(tipo)) {
            String idcliente = request.getParameter("idcliente");
            String sql =
                "SELECT s.id, c.nombre AS cliente, s.fecha, s.tipo, s.descripcion, " +
                "s.proximo_contacto, s.estado, s.idcliente " +
                "FROM seguimientos s " +
                "JOIN clientes c ON s.idcliente = c.id ";
            if (idcliente != null && !idcliente.isEmpty() && !"0".equals(idcliente)) {
                sql += "WHERE s.idcliente = " + Integer.parseInt(idcliente) + " ";
            }
            sql += "ORDER BY s.fecha DESC, s.id DESC";

            rs = st.executeQuery(sql);
            while (rs.next()) {
                out.print("<tr>");
                out.print("<td>" + rs.getInt("id") + "</td>");
                out.print("<td>" + rs.getString("cliente") + "</td>");
                out.print("<td>" + rs.getDate("fecha") + "</td>");
                out.print("<td>" + rs.getString("tipo") + "</td>");
                String desc = rs.getString("descripcion");
                out.print("<td>" + (desc != null ? desc : "") + "</td>");
                Date prox = rs.getDate("proximo_contacto");
                out.print("<td>" + (prox != null ? prox.toString() : "-") + "</td>");
                String est = rs.getString("estado");
                String badge = "PENDIENTE".equals(est) ? "warning" : ("REALIZADO".equals(est) ? "success" : "secondary");
                out.print("<td><span class='badge bg-" + badge + "'>" + est + "</span></td>");
                out.print("<td>");
                out.print("<button class='btn btn-warning btn-sm' onclick='editarSeguimiento(" + rs.getInt("id") + ")'>Editar</button> ");
                out.print("<button class='btn btn-danger btn-sm' onclick='eliminarSeguimiento(" + rs.getInt("id") + ")'>Eliminar</button>");
                out.print("</td>");
                out.print("</tr>");
            }
        }
        
        else if ("listarclientes".equals(tipo)) {
            rs = st.executeQuery(
                "SELECT id, nombre, documento FROM clientes WHERE estado = true ORDER BY nombre"
            );
            out.print("<option value=''>Seleccionar Cliente</option>");
            while (rs.next()) {
                out.print("<option value='" + rs.getInt("id") + "'>"
                        + rs.getString("nombre") + " (" + rs.getString("documento") + ")</option>");
            }
        }
        
        else if ("guardar".equals(tipo)) {
            String idStr = request.getParameter("id");
            int idcliente = Integer.parseInt(request.getParameter("idcliente"));
            String fecha = request.getParameter("fecha");
            String tipoSeg = request.getParameter("tipo_seg");
            String descripcion = request.getParameter("descripcion");
            String proximo = request.getParameter("proximo_contacto");
            String estado = request.getParameter("estado");
            if (estado == null || estado.isEmpty()) estado = "PENDIENTE";

            if (descripcion != null) {
                descripcion = descripcion.replace("'", "''");
            } else {
                descripcion = "";
            }

            if (idStr == null || idStr.isEmpty() || "0".equals(idStr)) {
                ps = conn.prepareStatement(
                    "INSERT INTO seguimientos (idcliente, fecha, tipo, descripcion, proximo_contacto, estado) " +
                    "VALUES (?, ?::date, ?, ?, " +
                    (proximo != null && !proximo.isEmpty() ? "?::date" : "NULL") +
                    ", ?)"
                );
                ps.setInt(1, idcliente);
                ps.setString(2, fecha);
                ps.setString(3, tipoSeg);
                ps.setString(4, descripcion);
                if (proximo != null && !proximo.isEmpty()) {
                    ps.setString(5, proximo);
                    ps.setString(6, estado);
                } else {
                    ps.setString(5, estado);
                }
                ps.executeUpdate();
                out.print("ok_insert");
            } else {
                int id = Integer.parseInt(idStr);
                if (proximo != null && !proximo.isEmpty()) {
                    ps = conn.prepareStatement(
                        "UPDATE seguimientos SET idcliente=?, fecha=?::date, tipo=?, descripcion=?, " +
                        "proximo_contacto=?::date, estado=? WHERE id=?"
                    );
                    ps.setInt(1, idcliente);
                    ps.setString(2, fecha);
                    ps.setString(3, tipoSeg);
                    ps.setString(4, descripcion);
                    ps.setString(5, proximo);
                    ps.setString(6, estado);
                    ps.setInt(7, id);
                } else {
                    ps = conn.prepareStatement(
                        "UPDATE seguimientos SET idcliente=?, fecha=?::date, tipo=?, descripcion=?, " +
                        "proximo_contacto=NULL, estado=? WHERE id=?"
                    );
                    ps.setInt(1, idcliente);
                    ps.setString(2, fecha);
                    ps.setString(3, tipoSeg);
                    ps.setString(4, descripcion);
                    ps.setString(5, estado);
                    ps.setInt(6, id);
                }
                ps.executeUpdate();
                out.print("ok_update");
            }
        }
        
        else if ("obtener".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            rs = st.executeQuery("SELECT * FROM seguimientos WHERE id = " + id);
            if (rs.next()) {
                Date prox = rs.getDate("proximo_contacto");
                out.print(rs.getInt("id") + "|"
                        + rs.getInt("idcliente") + "|"
                        + rs.getDate("fecha") + "|"
                        + rs.getString("tipo") + "|"
                        + (rs.getString("descripcion") != null ? rs.getString("descripcion") : "") + "|"
                        + (prox != null ? prox.toString() : "") + "|"
                        + rs.getString("estado"));
            }
        }
        
        else if ("eliminar".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            st.executeUpdate("DELETE FROM seguimientos WHERE id = " + id);
            out.print("ok");
        }
        
        else if ("pendientes".equals(tipo)) {
            rs = st.executeQuery(
                "SELECT s.id, c.nombre AS cliente, s.fecha, s.tipo, s.descripcion, " +
                "s.proximo_contacto, s.estado " +
                "FROM seguimientos s " +
                "JOIN clientes c ON s.idcliente = c.id " +
                "WHERE s.estado = 'PENDIENTE' " +
                "AND (s.proximo_contacto IS NULL OR s.proximo_contacto <= CURRENT_DATE + 7) " +
                "ORDER BY s.proximo_contacto ASC NULLS LAST, s.id DESC"
            );
            while (rs.next()) {
                out.print("<tr>");
                out.print("<td>" + rs.getInt("id") + "</td>");
                out.print("<td>" + rs.getString("cliente") + "</td>");
                out.print("<td>" + rs.getDate("fecha") + "</td>");
                out.print("<td>" + rs.getString("tipo") + "</td>");
                out.print("<td>" + (rs.getString("descripcion") != null ? rs.getString("descripcion") : "") + "</td>");
                Date prox = rs.getDate("proximo_contacto");
                out.print("<td>" + (prox != null ? prox.toString() : "-") + "</td>");
                out.print("<td><span class='badge bg-warning'>PENDIENTE</span></td>");
                out.print("<td>");
                out.print("<button class='btn btn-success btn-sm' onclick='marcarRealizado(" + rs.getInt("id") + ")'>Hecho</button> ");
                out.print("<button class='btn btn-warning btn-sm' onclick='editarSeguimiento(" + rs.getInt("id") + ")'>Editar</button>");
                out.print("</td>");
                out.print("</tr>");
            }
        }
        
        else if ("realizar".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            st.executeUpdate("UPDATE seguimientos SET estado = 'REALIZADO' WHERE id = " + id);
            out.print("ok");
        }
        else {
            out.print("Tipo no reconocido: " + tipo);
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
