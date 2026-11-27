<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    
    if (session.getAttribute("usuario") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    String error = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username != null && password != null
                && !username.trim().isEmpty() && !password.isEmpty()) {

            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                Class.forName("org.postgresql.Driver");
                conn = DriverManager.getConnection(
                    "jdbc:postgresql://localhost:5432/proyecto_edgar",
                    "postgres",
                    "ctaticpy"
                );
                ps = conn.prepareStatement(
                    "SELECT id, username, nombre, rol FROM usuarios " +
                    "WHERE username = ? AND password = ? AND estado = true"
                );
                ps.setString(1, username.trim());
                ps.setString(2, password);
                rs = ps.executeQuery();

                if (rs.next()) {
                    session.setAttribute("usuario", rs.getString("username"));
                    session.setAttribute("nombre", rs.getString("nombre"));
                    session.setAttribute("rol", rs.getString("rol"));
                    session.setAttribute("idusuario", rs.getInt("id"));
                    response.sendRedirect("dashboard.jsp");
                    return;
                } else {
                    error = "1";
                }
            } catch (Exception e) {
                error = "1";

            } finally {
                if (rs != null) try { rs.close(); } catch (Exception e) {}
                if (ps != null) try { ps.close(); } catch (Exception e) {}
                if (conn != null) try { conn.close(); } catch (Exception e) {}
            }
        } else {
            error = "1";
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login Clientix CRM</title>
    <link href="<%=request.getContextPath()%>/assets/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-4">
            <div class="card shadow">
                <div class="card-header text-center">
                    <h3>Clientix CRM</h3>
                </div>
                <div class="card-body">
                    <% if (error != null) { %>
                    <div class="alert alert-danger">
                        Usuario o contraseña incorrectos
                    </div>
                    <% } %>
                    <form method="post" action="login.jsp">
                        <div class="mb-3">
                            <label>Usuario</label>
                            <input type="text" name="username" class="form-control" required
                                   value="admin">
                        </div>
                        <div class="mb-3">
                            <label>Password</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">Ingresar</button>
                    </form>
                    <hr>
                    <small>admin / 1234</small>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
