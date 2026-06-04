package com.demo.massassignment.controller;

import com.demo.massassignment.dto.UpdateUserRequestDTO;
import com.demo.massassignment.model.User;
import com.demo.massassignment.repository.UserRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/{id}")
    public User getUser(@PathVariable("id") Long id) {

        return userRepository.findById(id);
    }

    // =====================================================
    // VULNERABLE ENDPOINT
    // =====================================================
    //
    // MASS ASSIGNMENT VULNERABILITY:
    //
    // Spring automatically binds ALL incoming JSON fields
    // into the User object.
    //
    // An attacker can send:
    //
    // {
    //   "isAdmin": true
    // }
    //
    // and escalate privileges.
    //
    // Learners must fix this using DTOs.
    //
    // =====================================================

    @PutMapping("/{id}")
    public User updateUser(
            @PathVariable("id") Long id,
            @RequestBody UpdateUserRequestDTO request
    ) {

        // 1. Fetch the existing user entity from the simulated database
        User existingUser = userRepository.findById(id);
        if (existingUser == null) {
            throw new RuntimeException("User not found with id: " + id);
        }

        // 2. Explicitly map only the allowed fields from the DTO to the model object
        if (request.getEmail() != null) {
            existingUser.setEmail(request.getEmail());
        }
        if (request.getBio() != null) {
            existingUser.setBio(request.getBio());
        }

        // 3. Save the modified User object (its 'admin' property remains unchanged)
        return userRepository.save(existingUser);
    }
}
