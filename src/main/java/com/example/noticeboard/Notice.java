package com.example.noticeboard;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Notice {
    private String id;
    private String title;
    private String body;
    private String institution;
    private String campus;
    private String location;
    private String category;
    private List<String> imageUrls = new ArrayList<>();
    private LocalDate datePosted;
    private LocalDate expiryDate;
    private String author;

    public Notice() {}

    public Notice(String title, String body, String institution, String campus, String location, String category, List<String> imageUrls, String author) {
        this.id = "NOT-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        this.title = title;
        this.body = body;
        this.institution = institution;
        this.campus = campus;
        this.location = location;
        this.category = category;
        if (imageUrls != null) {
            this.imageUrls.addAll(imageUrls);
        }
        this.datePosted = LocalDate.now();
        this.expiryDate = this.datePosted.plusDays(2);
        this.author = (author == null || author.isBlank()) ? "Anonymous" : author;
    }

    public Notice(String title, String body, String institution, String campus, String location, String category, List<String> imageUrls, String author, int daysOld) {
        this(title, body, institution, campus, location, category, imageUrls, author);
        this.datePosted = LocalDate.now().minusDays(daysOld);
        this.expiryDate = this.datePosted.plusDays(2);
    }

    public boolean isExpired() { return LocalDate.now().isAfter(expiryDate); }

    public String getId() { return id; }
    public String getTitle() { return title; }
    public String getBody() { return body; }
    public String getInstitution() { return institution; }
    public String getCampus() { return campus; }
    public String getLocation() { return location; }
    public String getCategory() { return category; }
    public List<String> getImageUrls() { return imageUrls; }

    // Helper to fetch primary cover photo
    public String getPrimaryImage() {
        return imageUrls.isEmpty() ? null : imageUrls.get(0);
    }

    public LocalDate getDatePosted() { return datePosted; }
    public LocalDate getExpiryDate() { return expiryDate; }
    public String getAuthor() { return author; }

    public void setTitle(String title) { this.title = title; }
    public void setBody(String body) { this.body = body; }
    public void setInstitution(String institution) { this.institution = institution; }
    public void setCampus(String campus) { this.campus = campus; }
    public void setLocation(String location) { this.location = location; }
    public void setCategory(String category) { this.category = category; }
    public void setImageUrls(List<String> imageUrls) {
        this.imageUrls = imageUrls != null ? imageUrls : new ArrayList<>();
    }
    public void setAuthor(String author) { this.author = author; }
}