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
            String filtro = request.getParameter("filtro"); 
            String sql =
                "SELECT t.id, t.titulo, t.descripcion, t.fecha_vencimiento, t.prioridad, t.estado, " +
                "t.idcliente, c.nombre AS cliente " +
                "FROM tareas t " +
                "LEFT JOIN clientes c ON t.idcliente = c.id ";

            if ("pendientes".equals(filtro)) {
                sql += "WHERE t.estado = 'PENDIENTE' ";
            } else if ("hoy".equals(filtro)) {
                sql += "WHERE t.estado = 'PENDIENTE' AND t.fecha_vencimiento = CURRENT_DATE ";
            } else if ("vencidas".equals(filtro)) {
                sql += "WHERE t.estado = 'PENDIENTE' AND t.fecha_vencimiento < CURRENT_DATE ";
            }

            sql += "ORDER BY " +
                   "CASE WHEN t.estado = 'PENDIENTE' THEN 0 ELSE 1 END, " +
                   "t.fecha_vencimiento ASC NULLS LAST, t.id DESC";

            rs = st.executeQuery(sql);
            while (rs.next()) {
                out.print("<tr>");
                out.print("<td>" + rs.getInt("id") + "</td>");
                out.print("<td>" + rs.getString("titulo") + "</td>");
                String cli = rs.getString("cliente");
                out.print("<td>" + (cli != null ? cli : "-") + "</td>");
                Date fv = rs.getDate("fecha_vencimiento");
                out.print("<td>" + (fv != null ? fv.toString() : "-") + "</td>");
                String pri = rs.getString("prioridad");
                String badgePri = "ALTA".equals(pri) ? "danger" : ("BAJA".equals(pri) ? "secondary" : "info");
                out.print("<td><span class='badge bg-" + badgePri + "'>" + pri + "</span></td>");
                String est = rs.getString("estado");
                String badgeEst = "PENDIENTE".equals(est) ? "warning" : ("REALIZADO".equals(est) ? "success" : "secondary");
                out.print("<td><span class='badge bg-" + badgeEst + "'>" + est + "</span></td>");
                out.print("<td>");
                if ("PENDIENTE".equals(est)) {
                    out.print("<button class='btn btn-success btn-sm' onclick='marcarHecha(" + rs.getInt("id") + ")'>Hecha</button> ");
                }
                out.print("<button class='btn btn-warning btn-sm' onclick='editarTarea(" + rs.getInt("id") + ")'>Editar</button> ");
                out.print("<button class='btn btn-danger btn-sm' onclick='eliminarTarea(" + rs.getInt("id") + ")'>Eliminar</button>");
                out.print("</td>");
                out.print("</tr>");
            }
        }
        
        else if ("listarclientes".equals(tipo)) {
            rs = st.executeQuery(
                "SELECT id, nombre, documento FROM clientes WHERE estado = true ORDER BY nombre"
            );
            out.print("<option value=''>Sin cliente (tarea general)</option>");
            while (rs.next()) {
                out.print("<option value='" + rs.getInt("id") + "'>"
                        + rs.getString("nombre") + " (" + rs.getString("documento") + ")</option>");
            }
        }
        
        else if ("guardar".equals(tipo)) {
            String idStr = request.getParameter("id");
            String titulo = request.getParameter("titulo");
            String descripcion = request.getParameter("descripcion");
            String fechaVen = request.getParameter("fecha_vencimiento");
            String idclienteStr = request.getParameter("idcliente");
            String prioridad = request.getParameter("prioridad");
            String estado = request.getParameter("estado");

            if (titulo == null || titulo.trim().isEmpty()) {
                out.print("error: El título es obligatorio");
                return;
            }
            titulo = titulo.replace("'", "''");
            if (descripcion != null) descripcion = descripcion.replace("'", "''");
            else descripcion = "";
            if (prioridad == null || prioridad.isEmpty()) prioridad = "MEDIA";
            if (estado == null || estado.isEmpty()) estado = "PENDIENTE";

            Integer idcliente = null;
            if (idclienteStr != null && !idclienteStr.isEmpty() && !"0".equals(idclienteStr)) {
                idcliente = Integer.parseInt(idclienteStr);
            }

            if (idStr == null || idStr.isEmpty() || "0".equals(idStr)) {
                ps = conn.prepareStatement(
                    "INSERT INTO tareas (titulo, descripcion, fecha_vencimiento, idcliente, prioridad, estado) " +
                    "VALUES (?, ?, " +
                    (fechaVen != null && !fechaVen.isEmpty() ? "?::date" : "NULL") +
                    ", ?, ?, ?)"
                );
                int i = 1;
                ps.setString(i++, titulo);
                ps.setString(i++, descripcion);
                if (fechaVen != null && !fechaVen.isEmpty()) {
                    ps.setString(i++, fechaVen);
                }
                if (idcliente != null) ps.setInt(i++, idcliente);
                else ps.setNull(i++, Types.INTEGER);
                ps.setString(i++, prioridad);
                ps.setString(i++, estado);
                ps.executeUpdate();
                out.print("ok_insert");
            } else {
                int id = Integer.parseInt(idStr);
                String sql =
                    "UPDATE tareas SET titulo=?, descripcion=?, fecha_vencimiento=" +
                    (fechaVen != null && !fechaVen.isEmpty() ? "?::date" : "NULL") +
                    ", idcliente=?, prioridad=?, estado=? WHERE id=?";
                ps = conn.prepareStatement(sql);
                int i = 1;
                ps.setString(i++, titulo);
                ps.setString(i++, descripcion);
                if (fechaVen != null && !fechaVen.isEmpty()) {
                    ps.setString(i++, fechaVen);
                }
                if (idcliente != null) ps.setInt(i++, idcliente);
                else ps.setNull(i++, Types.INTEGER);
                ps.setString(i++, prioridad);
                ps.setString(i++, estado);
                ps.setInt(i++, id);
                ps.executeUpdate();
                out.print("ok_update");
            }
        }
        
        else if ("obtener".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            rs = st.executeQuery("SELECT * FROM tareas WHERE id = " + id);
            if (rs.next()) {
                Date fv = rs.getDate("fecha_vencimiento");
                int idc = rs.getInt("idcliente");
                boolean tieneCliente = !rs.wasNull();
                out.print(rs.getInt("id") + "|"
                        + rs.getString("titulo") + "|"
                        + (rs.getString("descripcion") != null ? rs.getString("descripcion") : "") + "|"
                        + (fv != null ? fv.toString() : "") + "|"
                        + (tieneCliente ? String.valueOf(idc) : "") + "|"
                        + rs.getString("prioridad") + "|"
                        + rs.getString("estado"));
            }
        }
       
        else if ("eliminar".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            st.executeUpdate("DELETE FROM tareas WHERE id = " + id);
            out.print("ok");
        }
        
        else if ("realizar".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            st.executeUpdate("UPDATE tareas SET estado = 'REALIZADO' WHERE id = " + id);
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
