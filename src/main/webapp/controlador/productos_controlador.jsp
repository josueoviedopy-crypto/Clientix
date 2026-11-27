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
                "SELECT id, codigo, descripcion, precio, iva " +
                "FROM articulos WHERE estado = true ORDER BY id DESC"
            );
            while (rs.next()) {
                out.print("<tr>");
                out.print("<td>" + rs.getInt("id") + "</td>");
                out.print("<td>" + rs.getString("codigo") + "</td>");
                out.print("<td>" + rs.getString("descripcion") + "</td>");
                out.print("<td>" + String.format("%.0f", rs.getDouble("precio")) + "</td>");
                out.print("<td>" + String.format("%.0f", rs.getDouble("iva")) + "%</td>");
                out.print("<td style='white-space:nowrap;'>");
                out.print("<button class='btn btn-warning btn-sm' onclick='editarProducto(" + rs.getInt("id") + ")'>Editar</button> ");
                out.print("<button class='btn btn-danger btn-sm' onclick='eliminarProducto(" + rs.getInt("id") + ")'>Eliminar</button> ");
                out.print("<a href='controlador/generar_reporte.jsp?reporte=productos&tipo=individual&id=" + rs.getInt("id") +
                          "' target='_blank' class='btn btn-info btn-sm' title='Ver PDF'><i class='bi bi-eye'></i></a>");
                out.print("</td>");
                out.print("</tr>");
            }
        }

        
        else if ("guardar".equals(tipo)) {
            String idStr = request.getParameter("id");
            String codigo = request.getParameter("codigo") != null ? request.getParameter("codigo").trim() : "";
            String descripcion = request.getParameter("descripcion") != null ? request.getParameter("descripcion").trim() : "";
            double precio = Double.parseDouble(request.getParameter("precio"));
            double iva = Double.parseDouble(request.getParameter("iva"));

            
            if (iva != 0 && iva != 5 && iva != 10) {
                out.print("error:iva_invalido");
                return;
            }

            
            String check = "SELECT id FROM articulos WHERE codigo = '" + codigo + "' AND estado = true";
            if (idStr != null && !idStr.isEmpty()) {
                check += " AND id != " + idStr;
            }
            rs = st.executeQuery(check);
            if (rs.next()) {
                out.print("error:codigo_duplicado");
                return;
            }

            if (idStr == null || idStr.isEmpty()) {
                st.executeUpdate(
                    "INSERT INTO articulos(codigo, descripcion, precio, iva, estado) VALUES('" +
                    codigo + "','" + descripcion + "'," + precio + "," + iva + ", true)"
                );
                out.print("ok_insert");
            } else {
                st.executeUpdate(
                    "UPDATE articulos SET codigo='" + codigo + "', descripcion='" + descripcion +
                    "', precio=" + precio + ", iva=" + iva + " WHERE id=" + idStr
                );
                out.print("ok_update");
            }
        }

        
        else if ("obtener".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            rs = st.executeQuery("SELECT * FROM articulos WHERE id = " + id);
            if (rs.next()) {
                out.print(
                    rs.getInt("id") + "|" +
                    rs.getString("codigo") + "|" +
                    rs.getString("descripcion") + "|" +
                    rs.getDouble("precio") + "|" +
                    rs.getDouble("iva")
                );
            }
        }

        
        else if ("eliminar".equals(tipo)) {
            int id = Integer.parseInt(request.getParameter("id"));
            st.executeUpdate("UPDATE articulos SET estado = false WHERE id = " + id);
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


