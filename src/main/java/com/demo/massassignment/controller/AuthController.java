package com.demo.massassignment.controller;

import org.springframework.web.bind.annotation.*;
import com.demo.massassignment.util.JwtUtil;

import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @PostMapping("/token")
    public Map<String, String> getToken(
            @RequestBody LoginRequest request) {

        if ("admin".equals(request.getUsername()) &&
                "admin123".equals(request.getPassword())) {

            String token =
                    JwtUtil.generateToken(
                            "admin",
                            "ROLE_ADMIN"
                    );

            return Map.of("token", token);
        }

        if ("user".equals(request.getUsername()) &&
                "user123".equals(request.getPassword())) {

            String token =
                    JwtUtil.generateToken(
                            "user",
                            "ROLE_USER"
                    );

            return Map.of("token", token);
        }

        throw new RuntimeException("Invalid credentials");
    }
}
