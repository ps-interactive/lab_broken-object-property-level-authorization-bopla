package com.demo.massassignment.repository;

import com.demo.massassignment.model.User;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.Map;

@Repository
public class UserRepository {

    // Simulating a database
    private final Map<Long, User> users = new HashMap<>();

    @PostConstruct
    public void init() {

        User john = new User();
        john.setId(1L);
        john.setUsername("john");
        john.setEmail("john@test.com");
        john.setBio("Standard User");
        john.setAdmin(false);

        User admin = new User();
        admin.setId(2L);
        admin.setUsername("admin");
        admin.setEmail("admin@test.com");
        admin.setBio("Administrator");
        admin.setAdmin(true);

        users.put(1L, john);
        users.put(2L, admin);
    }

    public User findById(Long id) {
        return users.get(id);
    }

    public User save(User user) {
        // Storing in local Map - in production you will store it in a database, 
        // like MySQL, Oracle, MongoDB, etc.
        System.out.println("User ID: " + user.getId());
        System.out.println("isAdmin: " + user.isAdmin());
        users.put(user.getId(), user);
        return user;
    }
}
