package com.demo.massassignment.controller;

// import com.demo.massassignment.dto.UpdateUserRequestDTO;
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
            @RequestBody User existingUser
    ) {
        existingUser.setId(id);
        return userRepository.save(existingUser);
    }
}
