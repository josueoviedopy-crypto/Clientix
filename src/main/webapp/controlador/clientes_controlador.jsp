<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;

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
                "SELECT id, nombre, documento, email, telefono, direccion, ciudad " +
                "FROM clientes WHERE estado = true ORDER BY id DESC"
            );
            while (rs.next()) {
                out.print("<tr>");
                out.print("<td>" + rs.getInt("id") + "</td>");
                out.print("<td>" + rs.getString("nombre") + "</td>");
                out.print("<td>" + rs.getString("documento") + "</td>");
                out.print("<td>" + (rs.getString("email") != null ? rs.getString("email") : "") + "</td>");
                out.print("<td>" + (rs.getString("telefono") != null ? rs.getString("telefono") : "") + "</td>");
                out.print("<td>" + (rs.getString("direccion") != null ? rs.getString("direccion") : "") + "</td>");
                out.print("<td>" + (rs.getString("ciudad") != null ? rs.getString("ciudad") : "") + "</td>");
                out.print("<td>");
                out.print("<button class='btn btn-warning btn-sm' onclick='editarCliente(" + rs.getInt("id") + ")'>Editar</button> ");
                out.print("<button class='btn btn-danger btn-sm' onclick='eliminarCliente(" + rs.getInt("id") + ")'>Eliminar</button> ");
                out.print("<a href='controlador/generar_reporte.jsp?reporte=clientes&tipo=individual&id=" + rs.getInt("id") + "' target='_blank' class='btn btn-info btn-sm' title='Ver PDF'><i class='bi bi-eye'></i></a>");
                out.print("</td>");
                out.print("</tr>");
            }
        }

        
        else if ("guardar".equals(tipo)) {
            String idStr = request.getParameter("id");
            String nombre = request.getParameter("nombre") != null ? request.getParameter("nombre").trim() : "";
            String documento = request.getParameter("documento") != null ? request.getParameter("documento").trim() : "";
            String email = request.getParameter("email") != null ? request.getParameter("email").trim() : "";
            String telefono = request.getParameter("telefono") != null ? request.getParameter("telefono").trim() : "";
            String direccion = request.getParameter("direccion") != null ? request.getParameter("direccion").trim() : "";
            String ciudad = request.getParameter("ciudad") != null ? request.getParameter("ciudad").trim() : "";

            
            String sqlCheck = "SELECT id FROM clientes WHERE documento = '" + documento + "' AND estado = true";
            if (idStr != null && !idStr.isEmpty()) {
                sqlCheck += " AND id != " + idStr;
            }
            rs = st.executeQuery(sqlCheck);
            if (rs.next()) {
                out.print("error:documento_duplicado");
                return;
            }

            if (idStr == null || idStr.isEmpty()) {
               
                st.executeUpdate(
                    "INSERT INTO clientes(nombre, documento, email, telefono, direccion, ciudad, estado) " +
                    "VALUES('" + nombre + "','" + documento + "','" + email + "','" + telefono + "','" +
                    direccion + "','" + ciudad + "', true)"
                );
                out.print("ok_insert");
            } else {
                
                st.executeUpdate(
                    "UPDATE clientes SET nombre='" + nombre + "', documento='" + documento +
                    "', email='" + email + "', telefono='" + telefono +
                    "', direccion='" + direccion + "', ciudad='" + ciudad +
                    "' WHERE id=" + idStr
                );
                out.print("ok_update");
            }
        }

        
        else if ("obtener".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            rs = st.executeQuery("SELECT * FROM clientes WHERE id = " + id);
            if (rs.next()) {
                out.print(
                    rs.getInt("id") + "|" +
                    rs.getString("nombre") + "|" +
                    rs.getString("documento") + "|" +
                    (rs.getString("email") != null ? rs.getString("email") : "") + "|" +
                    (rs.getString("telefono") != null ? rs.getString("telefono") : "") + "|" +
                    (rs.getString("direccion") != null ? rs.getString("direccion") : "") + "|" +
                    (rs.getString("ciudad") != null ? rs.getString("ciudad") : "")
                );
            }
        }

       
        else if ("eliminar".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            st.executeUpdate("UPDATE clientes SET estado = false WHERE id = " + id);
            out.print("ok");
        }

    } catch (Exception e) {
        out.print("error: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (st != null) try { st.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

