package com.example.noticeboard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@WebServlet("/edit-notice-handler")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 25)
public class EditNoticeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String currentUsername = (String) request.getSession().getAttribute("username");
        if (currentUsername == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String noticeId = request.getParameter("noticeId");
        Notice notice = NoticeDirectory.getById(noticeId);

        if (notice == null || !notice.getAuthor().equalsIgnoreCase(currentUsername)) {
            response.sendRedirect("myboard.jsp?error=unauthorized");
            return;
        }

        notice.setTitle(request.getParameter("title"));
        notice.setBody(request.getParameter("body"));
        notice.setCampus(request.getParameter("campus"));
        notice.setLocation(request.getParameter("location"));
        notice.setCategory(request.getParameter("category"));

        // 1. Retain existing images kept by user
        String[] keptImages = request.getParameterValues("existingImages");
        List<String> finalImages = new ArrayList<>();
        if (keptImages != null) {
            for (String img : keptImages) {
                if (finalImages.size() < 4) finalImages.add(img);
            }
        }

        // 2. Process newly uploaded images
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        for (Part part : request.getParts()) {
            if (part.getName().equals("noticeImages") && part.getSize() > 0) {
                if (finalImages.size() >= 4) break; // Enforce max 4

                String originalFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                String uniqueFileName = UUID.randomUUID().toString().substring(0, 8) + "_" + originalFileName;

                part.write(uploadPath + File.separator + uniqueFileName);
                finalImages.add("uploads/" + uniqueFileName);
            }
        }

        notice.setImageUrls(finalImages);
        NoticeDirectory.update(notice);
        response.sendRedirect("myboard.jsp?status=notice_updated");
    }
}