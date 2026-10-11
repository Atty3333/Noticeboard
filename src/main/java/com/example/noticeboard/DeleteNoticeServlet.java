package com.example.noticeboard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/delete-notice-handler")
public class DeleteNoticeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String currentUsername = (String) request.getSession().getAttribute("username");
        if (currentUsername == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String noticeId = request.getParameter("noticeId");
        Notice notice = NoticeDirectory.getById(noticeId);

        if (notice != null && notice.getAuthor().equalsIgnoreCase(currentUsername)) {
            NoticeDirectory.delete(noticeId);
        }

        response.sendRedirect("myboard.jsp?status=notice_deleted");
    }
}