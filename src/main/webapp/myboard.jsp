<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.example.noticeboard.Notice" %>
<%@ page import="com.example.noticeboard.NoticeDirectory" %>
<%@ page import="com.example.noticeboard.User" %>
<%@ page import="com.example.noticeboard.UserDirectory" %>
<%@ page import="com.example.noticeboard.DataConstants" %>
<%@ page import="java.util.List" %>
<%
    String currentUser = (String) session.getAttribute("username");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    User userObj = UserDirectory.getUserByUsername(currentUser);
    if (userObj == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String interestsStr = (userObj.getInterests() != null) ? String.join(", ", userObj.getInterests()) : "";
    String hobbiesStr = (userObj.getHobbies() != null) ? String.join(", ", userObj.getHobbies()) : "";

    String avatarUrl = (userObj.getProfilePictureUrl() != null && !userObj.getProfilePictureUrl().isBlank())
            ? userObj.getProfilePictureUrl()
            : "https://ui-avatars.com/api/?name=" + currentUser + "&background=1e3a8a&color=fff";

    String userCampus = (userObj.getCampus() != null) ? userObj.getCampus() : "Botswana Accountancy College";
    String userLocation = (userObj.getLocation() != null) ? userObj.getLocation() : "Unknown Location";

    String errorParam = request.getParameter("error");
    String statusParam = request.getParameter("status");
    String tabParam = request.getParameter("tab");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Dashboard & Settings</title>
    <link rel="stylesheet" href="css/noticeboard.css">
    <style>
        .tag {
            display: inline-block; background: #e2e8f0; color: #1e293b; padding: 4px 10px;
            border-radius: 12px; font-size: 0.85rem; margin: 3px; font-weight: 500;
        }
        .dashboard-layout {
            display: flex;
            gap: 24px;
            margin-top: 20px;
            align-items: flex-start;
        }
        .sidebar {
            width: 260px;
            background: var(--card-bg);
            padding: 20px;
            border-radius: 12px;
            border: 1px solid var(--border-color);
            position: sticky;
            top: 20px;
        }
        .sidebar-menu { list-style: none; padding: 0; margin: 0; }
        .sidebar-menu li { margin-bottom: 10px; }
        .sidebar-link {
            display: block;
            padding: 12px 16px;
            border-radius: 8px;
            color: var(--text-main);
            text-decoration: none;
            font-weight: 500;
            transition: all 0.2s ease;
            background: rgba(0,0,0,0.02);
            border: 1px solid transparent;
            cursor: pointer;
        }
        .sidebar-link:hover {
            background: var(--bg-color);
            border-color: var(--border-color);
            color: var(--primary-blue);
        }
        .sidebar-link.active {
            background: var(--primary-blue);
            color: #fff;
            border-color: var(--primary-blue);
        }
        .main-content {
            flex: 1;
            min-width: 0;
            background: var(--card-bg);
            padding: 2.5rem;
            border-radius: 12px;
            border: 1px solid var(--border-color);
        }
        .alert-banner {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 0.95rem;
        }
        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #f87171; }
        .alert-success { background: #dcfce7; color: #166534; border: 1px solid #4ade80; }
        .form-group input[type="text"], .form-group input[type="email"], .form-group input[type="password"], .form-group input[type="file"], .form-group select {
            width: 100%;
            box-sizing: border-box;
        }
        @media (max-width: 768px) {
            .dashboard-layout { flex-direction: column; }
            .sidebar { width: 100%; position: static; }
        }
    </style>
    <script>
        function switchTab(tabId) {
            document.querySelectorAll('.sidebar-link').forEach(link => link.classList.remove('active'));
            var activeLink = document.getElementById('tab-' + tabId);
            if (activeLink) activeLink.classList.add('active');

            document.getElementById('content-overview').style.display = 'none';
            document.getElementById('content-edit').style.display = 'none';
            document.getElementById('content-security').style.display = 'none';

            if (tabId === 'overview') {
                document.getElementById('content-overview').style.display = 'block';
            } else if (tabId === 'edit') {
                document.getElementById('content-edit').style.display = 'block';
            } else if (tabId === 'security') {
                document.getElementById('content-security').style.display = 'block';
            }
        }

        function previewAvatar(event) {
            const input = event.target;
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const preview = document.getElementById('avatarPreview');
                    if (preview) {
                        preview.src = e.target.result;
                    }
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        window.onload = function() {
            let hash = window.location.hash.substring(1);
            let urlTab = "<%= tabParam != null ? tabParam : "" %>";
            let activeTab = hash || urlTab;

            if (activeTab === 'edit' || activeTab === 'security') {
                switchTab(activeTab);
            } else {
                switchTab('overview');
            }
        };
    </script>
</head>
<body>
<div class="container">
    <header class="board-header">
        <h1 style="color: var(--primary-blue); font-size: 1.5rem; margin: 0;">My Dashboard</h1>
        <div>
            <a href="board.jsp" class="btn-post" style="background-color: var(--text-muted); color: white;">Back to Board</a>
        </div>
    </header>

    <% if ("invalidpassword".equals(errorParam)) { %>
    <div class="alert-banner alert-error">Incorrect old password. Changes were not saved.</div>
    <% } else if ("usernametaken".equals(errorParam)) { %>
    <div class="alert-banner alert-error">The requested username is already taken.</div>
    <% } else if ("updated".equals(statusParam)) { %>
    <div class="alert-banner alert-success">Your profile details were updated successfully.</div>
    <% } else if ("password_updated".equals(statusParam)) { %>
    <div class="alert-banner alert-success">Your password was changed successfully.</div>
    <% } else if ("notice_updated".equals(statusParam)) { %>
    <div class="alert-banner alert-success">Notice updated successfully.</div>
    <% } else if ("notice_deleted".equals(statusParam)) { %>
    <div class="alert-banner alert-success">Notice deleted successfully.</div>
    <% } %>

    <div class="dashboard-layout">
        <!-- LEFT SIDEBAR -->
        <aside class="sidebar">
            <div style="text-align: center; margin-bottom: 20px;">
                <img src="<%= avatarUrl %>" alt="Profile Picture" style="width:80px; height:80px; border-radius:50%; object-fit:cover; border:3px solid var(--bg-color); box-shadow:0 2px 4px rgba(0,0,0,0.1);">
                <h3 style="margin: 10px 0 5px 0; font-size: 1.2rem; color: var(--text-main);"><%= currentUser %></h3>
                <span class="tag" style="background: var(--accent-blue); color: white;"><%= userCampus %></span>
            </div>
            <ul class="sidebar-menu">
                <li><a id="tab-overview" onclick="switchTab('overview')" class="sidebar-link active">Overview</a></li>
                <li><a id="tab-edit" onclick="switchTab('edit')" class="sidebar-link">Edit Profile</a></li>
                <li><a id="tab-security" onclick="switchTab('security')" class="sidebar-link">Change Password</a></li>
            </ul>
        </aside>

        <!-- MAIN CONTENT -->
        <main class="main-content">

            <!-- OVERVIEW TAB -->
            <div id="content-overview">
                <div class="profile-header" style="display:flex; flex-direction:column; align-items:center; padding-bottom: 2rem; border-bottom: 1px solid var(--border-color); margin-bottom:2rem;">
                    <img src="<%= avatarUrl %>" class="profile-avatar" alt="Profile Picture" style="width:120px; height:120px; border-radius:50%; object-fit:cover; border:4px solid var(--bg-color); box-shadow:0 4px 6px -1px rgba(0,0,0,0.1); margin-bottom:1rem;">
                    <h2 style="margin-bottom: 5px; font-size: 1.8rem;"><%= currentUser %></h2>
                    <p style="color: var(--text-muted); font-size: 1.1rem; margin-bottom: 15px; text-align: center;">
                        <%= userCampus %> <br> <%= userLocation %>
                    </p>

                    <div style="display: flex; gap: 20px; background: rgba(0,0,0,0.03); padding: 15px; border-radius: 8px; width: 100%; max-width: 600px; justify-content: center; text-align: center;">
                        <div style="flex: 1;">
                            <strong style="color: var(--primary-blue); display:block; margin-bottom: 8px;">Interests</strong>
                            <% if(userObj != null && userObj.getInterests() != null && !userObj.getInterests().isEmpty()) {
                                for(String interest : userObj.getInterests()) { %>
                            <span class="tag"><%= interest %></span>
                            <%     }
                            } else { %> <span style="font-size: 0.9rem; color: #64748b;">None listed</span> <% } %>
                        </div>
                        <div style="flex: 1; border-left: 1px solid var(--border-color);">
                            <strong style="color: var(--primary-blue); display:block; margin-bottom: 8px;">Hobbies</strong>
                            <% if(userObj != null && userObj.getHobbies() != null && !userObj.getHobbies().isEmpty()) {
                                for(String hobby : userObj.getHobbies()) { %>
                            <span class="tag"><%= hobby %></span>
                            <%     }
                            } else { %> <span style="font-size: 0.9rem; color: #64748b;">None listed</span> <% } %>
                        </div>
                    </div>
                </div>

                <h2 style="color: var(--text-main); margin-bottom: 20px; font-size: 1.3rem;">My Posted Notices</h2>
                <div class="notice-grid">
                    <%
                        List<Notice> userNotices = NoticeDirectory.getByAuthor(currentUser);
                        if (userNotices.isEmpty()) {
                    %>
                    <div style="grid-column: 1 / -1; text-align: center; padding: 40px; background: var(--card-bg); border-radius: 12px; border: 1px solid var(--border-color);">
                        <p style="color: var(--text-muted);">You haven't posted any notices yet.</p>
                    </div>
                    <% } else { %>
                    <% for (Notice n : userNotices) {
                        String categoryClass = "badge-" + n.getCategory().split(" ")[0].toLowerCase();
                        String expiredClass = n.isExpired() ? "expired-notice" : "";
                        String noticeId = n.getId();
                    %>
                    <div class="notice-card <%= expiredClass %>">
                        <div>
                            <% if (n.getPrimaryImage() != null && !n.getPrimaryImage().isBlank()) { %>
                            <img src="<%= n.getPrimaryImage() %>" class="thumbnail" alt="Notice Image" style="width:100%; height:150px; object-fit:cover; border-radius:6px; margin-bottom:1rem;">
                            <% } %>
                            <div class="card-meta">
                                <span class="badge <%= categoryClass %>"><%= n.getCategory() %></span>
                                <% if (n.isExpired()) { %> <span class="expired-label">EXPIRED</span> <% } %>
                            </div>
                            <h3 class="card-title"><%= n.getTitle() %></h3>
                            <p class="card-body" style="display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;"><%= n.getBody() %></p>
                        </div>
                        <div class="card-footer" style="margin-top: 15px; border-top: 1px solid var(--border-color); padding-top: 15px; display: flex; justify-content: space-between; align-items: center;">
                            <div style="font-size: 0.85rem;">
                                <span>Posted: <%= n.getDatePosted() %></span><br>
                                <span style="color: #ef4444;">Expires: <%= n.getExpiryDate() %></span>
                            </div>
                            <div style="display: flex; gap: 8px; align-items: center;">
                                <a href="edit-notice.jsp?id=<%= noticeId %>" class="btn-post" style="padding: 5px 12px; font-size: 0.85rem; background: var(--primary-blue); color: white; text-decoration: none;">Edit</a>
                                <form action="delete-notice-handler" method="post" style="margin: 0; display: inline-flex;">
                                    <input type="hidden" name="noticeId" value="<%= noticeId %>">
                                    <button type="submit" class="btn-post" style="padding: 5px 12px; font-size: 0.85rem; background-color: #ef4444; color: white; border: none; cursor: pointer;" onclick="return confirm('Delete this notice permanently?');">Delete</button>
                                </form>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    <% } %>
                </div>
            </div>

            <!-- EDIT PROFILE TAB (SEPARATE FORM) -->
            <div id="content-edit" style="display: none;">
                <form id="form-edit-profile" action="update-profile-handler" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="targetTab" value="edit">

                    <h2 style="color: var(--primary-blue); font-size: 1.8rem; margin-bottom: 25px; border-bottom: 2px solid var(--border-color); padding-bottom: 10px;">Edit Profile</h2>

                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="username" value="<%= userObj.getUsername() %>" required>
                    </div>

                    <div class="form-group">
                        <label>Profile Picture</label>
                        <div style="display: flex; align-items: center; gap: 15px; margin-bottom: 10px;">
                            <img id="avatarPreview" src="<%= avatarUrl %>" alt="Profile Picture Preview" style="width: 70px; height: 70px; border-radius: 50%; object-fit: cover; border: 2px solid var(--border-color); box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                            <span style="font-size: 0.85rem; color: var(--text-muted);">Preview of your avatar</span>
                        </div>
                        <input type="file" name="profilePicture" accept="image/*" onchange="previewAvatar(event)">
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email" value="<%= userObj.getEmail() %>" required>
                    </div>

                    <div class="form-group">
                        <label>Campus</label>
                        <select name="campus" required>
                            <% for(String c : DataConstants.CAMPUSES) { %>
                            <option value="<%= c %>" <%= c.equals(userObj.getCampus()) ? "selected" : "" %>><%= c %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Location</label>
                        <select name="location" required>
                            <% for(String loc : DataConstants.LOCATIONS) { %>
                            <option value="<%= loc %>" <%= loc.equals(userObj.getLocation()) ? "selected" : "" %>><%= loc %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Interests (comma separated)</label>
                        <input type="text" name="interests" value="<%= interestsStr %>">
                    </div>

                    <div class="form-group">
                        <label>Hobbies (comma separated)</label>
                        <input type="text" name="hobbies" value="<%= hobbiesStr %>">
                    </div>

                    <button type="submit" class="btn-submit" style="width: 100%; margin-top: 15px;">Save Changes</button>
                </form>
            </div>

            <!-- SECURITY TAB (SEPARATE FORM) -->
            <div id="content-security" style="display: none;">
                <form id="form-security" action="update-profile-handler" method="post">
                    <input type="hidden" name="targetTab" value="security">

                    <h2 style="color: var(--primary-blue); font-size: 1.8rem; margin-bottom: 25px; border-bottom: 2px solid var(--border-color); padding-bottom: 10px;">Security</h2>

                    <div class="form-group">
                        <label>Current Password</label>
                        <input type="password" name="oldPassword" placeholder="Enter current password" required>
                    </div>
                    <div class="form-group">
                        <label>New Password</label>
                        <input type="password" name="newPassword" placeholder="Enter new password" required>
                    </div>

                    <button type="submit" class="btn-submit" style="width: 100%; margin-top: 15px;">Save Changes</button>
                </form>
            </div>

        </main>
    </div>
</div>
</body>
</html>