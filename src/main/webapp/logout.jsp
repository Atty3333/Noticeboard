<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Destroy the session and all its attributes
    session.invalidate();
    response.sendRedirect("board.jsp");
%>