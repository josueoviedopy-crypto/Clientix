<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;
    
    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyecto_edgar", "postgres", "ctaticpy");
        st = conn.createStatement();

        String tipo = request.getParameter("tipo");

    if ("listar".equals(tipo)) {
    rs = st.executeQuery("SELECT id, nombre, ruc, direccion, telefono FROM proveedores WHERE estado = true ORDER BY id DESC");
    while (rs.next()) {
        out.print("<tr>");
        out.print("<td>" + rs.getInt("id") + "</td>");
        out.print("<td>" + rs.getString("nombre") + "</td>");
        out.print("<td>" + (rs.getString("ruc") != null ? rs.getString("ruc") : "") + "</td>");
        out.print("<td>" + (rs.getString("direccion") != null ? rs.getString("direccion") : "") + "</td>");
        out.print("<td>" + (rs.getString("telefono") != null ? rs.getString("telefono") : "") + "</td>");
        
        
        out.print("<td>");
        out.print("<button class='btn btn-warning btn-sm' onclick='editarProveedor(" + rs.getInt("id") + ")'>Editar</button> ");
        out.print("<button class='btn btn-danger btn-sm' onclick='eliminarProveedor(" + rs.getInt("id") + ")'>Eliminar</button> ");
        out.print("<a href='controlador/generar_reporte.jsp?reporte=clientes&tipo=individual&id=" + rs.getInt("id") + "' target='_blank' class='btn btn-info btn-sm' title='Ver PDF'><i class='bi bi-eye'></i></a>");
        out.print("</td>");
        
        out.print("</tr>");
    }
}
    else if ("guardar".equals(tipo)) {
        String idStr = request.getParameter("id");
        String nombre = request.getParameter("nombre").trim();
        String ruc = request.getParameter("ruc").trim();
        String direccion = request.getParameter("direccion").trim();
        String telefono = request.getParameter("telefono").trim();

        
        String check = "SELECT id FROM proveedores WHERE ruc = '" + ruc + "' AND estado = true";
        if (idStr != null && !idStr.isEmpty()) check += " AND id != " + idStr;
        rs = st.executeQuery(check);
        if (rs.next()) {
            out.print("error:ruc_duplicado");
            return;
        }

        if (idStr == null || idStr.isEmpty()) {
            st.executeUpdate("INSERT INTO proveedores(nombre, ruc, direccion, telefono, estado) VALUES('" + 
                nombre + "','" + ruc + "','" + direccion + "','" + telefono + "', true)");
            out.print("ok_insert");
        } else {
            st.executeUpdate("UPDATE proveedores SET nombre='" + nombre + "', ruc='" + ruc + 
                "', direccion='" + direccion + "', telefono='" + telefono + "' WHERE id=" + idStr);
            out.print("ok_update");
        }
    } 
    else if ("obtener".equals(tipo)) {
        int id = Integer.parseInt(request.getParameter("id"));
        rs = st.executeQuery("SELECT * FROM proveedores WHERE id = " + id);
        if (rs.next()) {
            out.print(rs.getInt("id") + "|" + rs.getString("nombre") + "|" + rs.getString("ruc") + 
                     "|" + rs.getString("direccion") + "|" + rs.getString("telefono"));
        }
    } 
    else if ("eliminar".equals(tipo)) {
        int id = Integer.parseInt(request.getParameter("id"));
        st.executeUpdate("UPDATE proveedores SET estado = false WHERE id = " + id);
        out.print("ok");
    }
} catch(Exception e) {
        out.print("error: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (st != null) try { st.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

