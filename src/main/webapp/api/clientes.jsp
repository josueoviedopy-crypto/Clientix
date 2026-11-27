<%@page import="java.sql.*, org.json.*"%>
<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");

    JSONObject json = new JSONObject();
    JSONArray lista = new JSONArray();
    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;

    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_edgar",
            "postgres", "ctaticpy"
        );
        st = conn.createStatement();
        rs = st.executeQuery(
            "SELECT id, nombre, documento, email, telefono FROM clientes WHERE estado = true ORDER BY nombre"
        );

        while (rs.next()) {
            JSONObject item = new JSONObject();
            item.put("id", rs.getInt("id"));
            item.put("nombre", rs.getString("nombre"));
            item.put("documento", rs.getString("documento") != null ? rs.getString("documento") : "");
            item.put("email", rs.getString("email") != null ? rs.getString("email") : "");
            item.put("telefono", rs.getString("telefono") != null ? rs.getString("telefono") : "");
            lista.put(item);
        }
        json.put("ok", true);
        json.put("data", lista);
    } catch (Exception e) {
        json.put("ok", false);
        json.put("mensaje", e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (st != null) try { st.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    out.print(json.toString());
%>
