<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.example.noticeboard.DataConstants" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Post a Notice</title>
    <link rel="stylesheet" href="css/noticeboard.css">
    <style>
        .image-preview-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-top: 12px;
        }
        .preview-slot {
            position: relative;
            width: 100%;
            padding-top: 100%;
            border-radius: 8px;
            background: #f8fafc;
            border: 2px dashed var(--border-color);
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
            padding: 14px;
            background: #f8fafc;
            border: 2px dashed var(--border-color);
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            color: var(--text-dark);
            transition: border-color 0.2s, background-color 0.2s;
        }
        .custom-file-upload:hover {
            border-color: var(--accent-blue);
            background: #f1f5f9;
        }
    </style>
</head>
<body style="display: flex; align-items: center; min-height: 100vh; padding: 20px 0;">
<div class="container" style="width: 100%; max-width: 600px;">
    <div class="form-card">
        <h2 style="margin-bottom: 25px; color: var(--primary-blue); font-size: 1.8rem; text-align: center;">Pin a New Notice</h2>

        <form id="postNoticeForm" action="post-handler" method="post" enctype="multipart/form-data">

            <div class="form-group">
                <label>Add Photos (1 to 4 Images)</label>
                <label for="noticeImages" class="custom-file-upload">
                    ➕ Choose Notice Images
                </label>
                <input type="file" id="noticeImages" name="noticeImages" accept="image/*" multiple style="display: none;">

                <div class="image-preview-grid" id="previewGrid"></div>
                <p id="imageError" style="color: #ef4444; font-size: 0.85rem; display: none; margin-top: 8px;">You can upload a maximum of 4 images.</p>
            </div>

            <div class="form-group">
                <label for="title">Headline *</label>
                <input type="text" id="title" name="title" placeholder="e.g. Selling textbook, Lost Keys..." required>
            </div>

            <div class="form-group">
                <label for="body">Message Details *</label>
                <textarea id="body" name="body" rows="6" placeholder="Provide full details here..." required></textarea>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                <div class="form-group">
                    <label for="campus">Campus *</label>
                    <select id="campus" name="campus" required>
                        <option value="">Select...</option>
                        <% for(String c : DataConstants.CAMPUSES) { %>
                        <option value="<%= c %>"><%= c %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="location">Location *</label>
                    <select id="location" name="location" required>
                        <option value="">Select...</option>
                        <% for(String loc : DataConstants.LOCATIONS) { %>
                        <option value="<%= loc %>"><%= loc %></option>
                        <% } %>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="category">Category *</label>
                <select id="category" name="category" required>
                    <option value="">Select Category...</option>
                    <% for(String cat : DataConstants.CATEGORIES) { %>
                    <option value="<%= cat %>"><%= cat %></option>
                    <% } %>
                </select>
            </div>

            <div class="form-group" style="display: flex; align-items: center; gap: 10px; background: #f8fafc; padding: 12px; border-radius: 8px;">
                <input type="checkbox" id="anonymous" name="anonymous" value="true" style="width: 20px; height: 20px;">
                <label for="anonymous" style="margin: 0; cursor: pointer;">Post Anonymously (Hide my name)</label>
            </div>

            <div style="display: flex; gap: 10px; margin-top: 30px;">
                <button type="submit" class="btn-submit" style="flex: 2;">📌 Publish Notice</button>
                <a href="board.jsp" class="btn-post" style="flex: 1; background-color: var(--text-muted); text-align: center; padding: 14px; font-size: 1rem;">Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
    const fileInput = document.getElementById('noticeImages');
    const previewGrid = document.getElementById('previewGrid');
    const errorMsg = document.getElementById('imageError');
    let selectedFiles = [];

    fileInput.addEventListener('change', function(e) {
        const newFiles = Array.from(e.target.files);
        if (selectedFiles.length + newFiles.length > 4) {
            errorMsg.style.display = 'block';
            return;
        }
        errorMsg.style.display = 'none';

        newFiles.forEach(file => {
            if (selectedFiles.length < 4) {
                selectedFiles.push(file);
            }
        });

        updateFileInputAndPreviews();
    });

    function removeFile(index) {
        selectedFiles.splice(index, 1);
        errorMsg.style.display = 'none';
        updateFileInputAndPreviews();
    }

    function updateFileInputAndPreviews() {
        const dt = new DataTransfer();
        selectedFiles.forEach(file => dt.items.add(file));
        fileInput.files = dt.files;

        previewGrid.innerHTML = '';
        selectedFiles.forEach((file, idx) => {
            const slot = document.createElement('div');
            slot.className = 'preview-slot';

            const img = document.createElement('img');
            img.src = URL.createObjectURL(file);

            const removeBtn = document.createElement('button');
            removeBtn.type = 'button';
            removeBtn.className = 'remove-img-btn';
            removeBtn.innerHTML = '&times;';
            removeBtn.onclick = () => removeFile(idx);

            slot.appendChild(img);
            slot.appendChild(removeBtn);
            previewGrid.appendChild(slot);
        });
    }
</script>
</body>
</html>