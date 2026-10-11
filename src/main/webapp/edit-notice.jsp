<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.example.noticeboard.Notice" %>
<%@ page import="com.example.noticeboard.NoticeDirectory" %>
<%@ page import="com.example.noticeboard.DataConstants" %>
<%@ page import="java.util.List" %>
<%
    String currentUser = (String) session.getAttribute("username");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String noticeId = request.getParameter("id");
    Notice notice = NoticeDirectory.getById(noticeId);

    if (notice == null || !notice.getAuthor().equalsIgnoreCase(currentUser)) {
        response.sendRedirect("myboard.jsp?error=invalid_notice");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Notice</title>
    <link rel="stylesheet" href="css/noticeboard.css">
    <style>
        .form-container {
            max-width: 650px;
            margin: 40px auto;
            background: var(--card-bg);
            padding: 30px;
            border-radius: 12px;
            border: 1px solid var(--border-color);
        }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; }
        .form-group input, .form-group textarea, .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            box-sizing: border-box;
        }
        .image-preview-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-top: 10px;
        }
        .preview-slot {
            position: relative;
            width: 100%;
            padding-top: 100%;
            border-radius: 8px;
            background: #f8fafc;
            border: 1px solid var(--border-color);
            overflow: hidden;
        }
        .preview-slot img {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .remove-img-btn {
            position: absolute;
            top: 4px;
            right: 4px;
            background: #ef4444;
            color: white;
            border: none;
            border-radius: 50%;
            width: 22px;
            height: 22px;
            cursor: pointer;
            font-size: 14px;
            line-height: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 10;
        }
        .custom-file-upload {
            display: block;
            text-align: center;
            padding: 12px;
            background: #f8fafc;
            border: 2px dashed var(--border-color);
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            color: var(--text-dark);
        }
    </style>
</head>
<body>
<div class="container">
    <div class="form-container">
        <h2 style="color: var(--primary-blue); margin-bottom: 20px;">Edit Notice</h2>
        <form id="editNoticeForm" action="edit-notice-handler" method="post" enctype="multipart/form-data">
            <input type="hidden" name="noticeId" value="<%= notice.getId() %>">

            <div class="form-group">
                <label for="title">Title</label>
                <input type="text" id="title" name="title" value="<%= notice.getTitle() %>" required>
            </div>

            <div class="form-group">
                <label for="category">Category</label>
                <select id="category" name="category" required>
                    <% for(String cat : DataConstants.CATEGORIES) { %>
                    <option value="<%= cat %>" <%= cat.equals(notice.getCategory()) ? "selected" : "" %>><%= cat %></option>
                    <% } %>
                </select>
            </div>

            <div class="form-group">
                <label for="campus">Campus</label>
                <select id="campus" name="campus" required>
                    <% for(String c : DataConstants.CAMPUSES) { %>
                    <option value="<%= c %>" <%= c.equals(notice.getCampus()) ? "selected" : "" %>><%= c %></option>
                    <% } %>
                </select>
            </div>

            <div class="form-group">
                <label for="location">Location</label>
                <select id="location" name="location" required>
                    <% for(String loc : DataConstants.LOCATIONS) { %>
                    <option value="<%= loc %>" <%= loc.equals(notice.getLocation()) ? "selected" : "" %>><%= loc %></option>
                    <% } %>
                </select>
            </div>

            <div class="form-group">
                <label for="body">Body</label>
                <textarea id="body" name="body" rows="5" required><%= notice.getBody() %></textarea>
            </div>

            <div class="form-group">
                <label>Current & New Photos (Max 4 Total)</label>
                <div class="image-preview-grid" id="existingGrid">
                    <%
                        List<String> images = notice.getImageUrls();
                        for (int i = 0; i < images.size(); i++) {
                            String imgUrl = images.get(i);
                    %>
                    <div class="preview-slot" id="existing-slot-<%= i %>">
                        <img src="<%= imgUrl %>" alt="Notice Photo">
                        <input type="hidden" name="existingImages" value="<%= imgUrl %>">
                        <button type="button" class="remove-img-btn" onclick="removeExistingImage('existing-slot-<%= i %>')">&times;</button>
                    </div>
                    <% } %>
                </div>

                <label for="noticeImages" class="custom-file-upload" style="margin-top: 15px;">
                    ➕ Upload Additional Photos
                </label>
                <input type="file" id="noticeImages" name="noticeImages" accept="image/*" multiple style="display: none;">

                <div class="image-preview-grid" id="newPreviewGrid"></div>
                <p id="imageError" style="color: #ef4444; font-size: 0.85rem; display: none; margin-top: 8px;">Total combined images cannot exceed 4.</p>
            </div>

            <div style="display: flex; gap: 10px; margin-top: 20px;">
                <button type="submit" class="btn-submit" style="flex: 1;">Save Changes</button>
                <a href="myboard.jsp" class="btn-post" style="background: var(--text-muted); text-align: center; text-decoration: none; line-height: 2.2;">Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
    const fileInput = document.getElementById('noticeImages');
    const newPreviewGrid = document.getElementById('newPreviewGrid');
    const errorMsg = document.getElementById('imageError');
    let selectedNewFiles = [];

    function getExistingCount() {
        return document.querySelectorAll('input[name="existingImages"]').length;
    }

    function removeExistingImage(slotId) {
        const slot = document.getElementById(slotId);
        if (slot) {
            slot.remove();
        }
        errorMsg.style.display = 'none';
    }

    fileInput.addEventListener('change', function(e) {
        const newFiles = Array.from(e.target.files);
        const currentTotal = getExistingCount() + selectedNewFiles.length;

        if (currentTotal + newFiles.length > 4) {
            errorMsg.style.display = 'block';
            return;
        }
        errorMsg.style.display = 'none';

        newFiles.forEach(file => {
            if (getExistingCount() + selectedNewFiles.length < 4) {
                selectedNewFiles.push(file);
            }
        });

        updateNewFileInputAndPreviews();
    });

    function removeNewFile(index) {
        selectedNewFiles.splice(index, 1);
        errorMsg.style.display = 'none';
        updateNewFileInputAndPreviews();
    }

    function updateNewFileInputAndPreviews() {
        const dt = new DataTransfer();
        selectedNewFiles.forEach(file => dt.items.add(file));
        fileInput.files = dt.files;

        newPreviewGrid.innerHTML = '';
        selectedNewFiles.forEach((file, idx) => {
            const slot = document.createElement('div');
            slot.className = 'preview-slot';

            const img = document.createElement('img');
            img.src = URL.createObjectURL(file);

            const removeBtn = document.createElement('button');
            removeBtn.type = 'button';
            removeBtn.className = 'remove-img-btn';
            removeBtn.innerHTML = '&times;';
            removeBtn.onclick = () => removeNewFile(idx);

            slot.appendChild(img);
            slot.appendChild(removeBtn);
            newPreviewGrid.appendChild(slot);
        });
    }
</script>
</body>
</html>