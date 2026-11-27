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
            rs = st.executeQuery(
                "SELECT id, username, nombre, rol FROM usuarios WHERE estado = true ORDER BY id DESC"
            );
            while (rs.next()) {
                out.print("<tr>");
                out.print("<td>" + rs.getInt("id") + "</td>");
                out.print("<td>" + rs.getString("username") + "</td>");
                out.print("<td>" + (rs.getString("nombre") != null ? rs.getString("nombre") : "") + "</td>");
                out.print("<td>" + (rs.getString("rol") != null ? rs.getString("rol") : "") + "</td>");
                out.print("<td>");
                out.print("<button class='btn btn-warning btn-sm' onclick='editarUsuario(" + rs.getInt("id") + ")'>Editar</button> ");
                out.print("<button class='btn btn-danger btn-sm' onclick='eliminarUsuario(" + rs.getInt("id") + ")'>Eliminar</button>");
                out.print("</td>");
                out.print("</tr>");
            }
        }

        
        else if ("guardar".equals(tipo)) {
            String idStr = request.getParameter("id");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String nombre = request.getParameter("nombre");
            String rol = request.getParameter("rol");

            if (username == null || username.trim().isEmpty()) {
                out.print("error: usuario obligatorio");
                return;
            }

            
            ps = conn.prepareStatement(
                "SELECT id FROM usuarios WHERE username = ? AND estado = true" +
                (idStr != null && !idStr.isEmpty() ? " AND id <> " + Integer.parseInt(idStr) : "")
            );
            ps.setString(1, username.trim());
            rs = ps.executeQuery();
            if (rs.next()) {
                out.print("usuario_duplicado");
                return;
            }
            rs.close();
            ps.close();

            if (idStr == null || idStr.trim().isEmpty()) {
                
                if (password == null || password.isEmpty()) {
                    out.print("error: contraseña obligatoria");
                    return;
                }
                ps = conn.prepareStatement(
                    "INSERT INTO usuarios (username, password, nombre, rol, estado) VALUES (?, ?, ?, ?, true)"
                );
                ps.setString(1, username.trim());
                ps.setString(2, password);
                ps.setString(3, nombre != null ? nombre.trim() : "");
                ps.setString(4, rol != null ? rol.trim() : "usuario");
                ps.executeUpdate();
                out.print("ok_insert");
            } else {
                
                int id = Integer.parseInt(idStr);
                if (password != null && !password.isEmpty()) {
                    ps = conn.prepareStatement(
                        "UPDATE usuarios SET username=?, password=?, nombre=?, rol=? WHERE id=?"
                    );
                    ps.setString(1, username.trim());
                    ps.setString(2, password);
                    ps.setString(3, nombre != null ? nombre.trim() : "");
                    ps.setString(4, rol != null ? rol.trim() : "usuario");
                    ps.setInt(5, id);
                } else {
                    
                    ps = conn.prepareStatement(
                        "UPDATE usuarios SET username=?, nombre=?, rol=? WHERE id=?"
                    );
                    ps.setString(1, username.trim());
                    ps.setString(2, nombre != null ? nombre.trim() : "");
                    ps.setString(3, rol != null ? rol.trim() : "usuario");
                    ps.setInt(4, id);
                }
                ps.executeUpdate();
                out.print("ok_update");
            }
        }

        
        else if ("obtener".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            rs = st.executeQuery("SELECT id, username, nombre, rol FROM usuarios WHERE id = " + id);
            if (rs.next()) {
                out.print(rs.getInt("id") + "|" +
                          rs.getString("username") + "|" +
                          (rs.getString("nombre") != null ? rs.getString("nombre") : "") + "|" +
                          (rs.getString("rol") != null ? rs.getString("rol") : ""));
            }
        }

        
        else if ("eliminar".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            st.executeUpdate("UPDATE usuarios SET estado = false WHERE id = " + id);
            out.print("ok");
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
