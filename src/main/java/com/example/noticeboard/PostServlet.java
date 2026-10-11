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

@WebServlet("/post-handler")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 25)
public class PostServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String title = request.getParameter("title");
        String body = request.getParameter("body");
        String campus = request.getParameter("campus");
        String location = request.getParameter("location");
        String category = request.getParameter("category");
        boolean anonymous = request.getParameter("anonymous") != null;
        String author = anonymous ? "Anonymous" : (String) request.getSession().getAttribute("username");

        List<String> uploadedImages = new ArrayList<>();
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();

        // Process multiple files
        for (Part part : request.getParts()) {
            if (part.getName().equals("noticeImages") && part.getSize() > 0) {
                if (uploadedImages.size() >= 4) break; // Enforce max 4 images

                String originalFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                String uniqueFileName = UUID.randomUUID().toString().substring(0, 8) + "_" + originalFileName;

                part.write(uploadPath + File.separator + uniqueFileName);
                uploadedImages.add("uploads/" + uniqueFileName);
            }
        }

        Notice notice = new Notice(title, body, campus, campus, location, category, uploadedImages, author);
        NoticeDirectory.add(notice);

        response.sendRedirect("board.jsp");
    }
}