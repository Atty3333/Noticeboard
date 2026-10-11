package com.example.noticeboard;

import java.util.ArrayList;
import java.util.List;

public final class UserDirectory {
    private static final List<User> USERS = new ArrayList<>();

    static {
        USERS.add(new User("Student123", "student@bac.ac.bw", "password123", null, "Botswana Accountancy College", "Gaborone", List.of("Technology", "Startups"), List.of("Gaming", "Reading")));
        USERS.add(new User("admin", "admin@bac.ac.bw", "admin", null, "Botswana Accountancy College", "Gaborone", List.of("System Administration"), List.of("Chess")));
    }

    private UserDirectory() {}

    public static boolean register(User user) {
        for (User u : USERS) {
            if (u.getUsername().equalsIgnoreCase(user.getUsername())) return false;
        }
        USERS.add(user);
        return true;
    }

    public static boolean isUsernameTaken(String username, String currentUsername) {
        for (User u : USERS) {
            if (!u.getUsername().equalsIgnoreCase(currentUsername) && u.getUsername().equalsIgnoreCase(username)) {
                return true;
            }
        }
        return false;
    }

    public static boolean updateUser(User updatedUser) {
        int index = USERS.indexOf(updatedUser);
        if (index != -1) {
            USERS.set(index, updatedUser);
            return true;
        }
        return false;
    }

    public static User authenticate(String username, String password) {
        for (User u : USERS) {
            if (u.getUsername().equalsIgnoreCase(username) && u.getPassword().equals(password)) return u;
        }
        return null;
    }

    public static User getUserByUsername(String username) {
        for (User u : USERS) {
            if (u.getUsername().equalsIgnoreCase(username)) return u;
        }
        return null;
    }
}