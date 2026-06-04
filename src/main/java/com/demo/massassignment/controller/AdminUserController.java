package com.demo.massassignment.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.demo.massassignment.dto.UpdateUserRoleRequestDTO;
import com.demo.massassignment.model.User;
import com.demo.massassignment.repository.UserRepository;

@RestController
@RequestMapping("/api/admin/users")
public class AdminUserController {

    private final UserRepository userRepository;

    public AdminUserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PutMapping("/{id}/role")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> updateRole(
            @PathVariable("id") Long id,
            @RequestBody UpdateUserRoleRequestDTO request
    ) {

        User existingUser = userRepository.findById(id);

        if (existingUser == null) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "User not found"
            );
        }

        // Only administrative requests hitting this endpoint can alter the admin flag
        existingUser.setAdmin(request.isAdmin());
        userRepository.save(existingUser);

        return ResponseEntity.noContent().build();
    }
}