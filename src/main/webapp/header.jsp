<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String nombreUsuario = String.valueOf(session.getAttribute("usuario"));
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Clientix CRM</title>
    <link href="<%=request.getContextPath()%>/assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background: #f4f6f9; margin: 0; }
        .sidebar {
            width: 230px;
            position: fixed;
            top: 0;
            left: 0;
            height: 100%;
            background: #343a40;
            padding-top: 20px;
            color: white;
            overflow-y: auto;
            z-index: 1000;
        }
        .sidebar h4 {
            text-align: center;
            font-size: 1.2rem;
            margin-bottom: 10px;
        }
        .sidebar .user-info {
            text-align: center;
            font-size: 0.85rem;
            color: #adb5bd;
            margin-bottom: 10px;
            padding: 0 10px;
        }
        .sidebar a {
            color: #c2c7d0;
            display: block;
            padding: 10px 20px;
            text-decoration: none;
        }
        .sidebar a:hover,
        .sidebar a.active {
            background: #495057;
            color: white;
        }
        .sidebar hr {
            border-color: #495057;
            margin: 10px 15px;
        }
        .content-wrapper {
            margin-left: 230px;
            padding: 20px;
            min-height: 100vh;
        }
    </style>
</head>
<body>
<div class="sidebar">
    <h4>Clientix CRM</h4>
    <div class="user-info">
        <i class="bi bi-person-circle"></i> <%= nombreUsuario %>
    </div>
    <hr>
    <a href="<%=request.getContextPath()%>/dashboard.jsp">
        <i class="bi bi-speedometer2"></i> Dashboard
    </a>
    <a href="<%=request.getContextPath()%>/clientes.jsp">
        <i class="bi bi-people"></i> Clientes
    </a>
    <a href="<%=request.getContextPath()%>/productos.jsp">
        <i class="bi bi-box"></i> Productos
    </a>
    <a href="<%=request.getContextPath()%>/proveedores.jsp">
        <i class="bi bi-truck"></i> Proveedores
    </a>
    <a href="<%=request.getContextPath()%>/cabeceradetalle.jsp">
        <i class="bi bi-bag"></i> Compras
    </a>
    <a href="<%=request.getContextPath()%>/ventavista.jsp">
        <i class="bi bi-cart"></i> Ventas
    </a>
    <a href="<%=request.getContextPath()%>/seguimientos.jsp">
        <i class="bi bi-telephone"></i> Seguimientos
    </a>
    <a href="<%=request.getContextPath()%>/tareas.jsp">
        <i class="bi bi-check2-square"></i> Tareas
    </a>
    <a href="<%=request.getContextPath()%>/reportes.jsp">
        <i class="bi bi-bar-chart"></i> Reportes
    </a>
    <a href="<%=request.getContextPath()%>/usuarios.jsp">
        <i class="bi bi-person-gear"></i> Usuarios
    </a>
    <hr>
    <a href="<%=request.getContextPath()%>/logout.jsp">
        <i class="bi bi-box-arrow-right"></i> Salir
    </a>
</div>
        