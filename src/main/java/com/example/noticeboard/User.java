package com.example.noticeboard;

import java.util.ArrayList;
import java.util.List;

public class User {
    private String username;
    private String email;
    private String password;
    private String profilePictureUrl;
    private String campus;
    private String location;
    private List<String> interests;
    private List<String> hobbies;

    public User(String username, String email, String password, String profilePictureUrl, String campus, String location, List<String> interests, List<String> hobbies) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.profilePictureUrl = profilePictureUrl;
        this.campus = campus;
        this.location = location;
        this.interests = interests != null ? interests : new ArrayList<>();
        this.hobbies = hobbies != null ? hobbies : new ArrayList<>();
    }

    public String getUsername() { return username; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public String getProfilePictureUrl() { return profilePictureUrl; }
    public String getCampus() { return campus; }
    public String getLocation() { return location; }
    public List<String> getInterests() { return interests; }
    public List<String> getHobbies() { return hobbies; }

    public void setUsername(String username) { this.username = username; }
    public void setEmail(String email) { this.email = email; }
    public void setPassword(String password) { this.password = password; }
    public void setProfilePictureUrl(String profilePictureUrl) { this.profilePictureUrl = profilePictureUrl; }
    public void setCampus(String campus) { this.campus = campus; }
    public void setLocation(String location) { this.location = location; }
    public void setInterests(List<String> interests) { this.interests = interests; }
    public void setHobbies(List<String> hobbies) { this.hobbies = hobbies; }
}