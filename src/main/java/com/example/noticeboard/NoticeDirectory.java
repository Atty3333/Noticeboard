package com.example.noticeboard;

import java.util.ArrayList;
import java.util.List;

public final class NoticeDirectory {
    private static final List<Notice> NOTICES = new ArrayList<>();

    static {
        NOTICES.add(new Notice("Calculus Study Group", "Meeting Thursday.", "Botswana Accountancy College", "Botswana Accountancy College", "Francistown", "Academic", List.of("https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=600&q=80"), "Student123"));
        NOTICES.add(new Notice("Selling iPhone 13", "Good condition, P6000.", "University of Botswana", "University of Botswana", "Gaborone", "Electronics", List.of("https://images.unsplash.com/photo-1582139329536-e7284fece509?auto=format&fit=crop&w=600&q=80"), "Student123"));
        NOTICES.add(new Notice("Lost Car Keys", "Lost near the cafeteria.", "Botswana Accountancy College", "Botswana Accountancy College", "Gaborone", "Lost & Found", List.of("https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=600&q=80"), "Anonymous", 3));
    }

    private NoticeDirectory() {}

    public static void add(Notice notice) {
        NOTICES.add(0, notice);
    }

    public static Notice getById(String id) {
        if (id == null || id.isBlank()) return null;
        for (Notice n : NOTICES) {
            if (n.getId().equalsIgnoreCase(id)) {
                return n;
            }
        }
        return null;
    }

    public static boolean update(Notice updatedNotice) {
        for (int i = 0; i < NOTICES.size(); i++) {
            if (NOTICES.get(i).getId().equalsIgnoreCase(updatedNotice.getId())) {
                NOTICES.set(i, updatedNotice);
                return true;
            }
        }
        return false;
    }

    public static boolean delete(String id) {
        return NOTICES.removeIf(n -> n.getId().equalsIgnoreCase(id));
    }

    public static void updateAuthor(String oldAuthor, String newAuthor) {
        for (Notice n : NOTICES) {
            if (n.getAuthor().equalsIgnoreCase(oldAuthor)) {
                n.setAuthor(newAuthor);
            }
        }
    }

    public static List<Notice> search(String campus, String location, String category, String keyword) {
        List<Notice> hits = new ArrayList<>();
        for (Notice n : NOTICES) {
            if (campus != null && !campus.isBlank() && !n.getCampus().equalsIgnoreCase(campus)) continue;
            if (location != null && !location.isBlank() && !n.getLocation().equalsIgnoreCase(location)) continue;
            if (category != null && !category.isBlank() && !n.getCategory().equalsIgnoreCase(category)) continue;

            if (keyword != null && !keyword.isBlank()) {
                String lowerKeyword = keyword.toLowerCase();
                if (!n.getTitle().toLowerCase().contains(lowerKeyword) && !n.getBody().toLowerCase().contains(lowerKeyword)) {
                    continue;
                }
            }
            hits.add(n);
        }
        return hits;
    }

    public static List<Notice> getByAuthor(String author) {
        List<Notice> hits = new ArrayList<>();
        for (Notice n : NOTICES) {
            if (n.getAuthor().equalsIgnoreCase(author)) {
                hits.add(n);
            }
        }
        return hits;
    }
}