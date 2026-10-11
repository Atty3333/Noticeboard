<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.example.noticeboard.DataConstants" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - Campus Noticeboard</title>
    <link rel="stylesheet" href="css/noticeboard.css">
</head>
<body style="display: flex; align-items: center; min-height: 100vh;">
<div class="container" style="width: 100%; max-width: 500px;">
    <div class="form-card">
        <div style="text-align: center; margin-bottom: 25px;">
            <h2 style="color: var(--primary-blue); font-size: 1.8rem;">Create an Account</h2>
            <p style="color: var(--text-muted); font-size: 0.9rem;">Join the campus noticeboard</p>
        </div>

        <% if ("exists".equals(request.getParameter("error"))) { %>
        <div style="color: white; background: var(--danger); padding: 12px; border-radius: 8px; margin-bottom: 20px; text-align: center; font-weight: 600;">
            Username is already taken.
        </div>
        <% } %>

        <form action="signup-handler" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label>Profile Picture</label>
                <label for="profilePicture" class="custom-file-upload">
                    📷 Choose Image...
                </label>
                <input type="file" id="profilePicture" name="profilePicture" accept="image/*">
                <p id="fileNameDisplay" style="font-size: 0.8rem; color: var(--text-muted); margin-top: 5px; text-align: center;"></p>
            </div>

            <div class="form-group">
                <label for="username">Username *</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="email">Campus Email *</label>
                <input type="email" id="email" name="email" required>
            </div>
            <div class="form-group">
                <label for="password">Password *</label>
                <input type="password" id="password" name="password" required>
            </div>

            <div class="form-group">
                <label for="campus">Campus *</label>
                <select id="campus" name="campus" required>
                    <option value="">Select Campus...</option>
                    <% for(String c : DataConstants.CAMPUSES) { %>
                    <option value="<%= c %>"><%= c %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label for="location">Location (City) *</label>
                <select id="location" name="location" required>
                    <option value="">Select Location...</option>
                    <% for(String loc : DataConstants.LOCATIONS) { %>
                    <option value="<%= loc %>"><%= loc %></option>
                    <% } %>
                </select>
            </div>

            <!-- New Fields for Multiple Interests and Hobbies -->
            <div class="form-group">
                <label for="interests">Interests (comma separated)</label>
                <input type="text" id="interests" name="interests" placeholder="e.g., AI, Web Dev, Startups">
            </div>
            <div class="form-group">
                <label for="hobbies">Hobbies (comma separated)</label>
                <input type="text" id="hobbies" name="hobbies" placeholder="e.g., Hiking, Chess, Reading">
            </div>

            <button type="submit" class="btn-submit">Sign Up</button>
        </form>
        <p style="text-align: center; margin-top: 20px; font-size: 0.95rem;">
            Already have an account? <a href="login.jsp" style="color: var(--accent-blue); font-weight: 600; text-decoration: none;">Sign in here</a>
        </p>
    </div>
</div>

<script>
    document.getElementById('profilePicture').addEventListener('change', function() {
        var name = this.files[0] ? this.files[0].name : 'No file selected';
        document.getElementById('fileNameDisplay').textContent = name;
    });
</script>
</body>
</html>