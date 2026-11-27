<%@page import="java.sql.*, org.json.*"%>
<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Content-Type");

    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
        return;
    }

    String username = request.getParameter("username");
    String password = request.getParameter("password");
    JSONObject json = new JSONObject();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        if (username == null || password == null || username.isEmpty() || password.isEmpty()) {
            json.put("ok", false);
            json.put("mensaje", "Usuario y contraseña requeridos");
            out.print(json.toString());
            return;
        }

        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_edgar",
            "postgres", "ctaticpy"
        );

        ps = conn.prepareStatement(
            "SELECT id, username, nombre, rol FROM usuarios WHERE username = ? AND password = ? AND estado = true"
        );
        ps.setString(1, username.trim());
        ps.setString(2, password);
        rs = ps.executeQuery();

        if (rs.next()) {
            json.put("ok", true);
            json.put("id", rs.getInt("id"));
            json.put("username", rs.getString("username"));
            json.put("nombre", rs.getString("nombre") != null ? rs.getString("nombre") : "");
            json.put("rol", rs.getString("rol") != null ? rs.getString("rol") : "usuario");
            json.put("mensaje", "Login correcto");
        } else {
            json.put("ok", false);
            json.put("mensaje", "Credenciales inválidas");
        }
    } catch (Exception e) {
        json.put("ok", false);
        json.put("mensaje", "Error: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    out.print(json.toString());
%>
