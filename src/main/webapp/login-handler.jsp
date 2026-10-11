<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.example.noticeboard.User" %>
<%@ page import="com.example.noticeboard.UserDirectory" %>
<%
    request.setCharacterEncoding("UTF-8");
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    User user = UserDirectory.authenticate(username, password);

    if (user != null) {
        // Successful login: Bind username to the session
        session.setAttribute("username", user.getUsername());
        response.sendRedirect("board.jsp");
    } else {
        // Failed login
        response.sendRedirect("login.jsp?error=invalid");
    }
%>