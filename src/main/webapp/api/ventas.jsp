<%@page import="java.sql.*, org.json.*"%>
<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Content-Type");

    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
        return;
    }

    request.setCharacterEncoding("UTF-8");
    JSONObject json = new JSONObject();

    String idclienteStr = request.getParameter("idcliente");
    String itemsStr = request.getParameter("items"); // JSON array

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        if (idclienteStr == null || itemsStr == null || itemsStr.isEmpty()) {
            json.put("ok", false);
            json.put("mensaje", "idcliente e items son obligatorios");
            out.print(json.toString());
            return;
        }

        int idcliente = Integer.parseInt(idclienteStr);
        JSONArray items = new JSONArray(itemsStr);
        if (items.length() == 0) {
            json.put("ok", false);
            json.put("mensaje", "El pedido no tiene artículos");
            out.print(json.toString());
            return;
        }

        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_edgar",
            "postgres", "ctaticpy"
        );
        conn.setAutoCommit(false);

        // Cabecera
        ps = conn.prepareStatement(
            "INSERT INTO ventas (idcliente, fecha, estado) VALUES (?, CURRENT_DATE, 'FINALIZADO') RETURNING id"
        );
        // Si preferís dejarla PENDIENTE para gestionarla en el web:
        // "... VALUES (?, CURRENT_DATE, 'PENDIENTE') RETURNING id"
        ps.setInt(1, idcliente);
        rs = ps.executeQuery();
        int idventa = 0;
        if (rs.next()) {
            idventa = rs.getInt(1);
        }
        rs.close();
        ps.close();

        // Detalle
        for (int i = 0; i < items.length(); i++) {
            JSONObject it = items.getJSONObject(i);
            int idarticulo = it.getInt("idarticulo");
            double precio = it.getDouble("precio");
            int cantidad = it.getInt("cantidad");
            double iva = it.has("iva") ? it.getDouble("iva") : 10;
            double subtotal = precio * cantidad;

            try {
                ps = conn.prepareStatement(
                    "INSERT INTO venta_detalle (idventa, idarticulo, precio, cantidad, iva, subtotal) " +
                    "VALUES (?, ?, ?, ?, ?, ?)"
                );
                ps.setInt(1, idventa);
                ps.setInt(2, idarticulo);
                ps.setDouble(3, precio);
                ps.setInt(4, cantidad);
                ps.setDouble(5, iva);
                ps.setDouble(6, subtotal);
                ps.executeUpdate();
                ps.close();
            } catch (Exception ex) {
                // Sin columnas iva/subtotal
                ps = conn.prepareStatement(
                    "INSERT INTO venta_detalle (idventa, idarticulo, precio, cantidad) VALUES (?, ?, ?, ?)"
                );
                ps.setInt(1, idventa);
                ps.setInt(2, idarticulo);
                ps.setDouble(3, precio);
                ps.setInt(4, cantidad);
                ps.executeUpdate();
                ps.close();
            }
        }

        conn.commit();
        json.put("ok", true);
        json.put("idventa", idventa);
        json.put("mensaje", "Venta registrada correctamente");

    } catch (Exception e) {
        try { if (conn != null) conn.rollback(); } catch (Exception ex) {}
        json.put("ok", false);
        json.put("mensaje", "Error: " + e.getMessage());
    } finally {
        try { if (conn != null) conn.setAutoCommit(true); } catch (Exception e) {}
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    out.print(json.toString());
%>
