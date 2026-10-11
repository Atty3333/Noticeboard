<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.example.noticeboard.Notice" %>
<%@ page import="com.example.noticeboard.NoticeDirectory" %>
<%@ page import="com.example.noticeboard.DataConstants" %>
<%@ page import="java.util.List" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Noticeboard</title>
    <link rel="stylesheet" href="css/noticeboard.css">
    <style>
        .photo-badge {
            position: absolute;
            top: 8px;
            right: 8px;
            background: rgba(15, 23, 42, 0.85);
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .modal-gallery {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
            margin-top: 15px;
        }
        .modal-gallery.single-img {
            grid-template-columns: 1fr;
        }
        .modal-gallery img {
            width: 100%;
            height: 220px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid var(--border-color);
        }
        .filter-bar {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }
        .filter-bar input, .filter-bar select {
            padding: 8px 12px;
            border: 1px solid var(--border-color, #cbd5e1);
            border-radius: 6px;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
<div class="container">
    <header class="board-header">
        <h1>Noticeboard</h1>
        <div style="display: flex; gap: 10px; align-items: center;">
            <a href="post-notice.jsp" class="btn-post">+ Post Notice</a>
            <% if (session.getAttribute("username") != null) { %>
            <a href="myboard.jsp" class="btn-post" style="background-color: #64748b;">My Board</a>
            <a href="logout.jsp" class="btn-post" style="background-color: #ef4444;">Logout</a>
            <% } else { %>
            <a href="login.jsp" class="btn-post" style="background-color: #64748b;">Sign In</a>
            <a href="signup.jsp" class="btn-post" style="background-color: var(--accent-blue);">Sign Up</a>
            <% } %>
        </div>
    </header>

    <%-- Filter Form with auto-trigger handlers --%>
    <form action="board.jsp" method="get" id="filterForm" class="filter-bar">
        <input type="text" id="keywordInput" name="keyword" placeholder="Search notices..." value="${param.keyword}" style="flex: 1; min-width: 200px;">

        <select name="campus" id="campusSelect">
            <option value="">All Campuses</option>
            <%
                String currentCampus = request.getParameter("campus");
                for (String campus : DataConstants.CAMPUSES) {
                    String selected = campus.equalsIgnoreCase(currentCampus) ? "selected" : "";
            %>
            <option value="<%= campus %>" <%= selected %>><%= campus %></option>
            <% } %>
        </select>

        <select name="location" id="locationSelect">
            <option value="">All Locations</option>
            <%
                String currentLocation = request.getParameter("location");
                for (String loc : DataConstants.LOCATIONS) {
                    String selected = loc.equalsIgnoreCase(currentLocation) ? "selected" : "";
            %>
            <option value="<%= loc %>" <%= selected %>><%= loc %></option>
            <% } %>
        </select>

        <select name="category" id="categorySelect">
            <option value="">All Categories</option>
            <%
                String currentCategory = request.getParameter("category");
                for (String cat : DataConstants.CATEGORIES) {
                    String selected = cat.equalsIgnoreCase(currentCategory) ? "selected" : "";
            %>
            <option value="<%= cat %>" <%= selected %>><%= cat %></option>
            <% } %>
        </select>

        <button type="submit" id="searchBtn">Search</button>
    </form>

    <main class="notice-grid">
        <%
            String filterCampus = request.getParameter("campus");
            String filterLocation = request.getParameter("location");
            String filterCategory = request.getParameter("category");
            String keyword = request.getParameter("keyword");
            List<Notice> notices = NoticeDirectory.search(filterCampus, filterLocation, filterCategory, keyword);
        %>

        <% if (notices.isEmpty()) { %>
        <p style="grid-column: 1 / -1; color: var(--text-muted);">No notices found matching your criteria.</p>
        <% } else { %>
        <% for (Notice n : notices) {
            String categoryClass = "badge-" + n.getCategory().split(" ")[0].toLowerCase();
            String expiredClass = n.isExpired() ? "expired-notice" : "";
            String safeBody = n.getBody().replace("\"", "&quot;");

            List<String> imageUrls = n.getImageUrls();
            String primaryImg = n.getPrimaryImage();
            int totalImages = imageUrls.size();

            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < imageUrls.size(); i++) {
                sb.append("&quot;").append(imageUrls.get(i)).append("&quot;");
                if (i < imageUrls.size() - 1) sb.append(",");
            }
            sb.append("]");
            String imagesJson = sb.toString();
        %>
        <div class="notice-card <%= expiredClass %>"
             data-title="<%= n.getTitle().replace("\"", "&quot;") %>"
             data-body="<%= safeBody %>"
             data-campus="<%= n.getCampus() %>"
             data-institution="<%= n.getInstitution() %>"
             data-category="<%= n.getCategory() %>"
             data-author="<%= n.getAuthor() %>"
             data-date="<%= n.getDatePosted() %>"
             data-images="<%= imagesJson %>"
             onclick="openModal(this)">

            <div>
                <% if (primaryImg != null && !primaryImg.isBlank()) { %>
                <div style="position: relative;">
                    <img src="<%= primaryImg %>" class="thumbnail" alt="Notice Image">
                    <% if (totalImages > 1) { %>
                    <span class="photo-badge">📷 1/<%= totalImages %></span>
                    <% } %>
                </div>
                <% } %>
                <div class="card-meta">
                    <span class="badge <%= categoryClass %>"><%= n.getCategory() %></span>
                    <% if (n.isExpired()) { %> <span class="expired-label">EXPIRED</span> <% } %>
                </div>
                <h3 class="card-title"><%= n.getTitle() %></h3>
                <p class="card-body" style="display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;"><%= n.getBody() %></p>
            </div>
            <div class="card-footer" style="margin-top: 15px;">
                <span><%= n.getInstitution() %> (<%= n.getLocation() %>)</span>
                <span>Posted: <%= n.getDatePosted() %></span>
            </div>
        </div>
        <% } %>
        <% } %>
    </main>
</div>

<!-- Notice Details Modal -->
<div class="modal-overlay" id="noticeModal" onclick="closeModal(event)">
    <div class="modal-content" onclick="event.stopPropagation()">
        <span class="close-modal" onclick="closeModal(event)">&times;</span>
        <div class="card-meta" style="margin-bottom: 10px;">
            <span class="badge" id="modalCategory" style="background: #e2e8f0; color: #1e293b; padding: 4px 8px; border-radius: 4px; font-size: 0.8rem;"></span>
        </div>
        <h2 id="modalTitle" style="margin-top: 0; color: var(--primary-blue);"></h2>
        <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 15px;">
            Posted by <strong id="modalAuthor"></strong> on <span id="modalDate"></span><br>
            <span id="modalLocation"></span>
        </p>
        <hr style="border: 0; border-top: 1px solid var(--border-color); margin-bottom: 15px;">
        <p id="modalBody" style="line-height: 1.6; white-space: pre-line;"></p>

        <div id="modalGallery" class="modal-gallery"></div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        const filterForm = document.getElementById('filterForm');
        const selects = filterForm.querySelectorAll('select');
        const keywordInput = document.getElementById('keywordInput');

        // Automatic submit on select change
        selects.forEach(select => {
            select.addEventListener('change', () => {
                filterForm.submit();
            });
        });

        // Debounced automatic submit on keyword input (350ms delay)
        let debounceTimer;
        keywordInput.addEventListener('input', () => {
            clearTimeout(debounceTimer);
            debounceTimer = setTimeout(() => {
                filterForm.submit();
            }, 350);
        });

        // Restore cursor position if user was typing in keyword search field
        if (keywordInput.value.length > 0 && document.activeElement !== keywordInput) {
            keywordInput.focus();
            const valLen = keywordInput.value.length;
            keywordInput.setSelectionRange(valLen, valLen);
        }
    });

    function openModal(element) {
        const modal = document.getElementById('noticeModal');
        document.getElementById('modalTitle').innerText = element.getAttribute('data-title');
        document.getElementById('modalBody').innerText = element.getAttribute('data-body');
        document.getElementById('modalCategory').innerText = element.getAttribute('data-category');
        document.getElementById('modalAuthor').innerText = element.getAttribute('data-author');
        document.getElementById('modalDate').innerText = element.getAttribute('data-date');
        document.getElementById('modalLocation').innerText = element.getAttribute('data-institution') + ' - ' + element.getAttribute('data-campus');

        const imagesRaw = element.getAttribute('data-images');
        const images = JSON.parse(imagesRaw || '[]');
        const gallery = document.getElementById('modalGallery');
        gallery.innerHTML = '';

        if (images.length > 0) {
            gallery.className = images.length === 1 ? 'modal-gallery single-img' : 'modal-gallery';
            images.forEach(src => {
                const img = document.createElement('img');
                img.src = src;
                gallery.appendChild(img);
            });
            gallery.style.display = 'grid';
        } else {
            gallery.style.display = 'none';
        }

        modal.style.display = 'flex';
    }

    function closeModal(event) {
        document.getElementById('noticeModal').style.display = 'none';
    }
</script>

</body>
</html>