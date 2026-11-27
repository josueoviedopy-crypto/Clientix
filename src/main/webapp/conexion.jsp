<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%
    Connection conn = null;

    Class.forName("org.postgresql.Driver");
    conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyecto_edgar", "postgres", "1");
    if (conn != null) {
        out.print("conectado");
    }
%>
