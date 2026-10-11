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
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/signup-handler")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 5, maxRequestSize = 1024 * 1024 * 10)
public class SignupServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String campus = request.getParameter("campus");
        String location = request.getParameter("location");

        List<String> interests = parseCommaSeparated(request.getParameter("interests"));
        List<String> hobbies = parseCommaSeparated(request.getParameter("hobbies"));

        Part filePart = request.getPart("profilePicture");
        String fileName = null;

        if (filePart != null && filePart.getSize() > 0) {
            fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();
            filePart.write(uploadPath + File.separator + fileName);
            fileName = "uploads/" + fileName;
        }

        if (username != null && !username.isBlank() && password != null && !password.isBlank()) {
            User newUser = new User(username, email, password, fileName, campus, location, interests, hobbies);
            if (UserDirectory.register(newUser)) {
                request.getSession().setAttribute("username", username);
                request.getSession().setAttribute("userObj", newUser);
                response.sendRedirect("board.jsp");
                return;
            } else {
                response.sendRedirect("signup.jsp?error=exists");
                return;
            }
        }
        response.sendRedirect("signup.jsp");
    }

    private List<String> parseCommaSeparated(String input) {
        if (input == null || input.isBlank()) return List.of();
        return Arrays.stream(input.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
    }
}