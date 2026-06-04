package com.demo.massassignment.dto;

public class UpdateUserRequestDTO {

    private String email;
    private String bio;

    public String getEmail(){
        return email;
    }

    public void setEmail(String email){
        this.email = email;
    }

    public String getBio(){
        return bio;
    }

    public void setBio(String bio){
        this.bio = bio;
    }
}