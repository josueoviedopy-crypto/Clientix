
<%@include file="header.jsp" %>
<%@page import="java.sql.*"%>

<%
    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;

    int totalClientes = 0;
    int totalProductos = 0;
    int totalVentas = 0;
    int totalUsuarios = 0;

    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_edgar", 
            "postgres", 
            "ctaticpy"
        );
        st = conn.createStatement();

        
        rs = st.executeQuery("SELECT COUNT(*) FROM clientes WHERE estado = true");
        if (rs.next()) totalClientes = rs.getInt(1);

        rs = st.executeQuery("SELECT COUNT(*) FROM articulos WHERE estado = true");
        if (rs.next()) totalProductos = rs.getInt(1);

        rs = st.executeQuery("SELECT COUNT(*) FROM ventas WHERE estado = 'FINALIZADO'");
        if (rs.next()) totalVentas = rs.getInt(1);

        rs = st.executeQuery("SELECT COUNT(*) FROM usuarios"); // cambia si tu tabla se llama diferente
        if (rs.next()) totalUsuarios = rs.getInt(1);

    } catch(Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (st != null) try { st.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6"><h1 class="m-0">Dashboard</h1></div>
            </div>
        </div>
    </div>

    <div class="content">
        <div class="container-fluid">
            <div class="row g-3">
                <div class="col-md-3">
                    <div class="card-box bg-cliente">
                        <h4>Clientes</h4>
                        <h2><%= totalClientes %></h2>
                        <p>registrados</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card-box bg-producto">
                        <h4>Productos</h4>
                        <h2><%= totalProductos %></h2>
                        <p>en inventario</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card-box bg-venta">
                        <h4>Ventas</h4>
                        <h2><%= totalVentas %></h2>
                        <p>finalizadas</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card-box bg-user">
                        <h4>Usuarios</h4>
                        <h2><%= totalUsuarios %></h2>
                        <p>activos</p>
                    </div>
                </div>
            </div>

            <hr>

            <div class="row">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header bg-info text-white">Últimos Clientes</div>
                        <div class="card-body">
                            <ul class="list-group">
                                <% 
                                    try {
                                        rs = st.executeQuery("SELECT nombre FROM clientes WHERE estado = true ORDER BY id DESC LIMIT 5");
                                        while(rs.next()) {
                                            out.print("<li class='list-group-item'>" + rs.getString("nombre") + "</li>");
                                        }
                                    } catch(Exception e) {}
                                %>
                            </ul>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header bg-secondary text-white">Últimas Ventas</div>
                        <div class="card-body">
                            <ul class="list-group">
                                <% 
                                    try {
                                        rs = st.executeQuery("SELECT v.id, c.nombre FROM ventas v JOIN clientes c ON v.idcliente = c.id WHERE v.estado = 'FINALIZADO' ORDER BY v.id DESC LIMIT 5");
                                        while(rs.next()) {
                                            out.print("<li class='list-group-item'>Venta #" + rs.getInt("id") + " - " + rs.getString("nombre") + "</li>");
                                        }
                                    } catch(Exception e) {}
                                %>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@include file="footer.jsp" %>

