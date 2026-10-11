package com.example.noticeboard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/update-profile-handler")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 5, maxRequestSize = 1024 * 1024 * 10)
public class UpdateProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String currentUsername = (String) session.getAttribute("username");

        if (currentUsername == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = UserDirectory.getUserByUsername(currentUsername);
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String targetTab = request.getParameter("targetTab");

        // SECURITY TAB ACTION
        if ("security".equalsIgnoreCase(targetTab)) {
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");

            if (oldPassword == null || !user.getPassword().equals(oldPassword)) {
                response.sendRedirect("myboard.jsp?error=invalidpassword&tab=security#security");
                return;
            }

            if (newPassword != null && !newPassword.isBlank()) {
                user.setPassword(newPassword);
                UserDirectory.updateUser(user);
            }

            response.sendRedirect("myboard.jsp?status=password_updated&tab=security#security");
            return;
        }

        // EDIT PROFILE TAB ACTION
        String newUsername = request.getParameter("username");
        String email = request.getParameter("email");
        String campus = request.getParameter("campus");
        String location = request.getParameter("location");
        String rawInterests = request.getParameter("interests");
        String rawHobbies = request.getParameter("hobbies");

        if (newUsername != null && !newUsername.equalsIgnoreCase(currentUsername)) {
            if (UserDirectory.getUserByUsername(newUsername) != null) {
                response.sendRedirect("myboard.jsp?error=usernametaken&tab=edit#edit");
                return;
            }
            NoticeDirectory.updateAuthor(currentUsername, newUsername);
            user.setUsername(newUsername);
            session.setAttribute("username", newUsername);
        }

        if (email != null) user.setEmail(email);
        if (campus != null) user.setCampus(campus);
        if (location != null) user.setLocation(location);

        if (rawInterests != null) {
            List<String> interests = Arrays.stream(rawInterests.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toList());
            user.setInterests(interests);
        }

        if (rawHobbies != null) {
            List<String> hobbies = Arrays.stream(rawHobbies.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toList());
            user.setHobbies(hobbies);
        }

        Part avatarPart = request.getPart("profilePicture");
        if (avatarPart != null && avatarPart.getSize() > 0) {
            String fileName = Paths.get(avatarPart.getSubmittedFileName()).getFileName().toString();
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            avatarPart.write(uploadPath + File.separator + fileName);
            user.setProfilePictureUrl("uploads/" + fileName);
        }

        UserDirectory.updateUser(user);
        response.sendRedirect("myboard.jsp?status=updated&tab=edit#edit");
    }
}