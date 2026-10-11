<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - Campus Noticeboard</title>
    <link rel="stylesheet" href="css/noticeboard.css">
</head>
<body style="display: flex; align-items: center; min-height: 100vh;">
<div class="container" style="width: 100%; max-width: 420px;">
    <div class="form-card">
        <div style="text-align: center; margin-bottom: 25px;">
            <h2 style="color: var(--primary-blue); font-size: 1.8rem; margin: 0;">Welcome Back</h2>
            <p style="color: var(--text-muted); font-size: 0.9rem;">Sign in to your account</p>
        </div>

        <% if ("invalid".equals(request.getParameter("error"))) { %>
        <div style="color: black;  padding: 12px; border-radius: 8px; margin-bottom: 20px; text-align: center; font-weight: 600;">
            Invalid username or password.
        </div>
        <% } %>

        <form action="login-handler.jsp" method="post">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required>
            </div>

            <button type="submit" class="btn-submit" style="margin-top: 10px;">Sign In</button>
        </form>

        <p style="text-align: center; margin-top: 25px; font-size: 0.95rem;">
            No account yet? <a href="signup.jsp" style="color: var(--accent-blue); font-weight: 600; text-decoration: none;">Create one</a><br><br>
            <a href="board.jsp" style="color: var(--text-muted); text-decoration: none; font-size: 0.85rem;">← Return to Board</a>
        </p>
    </div>
</div>
</body>
</html>